#!/usr/bin/env python3
"""FinanceMate MVP E2E Test Suite - Validates ACTUAL functionality"""

import subprocess
import time
import os
from pathlib import Path

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
APP_PATH = Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app")

def test_build():
    """Build must succeed"""
    os.chdir(MACOS_ROOT)
    result = subprocess.run(["xcodebuild", "-scheme", "FinanceMate", "build"], capture_output=True)
    assert result.returncode == 0
    return True

def test_kiss():
    """All files must be <200 lines"""
    for file in MACOS_ROOT.glob("FinanceMate/*.swift"):
        lines = len(open(file).readlines())
        assert lines < 200, f"{file.name}: {lines} lines"
    return True

def test_security():
    """No force unwraps or fatalError"""
    result = subprocess.run(["grep", "-r", "fatalError\\|)!", str(MACOS_ROOT / "FinanceMate")], capture_output=True, text=True)
    assert result.returncode != 0
    return True

def test_data_model():
    """Core Data schema valid"""
    persistence = MACOS_ROOT / "FinanceMate/PersistenceController.swift"
    content = open(persistence).read()
    assert 'name = "Transaction"' in content
    assert 'isOptional = false' in content
    return True

def test_config():
    """OAuth configured"""
    env = PROJECT_ROOT / ".env"
    content = open(env).read()
    assert "GOOGLE_OAUTH_CLIENT_ID" in content
    assert "apps.googleusercontent.com" in content
    return True

def test_launch():
    """App launches successfully"""
    assert APP_PATH.exists()
    subprocess.Popen(["open", str(APP_PATH)])
    time.sleep(3)
    result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    assert "FinanceMate" in result.stdout
    return True

def test_auth_files_exist():
    """Authentication files must exist"""
    auth_files = [
        "AuthenticationManager.swift",
        "LoginView.swift",
        "SettingsView.swift",
        "GmailOAuthHelper.swift"
    ]
    for file in auth_files:
        path = MACOS_ROOT / "FinanceMate" / file
        assert path.exists(), f"Missing auth file: {file}"
    return len(auth_files)

def run_all():
    """Run all tests"""
    tests = [test_build, test_kiss, test_security, test_data_model, test_config, test_auth_files_exist, test_launch]
    results = []

    for test in tests:
        try:
            test()
            results.append((test.__name__, True))
        except Exception as e:
            results.append((test.__name__, False, str(e)))

    passed = sum(1 for _, success, *_ in results if success)
    print(f"\n{passed}/{len(results)} tests passed")

    for name, success, *info in results:
        status = "PASS" if success else "FAIL"
        print(f"{status} - {name}")
        if info:
            print(f"  {info[0]}")

    return 0 if passed == len(results) else 1

if __name__ == "__main__":
    exit(run_all())
