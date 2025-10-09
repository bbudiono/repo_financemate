#!/usr/bin/env python3
"""
GmailViewModel Decomposition Test - RED PHASE (Atomic TDD)

PURPOSE: Validate GmailViewModel.swift violates BLUEPRINT 200-line limit
TEST PHASE: RED - This test MUST FAIL until decomposition is implemented
"""

import os
from pathlib import Path

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
GMAIL_VIEWMODEL_PATH = MACOS_ROOT / "FinanceMate/GmailViewModel.swift"

# BLUEPRINT compliance thresholds
BLUEPRINT_MAX_LINES = 200
DECOMPOSITION_TARGET_COMPONENTS = 5

def test_gmail_viewmodel_line_count():
    """
    RED TEST: GmailViewModel exceeds BLUEPRINT 200-line limit

    EXPECTED FAILURE: Current implementation is 353 lines (76% over limit)
    SUCCESS CRITERION: Component must be <200 lines after decomposition
    """
    try:
        with open(GMAIL_VIEWMODEL_PATH, 'r') as f:
            content = f.read()
            line_count = len(content.splitlines())

        # RED PHASE: This should FAIL because current code violates limit
        is_compliant = line_count <= BLUEPRINT_MAX_LINES

        violation_percentage = ((line_count - BLUEPRINT_MAX_LINES) / BLUEPRINT_MAX_LINES) * 100

        print(f"[{'PASS' if is_compliant else 'FAIL'}] BLUEPRINT_LINE_COUNT:")
        print(f"  Current: {line_count} lines (BLUEPRINT limit: {BLUEPRINT_MAX_LINES})")
        print(f"  Violation: {violation_percentage:.1f}% over limit")

        return is_compliant

    except Exception as e:
        print(f"[FAIL] FILE_ACCESS: Could not read GmailViewModel.swift: {e}")
        return False

def test_responsibility_separation():
    """
    RED TEST: GmailViewModel contains multiple responsibilities

    EXPECTED FAILURE: Current implementation mixes concerns
    SUCCESS CRITERION: Each responsibility should be in separate component
    """
    try:
        with open(GMAIL_VIEWMODEL_PATH, 'r') as f:
            content = f.read()

        # Count different responsibility patterns
        auth_patterns = content.count('auth') + content.count('OAuth') + content.count('token')
        filter_patterns = content.count('Filter') + content.count('search')
        pagination_patterns = content.count('pagination') + content.count('loadNext')
        import_patterns = content.count('import') + content.count('createTransaction')
        archive_patterns = content.count('archive') + content.count('unarchive')

        # Count major responsibilities (patterns with significant usage)
        major_responsibilities = sum(1 for count in [auth_patterns, filter_patterns, pagination_patterns, import_patterns, archive_patterns] if count > 3)

        # RED PHASE: Should FAIL because multiple responsibilities exist
        has_single_responsibility = major_responsibilities <= 1

        print(f"[{'PASS' if has_single_responsibility else 'FAIL'}] SINGLE_RESPONSIBILITY:")
        print(f"  Found {major_responsibilities} major responsibilities")
        print(f"  Auth: {auth_patterns}, Filter: {filter_patterns}, Pagination: {pagination_patterns}")
        print(f"  Import: {import_patterns}, Archive: {archive_patterns}")

        return has_single_responsibility

    except Exception as e:
        print(f"[FAIL] RESPONSIBILITY_ANALYSIS: Could not analyze responsibilities: {e}")
        return False

def test_decomposition_feasibility():
    """
    RED TEST: GmailViewModel can be decomposed into target components

    EXPECTED FAILURE: Current monolithic structure prevents decomposition
    SUCCESS CRITERION: Should be decomposable into 5 components
    """
    try:
        with open(GMAIL_VIEWMODEL_PATH, 'r') as f:
            content = f.read()
            line_count = len(content.splitlines())

        # Calculate if decomposition is feasible
        estimated_lines_per_component = line_count / DECOMPOSITION_TARGET_COMPONENTS
        max_allowed_per_component = 150

        # RED PHASE: Should FAIL because decomposition is needed
        is_feasible = estimated_lines_per_component <= max_allowed_per_component

        print(f"[{'PASS' if is_feasible else 'FAIL'}] DECOMPOSITION_FEASIBILITY:")
        print(f"  Current: {line_count} lines")
        print(f"  Target: {DECOMPOSITION_TARGET_COMPONENTS} components")
        print(f"  Estimated per component: {estimated_lines_per_component:.0f} lines")
        print(f"  Maximum allowed: {max_allowed_per_component} lines")

        return is_feasible

    except Exception as e:
        print(f"[FAIL] DECOMPOSITION_ANALYSIS: Could not analyze decomposition: {e}")
        return False

def main():
    """Execute GmailViewModel decomposition test"""
    print("=" * 70)
    print("GMAIL VIEWMODEL DECOMPOSITION TEST - RED PHASE")
    print("=" * 70)
    print("PURPOSE: Validate decomposition requirements for GmailViewModel.swift")
    print("BLUEPRINT REQUIREMENT: Components <200 lines, single responsibility")
    print("EXPECTED: All tests should FAIL (RED) until decomposition is implemented")
    print("=" * 70)

    # Run all RED tests
    test_results = [
        test_gmail_viewmodel_line_count(),
        test_responsibility_separation(),
        test_decomposition_feasibility()
    ]

    # Calculate results
    passed_count = sum(test_results)
    total_tests = len(test_results)
    all_passed = all(test_results)

    print("=" * 70)
    print(f"DECOMPOSITION TEST RESULTS: {passed_count}/{total_tests} tests passed")

    if all_passed:
        print(" GREEN PHASE: GmailViewModel is properly decomposed")
    else:
        print(" RED PHASE: GmailViewModel requires decomposition")
        print("   DECOMPOSITION REQUIRED:")
        print("   - Current code violates BLUEPRINT 200-line limit")
        print("   - Multiple responsibilities mixed in single component")
        print("   - Target: 5 components <150 lines each")
        print("   - Required: Authentication, Filtering, Pagination, Import, Core")

    print("=" * 70)

    # RED PHASE: Exit with error code to indicate decomposition needed
    exit_code = 0 if all_passed else 1
    exit(exit_code)

if __name__ == "__main__":
    main()