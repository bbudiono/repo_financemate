#!/usr/bin/env python3
"""
Add Missing Files to Xcode Project
Adds files that exist in the filesystem but are missing from project.pbxproj
"""

import os
import sys
import uuid
import re

def generate_uuid():
    """Generate a UUID for Xcode project references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_missing_files_to_project(project_file_path):
    """Add missing files to Xcode project.pbxproj"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Files that need to be added to the project
    missing_files = [
        {
            'path': 'FinanceMate/Views/Settings/SettingsSidebar.swift',
            'name': 'SettingsSidebar.swift',
            'group': 'Settings'
        },
        {
            'path': 'FinanceMate/Views/Settings/SettingsContent.swift',
            'name': 'SettingsContent.swift',
            'group': 'Settings'
        }
    ]

    changes_made = 0

    for file_info in missing_files:
        file_path = file_info['path']
        file_name = file_info['name']

        # Check if file reference already exists
        if file_name in content:
            print(f"️  {file_name} already exists in project")
            continue

        # Check if actual file exists
        full_path = os.path.join(os.path.dirname(project_file_path), '..', file_path)
        if not os.path.exists(full_path):
            print(f" File does not exist: {full_path}")
            continue

        # Generate UUIDs for the file reference and build file
        file_ref_uuid = generate_uuid()
        build_file_uuid = generate_uuid()

        # Find the Settings group or create it
        settings_group_pattern = r'(/\* Settings \*/ = \{[^}]+children = \([^)]+)\);'
        settings_match = re.search(settings_group_pattern, content)

        if settings_match:
            # Add file reference to Settings group
            group_content = settings_match.group(1)
            new_group_content = group_content + f'\n\t\t\t\t{file_ref_uuid} /* {file_name} */,'
            content = content.replace(group_content, new_group_content)

            # Add file reference section
            file_ref_section = f"""/* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{file_name}"; sourceTree = "<group>"; }};"""

            # Find PBXFileReference section and add to it
            pbx_file_ref_pattern = r'(/* End PBXFileReference section */)'
            if re.search(pbx_file_ref_pattern, content):
                content = content.replace(pbx_file_ref_pattern, f'\n\t\t{file_ref_section}\n{pbx_file_ref_pattern}')
            else:
                print(f" Could not find PBXFileReference section")
                continue

            # Add build file reference
            build_file_section = f"""{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} */; }};"""

            # Find PBXBuildFile section and add to it
            pbx_build_file_pattern = r'(/* End PBXBuildFile section */)'
            if re.search(pbx_build_file_pattern, content):
                content = content.replace(pbx_build_file_pattern, f'\n\t\t{build_file_section}\n{pbx_build_file_pattern}')
            else:
                print(f" Could not find PBXBuildFile section")
                continue

            # Add to Sources build phase
            sources_build_phase_pattern = r'(/\* Sources \*/ = \{[^}]+files = \([^)]+)\);'
            sources_match = re.search(sources_build_phase_pattern, content)

            if sources_match:
                sources_content = sources_match.group(1)
                new_sources_content = sources_content + f'\n\t\t\t\t{build_file_uuid} /* {file_name} */,'
                content = content.replace(sources_content, new_sources_content)
            else:
                print(f" Could not find Sources build phase")
                continue

            print(f" Added {file_name} to project")
            changes_made += 1
        else:
            print(f" Could not find Settings group in project")

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)
        print(f"\n Added {changes_made} files to {project_file_path}")
        return True
    else:
        print(f"\nℹ️ No files needed to be added")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Adding missing files to Xcode project...")
        success = add_missing_files_to_project(project_file)

        if success:
            print(" Missing files added successfully!")
        else:
            print("ℹ️ No files needed to be added")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)