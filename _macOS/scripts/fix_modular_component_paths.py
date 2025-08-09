#!/usr/bin/env python3

"""
Fix Modular Component Paths in Xcode Project
===========================================

This script fixes the file path references for the new modular authentication components
in the FinanceMate Xcode project. The paths need to include the full "FinanceMate/Views/"
prefix to match the actual file locations.
"""

import os
import sys
import shutil
from pathlib import Path

def fix_modular_component_paths():
    """Fix the file paths for modular authentication components in Xcode project"""
    
    project_dir = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
    project_file = project_dir / "FinanceMate.xcodeproj/project.pbxproj"
    
    if not project_file.exists():
        print(f"❌ Project file not found: {project_file}")
        return False
    
    # Backup the project file
    backup_file = project_file.with_suffix('.pbxproj.backup_path_fix')
    shutil.copy2(project_file, backup_file)
    print(f"📋 Created backup: {backup_file.name}")
    
    # Read the project file
    with open(project_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define the path fixes needed
    path_fixes = [
        ('path = "LoginHeaderView.swift"', 'path = "FinanceMate/Views/LoginHeaderView.swift"'),
        ('path = "AuthenticationFormView.swift"', 'path = "FinanceMate/Views/AuthenticationFormView.swift"'),
        ('path = "SSOButtonsView.swift"', 'path = "FinanceMate/Views/SSOButtonsView.swift"'),
        ('path = "MFAInputView.swift"', 'path = "FinanceMate/Views/MFAInputView.swift"'),
        ('path = "AuthenticationErrorView.swift"', 'path = "FinanceMate/Views/AuthenticationErrorView.swift"'),
        ('path = "ForgotPasswordView.swift"', 'path = "FinanceMate/Views/ForgotPasswordView.swift"')
    ]
    
    # Apply the path fixes
    fixes_applied = 0
    for old_path, new_path in path_fixes:
        if old_path in content:
            content = content.replace(old_path, new_path)
            fixes_applied += 1
            print(f"🔧 Fixed path: {old_path} → {new_path}")
        else:
            print(f"⚠️  Path not found: {old_path}")
    
    # Write the modified project file
    with open(project_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Applied {fixes_applied} path fixes to Xcode project")
    return fixes_applied > 0

def main():
    print("🔧 Fixing Modular Component Paths in Xcode Project")
    print("=" * 52)
    
    success = fix_modular_component_paths()
    
    if success:
        print("\n✅ PATH FIXES COMPLETE")
        print("🔍 Next Steps:")
        print("   1. Clean build: xcodebuild clean")
        print("   2. Build project: xcodebuild build")
        print("   3. Verify modular components compile correctly")
        return 0
    else:
        print("\n❌ PATH FIXES FAILED")
        print("🔧 Manual fix required in Xcode")
        return 1

if __name__ == "__main__":
    sys.exit(main())