#!/usr/bin/env python3
"""
Atomic TDD test for CoreDataManager compilation fixes - P0 Critical
"""

import re
import sys

def test_coredata_compilation_issues():
    """Test that CoreDataManager has compilation issues - RED phase"""
    print(" RED PHASE TEST: CoreDataManager Compilation Issues")

    try:
        with open('FinanceMate/Services/CoreDataManager.swift', 'r') as f:
            content = f.read()

        # Check for problematic patterns
        issues = []

        if 'NSApplication.shared.delegate' in content:
            issues.append("NSApplication.shared.delegate")

        if 'as? AppDelegate' in content:
            issues.append("AppDelegate type casting")

        if 'as! NSFetchRequest<Transaction>' in content:
            issues.append("Force NSFetchRequest casting")

        if issues:
            print(f" RED TEST FAILING: Found compilation issues: {', '.join(issues)}")
            return False

        print(" No compilation issues found")
        return True

    except FileNotFoundError:
        print(" RED TEST FAILING: CoreDataManager.swift not found")
        return False

if __name__ == "__main__":
    success = test_coredata_compilation_issues()
    sys.exit(0 if success else 1)