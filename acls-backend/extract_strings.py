import os
import re

workflow_dir = r'd:\projects\CPR\acls-backend\acls\workflows'
strings = set()

for filename in os.listdir(workflow_dir):
    if filename.endswith('.py'):
        with open(os.path.join(workflow_dir, filename), 'r', encoding='utf-8') as f:
            content = f.read()
            # Match _("...") or _('...')
            matches = re.findall(r'_\(["\'](.*?)["\']\)', content)
            for m in matches:
                strings.add(m)

with open(r'd:\projects\CPR\acls-backend\extracted_strings.txt', 'w', encoding='utf-8') as f:
    for s in sorted(list(strings)):
        f.write(s + '\n')

print(f"Extracted {len(strings)} strings")
