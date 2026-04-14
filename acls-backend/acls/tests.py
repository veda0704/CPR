from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from unittest.mock import patch

from .workflow_data import WORKFLOW_STEPS

User = get_user_model()


class WorkflowAPITestCase(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(email="tester@example.com", password="pass123")
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)

        self.tts_patcher = patch("acls.api_views.TTSService.generate_audio", return_value="/static/audio/test.mp3")
        self.tts_patcher.start()

    def tearDown(self):
        self.tts_patcher.stop()

    def test_step_keys_are_unique(self):
        self.assertEqual(len(WORKFLOW_STEPS), len(set(WORKFLOW_STEPS.keys())))

    def test_each_step_has_title_question_and_choices(self):
        for step_id, step in WORKFLOW_STEPS.items():
            with self.subTest(step=step_id):
                self.assertIn("title", step)
                if step.get("type") == "redirect":
                    self.assertIn("next", step)
                else:
                    self.assertIn("question", step)
                    self.assertIn("choices", step)
                    self.assertIsInstance(step["choices"], list)

    def test_api_get_step_returns_valid_step(self):
        response = self.client.get(reverse("api_step", args=["scene_safety_start"]))
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["id"], "scene_safety_start")
        self.assertIn("title", data)
        self.assertIn("question", data)
        self.assertIn("video", data)
        self.assertIn("choices", data)
        self.assertGreater(len(data["choices"]), 0)

    def test_api_get_step_not_found(self):
        response = self.client.get(reverse("api_step", args=["missing_step"]))
        self.assertEqual(response.status_code, 404)
        self.assertIn("error", response.json())

    def test_api_bulk_sync_includes_all_steps(self):
        response = self.client.get(reverse("api_sync_all"))
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data), len(WORKFLOW_STEPS))
        self.assertIn("scene_safety_start", data)
        self.assertIn("bls_start", data)

    def test_api_dashboard_data_structure(self):
        response = self.client.get(reverse("api_dashboard"))
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("levels", data)
        self.assertIsInstance(data["levels"], list)
        self.assertTrue(any(level.get("id") == "level1" for level in data["levels"]))
        self.assertIn("modes", data)
        self.assertIn("Training", data["modes"])

    def test_api_get_step_accept_language_header(self):
        response = self.client.get(
            reverse("api_step", args=["scene_safety_start"]),
            HTTP_ACCEPT_LANGUAGE="te"
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["id"], "scene_safety_start")
        self.assertIn("audio_url", data)
