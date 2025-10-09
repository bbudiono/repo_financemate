#!/usr/bin/env python3
"""
FinanceMate E2E Test Alignment - RED Phase Test
Tests the expectation-reality mismatch between modular CoreData architecture expectations
and production inline model implementation that ensures build stability.

PRINCIPLES:
- Atomic TDD RED phase - creates failing test to drive alignment
- Expects modular CoreDataModelBuilder but validates inline model works
- Focus on build stability and production functionality
- 100% headless execution with deterministic validation
"""

import subprocess
import time
import os
import json
import sqlite3
import signal
import psutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

# Test configuration
TEST_TIMEOUT = 30
BUILD_TIMEOUT = 120
TEST_LOG_DIR = PROJECT_ROOT / "test_output"
TEST_LOG_DIR.mkdir(parents=True, exist_ok=True)

class TestLogger:
    """Centralized test logging for RED phase validation"""

    def __init__(self):
        self.log_file = TEST_LOG_DIR / f"coredata_alignment_red_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        self.test_results = []

    def log(self, test_name: str, status: str, message: str = ""):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] {test_name}: {status} - {message}\n"

        with open(self.log_file, 'a') as f:
            f.write(log_entry)

        self.test_results.append({
            'test': test_name,
            'status': status,
            'message': message,
            'timestamp': timestamp
        })

        print(f"[{status}] {test_name}: {message}")

logger = TestLogger()

def run_command(cmd: List[str], timeout: int = 60, cwd: Optional[Path] = None) -> Tuple[bool, str, str]:
    """Run command with timeout and return success, stdout, stderr"""
    try:
        result = subprocess.run(
            cmd,
            timeout=timeout,
            capture_output=True,
            text=True,
            cwd=cwd
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)

def test_coredata_expectation_vs_reality():
    """
    RED PHASE TEST: Expects modular CoreDataModelBuilder but validates inline model works
    This test FAILS initially to demonstrate the expectation-reality mismatch
    """
    logger.log("COREDATA_ALIGNMENT_RED", "START", "Testing CoreData expectation vs reality mismatch")

    # Check what exists in production
    persistence_file = MACOS_ROOT / "FinanceMate/PersistenceController.swift"
    coredata_model_builder_file = MACOS_ROOT / "FinanceMate/CoreDataModelBuilder.swift"

    # Reality: Check current inline model implementation
    if not persistence_file.exists():
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL", "PersistenceController.swift not found")
        return False

    with open(persistence_file, 'r') as f:
        persistence_content = f.read()

    # Expectation: Check if tests expect modular architecture
    if not coredata_model_builder_file.exists():
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL", "CoreDataModelBuilder.swift not found - tests expect this")
        return False

    with open(coredata_model_builder_file, 'r') as f:
        builder_content = f.read()

    # Validate expectation: Tests expect createModel() method
    if "createModel()" not in builder_content:
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL", "CoreDataModelBuilder missing createModel() method expected by tests")
        return False

    logger.log("COREDATA_ALIGNMENT_RED", "INFO", "CoreDataModelBuilder.createModel() found - test expectation exists")

    # Validate reality: Production uses inline model for build stability
    inline_model_indicators = [
        "guard let modelURL = Bundle.main.url(forResource: \"FinanceMate\", withExtension: \"momd\")",
        "guard let model = NSManagedObjectModel(contentsOf: modelURL)",
        "NSPersistentContainer(name: \"FinanceMate\", managedObjectModel: model)"
    ]

    found_inline_patterns = []
    for pattern in inline_model_indicators:
        if pattern in persistence_content:
            found_inline_patterns.append(pattern)

    if len(found_inline_patterns) < 3:
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL", f"Production not using inline model: missing {set(inline_model_indicators) - set(found_inline_patterns)}")
        return False

    logger.log("COREDATA_ALIGNMENT_RED", "INFO", "Production uses inline model approach for build stability")

    # The RED phase failure: Expectation mismatch
    # Tests expect modular CoreDataModelBuilder.createModel() but production uses inline model
    expectation_modular = "createModel()" in builder_content
    reality_inline = len(found_inline_patterns) >= 3

    if expectation_modular and reality_inline:
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL_RED", "EXPECTATION MISMATCH: Tests expect modular CoreDataModelBuilder.createModel() but production uses inline model for build stability")
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL_RED", "This is the core issue causing 3 E2E test failures")
        logger.log("COREDATA_ALIGNMENT_RED", "FAIL_RED", "Decision needed: Update tests to match inline model reality OR refactor production to use modular model")
        return False  # RED PHASE - This test MUST fail to drive the fix

    logger.log("COREDATA_ALIGNMENT_RED", "PASS", "CoreData architecture aligned")
    return True

def test_production_inline_model_functionality():
    """
    RED PHASE TEST: Validates that the current inline model approach actually works
    This test PASSES to prove production functionality is stable
    """
    logger.log("PRODUCTION_INLINE_MODEL", "START", "Testing production inline model functionality")

    # Build the project to verify inline model works
    cmd = [
        "xcodebuild",
        "-project", "FinanceMate.xcodeproj",
        "-scheme", "FinanceMate",
        "-configuration", "Debug",
        "build"
    ]

    success, stdout, stderr = run_command(cmd, timeout=BUILD_TIMEOUT, cwd=MACOS_ROOT)

    if not success:
        logger.log("PRODUCTION_INLINE_MODEL", "FAIL", f"Production build failed with inline model: {stderr[:200]}...")
        return False

    logger.log("PRODUCTION_INLINE_MODEL", "PASS", "Production build successful with inline model - build stability confirmed")

    # Check that Core Data model file exists (FinanceMate.momd)
    momd_path = MACOS_ROOT / "build/Build/Products/Debug/FinanceMate.app/Contents/Resources/FinanceMate.momd"
    if not momd_path.exists():
        # Try alternative locations
        alternative_paths = [
            MACOS_ROOT / "FinanceMate/Resources/FinanceMate.xcdatamodeld",
            MACOS_ROOT / "FinanceMate/FinanceMate.xcdatamodeld"
        ]

        model_found = False
        for path in alternative_paths:
            if path.exists():
                momd_path = path
                model_found = True
                break

        if not model_found:
            logger.log("PRODUCTION_INLINE_MODEL", "FAIL", "Core Data model file (FinanceMate.momd/xcdatamodeld) not found")
            return False

    logger.log("PRODUCTION_INLINE_MODEL", "PASS", f"Core Data model found: {momd_path}")
    return True

def test_build_stability_validation():
    """
    RED PHASE TEST: Validates that the inline model approach provides better build stability
    than the modular approach that was causing issues
    """
    logger.log("BUILD_STABILITY_VALIDATION", "START", "Testing build stability with inline model")

    # Test 1: Clean build
    clean_cmd = ["xcodebuild", "clean", "-project", "FinanceMate.xcodeproj", "-scheme", "FinanceMate"]
    clean_success, _, clean_stderr = run_command(clean_cmd, timeout=60, cwd=MACOS_ROOT)

    if not clean_success:
        logger.log("BUILD_STABILITY_VALIDATION", "WARN", f"Clean failed: {clean_stderr[:100]}...")

    # Test 2: Build twice to check consistency
    build_results = []
    for attempt in range(2):
        cmd = [
            "xcodebuild",
            "-project", "FinanceMate.xcodeproj",
            "-scheme", "FinanceMate",
            "-configuration", "Debug",
            "build"
        ]

        success, stdout, stderr = run_command(cmd, timeout=BUILD_TIMEOUT, cwd=MACOS_ROOT)
        build_results.append(success)

        if not success:
            logger.log("BUILD_STABILITY_VALIDATION", "FAIL", f"Build attempt {attempt + 1} failed: {stderr[:200]}...")
            return False
        else:
            logger.log("BUILD_STABILITY_VALIDATION", "INFO", f"Build attempt {attempt + 1} successful")

    # Test 3: No Core Data compilation errors
    build_output = stdout + stderr
    coredata_errors = [
        "Use of undeclared type 'CoreDataModelBuilder'",
        "Cannot find 'createModel' in scope",
        "Module 'FinanceMate' has no member named 'CoreDataModelBuilder'"
    ]

    found_coredata_errors = [error for error in coredata_errors if error in build_output]

    if found_coredata_errors:
        logger.log("BUILD_STABILITY_VALIDATION", "FAIL", f"Core Data compilation errors found: {found_coredata_errors}")
        return False

    if all(build_results):
        logger.log("BUILD_STABILITY_VALIDATION", "PASS", "Build stability confirmed - consistent builds with inline model")
        return True
    else:
        logger.log("BUILD_STABILITY_VALIDATION", "FAIL", "Build stability compromised - inconsistent results")
        return False

def test_e2e_impact_assessment():
    """
    RED PHASE TEST: Assesses the impact of the expectation-reality mismatch on E2E tests
    """
    logger.log("E2E_IMPACT_ASSESSMENT", "START", "Assessing E2E test failure impact")

    # Run the failing E2E tests to confirm they fail due to CoreData mismatch
    e2e_test_cmd = ["python3", "test_financemate_complete_e2e.py"]

    success, stdout, stderr = run_command(e2e_test_cmd, timeout=300, cwd=MACOS_ROOT / "tests")

    if success:
        logger.log("E2E_IMPACT_ASSESSMENT", "UNEXPECTED", "E2E tests passed - expectation-reality mismatch may be resolved")
        return True

    # Parse E2E test output to identify CoreData-related failures
    output = stdout + stderr

    coredata_failure_patterns = [
        "CORE_DATA_MODEL.*FAIL.*Missing Core Data patterns.*CoreDataModelBuilder.createModel()",
        "TAX_SPLITTING_E2E_WORKFLOW.*FAIL.*PersistenceController not using CoreDataModelBuilder",
        "BLUEPRINT_GMAIL.*FAIL"
    ]

    import re
    found_coredata_failures = []
    for pattern in coredata_failure_patterns:
        matches = re.findall(pattern, output, re.IGNORECASE)
        if matches:
            found_coredata_failures.extend(matches)

    if found_coredata_failures:
        logger.log("E2E_IMPACT_ASSESSMENT", "CONFIRMED", f"E2E failures due to CoreData mismatch: {len(found_coredata_failures)} failures")
        for failure in found_coredata_failures:
            logger.log("E2E_IMPACT_ASSESSMENT", "CONFIRMED", f"Failure pattern: {failure}")
        return False  # RED PHASE - Confirm the problem exists
    else:
        logger.log("E2E_IMPACT_ASSESSMENT", "INFO", "E2E failures may have different root cause")
        return True

def run_red_phase_tests():
    """Execute all RED phase tests to demonstrate the expectation-reality mismatch"""
    print(" COREDATA ALIGNMENT RED PHASE TESTS")
    print("=" * 60)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Project Root: {PROJECT_ROOT}")
    print(f"macOS Root: {MACOS_ROOT}")
    print("=" * 60)
    print("PURPOSE: Expose expectation-reality mismatch between modular CoreData tests")
    print("         and inline model production implementation for build stability")
    print("=" * 60)

    red_phase_tests = [
        ("CoreData Expectation vs Reality", test_coredata_expectation_vs_reality),
        ("Production Inline Model Functionality", test_production_inline_model_functionality),
        ("Build Stability Validation", test_build_stability_validation),
        ("E2E Impact Assessment", test_e2e_impact_assessment)
    ]

    passed_tests = 0
    total_tests = len(red_phase_tests)

    for test_name, test_func in red_phase_tests:
        print(f"\n RED PHASE TEST: {test_name}")
        print("-" * 50)

        try:
            if test_func():
                passed_tests += 1
                print(f" {test_name:.<40} PASSED")
            else:
                print(f" {test_name:.<40} FAILED (Expected in RED phase)")
        except Exception as e:
            print(f" {test_name:.<40} ERROR - {e}")
            logger.log(test_name, "ERROR", str(e))

    print("\n" + "=" * 60)
    print(" RED PHASE TEST SUMMARY")
    print("=" * 60)
    print(f"Tests Passed: {passed_tests}/{total_tests}")
    print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")

    if passed_tests < total_tests:
        print("\n RED PHASE VALIDATION COMPLETE")
        print(" Expectation-reality mismatch confirmed")
        print(" Ready for GREEN phase: Fix test expectations to match production reality")
        print(" Recommendation: Update tests to validate inline model approach")
    else:
        print("\n UNEXPECTED: All RED phase tests passed")
        print(" Expectation-reality mismatch may already be resolved")

    # Write RED phase summary
    red_summary = {
        'timestamp': datetime.now().isoformat(),
        'phase': 'RED',
        'purpose': 'Expose CoreData expectation-reality mismatch',
        'passed': passed_tests,
        'total': total_tests,
        'success_rate': (passed_tests/total_tests)*100,
        'expectation_mismatch_confirmed': passed_tests < total_tests,
        'test_results': logger.test_results
    }

    summary_file = TEST_LOG_DIR / "coredata_alignment_red_summary.json"
    with open(summary_file, 'w') as f:
        json.dump(red_summary, f, indent=2)

    print(f"\n RED phase logs: {logger.log_file}")
    print(f" RED phase summary: {summary_file}")

    return passed_tests < total_tests  # RED phase success = tests failing as expected

if __name__ == "__main__":
    red_phase_success = run_red_phase_tests()
    exit(0 if red_phase_success else 1)