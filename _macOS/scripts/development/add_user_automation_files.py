#!/usr/bin/env python3
"""
Script to add UserAutomationMemory.swift and UserAutomationMemoryService.swift to Xcode project
"""

import re
import uuid
import sys

def generate_unique_ids():
    """Generate unique IDs for both files"""
    user_memory_file_ref_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    user_memory_build_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    service_file_ref_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    service_build_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    return (user_memory_file_ref_id, user_memory_build_file_id, service_file_ref_id, service_build_file_id)

def add_to_build_file_section(content, build_file_id, file_ref_id, filename):
    """Add file to PBXBuildFile section"""
    build_entry = f"\t\t{build_file_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {filename} */; }};\n"
    pbxbuild_pattern = r"(/\* Begin PBXBuildFile section \*/\n)"
    match = re.search(pbxbuild_pattern, content)
    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + build_entry + content[insert_pos:]
    return content

def add_to_file_reference_section(content, file_ref_id, filename):
    """Add file to PBXFileReference section"""
    file_ref_entry = f"\t\t{file_ref_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};\n"
    pbxfileref_pattern = r"(/\* Begin PBXFileReference section \*/\n)"
    match = re.search(pbxfileref_pattern, content)
    if match:
        insert_pos = match.end()
        content = content[:insert_pos] + file_ref_entry + content[insert_pos:]
    return content

def add_to_group_and_sources(content, user_memory_file_ref_id, service_file_ref_id,
                             user_memory_build_file_id, service_build_file_id):
    """Add files to FinanceMate group and Sources build phase"""
    # Add to FinanceMate group
    group_pattern = r"(children = \([^)]+\);)"
    match = re.search(group_pattern, content)
    if match:
        children_section = match.group(1)
        new_children = children_section.replace(');', f',\n\t\t\t\t{user_memory_file_ref_id} /* UserAutomationMemory.swift */,\n\t\t\t\t{service_file_ref_id} /* UserAutomationMemoryService.swift */);')
        content = content.replace(children_section, new_children)

    # Add to Sources build phase
    sources_pattern = r"(files = \([^)]+\);)"
    match = re.search(sources_pattern, content)
    if match:
        files_section = match.group(1)
        new_files = files_section.replace(');', f',\n\t\t\t\t{user_memory_build_file_id} /* UserAutomationMemory.swift in Sources */,\n\t\t\t\t{service_build_file_id} /* UserAutomationMemoryService.swift in Sources */);')
        content = content.replace(files_section, new_files)

    return content

def add_files_to_pbxproj():
    """Main function to add UserAutomationMemory files to Xcode project"""
    pbxproj_path = "FinanceMate.xcodeproj/project.pbxproj"

    # Read current pbxproj
    with open(pbxproj_path, 'r') as f:
        content = f.read()

    # Generate unique IDs
    (user_memory_file_ref_id, user_memory_build_file_id,
     service_file_ref_id, service_build_file_id) = generate_unique_ids()

    # Add files to all necessary sections
    content = add_to_build_file_section(content, user_memory_build_file_id, user_memory_file_ref_id, "UserAutomationMemory.swift")
    content = add_to_build_file_section(content, service_build_file_id, service_file_ref_id, "UserAutomationMemoryService.swift")
    content = add_to_file_reference_section(content, user_memory_file_ref_id, "UserAutomationMemory.swift")
    content = add_to_file_reference_section(content, service_file_ref_id, "UserAutomationMemoryService.swift")
    content = add_to_group_and_sources(content, user_memory_file_ref_id, service_file_ref_id,
                                     user_memory_build_file_id, service_build_file_id)

    # Write updated content
    with open(pbxproj_path, 'w') as f:
        f.write(content)

    print(f"Added UserAutomationMemory.swift and UserAutomationMemoryService.swift to Xcode project")
    print(f"UserAutomationMemory file reference ID: {user_memory_file_ref_id}")
    print(f"UserAutomationMemory build file ID: {user_memory_build_file_id}")
    print(f"UserAutomationMemoryService file reference ID: {service_file_ref_id}")
    print(f"UserAutomationMemoryService build file ID: {service_build_file_id}")

if __name__ == "__main__":
    add_files_to_pbxproj()