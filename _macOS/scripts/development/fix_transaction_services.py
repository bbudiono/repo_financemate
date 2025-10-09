#!/usr/bin/env python3

import os
import re

def add_transaction_services_to_project():
    """Add transaction service files to Xcode project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Transaction service files to add
    service_files = {
        "TransactionDeletionService.swift": "FinanceMate/Services/TransactionDeletionService.swift",
        "TransactionSortingService.swift": "FinanceMate/Services/TransactionSortingService.swift",
        "TransactionFilteringService.swift": "FinanceMate/Services/TransactionFilteringService.swift"
    }

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Check if files are already in project
    already_added = []
    to_add = {}

    for name, path in service_files.items():
        if path in content:
            already_added.append(name)
        else:
            to_add[name] = path

    if already_added:
        print(f"Already in project: {', '.join(already_added)}")

    if not to_add:
        print("All transaction service files are already in the project")
        return

    # Generate unique IDs (use simple pattern for consistency)
    import random
    import string

    def generate_id():
        chars = string.ascii_uppercase + string.digits + string.ascii_lowercase
        return ''.join(random.choice(chars) for _ in range(24))

    # Find where to insert file references (after existing service files)
    insert_point = content.find("/* FinanceMate */ = {")
    if insert_point == -1:
        print("Error: Could not find FinanceMate group")
        return

    # Find the children section within FinanceMate group
    group_start = content.find("children = (", insert_point)
    if group_start == -1:
        print("Error: Could not find children section")
        return

    # Find the end of the children section
    bracket_count = 0
    children_start = group_start + len("children = (")
    for i, char in enumerate(content[children_start:]):
        if char == '(':
            bracket_count += 1
        elif char == ')':
            if bracket_count == 0:
                children_end = children_start + i
                break
            bracket_count -= 1

    # Add file references to PBXFileReference section
    file_ref_section = content.find("/* Begin PBXFileReference section */")
    if file_ref_section == -1:
        print("Error: Could not find PBXFileReference section")
        return

    # Find end of PBXFileReference section
    ref_end = content.find("/* End PBXFileReference section */", file_ref_section)

    # Add build file references to PBXBuildFile section
    build_file_section = content.find("/* Begin PBXBuildFile section */")
    build_end = content.find("/* End PBXBuildFile section */", build_file_section)

    # Find Sources build phase
    sources_section = content.find("/* Begin PBXSourcesBuildPhase section */")
    sources_end = content.find("/* End PBXSourcesBuildPhase section */", sources_section)

    # Generate insertions
    file_refs = ""
    build_refs = ""
    source_refs = ""
    children_refs = ""

    for name, path in to_add.items():
        file_id = generate_id()
        build_id = generate_id()

        # Add to file references
        file_refs += f'\n\t\t{file_id} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = "<group>"; }};'

        # Add to build file references
        build_refs += f'\n\t\t{build_id} = {{isa = PBXBuildFile; fileRef = {file_id}; }};'

        # Add to sources build phase (find where other Services are)
        source_refs += f'\n\t\t\t\t{build_id} /* {name} in Sources */,\n'

        # Add to children
        children_refs += f'\n\t\t\t\t{file_id} /* {name} */,\n'

    # Insert file references
    content = content[:ref_end] + file_refs + content[ref_end:]

    # Insert build file references
    content = content[:build_end] + build_refs + content[build_end:]

    # Find where to insert in Sources build phase (after other Services)
    sources_insert = content.find("Services", sources_section)
    if sources_insert != -1:
        # Find the end of the Services entry
        services_end = content.find(");", sources_insert)
        content = content[:services_end] + source_refs + content[services_end:]

    # Insert into children section
    content = content[:children_end] + children_refs + content[children_end:]

    # Write updated project file
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Successfully added {len(to_add)} transaction service files to project:")
    for name in to_add.keys():
        print(f"  - {name}")

if __name__ == "__main__":
    add_transaction_services_to_project()