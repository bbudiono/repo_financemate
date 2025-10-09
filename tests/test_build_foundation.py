#!/usr/bin/env python3
"""FinanceMate Build Tests - Foundation validation"""

import subprocess
import os
from pathlib import Path

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

def test_build():
    """Build must succeed"""
    os.chdir(MACOS_ROOT)
    result = subprocess.run(["xcodebuild", "-scheme", "FinanceMate", "-configuration", "Debug",
                           "-destination", "platform=macOS", "build"],
                           capture_output=True, text=True)
    return "BUILD SUCCEEDED" in result.stdout

def test_kiss():
    """Swift files under 200 lines"""
    count = 0
    for root, dirs, files in os.walk(MACOS_ROOT):
        for file in files:
            if file.endswith('.swift'):
                with open(os.path.join(root, file)) as f:
                    if len(f.readlines()) > 200:
                        count += 1
    return count == 0

def test_security():
    """No fatalError calls"""
    count = 0
    for root, dirs, files in os.walk(MACOS_ROOT / "FinanceMate"):
        for file in files:
            if file.endswith('.swift'):
                with open(os.path.join(root, file)) as f:
                    if 'fatalError(' in f.read():
                        count += 1
    return count == 0

if __name__ == "__main__":
    tests = [test_build, test_kiss, test_security]
    results = [test() for test in tests]
    passed = sum(results)
    print(f"Tests passed: {passed}/{len(results)}")