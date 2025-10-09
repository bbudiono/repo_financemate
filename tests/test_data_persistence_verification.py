#!/usr/bin/env python3
"""
Data Persistence Verification Test - RED PHASE
Tests BLUEPRINT Requirement #6: Data persistence verification functionality
"""

import sys
import subprocess
import time
from pathlib import Path

def test_service_exists():
    """Test that PersistenceValidationService exists"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/PersistenceValidationService.swift")
    return service_path.exists()

def test_data_persistence_functions_exist():
    """Test that data persistence validation functions exist"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/PersistenceValidationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    required_funcs = ["createTestData", "validateDataPersistence", "cleanupTestData"]
    for func in required_funcs:
        if f"func {func}" not in content:
            return False
    return True

def test_core_data_persistence_integration():
    """Test Core Data persistence integration"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/PersistenceValidationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    patterns = ["PersistenceController", "NSManagedObjectContext", "Core Data"]
    return any(pattern in content for pattern in patterns)

def test_persistence_validation_workflow():
    """Test persistence validation workflow implementation"""
    service_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/Services/PersistenceValidationService.swift")

    if not service_path.exists():
        return False

    with open(service_path, 'r') as f:
        content = f.read()

    patterns = ["restart", "persistence", "validation", "integrity"]
    return any(pattern in content for pattern in patterns)

def test_xcode_integration():
    """Test Xcode project integration"""
    project_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj/project.pbxproj")

    if not project_path.exists():
        return False

    with open(project_path, 'r') as f:
        project_content = f.read()

    return "PersistenceValidationService.swift" in project_content

def main():
    """Execute RED PHASE tests"""
    print(" DATA PERSISTENCE VERIFICATION - RED PHASE")
    print("BLUEPRINT Requirement #6: Data persistence verification")

    tests = [
        ("Service Exists", test_service_exists),
        ("Persistence Functions Exist", test_data_persistence_functions_exist),
        ("Core Data Integration", test_core_data_persistence_integration),
        ("Validation Workflow", test_persistence_validation_workflow),
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
        print(" RED PHASE: Data persistence verification not implemented")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)