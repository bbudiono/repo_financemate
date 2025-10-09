#!/usr/bin/env python3
"""
Simple script to add AuthTypes.swift and TokenStorageService.swift to Xcode project using sed commands
"""

import subprocess
import sys
import re
import random

def generate_xcode_id():
    """Generate a 24-character hex identifier like Xcode uses"""
    return ''.join(random.choices('0123456789ABCDEF', k=24))

def main():
    """Add missing authentication files to Xcode project"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Generate unique IDs
    auth_types_build_id = generate_xcode_id()
    auth_types_file_id = generate_xcode_id()
    token_storage_build_id = generate_xcode_id()
    token_storage_file_id = generate_xcode_id()

    print(f"Adding AuthTypes.swift and TokenStorageService.swift to Xcode project")
    print(f"AuthTypes.swift - Build: {auth_types_build_id}, File: {auth_types_file_id}")
    print(f"TokenStorageService.swift - Build: {token_storage_build_id}, File: {token_storage_file_id}")

    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()

    # 1. Add PBXBuildFile entries after AuthenticationManager
    auth_manager_line = '44D1E7A36F1DEFC689B2D29B /* AuthenticationManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0462096396F23463327279A7 /* AuthenticationManager.swift */; };'

    build_entries = []
    build_entries.append(f"\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {auth_types_file_id} /* AuthTypes.swift */; }};")
    build_entries.append(f"\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {token_storage_file_id} /* TokenStorageService.swift */; }};")

    if auth_manager_line in content:
        insert_pos = content.find(auth_manager_line) + len(auth_manager_line) + 1
        content = content[:insert_pos] + '\n'.join(build_entries) + '\n' + content[insert_pos:]
        print(" Added PBXBuildFile entries")
    else:
        print(" Could not find AuthenticationManager PBXBuildFile entry")
        return False

    # 2. Add PBXFileReference entries after AuthenticationManager
    auth_manager_ref = '0462096396F23463327279A7 /* AuthenticationManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationManager.swift; sourceTree = "<group>"; };'

    fileref_entries = []
    fileref_entries.append(f"\t\t{auth_types_file_id} /* AuthTypes.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthTypes.swift; sourceTree = \"<group>\"; }};")
    fileref_entries.append(f"\t\t{token_storage_file_id} /* TokenStorageService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Services/TokenStorageService.swift; sourceTree = \"<group>\"; }};")

    if auth_manager_ref in content:
        insert_pos = content.find(auth_manager_ref) + len(auth_manager_ref) + 1
        content = content[:insert_pos] + '\n'.join(fileref_entries) + '\n' + content[insert_pos:]
        print(" Added PBXFileReference entries")
    else:
        print(" Could not find AuthenticationManager PBXFileReference entry")
        return False

    # 3. Add to FinanceMate group children - after AuthenticationManager.swift
    auth_manager_group = '0462096396F23463327279A7 /* AuthenticationManager.swift */,'

    group_entries = []
    group_entries.append(f"\t\t\t\t{auth_types_file_id} /* AuthTypes.swift */,")
    group_entries.append(f"\t\t\t\t{token_storage_file_id} /* TokenStorageService.swift */,")

    if auth_manager_group in content:
        insert_pos = content.find(auth_manager_group) + len(auth_manager_group) + 1
        content = content[:insert_pos] + '\n'.join(group_entries) + '\n' + content[insert_pos:]
        print(" Added to FinanceMate group")
    else:
        print(" Could not find AuthenticationManager in FinanceMate group")
        return False

    # 4. Add to Sources build phase - after AuthenticationManager.swift in Sources
    auth_manager_sources = '44D1E7A36F1DEFC689B2D29B /* AuthenticationManager.swift in Sources */,'

    sources_entries = []
    sources_entries.append(f"\t\t\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */,")
    sources_entries.append(f"\t\t\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */,")

    if auth_manager_sources in content:
        insert_pos = content.find(auth_manager_sources) + len(auth_manager_sources) + 1
        content = content[:insert_pos] + '\n'.join(sources_entries) + '\n' + content[insert_pos:]
        print(" Added to Sources build phase")
    else:
        print(" Could not find AuthenticationManager in Sources build phase")
        return False

    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)

    print(" Successfully added both authentication files to Xcode project")
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)