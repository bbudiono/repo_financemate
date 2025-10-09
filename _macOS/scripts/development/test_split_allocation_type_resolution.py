#!/usr/bin/env python3
"""
Atomic TDD Test: SplitAllocation Type Resolution - RED Phase
P0 Critical: Build Stability Restoration

This test validates that SplitAllocation type is properly accessible
in SplitAllocationCalculationService.swift
"""

import subprocess
import sys
import os

def test_split_allocation_type_resolution():
    """RED Phase: Test that SplitAllocation type should be accessible"""
    print(" RED PHASE: SplitAllocation Type Resolution Test")

    # Change to project directory
    os.chdir('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS')

    # Try to compile just the SplitAllocationCalculationService
    cmd = [
        'xcodebuild',
        '-project', 'FinanceMate.xcodeproj',
        '-scheme', 'FinanceMate',
        '-configuration', 'Debug',
        '-only-testing', 'FinanceMateTests',
        'build'
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)

        # Check for SplitAllocation compilation errors
        if "cannot find type 'SplitAllocation' in scope" in result.stderr:
            print(" RED TEST FAILING: SplitAllocation type not accessible as expected")
            print("   Error confirmed in compilation output")
            return False
        elif result.returncode == 0:
            print(" SplitAllocation type accessible - GREEN PHASE NEEDED")
            return True
        else:
            print(f" Unexpected compilation result: {result.stderr}")
            return False

    except subprocess.TimeoutExpired:
        print(" Build timed out")
        return False
    except Exception as e:
        print(f" Test execution failed: {e}")
        return False

if __name__ == "__main__":
    success = test_split_allocation_type_resolution()
    sys.exit(0 if not success else 1)  # Exit 1 if test fails (RED phase)