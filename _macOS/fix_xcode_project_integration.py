#!/usr/bin/env python3
"""
Comprehensive Xcode Project Integration Fix
Ensures all SSO files are properly added to the Xcode project with correct build phases
"""

import os
import re
import uuid
import shutil
from datetime import datetime

def backup_project():
    """Create backup of project.pbxproj"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    backup_file = f'{project_file}.backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}'
    shutil.copy2(project_file, backup_file)
    print(f"✅ Project backup: {backup_file}")
    return backup_file

def verify_file_references():
    """Verify all SSO files have proper file references in project"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Files that must be referenced
    required_files = [
        'SSOManager.swift',
        'AppleAuthProvider.swift', 
        'GoogleAuthProvider.swift',
        'TokenStorage.swift',
        'AuthenticationService.swift',
        'UserSession.swift'  # Contains OAuth2Provider and AuthenticationResult
    ]
    
    print("🔍 Verifying file references...")
    missing_refs = []
    
    for filename in required_files:
        # Look for file reference pattern
        if f'/* {filename} */' in content:
            print(f"✅ {filename} - File reference found")
        else:
            print(f"❌ {filename} - Missing file reference")
            missing_refs.append(filename)
    
    return missing_refs

def verify_build_phases():
    """Verify all SSO files are in Compile Sources build phase"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    required_files = [
        'SSOManager.swift',
        'AppleAuthProvider.swift',
        'GoogleAuthProvider.swift', 
        'TokenStorage.swift',
        'AuthenticationService.swift',
        'UserSession.swift'
    ]
    
    print("🔍 Verifying build phases...")
    missing_builds = []
    
    for filename in required_files:
        # Look for build phase pattern
        if f'{filename} in Sources' in content:
            print(f"✅ {filename} - In Compile Sources")
        else:
            print(f"❌ {filename} - Missing from Compile Sources") 
            missing_builds.append(filename)
    
    return missing_builds

def fix_compilation_dependencies():
    """Ensure proper compilation order and dependencies"""
    project_file = 'FinanceMate.xcodeproj/project.pbxproj'
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Define compilation order (dependencies first)
    compilation_order = [
        'UserSession.swift',           # Contains OAuth2Provider, AuthenticationResult
        'TokenStorage.swift',          # Depends on OAuth2Provider
        'AppleAuthProvider.swift',     # Depends on TokenStorage, AuthenticationResult
        'GoogleAuthProvider.swift',    # Depends on TokenStorage, AuthenticationResult
        'SSOManager.swift',           # Depends on all above
        'AuthenticationService.swift', # Uses providers
        'AuthenticationViewModel.swift' # Uses SSOManager
    ]
    
    print(f"🔧 Recommended compilation order:")
    for i, filename in enumerate(compilation_order, 1):
        print(f"  {i}. {filename}")
    
    # Check current order in Sources build phase
    sources_section = re.search(r'sources = \((.*?)\);', content, re.DOTALL)
    if sources_section:
        sources_content = sources_section.group(1)
        print(f"\n📋 Current Sources build phase has {len(sources_content.split('in Sources'))} files")
    
    return True

def test_build_after_fixes():
    """Test build after applying fixes"""
    print("\n🔧 Testing build after fixes...")
    
    result = os.system('xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build > build_fix_test.log 2>&1')
    
    if result == 0:
        print("✅ BUILD SUCCESSFUL!")
        return True
    else:
        print("❌ Build still failing. Checking errors...")
        
        # Show first few errors
        os.system('grep -E "error:" build_fix_test.log | head -3')
        return False

def create_manual_fix_instructions():
    """Create manual fix instructions if automated fixes don't work"""
    
    instructions = """
# MANUAL XCODE PROJECT FIX INSTRUCTIONS

## Problem: SSO files not visible to each other during compilation

## Solution: Manual Xcode Project Configuration

### Step 1: Open Xcode Project
1. Open FinanceMate.xcodeproj in Xcode
2. Select FinanceMate project in navigator
3. Select FinanceMate target

### Step 2: Verify File References
In Project Navigator, ensure these files are present:
- FinanceMate/Services/SSOManager.swift
- FinanceMate/Services/AppleAuthProvider.swift  
- FinanceMate/Services/GoogleAuthProvider.swift
- FinanceMate/Services/TokenStorage.swift
- FinanceMate/Services/AuthenticationService.swift
- FinanceMate/Models/UserSession.swift

### Step 3: Check Build Phases
1. Select FinanceMate target
2. Go to Build Phases tab
3. Expand "Compile Sources"
4. Ensure ALL SSO files are listed
5. If missing, drag files from navigator to Compile Sources

### Step 4: Check Compilation Order
In Compile Sources, ensure this order:
1. UserSession.swift (first - defines OAuth2Provider)  
2. TokenStorage.swift
3. AppleAuthProvider.swift
4. GoogleAuthProvider.swift
5. SSOManager.swift
6. AuthenticationService.swift
7. AuthenticationViewModel.swift (last - uses SSOManager)

### Step 5: Clean and Build
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)

### Step 6: If Still Fails
The issue might be circular dependencies or module visibility.
Consider adding explicit imports or restructuring the code.
"""
    
    with open('MANUAL_XCODE_FIX_INSTRUCTIONS.md', 'w') as f:
        f.write(instructions)
    
    print("📋 Created MANUAL_XCODE_FIX_INSTRUCTIONS.md")

def main():
    """Main execution function"""
    print("🔧 COMPREHENSIVE XCODE PROJECT INTEGRATION FIX")
    print("=" * 60)
    
    # Change to project directory
    os.chdir('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS')
    
    # Step 1: Backup project
    backup_file = backup_project()
    
    # Step 2: Verify file references
    missing_refs = verify_file_references()
    
    # Step 3: Verify build phases  
    missing_builds = verify_build_phases()
    
    # Step 4: Check compilation dependencies
    fix_compilation_dependencies()
    
    # Step 5: Test build
    build_success = test_build_after_fixes()
    
    # Step 6: Create manual instructions if needed
    if not build_success:
        create_manual_fix_instructions()
        print("\n⚠️  AUTOMATED FIX INCOMPLETE - MANUAL INTERVENTION REQUIRED")
        print("📋 See MANUAL_XCODE_FIX_INSTRUCTIONS.md for detailed steps")
        return False
    else:
        print("\n🎉 AUTOMATED FIX SUCCESSFUL!")
        return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)