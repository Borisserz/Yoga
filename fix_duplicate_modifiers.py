import os
import glob

yoga_dir = '/Users/borisserzhanovich/projects/Yoga1/Yoga1'

for filepath in glob.glob(os.path.join(yoga_dir, '**', '*.swift'), recursive=True):
    with open(filepath, 'r') as f:
        content = f.read()
    
    modified = False
    
    if 'internal internal' in content:
        content = content.replace('internal internal', 'internal')
        modified = True
        
    if 'public public' in content:
        content = content.replace('public public', 'public')
        modified = True
        
    if modified:
        with open(filepath, 'w') as f:
            f.write(content)

print("Duplicate modifiers fixed.")
