import os
import re

backend_dir = r"d:\projects\CPR\acls-backend"
all_strings = set()

# Paths to scan
paths_to_scan = [
    os.path.join(backend_dir, 'acls', 'workflows'),
    os.path.join(backend_dir, 'acls', 'api_views.py'),
]

for scan_path in paths_to_scan:
    if os.path.isdir(scan_path):
        for root, dirs, files in os.walk(scan_path):
            for file in files:
                if file.endswith('.py'):
                    # print(f"Scanning {file}...")
                    with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                        content = f.read()
                        # Match _("...") or _('...')
                        matches = re.findall(r'_\(["\'](.*?)["\']\)', content)
                        all_strings.update(matches)
    elif os.path.isfile(scan_path):
        with open(scan_path, 'r', encoding='utf-8') as f:
            content = f.read()
            matches = re.findall(r'_\(["\'](.*?)["\']\)', content)
            all_strings.update(matches)

# Sort and save
with open(os.path.join(backend_dir, 'extracted_strings.txt'), 'w', encoding='utf-8') as f:
    for s in sorted(list(all_strings)):
        f.write(s + '\n')

print(f"Extracted {len(all_strings)} strings to extracted_strings.txt")
