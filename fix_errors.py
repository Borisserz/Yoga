import os
import glob
import re

yoga_dir = '/Users/borisserzhanovich/projects/Yoga1/Yoga1'

# 1. Remove 'public ' modifiers from all Swift files
for filepath in glob.glob(os.path.join(yoga_dir, '**', '*.swift'), recursive=True):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove 'public ' at the start of a line or after whitespace
    # except 'public import'
    content = re.sub(r'(\s*)public (?!import)', r'\1', content)
    # Also handle start of line without whitespace
    content = re.sub(r'^public (?!import)', r'', content)
    
    with open(filepath, 'w') as f:
        f.write(content)

# 2. Add 'displayName', 'refreshReminders', and fix saveUserStats in AppState.swift
appstate_path = os.path.join(yoga_dir, 'AppState.swift')
with open(appstate_path, 'r') as f:
    appstate_content = f.read()

# Add displayName
if 'var displayName: String' not in appstate_content:
    appstate_content = appstate_content.replace(
        'var currentUserId: String = "local_user"',
        'var currentUserId: String = "local_user"\n    var displayName: String = "Yogi"'
    )

# Fix saveUserStats call
appstate_content = appstate_content.replace(
    '''FirebaseManager.shared.saveUserStats(userId: currentUserId,
                                             minutes: completedMinutes,
                                             streak: streakDays)''',
    '''FirebaseManager.shared.saveUserStats(userId: currentUserId,
                                             name: displayName,
                                             minutes: completedMinutes,
                                             streak: streakDays,
                                             xp: totalXP,
                                             level: level)'''
)

# Add refreshReminders
if 'func refreshReminders()' not in appstate_content:
    appstate_content = appstate_content.replace(
        'func reset() {',
        '''func refreshReminders() {
        NotificationManager.shared.scheduleSmartReminders(streakDays: streakDays, hasPracticedToday: practicedToday)
    }

    func reset() {'''
    )

with open(appstate_path, 'w') as f:
    f.write(appstate_content)

# 3. Fix YogaEpicApp.swift closure signature
app_path = os.path.join(yoga_dir, 'YogaEpicApp .swift')
with open(app_path, 'r') as f:
    app_content = f.read()

app_content = app_content.replace('.onChange(of: scenePhase) { _, newPhase in', '.onChange(of: scenePhase) { oldPhase, newPhase in')

with open(app_path, 'w') as f:
    f.write(app_content)

print("Errors fixed programmatically.")
