#!/usr/bin/env python3
"""
Add Sandbox Model Files to Build Phase
Adds the missing model files to the Sandbox target build phase
"""

import os
import re


def add_sandbox_models():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Create backup
    backup_file = f"{project_file}.backup_sandbox_models"
    with open(backup_file, "w") as f:
        f.write(content)
    print(f"Created backup: {backup_file}")

    # Generate unique IDs for the new files
    auth_state_file_id = "AUTHSTATE001SANDBOX2025AABB"
    auth_state_build_id = "AUTHSTATEBUILD001SANDBOXAA"
    user_class_file_id = "USERCLASS001SANDBOX2025AABB"
    user_class_build_id = "USERCLASSBUILD001SANDBOXAA"
    user_session_file_id = "USERSESSION001SANDBOX2025AA"
    user_session_build_id = "USERSESSIONBUILD001SANDAA"

    # Add file references
    file_refs_section = r"(/* Begin PBXFileReference section */)"
    new_file_refs = f"""\\1
\t\t{auth_state_file_id} /* AuthenticationState.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthenticationState.swift; sourceTree = "<group>"; }};
\t\t{user_class_file_id} /* User+CoreDataClass.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "User+CoreDataClass.swift"; sourceTree = "<group>"; }};
\t\t{user_session_file_id} /* UserSession.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = UserSession.swift; sourceTree = "<group>"; }};"""

    content = re.sub(file_refs_section, new_file_refs, content)

    # Add build file references
    build_file_section = r"(/* Begin PBXBuildFile section */)"
    new_build_files = f"""\\1
\t\t{auth_state_build_id} /* AuthenticationState.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {auth_state_file_id} /* AuthenticationState.swift */; }};
\t\t{user_class_build_id} /* User+CoreDataClass.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {user_class_file_id} /* User+CoreDataClass.swift */; }};
\t\t{user_session_build_id} /* UserSession.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {user_session_file_id} /* UserSession.swift */; }};"""

    content = re.sub(build_file_section, new_build_files, content)

    # Add files to the Sandbox Models group
    sandbox_models_group = (
        r"(BB30C92C753FB0F53D2DAAC2 /\* Models \*/ = \{[^}]*children = \([^)]*)"
    )
    new_group_children = f"""\\1
\t\t\t\t{auth_state_file_id} /* AuthenticationState.swift */,
\t\t\t\t{user_class_file_id} /* User+CoreDataClass.swift */,
\t\t\t\t{user_session_file_id} /* UserSession.swift */,"""

    content = re.sub(sandbox_models_group, new_group_children, content)

    # Add to Sandbox build phase (AB21026E2F69F93017944B0D)
    sandbox_build_phase = (
        r"(AB21026E2F69F93017944B0D /\* Sources \*/ = \{[^}]*files = \([^)]*)"
    )
    new_build_phase_files = f"""\\1
\t\t\t\t{auth_state_build_id} /* AuthenticationState.swift in Sources */,
\t\t\t\t{user_class_build_id} /* User+CoreDataClass.swift in Sources */,
\t\t\t\t{user_session_build_id} /* UserSession.swift in Sources */,"""

    content = re.sub(sandbox_build_phase, new_build_phase_files, content)

    # Write the updated content back
    with open(project_file, "w") as f:
        f.write(content)

    print("✅ Added AuthenticationState.swift to Sandbox target")
    print("✅ Added User+CoreDataClass.swift to Sandbox target")
    print("✅ Added UserSession.swift to Sandbox target")
    return True


if __name__ == "__main__":
    success = add_sandbox_models()
    if success:
        print("\n🎯 SANDBOX MODELS ADDITION COMPLETE")
        print("The Sandbox target now has the required model files")
    else:
        print("\n❌ SANDBOX MODELS ADDITION FAILED")




