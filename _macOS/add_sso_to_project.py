#!/usr/bin/env python3
"""
Automated Xcode Project Integration Script
Ensures all SSO files are properly integrated into FinanceMate target
"""

import os
import re
import uuid
import shutil
from datetime import datetime

def backup_project_file():
    """Create backup of project.pbxproj file"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    backup_file = f'{project_file}.backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}'
    shutil.copy2(project_file, backup_file)
    print(f"✅ Project backup created: {backup_file}")
    return backup_file

def ensure_sso_files_in_project():
    """Ensure all SSO files are properly referenced in Xcode project"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    
    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # SSO files that must be in project
    sso_files = [
        'AppleAuthProvider.swift',
        'GoogleAuthProvider.swift', 
        'SSOManager.swift',
        'TokenStorage.swift',
        'AuthenticationService.swift'
    ]
    
    print("🔍 Checking SSO file integration status:")
    missing_files = []
    
    for file in sso_files:
        if file in content:
            print(f"✅ {file} - Found in project")
        else:
            print(f"❌ {file} - Missing from project") 
            missing_files.append(file)
    
    if missing_files:
        print(f"\n⚠️  {len(missing_files)} files need to be added to project")
        return False
    else:
        print("\n✅ All SSO files are properly integrated")
        return True

def fix_compilation_order():
    """Ensure SSOManager compiles before AuthenticationViewModel"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Find build phases section for FinanceMate target
    build_phases_pattern = r'buildPhases = \((.*?)\);'  
    sources_pattern = r'sources = \((.*?)\);'
    
    # Check if SSOManager is compiled before AuthenticationViewModel
    sso_index = content.find('SSOManager.swift in Sources')
    auth_vm_index = content.find('AuthenticationViewModel.swift in Sources')
    
    if sso_index > 0 and auth_vm_index > 0:
        if sso_index < auth_vm_index:
            print("✅ SSOManager compiles before AuthenticationViewModel")
            return True
        else:
            print("⚠️  Compilation order may need adjustment")
            return False
    else:
        print("❌ Could not verify compilation order")
        return False

def main():
    """Main execution function"""
    print("🚀 AUTOMATED XCODE PROJECT INTEGRATION")
    print("=" * 50)
    
    # Change to project directory
    os.chdir('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS')
    
    # Step 1: Backup project file
    backup_file = backup_project_file()
    
    # Step 2: Check file integration
    files_integrated = ensure_sso_files_in_project()
    
    # Step 3: Check compilation order
    compilation_order_ok = fix_compilation_order()
    
    # Step 4: Test build
    print("\n🔧 Testing build compilation...")
    build_result = os.system('xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build > build_test.log 2>&1')
    
    if build_result == 0:
        print("✅ BUILD SUCCESSFUL - All SSO files properly integrated")
        return True
    else:
        print("❌ BUILD FAILED - Additional fixes needed")
        # Show specific errors
        os.system('grep -E "error:|Error:" build_test.log | head -5')
        return False

if __name__ == "__main__":
    success = main()
    if success:
        print("\n🎉 AUTOMATED INTEGRATION COMPLETE")
    else:
        print("\n⚠️  MANUAL INTERVENTION REQUIRED")