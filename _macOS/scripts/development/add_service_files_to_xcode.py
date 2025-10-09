#!/usr/bin/env python3
"""
Script to add new service files to Xcode project
Updates project.pbxproj with EmailConnectorService, GmailAPIService, and CoreDataManager
"""

import re
import uuid
import shutil
from pathlib import Path

def generate_uuid():
    """Generate a random UUID for Xcode project references"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_file_to_project(project_file_path, file_path, group_name="FinanceMate"):
    """Add a Swift file to Xcode project.pbxproj"""

    project_file = Path(project_file_path)
    if not project_file.exists():
        print(f"Project file not found: {project_file_path}")
        return False

    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate UUIDs for the new file references
    file_ref_uuid = generate_uuid()
    build_file_uuid = generate_uuid()

    # Get relative path from project file directory to the Swift file
    swift_file_path = Path(file_path)
    project_dir = project_file.parent.parent  # Go up from .xcodeproj directory
    relative_path = swift_file_path.relative_to(project_dir)

    # Add to PBXBuildFile section
    pbx_build_file_pattern = r'(/* Begin PBXBuildFile section \*/)'
    build_file_entry = f'\t\t{build_file_uuid} /* {swift_file_path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {swift_file_path.name} */; }};\n'
    content = re.sub(pbx_build_file_pattern, r'\1' + build_file_entry, content)

    # Add to PBXFileReference section
    pbx_file_ref_pattern = r'(/* Begin PBXFileReference section \*/)'
    file_ref_entry = f'\t\t{file_ref_uuid} /* {swift_file_path.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{relative_path}"; sourceTree = "<group>"; }};\n'
    content = re.sub(pbx_file_ref_pattern, r'\1' + file_ref_entry, content)

    # Add to Sources build phase
    sources_phase_pattern = r'(\t\t\t/* Sources \*/ = \{[^}]+?files = \(\n)'
    sources_entry = f'\t\t\t\t{build_file_uuid} /* {swift_file_path.name} in Sources */,\n'
    content = re.sub(sources_phase_pattern, r'\1' + sources_entry, content)

    # Add to group (find the FinanceMate group)
    group_pattern = r'(\t\t\t[^}]+?FinanceMate[^}]*?children = \(\n)'
    group_entry = f'\t\t\t\t{file_ref_uuid} /* {swift_file_path.name} */,\n'
    content = re.sub(group_pattern, r'\1' + group_entry, content)

    # Write back the modified content
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Added {swift_file_path.name} to Xcode project")
    return True

def main():
    """Main function to add all service files to the project"""

    # Project file path
    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Service files to add
    service_files = [
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/EmailConnectorService.swift",
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/GmailAPIService.swift",
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CoreDataManager.swift",
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailViewModelRefactored.swift"
    ]

    # Test files to add
    test_files = [
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateTests/Services/EmailConnectorServiceTests.swift",
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateTests/Services/GmailAPIServiceTests.swift",
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMateTests/Services/CoreDataManagerTests.swift"
    ]

    print("Adding service files to Xcode project...")

    success_count = 0
    for file_path in service_files:
        if Path(file_path).exists():
            if add_file_to_project(project_file, file_path):
                success_count += 1
        else:
            print(f"File not found: {file_path}")

    print(f"Successfully added {success_count}/{len(service_files)} service files")

    print("\nAdding test files to Xcode project...")

    test_success_count = 0
    for file_path in test_files:
        if Path(file_path).exists():
            if add_file_to_project(project_file, file_path, group_name="FinanceMateTests"):
                test_success_count += 1
        else:
            print(f"Test file not found: {file_path}")

    print(f"Successfully added {test_success_count}/{len(test_files)} test files")

    if success_count + test_success_count > 0:
        print("\nProject file updated successfully!")
        print("Please open Xcode and verify the files are properly included.")
    else:
        print("\nNo files were added. Please check the file paths.")

if __name__ == "__main__":
    main()