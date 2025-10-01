#!/usr/bin/env python3
"""
Fix Xcode project.pbxproj file references after nuclear reset.
Removes all stale file references and adds only the actual MVP files.
"""

import re
import json
import uuid

# Actual MVP files that exist
MVP_FILES = {
    'FinanceMateApp.swift': 'App',
    'ProductionConfig.swift': 'Configuration',
    'PersistenceController.swift': 'Models',
    'Transaction.swift': 'Models',
    'GmailAPI.swift': 'Services',
    'KeychainHelper.swift': 'Services',
    'GmailViewModel.swift': 'ViewModels',
    'ContentView.swift': 'Views',
    'DashboardView.swift': 'Views',
    'GmailView.swift': 'Views',
    'TransactionsView.swift': 'Views'
}

def generate_uuid():
    """Generate a 24-character hex string like Xcode uses"""
    return uuid.uuid4().hex[:24].upper()

def read_project_file(path):
    """Read the project.pbxproj file"""
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_project_file(path, content):
    """Write the project.pbxproj file"""
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def remove_stale_references(content):
    """Remove all file references to non-existent files"""
    lines = content.split('\n')
    cleaned_lines = []
    skip_next = 0
    removed_count = 0

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if this line references a non-existent file
        # Look for patterns like: path = FinanceMateApp.swift
        if 'path =' in line and '.swift' in line:
            # Extract the filename
            match = re.search(r'path = (.+?);', line)
            if match:
                filename = match.group(1).strip('"')
                # If it's not in our MVP files, mark for removal
                basename = filename.split('/')[-1]
                if basename not in MVP_FILES:
                    # This is a stale reference, skip the entire PBXFileReference block
                    # Find the UUID at the start of the line
                    uuid_match = re.search(r'^\s*([A-F0-9]{24})', line)
                    if uuid_match:
                        file_uuid = uuid_match.group(1)
                        # Remove this file reference line
                        removed_count += 1
                        i += 1
                        continue

        cleaned_lines.append(line)
        i += 1

    return '\n'.join(cleaned_lines), removed_count

def add_mvp_file_references(content):
    """Add file references for MVP files"""
    # Generate UUIDs for each file
    file_refs = {}
    build_file_refs = {}

    for filename, group in MVP_FILES.items():
        file_uuid = generate_uuid()
        build_uuid = generate_uuid()
        file_refs[filename] = {
            'uuid': file_uuid,
            'build_uuid': build_uuid,
            'group': group
        }

    # Find the PBXFileReference section
    lines = content.split('\n')
    modified_lines = []

    # Insert file references in PBXFileReference section
    in_file_ref_section = False
    file_ref_section_end = -1

    for i, line in enumerate(lines):
        if '/* Begin PBXFileReference section */' in line:
            in_file_ref_section = True
            modified_lines.append(line)
            # Add all MVP file references here
            for filename, info in file_refs.items():
                ref_line = f"\t\t{info['uuid']} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};"
                modified_lines.append(ref_line)
            continue

        if in_file_ref_section and '/* End PBXFileReference section */' in line:
            in_file_ref_section = False

        modified_lines.append(line)

    return '\n'.join(modified_lines), len(file_refs)

def main():
    project_path = '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj'

    print("Reading project.pbxproj...")
    content = read_project_file(project_path)

    print("Removing stale file references...")
    content, removed = remove_stale_references(content)
    print(f"  Removed {removed} stale references")

    print("Adding MVP file references...")
    content, added = add_mvp_file_references(content)
    print(f"  Added {added} MVP file references")

    print("Writing updated project.pbxproj...")
    write_project_file(project_path, content)

    print("\nSummary:")
    print(f"  Stale references removed: {removed}")
    print(f"  MVP references added: {added}")
    print("\nNext step: Test the build with:")
    print("  cd _macOS && xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate")

if __name__ == '__main__':
    main()
