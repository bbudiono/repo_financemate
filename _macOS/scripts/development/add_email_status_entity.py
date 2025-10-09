#!/usr/bin/env python3
"""
Add EmailStatusEntity.swift to Xcode project
"""

import os
import re
import random
import string

PROJECT_FILE = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

def generate_uuid():
    """Generate a random 24-character UUID"""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(24))

def read_project():
    with open(PROJECT_FILE, 'r') as f:
        return f.read()

def write_project(content):
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

def main():
    print("Adding EmailStatusEntity.swift to Xcode project...")

    content = read_project()

    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()

    # Check if already exists
    if "EmailStatusEntity.swift" in content:
        print("EmailStatusEntity.swift already exists in project")
        return

    # Add PBXBuildFile entry
    build_file_entry = f"\t\t{build_file_uuid} /* EmailStatusEntity.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* EmailStatusEntity.swift */; }};\n"

    # Find the location after TransactionBuilder build entry
    pattern = r'(\t\t4B969654D27AC3C2BA466EBE /\* TransactionBuilder\.swift in Sources \*/ = {{isa = PBXBuildFile; fileRef = 71BCE3AE60C68983B30B2975 /\* TransactionBuilder\.swift \*/; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + build_file_entry, content)
        print("Added PBXBuildFile entry")

    # Add PBXFileReference entry
    file_ref_entry = f"\t\t{file_ref_uuid} /* EmailStatusEntity.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = EmailStatusEntity.swift; sourceTree = \"<group>\"; }};\n"

    # Find the location after TransactionBuilder file reference
    pattern = r'(\t\t71BCE3AE60C68983B30B2975 /\* TransactionBuilder\.swift \*/ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode\.swift; path = Services/TransactionBuilder\.swift; sourceTree = \"<group>\"; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + file_ref_entry, content)
        print("Added PBXFileReference entry")

    # Add to main group (not Services since it's a Core Data entity)
    # Find a good location in the main group
    pattern = r'(\t\t71BCE3AE60C68983B30B2975 /\* TransactionBuilder\.swift \*/,\n)'
    if re.search(pattern, content):
        main_group_entry = f"\t\t\t\t{file_ref_uuid} /* EmailStatusEntity.swift */,\n"
        content = re.sub(pattern, r'\1' + main_group_entry, content)
        print("Added to main group")

    # Add to Sources build phase (after TransactionBuilder)
    pattern = r'(\t\t\t\t4B969654D27AC3C2BA466EBE /\* TransactionBuilder\.swift in Sources \*/,\n)'
    if re.search(pattern, content):
        sources_entry = f"\t\t\t\t{build_file_uuid} /* EmailStatusEntity.swift in Sources */,\n"
        content = re.sub(pattern, r'\1' + sources_entry, content)
        print("Added to Sources build phase")

    # Write back
    write_project(content)
    print(" EmailStatusEntity.swift added successfully!")
    print(f"   File reference UUID: {file_ref_uuid}")
    print(f"   Build file UUID: {build_file_uuid}")

if __name__ == "__main__":
    main()