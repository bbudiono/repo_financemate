#!/usr/bin/env python3
"""
Xcode Project Path Fixer
Fixes file references that have incorrect paths after refactoring
"""

import re
import os
import sys

def fix_xcode_project_paths(project_file_path):
    """Fix file paths in Xcode project.pbxproj file"""

    # Read the project file
    with open(project_file_path, 'r') as f:
        content = f.read()

    original_content = content

    # Files that need path corrections
    path_corrections = {
        'CoreDataRelationshipBuilder.swift': 'FinanceMate/CoreDataRelationshipBuilder.swift',
        'CoreDataEntityBuilder.swift': 'FinanceMate/CoreDataEntityBuilder.swift',
        'CoreDataModelBuilder.swift': 'FinanceMate/CoreDataModelBuilder.swift',
        'EnvFileReader.swift': 'FinanceMate/EnvFileReader.swift',
        'CoreDataManager.swift': 'FinanceMate/Services/CoreDataManager.swift',
        'EmailConnectorService.swift': 'FinanceMate/Services/EmailConnectorService.swift',
        'GmailAPIService.swift': 'FinanceMate/Services/GmailAPIService.swift',
        'EmailCacheManager.swift': 'FinanceMate/EmailCacheManager.swift',
        'EmailCacheService.swift': 'FinanceMate/Services/EmailCacheService.swift',
        'ImportTracker.swift': 'FinanceMate/Services/ImportTracker.swift',
        'PaginationManager.swift': 'FinanceMate/Services/PaginationManager.swift',
        'TransactionBuilder.swift': 'FinanceMate/Services/TransactionBuilder.swift',
        'DashboardMetricsService.swift': 'FinanceMate/Services/DashboardMetricsService.swift',
        'GmailDebugLogger.swift': 'FinanceMate/Utilities/GmailDebugLogger.swift',
        'GmailTableComponents.swift': 'FinanceMate/Views/Gmail/GmailTableComponents.swift',
        'GmailReceiptsTableView.swift': 'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift',
        'FilterPill.swift': 'FinanceMate/Views/Gmail/Filters/FilterPill.swift',
        'AmountFilterMenu.swift': 'FinanceMate/Views/Gmail/Filters/AmountFilterMenu.swift',
        'ConfidenceFilterMenu.swift': 'FinanceMate/Views/Gmail/Filters/ConfidenceFilterMenu.swift',
        'DateFilterMenu.swift': 'FinanceMate/Views/Gmail/Filters/DateFilterMenu.swift',
        'MerchantFilterMenu.swift': 'FinanceMate/Views/Gmail/Filters/MerchantFilterMenu.swift',
        'CategoryFilterMenu.swift': 'FinanceMate/Views/Gmail/Filters/CategoryFilterMenu.swift',
        'DashboardCard.swift': 'FinanceMate/Components/DashboardCard.swift',
        'SettingsViewModel.swift': 'FinanceMate/ViewModels/SettingsViewModel.swift',
        'SettingsSidebar.swift': 'FinanceMate/Views/Settings/SettingsSidebar.swift',
        'SettingsContent.swift': 'FinanceMate/Views/Settings/SettingsContent.swift',
        'ProfileSection.swift': 'FinanceMate/Views/Settings/ProfileSection.swift',
        'SecuritySection.swift': 'FinanceMate/Views/Settings/SecuritySection.swift',
        'APIKeysSection.swift': 'FinanceMate/Views/Settings/APIKeysSection.swift',
        'ConnectionsSection.swift': 'FinanceMate/Views/Settings/ConnectionsSection.swift',
        'AutomationSection.swift': 'FinanceMate/Views/Settings/AutomationSection.swift',
        'TransactionsViewModel.swift': 'FinanceMate/ViewModels/TransactionsViewModel.swift',
        'GmailTransactionRow.swift': 'FinanceMate/Views/Gmail/GmailTransactionRow.swift',
        'GmailTableRow.swift': 'FinanceMate/Views/Gmail/GmailTableRow.swift',
        'GmailFilterBar.swift': 'FinanceMate/Views/Gmail/GmailFilterBar.swift',
        'TransactionsTableView.swift': 'FinanceMate/Views/Transactions/TransactionsTableView.swift',
        'SplitAllocationHeaderView.swift': 'FinanceMate/Views/SplitAllocation/SplitAllocationHeaderView.swift',
        'SplitAllocationView.swift': 'FinanceMate/Views/SplitAllocationView.swift',
        'GlassmorphismStyles.swift': 'FinanceMate/Views/GlassmorphismStyles.swift',
        'GlassmorphismPreview.swift': 'FinanceMate/Views/GlassmorphismPreview.swift',
        'GlassmorphismModifier.swift': 'FinanceMate/Views/GlassmorphismModifier.swift',
        'DashboardViewModel.swift': 'FinanceMate/ViewModels/DashboardViewModel.swift',
        'DashboardDataService.swift': 'FinanceMate/Services/DashboardDataService.swift',
        'DashboardFormattingService.swift': 'FinanceMate/Services/DashboardFormattingService.swift',
        'TransactionValidationService.swift': 'FinanceMate/Services/TransactionValidationService.swift',
        'SplitAllocationValidationService.swift': 'FinanceMate/Services/SplitAllocationValidationService.swift',
        'SplitAllocationTaxCategoryService.swift': 'FinanceMate/Services/SplitAllocationTaxCategoryService.swift',
        'SplitAllocationCalculationService.swift': 'FinanceMate/Services/SplitAllocationCalculationService.swift',
        'TransactionDeletionService.swift': 'FinanceMate/Services/TransactionDeletionService.swift',
        'TransactionSortingService.swift': 'FinanceMate/Services/TransactionSortingService.swift',
        'TransactionFilteringService.swift': 'FinanceMate/Services/TransactionFilteringService.swift',
        'SplitAllocationPersistenceService.swift': 'FinanceMate/Services/SplitAllocationPersistenceService.swift',
        'SplitAllocationQuickSplitService.swift': 'FinanceMate/Services/SplitAllocationQuickSplitService.swift',
        'SplitAllocationDataService.swift': 'FinanceMate/Services/SplitAllocationDataService.swift',
        'CoreDataManagerTests.swift': 'FinanceMateTests/Services/CoreDataManagerTests.swift',
        'GmailAPIServiceTests.swift': 'FinanceMateTests/Services/GmailAPIServiceTests.swift',
        'EmailConnectorServiceTests.swift': 'FinanceMateTests/Services/EmailConnectorServiceTests.swift'
    }

    # Apply path corrections
    changes_made = 0
    for filename, correct_path in path_corrections.items():
        # Pattern to find file references with wrong path
        pattern = rf'(path = )[^\n;]*{filename}[^\n;]*'
        replacement = f'\\1"{correct_path}"'

        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            changes_made += 1
            print(f"Fixed path for {filename} -> {correct_path}")

    # Write back if changes were made
    if content != original_content:
        with open(project_file_path, 'w') as f:
            f.write(content)
        print(f"\n Fixed {changes_made} file paths in {project_file_path}")
        return True
    else:
        print(f"\nℹ️ No path corrections needed for {project_file_path}")
        return False

if __name__ == "__main__":
    project_dir = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    project_file = os.path.join(project_dir, "FinanceMate.xcodeproj/project.pbxproj")

    if os.path.exists(project_file):
        print(" Fixing Xcode project file paths...")
        success = fix_xcode_project_paths(project_file)

        if success:
            print(" Xcode project file paths fixed successfully!")
        else:
            print("ℹ️ No fixes were needed")
    else:
        print(f" Project file not found: {project_file}")
        sys.exit(1)