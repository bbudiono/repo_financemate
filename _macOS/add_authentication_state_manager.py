#!/usr/bin/env python3

import os
import re
import sys


def add_authentication_state_manager_to_production():
    """Add AuthenticationStateManager.swift to production target build phase"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print("ERROR: project.pbxproj not found")
        return False

    # Backup the project file
    backup_file = (
        project_file + ".backup_auth_state_" + str(int(__import__("time").time()))
    )
    os.system(f"cp '{project_file}' '{backup_file}'")
    print(f"Backed up project file to: {backup_file}")

    with open(project_file, "r") as f:
        content = f.read()

    # Find the AuthenticationStateManager.swift file path
    auth_state_file_path = (
        "FinanceMate/FinanceMate/ViewModels/AuthenticationStateManager.swift"
    )

    if auth_state_file_path not in content:
        print(f"ERROR: {auth_state_file_path} not found in project")
        return False

    # Generate a new UUID for the file reference (if needed)
    import uuid

    new_file_ref_id = "".join(str(uuid.uuid4()).replace("-", "").upper()[:24])
    new_build_file_id = "".join(str(uuid.uuid4()).replace("-", "").upper()[:24])

    # Find existing file reference pattern
    file_ref_pattern = r"([A-F0-9]{24})\s+/\*\s+AuthenticationStateManager\.swift\s+\*/\s*=\s*\{[^}]*\};"
    file_ref_match = re.search(file_ref_pattern, content)

    if file_ref_match:
        file_ref_id = file_ref_match.group(1)
        print(f"Found existing file reference: {file_ref_id}")
    else:
        # Create new file reference
        file_ref_id = new_file_ref_id

        # Find the PBXFileReference section
        file_ref_section_pattern = r"(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)"
        file_ref_section_match = re.search(file_ref_section_pattern, content, re.DOTALL)

        if file_ref_section_match:
            file_ref_entry = f'\t\t{file_ref_id} /* AuthenticationStateManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationStateManager.swift; sourceTree = "<group>"; }};\n'

            # Insert before the end comment
            updated_section = (
                file_ref_section_match.group(1)
                + file_ref_entry
                + file_ref_section_match.group(2)
            )
            content = content.replace(file_ref_section_match.group(0), updated_section)
            print(f"Created new file reference: {file_ref_id}")
        else:
            print("ERROR: Could not find PBXFileReference section")
            return False

    # Find the production target Sources build phase
    production_sources_pattern = r"([A-F0-9]{24})\s+/\*\s+Sources\s+\*/\s*=\s*\{\s*isa\s*=\s*PBXSourcesBuildPhase;[^}]*files\s*=\s*\(\s*(.*?)\s*\);[^}]*\};"

    # Find all Sources build phases
    for match in re.finditer(production_sources_pattern, content, re.DOTALL):
        build_phase_id = match.group(1)
        files_section = match.group(2)

        # Check if this is the production target (look for production-specific files)
        if "AuthenticationViewModel.swift" in files_section:
            print(f"Found production Sources build phase: {build_phase_id}")

            # Check if AuthenticationStateManager is already in the build phase
            if file_ref_id in files_section:
                print(
                    "AuthenticationStateManager.swift is already in production Sources build phase"
                )
                return True

            # Create build file entry
            build_file_entry = f"\t\t\t\t{new_build_file_id} /* AuthenticationStateManager.swift in Sources */,"

            # Add to the files section
            updated_files_section = (
                files_section.rstrip() + "\n" + build_file_entry + "\n"
            )
            updated_match = match.group(0).replace(files_section, updated_files_section)
            content = content.replace(match.group(0), updated_match)

            # Add the PBXBuildFile entry
            build_file_section_pattern = r"(/\* Begin PBXBuildFile section \*/.*?)(/\* End PBXBuildFile section \*/)"
            build_file_section_match = re.search(
                build_file_section_pattern, content, re.DOTALL
            )

            if build_file_section_match:
                build_file_ref_entry = f"\t\t{new_build_file_id} /* AuthenticationStateManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* AuthenticationStateManager.swift */; }};\n"

                updated_build_section = (
                    build_file_section_match.group(1)
                    + build_file_ref_entry
                    + build_file_section_match.group(2)
                )
                content = content.replace(
                    build_file_section_match.group(0), updated_build_section
                )

                print(
                    f"Added AuthenticationStateManager.swift to production Sources build phase"
                )
                break
            else:
                print("ERROR: Could not find PBXBuildFile section")
                return False

    # Write the updated content
    with open(project_file, "w") as f:
        f.write(content)

    print("Successfully updated project.pbxproj")
    return True


if __name__ == "__main__":
    success = add_authentication_state_manager_to_production()
    sys.exit(0 if success else 1)



