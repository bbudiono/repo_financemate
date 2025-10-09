#!/usr/bin/env python3

import os
import re
import random
import string

def generate_uuid():
    """Generate a valid 24-character Xcode UUID"""
    chars = string.ascii_uppercase + string.digits + string.ascii_lowercase
    return ''.join(random.choices(chars, k=24))

def fix_bank_connection_files():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Files to fix
    files_to_fix = [
        'BankConnectionView.swift',
        'BankConnectionStatusView.swift',
        'BankInstitutionListView.swift',
        'BankLoginFormView.swift'
    ]

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Find the PBXFileReference section
    file_ref_pattern = r'(/\* PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, content)

    if not file_ref_match:
        print("Could not find PBXFileReference section")
        return False

    # Find insertion point (after the section header)
    insertion_point = file_ref_match.end()

    # Add missing file references
    new_file_refs = []
    for file_name in files_to_fix:
        # Check if file reference already exists
        if f"/* {file_name}" not in content:
            file_ref_uuid = generate_uuid()
            file_ref_entry = f"\t\t{file_ref_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file_name}\"; sourceTree = \"<group>\"; }};"
            new_file_refs.append(file_ref_entry)

    if new_file_refs:
        # Insert new file references
        content = content[:insertion_point] + '\n' + '\n'.join(new_file_refs) + '\n\n' + content[insertion_point:]
        print(f"Added {len(new_file_refs)} missing file references")

    # Fix the Settings group children - remove incorrect references and add correct ones
    settings_group_pattern = r'(CDF8CD17DB1E4DB0B902574C /\* Settings \*/ = {{\s*isa = PBXGroup;\s*children = \(\s*)(.*?)(\s*\);\s*path = Settings; sourceTree = \"<group>\";}};)'
    settings_match = re.search(settings_group_pattern, content, re.DOTALL)

    if not settings_match:
        print("Could not find Settings group")
        return False

    # Fix the Settings group children
    group_start = settings_match.group(1)
    group_content = settings_match.group(2)
    group_end = settings_match.group(3)

    # Remove incorrect bank connection references
    lines = group_content.split('\n')
    corrected_lines = []

    for line in lines:
        # Remove the problematic build phase references and keep proper file references
        if any(f"/* {file}" in line for file in files_to_fix):
            # Skip build phase references (they end with "in Sources */")
            if line.strip().endswith("in Sources */"):
                continue
            # Keep file references (they don't end with "in Sources */")
            if "/* BankConnection" in line and not line.strip().endswith("in Sources */"):
                corrected_lines.append(line)
        else:
            corrected_lines.append(line)

    # Add missing file references to Settings group
    for file_name in files_to_fix:
        file_ref_pattern = f"(\w{{24}}) /\* {file_name} \*/ = {{isa = PBXFileReference;"
        file_ref_match = re.search(file_ref_pattern, content)
        if file_ref_match and not any(f"/* {file_name} */" in line for line in corrected_lines):
            file_ref_uuid = file_ref_match.group(1)
            corrected_lines.append(f"\t\t\t\t{file_ref_uuid} /* {file_name} */,")

    new_group_content = '\n'.join(corrected_lines)
    content = content.replace(settings_match.group(0), group_start + new_group_content + group_end)

    # Fix the Sources build phase - ensure all bank connection files are included
    sources_phase_pattern = r'(\w{{24}} /\* Sources \*/ = {{\s*isa = PBXSourcesBuildPhase;\s*buildActionMask = .*?;\s*files = \(\s*)(.*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;}};)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)

    if not sources_match:
        print("Could not find Sources build phase")
        return False

    phase_start = sources_match.group(1)
    phase_content = sources_match.group(2)
    phase_end = sources_match.group(3)

    # Ensure all bank connection build files are in Sources build phase
    phase_lines = phase_content.split('\n')

    for file_name in files_to_fix:
        # Find the build file UUID for this file
        build_file_pattern = f"(\w{{24}}) /\* {file_name} in Sources \*/ = {{isa = PBXBuildFile;"
        build_file_match = re.search(build_file_pattern, content)
        if build_file_match:
            build_file_uuid = build_file_match.group(1)
            if not any(build_file_uuid in line for line in phase_lines):
                phase_lines.append(f"\t\t\t\t{build_file_uuid} /* {file_name} in Sources */,")

    new_phase_content = '\n'.join(phase_lines)
    content = content.replace(sources_match.group(0), phase_start + new_phase_content + phase_end)

    # Write updated content
    with open(project_file, 'w') as f:
        f.write(content)

    print("Fixed bank connection file references")
    return True

if __name__ == "__main__":
    # Change to the correct directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    if fix_bank_connection_files():
        print("Successfully fixed bank connection file references")
    else:
        print("Failed to fix bank connection file references")