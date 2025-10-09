#!/usr/bin/env python3
"""
Simplified script to add SplitAllocationTests.swift to the Xcode project
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

    # Find where to add the build file entry (before End PBXBuildFile section)
    build_file_pattern = r'(.*)(/\* End PBXBuildFile section.*)'
    build_entry = f"\t\t{build_file_uuid} /* SplitAllocationTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* SplitAllocationTests.swift */; }};\n"
    content = re.sub(build_file_pattern, r'\1' + build_entry + r'\2', content, flags=re.DOTALL)

    # Find where to add the file reference (before End PBXFileReference section)
    file_ref_pattern = r'(.*)(/\* End PBXFileReference section.*)'
    file_entry = f"\t\t{file_ref_uuid} /* SplitAllocationTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationTests.swift; sourceTree = \"<group>\"; }};\n"
    content = re.sub(file_ref_pattern, r'\1' + file_entry + r'\2', content, flags=re.DOTALL)

    # Find FinanceMateTests group and add the file
    test_group_pattern = r'(/\* FinanceMateTests \*/ = {[^}]*children = \([^)]*)(\);)'
    new_child = f"\n\t\t\t\t{file_ref_uuid} /* SplitAllocationTests.swift */,"
    content = re.sub(test_group_pattern, r'\1' + new_child + r'\2', content, flags=re.DOTALL)

    # Find the test target sources and add our file
    test_sources_pattern = r'(/\* Sources \*/ = {[^}]*files = \([^)]*)(\);)'
    new_build_entry = f"\n\t\t\t\t{build_file_uuid} /* SplitAllocationTests.swift in Sources */,"
    content = re.sub(test_sources_pattern, r'\1' + new_build_entry + r'\2', content, flags=re.DOTALL)

    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Added SplitAllocationTests.swift to Xcode project")
    print(f"File reference UUID: {file_ref_uuid}")
    print(f"Build file UUID: {build_file_uuid}")

if __name__ == "__main__":
    add_test_file_to_project()