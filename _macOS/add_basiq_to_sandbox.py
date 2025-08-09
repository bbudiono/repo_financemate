#!/usr/bin/env python3
"""
Add Basiq Integration Components to Sandbox Build Phase
Adds BasiqAPIService.swift, BankConnectionView.swift, and BasiqAPIServiceTests.swift
"""

import os
import re


def add_basiq_to_sandbox():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    if not os.path.exists(project_file):
        print(f"Error: {project_file} not found")
        return False

    # Read the project file
    with open(project_file, "r") as f:
        content = f.read()

    # Create backup
    backup_file = f"{project_file}.backup_basiq_add"
    with open(backup_file, "w") as f:
        f.write(content)
    print(f"Created backup: {backup_file}")

    # Generate unique IDs for the new files
    basiq_service_file_id = "BASIQSERVICE001SANDBOX2025"
    basiq_service_build_id = "BASIQSERVICEBUILD001SBAA"
    bank_connection_file_id = "BANKCONNECTION001SANDBOXBB"
    bank_connection_build_id = "BANKCONNECTIONBUILD001SAA"
    basiq_test_file_id = "BASIQTEST001SANDBOXCC"
    basiq_test_build_id = "BASIQTESTBUILD001SBAA"

    # Find the Sandbox Sources build phase
    sandbox_sources_pattern = r"(AB21026E2F69F93017944B0D.*?files = \()(.*?)(\);)"

    match = re.search(sandbox_sources_pattern, content, re.DOTALL)
    if not match:
        print("Error: Could not find Sandbox Sources build phase")
        return False

    # Add the new build file references to the Sources build phase
    current_files = match.group(2)
    new_files = f"{current_files}\n\t\t\t\t{basiq_service_build_id} /* BasiqAPIService.swift in Sources */,\n\t\t\t\t{bank_connection_build_id} /* BankConnectionView.swift in Sources */,"

    content = content.replace(
        match.group(0), f"{match.group(1)}{new_files}{match.group(3)}"
    )

    # Find the Sandbox Tests build phase
    sandbox_tests_pattern = r"(AB21026F2F69F93017944B0D.*?files = \()(.*?)(\);)"

    test_match = re.search(sandbox_tests_pattern, content, re.DOTALL)
    if test_match:
        current_test_files = test_match.group(2)
        new_test_files = f"{current_test_files}\n\t\t\t\t{basiq_test_build_id} /* BasiqAPIServiceTests.swift in Sources */,"

        content = content.replace(
            test_match.group(0),
            f"{test_match.group(1)}{new_test_files}{test_match.group(3)}",
        )

    # Add PBXBuildFile entries
    build_files_section = "/* Begin PBXBuildFile section */"
    build_files_insertion = f"""{build_files_section}
\t\t{basiq_service_build_id} /* BasiqAPIService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {basiq_service_file_id} /* BasiqAPIService.swift */; }};
\t\t{bank_connection_build_id} /* BankConnectionView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {bank_connection_file_id} /* BankConnectionView.swift */; }};
\t\t{basiq_test_build_id} /* BasiqAPIServiceTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {basiq_test_file_id} /* BasiqAPIServiceTests.swift */; }};"""

    content = content.replace(build_files_section, build_files_insertion)

    # Add PBXFileReference entries
    file_refs_section = "/* Begin PBXFileReference section */"
    file_refs_insertion = f"""{file_refs_section}
\t\t{basiq_service_file_id} /* BasiqAPIService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BasiqAPIService.swift; sourceTree = "<group>"; }};
\t\t{bank_connection_file_id} /* BankConnectionView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BankConnectionView.swift; sourceTree = "<group>"; }};
\t\t{basiq_test_file_id} /* BasiqAPIServiceTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BasiqAPIServiceTests.swift; sourceTree = "<group>"; }};"""

    content = content.replace(file_refs_section, file_refs_insertion)

    # Add to Services group (find the Services group for Sandbox)
    services_group_pattern = (
        r"(7A5F2E2C2C2F8B5300123456.*?children = \()(.*?)(\);.*?name = Services;)"
    )
    services_match = re.search(services_group_pattern, content, re.DOTALL)
    if services_match:
        current_services_children = services_match.group(2)
        new_services_children = f"{current_services_children}\n\t\t\t\t{basiq_service_file_id} /* BasiqAPIService.swift */,"
        content = content.replace(
            services_match.group(0),
            f"{services_match.group(1)}{new_services_children}{services_match.group(3)}",
        )

    # Add to Views group (find the Views group for Sandbox)
    views_group_pattern = (
        r"(7A5F2E2B2C2F8B5300123456.*?children = \()(.*?)(\);.*?name = Views;)"
    )
    views_match = re.search(views_group_pattern, content, re.DOTALL)
    if views_match:
        current_views_children = views_match.group(2)
        new_views_children = f"{current_views_children}\n\t\t\t\t{bank_connection_file_id} /* BankConnectionView.swift */,"
        content = content.replace(
            views_match.group(0),
            f"{views_match.group(1)}{new_views_children}{views_match.group(3)}",
        )

    # Add to Tests Services group
    test_services_pattern = r"(Services.*?children = \()(.*?)(\);.*?name = Services;.*?FinanceMate-SandboxTests)"
    test_services_match = re.search(test_services_pattern, content, re.DOTALL)
    if test_services_match:
        current_test_services = test_services_match.group(2)
        new_test_services = f"{current_test_services}\n\t\t\t\t{basiq_test_file_id} /* BasiqAPIServiceTests.swift */,"
        content = content.replace(
            test_services_match.group(0),
            f"{test_services_match.group(1)}{new_test_services}{test_services_match.group(3)}",
        )

    # Write the updated content
    with open(project_file, "w") as f:
        f.write(content)

    print("Successfully added Basiq integration components to Sandbox target:")
    print(f"  - BasiqAPIService.swift (File ID: {basiq_service_file_id})")
    print(f"  - BankConnectionView.swift (File ID: {bank_connection_file_id})")
    print(f"  - BasiqAPIServiceTests.swift (File ID: {basiq_test_file_id})")
    return True


if __name__ == "__main__":
    success = add_basiq_to_sandbox()
    if success:
        print("✅ Basiq integration components added successfully!")
    else:
        print("❌ Failed to add Basiq integration components.")




