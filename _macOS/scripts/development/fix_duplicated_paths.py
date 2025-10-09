#!/usr/bin/env python3
"""
Fix Duplicated Xcode Project Paths
Removes double FinanceMate/ prefixes created by the previous fix
"""

import re
import os
import sys

def fix_duplicated_paths(project_file_path):
    """Fix duplicated paths in Xcode project.pbxproj file"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Fix double FinanceMate/ prefixes
    content = re.sub(r'path = "FinanceMate/FinanceMate/', 'path = "FinanceMate/', content)
    content = re.sub(r'path = FinanceMate/FinanceMate/', 'path = FinanceMate/', content)

    # Also fix any remaining path issues
    path_fixes = {
        'FinanceMate/Views/Gmail/FinanceMate/Views/Gmail/': 'FinanceMate/Views/Gmail/',
        'FinanceMate/Views/Settings/FinanceMate/Views/Settings/': 'FinanceMate/Views/Settings/',
        'FinanceMate/Services/FinanceMate/Services/': 'FinanceMate/Services/',
        'FinanceMate/ViewModels/FinanceMate/ViewModels/': 'FinanceMate/ViewModels/',
        'FinanceMate/Utilities/FinanceMate/Utilities/': 'FinanceMate/Utilities/',
        'FinanceMate/Components/FinanceMate/Components/': 'FinanceMate/Components/',
        'FinanceMate/Models/FinanceMate/Models/': 'FinanceMate/Models/',
        'FinanceMateTests/Services/FinanceMateTests/Services/': 'FinanceMateTests/Services/',
    }

    for bad_path, good_path in path_fixes.items():
        content = content.replace(bad_path, good_path)

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)
        print(f" Fixed duplicated paths in {project_file_path}")
        return True
    else:
        print(f"ℹ️ No duplicated path corrections needed")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Fixing duplicated Xcode project paths...")
        success = fix_duplicated_paths(project_file)

        if success:
            print(" Duplicated paths fixed successfully!")
        else:
            print("ℹ️ No fixes were needed")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)