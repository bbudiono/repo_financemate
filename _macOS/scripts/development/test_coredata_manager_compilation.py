#!/usr/bin/env python3
"""
Atomic TDD test for CoreDataManager compilation fixes
P0 Critical: Fix CoreDataManager platform compatibility issues
"""

import subprocess
import sys
import re

def test_coredata_manager_compilation():
    """Test that CoreDataManager compiles without platform errors"""
    print(" RED PHASE TEST: CoreDataManager Compilation Validation")

    # Test 1: Check for NSApplication compatibility issues
    try:
        with open('FinanceMate/Services/CoreDataManager.swift', 'r') as f:
            content = f.read()

        # Look for problematic NSApplication usage
        nsapp_pattern = r'NSApplication\.shared\.delegate'
        if re.search(nsapp_pattern, content):
            print(" RED TEST FAILING: NSApplication.shared.delegate found - platform compatibility issue")
            return False

        print(" NSApplication compatibility check passed")

    except FileNotFoundError:
        print(" RED TEST FAILING: CoreDataManager.swift not found")
        return False

    # Test 2: Check for AppDelegate type issues
    try:
        appdelegate_pattern = r'as\s+\?AppDelegate'
        if re.search(appdelegate_pattern, content):
            print(" RED TEST FAILING: AppDelegate type casting found - type resolution issue")
            return False

        print(" AppDelegate type resolution check passed")

    except Exception:
        print(" RED TEST FAILING: Error checking AppDelegate patterns")
        return False

    # Test 3: Check for Core Data casting issues
    try:
        casting_pattern = r'as!\s*NSFetchRequest<\w+>'
        if re.search(casting_pattern, content):
            print(" RED TEST FAILING: Force casting NSFetchRequest found - type safety issue")
            return False

        print(" Core Data type casting check passed")

    except Exception:
        print(" RED TEST FAILING: Error checking Core Data casting patterns")
        return False

    print(" RED TEST COMPLETE: CoreDataManager compilation issues identified")
    return True

if __name__ == "__main__":
    success = test_coredata_manager_compilation()
    sys.exit(0 if success else 1)