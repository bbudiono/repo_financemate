#!/usr/bin/env python3
"""
Add Gmail performance test files to Xcode project
"""

import os
import subprocess

def run_command(cmd):
    """Run shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        print(f"Error: {e.stderr}")
        return None

def main():
    """Add Gmail performance test files to Xcode project"""
    project_path = "FinanceMate.xcodeproj"
    target_name = "FinanceMateTests"

    # Test files to add
    test_files = [
        "FinanceMateTests/GmailCachePerformanceTests.swift",
        "FinanceMateTests/GmailRateLimitTests.swift",
        "FinanceMateTests/GmailPaginationTests.swift"
    ]

    print("Adding Gmail performance test files to Xcode project...")

    for test_file in test_files:
        if os.path.exists(test_file):
            print(f"Adding {test_file} to {target_name}...")
            cmd = f'xcodebuild -project {project_path} -target {target_name} -addFile "{test_file}"'
            result = run_command(cmd)
            if result:
                print(f" Added {test_file}")
            else:
                print(f" Failed to add {test_file}")
        else:
            print(f" File not found: {test_file}")

    print("Gmail performance test files added successfully!")

if __name__ == "__main__":
    main()