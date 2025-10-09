#!/usr/bin/env python3
"""
E2E Test Utilities - Simple helper functions
"""

import subprocess
import time
import psutil
from pathlib import Path
from typing import Tuple, Optional


def run_command(cmd: list, timeout: int = 60, cwd: Optional[Path] = None) -> Tuple[bool, str, str]:
    """Run command with timeout and return success, stdout, stderr"""
    try:
        result = subprocess.run(
            cmd,
            timeout=timeout,
            capture_output=True,
            text=True,
            cwd=cwd
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"


def find_finance_app() -> Optional[Path]:
    """Find the FinanceMate.app in derived data or build directories"""
    macos_root = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS")
    supported_paths = [
        Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Products/Debug/FinanceMate.app"),
        macos_root / "build/Build/Products/Debug/FinanceMate.app"
    ]

    for pattern in supported_paths:
        if pattern.exists():
            return pattern

        if '*' in str(pattern):
            import glob
            matches = glob.glob(str(pattern))
            if matches:
                return Path(matches[0])

    return None


def kill_existing_finance_processes() -> bool:
    """Kill any existing FinanceMate processes"""
    killed_count = 0
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            if proc.info['name'] == 'FinanceMate':
                proc.kill()
                killed_count += 1
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    if killed_count > 0:
        time.sleep(2)
    return killed_count > 0


def launch_finance_app() -> Tuple[bool, Optional[int]]:
    """Launch FinanceMate and return success and PID"""
    finance_app = find_finance_app()
    if not finance_app:
        return False, None

    kill_existing_finance_processes()

    success, _, _ = run_command(["open", "-n", str(finance_app)], timeout=30)

    if not success:
        return False, None

    time.sleep(5)
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            if proc.info['name'] == 'FinanceMate':
                return True, proc.info['pid']
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass

    return False, None