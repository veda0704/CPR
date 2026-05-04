from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from .models import User

COMMON_PASSWORDS = {
    'password',
    '12345678',
    'qwerty',
    'abc123',
    'letmein',
    'admin',
    'welcome',
}

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name')

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    remember_me = serializers.BooleanField(required=False, default=False)

class SignupSerializer(serializers.ModelSerializer):
    confirm_password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ('email', 'first_name', 'last_name', 'password', 'confirm_password')
        extra_kwargs = {'password': {'write_only': True}}

    def validate_email(self, value):
        """Validate that email is not already used by an active account."""
        # Check if there's an active user with this email
        if User.objects.filter(email__iexact=value, is_active=True).exists():
            raise serializers.ValidationError('An active account already exists with this email.', code='email_in_use')
        return value.lower()

    def validate_password(self, value):
        """Validate password complexity using Django's password validators."""
        if not value or len(value) < 8:
            raise serializers.ValidationError('Password must be at least 8 characters long.', code='password_short')

        if value.lower() in COMMON_PASSWORDS:
            raise serializers.ValidationError('Password is too common.', code='password_common')

        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(list(e.messages), code='password_weak')
        return value

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({
                'confirm_password': ['Passwords do not match.'],
            }, code='password_mismatch')
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        return User.objects.create_user(**validated_data)
