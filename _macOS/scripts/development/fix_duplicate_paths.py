#!/usr/bin/env python3
"""
Fix duplicate FinanceMate directory paths in Xcode project
"""

import re

def fix_duplicate_paths():
    """Fix paths with duplicate FinanceMate directory"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    # Pattern to fix duplicate FinanceMate paths
    # From: FinanceMate/FinanceMate/Services/TransactionBuilder.swift
    # To:   FinanceMate/Services/TransactionBuilder.swift

    original_content = content
    changes_made = 0

    # Fix duplicate FinanceMate paths
    content = re.sub(r'path = "FinanceMate/FinanceMate/', 'path = "FinanceMate/', content)

    # Count changes
    if content != original_content:
        changes_made = len(re.findall(r'path = "FinanceMate/FinanceMate/', original_content))

    if changes_made > 0:
        with open(project_file, 'w') as f:
            f.write(content)
        print(f" Fixed {changes_made} duplicate FinanceMate paths")
        return True
    else:
        print("ℹ️ No duplicate paths found")
        return False

if __name__ == "__main__":
    fix_duplicate_paths()