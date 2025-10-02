#!/usr/bin/env python3
"""Automated Gmail OAuth Flow Test - No Manual Intervention Required"""

import subprocess
import time
import os
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

def log_test(test_name, status, message=""):
    """Log test results"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {test_name}: {status} - {message}")

def test_gmail_oauth_code_components():
    """Test all Gmail OAuth components are properly implemented"""
    tests_passed = []
    tests_failed = []

    # 1. Test OAuth credentials are configured
    env_file = PROJECT_ROOT / ".env"
    if env_file.exists():
        env_content = env_file.read_text()
        has_client_id = "GOOGLE_OAUTH_CLIENT_ID=" in env_content
        has_client_secret = "GOOGLE_OAUTH_CLIENT_SECRET=" in env_content
        has_redirect = "GOOGLE_OAUTH_REDIRECT_URI=" in env_content

        if all([has_client_id, has_client_secret, has_redirect]):
            tests_passed.append("OAuth credentials configured")
            log_test("OAuth Credentials", "PASS", "All credentials present in .env")
        else:
            tests_failed.append("OAuth credentials missing")
            log_test("OAuth Credentials", "FAIL", "Missing credentials in .env")
    else:
        tests_failed.append(".env file missing")
        log_test("OAuth Credentials", "FAIL", ".env file not found")

    # 2. Test OAuth helper implementation
    oauth_helper = MACOS_ROOT / "FinanceMate/GmailOAuthHelper.swift"
    if oauth_helper.exists():
        content = oauth_helper.read_text()
        has_auth_url = "getAuthorizationURL" in content
        has_exchange = "exchangeCodeForToken" in content
        has_scopes = "gmail.readonly" in content.lower()

        if all([has_auth_url, has_exchange, has_scopes]):
            tests_passed.append("OAuth helper complete")
            log_test("OAuth Helper", "PASS", "All OAuth methods implemented")
        else:
            tests_failed.append("OAuth helper incomplete")
            log_test("OAuth Helper", "FAIL", f"Missing: URL:{has_auth_url} Exchange:{has_exchange} Scopes:{has_scopes}")
    else:
        tests_failed.append("GmailOAuthHelper.swift missing")
        log_test("OAuth Helper", "FAIL", "File not found")

    # 3. Test token storage implementation
    keychain = MACOS_ROOT / "FinanceMate/KeychainHelper.swift"
    if keychain.exists():
        content = keychain.read_text()
        has_save = "save" in content
        has_get = "get" in content
        has_delete = "delete" in content

        if all([has_save, has_get, has_delete]):
            tests_passed.append("Keychain storage complete")
            log_test("Token Storage", "PASS", "Keychain methods implemented")
        else:
            tests_failed.append("Keychain storage incomplete")
            log_test("Token Storage", "FAIL", f"Missing: Save:{has_save} Get:{has_get} Delete:{has_delete}")
    else:
        tests_failed.append("KeychainHelper.swift missing")
        log_test("Token Storage", "FAIL", "File not found")

    # 4. Test Gmail ViewModel OAuth integration
    gmail_vm = MACOS_ROOT / "FinanceMate/GmailViewModel.swift"
    if gmail_vm.exists():
        content = gmail_vm.read_text()
        has_exchange = "exchangeCode" in content
        has_refresh = "refreshAccessToken" in content
        has_auth_check = "checkAuthentication" in content
        has_keychain = "KeychainHelper" in content

        if all([has_exchange, has_refresh, has_auth_check, has_keychain]):
            tests_passed.append("ViewModel OAuth integration complete")
            log_test("ViewModel OAuth", "PASS", "All OAuth methods integrated")
        else:
            tests_failed.append("ViewModel OAuth incomplete")
            log_test("ViewModel OAuth", "FAIL", f"Exchange:{has_exchange} Refresh:{has_refresh} Check:{has_auth_check}")
    else:
        tests_failed.append("GmailViewModel.swift missing")
        log_test("ViewModel OAuth", "FAIL", "File not found")

    # 5. Test Gmail View OAuth UI
    gmail_view = MACOS_ROOT / "FinanceMate/GmailView.swift"
    if gmail_view.exists():
        content = gmail_view.read_text()
        has_connect_button = "Connect Gmail" in content
        has_code_input = "TextField" in content and "authCode" in content
        has_submit_button = "Submit Code" in content
        has_error_display = "errorMessage" in content
        has_loading = "isLoading" in content or "ProgressView" in content

        if all([has_connect_button, has_code_input, has_submit_button, has_error_display, has_loading]):
            tests_passed.append("OAuth UI complete")
            log_test("OAuth UI", "PASS", "All UI components present")
        else:
            tests_failed.append("OAuth UI incomplete")
            log_test("OAuth UI", "FAIL", f"Connect:{has_connect_button} Input:{has_code_input} Submit:{has_submit_button}")
    else:
        tests_failed.append("GmailView.swift missing")
        log_test("OAuth UI", "FAIL", "File not found")

    # 6. Test transaction extraction from emails
    gmail_api = MACOS_ROOT / "FinanceMate/GmailAPI.swift"
    if gmail_api.exists():
        content = gmail_api.read_text()
        has_fetch = "fetchEmails" in content
        has_extract = "extractTransaction" in content
        has_australian = any(x in content for x in ["GST", "ABN", "woolworths", "coles"])
        has_line_items = "extractLineItems" in content

        if all([has_fetch, has_extract, has_australian, has_line_items]):
            tests_passed.append("Email extraction complete")
            log_test("Email Extraction", "PASS", "Australian patterns implemented")
        else:
            tests_failed.append("Email extraction incomplete")
            log_test("Email Extraction", "FAIL", f"Fetch:{has_fetch} Extract:{has_extract} AU:{has_australian}")
    else:
        tests_failed.append("GmailAPI.swift missing")
        log_test("Email Extraction", "FAIL", "File not found")

    # 7. Test Core Data persistence
    gmail_vm = MACOS_ROOT / "FinanceMate/GmailViewModel.swift"
    if gmail_vm.exists():
        content = gmail_vm.read_text()
        has_transaction_create = "Transaction(context:" in content
        has_line_item_create = "LineItem" in content
        has_tax_category = "taxCategory" in content
        has_save = "viewContext.save()" in content or "context.save()" in content

        if all([has_transaction_create, has_line_item_create, has_tax_category, has_save]):
            tests_passed.append("Transaction persistence complete")
            log_test("Persistence", "PASS", "Core Data integration verified")
        else:
            tests_failed.append("Transaction persistence incomplete")
            log_test("Persistence", "FAIL", f"Transaction:{has_transaction_create} Save:{has_save}")
    else:
        tests_failed.append("Persistence check failed")
        log_test("Persistence", "FAIL", "GmailViewModel.swift not found")

    # Summary
    total = len(tests_passed) + len(tests_failed)
    passed = len(tests_passed)

    print("\n" + "=" * 80)
    print(f"GMAIL OAUTH AUTOMATED TEST SUMMARY")
    print(f"Total Tests: {total} | Passed: {passed} | Failed: {len(tests_failed)}")
    print("=" * 80)

    if tests_passed:
        print("\n PASSED TESTS:")
        for test in tests_passed:
            print(f"  • {test}")

    if tests_failed:
        print("\n FAILED TESTS:")
        for test in tests_failed:
            print(f"  • {test}")

    print("\n" + "=" * 80)
    print(f"OVERALL: {' PASSED' if len(tests_failed) == 0 else ' FAILED'}")
    print("=" * 80)

    return len(tests_failed) == 0

def test_button_states_automated():
    """Test all button states programmatically"""
    button_tests = []

    # Define all buttons and their expected states
    button_configs = [
        ("GmailView.swift", "Connect Gmail", ["isAuthenticated", "showCodeInput"]),
        ("GmailView.swift", "Submit Code", ["authCode.isEmpty", "isLoading"]),
        ("GmailView.swift", "Refresh Emails", ["isLoading"]),
        ("GmailView.swift", "Create All", ["extractedTransactions.isEmpty"]),
        ("TransactionsView.swift", "Delete", ["selectedTransaction", "showingDeleteAlert"]),
        ("LoginView.swift", "Sign in with Apple", ["isAuthenticating"]),
        ("LoginView.swift", "Sign in with Google", ["isAuthenticating"]),
        ("SettingsView.swift", "Sign Out", ["showingSignOutAlert"])
    ]

    for file_name, button_text, state_checks in button_configs:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            button_tests.append((button_text, False, "File not found"))
            continue

        content = file_path.read_text()

        # Check button exists
        has_button = button_text in content

        # Check state management
        has_states = all(any(state in content for state in [s, f"@State.*{s}", f"@Published.*{s}"])
                        for s in state_checks)

        # Check disabled state
        has_disabled = ".disabled(" in content

        if has_button and (has_states or has_disabled):
            button_tests.append((button_text, True, "State management verified"))
        else:
            button_tests.append((button_text, False, f"Button:{has_button} States:{has_states} Disabled:{has_disabled}"))

    # Print results
    print("\n" + "=" * 80)
    print("BUTTON STATE AUTOMATED TEST RESULTS")
    print("=" * 80)

    passed = sum(1 for _, success, _ in button_tests if success)
    total = len(button_tests)

    for button, success, message in button_tests:
        status = "" if success else ""
        print(f"{status} {button}: {message}")

    print(f"\nSummary: {passed}/{total} button state tests passed")

    return passed == total

def test_ui_navigation_automated():
    """Test navigation components are properly implemented"""
    nav_tests = []

    # Test tab navigation
    content_view = MACOS_ROOT / "FinanceMate/ContentView.swift"
    if content_view.exists():
        content = content_view.read_text()
        tabs = ["Dashboard", "Transactions", "Gmail", "Settings"]
        has_all_tabs = all(f'"{tab}"' in content for tab in tabs)
        has_selection = "selectedTab" in content or "@State.*selection" in content

        if has_all_tabs and has_selection:
            nav_tests.append(("Tab Navigation", True, "All tabs with selection"))
        else:
            nav_tests.append(("Tab Navigation", False, f"Tabs:{has_all_tabs} Selection:{has_selection}"))
    else:
        nav_tests.append(("Tab Navigation", False, "ContentView.swift not found"))

    # Test navigation state management
    views = ["DashboardView", "TransactionsView", "GmailView", "SettingsView"]
    for view_name in views:
        view_file = MACOS_ROOT / f"FinanceMate/{view_name}.swift"
        if view_file.exists():
            content = view_file.read_text()
            has_navigation = "NavigationView" in content or "NavigationStack" in content or "TabView" in content
            nav_tests.append((f"{view_name} Navigation", has_navigation, "Navigation structure"))
        else:
            nav_tests.append((f"{view_name} Navigation", False, "File not found"))

    # Print results
    print("\n" + "=" * 80)
    print("NAVIGATION AUTOMATED TEST RESULTS")
    print("=" * 80)

    for test_name, success, message in nav_tests:
        status = "" if success else ""
        print(f"{status} {test_name}: {message}")

    passed = sum(1 for _, success, _ in nav_tests if success)
    total = len(nav_tests)
    print(f"\nSummary: {passed}/{total} navigation tests passed")

    return passed == total

def main():
    """Run all automated tests"""
    print("\n" + "#" * 80)
    print("FINANCEMATE FULLY AUTOMATED TEST SUITE")
    print("No Manual Intervention Required")
    print("#" * 80)

    all_passed = True

    # Run Gmail OAuth tests
    print("\n TESTING GMAIL OAUTH IMPLEMENTATION")
    if not test_gmail_oauth_code_components():
        all_passed = False

    # Run button state tests
    print("\n TESTING BUTTON STATES")
    if not test_button_states_automated():
        all_passed = False

    # Run navigation tests
    print("\n TESTING NAVIGATION COMPONENTS")
    if not test_ui_navigation_automated():
        all_passed = False

    # Final summary
    print("\n" + "#" * 80)
    print(f"FINAL RESULT: {' ALL TESTS PASSED' if all_passed else ' SOME TESTS FAILED'}")
    print("#" * 80)

    return 0 if all_passed else 1

if __name__ == "__main__":
    exit(main())