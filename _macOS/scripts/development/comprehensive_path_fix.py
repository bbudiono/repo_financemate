#!/usr/bin/env python3
"""
Comprehensive Xcode Project Path Fix
Fixes all duplicated FinanceMate/ paths in project file
"""

import re
import os
import sys

def comprehensive_path_fix(project_file_path):
    """Fix all duplicated paths in Xcode project.pbxproj file"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Fix all instances of double FinanceMate/ prefix
    patterns_to_fix = [
        (r'path = "FinanceMate/FinanceMate/', 'path = "FinanceMate/'),
        (r'path = FinanceMate/FinanceMate/', 'path = FinanceMate/'),
        (r'name = "([^"]+)"; path = "FinanceMate/FinanceMate/', r'name = "\1"; path = "FinanceMate/'),
        (r'fileRef = [A-F0-9]+ /\* ([^*]+) \*/;', r'\1'),  # This will help identify the pattern
    ]

    for pattern, replacement in patterns_to_fix:
        content = re.sub(pattern, replacement, content)

    # More specific fixes for the exact duplicated paths we see
    specific_fixes = {
        'FinanceMate/FinanceMate/Views/': 'FinanceMate/Views/',
        'FinanceMate/FinanceMate/ViewModels/': 'FinanceMate/ViewModels/',
        'FinanceMate/FinanceMate/Services/': 'FinanceMate/Services/',
        'FinanceMate/FinanceMate/Utilities/': 'FinanceMate/Utilities/',
        'FinanceMate/FinanceMate/Components/': 'FinanceMate/Components/',
        'FinanceMate/FinanceMate/Models/': 'FinanceMate/Models/',
        'FinanceMate/FinanceMate/Tests/': 'FinanceMate/Tests/',
        'FinanceMate/FinanceMateTests/': 'FinanceMateTests/',
    }

    for bad_path, good_path in specific_fixes.items():
        content = content.replace(bad_path, good_path)

    # Also fix name references that might have the duplication
    content = re.sub(r'name = "FinanceMate/FinanceMate/([^"]+)"', r'name = "\1"', content)

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)

        # Count changes
        changes = len([line for line in content.split('\n') if 'FinanceMate/FinanceMate/' in line])
        print(f" Fixed comprehensive path issues in {project_file_path}")
        print(f" Remaining duplicated paths: {changes}")
        return True
    else:
        print(f"ℹ️ No comprehensive path corrections needed")
        return False

def clean_derived_data():
    """Clean Xcode derived data to force regeneration"""
    derived_data_path = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData"
    finance_match_path = os.path.join(derived_data_path, "FinanceMate-*")

    try:
        import glob
        finance_dirs = glob.glob(finance_match_path)
        for finance_dir in finance_dirs:
            import shutil
            shutil.rmtree(finance_dir)
            print(f"️  Cleaned: {finance_dir}")
        return True
    except Exception as e:
        print(f"️ Could not clean derived data: {e}")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Applying comprehensive Xcode project path fixes...")
        success = comprehensive_path_fix(project_file)

        if success:
            print("️  Cleaning derived data to force regeneration...")
            clean_derived_data()
            print(" Comprehensive path fixes completed!")
        else:
            print("ℹ️ No fixes were needed")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)