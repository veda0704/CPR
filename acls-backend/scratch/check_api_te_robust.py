import requests
import json
import sys

# Ensure UTF-8 output even in limited terminals
sys.stdout.reconfigure(encoding='utf-8')

def test_lang(lang):
    url = "http://localhost:8002/api/acls/step/1/"
    headers = {"Accept-Language": lang}
    response = requests.get(url, headers=headers)
    print(f"--- LANGUAGE: {lang} ---")
    if response.status_code == 200:
        print(json.dumps(response.json(), ensure_ascii=False, indent=2))
    else:
        print(f"Error {response.status_code}: {response.text}")
    print("\n")

test_lang("te")
test_lang("te-IN")
