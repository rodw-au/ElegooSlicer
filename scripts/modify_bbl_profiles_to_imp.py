import os
import json
import shutil
from pathlib import Path

#合并OrcaSlicer配置文件到Elegoo，需要把BBL Generic文件添加Bambu头，防止和Elegoo冲突
#第一步需要先把OrcaSlicer的配置文件放到Elegoo profiles文件夹下
scripts_dir = Path(__file__).resolve().parent
print(f'Scripts dir: {scripts_dir}')
root_dir = scripts_dir.parent
profiles_dir = root_dir / 'resources' / 'profiles'


filament_directory = profiles_dir / 'BBL' / 'filament'
machine_directory = profiles_dir / 'BBL' / 'machine'
bbl_json_path =  profiles_dir / 'BBL.json'


for root, dirs, files in os.walk(filament_directory):
    for file in files:
        if file.endswith('.json'):
            file_path = os.path.join(root, file)
            
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if file.startswith('Generic'):
                new_file_name = 'Bambu ' + file
                new_file_path = os.path.join(root, new_file_name)
                os.rename(file_path, new_file_path)
                file_path = new_file_path 
            
            modified = False
            if 'name' in data and data['name'].startswith('Generic'):
                data['name'] = 'Bambu ' + data['name']
                modified = True
            
            if 'inherits' in data and data['inherits'].startswith('Generic'):
                data['inherits'] = 'Bambu ' + data['inherits']
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
                        data[key] = [item.replace('Generic', 'Bambu Generic') for item in data[key]]
                    elif isinstance(data[key], str):
                        data[key] = data[key].replace('Generic', 'Bambu Generic')
                    modified = True
            

            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=4)


with open(bbl_json_path, 'r', encoding='utf-8') as f:
    bbl_data = json.load(f)

modified = False
for filament in bbl_data.get('filament_list', []):
    if 'name' in filament and filament['name'].startswith('Generic'): 
        if 'sub_path' in filament and filament['name'] in filament['sub_path']:
            filament['sub_path'] = filament['sub_path'].replace(filament['name'], 'Bambu ' + filament['name'])
                        
        filament['name'] = 'Bambu ' + filament['name']
        modified = True

if modified:
    with open(bbl_json_path, 'w', encoding='utf-8') as f:
        json.dump(bbl_data, f, ensure_ascii=False, indent=4)
print("处理完成")