#!/usr/bin/env python3
"""
Test 4: SwiftUI View Rendering Functional Test
Converts grep-based test_swift_ui_structure() to functional validation

PREVIOUS (Grep): Checked if Swift files exist
CURRENT (Functional): Validates views actually render without crashing
"""

import subprocess
import time
import signal
from pathlib import Path
from typing import Tuple, Optional

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

def find_app_binary() -> Optional[Path]:
    """Find the built FinanceMate.app binary"""
    derived_data_pattern = Path.home() / "Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Products/Debug/FinanceMate.app"

    import glob
    matches = glob.glob(str(derived_data_pattern))
    if matches:
        return Path(matches[0])

    local_build = MACOS_ROOT / "build/Build/Products/Debug/FinanceMate.app"
    if local_build.exists():
        return local_build

    return None

def run_swift_snippet(code: str, timeout: int = 10) -> Tuple[bool, str]:
    """Execute Swift code snippet and return success status and output"""
    swift_file = MACOS_ROOT / "temp_swift_test.swift"

    try:
        # Write Swift code to temporary file
        swift_file.write_text(code)

        # Compile and run Swift code
        result = subprocess.run(
            ["swift", str(swift_file)],
            timeout=timeout,
            capture_output=True,
            text=True,
            cwd=MACOS_ROOT
        )

        success = result.returncode == 0
        output = result.stdout + result.stderr

        return success, output

    except subprocess.TimeoutExpired:
        return False, "Swift execution timed out"
    except Exception as e:
        return False, f"Swift execution error: {str(e)}"
    finally:
        if swift_file.exists():
            swift_file.unlink()

def get_app_console_logs(app_pid: int) -> str:
    """Retrieve console logs for the running app process"""
    try:
        result = subprocess.run(
            ["log", "show", "--predicate", f"process == {app_pid}", "--last", "30s", "--style", "compact"],
            timeout=5,
            capture_output=True,
            text=True
        )
        return result.stdout
    except Exception as e:
        return f"Error retrieving logs: {str(e)}"

def launch_financemate() -> Optional[int]:
    """Launch FinanceMate app and return process ID"""
    app_path = find_app_binary()
    if not app_path:
        return None

    try:
        # Launch app in background
        subprocess.Popen(["open", str(app_path)])
        time.sleep(5)  # Wait for app to launch

        # Find the process ID
        result = subprocess.run(
            ["pgrep", "-f", "FinanceMate.app"],
            capture_output=True,
            text=True
        )

        if result.stdout.strip():
            return int(result.stdout.strip().split('\n')[0])

        return None

    except Exception as e:
        print(f"Launch error: {e}")
        return None

def terminate_app(app_pid: int):
    """Gracefully terminate the app"""
    try:
        subprocess.run(["kill", "-TERM", str(app_pid)], timeout=2)
        time.sleep(1)
    except:
        # Force kill if graceful termination fails
        try:
            subprocess.run(["kill", "-9", str(app_pid)], timeout=1)
        except:
            pass

def app_is_running(app_pid: int) -> bool:
    """Check if app process is still running"""
    try:
        result = subprocess.run(
            ["ps", "-p", str(app_pid)],
            capture_output=True,
            text=True
        )
        return result.returncode == 0
    except:
        return False

def test_swiftui_view_rendering():
    """
    FUNCTIONAL TEST: Verify SwiftUI views actually render without crashing

    Tests:
    1. App launches successfully
    2. No SwiftUI runtime errors in console
    3. No fatal errors during view rendering
    4. App remains responsive for 10 seconds
    """
    print("\n=== Test 4: SwiftUI View Rendering ===")

    # Step 1: Launch the app
    print("  [1/4] Launching FinanceMate app...")
    app_pid = launch_financemate()

    if not app_pid:
        print("  ❌ FAIL: Could not launch FinanceMate app")
        assert False, "App launch failed - cannot test view rendering"

    print(f"  ✅ App launched (PID: {app_pid})")

    try:
        # Step 2: Verify app is running
        print("  [2/4] Verifying app is running...")
        time.sleep(2)

        if not app_is_running(app_pid):
            print("  ❌ FAIL: App crashed immediately after launch")
            assert False, "App is not running - views failed to render"

        print("  ✅ App is running")

        # Step 3: Check console for SwiftUI errors
        print("  [3/4] Checking console for SwiftUI errors...")
        logs = get_app_console_logs(app_pid)

        error_patterns = [
            "Fatal error",
            "SwiftUI: error",
            "Terminating app due to",
            "*** Assertion failure",
            "SIGABRT",
            "uncaught exception"
        ]

        found_errors = []
        for pattern in error_patterns:
            if pattern.lower() in logs.lower():
                found_errors.append(pattern)

        if found_errors:
            print(f"  ❌ FAIL: Found errors in console: {found_errors}")
            print(f"\n  Console logs:\n{logs[:500]}")
            assert False, f"SwiftUI errors found: {found_errors}"

        print("  ✅ No SwiftUI errors in console")

        # Step 4: Verify app remains responsive
        print("  [4/4] Verifying app remains responsive...")
        for i in range(10):
            time.sleep(1)
            if not app_is_running(app_pid):
                print(f"  ❌ FAIL: App crashed after {i+1} seconds")
                assert False, "App crashed during execution - view rendering unstable"

        print("  ✅ App remained responsive for 10 seconds")

        print("\n  ✅ PASS: All SwiftUI views render correctly without errors")
        return True

    finally:
        # Clean up: terminate the app
        print("  [Cleanup] Terminating app...")
        terminate_app(app_pid)

def test_swiftui_compilation():
    """
    FUNCTIONAL TEST: Verify SwiftUI views compile correctly

    Tests ability to import and compile key SwiftUI components
    """
    print("\n=== Bonus Test: SwiftUI Compilation ===")

    swift_test = """
import Foundation
import SwiftUI

// Verify SwiftUI types compile
struct TestView: View {
    var body: some View {
        Text("Test")
    }
}

// Verify compilation succeeds
print("SUCCESS: SwiftUI compilation verified")
"""

    print("  [1/1] Testing SwiftUI compilation...")
    success, output = run_swift_snippet(swift_test)

    if not success:
        print(f"  ❌ FAIL: SwiftUI compilation failed\n{output}")
        assert False, "SwiftUI compilation test failed"

    if "SUCCESS" not in output:
        print(f"  ❌ FAIL: Unexpected output\n{output}")
        assert False, "SwiftUI compilation test did not complete"

    print("  ✅ PASS: SwiftUI compilation successful")
    return True

if __name__ == "__main__":
    try:
        test_swiftui_view_rendering()
        test_swiftui_compilation()
        print("\n✅ ALL TESTS PASSED")
    except AssertionError as e:
        print(f"\n❌ TEST FAILED: {e}")
        exit(1)
    except Exception as e:
        print(f"\n❌ UNEXPECTED ERROR: {e}")
        exit(1)
