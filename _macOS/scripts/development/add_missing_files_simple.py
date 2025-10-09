#!/usr/bin/env python3
"""
Add Missing Files to Xcode Project - Simple version
Adds SettingsSidebar.swift and SettingsContent.swift to project
"""

import os
import subprocess
import sys

def run_xcodeproj_command(command):
    """Run xcodeproj command to add files to project"""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
        if result.returncode == 0:
            print(f" Command successful: {command}")
            return True
        else:
            print(f" Command failed: {command}")
            print(f"Error: {result.stderr}")
            return False
    except Exception as e:
        print(f" Exception running command: {e}")
        return False

def add_missing_files():
    """Add missing Settings files using xcodeproj tools"""

    # Check if files exist
    files_to_add = [
        "FinanceMate/Views/Settings/SettingsSidebar.swift",
        "FinanceMate/Views/Settings/SettingsContent.swift"
    ]

    for file_path in files_to_add:
        full_path = f"/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/{file_path}"
        if not os.path.exists(full_path):
            print(f" File does not exist: {full_path}")
            return False

    # Try using xcodeproj gem (Ruby-based approach)
    commands = [
        "cd /Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents\\ -\\ Apps\\ \\(Working\\)/repos_github/Working/repo_financemate/_macOS && xcodeproj -project FinanceMate.xcodeproj -target FinanceMate add-file FinanceMate/Views/Settings/SettingsSidebar.swift",
        "cd /Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents\\ -\\ Apps\\ \\(Working\\)/repos_github/Working/repo_financemate/_macOS && xcodeproj -project FinanceMate.xcodeproj -target FinanceMate add-file FinanceMate/Views/Settings/SettingsContent.swift"
    ]

    success_count = 0
    for command in commands:
        if run_xcodeproj_command(command):
            success_count += 1

    if success_count > 0:
        print(f" Added {success_count} files to project")
        return True
    else:
        print("️ xcodeproj command not available, trying manual approach...")
        return add_files_manually()

def add_files_manually():
    """Manually add files by editing project.pbxproj"""
    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Simple approach: check if files are referenced
    with open(project_file, 'r') as f:
        content = f.read()

    missing_files = []
    if "SettingsSidebar.swift" not in content:
        missing_files.append("SettingsSidebar.swift")
    if "SettingsContent.swift" not in content:
        missing_files.append("SettingsContent.swift")

    if missing_files:
        print(f"️ Files missing from project: {missing_files}")
        print(" Please add these files manually using Xcode:")
        print("   1. Open FinanceMate.xcodeproj in Xcode")
        print("   2. Right-click on Settings group")
        print("   3. Select 'Add Files to FinanceMate...'")
        print(f"   4. Add: {', '.join(missing_files)}")
        return False
    else:
        print(" All files already present in project")
        return True

if __name__ == "__main__":
    print(" Adding missing Settings files to Xcode project...")
    if add_missing_files():
        print(" Missing files processed successfully!")
    else:
        print("️ Manual intervention required")
        sys.exit(1)