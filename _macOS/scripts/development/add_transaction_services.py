#!/usr/bin/env python3

import os
import re

def add_transaction_service_files():
    """Add transaction service files to Xcode project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Transaction service files to add
    service_files = [
        "FinanceMate/Services/TransactionDeletionService.swift",
        "FinanceMate/Services/TransactionSortingService.swift",
        "FinanceMate/Services/TransactionFilteringService.swift"
    ]

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Find last file reference
    file_ref_pattern = r'(\w+)\s*=\s*\{isa = PBXFileReference.*?};'
    file_refs = re.findall(file_ref_pattern, content)

    if not file_refs:
        print("Error: Could not find any file references")
        return

    last_ref = file_refs[-1]

    # Find build phase references
    build_phases_pattern = r'(\w+)\s*=\s*\{isa = PBXSourcesBuildPhase.*?files = \((.*?)\);'
    build_phases = re.findall(build_phases_pattern, content, re.DOTALL)

    if not build_phases:
        print("Error: Could not find build phases")
        return

    main_build_phase = build_phases[0]

    # Generate unique IDs
    import random
    import string

    def generate_id():
        chars = string.ascii_uppercase + string.digits + string.ascii_lowercase
        return ''.join(random.choice(chars) for _ in range(24))

    # Add file references and build file references
    added_count = 0
    for service_file in service_files:
        if not os.path.exists(service_file):
            print(f"Warning: {service_file} does not exist")
            continue

        if service_file in content:
            print(f"{service_file} already in project")
            continue

        file_id = generate_id()
        build_file_id = generate_id()

        # Add file reference
        file_ref = f'\n\t\t{file_id} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{service_file}"; sourceTree = "<group>"; }};'

        # Add build file reference
        build_ref = f'\n\t\t{build_file_id} = {{isa = PBXBuildFile; fileRef = {file_id}; }};'

        # Insert into appropriate sections
        content = content.replace(f'\n\t\t{last_ref} = {{isa = PBXFileReference;',
                                f'\n\t\t{file_ref}\n\t\t{last_ref} = {{isa = PBXFileReference;')

        # Add to build phase
        content = content.replace(f'\n\t\t\t\t{main_build_phase[1]} = {{isa = PBXSourcesBuildPhase;',
                                f'\n\t\t\t\t{build_file_id} = {{isa = PBXBuildFile; fileRef = {file_id} }};\n\t\t\t\t{main_build_phase[1]} = {{isa = PBXSourcesBuildPhase;')

        print(f"Added {service_file} to Xcode project")
        added_count += 1

    if added_count > 0:
        # Write updated project file
        with open(project_file, 'w') as f:
            f.write(content)

        print(f"\nSuccessfully added {added_count}/{len(service_files)} transaction service files")
        print("Project file updated successfully!")
    else:
        print("No new files to add")

if __name__ == "__main__":
    add_transaction_service_files()