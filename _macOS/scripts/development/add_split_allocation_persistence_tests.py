#!/usr/bin/env python3
"""
Add SplitAllocationPersistenceValidationTests.swift to Xcode project
"""

import os
import sys
import re

def add_test_file_to_xcode_project():
    """Add the test file to the FinanceMate Xcode project"""

    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    test_file_path = "FinanceMateTests/SplitAllocationPersistenceValidationTests.swift"

    if not os.path.exists(project_path):
        print(f"Error: {project_path} not found")
        return False

    if not os.path.exists(test_file_path):
        print(f"Error: {test_file_path} not found")
        return False

    # Read current project file
    with open(project_path, 'r') as f:
        content = f.read()

    # Generate UUID for the test file
    import uuid
    test_file_uuid = str(uuid.uuid4()).replace('-', '')[:24]
    build_file_uuid = str(uuid.uuid4()).replace('-', '')[:24]

    # Find the FinanceMateTests target
    test_target_pattern = r'FinanceMateTests.*?=\s*\{[^}]*name\s*=\s*FinanceMateTests[^}]*\}'
    test_target_match = re.search(test_target_pattern, content, re.DOTALL)

    if not test_target_match:
        print("Error: Could not find FinanceMateTests target")
        return False

    # Find the PBXSourcesBuildPhase for tests
    sources_pattern = r'PBXSourcesBuildPhase.*?=\s*\{[^}]*name\s*=\s*Sources[^}]*\}'
    sources_match = re.search(sources_pattern, content, re.DOTALL)

    if not sources_match:
        print("Error: Could not find PBXSourcesBuildPhase")
        return False

    # Add file reference
    file_ref_pattern = r'(\s+)(SplitAllocationTests\.swift[^}]+fileRef\s*=\s*)([^;]+;)'
    file_ref_match = re.search(file_ref_pattern, content)

    if file_ref_match:
        # Add new file reference after existing one
        indent = file_ref_match.group(1)
        ref_content = file_ref_match.group(2)
        ref_uuid = file_ref_match.group(3)

        new_file_ref = f"{indent}SplitAllocationPersistenceValidationTests.swift /* SplitAllocationPersistenceValidationTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationPersistenceValidationTests.swift; sourceTree = \"<group>\"; }};\n"
        new_build_file = f"{indent}{test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift */; }};\n"

        # Insert new file reference
        content = content.replace(file_ref_match.group(0),
                                file_ref_match.group(0) + new_file_ref + new_build_file)

    # Add to build files section
    build_files_pattern = r'(/* End PBXBuildFile section */)'
    build_files_match = re.search(build_files_pattern, content)

    if build_files_match:
        new_build_file_entry = f"\t\t{test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift */; }};\n"
        content = content.replace(build_files_match.group(1),
                                new_build_file_entry + build_files_match.group(1))

    # Add to PBXFileReference section
    file_refs_pattern = r'(/* End PBXFileReference section */)'
    file_refs_match = re.search(file_refs_pattern, content)

    if file_refs_match:
        new_file_ref_entry = f"\t\t{test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitAllocationPersistenceValidationTests.swift; sourceTree = \"<group>\"; }};\n"
        content = content.replace(file_refs_match.group(1),
                                new_file_ref_entry + file_refs_match.group(1))

    # Add to Sources build phase
    if sources_match:
        sources_section = sources_match.group(0)
        new_source_entry = f"\t\t\t\t{test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift in Sources */,\n"

        # Find the last file entry in the sources section
        last_file_pattern = r'(\s+)([^/]+\.swift[^)]+\s+in Sources[^,]+,)'
        last_file_match = re.search(last_file_pattern, sources_section)

        if last_file_match:
            content = content.replace(last_file_match.group(0),
                                    last_file_match.group(0) + new_source_entry)

    # Add to group (FinanceMateTests)
    group_pattern = r'(FinanceMateTests[^=]*=\s*\{[^}]*children\s*=\s*\([^)]*)(\);)'
    group_match = re.search(group_pattern, content, re.DOTALL)

    if group_match:
        children_section = group_match.group(1)
        new_child_entry = f"\t\t\t\t{test_file_uuid} /* SplitAllocationPersistenceValidationTests.swift */,\n"
        content = content.replace(group_match.group(0),
                                children_section + new_child_entry + group_match.group(2))

    # Write updated project file
    with open(project_path, 'w') as f:
        f.write(content)

    print(f"Added {test_file_path} to Xcode project")
    return True

if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    success = add_test_file_to_xcode_project()
    sys.exit(0 if success else 1)