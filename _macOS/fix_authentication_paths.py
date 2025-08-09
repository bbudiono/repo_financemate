#!/usr/bin/env python3

"""
Fix file paths for modular authentication components in Xcode project.

Purpose: Update the file paths in project.pbxproj to point to the correct location:
         FinanceMate/FinanceMate/ViewModels/ instead of the root directory.

This script fixes the path references that were incorrectly set during integration.
"""

import os
import re

def find_pbxproj_file():
    """Find the project.pbxproj file in the current directory structure."""
    current_dir = os.getcwd()
    
    # Look for .xcodeproj directory
    xcodeproj_dirs = [d for d in os.listdir(current_dir) if d.endswith('.xcodeproj')]
    if not xcodeproj_dirs:
        # We might be inside the xcodeproj already
        if os.path.exists('project.pbxproj'):
            return 'project.pbxproj'
        return None
    
    # Use the first .xcodeproj directory found
    pbxproj_path = os.path.join(xcodeproj_dirs[0], 'project.pbxproj')
    if os.path.exists(pbxproj_path):
        return pbxproj_path
    
    return None

def read_pbxproj(file_path):
    """Read the project.pbxproj file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def write_pbxproj(file_path, content):
    """Write the project.pbxproj file with backup."""
    # Create backup
    backup_path = f"{file_path}.backup_path_fix"
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Backup created: {backup_path}")
    
    # Write new content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Updated: {file_path}")

def fix_authentication_paths():
    """Main function to fix authentication component file paths."""
    
    # Files to fix
    modules = [
        'AuthenticationManager.swift',
        'SessionManager.swift', 
        'UserProfileManager.swift',
        'AuthenticationStateManager.swift'
    ]
    
    # Find project file
    pbxproj_path = find_pbxproj_file()
    if not pbxproj_path:
        print("❌ Error: Could not find project.pbxproj file")
        return False
    
    print(f"📁 Found project file: {pbxproj_path}")
    
    # Read current content
    content = read_pbxproj(pbxproj_path)
    original_content = content
    
    # Process each module
    for module in modules:
        print(f"\n🔧 Fixing path for {module}...")
        
        # Fix file reference path from root to ViewModels directory
        old_path_pattern = rf'({{isa = PBXFileReference;[^}}]*path = ){module}(; sourceTree = "<group>"; }})'
        new_path = f'FinanceMate/FinanceMate/ViewModels/{module}'
        
        replacement = rf'\1{new_path}\2'
        
        if re.search(old_path_pattern, content):
            content = re.sub(old_path_pattern, replacement, content)
            print(f"  ✅ Fixed path: {module} -> {new_path}")
        else:
            print(f"  ⚠️  Path pattern not found for: {module}")
        
        # Verify file exists at correct location
        expected_path = f"FinanceMate/FinanceMate/ViewModels/{module}"
        if os.path.exists(expected_path):
            print(f"  ✅ File exists at: {expected_path}")
        else:
            print(f"  ❌ File NOT found at: {expected_path}")
    
    # Write updated content if changes were made
    if content != original_content:
        write_pbxproj(pbxproj_path, content)
        print(f"\n🎉 Successfully fixed authentication module paths!")
        return True
    else:
        print(f"\n✅ All paths already correct")
        return True

if __name__ == "__main__":
    try:
        success = fix_authentication_paths()
        if success:
            print("\n🚀 Path fixes complete! Ready for build validation.")
        else:
            print("\n❌ Path fix failed!")
    except Exception as e:
        print(f"\n💥 Error during path fix: {str(e)}")
        import traceback
        traceback.print_exc()