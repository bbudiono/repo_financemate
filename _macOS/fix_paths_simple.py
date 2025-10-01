#!/usr/bin/env python3
"""
Simple fix for Xcode project path references.
Removes lines referencing FinanceMate/FinanceMate/... paths (double nested - wrong).
"""

import re
import sys

def fix_project_paths(project_file_path):
    """Fix incorrect path references in project.pbxproj"""

    print(f"Reading: {project_file_path}")
    with open(project_file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_line_count = content.count('\n')

    # Pattern to match lines with FinanceMate/FinanceMate/ paths (double nested - WRONG)
    # These are the stale references from the old implementation
    wrong_path_pattern = r'.*/FinanceMate/FinanceMate/.*\.swift'

    # Find all lines with wrong paths
    lines = content.split('\n')
    cleaned_lines = []
    removed_lines = []
    removed_count = 0

    # Track UUIDs of files to remove
    uuids_to_remove = set()

    # First pass: find UUIDs of files with wrong paths
    for line in lines:
        if re.search(wrong_path_pattern, line):
            # Extract UUID from the line
            uuid_match = re.search(r'([A-F0-9]{24})', line)
            if uuid_match:
                uuids_to_remove.add(uuid_match.group(1))
                removed_lines.append(line.strip())
                removed_count += 1

    print(f"\nFound {removed_count} lines with incorrect paths")
    print(f"Found {len(uuids_to_remove)} file UUIDs to remove")

    # Second pass: remove lines containing any of the bad UUIDs
    final_lines = []
    total_removed = 0

    for line in lines:
        # Check if this line references any of the UUIDs to remove
        should_remove = False
        for uuid in uuids_to_remove:
            if uuid in line:
                should_remove = True
                total_removed += 1
                break

        if not should_remove:
            final_lines.append(line)

    # Join back together
    fixed_content = '\n'.join(final_lines)

    print(f"\nTotal lines removed: {total_removed}")

    # Write back
    print(f"Writing fixed content to: {project_file_path}")
    with open(project_file_path, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print("\nSample removed lines:")
    for i, line in enumerate(removed_lines[:5]):
        print(f"  {i+1}. {line[:100]}...")

    print("\n Project file fixed!")
    print(f"   Original lines: {original_line_count}")
    print(f"   Removed: {total_removed}")
    print(f"   Final lines: {fixed_content.count(chr(10))}")

    return removed_count

if __name__ == '__main__':
    project_path = '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj'

    print("="*70)
    print("FIXING XCODE PROJECT FILE REFERENCES")
    print("="*70)

    removed = fix_project_paths(project_path)

    print("\n" + "="*70)
    print("NEXT STEPS")
    print("="*70)
    print("1. Test the build:")
    print("   cd _macOS && xcodebuild build -project FinanceMate.xcodeproj -scheme FinanceMate")
    print("\n2. If build fails, restore backup:")
    print("   cp FinanceMate.xcodeproj/project.pbxproj.backup FinanceMate.xcodeproj/project.pbxproj")
