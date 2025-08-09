#!/usr/bin/env python3
"""
Fix the Sandbox Sources build phase by adding the multi-entity architecture files
to the main app target (not just tests).
"""

import os
import re


def fix_sandbox_build_phase():
    """Add multi-entity files to the main Sandbox Sources build phase"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Find the Sandbox Sources build phase (main app target)
    sandbox_sources_pattern = (
        r"(AB21026E2F69F93017944B0D \/\* Sources \*\/ = \{[^}]*?files = \([^)]*?\);)"
    )
    sandbox_sources_match = re.search(sandbox_sources_pattern, content, re.DOTALL)

    if not sandbox_sources_match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    sandbox_sources_section = sandbox_sources_match.group(1)

    # Files to add (these are the build file IDs from the project)
    files_to_add = [
        "8EDD9AB7F32B432899B1E836 /* FinancialEntityDefinition.swift in Sources */",
        "C69E75BFAD014106AA7EA9F5 /* StarSchemaRelationshipConfigurator.swift in Sources */",
        "3FAACB01AEBE473BB92FF007 /* EnhancedCoreDataModel.swift in Sources */",
    ]

    # Check if files are already in the build phase
    files_to_add_filtered = []
    for file_entry in files_to_add:
        if file_entry not in sandbox_sources_section:
            files_to_add_filtered.append(file_entry)

    if not files_to_add_filtered:
        print("✅ All multi-entity files are already in Sandbox Sources build phase")
        return True

    # Add the files to the build phase
    # Find the closing parenthesis and semicolon pattern
    files_pattern = r"(files = \(\s*)(.*?)(\s*\);)"
    files_match = re.search(files_pattern, sandbox_sources_section, re.DOTALL)

    if not files_match:
        print("Error: Could not find files section in Sandbox Sources build phase")
        return False

    # Build the new files section
    existing_files = files_match.group(2).strip()

    # Add new files
    new_files_entries = []
    for file_entry in files_to_add_filtered:
        new_files_entries.append(f"\t\t\t\t{file_entry},")

    # Combine existing and new files
    if existing_files:
        updated_files = existing_files + "\n" + "\n".join(new_files_entries)
    else:
        updated_files = "\n".join(new_files_entries)

    # Update the files section
    updated_sandbox_sources = re.sub(
        files_pattern, rf"\1{updated_files}\3", sandbox_sources_section, flags=re.DOTALL
    )

    # Replace in the full content
    content = content.replace(sandbox_sources_section, updated_sandbox_sources)

    # Write back to file
    with open(project_file, "w") as f:
        f.write(content)

    print("✅ Successfully added multi-entity files to Sandbox Sources build phase:")
    for file_entry in files_to_add_filtered:
        print(f"   - {file_entry}")

    return True


if __name__ == "__main__":
    success = fix_sandbox_build_phase()
    if success:
        print("\n🎯 SOLUTION: Multi-entity files now available in main Sandbox app!")
        print("   - EnhancedPersistenceController should now be found")
        print("   - Sandbox build should succeed")
    else:
        print("\n❌ Failed to fix Sandbox build phase")




