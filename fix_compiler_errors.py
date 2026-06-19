import json
import os

yoga_dir = '/Users/borisserzhanovich/projects/Yoga1/Yoga1'

# --- 1. Fix AICameraSessionView.swift ---
camera_view_path = os.path.join(yoga_dir, 'AI', 'AICameraSessionView.swift')
with open(camera_view_path, 'r') as f:
    content = f.read()

if 'import AVFoundation' not in content:
    content = content.replace('import Vision', 'import Vision\nimport AVFoundation')

# Wrap timer closure in Task { @MainActor in }
if 'Task { @MainActor in' not in content:
    content = content.replace(
        'guard !finished else { return }',
        'Task { @MainActor in\n                guard !finished else { return }'
    )
    content = content.replace(
        'correctTime = max(0, correctTime - 0.25)\n                }\n            }\n        }',
        'correctTime = max(0, correctTime - 0.25)\n                }\n            }\n            }\n        }'
    )

with open(camera_view_path, 'w') as f:
    f.write(content)

# --- 2. Fix Localizable.xcstrings ---
strings_path = os.path.join(yoga_dir, 'Localizable.xcstrings')
with open(strings_path, 'r') as f:
    strings_data = json.load(f)

def rename_key(old_key, new_key):
    if old_key in strings_data['strings']:
        strings_data['strings'][new_key] = strings_data['strings'].pop(old_key)

rename_key('%lld%%', 'score.percent')
rename_key('%lld XP', 'xp.total')
rename_key('+%lld XP', 'xp.earned')
rename_key('Your level?', 'onb.level.title')
rename_key('Your level', 'onb.level.short')

with open(strings_path, 'w') as f:
    json.dump(strings_data, f, indent=2, ensure_ascii=False)

# --- 3. Replace usages in Swift files ---
replacements = [
    ('L("%lld%%"', 'L("score.percent"'),
    ('L("%lld XP"', 'L("xp.total"'),
    ('L("+%lld XP"', 'L("xp.earned"'),
    ('Text("Your level?")', 'Text("onb.level.title")'),
    ('Text("Your level")', 'Text("onb.level.short")')
]

import glob
for filepath in glob.glob(os.path.join(yoga_dir, '**', '*.swift'), recursive=True):
    with open(filepath, 'r') as f:
        file_content = f.read()
    
    modified = False
    for old_str, new_str in replacements:
        if old_str in file_content:
            file_content = file_content.replace(old_str, new_str)
            modified = True
            
    if modified:
        with open(filepath, 'w') as f:
            f.write(file_content)

print("Errors fixed successfully.")
