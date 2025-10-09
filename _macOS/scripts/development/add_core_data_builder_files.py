#!/usr/bin/env python3
"""
Add Core Data Builder Files to Xcode Project
"""

import os
import re
import uuid

def add_core_data_files_to_project():
    """Add CoreDataModelBuilder.swift to Xcode project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()

    original_content = content

    # Generate UUIDs for the new files
    file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

    # File to add
    file_name = "CoreDataModelBuilder.swift"
    file_path = "FinanceMate/CoreDataModelBuilder.swift"

    # Check if file already exists
    if file_uuid in content or file_name in content:
        print(f"{file_name} already exists in project")
        return

    # Add to PBXBuildFile section
    pbxbuildfile_pattern = r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)'
    pbxbuildfile_match = re.search(pbxbuildfile_pattern, content, re.DOTALL)
    if pbxbuildfile_match:
        build_section = pbxbuildfile_match.group(1)
        build_entry = f'\t\t{build_uuid} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {file_name} */; }};\n'
        new_build_section = build_section.replace('/* End PBXBuildFile section */', f'{build_entry}/* End PBXBuildFile section */')
        content = content.replace(build_section, new_build_section)

    # Add to PBXFileReference section
    fileref_pattern = r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)'
    fileref_match = re.search(fileref_pattern, content, re.DOTALL)
    if fileref_match:
        ref_section = fileref_match.group(1)
        ref_entry = f'\t\t{file_uuid} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = "<group>"; }};\n'
        new_ref_section = ref_section.replace('/* End PBXFileReference section */', f'{ref_entry}/* End PBXFileReference section */')
        content = content.replace(ref_section, new_ref_section)

    # Add to FinanceMate group
    finance_group_pattern = r'(\t\t838ED39BA86C60CA98CF6D9F \/\* FinanceMate \*/ = \{[^}]+children = \([^)]+)(\);)'
    finance_group_match = re.search(finance_group_pattern, content, re.DOTALL)
    if finance_group_match:
        group_start = finance_group_match.group(1)
        group_end = finance_group_match.group(2)
        group_entry = f',\n\t\t\t\t{file_uuid} /* {file_name} */'
        new_group = f'{group_start}{group_entry}{group_end}'
        content = content.replace(finance_group_match.group(0), new_group)

    # Add to Sources build phase
    sources_pattern = r'(/\* Begin PBXSourcesBuildPhase section \*/.*?files = \([^)]+)(\);.*?/\* End PBXSourcesBuildPhase section \*/)'
    sources_match = re.search(sources_pattern, content, re.DOTALL)
    if sources_match:
        sources_start = sources_match.group(1)
        sources_end = sources_match.group(2)
        sources_entry = f',\n\t\t\t\t{build_uuid} /* {file_name} in Sources */'
        new_sources = f'{sources_start}{sources_entry}{sources_end}'
        content = content.replace(sources_match.group(0), new_sources)

    # Write the updated content
    if content != original_content:
        with open(project_file, 'w') as f:
            f.write(content)
        print(f"Added {file_name} to Xcode project")
    else:
        print(f"No changes made to {file_name}")

if __name__ == "__main__":
    add_core_data_files_to_project()