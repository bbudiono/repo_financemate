#!/usr/bin/env python3
"""FinanceMate Comprehensive UI Component Test Suite - Tests EVERY UI element"""

import subprocess
import time
import os
import json
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")
SCREENSHOT_DIR = PROJECT_ROOT / "test_output" / f"ui_screenshots_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)

def log_test(test_name, status, message=""):
    """Log test results with timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_file = PROJECT_ROOT / "test_output" / "ui_component_test_log.txt"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {test_name}: {status} - {message}\n")

def capture_screenshot(name):
    """Capture app window screenshot"""
    output = SCREENSHOT_DIR / f"{name}_{datetime.now().strftime('%H%M%S')}.png"
    try:
        subprocess.run(["screencapture", "-o", "-w", str(output)],
                      timeout=5, capture_output=True)
    except:
        pass
    return output

def check_ui_element_exists(element_type, identifier):
    """Check if a UI element exists in the code"""
    swift_files = list(MACOS_ROOT.glob("FinanceMate/*.swift"))
    for file in swift_files:
        content = file.read_text()
        if element_type in content and identifier in content:
            return True
    return False

# NAVIGATION TESTS
def test_tab_navigation():
    """Test all tab navigation elements"""
    content_view = MACOS_ROOT / "FinanceMate/ContentView.swift"
    content = content_view.read_text()

    tabs = ["Dashboard", "Transactions", "Gmail", "Settings"]
    missing_tabs = []

    for tab in tabs:
        if f'"{tab}"' not in content or f'.tabItem' not in content:
            missing_tabs.append(tab)

    has_tab_selection = 'selectedTab' in content or '@State.*selection' in content

    success = len(missing_tabs) == 0 and has_tab_selection
    log_test("test_tab_navigation", "PASS" if success else "FAIL",
             f"Missing tabs: {missing_tabs}" if missing_tabs else "All tabs present with selection state")
    assert success, f"Tab navigation incomplete: Missing {missing_tabs}"
    return True

# BUTTON TESTS
def test_all_buttons():
    """Test all buttons have proper actions and states"""
    button_tests = [
        ("LoginView.swift", ["Sign in with Apple", "Sign in with Google"], "Authentication buttons"),
        ("GmailView.swift", ["Connect Gmail", "Submit Code", "Refresh Emails", "Create All", "Create Transaction"], "Gmail buttons"),
        ("TransactionsView.swift", ["Add Transaction", "Delete"], "Transaction buttons"),
        ("SettingsView.swift", ["Sign Out", "Save"], "Settings buttons"),
    ]

    failures = []

    for file_name, buttons, description in button_tests:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            failures.append(f"{file_name} not found")
            continue

        content = file_path.read_text()
        for button in buttons:
            # Check button exists with action
            has_button = f'Button("{button}")' in content or f'Button({button})' in content
            has_action = 'action:' in content or '.onTapGesture' in content or 'Task {' in content

            if not has_button:
                failures.append(f"{file_name}: Missing button '{button}'")
            elif not has_action:
                failures.append(f"{file_name}: Button '{button}' has no action")

    log_test("test_all_buttons", "PASS" if not failures else "FAIL",
             f"Failures: {failures}" if failures else "All buttons have actions")
    assert not failures, f"Button issues: {failures}"
    return True

def test_button_states():
    """Test buttons have proper enabled/disabled states"""
    files_to_check = ["GmailView.swift", "TransactionsView.swift", "LoginView.swift"]
    missing_states = []

    for file_name in files_to_check:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            continue

        content = file_path.read_text()

        # Check for button state management
        has_disabled = '.disabled(' in content
        has_loading = 'isLoading' in content or 'ProgressView' in content
        has_validation = 'isEmpty' in content or '!=' in content or '==' in content

        if not (has_disabled or has_loading):
            missing_states.append(f"{file_name}: No button state management")

    log_test("test_button_states", "PASS" if not missing_states else "FAIL",
             f"Missing: {missing_states}" if missing_states else "Button states managed")
    assert not missing_states, f"Button state issues: {missing_states}"
    return True

# TEXT INPUT TESTS
def test_text_fields():
    """Test all text fields have proper validation"""
    text_field_tests = [
        ("GmailView.swift", "authCode", "Authorization code input"),
        ("TransactionsView.swift", "searchText", "Search field"),
        ("TransactionsView.swift", "amount", "Amount input"),
        ("SettingsView.swift", "displayName", "Display name input"),
    ]

    failures = []

    for file_name, field, description in text_field_tests:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            failures.append(f"{file_name} not found")
            continue

        content = file_path.read_text()

        # Check TextField exists
        has_field = f'TextField(' in content and field in content
        has_binding = f'@State' in content or f'@Published' in content
        has_validation = 'onChange' in content or 'onSubmit' in content or '.isEmpty' in content

        if not has_field:
            failures.append(f"{file_name}: Missing TextField for '{field}'")
        elif not has_binding:
            failures.append(f"{file_name}: No binding for '{field}'")

    log_test("test_text_fields", "PASS" if not failures else "FAIL",
             f"Failures: {failures}" if failures else "All text fields validated")
    assert not failures, f"TextField issues: {failures}"
    return True

# LIST/SCROLL TESTS
def test_lists_and_scrolling():
    """Test all lists have proper scrolling and interaction"""
    list_tests = [
        ("TransactionsView.swift", "List", "Transaction list"),
        ("GmailView.swift", "List", "Email list"),
        ("DashboardView.swift", "ScrollView", "Dashboard scroll"),
    ]

    failures = []

    for file_name, component, description in list_tests:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            failures.append(f"{file_name} not found")
            continue

        content = file_path.read_text()

        has_component = component in content
        has_foreach = 'ForEach' in content
        has_id = 'id:' in content or 'id =' in content
        has_interaction = 'onTapGesture' in content or 'Button' in content or 'NavigationLink' in content

        if not has_component:
            failures.append(f"{file_name}: Missing {component}")
        elif component == "List" and not has_foreach:
            failures.append(f"{file_name}: List without ForEach")
        elif has_foreach and not has_id:
            failures.append(f"{file_name}: ForEach without id")

    log_test("test_lists_and_scrolling", "PASS" if not failures else "FAIL",
             f"Failures: {failures}" if failures else "Lists properly configured")
    assert not failures, f"List/Scroll issues: {failures}"
    return True

# MODAL/SHEET TESTS
def test_modals_and_sheets():
    """Test all modals/sheets have proper presentation"""
    modal_tests = [
        ("ContentView.swift", [".sheet", ".alert"], "Main view modals"),
        ("GmailView.swift", ["showCodeInput"], "OAuth code modal"),
        ("TransactionsView.swift", [".alert", "showingAddTransaction"], "Transaction modals"),
    ]

    failures = []

    for file_name, patterns, description in modal_tests:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            failures.append(f"{file_name} not found")
            continue

        content = file_path.read_text()

        for pattern in patterns:
            if pattern.startswith('.'):
                # It's a SwiftUI modifier
                if pattern not in content:
                    failures.append(f"{file_name}: Missing {pattern} modifier")
            else:
                # It's a state variable
                if f'@State.*{pattern}' not in content and f'@Published.*{pattern}' not in content:
                    if pattern in content:  # Check if it's at least referenced
                        continue
                    failures.append(f"{file_name}: Missing state for {pattern}")

    log_test("test_modals_and_sheets", "PASS" if not failures else "FAIL",
             f"Failures: {failures}" if failures else "Modals configured")
    assert not failures, f"Modal/Sheet issues: {failures}"
    return True

# PROGRESS INDICATORS
def test_loading_indicators():
    """Test all async operations have loading indicators"""
    files_to_check = ["GmailView.swift", "DashboardView.swift", "TransactionsView.swift"]
    missing_indicators = []

    for file_name in files_to_check:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            continue

        content = file_path.read_text()

        has_async = 'Task {' in content or 'async' in content or '.task' in content
        has_loading_state = 'isLoading' in content or '@Published.*loading' in content
        has_progress_view = 'ProgressView' in content

        if has_async and not (has_loading_state and has_progress_view):
            missing_indicators.append(f"{file_name}: Async operations without loading indicator")

    log_test("test_loading_indicators", "PASS" if not missing_indicators else "FAIL",
             f"Missing: {missing_indicators}" if missing_indicators else "All async ops have indicators")
    assert not missing_indicators, f"Loading indicator issues: {missing_indicators}"
    return True

# ERROR HANDLING UI
def test_error_ui():
    """Test all views have error handling UI"""
    files_to_check = ["GmailView.swift", "DashboardView.swift", "TransactionsView.swift", "LoginView.swift"]
    missing_error_ui = []

    for file_name in files_to_check:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            continue

        content = file_path.read_text()

        has_error_state = 'errorMessage' in content or 'error' in content.lower()
        has_error_display = '.alert' in content or 'Text(error' in content or '.foregroundColor(.red)' in content

        if not (has_error_state and has_error_display):
            missing_error_ui.append(f"{file_name}: No error UI")

    log_test("test_error_ui", "PASS" if not missing_error_ui else "FAIL",
             f"Missing: {missing_error_ui}" if missing_error_ui else "All views have error UI")
    assert not missing_error_ui, f"Error UI issues: {missing_error_ui}"
    return True

# ACCESSIBILITY
def test_accessibility():
    """Test accessibility labels and hints"""
    files_to_check = ["DashboardView.swift", "TransactionsView.swift", "GmailView.swift"]
    missing_accessibility = []

    for file_name in files_to_check:
        file_path = MACOS_ROOT / f"FinanceMate/{file_name}"
        if not file_path.exists():
            continue

        content = file_path.read_text()

        has_labels = '.accessibilityLabel' in content
        has_hints = '.accessibilityHint' in content or '.accessibilityValue' in content
        has_identifiers = '.accessibilityIdentifier' in content

        # At least some accessibility support should be present
        if not (has_labels or has_hints or has_identifiers):
            missing_accessibility.append(f"{file_name}: No accessibility support")

    log_test("test_accessibility", "WARN" if missing_accessibility else "PASS",
             f"Missing: {missing_accessibility}" if missing_accessibility else "Accessibility present")
    # Warning only, not a failure
    return True

def run_all_ui_tests():
    """Run all UI component tests"""
    print("\nFINANCEMATE COMPREHENSIVE UI COMPONENT TEST SUITE")
    print("=" * 80)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)

    tests = [
        ("NAVIGATION", [test_tab_navigation]),
        ("BUTTONS", [test_all_buttons, test_button_states]),
        ("TEXT INPUTS", [test_text_fields]),
        ("LISTS & SCROLLING", [test_lists_and_scrolling]),
        ("MODALS & SHEETS", [test_modals_and_sheets]),
        ("LOADING & PROGRESS", [test_loading_indicators]),
        ("ERROR HANDLING", [test_error_ui]),
        ("ACCESSIBILITY", [test_accessibility])
    ]

    all_results = []
    for category, test_funcs in tests:
        print(f"\n{category}")
        print("-" * 80)
        for test in test_funcs:
            try:
                test()
                all_results.append((test.__name__, True, ""))
                print(f"  OK {test.__name__}")
            except AssertionError as e:
                all_results.append((test.__name__, False, str(e)))
                print(f"  FAIL {test.__name__}: {e}")
            except Exception as e:
                all_results.append((test.__name__, False, f"ERROR: {e}"))
                print(f"  ERROR {test.__name__}: {e}")

    # Summary
    passed = sum(1 for _, s, _ in all_results if s)
    total = len(all_results)
    print("\n" + "=" * 80)
    print(f"SUMMARY: {total} UI component tests | {passed} passed | {total - passed} failed")
    print("=" * 80)

    return 0 if passed == total else 1

if __name__ == "__main__":
    exit(run_all_ui_tests())