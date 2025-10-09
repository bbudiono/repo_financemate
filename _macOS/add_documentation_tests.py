#!/usr/bin/env python3
"""
Add DocumentationQualityTests to Xcode project
"""

import subprocess
import sys

def main():
    """Add DocumentationQualityTests.swift to Xcode project"""
    try:
        # Use xcodeproj tool to add the file
        result = subprocess.run([
            'xcodeproj',
            'edit',
            'FinanceMate.xcodeproj',
            '--add', 'FinanceMateTests/DocumentationQualityTests.swift'
        ], capture_output=True, text=True)

        if result.returncode == 0:
            print("Successfully added DocumentationQualityTests.swift to project")
            return True
        else:
            print(f"Failed to add file: {result.stderr}")
            return False

    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    if main():
        print("DocumentationQualityTests added successfully")
    else:
        print("Failed to add DocumentationQualityTests")
        sys.exit(1)