#!/usr/bin/env python3
"""
Add AuthTypes.swift to Xcode project
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

def main():
    print("Adding AuthTypes.swift to Xcode project...")

    with open(PROJECT_FILE, 'r') as f:
        content = f.read()

    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()

    # Check if already exists
    if "AuthTypes.swift" in content:
        print("AuthTypes.swift already exists in project")
        return

    # Add PBXBuildFile entry
    build_file_entry = f"\t\t{build_file_uuid} /* AuthTypes.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* AuthTypes.swift */; }};\n"

    # Find the location after LineItem build entry
    pattern = r'(\t\t8C6D5F4A0E7B3A9C1D2F8E6B /\* LineItem\.swift in Sources \*/ = {{isa = PBXBuildFile; fileRef = 8C6D5F4A0E7B3A9C1D2F8E6B /\* LineItem\.swift \*/; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + build_file_entry, content)
        print("Added PBXBuildFile entry")

    # Add PBXFileReference entry
    file_ref_entry = f"\t\t{file_ref_uuid} /* AuthTypes.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Models/AuthTypes.swift; sourceTree = \"<group>\"; }};\n"

    # Find the location after LineItem file reference
    pattern = r'(\t\t8C6D5F4A0E7B3A9C1D2F8E6B /\* LineItem\.swift \*/ = {{isa = PBXFileReference; lastKnownFileType = sourcecode\.swift; path = LineItem\.swift; sourceTree = \"<group>\"; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + file_ref_entry, content)
        print("Added PBXFileReference entry")

    # Find Models group and add to it
    pattern = r'(\t\t\t\t8C6D5F4A0E7B3A9C1D2F8E6B /\* LineItem\.swift \*/,\n)'
    if re.search(pattern, content):
        models_entry = f"\t\t\t\t{file_ref_uuid} /* AuthTypes.swift */,\n"
        content = re.sub(pattern, r'\1' + models_entry, content)
        print("Added to Models group")

    # Add to Sources build phase (after LineItem)
    pattern = r'(\t\t\t\t8C6D5F4A0E7B3A9C1D2F8E6B /\* LineItem\.swift in Sources \*/,\n)'
    if re.search(pattern, content):
        sources_entry = f"\t\t\t\t{build_file_uuid} /* AuthTypes.swift in Sources */,\n"
        content = re.sub(pattern, r'\1' + sources_entry, content)
        print("Added to Sources build phase")

    # Write back
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)
    print(" AuthTypes.swift added successfully!")
    print(f"   File reference UUID: {file_ref_uuid}")
    print(f"   Build file UUID: {build_file_uuid}")

if __name__ == "__main__":
    main()