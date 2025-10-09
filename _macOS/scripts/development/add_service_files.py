#!/usr/bin/env python3

"""
Script to add new service files to Xcode project
"""

import os
import subprocess
import uuid

def add_file_to_xcode_project(project_path, file_path, group_name="FinanceMate"):
    """Add a file to Xcode project using xcodeproj"""
    try:
        # Generate UUIDs for the file reference and build file
        file_ref_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

        # Get relative path
        rel_path = os.path.relpath(file_path, os.path.dirname(project_path))

        # Use xcodeproj to add file
        cmd = [
            'xcodeproj',
            '-p', project_path,
            'add', rel_path
        ]

        result = subprocess.run(cmd, capture_output=True, text=True, cwd=os.path.dirname(project_path))

        if result.returncode == 0:
            print(f" Added {file_path} to project")
            return True
        else:
            print(f" Failed to add {file_path}: {result.stderr}")
            return False

    except Exception as e:
        print(f" Error adding {file_path}: {e}")
        return False

def main():
    # Define paths
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_path = os.path.join(project_dir, "FinanceMate.xcodeproj")

    # New service files to add
    service_files = [
        "FinanceMate/Services/DashboardDataService.swift",
        "FinanceMate/Services/TransactionValidationService.swift",
        "FinanceMate/Services/DashboardFormattingService.swift"
    ]

    print(" Adding service files to Xcode project...")

    success_count = 0
    for service_file in service_files:
        file_path = os.path.join(project_dir, service_file)
        if os.path.exists(file_path):
            if add_file_to_xcode_project(project_path, file_path):
                success_count += 1
        else:
            print(f" File not found: {file_path}")

    print(f" Added {success_count}/{len(service_files)} files to project")

    if success_count == len(service_files):
        print(" All service files added successfully!")
        return True
    else:
        print("️ Some files could not be added automatically")
        return False

if __name__ == "__main__":
    main()