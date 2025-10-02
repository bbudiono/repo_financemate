#!/usr/bin/env python3
"""Run comprehensive E2E validation - 3-5 times as per requirements"""

import subprocess
import time
from datetime import datetime
from pathlib import Path
import json

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")

def run_single_test(iteration):
    """Run a single E2E test iteration"""
    print(f"\n{'='*80}")
    print(f"ITERATION {iteration} - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*80}")

    # Run main E2E test
    result = subprocess.run(
        ["python3", "tests/test_financemate_complete_e2e.py"],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True
    )

    # Extract summary from output
    lines = result.stdout.split('\n')
    summary_line = None
    for line in lines:
        if 'SUMMARY:' in line:
            summary_line = line
            break

    return {
        'iteration': iteration,
        'timestamp': datetime.now().isoformat(),
        'return_code': result.returncode,
        'summary': summary_line,
        'passed': result.returncode == 0
    }

def run_ui_tests(iteration):
    """Run UI component tests"""
    result = subprocess.run(
        ["python3", "tests/test_ui_components_comprehensive.py"],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True
    )

    lines = result.stdout.split('\n')
    summary_line = None
    for line in lines:
        if 'SUMMARY:' in line:
            summary_line = line
            break

    return {
        'iteration': iteration,
        'test_type': 'UI Components',
        'summary': summary_line,
        'passed': result.returncode == 0
    }

def capture_app_screenshot(name):
    """Capture app window screenshot for validation"""
    timestamp = datetime.now().strftime('%H%M%S')
    output_dir = PROJECT_ROOT / "test_output" / "validation_screenshots"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / f"{name}_{timestamp}.png"

    try:
        subprocess.run(["screencapture", "-o", "-w", str(output_file)],
                      timeout=5, capture_output=True)
        return str(output_file)
    except:
        return None

def main():
    """Run comprehensive validation"""
    print(f"\n{'#'*80}")
    print("FINANCEMATE COMPREHENSIVE VALIDATION SUITE")
    print("Testing 5 times as per P0 requirements")
    print(f"{'#'*80}")

    results = {
        'start_time': datetime.now().isoformat(),
        'e2e_results': [],
        'ui_results': [],
        'screenshots': []
    }

    # Run E2E tests 5 times
    print("\n RUNNING E2E TESTS (5 iterations)")
    for i in range(1, 6):
        result = run_single_test(i)
        results['e2e_results'].append(result)
        print(f"  Iteration {i}: {' PASSED' if result['passed'] else ' FAILED'}")
        if result['summary']:
            print(f"    {result['summary']}")
        time.sleep(2)  # Brief pause between runs

    # Run UI tests 3 times
    print("\n RUNNING UI COMPONENT TESTS (3 iterations)")
    for i in range(1, 4):
        result = run_ui_tests(i)
        results['ui_results'].append(result)
        print(f"  Iteration {i}: {' PASSED' if result['passed'] else ' FAILED'}")
        if result['summary']:
            print(f"    {result['summary']}")
        time.sleep(1)

    # Capture screenshots for visual validation
    print("\n CAPTURING SCREENSHOTS FOR VISUAL VALIDATION")
    screenshot_tests = [
        "dashboard_view",
        "transactions_view",
        "gmail_view",
        "settings_view"
    ]

    for test in screenshot_tests:
        screenshot = capture_app_screenshot(test)
        if screenshot:
            results['screenshots'].append(screenshot)
            print(f"   Captured: {test}")
        else:
            print(f"  ️  Failed to capture: {test}")

    # Calculate overall stats
    e2e_passed = sum(1 for r in results['e2e_results'] if r['passed'])
    ui_passed = sum(1 for r in results['ui_results'] if r['passed'])

    results['summary'] = {
        'e2e_pass_rate': f"{e2e_passed}/5 ({e2e_passed*100/5:.1f}%)",
        'ui_pass_rate': f"{ui_passed}/3 ({ui_passed*100/3:.1f}%)",
        'screenshots_captured': len(results['screenshots']),
        'end_time': datetime.now().isoformat()
    }

    # Save results
    report_file = PROJECT_ROOT / "test_output" / f"comprehensive_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    report_file.parent.mkdir(parents=True, exist_ok=True)
    with open(report_file, 'w') as f:
        json.dump(results, f, indent=2)

    # Print final summary
    print(f"\n{'='*80}")
    print("COMPREHENSIVE VALIDATION SUMMARY")
    print(f"{'='*80}")
    print(f"E2E Tests: {results['summary']['e2e_pass_rate']}")
    print(f"UI Tests: {results['summary']['ui_pass_rate']}")
    print(f"Screenshots: {results['summary']['screenshots_captured']} captured")
    print(f"\nFull report saved to: {report_file}")

    # Overall pass/fail
    overall_pass = e2e_passed == 5  # All E2E tests must pass
    print(f"\n{' OVERALL: PASSED' if overall_pass else ' OVERALL: FAILED'}")

    return 0 if overall_pass else 1

if __name__ == "__main__":
    exit(main())