import json
import os

yoga_dir = '/Users/borisserzhanovich/projects/Yoga1/Yoga1'
strings_path = os.path.join(yoga_dir, 'Localizable.xcstrings')

with open(strings_path, 'r') as f:
    strings_data = json.load(f)

# Add missing keys for Onboarding
missing_keys = {
    "onb.focus.back": {"en": "Back pain", "ru": "Боли в спине"},
    "onb.focus.hips": {"en": "Hip mobility", "ru": "Подвижность таза"},
    "onb.focus.shoulders": {"en": "Shoulders & Neck", "ru": "Шея и плечи"},
    "onb.focus.stress": {"en": "Stress relief", "ru": "Снятие стресса"},
    "onb.focus.sleep": {"en": "Better sleep", "ru": "Улучшение сна"},
    "onb.focus.balance": {"en": "Balance", "ru": "Баланс"},
    "onb.time.morning": {"en": "Morning", "ru": "Утром"},
    "onb.time.afternoon": {"en": "Afternoon", "ru": "Днем"},
    "onb.time.evening": {"en": "Evening", "ru": "Вечером"},
    "today.title.flow": {"en": "Daily Flow", "ru": "Ежедневный поток"}
}

for key, translations in missing_keys.items():
    strings_data['strings'][key] = {
        "extractionState": "manual",
        "localizations": {
            "en": {"stringUnit": {"state": "translated", "value": translations["en"]}},
            "ru": {"stringUnit": {"state": "translated", "value": translations["ru"]}}
        }
    }

with open(strings_path, 'w') as f:
    json.dump(strings_data, f, indent=2, ensure_ascii=False)

print("Added missing localizations.")
