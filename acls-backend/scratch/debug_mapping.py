import os
import sys
import django

# Setup Django
sys.path.append(r"d:\projects\CPR\acls-backend")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'acls_backend.settings')
django.setup()

from acls.translation_service import TELUGU_MAPPINGS

print(f"Total keys in mapping: {len(TELUGU_MAPPINGS)}")

keys_to_check = [
    "ACLS: Scene & Check",
    "Is the area safe? Tap the patient and shout. Are they awake?",
    "YES, they are awake",
    "NO, not awake"
]

print("--- MAPPING STATUS ---")
for k in keys_to_check:
    val = TELUGU_MAPPINGS.get(k)
    print(f"Key: '{k}'")
    print(f"Val: '{val}'")
    print("-" * 20)
