#!/usr/bin/env python3
"""
Phase 1 GREEN: Add missing AuthTypes.swift and TokenStorageService.swift to Xcode project
This script adds the missing files to the FinanceMate build target to fix compilation errors.
"""

import re
import uuid
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

    # Find the end of the PBXBuildFile section to add our entries
    pbxbuildfile_end = content.find('/* End PBXBuildFile section */')
    if pbxbuildfile_end == -1:
        print("ERROR: Could not find PBXBuildFile section")
        return False

    # Create the new PBXBuildFile entries
    new_buildfile_entries = f"\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {auth_types_file_id} /* AuthTypes.swift */; }};\n"
    new_buildfile_entries += f"\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {token_storage_file_id} /* TokenStorageService.swift */; }};\n"

    # Insert the new entries before the end of PBXBuildFile section
    content = content[:pbxbuildfile_end] + new_buildfile_entries + content[pbxbuildfile_end:]

    # Find the end of the PBXFileReference section to add our entries
    pbxfileref_end = content.find('/* End PBXFileReference section */')
    if pbxfileref_end == -1:
        print("ERROR: Could not find PBXFileReference section")
        return False

    # Create the new PBXFileReference entries
    new_fileref_entries = f"\t\t{auth_types_file_id} /* AuthTypes.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthTypes.swift; sourceTree = \"<group>\"; }};\n"
    new_fileref_entries += f"\t\t{token_storage_file_id} /* TokenStorageService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Services/TokenStorageService.swift; sourceTree = \"<group>\"; }};\n"

    # Insert the new entries before the end of PBXFileReference section
    content = content[:pbxfileref_end] + new_fileref_entries + content[pbxfileref_end:]

    # Find the FinanceMate group to add the file references
    # Look for the main FinanceMate group (838ED39BA86C60CA98CF6D9F)
    finance_mate_group_pattern = r'(838ED39BA86C60CA98CF6D9F /\* FinanceMate \*/ = \{\s*isa = PBXGroup;\s*children = \([^)]+);)'

    match = re.search(finance_mate_group_pattern, content, re.DOTALL)
    if not match:
        print("ERROR: Could not find FinanceMate group")
        return False

    group_content = match.group(1)

    # Find where to insert the new children (before the closing parenthesis and semicolon)
    children_end = group_content.rfind(');')
    if children_end == -1:
        print("ERROR: Could not find children end in FinanceMate group")
        return False

    # Create new children entries
    new_children = f"\t\t\t\t{auth_types_file_id} /* AuthTypes.swift */,\n"
    new_children += f"\t\t\t\t{token_storage_file_id} /* TokenStorageService.swift */,\n"

    # Insert the new children
    new_group_content = group_content[:children_end] + new_children + group_content[children_end:]
    content = content.replace(group_content, new_group_content)

    # Find the Sources build phase to add the files to the build target
    # Look for the specific Sources build phase
    sources_pattern = r'(E728BDA24D7E5D5322C4F5B3 /\* Sources \*/ = \{[^}]+files = \([^)]+)\);'

    match = re.search(sources_pattern, content, re.DOTALL)
    if not match:
        print("ERROR: Could not find Sources build phase")
        return False

    sources_content = match.group(1)

    # Find where to insert the new build files (before the closing parenthesis and semicolon)
    files_end = sources_content.rfind(');')
    if files_end == -1:
        print("ERROR: Could not find files end in Sources build phase")
        return False

    # Create new build file entries
    new_build_files = f",\n\t\t\t\t{auth_types_build_id} /* AuthTypes.swift in Sources */"
    new_build_files += f",\n\t\t\t\t{token_storage_build_id} /* TokenStorageService.swift in Sources */"

    # Insert the new build files
    new_sources_content = sources_content[:files_end] + new_build_files + sources_content[files_end:]
    content = content.replace(sources_content, new_sources_content)

    # Write the modified content back to the file
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Successfully added AuthTypes.swift and TokenStorageService.swift to project.pbxproj")
    print(f"AuthTypes.swift - Build ID: {auth_types_build_id}, File ID: {auth_types_file_id}")
    print(f"TokenStorageService.swift - Build ID: {token_storage_build_id}, File ID: {token_storage_file_id}")

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