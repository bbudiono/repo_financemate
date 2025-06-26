#!/usr/bin/env python3
"""
Parse .xcresult bundle to extract test results
Usage: python3 parse_xcresult.py <path_to_xcresult>
"""

import json
import subprocess
import sys
import os

def run_xcrun_command(args):
    """Run xcrun command and return output"""
    cmd = ['xcrun', 'xcresulttool'] + args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running xcrun: {e.stderr}")
        return None

def parse_xcresult(xcresult_path):
    """Parse .xcresult bundle and extract test information"""
    if not os.path.exists(xcresult_path):
        print(f"Error: {xcresult_path} does not exist")
        return None
    
    # Get the result bundle object
    result_json = run_xcrun_command(['get', '--path', xcresult_path, '--format', 'json'])
    if not result_json:
        return None
    
    try:
        result_data = json.loads(result_json)
    except json.JSONDecodeError:
        print("Error: Failed to parse JSON from xcresult")
        return None
    
    # Extract test results
    test_results = {
        'total_tests': 0,
        'passed_tests': 0,
        'failed_tests': 0,
        'test_details': [],
        'screenshots': []
    }
    
    # Parse actions (test runs)
    if 'actions' in result_data:
        actions = result_data['actions'].get('_values', [])
        for action in actions:
            if action.get('_type', {}).get('_name') == 'ActionRecord':
                parse_action_record(action, test_results)
    
    return test_results

def parse_action_record(action, test_results):
    """Parse an action record to extract test information"""
    # Get the test summary
    action_result = action.get('actionResult', {})
    tests_ref = action_result.get('testsRef', {})
    
    if tests_ref.get('id', {}).get('_value'):
        # We would need to make another call to get the test details
        # For now, parse what we can from the action result
        
        test_summary = action_result.get('testSummary', {})
        if test_summary:
            test_results['total_tests'] = test_summary.get('testCount', 0)
            test_results['failed_tests'] = test_summary.get('failureCount', 0)
            test_results['passed_tests'] = test_results['total_tests'] - test_results['failed_tests']

def generate_markdown_report(test_results):
    """Generate a markdown report from test results"""
    report = f"""# Test Results Report

## Summary
- **Total Tests**: {test_results['total_tests']}
- **Passed**: {test_results['passed_tests']} ✅
- **Failed**: {test_results['failed_tests']} ❌
- **Pass Rate**: {(test_results['passed_tests'] / test_results['total_tests'] * 100) if test_results['total_tests'] > 0 else 0:.1f}%

## Test Details
"""
    
    if test_results['test_details']:
        for test in test_results['test_details']:
            status_emoji = "✅" if test['passed'] else "❌"
            report += f"- {status_emoji} **{test['name']}** ({test['duration']:.2f}s)\n"
            if test.get('failure_message'):
                report += f"  - Failure: {test['failure_message']}\n"
    
    if test_results['screenshots']:
        report += "\n## Screenshots Captured\n"
        for screenshot in test_results['screenshots']:
            report += f"- {screenshot}\n"
    
    return report

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 parse_xcresult.py <path_to_xcresult>")
        sys.exit(1)
    
    xcresult_path = sys.argv[1]
    print(f"Parsing {xcresult_path}...")
    
    test_results = parse_xcresult(xcresult_path)
    if not test_results:
        print("Failed to parse test results")
        sys.exit(1)
    
    # Generate report
    report = generate_markdown_report(test_results)
    
    # Save report
    report_path = "test_results_report.md"
    with open(report_path, 'w') as f:
        f.write(report)
    
    print(f"Report saved to {report_path}")
    print(f"Summary: {test_results['passed_tests']}/{test_results['total_tests']} tests passed")
    
    # Exit with non-zero if tests failed
    sys.exit(0 if test_results['failed_tests'] == 0 else 1)

if __name__ == "__main__":
    main()