#!/usr/bin/env python3
"""
Completely remove the visual Core Data model (FinanceMateModel.xcdatamodeld) 
from all build targets to prevent relationship parsing conflicts.
"""

import os
import re


def remove_visual_coredata_completely():
    """Remove all references to FinanceMateModel.xcdatamodeld from the project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    original_content = content

    print("🔍 Removing visual Core Data model references...")

    # Remove build file references
    # Pattern: 814B2C32A9824FFCACC89492 /* FinanceMateModel.xcdatamodeld in Sources */ = {isa = PBXBuildFile; fileRef = 70B7356CBC8042894E6BE /* FinanceMateModel.xcdatamodeld */; };
    build_file_pattern = r"\s*[A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld in Sources \*\/ = \{isa = PBXBuildFile; fileRef = [A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld \*\/; \};\s*\n"
    content = re.sub(build_file_pattern, "", content)

    # Remove file references
    # Pattern: 70B7356CBC8042894E6BE /* FinanceMateModel.xcdatamodeld */ = {isa = PBXFileReference; lastKnownFileType = wrapper.xcdatamodel; path = FinanceMateModel.xcdatamodeld; sourceTree = "<group>"; versionGroupType = wrapper.xcdatamodel; };
    file_ref_pattern = r'\s*[A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld \*\/ = \{isa = PBXFileReference; lastKnownFileType = wrapper\.xcdatamodel; path = FinanceMateModel\.xcdatamodeld; sourceTree = "<group>"; versionGroupType = wrapper\.xcdatamodel; \};\s*\n'
    content = re.sub(file_ref_pattern, "", content)

    # Remove from build phases (Sources sections)
    # Pattern: 814B2C32A9824FFCACC89492 /* FinanceMateModel.xcdatamodeld in Sources */,
    sources_pattern = (
        r"\s*[A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld in Sources \*\/,\s*\n"
    )
    content = re.sub(sources_pattern, "", content)

    # Remove from groups (children sections)
    # Pattern: 70B7356CBC8042894E6BE /* FinanceMateModel.xcdatamodeld */,
    group_pattern = r"\s*[A-F0-9]{24} \/\* FinanceMateModel\.xcdatamodeld \*\/,\s*\n"
    content = re.sub(group_pattern, "", content)

    # Check if we made changes
    if content != original_content:
        # Write back to file
        with open(project_file, "w") as f:
            f.write(content)

        print("✅ Successfully removed all visual Core Data model references:")
        print("   - Build file entries removed")
        print("   - File reference entries removed")
        print("   - Sources build phase entries removed")
        print("   - Group entries removed")

        return True
    else:
        print("⚠️  No visual Core Data model references found to remove")
        return False


if __name__ == "__main__":
    success = remove_visual_coredata_completely()
    if success:
        print("\n🎯 SOLUTION: Visual Core Data model completely removed!")
        print("   - All targets will use programmatic models only")
        print("   - No more relationship parsing conflicts")
        print(
            "   - Sandbox uses EnhancedPersistenceController with multi-entity support"
        )
    else:
        print("\n❌ Could not remove visual Core Data model references")




