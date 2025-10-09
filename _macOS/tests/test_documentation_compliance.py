#!/usr/bin/env python3
"""
Test Documentation Compliance - P0 Violation Resolution

Purpose: Validate documentation structure compliance for FinanceMate project
Issues & Complexity Summary: Critical P0 violations need immediate resolution
Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (file validation, navigation structure)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
AI Pre-Task Self-Assessment: 85%
Problem Estimate: 80%
Initial Code Complexity Estimate: 70%
Final Code Complexity: 75%
Overall Result Score: 90%
Key Variances/Learnings: Documentation validation requires careful file structure analysis
Last Updated: 2025-10-07

This test validates that all documentation files comply with P0 requirements:
1. Navigation structure documentation exists for API.md, BUILD_FAILURES.md, CODE_QUALITY.md
2. Code quality compliance (file size limits, structure requirements)
3. TECH-DEBT items are properly tracked and resolved

Test follows atomic TDD methodology: RED → GREEN → REFACTOR
"""

import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

class DocumentationComplianceValidator:
    """Validates documentation compliance with P0 requirements"""

    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.docs_dir = self.project_root / "docs"
        self.violations: List[str] = []
        self.passed_checks: List[str] = []

    def log_failure(self, test_name: str, message: str) -> None:
        """Log test failure for debugging"""
        self.violations.append(f"FAILED: {test_name} - {message}")
        print(f" FAILED: {test_name} - {message}")

    def log_success(self, test_name: str, message: str) -> None:
        """Log test success for verification"""
        self.passed_checks.append(f"PASSED: {test_name} - {message}")
        print(f" PASSED: {test_name} - {message}")

    def test_navigation_documentation_exists(self) -> bool:
        """Test: Navigation documentation exists for required files"""
        test_name = "Navigation Documentation Exists"
        required_files = ["API.md", "BUILD_FAILURES.md", "CODE_QUALITY.md"]
        navigation_sections = ["## Navigation Structure", "### Routes/Pages", "### Authentication Requirements"]

        all_passed = True

        for file_name in required_files:
            file_path = self.docs_dir / file_name

            if not file_path.exists():
                self.log_failure(test_name, f"Required file {file_name} does not exist")
                all_passed = False
                continue

            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Check for navigation structure
            nav_found = any(nav_section in content for nav_section in navigation_sections)

            if not nav_found:
                self.log_failure(test_name, f"Navigation documentation missing in {file_name}")
                all_passed = False
            else:
                self.log_success(test_name, f"Navigation documentation found in {file_name}")

        return all_passed

    def test_code_quality_compliance(self) -> bool:
        """Test: Documentation files comply with code quality standards"""
        test_name = "Code Quality Compliance"
        max_file_size = 500  # lines
        required_files = ["API.md", "BUILD_FAILURES.md", "CODE_QUALITY.md"]

        all_passed = True

        for file_name in required_files:
            file_path = self.docs_dir / file_name

            if not file_path.exists():
                continue  # Already tested above

            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            actual_lines = len(lines)
            if actual_lines > max_file_size:
                self.log_failure(test_name, f"{file_name} exceeds {max_file_size} lines ({actual_lines} lines)")
                all_passed = False
            else:
                self.log_success(test_name, f"{file_name} within size limit ({actual_lines} lines)")

        return all_passed

    def test_tasks_debt_tracking(self) -> bool:
        """Test: TECH-DEBT items are properly tracked in TASKS.md"""
        test_name = "TECH-DEBT Tracking"
        tasks_file = self.docs_dir / "TASKS.md"

        if not tasks_file.exists():
            self.log_failure(test_name, "TASKS.md does not exist")
            return False

        with open(tasks_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Check for active TECH-DEBT items
        tech_debt_pattern = r'### TECH-DEBT-[a-f0-9]+:'
        tech_debt_matches = re.findall(tech_debt_pattern, content)

        if len(tech_debt_matches) > 0:
            self.log_failure(test_name, f"Found {len(tech_debt_matches)} unresolved TECH-DEBT items")
            return False
        else:
            self.log_success(test_name, "No unresolved TECH-DEBT items found")
            return True

    def test_blueprint_compliance(self) -> bool:
        """Test: Documentation references BLUEPRINT.md compliance"""
        test_name = "BLUEPRINT Compliance"
        required_files = ["API.md", "BUILD_FAILURES.md", "CODE_QUALITY.md"]

        all_passed = True

        for file_name in required_files:
            file_path = self.docs_dir / file_name

            if not file_path.exists():
                continue

            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            if "BLUEPRINT.md" not in content:
                self.log_failure(test_name, f"{file_name} missing BLUEPRINT.md reference")
                all_passed = False
            else:
                self.log_success(test_name, f"{file_name} references BLUEPRINT.md")

        return all_passed

    def run_all_tests(self) -> Tuple[bool, List[str], List[str]]:
        """Run all documentation compliance tests"""
        print(" Running Documentation Compliance Tests...")
        print("=" * 50)

        tests = [
            self.test_navigation_documentation_exists,
            self.test_code_quality_compliance,
            self.test_tasks_debt_tracking,
            self.test_blueprint_compliance
        ]

        all_passed = True
        for test in tests:
            try:
                result = test()
                all_passed = all_passed and result
            except Exception as e:
                self.log_failure("Test Execution Error", str(e))
                all_passed = False

        print("=" * 50)
        print(f"Tests Passed: {len(self.passed_checks)}")
        print(f"Tests Failed: {len(self.violations)}")

        return all_passed, self.passed_checks, self.violations

def main():
    """Main test execution"""
    # Use parent directory for docs/ folder (go up one level from _macOS to repo root)
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    # Actually need to go up one more level since we're in _macOS/tests/
    project_root = os.path.dirname(project_root)
    validator = DocumentationComplianceValidator(project_root)

    all_passed, passed_checks, violations = validator.run_all_tests()

    if not all_passed:
        print("\n P0 VIOLATIONS DETECTED:")
        for violation in violations:
            print(f"  - {violation}")
        print("\n DOCUMENTATION COMPLIANCE TEST FAILED")
        sys.exit(1)
    else:
        print("\n ALL DOCUMENTATION COMPLIANCE TESTS PASSED")
        print("P0 violations resolved successfully")
        sys.exit(0)

if __name__ == "__main__":
    main()