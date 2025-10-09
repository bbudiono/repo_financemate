#!/usr/bin/env python3
"""
Fix Core Data Builder File Paths
Corrects the path references for Core Data builder files
"""

import re
import os
import sys

def fix_core_data_paths(project_file_path):
    """Fix Core Data builder file paths in Xcode project"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Fix the path references for Core Data builder files
    # They should be relative to the FinanceMate group, not include FinanceMate/ prefix
    path_corrections = {
        'path = "FinanceMate/CoreDataRelationshipBuilder.swift"': 'path = "CoreDataRelationshipBuilder.swift"',
        'path = "FinanceMate/CoreDataEntityBuilder.swift"': 'path = "CoreDataEntityBuilder.swift"',
        'path = "FinanceMate/CoreDataModelBuilder.swift"': 'path = "CoreDataModelBuilder.swift"',
    }

    changes_made = 0
    for wrong_path, correct_path in path_corrections.items():
        if wrong_path in content:
            content = content.replace(wrong_path, correct_path)
            changes_made += 1
            print(f"Fixed: {wrong_path} -> {correct_path}")

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)
        print(f"\n Fixed {changes_made} Core Data file paths")
        return True
    else:
        print(f"\nℹ️ No Core Data path corrections needed")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Fixing Core Data builder file paths...")
        success = fix_core_data_paths(project_file)

        if success:
            print(" Core Data paths fixed successfully!")
        else:
            print("ℹ️ No fixes were needed")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)