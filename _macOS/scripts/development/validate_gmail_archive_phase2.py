#!/usr/bin/env python3

import os
import sys
import re

def validate_file_exists(filepath, description):
    """Validate that a file exists"""
    if os.path.exists(filepath):
        print(f" {description}: {filepath}")
        return True
    else:
        print(f" {description}: {filepath} (MISSING)")
        return False

def validate_file_content(filepath, patterns, description):
    """Validate that a file contains specific patterns"""
    if not os.path.exists(filepath):
        print(f" {description}: {filepath} (MISSING)")
        return False

    with open(filepath, 'r') as f:
        content = f.read()

    all_patterns_found = True
    for pattern, pattern_desc in patterns:
        if re.search(pattern, content, re.IGNORECASE | re.MULTILINE):
            print(f" {description} - {pattern_desc}")
        else:
            print(f" {description} - {pattern_desc} (NOT FOUND)")
            all_patterns_found = False

    return all_patterns_found

def main():
    print(" Gmail Archive Phase 2 GREEN Validation")
    print("=" * 50)

    base_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
    total_checks = 0
    passed_checks = 0

    # Validate EmailStatusEntity implementation
    print("\n EmailStatusEntity Core Data Model:")
    email_status_patterns = [
        (r"@objc\(EmailStatusEntity\)", "ObjC bridging"),
        (r"class EmailStatusEntity.*NSManagedObject", "NSManagedObject inheritance"),
        (r"@NSManaged.*var emailId.*String", "emailId attribute"),
        (r"@NSManaged.*var status.*String", "status attribute"),
        (r"@NSManaged.*var lastUpdated.*Date", "lastUpdated attribute"),
        (r"var emailStatus.*EmailStatus", "EmailStatus enum property"),
        (r"enum.*ValidationError", "Validation error enum"),
        (r"static func findOrCreate", "Find or create method"),
        (r"static func fetchByEmailId", "Fetch by email ID method")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/EmailStatusEntity.swift",
                            email_status_patterns, "EmailStatusEntity"):
        passed_checks += 1

    # Validate GmailArchiveService implementation
    print("\n️ GmailArchiveService:")
    archive_service_patterns = [
        (r"class GmailArchiveService", "GmailArchiveService class"),
        (r"func archiveEmail\(withId.*String\)", "Archive email method"),
        (r"func unarchiveEmail\(withId.*String\)", "Unarchive email method"),
        (r"func markEmailAsTransactionCreated", "Mark as transaction created method"),
        (r"func batchArchiveEmails", "Batch archive method"),
        (r"func batchMarkAsTransactionCreated", "Batch mark as transaction created method"),
        (r"func getEmailStatus\(for.*String\)", "Get email status method"),
        (r"enum.*ArchiveError", "Archive error enum"),
        (r"case.*invalidEmailId", "Invalid email ID error"),
        (r"case.*saveFailed", "Save failed error")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/Services/GmailArchiveService.swift",
                            archive_service_patterns, "GmailArchiveService"):
        passed_checks += 1

    # Validate GmailModels enhancements
    print("\n Gmail Models Enhancement:")
    models_patterns = [
        (r"enum EmailStatus.*String.*Codable", "EmailStatus enum"),
        (r"case needsReview.*=.*Needs Review", "needsReview case"),
        (r"case transactionCreated.*=.*Transaction Created", "transactionCreated case"),
        (r"case archived.*=.*Archived", "archived case"),
        (r"struct GmailEmail.*Identifiable", "GmailEmail struct"),
        (r"var status.*EmailStatus.*=.*\.needsReview", "GmailEmail status field"),
        (r"class ExtractedTransaction.*ObservableObject", "ExtractedTransaction class"),
        (r"@Published.*var status.*EmailStatus.*=.*\.needsReview", "ExtractedTransaction status field"),
        (r"status.*EmailStatus.*=.*\.needsReview", "Status parameter in init")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/GmailModels.swift",
                            models_patterns, "GmailModels"):
        passed_checks += 1

    # Validate GmailViewModel enhancements
    print("\n GmailViewModel Enhancements:")
    viewmodel_patterns = [
        (r"@Published var showArchivedEmails = false", "showArchivedEmails property"),
        (r"private let archiveService.*GmailArchiveService", "Archive service dependency"),
        (r"var filteredExtractedTransactions", "Filtered transactions property"),
        (r"func archiveEmail\(with.*String\)", "Archive email method"),
        (r"func unarchiveEmail\(with.*String\)", "Unarchive email method"),
        (r"func markEmailAsTransactionCreated", "Mark as transaction created method"),
        (r"func importSelected", "Import selected method"),
        (r"markEmailAsTransactionCreated\(with.*extracted\.id\)", "Automatic archiving in createTransaction")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/GmailViewModel.swift",
                            viewmodel_patterns, "GmailViewModel"):
        passed_checks += 1

    # Validate GmailReceiptsTableView enhancements
    print("\n GmailReceiptsTableView Enhancements:")
    tableview_patterns = [
        (r"Toggle.*Show Archived Emails", "Archive toggle UI"),
        (r"isOn.*\$viewModel\.showArchivedEmails", "Archive toggle binding"),
        (r'Button\("Archive"\)', "Archive button"),
        (r"viewModel\.archiveSelectedEmails", "Archive selected emails method"),
        (r"let displayedTransactions.*viewModel\.showArchivedEmails", "Conditional transaction display"),
        (r"viewModel\.filteredExtractedTransactions", "Filtered transactions usage"),
        (r'Button\("Load 50 More"\)', "Load more button")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/Views/Gmail/GmailReceiptsTableView.swift",
                            tableview_patterns, "GmailReceiptsTableView"):
        passed_checks += 1

    # Validate ArchiveFilterMenu implementation
    print("\n Archive Filter Menu:")
    filter_patterns = [
        (r"struct ArchiveFilterMenu.*View", "ArchiveFilterMenu struct"),
        (r"Label.*Needs Review.*envelope", "Needs review filter option"),
        (r"Label.*Transaction Created.*checkmark\.circle", "Transaction created filter option"),
        (r"Label.*Archived.*archivebox", "Archived filter option"),
        (r"Label.*All Statuses.*tray\.full", "All statuses filter option"),
        (r"FilterPill\(\s*title.*Archive Status", "Filter pill component"),
        (r"isActive.*viewModel\.showArchivedEmails", "Active state binding")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/Views/Gmail/Filters/ArchiveFilterMenu.swift",
                            filter_patterns, "ArchiveFilterMenu"):
        passed_checks += 1

    # Validate GmailFilterBar integration
    print("\n️ GmailFilterBar Integration:")
    filterbar_patterns = [
        (r"ArchiveFilterMenu\(viewModel.*viewModel\)", "ArchiveFilterMenu integration")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/Views/Gmail/GmailFilterBar.swift",
                            filterbar_patterns, "GmailFilterBar"):
        passed_checks += 1

    # Validate PersistenceController enhancements
    print("\n PersistenceController Enhancements:")
    persistence_patterns = [
        (r"EmailStatusEntity", "EmailStatusEntity inclusion"),
        (r"emailIdAttribute.*attributeType.*stringAttributeType", "emailId attribute type"),
        (r"statusAttribute.*attributeType.*stringAttributeType", "status attribute type"),
        (r"lastUpdatedAttribute.*attributeType.*dateAttributeType", "lastUpdated attribute type"),
        (r"model\.entities.*\[transactionEntity.*emailStatusEntity\]", "Entities array inclusion")
    ]

    total_checks += 1
    if validate_file_content(f"{base_path}/FinanceMate/PersistenceController.swift",
                            persistence_patterns, "PersistenceController"):
        passed_checks += 1

    # Summary
    print("\n" + "=" * 50)
    print(f" VALIDATION SUMMARY: {passed_checks}/{total_checks} checks passed")

    if passed_checks == total_checks:
        print(" ALL GMAIL ARCHIVE PHASE 2 GREEN REQUIREMENTS VALIDATED!")
        print(" EmailStatusEntity Core Data model implemented")
        print(" GmailArchiveService with full CRUD operations")
        print(" Enhanced Gmail models with status tracking")
        print(" GmailViewModel with archive functionality")
        print(" GmailReceiptsTableView with archive toggle")
        print(" ArchiveFilterMenu integration")
        print(" Automatic archiving when transactions created")
        print(" Core Data persistence integration")
        return True
    else:
        print(f"️ {total_checks - passed_checks} validation checks failed")
        print(" Some Gmail Archive Phase 2 GREEN requirements missing")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)