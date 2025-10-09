#!/usr/bin/env python3

import os
import re
import uuid
import random

def generate_uuid():
    """Generate a valid 24-character Xcode UUID"""
    chars = string.ascii_uppercase + string.digits + string.ascii_lowercase
    return ''.join(random.choices(chars, k=24))

def add_files_to_xcode_project():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Files to add
    new_files = [
        {
            'path': 'FinanceMate/Views/Settings/BankConnectionView.swift',
            'group': 'Settings'
        },
        {
            'path': 'FinanceMate/Views/Settings/BankConnectionStatusView.swift',
            'group': 'Settings'
        },
        {
            'path': 'FinanceMate/Views/Settings/BankInstitutionListView.swift',
            'group': 'Settings'
        },
        {
            'path': 'FinanceMate/Views/Settings/BankLoginFormView.swift',
            'group': 'Settings'
        }
    ]

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Find existing patterns to locate insertion points
    settings_group_match = re.search(r'(\w{24}) \/\* Settings \*/ = {', content)
    sources_phase_match = re.search(r'(\w{24}) \/\* Sources \*/ = {', content)

    if not settings_group_match or not sources_phase_match:
        print("Could not find required groups in project file")
        return False

    settings_group_uuid = settings_group_match.group(1)
    sources_phase_uuid = sources_phase_match.group(1)

    # Generate entries for each new file
    new_file_refs = []
    new_build_files = []
    new_group_children = []
    new_source_files = []

    for file_info in new_files:
        file_path = file_info['path']
        file_name = os.path.basename(file_path)

        # Generate UUIDs
        file_ref_uuid = generate_uuid()
        build_file_uuid = generate_uuid()

        # Create file reference entry
        file_ref_entry = f"\t\t{file_ref_uuid} /* {file_name} in Sources */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file_name}\"; sourceTree = \"<group>\"; }};"
        new_file_refs.append(file_ref_entry)

        # Create build file entry
        build_file_entry = f"\t\t{build_file_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {file_name} in Sources */; }};"
        new_build_files.append(build_file_entry)

        # Create group child entry
        group_child_entry = f"\t\t\t\t{file_ref_uuid} /* {file_name} in Sources */,"
        new_group_children.append(group_child_entry)

        # Create source file entry for build phase
        source_file_entry = f"\t\t\t\t{build_file_uuid} /* {file_name} in Sources */,"
        new_source_files.append(source_file_entry)

    # Insert file references after existing ones
    file_ref_pattern = r'(/\* PBXFileReference section \*/)(.*?)(/\* PBXFrameworksBuildPhase section \*/)'
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)

    if file_ref_match:
        section_start = file_ref_match.group(1)
        section_content = file_ref_match.group(2)
        section_end = file_ref_match.group(3)

        new_section_content = section_content.rstrip() + '\n' + '\n'.join(new_file_refs) + '\n\n'
        content = content.replace(file_ref_match.group(0), section_start + new_section_content + section_end)

    # Insert build files after existing ones
    build_file_pattern = r'(/\* PBXBuildFile section \*/)(.*?)(/\* PBXCopyFilesBuildPhase section \*/)'
    build_file_match = re.search(build_file_pattern, content, re.DOTALL)

    if build_file_match:
        section_start = build_file_match.group(1)
        section_content = build_file_match.group(2)
        section_end = build_file_match.group(3)

        new_section_content = section_content.rstrip() + '\n' + '\n'.join(new_build_files) + '\n\n'
        content = content.replace(build_file_match.group(0), section_start + new_section_content + section_end)

    # Add files to Settings group
    settings_group_pattern = rf'({settings_group_uuid} \/\* Settings \*/ = {{\s*isa = PBXGroup;\s*children = \(\s*)(.*?)(\s*\);)'
    settings_match = re.search(settings_group_pattern, content, re.DOTALL)

    if settings_match:
        group_start = settings_match.group(1)
        group_content = settings_match.group(2)
        group_end = settings_match.group(3)

        new_group_content = group_content.rstrip() + '\n' + '\n'.join(new_group_children) + '\n'
        content = content.replace(settings_match.group(0), group_start + new_group_content + group_end)

    # Add files to Sources build phase
    sources_phase_pattern = rf'({sources_phase_uuid} \/\* Sources \*/ = {{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = .*?;\s*files = \(\s*)(.*?)(\s*\);)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)

    if sources_match:
        phase_start = sources_match.group(1)
        phase_content = sources_match.group(2)
        phase_end = sources_match.group(3)

        new_phase_content = phase_content.rstrip() + '\n' + '\n'.join(new_source_files) + '\n'
        content = content.replace(sources_match.group(0), phase_start + new_phase_content + phase_end)

    # Write updated content
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Successfully added {len(new_files)} files to Xcode project")
    return True

if __name__ == "__main__":
    import string
    import random

    # Change to the correct directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    if add_files_to_xcode_project():
        print("Files added successfully")
    else:
        print("Failed to add files")