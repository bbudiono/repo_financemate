#!/usr/bin/env python3
"""Fix paths in Xcode project for new transaction component files"""

import re

def fix_paths(project_file):
    with open(project_file, 'r') as f:
        content = f.read()

    # Files to fix
    files_to_fix = [
        "TransactionRowView.swift",
        "TransactionEmptyStateView.swift",
        "TransactionSearchBar.swift",
        "TransactionFilterBar.swift",
        "AddTransactionForm.swift"
    ]

    for file in files_to_fix:
        # Fix the path from FinanceMate/filename to just filename
        pattern = f'path = FinanceMate/{file};'
        replacement = f'path = {file};'
        content = re.sub(pattern, replacement, content)

    with open(project_file, 'w') as f:
        f.write(content)

    print(f"Fixed paths in {project_file}")

if __name__ == "__main__":
    fix_paths("FinanceMate.xcodeproj/project.pbxproj")
    print("All paths fixed!")