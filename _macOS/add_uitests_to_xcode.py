#!/usr/bin/env python3
"""
Add UI Test Swift files to Xcode project FinanceMateUITests target
This script resolves the critical blocking issue where FinanceMateUITests files
are not included in the FinanceMateUITests Xcode project target.
"""

import os
import sys
from pbxproj import XcodeProject

# Configuration
PROJECT_PATH = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj"
PBXPROJ_PATH = os.path.join(PROJECT_PATH, "project.pbxproj")

# UI Test files to add
UI_TEST_FILES_TO_ADD = [
    {
        "file_path": "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateUITests/FinanceMateUITests.swift",
        "relative_path": "FinanceMateUITests/FinanceMateUITests.swift",
        "target": "FinanceMateUITests",
        "group": "FinanceMateUITests"
    },
    {
        "file_path": "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateUITests/DashboardViewUITests.swift",
        "relative_path": "FinanceMateUITests/DashboardViewUITests.swift",
        "target": "FinanceMateUITests",
        "group": "FinanceMateUITests"
    },
    {
        "file_path": "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateUITests/TransactionsViewUITests.swift",
        "relative_path": "FinanceMateUITests/TransactionsViewUITests.swift",
        "target": "FinanceMateUITests",
        "group": "FinanceMateUITests"
    },
    {
        "file_path": "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateUITests/SettingsViewUITests.swift",
        "relative_path": "FinanceMateUITests/SettingsViewUITests.swift",
        "target": "FinanceMateUITests",
        "group": "FinanceMateUITests"
    }
]

def validate_files_exist():
    """Validate that the UI Test Swift files exist before adding to project"""
    print("Validating UI Test Swift files exist...")
    
    for file_info in UI_TEST_FILES_TO_ADD:
        if not os.path.exists(file_info["file_path"]):
            print(f"❌ ERROR: File does not exist: {file_info['file_path']}")
            return False
        else:
            print(f"✅ File exists: {file_info['relative_path']}")
    
    return True

def add_files_to_project():
    """Add the UI Test Swift files to the FinanceMateUITests target"""
    print(f"\nOpening Xcode project: {PBXPROJ_PATH}")
    
    try:
        # Load the Xcode project
        project = XcodeProject.load(PBXPROJ_PATH)
        
        # Get available targets
        targets = project.objects.get_targets()
        target_names = [project.objects[t].name for t in targets]
        print(f"Available targets: {target_names}")
        
        # Verify FinanceMateUITests target exists
        if "FinanceMateUITests" not in target_names:
            print("❌ ERROR: FinanceMateUITests target not found in project")
            return False
        
        # Process each UI test file
        for file_info in UI_TEST_FILES_TO_ADD:
            print(f"\nProcessing: {file_info['relative_path']}")
            
            # Check if file is already in project
            existing_files = project.objects.get_files_by_path(file_info["relative_path"])
            if existing_files:
                print(f"⚠️  File already exists in project: {file_info['relative_path']}")
                continue
            
            # Add file to project and target
            file_ref = project.add_file(
                file_info["file_path"],
                target=file_info["target"],
                parent=project.objects.get_or_create_group(file_info["group"])
            )
            
            print(f"✅ Added {file_info['relative_path']} to target {file_info['target']}")
        
        # Save the project
        project.save()
        print(f"\n✅ Project saved successfully: {PBXPROJ_PATH}")
        
        return True
        
    except Exception as e:
        print(f"❌ ERROR: Failed to modify project: {e}")
        return False

def verify_files_added():
    """Verify that the UI Test files were successfully added to the project"""
    print("\nVerifying UI Test files were added to project...")
    
    try:
        project = XcodeProject.load(PBXPROJ_PATH)
        
        for file_info in UI_TEST_FILES_TO_ADD:
            file_refs = project.objects.get_files_by_path(file_info["relative_path"])
            if file_refs:
                print(f"✅ Verified: {file_info['relative_path']} is in project")
                
                # Check if file is in target build phase
                targets = project.objects.get_targets()
                target_found = False
                
                for target_id in targets:
                    target = project.objects[target_id]
                    if target.name == file_info["target"]:
                        target_found = True
                        # Check if file is in target's build files
                        build_phases = target.get('buildPhases', [])
                        file_in_target = False
                        
                        for phase_id in build_phases:
                            phase = project.objects[phase_id]
                            if hasattr(phase, 'files') and phase.files:
                                for build_file_id in phase.files:
                                    build_file = project.objects[build_file_id]
                                    if build_file.fileRef in file_refs:
                                        file_in_target = True
                                        break
                            if file_in_target:
                                break
                        
                        if file_in_target:
                            print(f"✅ Verified: {file_info['relative_path']} is in target {file_info['target']}")
                        else:
                            print(f"❌ ERROR: {file_info['relative_path']} is NOT in target {file_info['target']}")
                            return False
                        break
                
                if not target_found:
                    print(f"❌ ERROR: Target not found: {file_info['target']}")
                    return False
            else:
                print(f"❌ ERROR: {file_info['relative_path']} is NOT in project")
                return False
        
        return True
        
    except Exception as e:
        print(f"❌ ERROR: Failed to verify project: {e}")
        return False

def main():
    """Main execution function"""
    print("🚀 Adding UI Test Swift files to FinanceMateUITests target...")
    print("=" * 60)
    
    # Step 1: Validate files exist
    if not validate_files_exist():
        sys.exit(1)
    
    # Step 2: Add files to project
    if not add_files_to_project():
        sys.exit(1)
    
    # Step 3: Verify files were added
    if not verify_files_added():
        sys.exit(1)
    
    print("\n🎉 SUCCESS: All UI Test files have been successfully added to FinanceMateUITests target!")
    print("=" * 60)
    print("Next steps:")
    print("1. Open Xcode and verify the UI test files appear in the project navigator")
    print("2. Run a test build to ensure UI tests compilation succeeds")
    print("3. Run UI tests to verify test discovery works")
    print("4. UI tests should execute headlessly and capture screenshots")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())