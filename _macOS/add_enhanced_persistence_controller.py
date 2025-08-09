#!/usr/bin/env python3
"""
Add EnhancedPersistenceController.swift to the Sandbox target build phase.
"""

import os
import re
import uuid


def generate_build_id():
    """Generate a unique 24-character build ID"""
    return "".join([c for c in str(uuid.uuid4()).replace("-", "").upper()])[:24]


def add_enhanced_persistence_controller():
    """Add EnhancedPersistenceController.swift to Sandbox Sources build phase"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Generate IDs for the file
    build_id = generate_build_id()
    file_id = generate_build_id()

    # Create build file entry
    build_file_entry = f"\t\t{build_id} /* EnhancedPersistenceController.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* EnhancedPersistenceController.swift */; }};"

    # Create file reference entry
    file_ref_entry = f'\t\t{file_id} /* EnhancedPersistenceController.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "EnhancedPersistenceController.swift"; sourceTree = "<group>"; }};'

    # Add build file entry to PBXBuildFile section
    build_file_section_pattern = r"(\/\* Begin PBXBuildFile section \*\/\n)"
    if re.search(build_file_section_pattern, content):
        content = re.sub(
            build_file_section_pattern,
            r"\1" + build_file_entry + "\n",
            content,
        )

    # Add file reference entry to PBXFileReference section
    file_ref_section_pattern = r"(\/\* Begin PBXFileReference section \*\/\n)"
    if re.search(file_ref_section_pattern, content):
        content = re.sub(
            file_ref_section_pattern,
            r"\1" + file_ref_entry + "\n",
            content,
        )

    # Find the Sandbox Sources build phase
    sandbox_sources_pattern = (
        r"(AB21026E2F69F93017944B0D \/\* Sources \*\/ = \{[^}]*?files = \([^)]*?\);)"
    )
    sandbox_sources_match = re.search(sandbox_sources_pattern, content, re.DOTALL)

    if not sandbox_sources_match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    sandbox_sources_section = sandbox_sources_match.group(1)

    # Add file to build phase
    files_pattern = r"(files = \(\s*)(.*?)(\s*\);)"
    files_match = re.search(files_pattern, sandbox_sources_section, re.DOTALL)

    if not files_match:
        print("Error: Could not find files section in Sandbox Sources build phase")
        return False

    existing_files = files_match.group(2).strip()
    new_file_entry = (
        f"\t\t\t\t{build_id} /* EnhancedPersistenceController.swift in Sources */,"
    )

    if existing_files:
        updated_files = existing_files + "\n" + new_file_entry
    else:
        updated_files = new_file_entry

    updated_sandbox_sources = re.sub(
        files_pattern, rf"\1{updated_files}\3", sandbox_sources_section, flags=re.DOTALL
    )

    # Replace in the full content
    content = content.replace(sandbox_sources_section, updated_sandbox_sources)

    # Write back to file
    with open(project_file, "w") as f:
        f.write(content)

    print(
        "✅ Successfully added EnhancedPersistenceController.swift to Sandbox Sources build phase"
    )
    print(f"   - Build ID: {build_id}")
    print(f"   - File ID: {file_id}")

    return True


if __name__ == "__main__":
    success = add_enhanced_persistence_controller()
    if success:
        print(
            "\n🎯 SOLUTION: EnhancedPersistenceController.swift now available in Sandbox!"
        )
        print("   - Multi-entity architecture with star schema ready")
        print("   - Sandbox build should now succeed")
    else:
        print("\n❌ Failed to add EnhancedPersistenceController.swift to build phase")




