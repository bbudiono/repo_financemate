#!/usr/bin/env python3
"""
Add Chatbot Components to Sandbox Build Phase
Adds ChatbotViewModel.swift and ChatbotDrawerView.swift to the Sandbox target build phase
"""

import os
import re


def add_chatbot_to_sandbox():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Create backup
    backup_file = f"{project_file}.backup_chatbot_add"
    with open(backup_file, "w") as f:
        f.write(content)
    print(f"Created backup: {backup_file}")

    # Generate unique IDs for the new files
    chatbot_vm_file_id = "CHATBOTVM001SANDBOX2025AABB"
    chatbot_vm_build_id = "CHATBOTVMBUILD001SANDBOXAA"
    chatbot_drawer_file_id = "CHATBOTDRAWER001SANDBOXBB"
    chatbot_drawer_build_id = "CHATBOTDRAWERBUILD001SBAA"

    # Find the Sandbox Sources build phase (AB21026E2F69F93017944B0D)
    sandbox_sources_pattern = r"(AB21026E2F69F93017944B0D.*?files = \()(.*?)(\);)"

    match = re.search(sandbox_sources_pattern, content, re.DOTALL)
    if not match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    # Add the new build file references to the Sources build phase
    current_files = match.group(2)
    new_files = f"{current_files}\n\t\t\t\t{chatbot_vm_build_id} /* ChatbotViewModel.swift in Sources */,\n\t\t\t\t{chatbot_drawer_build_id} /* ChatbotDrawerView.swift in Sources */,"

    content = content.replace(
        match.group(0), f"{match.group(1)}{new_files}{match.group(3)}"
    )

    # Add PBXBuildFile entries
    build_files_section = "/* Begin PBXBuildFile section */"
    build_files_insertion = f"""{build_files_section}
\t\t{chatbot_vm_build_id} /* ChatbotViewModel.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {chatbot_vm_file_id} /* ChatbotViewModel.swift */; }};
\t\t{chatbot_drawer_build_id} /* ChatbotDrawerView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {chatbot_drawer_file_id} /* ChatbotDrawerView.swift */; }};"""

    content = content.replace(build_files_section, build_files_insertion)

    # Add PBXFileReference entries
    file_refs_section = "/* Begin PBXFileReference section */"
    file_refs_insertion = f"""{file_refs_section}
\t\t{chatbot_vm_file_id} /* ChatbotViewModel.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatbotViewModel.swift; sourceTree = "<group>"; }};
\t\t{chatbot_drawer_file_id} /* ChatbotDrawerView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ChatbotDrawerView.swift; sourceTree = "<group>"; }};"""

    content = content.replace(file_refs_section, file_refs_insertion)

    # Add to ViewModels group (find the ViewModels group for Sandbox)
    viewmodels_group_pattern = (
        r"(7A5F2E2A2C2F8B5300123456.*?children = \()(.*?)(\);.*?name = ViewModels;)"
    )
    vm_match = re.search(viewmodels_group_pattern, content, re.DOTALL)
    if vm_match:
        current_vm_children = vm_match.group(2)
        new_vm_children = f"{current_vm_children}\n\t\t\t\t{chatbot_vm_file_id} /* ChatbotViewModel.swift */,"
        content = content.replace(
            vm_match.group(0),
            f"{vm_match.group(1)}{new_vm_children}{vm_match.group(3)}",
        )

    # Add to Views group (find the Views group for Sandbox)
    views_group_pattern = (
        r"(7A5F2E2B2C2F8B5300123456.*?children = \()(.*?)(\);.*?name = Views;)"
    )
    views_match = re.search(views_group_pattern, content, re.DOTALL)
    if views_match:
        current_views_children = views_match.group(2)
        new_views_children = f"{current_views_children}\n\t\t\t\t{chatbot_drawer_file_id} /* ChatbotDrawerView.swift */,"
        content = content.replace(
            views_match.group(0),
            f"{views_match.group(1)}{new_views_children}{views_match.group(3)}",
        )

    # Write the updated content
    with open(project_file, "w") as f:
        f.write(content)

    print("Successfully added chatbot components to Sandbox target:")
    print(f"  - ChatbotViewModel.swift (File ID: {chatbot_vm_file_id})")
    print(f"  - ChatbotDrawerView.swift (File ID: {chatbot_drawer_file_id})")
    return True


if __name__ == "__main__":
    success = add_chatbot_to_sandbox()
    if success:
        print("Chatbot components successfully added to Sandbox build phase!")
    else:
        print("Failed to add chatbot components to Sandbox build phase.")




