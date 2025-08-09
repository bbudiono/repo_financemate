#!/usr/bin/env python3

"""
Remove new authentication modules from UITest targets.

Purpose: Remove AuthenticationManager, SessionManager, UserProfileManager, 
         and AuthenticationStateManager from UITest build targets since
         we don't use XCUITest according to project guidelines.

This script ensures the new modules are only included in the main target
and unit tests, not in the deprecated UITest targets.
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
    backup_path = f"{file_path}.backup_uitest_fix"
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Backup created: {backup_path}")
    
    # Write new content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Updated: {file_path}")

def remove_from_uitest_targets():
    """Main function to remove authentication modules from UITest targets."""
    
    # Files to remove from UITest targets
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
    
    # Find UITest target build phases
    # Look for FinanceMateUITests target build phases
    uitest_pattern = r'(/\* Sources \*/ = \{[^}]*?productReference = [A-F0-9]+ /\* FinanceMateUITests\.xctest \*/;[^}]*?files = \(\s*)(.*?)(\s*\);[^}]*?\};)'
    
    def remove_modules_from_uitest_sources(match):
        prefix = match.group(1)
        files_section = match.group(2)
        suffix = match.group(3)
        
        # Remove authentication module build files from UITest target
        for module in modules:
            # Remove build file references containing the module name
            pattern = rf'\s*[A-F0-9]+ /\* {re.escape(module)} in Sources \*/,?'
            files_section = re.sub(pattern, '', files_section)
            print(f"  🗑️  Removed {module} from UITest Sources")
        
        return prefix + files_section + suffix
    
    # Apply the removal
    if re.search(uitest_pattern, content, re.DOTALL):
        content = re.sub(uitest_pattern, remove_modules_from_uitest_sources, content, flags=re.DOTALL)
        print("✅ Found and processed UITest Sources build phase")
    else:
        print("⚠️  UITest Sources build phase pattern not found")
    
    # Also remove from any other UITest-related build phases
    # Look for any other UITest references and clean them up
    for module in modules:
        # Remove any remaining UITest references
        uitest_ref_pattern = rf'[A-F0-9]+ /\* {re.escape(module)} in Sources \*/ = \{{isa = PBXBuildFile; fileRef = [A-F0-9]+ /\* {re.escape(module)} \*/; \}};'
        if re.search(uitest_ref_pattern, content):
            # Don't remove the main build file reference, just ensure it's not in UITest target
            print(f"  ⚠️  Found UITest build reference for {module}, but keeping main reference")
    
    # Write updated content if changes were made
    if content != original_content:
        write_pbxproj(pbxproj_path, content)
        print(f"\n🎉 Successfully removed authentication modules from UITest targets!")
        return True
    else:
        print(f"\n✅ No UITest references found to remove")
        return True

if __name__ == "__main__":
    try:
        success = remove_from_uitest_targets()
        if success:
            print("\n🚀 UITest cleanup complete! Ready for unit tests.")
        else:
            print("\n❌ UITest cleanup failed!")
    except Exception as e:
        print(f"\n💥 Error during UITest cleanup: {str(e)}")
        import traceback
        traceback.print_exc()