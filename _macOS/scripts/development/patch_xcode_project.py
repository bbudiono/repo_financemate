#!/usr/bin/env python3

"""
Script to manually patch Xcode project file with new service files
"""

import os
import re
import uuid

def generate_uuid():
    """Generate a UUID in the format used by Xcode"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_service_files_to_project():
    project_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    # Service files to add
    service_files = [
        ("DashboardDataService.swift", "FinanceMate/Services/DashboardDataService.swift"),
        ("TransactionValidationService.swift", "FinanceMate/Services/TransactionValidationService.swift"),
        ("DashboardFormattingService.swift", "FinanceMate/Services/DashboardFormattingService.swift")
    ]

    # Read the current project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Find where to insert the new PBXBuildFile entries (after existing service files)
    build_file_pattern = r'(\t\tE589DCE0D4E64F558A41553A /\* EmailConnectorService\.swift in Sources \*/ = \{isa = PBXBuildFile; fileRef = ED9BE430567649E2AF9425B9 /\* EmailConnectorService\.swift \*/; \};\n)'

    # Find where to insert the new PBXFileReference entries (after existing service files)
    file_ref_pattern = r'(\t\tED9BE430567649E2AF9425B9 /\* EmailConnectorService\.swift \*/ = \{isa = PBXFileReference; lastKnownFileType = sourcecode\.swift; path = "FinanceMate/Services/EmailConnectorService\.swift"; sourceTree = "<group>"; \};\n)'

    # Find where to add to the Sources build phase (after existing service files)
    sources_pattern = r'(\t\t\t\tE589DCE0D4E64F558A41553A /\* EmailConnectorService\.swift in Sources \*/,)'

    # Add new build files, file references, and sources entries
    new_build_files = ""
    new_file_refs = ""
    new_sources = ""

    for filename, filepath in service_files:
        build_uuid = generate_uuid()
        file_ref_uuid = generate_uuid()

        new_build_files += f'\t\t{build_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};\n'
        new_file_refs += f'\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{filepath}"; sourceTree = "<group>"; }};\n'
        new_sources += f'\t\t\t\t{build_uuid} /* {filename} in Sources */,\n'

    # Insert the new entries
    content = re.sub(build_file_pattern, r'\1' + new_build_files, content)
    content = re.sub(file_ref_pattern, r'\1' + new_file_refs, content)
    content = re.sub(sources_pattern, r'\1' + new_sources, content)

    # Write the updated content back
    with open(project_path, 'w') as f:
        f.write(content)

    print(f" Added {len(service_files)} service files to Xcode project")
    return True

if __name__ == "__main__":
    add_service_files_to_project()