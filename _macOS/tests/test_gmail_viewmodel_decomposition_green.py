#!/usr/bin/env python3
"""
GmailViewModel Decomposition Test - GREEN PHASE Validation

PURPOSE: Validate GmailViewModel.swift has been successfully decomposed
TEST PHASE: GREEN - This test should PASS after decomposition is implemented
"""

import os
from pathlib import Path

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
GMAIL_VIEWMODEL_PATH = MACOS_ROOT / "FinanceMate/GmailViewModel.swift"
SERVICES_DIR = MACOS_ROOT / "FinanceMate/Services"

# BLUEPRINT compliance thresholds
BLUEPRINT_MAX_LINES = 200
DECOMPOSITION_TARGET_COMPONENTS = 5

def test_gmail_viewmodel_line_count():
    """
    GREEN TEST: GmailViewModel is under BLUEPRINT 200-line limit

    SUCCESS CRITERION: Current implementation should be <200 lines
    """
    try:
        with open(GMAIL_VIEWMODEL_PATH, 'r') as f:
            content = f.read()
            line_count = len(content.splitlines())

        is_compliant = line_count <= BLUEPRINT_MAX_LINES
        violation_percentage = ((line_count - BLUEPRINT_MAX_LINES) / BLUEPRINT_MAX_LINES) * 100

        print(f"[{'PASS' if is_compliant else 'FAIL'}] BLUEPRINT_LINE_COUNT:")
        print(f"  Current: {line_count} lines (BLUEPRINT limit: {BLUEPRINT_MAX_LINES})")
        if violation_percentage > 0:
            print(f"  Violation: {violation_percentage:.1f}% over limit")
        else:
            print(f"  Compliance: {abs(violation_percentage):.1f}% under limit")

        return is_compliant

    except Exception as e:
        print(f"[FAIL] FILE_ACCESS: Could not read GmailViewModel.swift: {e}")
        return False

def test_service_extraction():
    """
    GREEN TEST: GmailViewModel services have been extracted

    SUCCESS CRITERION: Should find 5 service files
    """
    try:
        expected_services = [
            "GmailAuthenticationManager.swift",
            "GmailFilterManager.swift",
            "GmailPaginationManager.swift",
            "GmailImportManager.swift",
            "GmailViewModelCore.swift"
        ]

        found_services = []
        missing_services = []

        for service in expected_services:
            service_path = SERVICES_DIR / service
            if service_path.exists():
                found_services.append(service)
            else:
                missing_services.append(service)

        extraction_successful = len(found_services) == len(expected_services)

        print(f"[{'PASS' if extraction_successful else 'FAIL'}] SERVICE_EXTRACTION:")
        print(f"  Expected services: {len(expected_services)}")
        print(f"  Found services: {len(found_services)}")
        if found_services:
            print(f"  Services found: {', '.join(found_services)}")
        if missing_services:
            print(f"  Services missing: {', '.join(missing_services)}")

        return extraction_successful

    except Exception as e:
        print(f"[FAIL] SERVICE_ANALYSIS: Could not analyze service extraction: {e}")
        return False

def test_service_sizes():
    """
    GREEN TEST: Extracted services are under 150 lines each

    SUCCESS CRITERION: All services should be <150 lines
    """
    try:
        service_files = [
            SERVICES_DIR / "GmailAuthenticationManager.swift",
            SERVICES_DIR / "GmailFilterManager.swift",
            SERVICES_DIR / "GmailPaginationManager.swift",
            SERVICES_DIR / "GmailImportManager.swift",
            SERVICES_DIR / "GmailViewModelCore.swift"
        ]

        max_lines_per_service = 150
        all_services_compliant = True
        service_line_counts = []

        for service_file in service_files:
            if service_file.exists():
                with open(service_file, 'r') as f:
                    lines = len(f.read().splitlines())
                    service_line_counts.append((service_file.name, lines))

                    if lines > max_lines_per_service:
                        all_services_compliant = False
                        print(f"    VIOLATION: {service_file.name} has {lines} lines (limit: {max_lines_per_service})")

        print(f"[{'PASS' if all_services_compliant else 'FAIL'}] SERVICE_SIZES:")
        print(f"  Maximum lines per service: {max_lines_per_service}")

        for service_name, line_count in service_line_counts:
            status = "" if line_count <= max_lines_per_service else ""
            print(f"  {status} {service_name}: {line_count} lines")

        return all_services_compliant

    except Exception as e:
        print(f"[FAIL] SERVICE_SIZE_ANALYSIS: Could not analyze service sizes: {e}")
        return False

def main():
    """Execute GmailViewModel decomposition GREEN phase test"""
    print("=" * 70)
    print("GMAIL VIEWMODEL DECOMPOSITION TEST - GREEN PHASE")
    print("=" * 70)
    print("PURPOSE: Validate successful decomposition of GmailViewModel.swift")
    print("BLUEPRINT REQUIREMENT: Components <200 lines, single responsibility")
    print("EXPECTED: All tests should PASS (GREEN) after decomposition is implemented")
    print("=" * 70)

    # Run all GREEN tests
    test_results = [
        test_gmail_viewmodel_line_count(),
        test_service_extraction(),
        test_service_sizes()
    ]

    # Calculate results
    passed_count = sum(test_results)
    total_tests = len(test_results)
    all_passed = all(test_results)

    print("=" * 70)
    print(f"DECOMPOSITION TEST RESULTS: {passed_count}/{total_tests} tests passed")

    if all_passed:
        print(" GREEN PHASE: GmailViewModel is successfully decomposed")
        print("    Line count compliance achieved")
        print("    Service extraction completed")
        print("    Service size requirements met")
        print("    DECOMPOSITION SUCCESSFUL")
    else:
        print(" RED PHASE: GmailViewModel decomposition incomplete")
        print("   Some requirements still not met")

    print("=" * 70)

    # GREEN PHASE: Exit with success code if all tests pass
    exit_code = 0 if all_passed else 1
    exit(exit_code)

if __name__ == "__main__":
    main()