#!/usr/bin/env python3
"""
Add Services files to Xcode project
"""

import os
import subprocess
import sys

# Configuration
PROJECT_PATH = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj"
SERVICES_DIR = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Services"


def add_services_to_project():
    """Add Services files to Xcode project using xcodebuild"""
    print("Adding Services files to Xcode project...")

    # Change to project directory
    os.chdir(os.path.dirname(PROJECT_PATH))

    # List all Swift files in Services directory
    services_files = []
    for file in os.listdir(SERVICES_DIR):
        if file.endswith(".swift"):
            services_files.append(os.path.join(SERVICES_DIR, file))

    print(f"Found {len(services_files)} Swift files in Services directory:")
    for file in services_files:
        print(f"  - {os.path.basename(file)}")

    # For now, let's manually add the files using Xcode command line
    # This is a temporary solution until we can fix the pbxproj manipulation

    print("\n⚠️  Manual intervention required:")
    print(
        "Please open the Xcode project and add the following files to the FinanceMate target:"
    )
    for file in services_files:
        print(f"  - {file}")

    return True


if __name__ == "__main__":
    add_services_to_project()
