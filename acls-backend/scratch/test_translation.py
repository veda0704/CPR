import os
import sys
import django
from django.utils.translation import gettext_lazy as _

# Setup Django
sys.path.append(r"d:\projects\CPR\acls-backend")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'acls_backend.settings')
django.setup()

from acls.translation_service import translate_dict

test_data = {
    "title": "ACLS: Scene & Check",
    "question": "Is the area safe? Tap the patient and shout. Are they awake?",
    "choices": [
        {"label": "YES, they are awake", "next": "dashboard"},
        {"label": "NO, not awake", "next": "2"}
    ]
}

translated = translate_dict(test_data, lang='te')
print("--- TRANSLATED RESPONSE ---")
import json
print(json.dumps(translated, ensure_ascii=False, indent=2))
