#!/usr/bin/env python3
"""Simple Xcode project.pbxproj cleaner - removes non-existent file references"""

import re
import os

PROJECT_ROOT = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
PBXPROJ_PATH = f"{PROJECT_ROOT}/FinanceMate.xcodeproj/project.pbxproj"

MVP_FILES = [
    "FinanceMate/App/FinanceMateApp.swift",
    "FinanceMate/Configuration/ProductionConfig.swift",
    "FinanceMate/Models/PersistenceController.swift",
    "FinanceMate/Models/Transaction.swift",
    "FinanceMate/Services/GmailAPI.swift",
    "FinanceMate/Services/KeychainHelper.swift",
    "FinanceMate/ViewModels/GmailViewModel.swift",
    "FinanceMate/Views/ContentView.swift",
    "FinanceMate/Views/DashboardView.swift",
    "FinanceMate/Views/GmailView.swift",
    "FinanceMate/Views/TransactionsView.swift"
]

def find_stale_references(content):
    """Find Swift file references that don't exist on disk"""
    swift_pattern = r'path = ([^;]+\.swift);'
    all_swift_refs = re.findall(swift_pattern, content)
    stale_refs = []

    for ref in all_swift_refs:
        clean_path = ref.strip().replace('"', '').replace(' ', '')
        full_path = os.path.join(PROJECT_ROOT, clean_path)

        if not os.path.exists(full_path):
            is_mvp = any(mvp in clean_path for mvp in MVP_FILES)
            if not is_mvp:
                stale_refs.append(clean_path)

    return stale_refs

def remove_stale_lines(content, stale_refs):
    """Remove lines containing stale file references"""
    lines = content.splitlines()
    clean_lines = []
    removed_count = 0

    for line in lines:
        is_stale = any(stale_ref in line for stale_ref in stale_refs)
        if not is_stale:
            clean_lines.append(line)
        else:
            removed_count += 1

    return '\n'.join(clean_lines), removed_count

def main():
    print("Reading project.pbxproj...")
    with open(PBXPROJ_PATH, 'r') as f:
        content = f.read()

    stale_refs = find_stale_references(content)
    print(f"Found {len(stale_refs)} stale file references")

    if len(stale_refs) == 0:
        print("No stale references - project is clean!")
        return

    # Backup
    with open(PBXPROJ_PATH + ".backup", 'w') as f:
        f.write(content)

    # Clean
    cleaned_content, removed_count = remove_stale_lines(content, stale_refs)

    # Write
    with open(PBXPROJ_PATH, 'w') as f:
        f.write(cleaned_content)

    print(f"SUCCESS! Removed {removed_count} stale lines")

if __name__ == "__main__":
    main()
