#!/usr/bin/env python3
"""
Atomic TDD test for SplitAllocation build validation
"""

import subprocess
import sys

def test_split_allocation_build():
    """Test that SplitAllocation types compile successfully"""

    print(" ATOMIC TDD TEST: SplitAllocation Build Validation")

    # Test 1: Check if SplitAllocation.swift can be compiled individually
    try:
        result = subprocess.run([
            'xcodebuild',
            '-project', 'FinanceMate.xcodeproj',
            '-scheme', 'FinanceMate',
            '-configuration', 'Debug',
            '-only-testing:FinanceMate',
            'build'
        ], capture_output=True, text=True, timeout=30)

        split_allocation_errors = [
            line for line in result.stderr.split('\n')
            if 'SplitAllocation' in line and 'error:' in line
        ]

        if split_allocation_errors:
            print(f" RED TEST FAILING: SplitAllocation compilation errors found:")
            for error in split_allocation_errors[:3]:  # Show first 3 errors
                print(f"   - {error.strip()}")
            return False
        else:
            print(" GREEN TEST PASSING: No SplitAllocation compilation errors")
            return True

    except subprocess.TimeoutExpired:
        print(" TIMEOUT: Build test timed out")
        return False
    except Exception as e:
        print(f" ERROR: Build test failed with exception: {e}")
        return False

if __name__ == "__main__":
    success = test_split_allocation_build()
    sys.exit(0 if success else 1)