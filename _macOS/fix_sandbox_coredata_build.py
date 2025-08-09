#!/usr/bin/env python3
"""
Fix Sandbox Core Data Build Issue
Removes the .xcdatamodeld file from Sandbox target build phase since it uses programmatic model
"""

import os
import re


def fix_sandbox_coredata_build():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Create backup
    backup_file = f"{project_file}.backup_coredata_fix"
    with open(backup_file, "w") as f:
        f.write(content)
    print(f"Created backup: {backup_file}")

    # Find the Sandbox Sources build phase (AB21026E2F69F93017944B0D)
    # Remove the FinanceMateModel.xcdatamodeld reference from it

    # Pattern to match the line with the .xcdatamodeld reference in the Sandbox build phase
    pattern = r"(\s+)814B2C32A9824FFCACC89492 /\* FinanceMateModel\.xcdatamodeld in Sources \*/.*\n"

    # First, let's identify the Sandbox build phase section
    # Look for the build phase and remove only from that section
    sandbox_sources_phase = r"(AB21026E2F69F93017944B0D /\* Sources \*/ = \{.*?buildActionMask = 2147483647;.*?files = \()(.*?)(\);.*?runOnlyForDeploymentPostprocessing = 0;.*?\};)"

    def remove_xcdatamodeld_from_sandbox(match):
        prefix = match.group(1)
        files_section = match.group(2)
        suffix = match.group(3)

        # Remove the .xcdatamodeld line from the files section
        files_section = re.sub(pattern, "", files_section)

        return prefix + files_section + suffix

    # Apply the fix
    content = re.sub(
        sandbox_sources_phase,
        remove_xcdatamodeld_from_sandbox,
        content,
        flags=re.DOTALL,
    )

    # Write the fixed content back
    with open(project_file, "w") as f:
        f.write(content)

    print("✅ Fixed Sandbox Core Data build configuration")
    print("✅ Removed FinanceMateModel.xcdatamodeld from Sandbox target build phase")
    return True


if __name__ == "__main__":
    success = fix_sandbox_coredata_build()
    if success:
        print("\n🎯 SANDBOX BUILD FIX COMPLETE")
        print("The Sandbox target now uses only programmatic Core Data model creation")
    else:
        print("\n❌ SANDBOX BUILD FIX FAILED")




