#!/usr/bin/env python3
"""
Script to add UserAutomationMemoryTests.swift to the Xcode project
"""

import re
import uuid
import sys

def generate_unique_ids():
    """Generate unique IDs for Xcode project references"""
    test_file_ref_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    test_build_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    return test_file_ref_id, test_build_file_id

def add_to_build_file_section(content, test_build_file_id, test_file_ref_id):
    """Add test file to PBXBuildFile section"""
    build_file_entry = f"\t\t{test_build_file_id} /* UserAutomationMemoryTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {test_file_ref_id} /* UserAutomationMemoryTests.swift */; }};\n"

    pbxbuild_pattern = r"(/\* Begin PBXBuildFile section \*/\n)"
    match = re.search(pbxbuild_pattern, content)
    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + build_file_entry + content[insert_pos:]
    return content

def add_to_file_reference_section(content, test_file_ref_id):
    """Add test file to PBXFileReference section"""
    file_ref_entry = f"\t\t{test_file_ref_id} /* UserAutomationMemoryTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = UserAutomationMemoryTests.swift; sourceTree = \"<group>\"; }};\n"

    pbxfileref_pattern = r"(/\* Begin PBXFileReference section \*/\n)"
    match = re.search(pbxfileref_pattern, content)
    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + file_ref_entry + content[insert_pos:]
    return content

def add_to_finance_mate_tests_group(content, test_file_ref_id):
    """Add test file to FinanceMateTests group"""
    group_pattern = r"(/\* FinanceMateTests \*/ = {[^}]+children = \([^)]+);"
    match = re.search(group_pattern, content, re.DOTALL)
    if match:
        children_section = match.group(1)
        children_end_pattern = r"(children = \([^)]+);)"
        children_match = re.search(children_end_pattern, children_section)
        if children_match:
            new_children = children_match.group(1).replace(');', f',\n\t\t\t\t{test_file_ref_id} /* UserAutomationMemoryTests.swift */);')
            updated_section = children_section.replace(children_match.group(1), new_children)
            content = content.replace(children_section, updated_section)
    return content

def add_to_sources_build_phase(content, test_build_file_id):
    """Add test file to Sources build phase"""
    sources_pattern = r"(/\* Sources \*/ = {[^}]+files = \([^)]+);"
    match = re.search(sources_pattern, content, re.DOTALL)
    if match:
        sources_section = match.group(1)
        files_end_pattern = r"(files = \([^)]+);)"
        files_match = re.search(files_end_pattern, sources_section)
        if files_match:
            new_files = files_match.group(1).replace(');', f',\n\t\t\t\t{test_build_file_id} /* UserAutomationMemoryTests.swift in Sources */);')
            updated_section = sources_section.replace(files_match.group(1), new_files)
            content = content.replace(sources_section, updated_section)
    return content

def add_test_to_pbxproj():
    """Main function to add UserAutomationMemoryTests.swift to Xcode project"""
    pbxproj_path = "FinanceMate.xcodeproj/project.pbxproj"

    # Read current pbxproj
    with open(pbxproj_path, 'r') as f:
        content = f.read()

    # Generate unique IDs
    test_file_ref_id, test_build_file_id = generate_unique_ids()

    # Add test file to all necessary sections
    content = add_to_build_file_section(content, test_build_file_id, test_file_ref_id)
    content = add_to_file_reference_section(content, test_file_ref_id)
    content = add_to_finance_mate_tests_group(content, test_file_ref_id)
    content = add_to_sources_build_phase(content, test_build_file_id)

    # Write updated content
    with open(pbxproj_path, 'w') as f:
        f.write(content)

    print(f"Added UserAutomationMemoryTests.swift to Xcode project")
    print(f"File reference ID: {test_file_ref_id}")
    print(f"Build file ID: {test_build_file_id}")

if __name__ == "__main__":
    add_test_to_pbxproj()