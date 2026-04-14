import json
import os

backend_dir = r"d:\projects\CPR\acls-backend"

from acls.translation_service import TELUGU_MAPPINGS

with open(r"d:\projects\CPR\acls-backend\extracted_strings.txt", "r", encoding="utf-8") as f:
    extracted = [line.strip() for line in f if line.strip()]

missing = []
for s in extracted:
    # Handle newlines in strings
    s = s.replace('\\n', '\n')
    if s not in TELUGU_MAPPINGS and s.strip() not in TELUGU_MAPPINGS:
        missing.append(s)

print(f"Missing {len(missing)} strings out of {len(extracted)}")
