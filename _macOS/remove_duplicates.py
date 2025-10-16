#!/usr/bin/env python3
"""Remove duplicate build file entries from Xcode project"""

import re

def remove_duplicates():
    project_path = "FinanceMate.xcodeproj/project.pbxproj"
    duplicate_files = ["TransactionRowView.swift", "TransactionEmptyStateView.swift", "TransactionSearchBar.swift", "TransactionFilterBar.swift", "AddTransactionForm.swift"]

    with open(project_path, 'r') as f:
        content = f.read()

    for filename in duplicate_files:
        # Remove duplicate PBXBuildFile entries
        build_pattern = rf'(\t\t[A-Z0-9]+ /\* {filename} in Sources \*/ = {{isa = PBXBuildFile; fileRef = [A-Z0-9]+ /\* {filename} \*/; }};\n)'
        build_matches = re.findall(build_pattern, content)
        for i in range(1, len(build_matches)):
            content = content.replace(build_matches[i], '', 1)

        # Remove duplicate PBXFileReference entries
        ref_pattern = rf'(\t\t[A-Z0-9]+ /\* {filename} \*/ = {{[^}}]+}};\n)'
        ref_matches = re.findall(ref_pattern, content)
        for i in range(1, len(ref_matches)):
            content = content.replace(ref_matches[i], '', 1)

        # Remove duplicate PBXSourcesBuildPhase entries
        src_pattern = rf'(\t\t\t\t[A-Z0-9]+ /\* {filename} in Sources \*/,\n)'
        src_matches = re.findall(src_pattern, content)
        for i in range(1, len(src_matches)):
            content = content.replace(src_matches[i], '', 1)

    with open(project_path, 'w') as f:
        f.write(content)
    print("Duplicate build files removed!")

if __name__ == "__main__":
    remove_duplicates()