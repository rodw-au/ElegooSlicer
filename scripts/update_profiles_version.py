import os
import json
import re
from pathlib import Path

def update_version_in_json(folder_path, new_version):
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path) and file_name.endswith('.json'):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                if 'version' in data:
                    data['version'] = new_version
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=4)
                    print(f"Updated version in {file_path}")
                else:
                    print(f"No 'version' key found in {file_path}")
            
            except Exception as e:
                print(f"Failed to process {file_path}: {e}")


scripts_dir = Path(__file__).resolve().parent
root_dir = scripts_dir.parent
profiles_dir = root_dir / 'resources' / 'profiles'
version_pattern = r'^\d{2}\.\d{2}\.\d{2}\.\d{2}$'

while True:
    new_version = input("Please enter the new version (format: 01.01.05.00): ")
    if re.match(version_pattern, new_version):
        break
    else:
        print("Invalid version format. Please follow the format: XX.XX.XX.XX, where each part is a two-digit number.")


update_version_in_json(profiles_dir, new_version)
