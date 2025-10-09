#!/usr/bin/env python3
"""
Cross-Source Data Validation Test - RED PHASE
Tests BLUEPRINT Line 180: Cross-Source Data Validation
Navigation: Validates CrossSourceDataValidationService.swift implementation
"""

import sys
from pathlib import Path

def test_service_exists():
    """Test that CrossSourceDataValidationService exists"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataValidationService.swift")
    return service_path.exists()

def test_functions_implemented():
    """Test that required functions are implemented"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataValidationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    required_funcs = ["validateTransactionConsistency", "normalizeFieldMapping"]
    for func in required_funcs:
        if f"func {func}" not in content:
            return False
    return True

def test_data_source_support():
    """Test data source support"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataValidationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read().lower()

    sources = ["manual", "gmail", "bank"]
    return all(source in content for source in sources)

def test_xcode_integration():
    """Test Xcode project integration"""
    project_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj")

    if not project_path.exists():
        return False

    with open(project_path, 'r') as f:
        project_content = f.read()

    return "CrossSourceDataValidationService.swift" in project_content

def run_test(test_name, test_func):
    """Run a single test and return result"""
    print(f"\n {test_name}")
    try:
        result = test_func()
        print(f"{' PASS' if result else ' FAIL'}")
        return result
    except Exception as e:
        print(f" ERROR: {e}")
        return False

def get_test_list():
    """Get list of tests to run"""
    return [
        ("Service Exists", test_service_exists),
        ("Functions Implemented", test_functions_implemented),
        ("Data Source Support", test_data_source_support),
        ("Xcode Integration", test_xcode_integration)
    ]

def print_header():
    """Print test header"""
    print(" CROSS-SOURCE DATA VALIDATION - RED PHASE")
    print("BLUEPRINT Line 180: Cross-Source Data Validation")

def print_summary(results):
    """Print test summary and return success status"""
    passed = sum(results)
    total = len(results)
    print(f"\nSummary: {passed}/{total} tests passing")

    if passed == total:
        print(" GREEN PHASE READY!")
        return True
    else:
        print(" RED PHASE: Requirements not implemented")
        return False

def main():
    """Execute RED PHASE tests"""
    print_header()
    tests = get_test_list()

    results = []
    for test_name, test_func in tests:
        result = run_test(test_name, test_func)
        results.append(result)

    return print_summary(results)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

# Navigation: Validates CrossSourceDataValidationService.swift for BLUEPRINT Line 180
# Tests cross-source data validation: manual entry, Gmail import, bank API consistency
# Service location: FinanceMate/Services/CrossSourceDataValidationService.swift