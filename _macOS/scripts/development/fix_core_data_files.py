#!/usr/bin/env python3

import os
import re
import uuid

def add_file_to_xcode_project(project_file, file_path, group_name='FinanceMate'):
    """Add a Swift file to Xcode project.pbxproj file"""

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate UUIDs for new entries
    file_ref_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    build_file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

    # Find the group UUID for the target group
    group_pattern = rf'{group_name}.*?/\*.*?\*/ = {{[^}}]*name = {group_name}[^}}]*?}}'
    group_match = re.search(group_pattern, content, re.DOTALL)

    if not group_match:
        print(f"Could not find group '{group_name}' in project")
        return False

    # Extract group UUID
    group_section = group_match.group(0)
    group_uuid_match = re.search(r'(\w{24})/\* {group_name}', group_section)
    if not group_uuid_match:
        print(f"Could not extract group UUID for '{group_name}'")
        return False

    group_uuid = group_uuid_match.group(1)

    # Find the PBXGroup children section
    children_pattern = rf'{group_uuid} {{[^}}]*children = \([^)]*\);'
    children_match = re.search(children_pattern, content)

    if not children_match:
        print(f"Could not find children section for group '{group_name}'")
        return False

    # Add file reference to PBXFileReference section
    pbx_file_ref_section = re.search(r'/* Begin PBXFileReference section */.*?/* End PBXFileReference section */', content, re.DOTALL)
    if pbx_file_ref_section:
        new_file_ref = f"\t\t{file_ref_uuid} /* {os.path.basename(file_path)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{os.path.basename(file_path)}\"; sourceTree = \"<group>\"; }};\n"
        content = content.replace(pbx_file_ref_section.group(0), pbx_file_ref_section.group(0) + new_file_ref)

    # Add build file to PBXBuildFile section
    pbx_build_file_section = re.search(r'/* Begin PBXBuildFile section */.*?/* End PBXBuildFile section */', content, re.DOTALL)
    if pbx_build_file_section:
        new_build_file = f"\t\t{build_file_uuid} /* {os.path.basename(file_path)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {os.path.basename(file_path)} */; }};\n"
        content = content.replace(pbx_build_file_section.group(0), pbx_build_file_section.group(0) + new_build_file)

    # Add file reference to group children
    children_section = children_match.group(0)
    new_child = f"\t\t\t\t{file_ref_uuid} /* {os.path.basename(file_path)} */,\n"
    updated_children = children_section.replace(');', f'{new_child}\t\t\t);')
    content = content.replace(children_section, updated_children)

    # Add to Sources build phase
    sources_build_phase_pattern = r'/* Sources */ = {[^}]*files = \([^)]*\);'
    sources_match = re.search(sources_build_phase_pattern, content, re.DOTALL)
    if sources_match:
        sources_section = sources_match.group(0)
        new_source = f"\t\t\t\t{build_file_uuid} /* {os.path.basename(file_path)} in Sources */,\n"
        updated_sources = sources_section.replace(');', f'{new_source}\t\t\t);')
        content = content.replace(sources_section, updated_sources)

    # Write updated content back
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Added {file_path} to Xcode project")
    return True

def main():
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'

    if not os.path.exists(project_file):
        print(f"Project file not found: {project_file}")
        return

    # Files to add
    files_to_add = [
        'FinanceMate/CoreDataModelBuilder.swift',
        'FinanceMate/CoreDataMigrationService.swift',
        'FinanceMate/CoreDataEntityBuilder.swift',
        'FinanceMate/CoreDataRelationshipBuilder.swift',
        'FinanceMate/Services/CoreDataManager.swift'
    ]

    for file_path in files_to_add:
        if os.path.exists(file_path):
            add_file_to_xcode_project(project_file, file_path)
        else:
            print(f"File not found: {file_path}")

    print("Xcode project update complete")

if __name__ == '__main__':
    main()