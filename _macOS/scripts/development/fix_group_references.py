#!/usr/bin/env python3
"""
Fix group references to match file reference paths in Xcode project
"""

import re

def fix_group_references():
    """Fix group references to remove directory prefixes"""

    project_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj"

    with open(project_file, 'r') as f:
        content = f.read()

    original_content = content
    changes_made = 0

    # Fix group references by removing directory prefixes
    # Services/TransactionBuilder.swift -> TransactionBuilder.swift
    # Views/Gmail/GmailTableRow.swift -> GmailTableRow.swift

    path_fixes = {
        'Services/TransactionBuilder.swift': 'TransactionBuilder.swift',
        'Services/PaginationManager.swift': 'PaginationManager.swift',
        'Services/ImportTracker.swift': 'ImportTracker.swift',
        'Services/EmailCacheService.swift': 'EmailCacheService.swift',
        'Views/Gmail/GmailTableComponents.swift': 'GmailTableComponents.swift',
        'Views/Gmail/GmailTableRow.swift': 'GmailTableRow.swift',
        'Views/Gmail/GmailTransactionRow.swift': 'GmailTransactionRow.swift',
        'Views/Transactions/TransactionsTableView.swift': 'TransactionsTableView.swift',
        'ViewModels/TransactionsViewModel.swift': 'TransactionsViewModel.swift',
        'ViewModels/SettingsViewModel.swift': 'SettingsViewModel.swift',
        'Views/Settings/SettingsSidebar.swift': 'SettingsSidebar.swift',
        'Views/Settings/SettingsContent.swift': 'SettingsContent.swift',
        'Services/DashboardMetricsService.swift': 'DashboardMetricsService.swift',
        'Components/DashboardCard.swift': 'DashboardCard.swift',
        'Utilities/GmailDebugLogger.swift': 'GmailDebugLogger.swift'
    }

    for wrong_path, correct_name in path_fixes.items():
        # Fix in children sections
        pattern = rf'\s+([A-F0-9]{{24}}) /\* {wrong_path} \*/'
        replacement = f'\t\t\g<1> /* {correct_name} */'

        new_content = re.sub(pattern, replacement, content)
        if new_content != content:
            print(f"Fixed group reference: {wrong_path} -> {correct_name}")
            changes_made += 1
            content = new_content

    if changes_made > 0:
        with open(project_file, 'w') as f:
            f.write(content)
        print(f" Fixed {changes_made} group references")
        return True
    else:
        print("ℹ️ No group reference fixes needed")
        return False

if __name__ == "__main__":
    fix_group_references()