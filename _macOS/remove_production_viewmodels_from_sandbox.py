#!/usr/bin/env python3
"""
Remove Production ViewModels from Sandbox Target
Removes production authentication ViewModels that cause compilation errors in Sandbox
"""

import os
import re


def remove_production_viewmodels_from_sandbox():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Create backup
    backup_file = f"{project_file}.backup_remove_viewmodels"
    with open(backup_file, "w") as f:
        f.write(content)
    print(f"Created backup: {backup_file}")

    # Find the Sandbox Sources build phase (AB21026E2F69F93017944B0D)
    # Remove the problematic production ViewModels

    # Production ViewModels to remove from Sandbox target
    viewmodels_to_remove = [
        "AuthenticationManager.swift",
        "AuthenticationStateManager.swift",
        "SessionManager.swift",
        "UserProfileManager.swift",
    ]

    # Pattern to match lines in the Sandbox build phase for these files
    for viewmodel in viewmodels_to_remove:
        # Find the file reference ID for this viewmodel
        file_ref_pattern = rf"([A-F0-9]{{24}}) /\* {re.escape(viewmodel)} \*/ = \{{isa = PBXFileReference;"
        file_ref_match = re.search(file_ref_pattern, content)

        if file_ref_match:
            file_id = file_ref_match.group(1)

            # Find the build file reference for this file
            build_file_pattern = rf"([A-F0-9]{{24}}) /\* {re.escape(viewmodel)} in Sources \*/ = \{{isa = PBXBuildFile; fileRef = {file_id}"
            build_file_match = re.search(build_file_pattern, content)

            if build_file_match:
                build_file_id = build_file_match.group(1)

                # Remove from Sandbox build phase
                sandbox_build_phase_pattern = rf"(AB21026E2F69F93017944B0D /\* Sources \*/ = \{{[^}}]*files = \([^)]*)\s*{build_file_id} /\* {re.escape(viewmodel)} in Sources \*/,?\s*([^)]*\);[^}}]*\}};)"

                def remove_from_build_phase(match):
                    prefix = match.group(1)
                    suffix = match.group(2)
                    return prefix + suffix

                content = re.sub(
                    sandbox_build_phase_pattern,
                    remove_from_build_phase,
                    content,
                    flags=re.DOTALL,
                )
                print(f"✅ Removed {viewmodel} from Sandbox build phase")
            else:
                print(f"⚠️  Build file reference not found for {viewmodel}")
        else:
            print(f"⚠️  File reference not found for {viewmodel}")

    # Write the updated content back
    with open(project_file, "w") as f:
        f.write(content)

    print("✅ Removed production ViewModels from Sandbox target")
    return True


if __name__ == "__main__":
    success = remove_production_viewmodels_from_sandbox()
    if success:
        print("\n✅ SANDBOX VIEWMODEL CLEANUP SUCCESSFUL")
        print("🎯 Next: Test Sandbox build")
    else:
        print("\n❌ SANDBOX VIEWMODEL CLEANUP FAILED")




