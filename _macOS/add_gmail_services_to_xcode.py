#!/usr/bin/env python3
"""
Script to add missing Gmail service files to Xcode project
"""

import re
import uuid
import os

def generate_uuid():
    """Generate a UUID in the format used by Xcode"""
    return uuid.uuid4().hex.upper()[:24]

def add_files_to_xcode_project(project_path):
    """Add missing Gmail service files to Xcode project"""

    # Files to add
    files_to_add = [
        {
            'path': 'FinanceMate/Services/GmailAuthenticationManager.swift',
            'build_id': generate_uuid(),
            'file_id': generate_uuid()
        },
        {
            'path': 'FinanceMate/Services/GmailFilterManager.swift',
            'build_id': generate_uuid(),
            'file_id': generate_uuid()
        },
        {
            'path': 'FinanceMate/Services/GmailPaginationManager.swift',
            'build_id': generate_uuid(),
            'file_id': generate_uuid()
        },
        {
            'path': 'FinanceMate/Services/GmailImportManager.swift',
            'build_id': generate_uuid(),
            'file_id': generate_uuid()
        },
        {
            'path': 'FinanceMate/Services/GmailViewModelCore.swift',
            'build_id': generate_uuid(),
            'file_id': generate_uuid()
        }
    ]

    # Read the project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Add file references to PBXBuildFile section
    build_section_pattern = r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)'
    build_section_match = re.search(build_section_pattern, content, re.DOTALL)

    if build_section_match:
        build_section = build_section_match.group(1)
        new_build_entries = []

        for file_info in files_to_add:
            filename = os.path.basename(file_info['path'])
            new_entry = f"\t\t{file_info['build_id']} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_info['file_id']} /* {filename} */; }};\n"
            new_build_entries.append(new_entry)

        # Insert before the End PBXBuildFile section
        build_section_with_new = build_section.replace(
            '/* End PBXBuildFile section */',
            ''.join(new_build_entries) + '\t\t/* End PBXBuildFile section */'
        )
        content = content.replace(build_section, build_section_with_new)

    # Add file references to PBXFileReference section
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)

    if file_ref_match:
        file_ref_section = file_ref_match.group(1)
        new_file_refs = []

        for file_info in files_to_add:
            filename = os.path.basename(file_info['path'])
            new_entry = f"\t\t{file_info['file_id']} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {filename}; path = {file_info['path']}; sourceTree = \"<group>\"; }};\n"
            new_file_refs.append(new_entry)

        # Insert before the End PBXFileReference section
        file_ref_section_with_new = file_ref_section.replace(
            '/* End PBXFileReference section */',
            ''.join(new_file_refs) + '\t\t/* End PBXFileReference section */'
        )
        content = content.replace(file_ref_section, file_ref_section_with_new)

    # Add files to Services group
    services_group_pattern = r'(394E4BEBB6D3E4E94BB188EA /\* Services \*/ = \{{\s*isa = PBXGroup;\s*children = \([^}]+)\s*}};)'
    services_group_match = re.search(services_group_pattern, content, re.DOTALL)

    if services_group_match:
        services_group = services_group_match.group(1)
        new_services_children = []

        for file_info in files_to_add:
            filename = os.path.basename(file_info['path'])
            new_entry = f"\t\t\t\t{file_info['file_id']} /* {filename} */,\n"
            new_services_children.append(new_entry)

        # Add to existing children (before the closing parenthesis)
        services_group_with_new = services_group.replace(
            '634D7FEF94094129900D472F /* DashboardMetricsService.swift */,',
            '634D7FEF94094129900D472F /* DashboardMetricsService.swift */,\n' + ''.join(new_services_children)
        )
        content = content.replace(services_group, services_group_with_new)

    # Add files to Sources build phase
    sources_pattern = r'(/\* Sources \*/.*?isa = PBXSourcesBuildPhase;.*?files = \(([^)]+)\);)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if sources_match:
        sources_section = sources_match.group(1)
        sources_files = sources_match.group(2)

        new_source_entries = []
        for file_info in files_to_add:
            filename = os.path.basename(file_info['path'])
            new_entry = f"\t\t\t\t{file_info['build_id']} /* {filename} in Sources */,\n"
            new_source_entries.append(new_entry)

        # Add to existing files
        sources_files_with_new = sources_files + '\n' + ''.join(new_source_entries)
        sources_section_with_new = sources_section.replace(
            f'files = ({sources_files})',
            f'files = ({sources_files_with_new})'
        )
        content = content.replace(sources_section, sources_section_with_new)

    # Write back to file
    with open(project_path, 'w') as f:
        f.write(content)

    print(f"Added {len(files_to_add)} files to Xcode project")

if __name__ == "__main__":
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    add_files_to_xcode_project(project_path)
    print("Xcode project updated successfully")