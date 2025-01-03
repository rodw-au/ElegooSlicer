import os
import json
import shutil
from pathlib import Path

#合并Elegoo配置文件到OrcaSlicer，需要把Elegoo Generic文件添加Elegoo头，防止和BBL冲突
#第一步需要拷贝Elegoo到指定目录，不在原文件修改
scripts_dir = Path(__file__).resolve().parent
print(f'Scripts dir: {scripts_dir}')
root_dir = scripts_dir.parent
profiles_dir = root_dir / 'resources' / 'profiles'

current_dir = Path.cwd()  
elegoo_folder_path = current_dir / 'Elegoo'  
elegoo_json_path = current_dir / 'Elegoo.json'  


if not elegoo_folder_path.exists():
    shutil.copytree(profiles_dir / 'Elegoo', elegoo_folder_path)
    print(f'Copied Elegoo folder to {elegoo_folder_path}')

if not elegoo_json_path.exists():
    shutil.copy(profiles_dir / 'Elegoo.json', elegoo_json_path)
    print(f'Copied Elegoo.json to {elegoo_json_path}')


filament_directory = elegoo_folder_path / 'filament'
machine_directory = elegoo_folder_path / 'machine'


for root, dirs, files in os.walk(filament_directory):
    for file in files:
        if file.endswith('.json'):
            file_path = os.path.join(root, file)
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if file.startswith('Generic'):
                new_file_name = 'Elegoo ' + file
                new_file_path = os.path.join(root, new_file_name)
                os.rename(file_path, new_file_path)
                file_path = new_file_path 
            

            modified = False
            if 'name' in data and data['name'].startswith('Generic'):
                data['name'] = 'Elegoo ' + data['name']
                modified = True
            
            if 'inherits' in data and data['inherits'].startswith('Generic'):
                data['inherits'] = 'Elegoo ' + data['inherits']
                modified = True
                
            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=4)

for root, dirs, files in os.walk(machine_directory):
    for file in files:
        if file.endswith('.json'):
            file_path = os.path.join(root, file)
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            modified = False
            for key in ['default_materials', 'default_filament_profile']:
                if key in data:
                    if isinstance(data[key], list):
                        data[key] = [item.replace('Generic', 'Elegoo Generic') for item in data[key]]
                    elif isinstance(data[key], str):
                        data[key] = data[key].replace('Generic', 'Elegoo Generic')
                    modified = True

            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=4)


with open(elegoo_json_path, 'r', encoding='utf-8') as f:
    elegoo_data = json.load(f)

modified = False
for filament in elegoo_data.get('filament_list', []):
    if 'name' in filament and filament['name'].startswith('Generic'): 
        if 'sub_path' in filament and filament['name'] in filament['sub_path']:
            filament['sub_path'] = filament['sub_path'].replace(filament['name'], 'Elegoo ' + filament['name'])
                        
        filament['name'] = 'Elegoo ' + filament['name']
        modified = True

if modified:
    with open(elegoo_json_path, 'w', encoding='utf-8') as f:
        json.dump(elegoo_data, f, ensure_ascii=False, indent=4)
print("处理完成")