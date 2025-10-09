#!/usr/bin/env python3
"""
Add Missing Core Data Builder Files to Xcode Project
Safely adds only the essential missing files
"""

import re
import os
import sys

def add_core_data_files(project_file_path):
    """Add missing Core Data builder files to Xcode project"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Files to add with their UUIDs and paths
    files_to_add = [
        {
            'uuid': '1679809CE73649A89D666B60',
            'build_uuid': '7B99A061698B47FE9B9E26C9',
            'path': 'FinanceMate/CoreDataRelationshipBuilder.swift',
            'name': 'CoreDataRelationshipBuilder.swift'
        },
        {
            'uuid': 'BC56B4AD69A649E69C68598C',
            'build_uuid': 'C7184CA3E4FB419CB0BFCB59',
            'path': 'FinanceMate/CoreDataEntityBuilder.swift',
            'name': 'CoreDataEntityBuilder.swift'
        },
        {
            'uuid': '4E5B4E40CA8646FF9F47371C',
            'build_uuid': '3CD3EB4BFC34471590E0F531',
            'path': 'FinanceMate/CoreDataModelBuilder.swift',
            'name': 'CoreDataModelBuilder.swift'
        }
    ]

    # Find the PBXBuildFile section and add our files
    pbxbuildfile_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if pbxbuildfile_section:
        build_section = pbxbuildfile_section.group(1)
        for file_info in files_to_add:
            build_entry = f'\t\t{file_info["build_uuid"]} /* {file_info["name"]} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_info["uuid"]} /* {file_info["name"]} */; }};\n'
            if file_info["build_uuid"] not in build_section:
                build_section += build_entry

        content = content.replace(pbxbuildfile_section.group(1), build_section)

    # Find the PBXFileReference section and add our files
    pbxfileref_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if pbxfileref_section:
        ref_section = pbxfileref_section.group(1)
        for file_info in files_to_add:
            ref_entry = f'\t\t{file_info["uuid"]} /* {file_info["name"]} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{file_info["path"]}"; sourceTree = "<group>"; }};\n'
            if file_info["uuid"] not in ref_section:
                ref_section += ref_entry

        content = content.replace(pbxfileref_section.group(1), ref_section)

    # Add files to the main FinanceMate group
    finance_mate_group = re.search(r'(838ED39BA86C60CA98CF6D9F /\* FinanceMate \*/ = \{.*?children = \([^)]+\);)', content, re.DOTALL)
    if finance_mate_group:
        group_section = finance_mate_group.group(1)
        for file_info in files_to_add:
            file_entry = f'\t\t\t\t{file_info["uuid"]} /* {file_info["name"]} */,\n'
            if file_info["uuid"] not in group_section:
                # Add before the closing parenthesis of children
                group_section = re.sub(r'(\t\t\t\t[^)]*?\);)', f'{file_entry}\\1', group_section)

        content = content.replace(finance_mate_group.group(1), group_section)

    # Add files to the Sources build phase
    sources_phase = re.search(r'(/\* Begin PBXSourcesBuildPhase section \*/.*?files = \([^)]+?\);)', content, re.DOTALL)
    if sources_phase:
        sources_section = sources_phase.group(1)
        for file_info in files_to_add:
            source_entry = f'\t\t\t\t{file_info["build_uuid"]} /* {file_info["name"]} in Sources */,\n'
            if file_info["build_uuid"] not in sources_section:
                # Add before the closing parenthesis of files
                sources_section = re.sub(r'(\t\t\t\t[^)]*?\);)', f'{source_entry}\\1', sources_section)

        content = content.replace(sources_phase.group(1), sources_section)

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)

        print(f" Added Core Data builder files to {project_file_path}")
        return True
    else:
        print(f"ℹ️ Core Data builder files already exist")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Adding missing Core Data builder files...")
        success = add_core_data_files(project_file)

        if success:
            print(" Core Data builder files added successfully!")
        else:
            print("ℹ️ No files were needed")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)