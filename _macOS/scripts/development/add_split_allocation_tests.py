#!/usr/bin/env python3
"""
Script to add SplitAllocationTests.swift to the Xcode project
"""

import re
import uuid

def add_test_file_to_project():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Generate unique UUIDs for the new entries
    file_ref_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    build_file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Find the test target section (FinanceMateTests)
    test_target_pattern = r'(TestTarget\s*=\s*\{[^}]*name\s*=\s*FinanceMateTests[^}]*buildPhases\s*=\s*\([^)]*)(\);)'
    test_target_match = re.search(test_target_pattern, content, re.DOTALL)

    if test_target_match:
        # Find the Sources build phase in test target
        sources_pattern = r'(\w+\s*\/\*\s*Sources\s*\s*\/\*\s*=\s*\{[^}]*files\s*=\s*\()([^)]*)(\);)'
        sources_match = re.search(sources_pattern, content, re.DOTALL)

        if sources_match:
            # Add our test file to the sources
            new_sources_entry = f"\n\t\t\t\t{build_file_uuid} /* SplitAllocationTests.swift in Sources */,"
            updated_sources = sources_match.group(1) + sources_match.group(2) + new_sources_entry + sources_match.group(3)
            content = content.replace(sources_match.group(0), updated_sources)

    # Add the file reference to the project
    file_refs_pattern = r'(\/*\s*End\s+PBXFileReference\s*section)'
    file_entry = f"""\t\t{file_ref_uuid} /* SplitAllocationTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationTests.swift; sourceTree = "<group>"; }};
{file_refs_pattern}"""
    content = re.sub(file_refs_pattern, file_entry, content)

    # Add to test group
    test_group_pattern = r'(\/*\s*FinanceMateTests\s*\/\*\s*=\s*\{[^}]*children\s*=\s*\([^)]*)(\);)'
    test_group_match = re.search(test_group_pattern, content, re.DOTALL)

    if test_group_match:
        new_child = f"\n\t\t\t\t{file_ref_uuid} /* SplitAllocationTests.swift */,"
        updated_children = test_group_match.group(1) + test_group_match.group(2) + new_child + test_group_match.group(3)
        content = content.replace(test_group_match.group(0), updated_children)

    # Add the build file entry
    build_file_pattern = r'(\/*\s*End\s+PBXBuildFile\s*section)'
    build_entry = f"""\t\t{build_file_uuid} /* SplitAllocationTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* SplitAllocationTests.swift */; }};
{build_file_pattern}"""
    content = re.sub(build_file_pattern, build_entry, content)

    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Added SplitAllocationTests.swift to Xcode project")
    print(f"File reference UUID: {file_ref_uuid}")
    print(f"Build file UUID: {build_file_uuid}")

if __name__ == "__main__":
    add_test_file_to_project()