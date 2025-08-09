#!/usr/bin/env python3
"""
Remove the visual Core Data model from Sandbox target to prevent conflicts
with the programmatic EnhancedCoreDataModel.
"""

import os
import re


def remove_visual_coredata_from_sandbox():
    """Remove FinanceMateModel.xcdatamodeld from Sandbox target build phase"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Find the Sandbox Sources build phase
    sandbox_sources_pattern = (
        r"(AB21026E2F69F93017944B0D \/\* Sources \*\/ = \{[^}]*?\};)"
    )
    sandbox_sources_match = re.search(sandbox_sources_pattern, content, re.DOTALL)

    if not sandbox_sources_match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    sandbox_sources_section = sandbox_sources_match.group(1)

    # Remove the visual Core Data model line
    # Look for pattern: some_id /* FinanceMateModel.xcdatamodeld in Sources */,
    coredata_pattern = (
        r"\s*[A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld in Sources \*\/,\n"
    )

    updated_sandbox_sources = re.sub(coredata_pattern, "", sandbox_sources_section)

    # Check if we actually removed something
    if updated_sandbox_sources != sandbox_sources_section:
        # Replace the section in the full content
        content = content.replace(sandbox_sources_section, updated_sandbox_sources)

        # Write the updated content back
        with open(project_file, "w") as f:
            f.write(content)

        print(
            "✅ Successfully removed FinanceMateModel.xcdatamodeld from Sandbox target"
        )
        print("   Sandbox will now use EnhancedCoreDataModel programmatically")
        return True
    else:
        print("⚠️  FinanceMateModel.xcdatamodeld was not found in Sandbox target")
        return False


if __name__ == "__main__":
    success = remove_visual_coredata_from_sandbox()
    if success:
        print("\n🎯 SOLUTION: Sandbox build conflicts resolved!")
        print("   - Visual Core Data model removed from Sandbox")
        print("   - Enhanced programmatic model will be used instead")
    else:
        print("\n❌ Could not remove visual Core Data model from Sandbox")




