#!/usr/bin/env python3
"""
Core Data Model Loading Test - RED PHASE
Tests that FinanceMate app can launch and initialize Core Data without errors
"""

import sys
import subprocess
import time
import os
from pathlib import Path

def test_persistence_controller_has_inline_model():
    """Test that PersistenceController has inline Core Data model"""
    print(" Testing PersistenceController inline model...")

    controller_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/PersistenceController.swift")

    if not controller_path.exists():
        print(" PersistenceController.swift not found")
        return False

    with open(controller_path, 'r') as f:
        content = f.read()

    # Check for problematic CoreDataModelBuilder dependency
    if "CoreDataModelBuilder.createModel()" in content:
        print(" PersistenceController still uses CoreDataModelBuilder dependency")
        return False

    # Check for inline Core Data model implementation
    required_patterns = [
        "NSManagedObjectModel()",
        "NSEntityDescription()",
        "NSAttributeDescription()"
    ]

    missing_patterns = []
    for pattern in required_patterns:
        if pattern not in content:
            missing_patterns.append(pattern)

    if missing_patterns:
        print(f" Missing Core Data patterns: {missing_patterns}")
        return False

    print(" PersistenceController has inline Core Data model")
    return True

def test_transaction_entity_attributes():
    """Test that Transaction entity has required attributes"""
    print(" Testing Transaction entity attributes...")

    controller_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/PersistenceController.swift")

    with open(controller_path, 'r') as f:
        content = f.read()

    # Check for required Transaction entity attributes
    required_attributes = [
        'idAttr.name = "id"',
        'descAttr.name = "itemDescription"',
        'amountAttr.name = "amount"',
        'dateAttr.name = "date"'
    ]

    missing_attrs = []
    for attr in required_attributes:
        if attr not in content:
            missing_attrs.append(attr)

    if missing_attrs:
        print(f" Missing attributes: {missing_attrs}")
        return False

    print(" Transaction entity has required attributes")
    return True

def test_app_builds_successfully():
    """Test that app builds successfully"""
    print(" Testing app build...")

    build_cmd = [
        "xcodebuild",
        "-project", "FinanceMate.xcodeproj",
        "-scheme", "FinanceMate",
        "-configuration", "Debug",
        "build"
    ]

    try:
        result = subprocess.run(build_cmd,
                              capture_output=True,
                              text=True,
                              timeout=60,
                              cwd="/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")

        if result.returncode == 0:
            print(" App builds successfully")
            return True
        else:
            print(f" Build failed: {result.stderr[:200]}")
            return False
    except subprocess.TimeoutExpired:
        print(" Build timed out")
        return False
    except Exception as e:
        print(f" Build error: {e}")
        return False

def main():
    """Execute RED PHASE tests for Core Data model loading"""
    print(" CORE DATA MODEL LOADING - RED PHASE")
    print("Testing Core Data model implementation")

    tests = [
        ("PersistenceController Inline Model", test_persistence_controller_has_inline_model),
        ("Transaction Entity Attributes", test_transaction_entity_attributes),
        ("App Build Success", test_app_builds_successfully)
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
    print(f"\n Summary: {passed}/{total} tests passing")

    if passed == total:
        print("🟢 GREEN PHASE READY - Core Data model is properly implemented")
        return True
    else:
        print(" RED PHASE: Core Data model needs implementation")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)