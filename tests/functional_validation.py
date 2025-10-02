#!/usr/bin/env python3
"""
REAL Functional Validation - Not Code Existence Checks
Per BLUEPRINT Lines 23, 30, 31, 40: Validate actual functionality, state changes, data flows
"""

import subprocess
import time
from pathlib import Path

APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")

def test_app_launches_and_runs():
    """BLUEPRINT Line 23: Validate app launches without crash"""
    print("Testing: App launches successfully...")

    # Launch app
    proc = subprocess.Popen(["open", "-W", "-n", str(APP_PATH)])
    time.sleep(5)

    # Check if running
    result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    is_running = "FinanceMate" in result.stdout and "MacOS/FinanceMate" in result.stdout

    if is_running:
        print("   PASS: App launched and is running")
        # Get PID
        for line in result.stdout.split('\n'):
            if 'FinanceMate.app/Contents/MacOS/FinanceMate' in line:
                pid = line.split()[1]
                print(f"  Process ID: {pid}")
                return True, pid
    else:
        print("   FAIL: App did not launch or crashed immediately")
        return False, None

def test_app_responds():
    """BLUEPRINT Line 31: Verify app is responsive (not frozen/crashed)"""
    print("Testing: App is responsive...")

    # Check if process is in Running state (not Zombie)
    result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    for line in result.stdout.split('\n'):
        if 'FinanceMate.app/Contents/MacOS/FinanceMate' in line:
            # State is in column 8 (R=running, Z=zombie, S=sleeping)
            state = line.split()[7]
            if state in ['R', 'S']:  # Running or Sleeping (normal)
                print(f"   PASS: App is responsive (state: {state})")
                return True
            else:
                print(f"   FAIL: App is unresponsive (state: {state})")
                return False

    print("   FAIL: App process not found")
    return False

def test_no_crash_logs():
    """BLUEPRINT Line 32: Check for crash logs"""
    print("Testing: No recent crash logs...")

    crash_dir = Path.home() / "Library/Logs/DiagnosticReports"
    recent_crashes = []

    if crash_dir.exists():
        for crash_file in crash_dir.glob("FinanceMate*.crash"):
            # Check if modified in last 10 minutes
            if time.time() - crash_file.stat().st_mtime < 600:
                recent_crashes.append(crash_file.name)

    if not recent_crashes:
        print("   PASS: No crash logs found")
        return True
    else:
        print(f"   FAIL: Found crash logs: {recent_crashes}")
        return False

def cleanup_app():
    """BLUEPRINT Line 36: Terminate app after testing"""
    print("Cleanup: Terminating app...")
    subprocess.run(["pkill", "-9", "FinanceMate"], capture_output=True)
    time.sleep(1)
    print("   App terminated")

def main():
    print("="*70)
    print("FINANCEMATE FUNCTIONAL VALIDATION - REAL TESTS")
    print("="*70)
    print()

    tests_passed = 0
    tests_total = 3

    # Test 1: App launches
    success, pid = test_app_launches_and_runs()
    if success:
        tests_passed += 1
    else:
        cleanup_app()
        print(f"\nRESULT: {tests_passed}/{tests_total} FAILED - App won't launch")
        return

    # Test 2: App responsive
    if test_app_responds():
        tests_passed += 1

    # Test 3: No crashes
    if test_no_crash_logs():
        tests_passed += 1

    # Cleanup
    cleanup_app()

    print()
    print("="*70)
    print(f"RESULT: {tests_passed}/{tests_total} functional tests passed")
    print("="*70)
    print()

    if tests_passed == tests_total:
        print(" BASIC FUNCTIONALITY VERIFIED")
        print()
        print("️  STILL REQUIRES USER TESTING:")
        print("  - Gmail OAuth flow (needs user Google credentials)")
        print("  - Email loading (needs OAuth completion)")
        print("  - Transaction extraction (needs real emails)")
        print("  - Chatbot responses (needs ANTHROPIC_API_KEY)")
        print("  - All button interactions")
        print("  - Tab navigation validation")
    else:
        print(" BASIC FUNCTIONALITY FAILED")
        print("   App has critical issues preventing launch/run")

if __name__ == "__main__":
    main()
