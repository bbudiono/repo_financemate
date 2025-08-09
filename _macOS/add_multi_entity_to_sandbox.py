#!/usr/bin/env python3

"""
add_multi_entity_to_sandbox.py

Purpose: Add multi-entity architecture and star schema files to Sandbox target
Issues & Complexity Summary: Complex Xcode project manipulation with multiple file additions and group management
Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: High
  - Dependencies: 3 (Python, Xcode project format, File system)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
AI Pre-Task Self-Assessment: 90%
Problem Estimate: 85%
Initial Code Complexity Estimate: 88%
Final Code Complexity: TBD
Overall Result Score: TBD
Key Variances/Learnings: Automated Xcode project configuration for multi-entity architecture
Last Updated: 2025-08-08
"""

import os
import re
import uuid


def generate_build_id():
    """Generate a unique 24-character build ID"""
    return "".join([c for c in str(uuid.uuid4()).replace("-", "").upper()])[:24]


def add_multi_entity_files_to_sandbox():
    """Add multi-entity architecture files to Sandbox target build phase and groups"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Files to add to Sandbox target
    files_to_add = [
        {
            "name": "FinancialEntityDefinition.swift",
            "path": "FinanceMate-Sandbox/FinanceMate/Persistence/FinancialEntityDefinition.swift",
            "group": "Persistence",
        },
        {
            "name": "StarSchemaRelationshipConfigurator.swift",
            "path": "FinanceMate-Sandbox/FinanceMate/Persistence/StarSchemaRelationshipConfigurator.swift",
            "group": "Persistence",
        },
        {
            "name": "EnhancedCoreDataModel.swift",
            "path": "FinanceMate-Sandbox/FinanceMate/Persistence/EnhancedCoreDataModel.swift",
            "group": "Persistence",
        },
        {
            "name": "MultiEntityArchitectureTests.swift",
            "path": "FinanceMate-SandboxTests/Persistence/MultiEntityArchitectureTests.swift",
            "group": "Tests Persistence",
            "target": "test",
        },
    ]

    # Find the specific Sandbox Sources build phase using its ID
    sandbox_sources_pattern = (
        r"(AB21026E2F69F93017944B0D \/\* Sources \*\/ = \{[^}]*?\};)"
    )
    sandbox_sources_match = re.search(sandbox_sources_pattern, content, re.DOTALL)

    if not sandbox_sources_match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    sandbox_sources_section = sandbox_sources_match.group(1)

    # Find the specific Sandbox Test Sources build phase using its ID
    test_sources_pattern = r"(0B505466DA6D6EF0CE640F06 \/\* Sources \*\/ = \{[^}]*?\};)"
    test_sources_match = re.search(test_sources_pattern, content, re.DOTALL)

    if not test_sources_match:
        print("Error: Could not find Sandbox Test Sources build phase")
        return False

    test_sources_section = test_sources_match.group(1)

    # Generate build file references and file references
    build_file_entries = []
    file_reference_entries = []

    for file_info in files_to_add:
        build_id = generate_build_id()
        file_id = generate_build_id()

        file_info["build_id"] = build_id
        file_info["file_id"] = file_id

        # Create build file entry
        build_file_entry = f"\t\t{build_id} /* {file_info['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {file_info['name']} */; }};"
        build_file_entries.append(build_file_entry)

        # Create file reference entry
        file_ref_entry = f"\t\t{file_id} /* {file_info['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{file_info['name']}\"; sourceTree = \"<group>\"; }};"
        file_reference_entries.append(file_ref_entry)

    # Add build file entries to PBXBuildFile section
    build_file_section_pattern = r"(\/\* Begin PBXBuildFile section \*\/\n)"
    if re.search(build_file_section_pattern, content):
        content = re.sub(
            build_file_section_pattern,
            r"\1" + "\n".join(build_file_entries) + "\n",
            content,
        )

    # Add file reference entries to PBXFileReference section
    file_ref_section_pattern = r"(\/\* Begin PBXFileReference section \*\/\n)"
    if re.search(file_ref_section_pattern, content):
        content = re.sub(
            file_ref_section_pattern,
            r"\1" + "\n".join(file_reference_entries) + "\n",
            content,
        )

    # Add files to Sandbox Sources build phase
    sandbox_files_pattern = r"(files = \(\s*)(.*?)(\s*\);)"

    # Find and update Sandbox Sources build phase
    sandbox_sources_start = sandbox_sources_match.start()
    sandbox_sources_end = sandbox_sources_match.end()
    sandbox_sources_content = content[sandbox_sources_start:sandbox_sources_end]

    # Add non-test files to Sandbox Sources
    sandbox_build_refs = []
    for file_info in files_to_add:
        if file_info.get("target") != "test":
            sandbox_build_refs.append(
                f"\t\t\t\t{file_info['build_id']} /* {file_info['name']} in Sources */,"
            )

    if sandbox_build_refs:
        sandbox_files_match = re.search(
            sandbox_files_pattern, sandbox_sources_content, re.DOTALL
        )
        if sandbox_files_match:
            updated_sandbox_sources = re.sub(
                sandbox_files_pattern,
                r"\1"
                + sandbox_files_match.group(2)
                + "\n"
                + "\n".join(sandbox_build_refs)
                + r"\3",
                sandbox_sources_content,
                flags=re.DOTALL,
            )
            content = (
                content[:sandbox_sources_start]
                + updated_sandbox_sources
                + content[sandbox_sources_end:]
            )

    # Add test files to Sandbox Test Sources build phase
    test_sources_start = test_sources_match.start()
    test_sources_end = test_sources_match.end()
    test_sources_content = content[test_sources_start:test_sources_end]

    test_build_refs = []
    for file_info in files_to_add:
        if file_info.get("target") == "test":
            test_build_refs.append(
                f"\t\t\t\t{file_info['build_id']} /* {file_info['name']} in Sources */,"
            )

    if test_build_refs:
        test_files_match = re.search(
            sandbox_files_pattern, test_sources_content, re.DOTALL
        )
        if test_files_match:
            updated_test_sources = re.sub(
                sandbox_files_pattern,
                r"\1"
                + test_files_match.group(2)
                + "\n"
                + "\n".join(test_build_refs)
                + r"\3",
                test_sources_content,
                flags=re.DOTALL,
            )
            # Update content with the modified test sources section
            content = (
                content[:test_sources_start]
                + updated_test_sources
                + content[test_sources_end:]
            )

    # Add files to appropriate groups
    for file_info in files_to_add:
        group_name = file_info["group"]

        # Find the group section
        if file_info.get("target") == "test":
            group_pattern = (
                rf"(/\* {re.escape(group_name)} \*/ = \{{[^}}]*?children = \([^)]*?\);)"
            )
        else:
            group_pattern = (
                rf"(/\* {re.escape(group_name)} \*/ = \{{[^}}]*?children = \([^)]*?\);)"
            )

        group_match = re.search(group_pattern, content, re.DOTALL)
        if group_match:
            group_section = group_match.group(1)

            # Add file reference to group
            updated_group = re.sub(
                r"(children = \(\s*)(.*?)(\s*\);)",
                rf'\1\2\n\t\t\t\t{file_info["file_id"]} /* {file_info["name"]} */,\3',
                group_section,
                flags=re.DOTALL,
            )

            content = content.replace(group_section, updated_group)
        else:
            print(
                f"Warning: Could not find group '{group_name}' for file '{file_info['name']}'"
            )

    # Write the updated content back to the file
    with open(project_file, "w") as f:
        f.write(content)

    print("Successfully added multi-entity architecture files to Sandbox target:")
    for file_info in files_to_add:
        print(f"  - {file_info['name']} (Group: {file_info['group']})")

    return True


if __name__ == "__main__":
    success = add_multi_entity_files_to_sandbox()
    if success:
        print("\n✅ Multi-entity architecture integration complete!")
        print("Files added to Sandbox target and appropriate groups.")
    else:
        print("\n❌ Failed to add multi-entity architecture files.")
        print("Please check the error messages above.")
