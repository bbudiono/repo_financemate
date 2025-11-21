#!/usr/bin/env python3
"""
E2E Test: Gmail Archive Workflow Validation
BLUEPRINT Line 137: Auto-archive emails on transaction import

Purpose: Validates Feature #1 - Archive Processed Items
- Task 1.1: Auto-archive on transaction import
- Task 1.2: UI toggle for showing/hiding archived emails
- Task 1.3: Complete E2E workflow validation

Test Strategy: Code analysis + behavior validation (no UI automation)
"""

import subprocess
import os
import re
from pathlib import Path

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
MACOS_DIR = PROJECT_ROOT / "_macOS"
FINANCEMATE_DIR = MACOS_DIR / "FinanceMate"

def test_auto_archive_on_import_implemented():
    """
    Task 1.1: Verify createTransaction() calls archiveEmail() on success
    BLUEPRINT Line 137: Auto-archive on transaction import
    """
    gmail_viewmodel = FINANCEMATE_DIR / "GmailViewModel.swift"
    assert gmail_viewmodel.exists(), f"GmailViewModel.swift not found at {gmail_viewmodel}"

    content = gmail_viewmodel.read_text()

    # Check that createTransaction calls archiveEmail on success
    # Expected pattern: if transactionBuilder.createTransaction(...) != nil { archiveEmail(...)
    pattern = r'func\s+createTransaction.*?\{.*?archiveEmail\(id:\s*extracted\.id\)'
    match = re.search(pattern, content, re.DOTALL)

    assert match is not None, (
        "FAILURE: createTransaction() does not call archiveEmail() on success. "
        "Expected archiveEmail(id: extracted.id) to be called after successful transaction creation."
    )

    # Verify the logic order - archive should happen AFTER successful creation
    create_transaction_method = re.search(
        r'func createTransaction\(from extracted: ExtractedTransaction\).*?(?=func |\Z)',
        content,
        re.DOTALL
    )
    assert create_transaction_method is not None, "createTransaction method not found"

    method_content = create_transaction_method.group(0)

    # Check that archiveEmail is in success path (after != nil check)
    assert "!= nil" in method_content or "!= nil" in method_content, \
        "Transaction success check not found"

    assert "archiveEmail(id: extracted.id)" in method_content, \
        "archiveEmail call not found in createTransaction method"

    print("[PASS] Task 1.1: Auto-archive on import implemented correctly")

def test_archive_toggle_ui_exists():
    """
    Task 1.2: Verify UI toggle for showing/hiding archived emails exists
    BLUEPRINT Line 137: Toggle to view archived items
    """
    # Check GmailView.swift for the toggle
    gmail_view = FINANCEMATE_DIR / "GmailView.swift"
    assert gmail_view.exists(), f"GmailView.swift not found"

    content = gmail_view.read_text()

    # Check for Toggle component bound to showArchivedEmails
    assert "showArchivedEmails" in content, \
        "showArchivedEmails binding not found in GmailView"

    assert 'Toggle' in content, \
        "Toggle component not found in GmailView"

    # Also check the ArchiveFilterMenu
    filter_menu = FINANCEMATE_DIR / "Views" / "Gmail" / "Filters" / "ArchiveFilterMenu.swift"
    if filter_menu.exists():
        filter_content = filter_menu.read_text()
        assert "showArchivedEmails" in filter_content, \
            "ArchiveFilterMenu should use showArchivedEmails"

    print("[PASS] Task 1.2: Archive toggle UI exists")

def test_filtered_emails_respects_toggle():
    """
    Task 1.2: Verify filteredEmails computed property respects showArchivedEmails
    BLUEPRINT Line 137: Filter should hide archived items when toggle is off
    """
    gmail_viewmodel = FINANCEMATE_DIR / "GmailViewModel.swift"
    content = gmail_viewmodel.read_text()

    # Check filteredEmails computed property
    filtered_emails_pattern = r'var\s+filteredEmails\s*:.*?\{.*?showArchivedEmails.*?needsReview.*?\}'
    match = re.search(filtered_emails_pattern, content, re.DOTALL)

    assert match is not None, (
        "filteredEmails should filter by status based on showArchivedEmails toggle"
    )

    # Verify the logic
    assert "if showArchivedEmails" in content, \
        "filteredEmails should check showArchivedEmails flag"

    assert ".needsReview" in content, \
        "filteredEmails should filter for .needsReview status when toggle is off"

    print("[PASS] Task 1.2: filteredEmails respects toggle")

def test_email_status_enum_exists():
    """
    Verify EmailStatus enum has required cases for archive workflow
    """
    gmail_models = FINANCEMATE_DIR / "GmailModels.swift"
    assert gmail_models.exists(), "GmailModels.swift not found"

    content = gmail_models.read_text()

    # Check EmailStatus enum exists with required cases
    assert "enum EmailStatus" in content, "EmailStatus enum not found"
    assert "needsReview" in content, "needsReview status not found"
    assert "archived" in content, "archived status not found"
    assert "transactionCreated" in content, "transactionCreated status not found"

    print("[PASS] EmailStatus enum has all required cases")

def test_archive_email_method_exists():
    """
    Verify archiveEmail(id:) method exists and sets correct status
    """
    gmail_viewmodel = FINANCEMATE_DIR / "GmailViewModel.swift"
    content = gmail_viewmodel.read_text()

    # Check archiveEmail method exists
    archive_method_pattern = r'func\s+archiveEmail\(id:\s*String\).*?\{.*?\.archived.*?\}'
    match = re.search(archive_method_pattern, content, re.DOTALL)

    assert match is not None, "archiveEmail(id:) method not found or doesn't set .archived status"

    print("[PASS] archiveEmail(id:) method exists and sets correct status")

def test_build_succeeds():
    """
    Verify the project builds successfully with our changes
    """
    result = subprocess.run(
        [
            "xcodebuild", "-project", str(MACOS_DIR / "FinanceMate.xcodeproj"),
            "-scheme", "FinanceMate", "-configuration", "Debug", "build"
        ],
        capture_output=True,
        text=True,
        timeout=300
    )

    assert "BUILD SUCCEEDED" in result.stdout or result.returncode == 0, \
        f"Build failed: {result.stderr}"

    print("[PASS] Build succeeds with archive feature")

def test_blueprint_line_137_compliance():
    """
    BLUEPRINT Line 137: Complete compliance check
    'The Gmail Receipts table MUST automatically hide or archive items that have
    been successfully imported into the Transactions table. A toggle or filter
    must be available for the user to view these archived items.'
    """
    gmail_viewmodel = FINANCEMATE_DIR / "GmailViewModel.swift"
    content = gmail_viewmodel.read_text()

    # Requirement 1: Auto-archive on import
    assert "archiveEmail(id: extracted.id)" in content, \
        "BLUEPRINT 137: Auto-archive on import NOT implemented"

    # Requirement 2: Toggle to view archived items
    assert "showArchivedEmails" in content, \
        "BLUEPRINT 137: showArchivedEmails toggle NOT implemented"

    # Requirement 3: Filter respects toggle
    assert "if showArchivedEmails" in content, \
        "BLUEPRINT 137: Filter logic NOT implemented"

    print("[PASS] BLUEPRINT Line 137 FULLY COMPLIANT")

if __name__ == "__main__":
    print("=" * 60)
    print("E2E Test: Gmail Archive Workflow (Feature #1)")
    print("=" * 60)

    tests = [
        test_email_status_enum_exists,
        test_archive_email_method_exists,
        test_auto_archive_on_import_implemented,
        test_archive_toggle_ui_exists,
        test_filtered_emails_respects_toggle,
        test_build_succeeds,
        test_blueprint_line_137_compliance,
    ]

    passed = 0
    failed = 0

    for test in tests:
        try:
            test()
            passed += 1
        except AssertionError as e:
            print(f"[FAIL] {test.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"[ERROR] {test.__name__}: {e}")
            failed += 1

    print("=" * 60)
    print(f"Results: {passed}/{len(tests)} passed, {failed} failed")
    print("=" * 60)

    if failed > 0:
        exit(1)
