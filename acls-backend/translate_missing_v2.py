import json
import os
import re
import sys
from acls.translation_service import TELUGU_MAPPINGS
from deep_translator import GoogleTranslator
import time

# Ensure UTF-8 output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

log_file = r"d:\projects\CPR\acls-backend\translation_log.txt"

def log(msg):
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {msg}\n")
    print(msg)

log("Starting translation script...")

backend_dir = r"d:\projects\CPR\acls-backend"
po_translations_path = os.path.join(backend_dir, 'acls', 'po_translations.json')
django_po_path = os.path.join(backend_dir, 'locale', 'te', 'LC_MESSAGES', 'django.po')

# 1. Load existing po_translations.json
if os.path.exists(po_translations_path):
    with open(po_translations_path, 'r', encoding='utf-8') as f:
        existing_json_translations = json.load(f)
else:
    existing_json_translations = {}

log(f"Loaded {len(existing_json_translations)} existing translations from JSON.")

# 2. Add existing ones to cache
translation_cache = {}
translation_cache.update(TELUGU_MAPPINGS)
translation_cache.update(existing_json_translations)

# 3. Parse django.po for more existing translations
if os.path.exists(django_po_path):
    with open(django_po_path, 'r', encoding='utf-8') as f:
        content = f.read()
        blocks = content.split('\n\n')
        for block in blocks:
            msgid_match = re.search(r'msgid\s+"(.*?)"(?=\nmsgstr|\nmsgid_plural)', block, re.DOTALL)
            msgstr_match = re.search(r'msgstr\s+"(.*?)"', block, re.DOTALL)
            if msgid_match and msgstr_match:
                msgid = msgid_match.group(1).replace('"\n"', '').replace('\\n', '\n')
                msgstr = msgstr_match.group(1).replace('"\n"', '').replace('\\n', '\n')
                if msgid and msgstr and msgid not in translation_cache:
                    translation_cache[msgid] = msgstr

log(f"Total translations in cache (including manual & PO): {len(translation_cache)}")

# 4. Load extracted strings
with open(os.path.join(backend_dir, 'extracted_strings.txt'), 'r', encoding='utf-8') as f:
    extracted = [line.strip() for line in f if line.strip()]

missing_strings = []
for orig_s in extracted:
    s = orig_s.replace('\\t', '\t').replace('\\n', '\n')
    if s not in translation_cache and s.strip() not in translation_cache:
        missing_strings.append(s)

log(f"Total extracted strings: {len(extracted)}")
log(f"Total already translated: {len(extracted) - len(missing_strings)}")
log(f"Translating {len(missing_strings)} missing strings...")

if not missing_strings:
    log("No new translations needed.")
    sys.exit(0)

translator = GoogleTranslator(source='en', target='te')

# Translate missing strings
new_translations = {}
count = 0
for string in missing_strings:
    try:
        te_str = translator.translate(string)
        new_translations[string] = te_str
        count += 1
        if count % 10 == 0:
            log(f"Translated {count}/{len(missing_strings)} ...")
        time.sleep(0.1)  # Faster delay
    except Exception as e:
        log(f"Failed to translate: {string} -> {e}")

    # Periodic save every 50 translations
    if count > 0 and count % 50 == 0:
        temp_translations = existing_json_translations.copy()
        temp_translations.update(new_translations)
        with open(po_translations_path, 'w', encoding='utf-8') as f:
            json.dump(temp_translations, f, ensure_ascii=False, indent=2)
        log(f"Saved progress at {count} translations.")

if new_translations:
    existing_json_translations.update(new_translations)
    with open(po_translations_path, 'w', encoding='utf-8') as f:
        json.dump(existing_json_translations, f, ensure_ascii=False, indent=2)
    log("po_translations.json updated successfully!")
else:
    log("Done. No new translations added.")
