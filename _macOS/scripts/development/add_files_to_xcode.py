#!/usr/bin/env python3
"""Add new transaction component files to Xcode project"""

import subprocess
import sys

def add_file_to_xcode(project_path, file_path):
    """Add a single file to Xcode project"""
    cmd = [
        'ruby', '-e',
        f'''
require 'xcodeproj'
project = Xcodeproj::Project.open("{project_path}")
target = project.targets.first
group = project.main_group["FinanceMate"]

file_ref = group.new_file("{file_path}")
target.source_build_phase.add_file_reference(file_ref)

project.save
puts "Added {file_path}"
        '''
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error adding {file_path}: {result.stderr}")
        return False
    print(result.stdout.strip())
    return True

def main():
    project_path = "FinanceMate.xcodeproj"

    # List of new files to add
    new_files = [
        "FinanceMate/TransactionRowView.swift",
        "FinanceMate/TransactionEmptyStateView.swift",
        "FinanceMate/TransactionSearchBar.swift",
        "FinanceMate/TransactionFilterBar.swift",
        "FinanceMate/AddTransactionForm.swift"
    ]

    for file_path in new_files:
        if not add_file_to_xcode(project_path, file_path):
            print(f"Failed to add {file_path}")
            sys.exit(1)

    print("\nAll files added successfully!")

if __name__ == "__main__":
    main()