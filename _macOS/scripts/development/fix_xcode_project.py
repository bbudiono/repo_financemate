#!/usr/bin/env python3
"""
Manual fix for Xcode project to add WinningModelIndicator.swift
"""

import re
import uuid
import sys

def generate_uuid():
    """Generate a random UUID for Xcode project references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def create_file_entries(file_path, file_ref_id, build_file_id):
    """Create Xcode project file reference entries"""
    new_file_ref = f'\n\t\t\t{file_ref_id} /* {file_path.split("/")[-1]} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_path}; sourceTree = "<group>"; }};'
    new_build_file = f'\n\t\t\t{build_file_id} /* {file_path.split("/")[-1]} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {file_path.split("/")[-1]} */; }};'
    return new_file_ref, new_build_file

def add_to_sections(content, new_file_ref, new_build_file):
    """Add file references to Xcode project sections"""
    # Add file reference to PBXFileReference section
    file_ref_section = re.search(r'(PBXFileReference = \{[^}]+)', content, re.DOTALL)
    if file_ref_section:
        content = content.replace(
            file_ref_section.group(1),
            file_ref_section.group(1) + new_file_ref
        )

    # Add build file to PBXBuildFile section
    build_file_section = re.search(r'(PBXBuildFile = \{[^}]+)', content, re.DOTALL)
    if build_file_section:
        content = content.replace(
            build_file_section.group(1),
            build_file_section.group(1) + new_build_file
        )

    return content

def add_to_groups_and_sources(content, file_path, file_ref_id, build_file_id):
    """Add file to FinanceMate group and Sources build phase"""
    # Add file to FinanceMate group children
    finance_match = re.search(r'(/\* FinanceMate \*/ = \{[^}]+children = \([^)]+)', content, re.DOTALL)
    if not finance_match:
        return content

    finance_group = finance_match.group(1)
    updated_group = finance_group + f',\n\t\t\t\t{file_ref_id} /* {file_path.split("/")[-1]} */'
    content = content.replace(finance_group, updated_group)

    # Add to Sources build phase
    sources_phase = re.search(r'(Sources = \([^)]+)', content, re.DOTALL)
    if sources_phase:
        sources_content = sources_phase.group(1)
        new_sources_entry = f',\n\t\t\t\t{build_file_id} /* {file_path.split("/")[-1]} in Sources */'
        updated_sources = sources_content.replace(');', new_sources_entry + ');')
        content = content.replace(sources_content, updated_sources)

    return content

def add_file_to_xcode_project(project_file, file_path):
    """Add a file to Xcode project with proper references"""
    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate unique IDs
    file_ref_id = generate_uuid()
    build_file_id = generate_uuid()

    # Create file entries
    new_file_ref, new_build_file = create_file_entries(file_path, file_ref_id, build_file_id)

    # Add to project sections
    content = add_to_sections(content, new_file_ref, new_build_file)

    # Add to groups and sources
    content = add_to_groups_and_sources(content, file_path, file_ref_id, build_file_id)

    # Write back to file
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Successfully added {file_path} to Xcode project")
    return True

def main():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"
    file_path = "FinanceMate/Views/Components/WinningModelIndicator.swift"

    if add_file_to_xcode_project(project_file, file_path):
        print("File added successfully")
    else:
        print("Failed to add file")
        sys.exit(1)

if __name__ == "__main__":
    main()