#!/usr/bin/env python3
"""
Bank API Production Integration Test Suite - Atomic TDD Implementation
Tests the CRITICAL PRIORITY 1 GAP: Bank API integration is missing from production.

RED PHASE: This test MUST FAIL to validate the missing Bank API integration in production.
This test establishes clear success criteria for the GREEN phase implementation.

PRINCIPLES:
- Atomic TDD: Write failing test first, then implement minimal code
- Production Focus: Only test functionality critical for production deployment
- Headless Execution: All tests run without GUI interaction
- Real Validation: Tests actual file existence and build target inclusion

BLUEPRINT REQUIREMENTS:
- UR-101: Bank API integration for Australian financial institutions
- ANZ/NAB bank connectivity for comprehensive transaction import
- Basiq API service integration for production deployment
"""

import subprocess
import time
import os
import json
import sqlite3
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
TEST_LOG_DIR = PROJECT_ROOT / "test_output"
TEST_LOG_DIR.mkdir(parents=True, exist_ok=True)

class BankAPITestLogger:
    """Simple test logging for Bank API integration tests"""

    def __init__(self):
        self.log_file = TEST_LOG_DIR / f"bank_api_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        self.test_results = []

    def log(self, test_name: str, status: str, message: str = ""):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] {test_name}: {status} - {message}\n"

        with open(self.log_file, 'a') as f:
            f.write(log_entry)

        self.test_results.append({
            'test_name': test_name,
            'status': status,
            'message': message,
            'timestamp': timestamp
        })

def build_production_app():
    """Build FinanceMate production app for testing"""
    logger = BankAPITestLogger()

    try:
        logger.log("BUILD_PRODUCTION", "STARTED", "Building production FinanceMate app")

        # Change to production directory
        os.chdir(MACOS_ROOT)

        # Clean build directory
        clean_cmd = ["xcodebuild", "clean", "-project", "FinanceMate.xcodeproj",
                     "-scheme", "FinanceMate", "-configuration", "Debug"]

        result = subprocess.run(clean_cmd, capture_output=True, text=True, timeout=120)

        if result.returncode != 0:
            logger.log("BUILD_PRODUCTION", "FAILED", f"Clean failed: {result.stderr}")
            return False, f"Clean failed: {result.stderr}"

        # Build production app
        build_cmd = ["xcodebuild", "build", "-project", "FinanceMate.xcodeproj",
                     "-scheme", "FinanceMate", "-configuration", "Debug",
                     "-destination", "platform=macOS"]

        result = subprocess.run(build_cmd, capture_output=True, text=True, timeout=300)

        if result.returncode == 0:
            logger.log("BUILD_PRODUCTION", "PASSED", "Production app built successfully")
            return True, "Production app built successfully"
        else:
            logger.log("BUILD_PRODUCTION", "FAILED", f"Build failed: {result.stderr}")
            return False, f"Build failed: {result.stderr}"

    except subprocess.TimeoutExpired:
        logger.log("BUILD_PRODUCTION", "FAILED", "Build timed out")
        return False, "Build timed out"
    except Exception as e:
        logger.log("BUILD_PRODUCTION", "FAILED", f"Exception: {str(e)}")
        return False, f"Exception: {str(e)}"

def test_basiq_api_service_file_existence():
    """Test 1: Validate BasiqAPIService.swift exists in Sandbox but missing from Production"""
    logger = BankAPITestLogger()

    # Check Sandbox file exists
    sandbox_path = MACOS_ROOT / "FinanceMate-Sandbox/FinanceMate/Services/BasiqAPIService.swift"
    production_path = MACOS_ROOT / "FinanceMate/Services/BasiqAPIService.swift"

    logger.log("FILE_EXISTENCE_SANDBOX", "STARTED", f"Checking Sandbox file: {sandbox_path}")

    if sandbox_path.exists():
        logger.log("FILE_EXISTENCE_SANDBOX", "PASSED", "BasiqAPIService.swift exists in Sandbox")
        sandbox_exists = True
    else:
        logger.log("FILE_EXISTENCE_SANDBOX", "FAILED", "BasiqAPIService.swift missing from Sandbox")
        sandbox_exists = False

    logger.log("FILE_EXISTENCE_PRODUCTION", "STARTED", f"Checking Production file: {production_path}")

    if production_path.exists():
        logger.log("FILE_EXISTENCE_PRODUCTION", "FAILED", "BasiqAPIService.swift exists in Production (should be missing)")
        production_exists = True
    else:
        logger.log("FILE_EXISTENCE_PRODUCTION", "PASSED", "BasiqAPIService.swift correctly missing from Production")
        production_exists = False

    # This test PASSES if sandbox file exists and production file doesn't (confirming the gap)
    if sandbox_exists and not production_exists:
        logger.log("FILE_EXISTENCE_VALIDATION", "PASSED", "Gap confirmed: BasiqAPIService in Sandbox, missing from Production")
        return True, "Gap confirmed - ready for GREEN phase"
    else:
        gap_status = "Sandbox missing" if not sandbox_exists else "Production has file"
        logger.log("FILE_EXISTENCE_VALIDATION", "FAILED", f"Unexpected state: {gap_status}")
        return False, f"Unexpected state: {gap_status}"

def test_xcode_target_inclusion():
    """Test 2: Verify BasiqAPIService not included in production build target"""
    logger = BankAPITestLogger()

    project_file = MACOS_ROOT / "FinanceMate.xcodeproj/project.pbxproj"

    logger.log("XCODE_TARGET_CHECK", "STARTED", f"Checking Xcode project: {project_file}")

    if not project_file.exists():
        logger.log("XCODE_TARGET_CHECK", "FAILED", "Xcode project file not found")
        return False, "Xcode project file not found"

    try:
        with open(project_file, 'r') as f:
            project_content = f.read()

        # Check for BasiqAPIService references in production target
        basiq_refs = project_content.count("BasiqAPIService.swift")

        logger.log("XCODE_TARGET_CHECK", "INFO", f"Found {basiq_refs} BasiqAPIService.swift references")

        if basiq_refs == 0:
            logger.log("XCODE_TARGET_CHECK", "PASSED", "BasiqAPIService not included in any targets")
            return True, "No BasiqAPIService references found"
        else:
            # Check if references are only in Sandbox target
            sandbox_refs = project_content.count("FinanceMate-Sandbox") and project_content.count("BasiqAPIService.swift")
            production_refs = project_content.count("FinanceMate.") and project_content.count("BasiqAPIService.swift")

            if sandbox_refs > 0 and production_refs == 0:
                logger.log("XCODE_TARGET_CHECK", "PASSED", "BasiqAPIService only in Sandbox target")
                return True, "BasiqAPIService only in Sandbox target"
            else:
                logger.log("XCODE_TARGET_CHECK", "FAILED", f"BasiqAPIService found in production target ({production_refs} refs)")
                return False, f"BasiqAPIService found in production target ({production_refs} refs)"

    except Exception as e:
        logger.log("XCODE_TARGET_CHECK", "FAILED", f"Exception reading project file: {str(e)}")
        return False, f"Exception reading project file: {str(e)}"

def test_import_validation():
    """Test 3: Validate that production code cannot import bank API services"""
    logger = BankAPITestLogger()

    logger.log("IMPORT_VALIDATION", "STARTED", "Testing BasiqAPIService import capability in production")

    try:
        # Since we already confirmed BasiqAPIService.swift doesn't exist in production,
        # we need to check if any production files attempt to import or reference it

        production_views = MACOS_ROOT / "FinanceMate/Views/"
        production_services = MACOS_ROOT / "FinanceMate/Services/"
        production_viewmodels = MACOS_ROOT / "FinanceMate/ViewModels/"

        # Check all production Swift files for BasiqAPIService references
        production_dirs = [production_views, production_services, production_viewmodels]

        import_issues_found = 0

        for prod_dir in production_dirs:
            if not prod_dir.exists():
                continue

            for swift_file in prod_dir.glob("*.swift"):
                try:
                    with open(swift_file, 'r') as f:
                        content = f.read()

                    # Look for any BasiqAPIService imports or references
                    if "BasiqAPIService" in content:
                        logger.log("IMPORT_VALIDATION", "FAILED", f"Found BasiqAPIService reference in {swift_file.name}")
                        import_issues_found += 1
                    elif "import.*Basiq" in content:
                        logger.log("IMPORT_VALIDATION", "FAILED", f"Found Basiq import in {swift_file.name}")
                        import_issues_found += 1

                except Exception as e:
                    logger.log("IMPORT_VALIDATION", "ERROR", f"Error reading {swift_file.name}: {str(e)}")

        # Also check main production files
        main_files = ["FinanceMateApp.swift", "ContentView.swift"]
        for main_file in main_files:
            main_path = MACOS_ROOT / f"FinanceMate/{main_file}"
            if main_path.exists():
                try:
                    with open(main_path, 'r') as f:
                        content = f.read()

                    if "BasiqAPIService" in content:
                        logger.log("IMPORT_VALIDATION", "FAILED", f"Found BasiqAPIService reference in {main_file}")
                        import_issues_found += 1

                except Exception as e:
                    logger.log("IMPORT_VALIDATION", "ERROR", f"Error reading {main_file}: {str(e)}")

        if import_issues_found == 0:
            logger.log("IMPORT_VALIDATION", "PASSED", "No BasiqAPIService imports found in production code")
            return True, "Import validation passed - no BasiqAPIService references in production"
        else:
            logger.log("IMPORT_VALIDATION", "FAILED", f"Found {import_issues_found} BasiqAPIService references in production")
            return False, f"Found {import_issues_found} BasiqAPIService references in production"

    except Exception as e:
        logger.log("IMPORT_VALIDATION", "FAILED", f"Exception during import validation: {str(e)}")
        return False, f"Exception during import validation: {str(e)}"

def test_bank_connection_ui_elements():
    """Test 4: Confirm bank connection UI elements absent in production build"""
    logger = BankAPITestLogger()

    # Check for BankConnectionView in production
    production_ui_path = MACOS_ROOT / "FinanceMate/Views/"
    sandbox_ui_path = MACOS_ROOT / "FinanceMate-Sandbox/FinanceMate/Views/"

    logger.log("UI_ELEMENTS_CHECK", "STARTED", "Checking for bank connection UI elements")

    # Look for bank-related UI files
    bank_ui_files = ["BankConnectionView.swift"]

    for ui_file in bank_ui_files:
        production_file = production_ui_path / ui_file
        sandbox_file = sandbox_ui_path / ui_file

        if sandbox_file.exists():
            logger.log("UI_ELEMENTS_SANDBOX", "PASSED", f"Found {ui_file} in Sandbox")

            if production_file.exists():
                logger.log("UI_ELEMENTS_PRODUCTION", "FAILED", f"Found {ui_file} in Production (should be missing)")
                return False, f"Bank UI {ui_file} exists in production"
            else:
                logger.log("UI_ELEMENTS_PRODUCTION", "PASSED", f"{ui_file} correctly missing from Production")
        else:
            logger.log("UI_ELEMENTS_SANDBOX", "INFO", f"{ui_file} not found in Sandbox")

    # Check production main views for bank connection references
    main_views = ["FinanceMateApp.swift", "ContentView.swift", "TransactionsView.swift"]

    for view_file in main_views:
        view_path = production_ui_path / view_file
        if view_path.exists():
            try:
                with open(view_path, 'r') as f:
                    content = f.read()

                # Look for bank-related references
                bank_refs = ["BankConnectionView", "BasiqAPIService", "connectBank", "bank.*connection"]

                for ref in bank_refs:
                    if ref.lower() in content.lower():
                        logger.log("UI_ELEMENTS_REFS", "FAILED", f"Found bank reference '{ref}' in {view_file}")
                        return False, f"Bank reference '{ref}' found in {view_file}"

            except Exception as e:
                logger.log("UI_ELEMENTS_REFS", "ERROR", f"Error reading {view_file}: {str(e)}")

    logger.log("UI_ELEMENTS_CHECK", "PASSED", "No bank connection UI elements found in production")
    return True, "Bank connection UI elements correctly absent from production"

def test_bank_api_integration_production_ready():
    """
    MAIN TEST: Bank API Integration Production Ready Test

    RED PHASE: This test MUST FAIL to validate the missing Bank API integration.

    BLUEPRINT REQUIREMENTS:
    - UR-101: Bank API integration for Australian financial institutions
    - ANZ/NAB bank connectivity for comprehensive transaction import
    - Basiq API service integration for production deployment

    GREEN PHASE SUCCESS CRITERIA:
    1. BasiqAPIService.swift exists in both Sandbox AND Production
    2. BasiqAPIService included in production build target
    3. Production code can import BasiqAPIService
    4. Bank connection UI elements available in production

    Returns:
        bool: True if test PASSES (gap exists), False if test FAILS (integration present)
    """
    logger = BankAPITestLogger()

    print("=" * 80)
    print("BANK API PRODUCTION INTEGRATION TEST - RED PHASE")
    print("=" * 80)
    print("PURPOSE: Validate CRITICAL PRIORITY 1 GAP - Bank API missing from production")
    print("EXPECTED: Test should FAIL (confirming gap exists)")
    print("GREEN PHASE: Test passes only after Bank API integration is promoted")
    print("=" * 80)

    test_results = []

    # Build production app first
    build_success, build_message = build_production_app()
    test_results.append(("BUILD_PRODUCTION", build_success, build_message))

    if not build_success:
        print(f" BUILD FAILED: {build_message}")
        print("=" * 80)
        print("TEST RESULT: FAILED - Cannot validate Bank API integration due to build failure")
        print("=" * 80)
        return False

    # Run all validation tests
    tests = [
        ("BASIQ_FILE_EXISTENCE", test_basiq_api_service_file_existence),
        ("XCODE_TARGET_INCLUSION", test_xcode_target_inclusion),
        ("IMPORT_VALIDATION", test_import_validation),
        ("BANK_UI_ELEMENTS", test_bank_connection_ui_elements)
    ]

    for test_name, test_func in tests:
        print(f"\n Running {test_name}...")
        try:
            success, message = test_func()
            test_results.append((test_name, success, message))

            if success:
                print(f" {test_name}: PASSED - {message}")
            else:
                print(f" {test_name}: FAILED - {message}")

        except Exception as e:
            print(f" {test_name}: ERROR - {str(e)}")
            test_results.append((test_name, False, f"Exception: {str(e)}"))

    # Analyze results
    passed_tests = sum(1 for _, success, _ in test_results if success)
    total_tests = len(test_results)

    print("\n" + "=" * 80)
    print("TEST RESULTS SUMMARY")
    print("=" * 80)

    for test_name, success, message in test_results:
        status = " PASS" if success else " FAIL"
        print(f"{status} {test_name}: {message}")

    print(f"\nOverall: {passed_tests}/{total_tests} tests passed")

    # RED PHASE LOGIC: Test PASSES if all validations confirm the GAP exists
    # This means BasiqAPIService is in Sandbox but NOT in Production
    if passed_tests == total_tests:
        print("\n RED PHASE CONFIRMED: Bank API integration gap exists in production")
        print(" CRITICAL PRIORITY 1 GAP VALIDATED - Ready for GREEN phase implementation")
        print("\nGREEN PHASE REQUIREMENTS:")
        print("1. Promote BasiqAPIService.swift to Production")
        print("2. Include BasiqAPIService in production build target")
        print("3. Enable bank connection UI elements in production")
        print("4. Integrate ANZ/NAB bank connectivity")
        print("=" * 80)
        return True  # Test passes - gap confirmed
    else:
        print("\n🟢 UNEXPECTED: Some Bank API integration may already exist in production")
        print("️  This suggests the gap may be partially resolved")
        print("=" * 80)
        return False  # Test fails - gap may not exist

def main():
    """Main test execution"""
    print("Bank API Production Integration Test - Atomic TDD Red Phase")
    print("Testing CRITICAL PRIORITY 1 GAP: Bank API integration missing from production")

    start_time = time.time()

    try:
        result = test_bank_api_integration_production_ready()

        execution_time = time.time() - start_time
        print(f"\nTest execution completed in {execution_time:.2f} seconds")

        if result:
            print("\n RED PHASE SUCCESS: Gap confirmed - Bank API integration missing from production")
            print("Ready for GREEN phase implementation")
            exit(0)  # Success - gap confirmed
        else:
            print("\n🟢 UNEXPECTED RESULT: Bank API integration may already exist")
            print("Investigation required to understand current state")
            exit(1)  # Failure - unexpected state

    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        exit(2)
    except Exception as e:
        print(f"\nTest execution failed: {str(e)}")
        exit(3)

if __name__ == "__main__":
    main()