#!/usr/bin/env python3
"""
Script to remove SplitAllocationTests.swift from main FinanceMate target
"""

import re

def remove_test_from_main_target():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Read the current project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Remove the build file reference
    build_file_pattern = r'\t\t1249B5569AF1479594074157 /\* SplitAllocationTests\.swift in Sources \*/ = \{[^}]*\};\n'
    content = re.sub(build_file_pattern, '', content)

    # Remove the file reference
    file_ref_pattern = r'\t\tCF3E735453A249B09CC3E8B4 /\* SplitAllocationTests\.swift \*/ = \{[^}]*\};\n'
    content = re.sub(file_ref_pattern, '', content)

    # Remove from test group (if exists)
    test_group_pattern = r'\t\t\t\tCF3E735453A249B09CC3E8B4 /\* SplitAllocationTests\.swift \*/,\n'
    content = re.sub(test_group_pattern, '', content)

    # Remove from sources build phase
    sources_pattern = r'\t\t\t\t1249B5569AF1479594074157 /\* SplitAllocationTests\.swift in Sources \*/,\n'
    content = re.sub(sources_pattern, '', content)

    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)

    print("Removed SplitAllocationTests.swift from main FinanceMate target")

if __name__ == "__main__":
    remove_test_from_main_target()