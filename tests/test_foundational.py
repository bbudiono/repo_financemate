#!/usr/bin/env python3
"""FinanceMate Foundational Tests - Build, Security, Core Data"""

import subprocess
import os
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

def log_test(test_name, status, message=""):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_file = PROJECT_ROOT / "test_output" / "e2e_test_log.txt"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {test_name}: {status} - {message}\n")

def test_build():
    os.chdir(MACOS_ROOT)
    result = subprocess.run(["xcodebuild", "-scheme", "FinanceMate", "-configuration", "Debug",
                           "-destination", "platform=macOS", "build"],
                           capture_output=True, text=True)
    success = "BUILD SUCCEEDED" in result.stdout or result.returncode == 0
    log_test("test_build", "PASS" if success else "FAIL", f"Build: {'OK' if success else 'FAILED'}")
    return success

def test_kiss_compliance():
    swift_files = []
    for root, dirs, files in os.walk(MACOS_ROOT):
        for file in files:
            if file.endswith('.swift'):
                swift_files.append(os.path.join(root, file))

    violations = sum(1 for file_path in swift_files
                   if len(open(file_path).readlines()) > 200)
    log_test("test_kiss_compliance", "PASS" if violations == 0 else "FAIL", f"Violations: {violations}")
    return violations == 0

def test_security_hardening():
    violations = 0
    for root, dirs, files in os.walk(MACOS_ROOT / "FinanceMate"):
        for file in files:
            if file.endswith('.swift'):
                content = open(os.path.join(root, file)).read()
                if 'fatalError(' in content:
                    violations += 1

    log_test("test_security_hardening", "PASS" if violations == 0 else "FAIL", f"Violations: {violations}")
    return violations == 0

def test_core_data_schema():
    for root, dirs, files in os.walk(MACOS_ROOT / "FinanceMate"):
        for file in files:
            if file.endswith('.swift'):
                content = open(os.path.join(root, file)).read()
                if 'struct Transaction' in content:
                    required = ['id', 'amount', 'merchant', 'date']
                    if all(attr in content for attr in required):
                        log_test("test_core_data_schema", "PASS", "Transaction entity complete")
                        return True

    log_test("test_core_data_schema", "FAIL", "Transaction entity not found")
    return False

def test_tax_category_support():
    for root, dirs, files in os.walk(MACOS_ROOT / "FinanceMate"):
        for file in files:
            if file.endswith('.swift'):
                content = open(os.path.join(root, file)).read()
                if 'TaxCategory' in content:
                    log_test("test_tax_category_support", "PASS", "TaxCategory found")
                    return True

    log_test("test_tax_category_support", "FAIL", "TaxCategory not found")
    return False

if __name__ == "__main__":
    tests = [test_build, test_kiss_compliance, test_security_hardening, test_core_data_schema, test_tax_category_support]
    results = [test() for test in tests]
    passed = sum(results)
    log_test("FOUNDATIONAL_SUMMARY", "PASS" if passed == len(results) else "FAIL", f"Passed: {passed}/{len(results)}")