#!/usr/bin/env python3
"""
Add AI Model test files to Xcode project
"""

import re
import sys

def add_test_to_project(project_file, test_file):
    """Add a test file to the Xcode project"""

    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Check if file already exists
    if test_file in content:
        print(f"File {test_file} already in project")
        return True

    # Find test bundle section and add the new file
    # This is a simplified approach - in real implementation we'd need proper pbxproj parsing
    test_pattern = r'(FinanceMateTests\.phaseSources = \(\s*.*?)(\s*\);)'

    def add_test_file(match):
        prefix = match.group(1)
        suffix = match.group(2)

        # Add the new test file
        new_test = f'\n\t\t{test_file} /* Sources */,\n'
        return prefix + new_test + suffix

    new_content = re.sub(test_pattern, add_test_file, content, flags=re.DOTALL)

    # Write back
    with open(project_file, 'w') as f:
        f.write(new_content)

    print(f"Added {test_file} to project")
    return True

def main():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    test_files = [
        "AIModelJudgeConfigurationTests.swift",
        "AIModelGeneratorConfigurationTests.swift",
        "AIModelDiscoveryTests.swift",
        "AIModelMocks.swift"
    ]

    for test_file in test_files:
        add_test_to_project(project_file, test_file)

    print("AI Model test files added to project")

if __name__ == "__main__":
    main()