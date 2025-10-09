#!/usr/bin/env python3
"""Quick fix for Gmail service files compilation errors"""

import subprocess
import sys

def add_files_to_xcode():
    """Add missing Gmail service files using xcodeproj"""
    try:
        # Add GmailAuthenticationManager
        subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj',
            '-target', 'FinanceMate', 'add-file',
            'FinanceMate/Services/GmailAuthenticationManager.swift'
        ], check=False)

        # Add GmailFilterManager
        subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj',
            '-target', 'FinanceMate', 'add-file',
            'FinanceMate/Services/GmailFilterManager.swift'
        ], check=False)

        # Add GmailPaginationManager
        subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj',
            '-target', 'FinanceMate', 'add-file',
            'FinanceMate/Services/GmailPaginationManager.swift'
        ], check=False)

        # Add GmailImportManager
        subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj',
            '-target', 'FinanceMate', 'add-file',
            'FinanceMate/Services/GmailImportManager.swift'
        ], check=False)

        # Add GmailViewModelCore
        subprocess.run([
            'xcodebuild', '-project', 'FinanceMate.xcodeproj',
            '-target', 'FinanceMate', 'add-file',
            'FinanceMate/Services/GmailViewModelCore.swift'
        ], check=False)

        print("Added Gmail service files to Xcode project")

    except Exception as e:
        print(f"Error adding files: {e}")

if __name__ == "__main__":
    add_files_to_xcode()