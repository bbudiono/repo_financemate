#!/usr/bin/env python3
"""
Phase 1 GREEN: Simple approach to add missing AuthTypes.swift and TokenStorageService.swift to Xcode project
"""

import re
import random
import sys

def generate_xcode_id():
    """Generate a 24-character hex identifier like Xcode uses"""
    return ''.join(random.choices('0123456789ABCDEF', k=24))

def add_files_to_pbxproj():
    """Add AuthTypes.swift and TokenStorageService.swift to the Xcode project"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate unique IDs for the new files
    auth_types_build_id = generate_xcode_id()
    auth_types_file_id = generate_xcode_id()
    token_storage_build_id = generate_xcode_id()
    token_storage_file_id = generate_xcode_id()

    print(f"Generated IDs:")
    print(f"  AuthTypes - Build: {auth_types_build_id}, File: {auth_types_file_id}")
    print(f"  TokenStorage - Build: {token_storage_build_id}, File: {token_storage_file_id}")

    # 1. Add to PBXBuildFile section
    pbxbuildfile_end = content.find('/* End PBXBuildFile section */')
    if pbxbuildfile_end == -1:
        print("ERROR: Could not find PBXBuildFile section")
        return False

    new_buildfile_entries = []
    new_buildfile_entries.append(f"\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {auth_types_file_id} /* AuthTypes.swift */; }};")
    new_buildfile_entries.append(f"\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {token_storage_file_id} /* TokenStorageService.swift */; }};")

    buildfile_insert = '\n'.join(new_buildfile_entries) + '\n'
    content = content[:pbxbuildfile_end] + buildfile_insert + content[pbxbuildfile_end:]

    # 2. Add to PBXFileReference section
    pbxfileref_end = content.find('/* End PBXFileReference section */')
    if pbxfileref_end == -1:
        print("ERROR: Could not find PBXFileReference section")
        return False

    new_fileref_entries = []
    new_fileref_entries.append(f"\t\t{auth_types_file_id} /* AuthTypes.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthTypes.swift; sourceTree = \"<group>\"; }};")
    new_fileref_entries.append(f"\t\t{token_storage_file_id} /* TokenStorageService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Services/TokenStorageService.swift; sourceTree = \"<group>\"; }};")

    fileref_insert = '\n'.join(new_fileref_entries) + '\n'
    content = content[:pbxfileref_end] + fileref_insert + content[pbxfileref_end:]

    # 3. Add to FinanceMate group children - find any line with AuthenticationManager and add after it
    auth_manager_line = content.find('0462096396F23463327279A7 /* AuthenticationManager.swift */')
    if auth_manager_line == -1:
        print("ERROR: Could not find AuthenticationManager.swift in project")
        return False

    # Find the end of this line and add our files after it
    line_end = content.find('\n', auth_manager_line)
    if line_end == -1:
        print("ERROR: Could not find end of AuthenticationManager line")
        return False

    group_insert = []
    group_insert.append(f"\t\t\t\t{auth_types_file_id} /* AuthTypes.swift */,")
    group_insert.append(f"\t\t\t\t{token_storage_file_id} /* TokenStorageService.swift */,")

    content = content[:line_end + 1] + '\n'.join(group_insert) + '\n' + content[line_end + 1:]

    # 4. Add to Sources build phase - find AuthenticationManager in Sources and add after it
    sources_auth_line = content.find('44D1E7A36F1DEFC689B2D29B /* AuthenticationManager.swift in Sources */')
    if sources_auth_line == -1:
        print("ERROR: Could not find AuthenticationManager.swift in Sources")
        return False

    # Find the end of this line and add our files after it
    sources_line_end = content.find('\n', sources_auth_line)
    if sources_line_end == -1:
        print("ERROR: Could not find end of AuthenticationManager Sources line")
        return False

    sources_insert = []
    sources_insert.append(f"\t\t\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */,")
    sources_insert.append(f"\t\t\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */,")

    content = content[:sources_line_end + 1] + '\n'.join(sources_insert) + '\n' + content[sources_line_end + 1:]

    # Write the modified content back to the file
    with open(project_file, 'w') as f:
        f.write(content)

    print("Successfully added both files to Xcode project")
    return True

def main():
    """Main function to execute the GREEN phase"""
    print("🟢 PHASE 1 GREEN: Adding missing authentication files to Xcode project")
    print("=" * 70)

    # Add the missing files to the project
    if add_files_to_pbxproj():
        print(" Successfully added missing files to Xcode project")
        print(" AuthenticationManager import issues should now be resolved")
        return True
    else:
        print(" Failed to add missing files to Xcode project")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)