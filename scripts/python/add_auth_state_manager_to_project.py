#!/usr/bin/env python3

import os
import re
import sys
import time


def add_auth_state_manager_to_project():
    """Add AuthenticationStateManager.swift to the Xcode project"""

    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print("ERROR: project.pbxproj not found")
        return False

    # Backup the project file
    backup_file = project_file + ".backup_add_auth_state_" + str(int(time.time()))
    os.system(f"cp '{project_file}' '{backup_file}'")
    print(f"Backed up project file to: {backup_file}")

    with open(project_file, "r") as f:
        content = f.read()

    # Check if AuthenticationStateManager.swift is already in the project
    if "AuthenticationStateManager.swift" in content:
        print("AuthenticationStateManager.swift is already in the project")
        return True

    # Generate UUIDs for the new file
    auth_state_file_ref_id = "AUTHSTATE2025MANAGER2025AABBCC"
    auth_state_build_file_id = "AUTHSTATEBUILD2025MANAGERAABB"

    # 1. Add to PBXBuildFile section
    build_file_pattern = (
        r"(/\* Begin PBXBuildFile section \*/)(.*?)(/\* End PBXBuildFile section \*/)"
    )
    build_file_match = re.search(build_file_pattern, content, re.DOTALL)

    if build_file_match:
        build_file_entry = f"\t\t{auth_state_build_file_id} /* AuthenticationStateManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {auth_state_file_ref_id} /* AuthenticationStateManager.swift */; }};\n"

        updated_build_section = (
            build_file_match.group(1)
            + build_file_entry
            + build_file_match.group(2)
            + build_file_match.group(3)
        )
        content = content.replace(build_file_match.group(0), updated_build_section)
        print("Added to PBXBuildFile section")
    else:
        print("ERROR: Could not find PBXBuildFile section")
        return False

    # 2. Add to PBXFileReference section
    file_ref_pattern = r"(/\* Begin PBXFileReference section \*/)(.*?)(/\* End PBXFileReference section \*/)"
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)

    if file_ref_match:
        file_ref_entry = f'\t\t{auth_state_file_ref_id} /* AuthenticationStateManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationStateManager.swift; sourceTree = "<group>"; }};\n'

        updated_file_ref_section = (
            file_ref_match.group(1)
            + file_ref_entry
            + file_ref_match.group(2)
            + file_ref_match.group(3)
        )
        content = content.replace(file_ref_match.group(0), updated_file_ref_section)
        print("Added to PBXFileReference section")
    else:
        print("ERROR: Could not find PBXFileReference section")
        return False

    # 3. Add to the ViewModels group (find where AuthenticationViewModel is)
    viewmodels_group_pattern = (
        r"(AUTH002VIEWMODEL2025BBCCDDEE /\* AuthenticationViewModel\.swift \*/,)"
    )
    viewmodels_group_match = re.search(viewmodels_group_pattern, content)

    if viewmodels_group_match:
        # Add after AuthenticationViewModel.swift
        group_entry = f"\n\t\t\t\t{auth_state_file_ref_id} /* AuthenticationStateManager.swift */,"
        updated_group = viewmodels_group_match.group(1) + group_entry
        content = content.replace(viewmodels_group_match.group(0), updated_group)
        print("Added to ViewModels group")
    else:
        print("ERROR: Could not find ViewModels group with AuthenticationViewModel")
        return False

    # 4. Add to Sources build phase (find where AuthenticationViewModel is compiled)
    sources_build_pattern = r"(AUTHBUILD2025VIEWMODELAABBCC /\* AuthenticationViewModel\.swift in Sources \*/,)"
    sources_build_match = re.search(sources_build_pattern, content)

    if sources_build_match:
        # Add after AuthenticationViewModel.swift in Sources
        sources_entry = f"\n\t\t\t\t{auth_state_build_file_id} /* AuthenticationStateManager.swift in Sources */,"
        updated_sources = sources_build_match.group(1) + sources_entry
        content = content.replace(sources_build_match.group(0), updated_sources)
        print("Added to Sources build phase")
    else:
        print("ERROR: Could not find Sources build phase with AuthenticationViewModel")
        return False

    # Write the updated content
    with open(project_file, "w") as f:
        f.write(content)

    print("Successfully added AuthenticationStateManager.swift to the project")
    return True


if __name__ == "__main__":
    success = add_auth_state_manager_to_project()
    sys.exit(0 if success else 1)



