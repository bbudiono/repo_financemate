#!/usr/bin/env python3
"""
Add Gmail Archive System tests to Xcode project
Phase 2 RED: Adds failing test files for Gmail archive functionality
"""

import os
import re
import uuid

def add_test_target_to_project():
    """Add test target and files to Xcode project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Read current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate UUIDs for new entries
    test_target_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    test_build_phase_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    test_files = [
        "GmailArchiveSystemTests.swift",
        "Views/GmailReceiptsTableViewArchiveTests.swift",
        "Services/GmailArchiveServiceTests.swift",
        "CoreDataGmailArchiveTests.swift",
        "GmailArchiveIntegrationTests.swift"
    ]

    # Create build file entries for test files
    build_file_entries = ""
    file_reference_entries = ""

    for test_file in test_files:
        file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
        build_file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

        build_file_entries += f"""
\t\t{build_file_uuid} /* {test_file} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {test_file} */; }};
"""
        file_reference_entries += f"""
\t\t{file_uuid} /* {test_file} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "FinanceMateTests/{test_file}"; sourceTree = "<group>"; }};
"""

    # Create test target entry
    test_target_entry = f"""
\t\t{test_target_uuid} /* FinanceMateTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {str(uuid.uuid4()).replace('-', '').upper()[:24]} /* Build configuration list for PBXNativeTarget "FinanceMateTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{test_build_phase_uuid} /* Sources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = FinanceMateTests;
\t\t\tproductName = FinanceMateTests;
\t\t\tproductReference = {str(uuid.uuid4()).replace('-', '').upper()[:24]} /* FinanceMateTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};
"""

    # Create test build phase entry
    test_build_phase_entry = f"""
\t\t{test_build_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{build_file_entries}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
"""

    # Add test target to targets section
    targets_section = re.search(r'(/\* Begin PBXNativeTarget section \*/.*?/\* End PBXNativeTarget section \*/)', content, re.DOTALL)
    if targets_section:
        new_targets_section = targets_section.group(1) + test_target_entry
        content = content.replace(targets_section.group(1), new_targets_section)

    # Add test files to build files section
    build_files_section = re.search(r'(/\* Begin PBXBuildFile section \*/)', content)
    if build_files_section:
        insertion_point = build_files_section.end()
        content = content[:insertion_point] + build_file_entries + content[insertion_point:]

    # Add file references
    file_refs_section = re.search(r'(/\* Begin PBXFileReference section \*/)', content)
    if file_refs_section:
        insertion_point = file_refs_section.end()
        content = content[:insertion_point] + file_reference_entries + content[insertion_point:]

    # Update project references to include test target
    project_section = re.search(r'(targets = \([^)]*\);)', content)
    if project_section:
        new_targets = project_section.group(1).replace(');', f',\n\t\t\t\t{test_target_uuid} /* FinanceMateTests */,);')
        content = content.replace(project_section.group(1), new_targets)

    # Write updated project file
    with open(project_file, 'w') as f:
        f.write(content)

    print(" Added test target and Gmail archive test files to Xcode project")
    print(f" Added {len(test_files)} test files:")
    for test_file in test_files:
        print(f"   - FinanceMateTests/{test_file}")

if __name__ == "__main__":
    add_test_target_to_project()