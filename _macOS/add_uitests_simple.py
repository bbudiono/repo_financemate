#!/usr/bin/env python3
"""
Simple script to add UI Test files to Xcode project using pbxproj library
with better error handling
"""

import os
import sys

def check_dependencies():
    """Check if required modules are available"""
    try:
        from pbxproj import XcodeProject
        print("✅ pbxproj module available")
        return True
    except ImportError as e:
        print(f"❌ ERROR: pbxproj module not available: {e}")
        return False

def add_uitest_files():
    """Add UI test files using pbxproj"""
    try:
        from pbxproj import XcodeProject
        
        # Project paths
        project_root = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        project_path = os.path.join(project_root, "FinanceMate.xcodeproj", "project.pbxproj")
        
        print(f"Loading project: {project_path}")
        
        # Check if project file exists
        if not os.path.exists(project_path):
            print(f"❌ ERROR: Project file not found: {project_path}")
            return False
        
        # UI test files to add
        uitest_files = [
            "FinanceMateUITests/FinanceMateUITests.swift",
            "FinanceMateUITests/DashboardViewUITests.swift", 
            "FinanceMateUITests/TransactionsViewUITests.swift",
            "FinanceMateUITests/SettingsViewUITests.swift"
        ]
        
        # Load project
        project = XcodeProject.load(project_path)
        print("✅ Project loaded successfully")
        
        # Add each file
        for relative_file_path in uitest_files:
            full_file_path = os.path.join(project_root, relative_file_path)
            
            if not os.path.exists(full_file_path):
                print(f"⚠️  Skipping missing file: {full_file_path}")
                continue
            
            print(f"Adding file: {relative_file_path}")
            
            try:
                # Add file to project
                project.add_file(full_file_path, target="FinanceMateUITests")
                print(f"✅ Added: {relative_file_path}")
            except Exception as e:
                print(f"⚠️  Could not add {relative_file_path}: {e}")
        
        # Save project
        project.save()
        print("✅ Project saved successfully")
        
        return True
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def main():
    print("🚀 Adding UI Test files to Xcode project...")
    print("=" * 50)
    
    if not check_dependencies():
        return 1
    
    if add_uitest_files():
        print("\n🎉 SUCCESS: UI test files have been added!")
        return 0
    else:
        print("\n❌ FAILED: Could not add UI test files")
        return 1

if __name__ == "__main__":
    sys.exit(main())