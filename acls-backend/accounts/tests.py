from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from django.core import mail
from rest_framework.test import APIClient
from rest_framework import status

User = get_user_model()


class AuthenticationTestCase(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_data = {
            'email': 'test@example.com',
            'password': 'testpass123',
            'first_name': 'Test',
            'last_name': 'User'
        }
        self.user = User.objects.create_user(**self.user_data, is_active=True)

    def test_login_success(self):
        response = self.client.post(reverse('api_login'), {
            'email': self.user_data['email'],
            'password': self.user_data['password']
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_login_invalid_credentials(self):
        response = self.client.post(reverse('api_login'), {
            'email': self.user_data['email'],
            'password': 'wrongpassword'
        })
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data.get('code'), 'invalid_credentials')

    def test_login_inactive_user(self):
        inactive_user = User.objects.create_user(
            email='inactive@example.com',
            password='testpass123',
            first_name='Inactive',
            last_name='User',
            is_active=False
        )
        response = self.client.post(reverse('api_login'), {
            'email': 'inactive@example.com',
            'password': 'testpass123'
        })
        # Django's authenticate() returns None for inactive users, treated as invalid credentials
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data.get('code'), 'invalid_credentials')

    def test_signup_success(self):
        response = self.client.post(reverse('api_signup'), {
            'email': 'newuser@example.com',
            'password': 'newpass123',
            'confirm_password': 'newpass123',
            'first_name': 'New',
            'last_name': 'User'
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('success'))
        self.assertIn('Account created successfully', response.data.get('message'))

        # Check that user was created and is active (no email verification required)
        created_user = User.objects.get(email='newuser@example.com')
        self.assertTrue(created_user.is_active)
        self.assertEqual(created_user.first_name, 'New')
        self.assertEqual(created_user.last_name, 'User')
        
        # Check that tokens were issued
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)

    def test_signup_duplicate_email_active(self):
        response = self.client.post(reverse('api_signup'), {
            'email': self.user_data['email'],  # Already exists and is active
            'password': 'newpass123',
            'confirm_password': 'newpass123',
            'first_name': 'New',
            'last_name': 'User'
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Validation errors return 'invalid_input' code by default
        self.assertEqual(response.data.get('code'), 'invalid_input')
        self.assertIn('errors', response.data)

    def test_signup_duplicate_email_inactive_user(self):
        # Create inactive user
        inactive_user = User.objects.create_user(
            email='inactive@example.com',
            password='oldpass123',
            first_name='Old',
            last_name='Name',
            is_active=False
        )

        # Try to signup with same email - the serializer checks for ANY user with this email
        response = self.client.post(reverse('api_signup'), {
            'email': 'inactive@example.com',
            'password': 'newpass123',
            'confirm_password': 'newpass123',
            'first_name': 'New',
            'last_name': 'Name'
        })
        # Should fail validation - email already exists in database
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data.get('code'), 'invalid_input')

    def test_signup_password_mismatch(self):
        response = self.client.post(reverse('api_signup'), {
            'email': 'newuser@example.com',
            'password': 'testpass123',
            'confirm_password': 'different123',
            'first_name': 'New',
            'last_name': 'User'
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('confirm_password', response.data.get('errors', {}))

    def test_user_creation_with_custom_fields(self):
        # Test that user can be created with all custom fields
        user_data = {
            'email': 'customuser@example.com',
            'password': 'custompass123',
            'first_name': 'Custom',
            'last_name': 'User'
        }
        user = User.objects.create_user(**user_data)
        self.assertEqual(user.email, 'customuser@example.com')
        self.assertEqual(user.first_name, 'Custom')
        self.assertEqual(user.last_name, 'User')
        self.assertTrue(user.check_password('custompass123'))

    def test_password_validation_too_short(self):
        response = self.client.post(reverse('api_signup'), {
            'email': 'shortpass@example.com',
            'password': 'short',
            'confirm_password': 'short',
            'first_name': 'Short',
            'last_name': 'Pass'
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('errors', response.data)

    def test_signup_with_common_password(self):
        response = self.client.post(reverse('api_signup'), {
            'email': 'commonpass@example.com',
            'password': 'password',
            'confirm_password': 'password',
            'first_name': 'Common',
            'last_name': 'Pass'
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('errors', response.data)

    def test_get_me_authenticated(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.get(reverse('api_me'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.user_data['email'])

    def test_get_me_unauthenticated(self):
        response = self.client.get(reverse('api_me'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
