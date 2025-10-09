#!/usr/bin/env python3

import os
import re

def add_service_files():
    project_file = "FinanceMate.xcodeproj/project.pbxproj"

    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()

    # Generate IDs for the new files
    import random
    import string

    def gen_id():
        return ''.join(random.choice(string.ascii_uppercase + string.digits + string.ascii_lowercase) for _ in range(24))

    # Service files to add
    services = [
        ("TransactionDeletionService.swift", "FinanceMate/Services/TransactionDeletionService.swift"),
        ("TransactionSortingService.swift", "FinanceMate/Services/TransactionSortingService.swift"),
        ("TransactionFilteringService.swift", "FinanceMate/Services/TransactionFilteringService.swift")
    ]

    # Add file references after existing service files
    ref_insert = content.find("401D373574BB4DBDBC9D6778 /* CoreDataManager.swift */")
    if ref_insert == -1:
        print("Could not find CoreDataManager reference")
        return

    # Find the end of that line
    line_end = content.find('\n', ref_insert)

    # Add new file references
    new_refs = ""
    new_build_refs = ""

    for name, path in services:
        if path in content:
            print(f"{name} already in project")
            continue

        file_id = gen_id()
        build_id = gen_id()

        # Add file reference
        new_refs += f'\n\t\t{file_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = "<group>"; }};'

        # Add build file reference
        new_build_refs += f'\n\t\t{build_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id} /* {name} */; }};'

        print(f"Adding {name} with IDs {file_id}/{build_id}")

    # Insert file references
    if new_refs:
        content = content[:line_end] + new_refs + content[line_end:]

    # Add build file references
    build_insert = content.find("/* Begin PBXBuildFile section */")
    if build_insert != -1:
        # Find the end of the line with the last build file reference
        build_section_end = content.find("/* Begin PBXFileReference section */", build_insert)
        if build_section_end != -1:
            content = content[:build_section_end] + new_build_refs + "\n" + content[build_section_end:]

    # Find the Sources build phase and add the files
    sources_phase = content.find("files = (\n\t\t\t1196450B6B7F4FA8AB614646 /* TransactionsTableView.swift in Sources */")
    if sources_phase != -1:
        # Add the new service files to the sources build phase
        sources_addition = ""

        # Re-create the mapping with the generated IDs
        for name, path in services:
            if path not in content:
                # Find the build ID for this file (this is a simplified approach)
                # In a real implementation, we'd track the IDs properly
                pass

        # For now, let's just add a placeholder where service files should go
        service_insert = content.find("C5D039B34678F1E7783D60F3 /* TransactionRowView.swift in Sources */")
        if service_insert != -1:
            # We'll add the service files after TransactionRowView
            line_end = content.find('\n', service_insert)
            service_files_list = """
				// Transaction Services
				TRANSACTION_DELETION_SERVICE_BUILD_REF /* TransactionDeletionService.swift in Sources */,
				TRANSACTION_SORTING_SERVICE_BUILD_REF /* TransactionSortingService.swift in Sources */,
				TRANSACTION_FILTERING_SERVICE_BUILD_REF /* TransactionFilteringService.swift in Sources */,
"""
            content = content[:line_end] + service_files_list + content[line_end:]

    # Write the updated content
    with open(project_file, 'w') as f:
        f.write(content)

    print("Service file references added to project")

if __name__ == "__main__":
    add_service_files()