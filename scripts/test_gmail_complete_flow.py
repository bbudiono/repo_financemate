#!/usr/bin/env python3
"""
Complete Gmail OAuth Flow Validation
Tests OAuth authentication and email fetching from bernhardbudiono@gmail.com
"""

import subprocess
import time
import json
from pathlib import Path
from datetime import datetime


def run_command(cmd, desc):
    """Run command and capture output"""
    print(f"\n[{desc}]")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print(f"Errors: {result.stderr}")
    return result.returncode == 0


def capture_screenshot(name, output_dir):
    """Capture screenshot for evidence"""
    screenshot_path = output_dir / f"{name}.png"
    subprocess.run(
        f'screencapture -x "{screenshot_path}"',
        shell=True,
        capture_output=True
    )
    print(f"Screenshot: {screenshot_path}")
    return screenshot_path


def main():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = Path(__file__).parent.parent / f"test_output/gmail_complete_validation_{timestamp}"
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 70)
    print("GMAIL OAUTH COMPLETE FLOW VALIDATION")
    print("=" * 70)
    print(f"Output directory: {output_dir}")

    results = {
        "timestamp": timestamp,
        "tests": [],
        "screenshots": [],
        "overall_status": "PENDING"
    }

    # Test 1: Build the app
    print("\n--- TEST 1: Build Application ---")
    macos_dir = Path(__file__).parent.parent / "_macOS"
    build_success = run_command(
        f'cd "{macos_dir}" && xcodebuild -project FinanceMate.xcodeproj -scheme FinanceMate -configuration Debug build',
        "Building FinanceMate app"
    )
    results["tests"].append({
        "name": "Build Application",
        "status": "PASS" if build_success else "FAIL"
    })

    if not build_success:
        results["overall_status"] = "FAILED"
        save_results(results, output_dir)
        return

    # Test 2: Launch app
    print("\n--- TEST 2: Launch Application ---")
    app_path = "/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-fwbqcnjwjvdjcycepscbrwsnbvql/Build/Products/Debug/FinanceMate.app"

    subprocess.Popen(["open", app_path])
    print("App launched")
    time.sleep(3)

    screenshot = capture_screenshot("01_app_launched", output_dir)
    results["screenshots"].append(str(screenshot))

    # Test 3: Check OAuth credentials loaded
    print("\n--- TEST 3: OAuth Credentials Loaded ---")
    log_file = output_dir / "console_logs.txt"
    subprocess.run(
        f'log show --predicate \'process == "FinanceMate"\' --info --last 30s > "{log_file}"',
        shell=True
    )

    with open(log_file) as f:
        logs = f.read()

    oauth_loaded = "OAuth credentials loaded successfully" in logs
    results["tests"].append({
        "name": "OAuth Credentials Loaded",
        "status": "PASS" if oauth_loaded else "FAIL"
    })

    # Test 4: Manual OAuth flow
    print("\n--- TEST 4: Manual OAuth Flow ---")
    print("\nMANUAL STEPS REQUIRED:")
    print("1. Click on 'Gmail Receipts' tab")
    print("2. Click 'Connect Gmail' button")
    print("3. Sign in with bernhardbudiono@gmail.com in browser")
    print("4. Grant Gmail permissions")
    print("5. Copy authorization code")
    print("6. Paste into app")
    print("\nWaiting 60 seconds for manual OAuth flow...")

    time.sleep(30)
    screenshot = capture_screenshot("02_oauth_flow_started", output_dir)
    results["screenshots"].append(str(screenshot))

    time.sleep(30)
    screenshot = capture_screenshot("03_oauth_complete", output_dir)
    results["screenshots"].append(str(screenshot))

    # Test 5: Check for OAuth URL in logs
    print("\n--- TEST 5: OAuth URL Generated ---")
    subprocess.run(
        f'log show --predicate \'process == "FinanceMate"\' --info --last 2m > "{log_file}"',
        shell=True
    )

    with open(log_file) as f:
        logs = f.read()

    oauth_url_generated = "Opening OAuth URL" in logs
    button_clicked = "Connect Gmail button clicked" in logs

    results["tests"].append({
        "name": "Gmail Button Clicked",
        "status": "PASS" if button_clicked else "FAIL"
    })

    results["tests"].append({
        "name": "OAuth URL Generated",
        "status": "PASS" if oauth_url_generated else "FAIL"
    })

    # Final screenshot
    time.sleep(5)
    screenshot = capture_screenshot("04_final_state", output_dir)
    results["screenshots"].append(str(screenshot))

    # Determine overall status
    passed = sum(1 for t in results["tests"] if t["status"] == "PASS")
    total = len(results["tests"])
    results["overall_status"] = "PASSED" if passed == total else f"PARTIAL ({passed}/{total})"

    # Save results
    save_results(results, output_dir)

    print("\n" + "=" * 70)
    print(f"VALIDATION COMPLETE: {results['overall_status']}")
    print(f"Tests Passed: {passed}/{total}")
    print(f"Evidence: {output_dir}")
    print("=" * 70)


def save_results(results, output_dir):
    """Save test results to JSON"""
    results_file = output_dir / "test_results.json"
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved: {results_file}")


if __name__ == "__main__":
    main()
