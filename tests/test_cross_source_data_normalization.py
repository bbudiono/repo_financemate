#!/usr/bin/env python3
"""
Cross-Source Data Normalization Test - RED PHASE
Tests BLUEPRINT Line 180: Enhanced data normalization functionality
"""

import sys
from pathlib import Path

def test_service_exists():
    """Test that CrossSourceDataNormalizationService exists"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataNormalizationService.swift")
    return service_path.exists()

def test_functions_exist():
    """Test that required functions are implemented"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataNormalizationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    required_funcs = ["normalizeTransactionFields", "mapDataSources"]
    for func in required_funcs:
        if f"func {func}" not in content:
            return False
    return True

def test_data_normalization_features():
    """Test data normalization features"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/CrossSourceDataNormalizationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read().lower()

    patterns = ["gmail", "bank", "manual", "normalization"]
    return all(pattern in content for pattern in patterns)

def test_xcode_integration():
    """Test Xcode project integration"""
    project_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj")

    if not project_path.exists():
        return False

    with open(project_path, 'r') as f:
        project_content = f.read()

    return "CrossSourceDataNormalizationService.swift" in project_content

def main():
    """Execute RED PHASE tests"""
    print(" CROSS-SOURCE DATA NORMALIZATION - RED PHASE")
    print("BLUEPRINT Line 180: Enhanced data normalization")

    tests = [
        ("Service Exists", test_service_exists),
        ("Functions Exist", test_functions_exist),
        ("Normalization Features", test_data_normalization_features),
        ("Xcode Integration", test_xcode_integration)
    ]

    results = []
    for test_name, test_func in tests:
        print(f"\n {test_name}")
        try:
            result = test_func()
            print(f"{' PASS' if result else ' FAIL'}")
            results.append(result)
        except Exception as e:
            print(f" ERROR: {e}")
            results.append(False)

    passed = sum(results)
    total = len(results)
    print(f"\nSummary: {passed}/{total} tests passing")

    if passed == total:
        print(" GREEN PHASE READY!")
        return True
    else:
        print(" RED PHASE: Enhanced normalization not implemented")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)