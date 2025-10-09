#!/usr/bin/env python3
"""
Fix missing Services files in Xcode project by adding them to the project.pbxproj
"""

import os
import re
from pathlib import Path

# Project root directory
PROJECT_ROOT = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
PROJECT_FILE = os.path.join(PROJECT_ROOT, "FinanceMate.xcodeproj/project.pbxproj")
SERVICES_DIR = os.path.join(PROJECT_ROOT, "FinanceMate/Services")

# Services that need to be added to the project
MISSING_SERVICES = [
    "EmailCacheService.swift",
    "GmailArchiveService.swift",
    "ImportTracker.swift",
    "PaginationManager.swift",
    "TransactionBuilder.swift"
]

def read_project_file():
    """Read the current project.pbxproj file"""
    with open(PROJECT_FILE, 'r') as f:
        return f.read()

def write_project_file(content):
    """Write content back to project.pbxproj"""
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

def find_next_available_uuid(content):
    """Find the next available UUID for project items"""
    # Extract all existing UUIDs
    uuid_pattern = r'([A-Z0-9]{24})'
    existing_uuids = set(re.findall(uuid_pattern, content))

    # Generate a new UUID that doesn't exist
    import random
    import string
    while True:
        chars = string.ascii_uppercase + string.digits
        new_uuid = ''.join(random.choice(chars) for _ in range(24))
        if new_uuid not in existing_uuids:
            return new_uuid

def add_file_to_project(content, filename):
    """Add a service file to the Xcode project"""
    filepath = os.path.join(SERVICES_DIR, filename)
    if not os.path.exists(filepath):
        print(f" File not found: {filepath}")
        return content, None

    print(f" Adding {filename} to project...")

    # Generate UUIDs for the file and build file
    file_ref_uuid = find_next_available_uuid(content)
    build_file_uuid = find_next_available_uuid(content)

    # Find the main group UUID (usually the first group)
    main_group_match = re.search(r'mainGroup = ([A-Z0-9]{24});', content)
    if not main_group_match:
        print(" Could not find main group")
        return content, None
    main_group_uuid = main_group_match.group(1)

    # Find the FinanceMate target UUID
    target_match = re.search(r'PBXNativeTarget.*\n.*name = FinanceMate.*;\n.*productRef = ([A-Z0-9]{24});', content, re.DOTALL)
    if not target_match:
        print(" Could not find FinanceMate target")
        return content, None
    # Extract target UUID from the match
    target_full_match = target_match.group(0)
    target_uuid_match = re.search(r'([A-Z0-9]{24})\s*=\s*\{[^}]*name\s*=\s*FinanceMate', target_full_match)
    if not target_uuid_match:
        print(" Could not extract FinanceMate target UUID")
        return content, None
    target_uuid = target_uuid_match.group(1)

    # Add file reference
    file_ref_entry = f"""\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{filename}"; sourceTree = "<group>"; }};"""

    # Find where to insert the file reference (after other file references)
    file_ref_section_match = re.search(r'(/* End PBXFileReference section\s*\*/)', content)
    if file_ref_section_match:
        content = content[:file_ref_section_match.start()] + file_ref_entry + '\n' + content[file_ref_section_match.start():]

    # Add build file
    build_file_entry = f"""\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};"""

    # Find where to insert the build file (after other build files)
    build_file_section_match = re.search(r'(/* End PBXBuildFile section\s*\*/)', content)
    if build_file_section_match:
        content = content[:build_file_section_match.start()] + build_file_entry + '\n' + content[build_file_section_match.start():]

    # Add to Sources build phase
    sources_phase_match = re.search(r'PBXSourcesBuildPhase = \(\s*isa = PBXSourcesBuildPhase;(.*?files = \([^)]*\);)', content, re.DOTALL)
    if sources_phase_match:
        sources_content = sources_phase_match.group(1)
        # Find where to insert the build file reference
        files_match = re.search(r'files = \(\s*([^)]*)\s*\);', sources_content)
        if files_match:
            files_list = files_match.group(1)
            new_files_list = files_list.rstrip() + f'\n\t\t\t\t{build_file_uuid} /* {filename} in Sources */,'
            new_sources_content = sources_content.replace(files_match.group(0), f'files = (\n{new_files_list}\n\t\t\t);')
            content = content.replace(sources_phase_match.group(0), f'PBXSourcesBuildPhase = (\n\t\t\tisa = PBXSourcesBuildPhase;{new_sources_content})')

    # Add to group (Services group)
    services_group_match = re.search(r'([A-Z0-9]{24}) /\* Services \*/ = \{', content)
    if services_group_match:
        services_group_uuid = services_group_match.group(1)
        # Find the group definition and add the file
        group_def_pattern = f'{services_group_uuid} /\\* Services \\*/ = {{\\s*isa = PBXGroup;\\s*children = \\([^)]*\\);'
        group_match = re.search(group_def_pattern, content, re.DOTALL)
        if group_match:
            children_content = group_match.group(0)
            # Find the children array and add the file reference
            children_array_match = re.search(r'children = \(\s*([^)]*)\s*\);', children_content)
            if children_array_match:
                children_list = children_array_match.group(1)
                new_children_list = children_list.rstrip() + f'\n\t\t\t\t{file_ref_uuid} /* {filename} */,'
                new_group_content = children_content.replace(children_array_match.group(0), f'children = (\n{new_children_list}\n\t\t\t);')
                content = content.replace(group_match.group(0), new_group_content)

    print(f" Added {filename} with UUIDs: file={file_ref_uuid}, build={build_file_uuid}")
    return content, (file_ref_uuid, build_file_uuid)

def main():
    """Main function to fix missing services"""
    print(" Fixing missing Services files in Xcode project...")

    # Check if project file exists
    if not os.path.exists(PROJECT_FILE):
        print(f" Project file not found: {PROJECT_FILE}")
        return

    # Read current project file
    content = read_project_file()

    # Track added files
    added_files = []

    # Add each missing service file
    for service_file in MISSING_SERVICES:
        # Check if file already exists in project
        if service_file in content:
            print(f" {service_file} already exists in project")
            continue

        # Add file to project
        content, uuids = add_file_to_project(content, service_file)
        if uuids:
            added_files.append(service_file)

    # Write updated project file
    write_project_file(content)

    print(f"\n Added {len(added_files)} service files to Xcode project:")
    for file in added_files:
        print(f"    {file}")

    print(f"\n Project file updated: {PROJECT_FILE}")

if __name__ == "__main__":
    main()