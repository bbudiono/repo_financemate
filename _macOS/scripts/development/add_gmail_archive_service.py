#!/usr/bin/env python3
"""
Add GmailArchiveService.swift to Xcode project
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
    print("Adding GmailArchiveService.swift to Xcode project...")

    content = read_project()

    # Generate UUIDs
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()

    # Check if already exists
    if "GmailArchiveService.swift" in content:
        print("GmailArchiveService.swift already exists in project")
        return

    # Add PBXBuildFile entry (find the section and add to it)
    build_file_entry = f"\t\t{build_file_uuid} /* GmailArchiveService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* GmailArchiveService.swift */; }};\n"

    # Find the location after EmailCacheService build entry
    pattern = r'(\t\t0A5D945D9848B184FD19BAED /\* EmailCacheService\.swift in Sources \*/ = {{isa = PBXBuildFile; fileRef = 779F3E7AB1C78B0F65C81E1C /\* EmailCacheService\.swift \*/; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + build_file_entry, content)
        print("Added PBXBuildFile entry")

    # Add PBXFileReference entry
    file_ref_entry = f"\t\t{file_ref_uuid} /* GmailArchiveService.swift */ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = Services/GmailArchiveService.swift; sourceTree = \"<group>\"; }};\n"

    # Find the location after EmailCacheService file reference
    pattern = r'(\t\t779F3E7AB1C78B0F65C81E1C /\* EmailCacheService\.swift \*/ = {{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode\.swift; path = Services/EmailCacheService\.swift; sourceTree = \"<group>\"; }};)\n'
    if re.search(pattern, content):
        content = re.sub(pattern, r'\1\n' + file_ref_entry, content)
        print("Added PBXFileReference entry")

    # Add to Services group
    pattern = r'(\t\t\t\t779F3E7AB1C78B0F65C81E1C /\* EmailCacheService\.swift \*/,\n)'
    if re.search(pattern, content):
        services_entry = f"\t\t\t\t{file_ref_uuid} /* GmailArchiveService.swift */,\n"
        content = re.sub(pattern, r'\1' + services_entry, content)
        print("Added to Services group")

    # Add to Sources build phase (after EmailCacheService)
    pattern = r'(\t\t\t\t0A5D945D9848B184FD19BAED /\* EmailCacheService\.swift in Sources \*/,\n)'
    if re.search(pattern, content):
        sources_entry = f"\t\t\t\t{build_file_uuid} /* GmailArchiveService.swift in Sources */,\n"
        content = re.sub(pattern, r'\1' + sources_entry, content)
        print("Added to Sources build phase")

    # Write back
    write_project(content)
    print(" GmailArchiveService.swift added successfully!")
    print(f"   File reference UUID: {file_ref_uuid}")
    print(f"   Build file UUID: {build_file_uuid}")

if __name__ == "__main__":
    main()