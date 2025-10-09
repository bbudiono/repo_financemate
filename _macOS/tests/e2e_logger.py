#!/usr/bin/env python3
"""
E2E Test Logger - Simple logging functionality
"""

from pathlib import Path
from datetime import datetime
from typing import Dict

TEST_LOG_DIR = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/test_output")
TEST_LOG_DIR.mkdir(parents=True, exist_ok=True)


class E2ETestLogger:
    """Centralized test logging with timestamp"""

    def __init__(self):
        self.log_file = TEST_LOG_DIR / f"e2e_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
        self.test_results = []

    def log(self, test_name: str, status: str, message: str = ""):
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_entry = f"[{timestamp}] {test_name}: {status} - {message}\n"

        with open(self.log_file, 'a') as f:
            f.write(log_entry)

        self.test_results.append({
            'test': test_name,
            'status': status,
            'message': message,
            'timestamp': timestamp
        })

        print(f"[{status}] {test_name}: {message}")

    def get_summary(self) -> Dict:
        passed = len([r for r in self.test_results if r['status'] == 'PASS'])
        total = len(self.test_results)
        return {
            'passed': passed,
            'total': total,
            'success_rate': (passed / total * 100) if total > 0 else 0,
            'results': self.test_results
        }