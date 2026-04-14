import requests
import json

url = "http://localhost:8002/api/acls/step/1/"
headers = {"Accept-Language": "te"}

response = requests.get(url, headers=headers)
print("Status Code:", response.status_code)
print("--- RESPONSE ---")
print(json.dumps(response.json(), ensure_ascii=False, indent=2))
