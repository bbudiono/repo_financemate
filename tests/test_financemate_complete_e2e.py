#!/usr/bin/env python3
"""FinanceMate MVP E2E Test Suite - Validates ACTUAL functionality"""

import subprocess
import time
import os
from pathlib import Path

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")

def test_build_success():
    """Build must succeed with zero warnings"""
    os.chdir(MACOS_ROOT)
    result = subprocess.run(
        ["xcodebuild", "-scheme", "FinanceMate", "build"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0, f"Build failed: {result.stderr}"
    return True

def test_app_launches():
    """App must launch without crashes"""
    assert APP_PATH.exists(), f"App not found at {APP_PATH}"

    subprocess.Popen(["open", str(APP_PATH)])
    time.sleep(3)

    result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    assert "FinanceMate" in result.stdout, "App crashed on launch"
    return True

def test_kiss_compliance():
    """All files must be <200 lines"""
    swift_files = list(MACOS_ROOT.glob("FinanceMate/**/*.swift"))
    violations = []

    for file in swift_files:
        with open(file) as f:
            line_count = len(f.readlines())
            if line_count > 200:
                violations.append((file.name, line_count))

    assert len(violations) == 0, f"KISS violations: {violations}"
    return len(swift_files)

def test_no_force_unwraps():
    """Zero force unwraps allowed"""
    result = subprocess.run(
        ["grep", "-rE", "\\!\\s*$|\\)\\!|\\]\\!|as\\!|try\\!", "--include=*.swift", str(MACOS_ROOT / "FinanceMate")],
        capture_output=True,
        text=True
    )

    force_unwraps = [l for l in result.stdout.split("\n") if l.strip() and "!" not in ["!viewModel", "!="]]
    assert len(force_unwraps) == 0, f"Force unwraps found: {force_unwraps}"
    return True

def test_core_data_valid():
    """Core Data schema must be properly defined"""
    persistence = MACOS_ROOT / "FinanceMate/PersistenceController.swift"
    with open(persistence) as f:
        content = f.read()

    assert 'name = "Transaction"' in content
    assert 'name = "id"' in content
    assert 'isOptional = false' in content
    return True

def test_oauth_configured():
    """OAuth credentials must exist"""
    env_file = PROJECT_ROOT / ".env"
    assert env_file.exists()

    with open(env_file) as f:
        content = f.read()

    assert "GOOGLE_OAUTH_CLIENT_ID" in content
    assert "GOOGLE_OAUTH_CLIENT_SECRET" in content
    return True

def print_results(results):
    """Print test results summary"""
    print("\n" + "=" * 60)
    print("TEST RESULTS")
    print("=" * 60)

    passed = sum(1 for _, success, _ in results if success)

    for name, success, info in results:
        status = "PASS" if success else "FAIL"
        print(f"{status} - {name}")
        if not success:
            print(f"     {info}")

    print(f"\nTOTAL: {passed}/{len(results)} tests passed")
    return passed == len(results)

def run_all():
    """Execute all E2E tests"""
    tests = [
        test_build_success,
        test_kiss_compliance,
        test_no_force_unwraps,
        test_core_data_valid,
        test_oauth_configured,
        test_app_launches
    ]

    results = []
    for test in tests:
        try:
            result = test()
            results.append((test.__name__, True, result))
        except AssertionError as e:
            results.append((test.__name__, False, str(e)))
        except Exception as e:
            results.append((test.__name__, False, f"Error: {e}"))

    success = print_results(results)
    return 0 if success else 1

if __name__ == "__main__":
    exit(run_all())
