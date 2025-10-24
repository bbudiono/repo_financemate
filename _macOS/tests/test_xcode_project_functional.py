#!/usr/bin/env python3
"""
Xcode Project Functional Validation
Converted from grep-based test_xcode_project_structure

PRINCIPLES:
- 100% functional validation (not text search)
- Tests real Xcode project capabilities
- Validates scheme configuration
- Verifies build settings
"""

import subprocess
import sys
from pathlib import Path

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
XCODE_PROJECT = MACOS_ROOT / "FinanceMate.xcodeproj"

class XcodeProjectFunctionalTest:
    """Functional tests for Xcode project structure"""

    def __init__(self):
        self.test_results = []
        self.passed = 0
        self.failed = 0

    def log_result(self, test_name: str, passed: bool, message: str = ""):
        """Log test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        self.test_results.append({
            'test': test_name,
            'status': status,
            'message': message
        })

        if passed:
            self.passed += 1
        else:
            self.failed += 1

        print(f"{status}: {test_name}")
        if message:
            print(f"  → {message}")

    def test_xcode_project_can_list_schemes(self):
        """Test 1: Verify xcodeproj file is valid and can list schemes"""
        try:
            result = subprocess.run([
                "xcodebuild", "-list",
                "-project", str(XCODE_PROJECT)
            ], capture_output=True, timeout=30)

            output = result.stdout.decode()

            # Verify FinanceMate scheme exists
            has_scheme = "FinanceMate" in output

            # Verify project structure is valid
            has_targets = "Targets:" in output

            if result.returncode == 0 and has_scheme and has_targets:
                self.log_result(
                    "xcode_project_can_list_schemes",
                    True,
                    f"Valid Xcode project with FinanceMate scheme"
                )
                return True
            else:
                self.log_result(
                    "xcode_project_can_list_schemes",
                    False,
                    f"Invalid project structure or missing scheme"
                )
                return False

        except subprocess.TimeoutExpired:
            self.log_result(
                "xcode_project_can_list_schemes",
                False,
                "xcodebuild -list timed out"
            )
            return False
        except Exception as e:
            self.log_result(
                "xcode_project_can_list_schemes",
                False,
                f"Error: {str(e)}"
            )
            return False

    def test_scheme_configuration(self):
        """Test 2: Verify scheme has proper build settings"""
        try:
            result = subprocess.run([
                "xcodebuild", "-showBuildSettings",
                "-project", str(XCODE_PROJECT),
                "-scheme", "FinanceMate"
            ], capture_output=True, timeout=30)

            output = result.stdout.decode()

            # Verify critical build settings
            checks = {
                'PRODUCT_NAME': "PRODUCT_NAME = FinanceMate" in output,
                'SWIFT_VERSION': "SWIFT_VERSION" in output,
                'MACOSX_DEPLOYMENT_TARGET': "MACOSX_DEPLOYMENT_TARGET" in output,
                'PRODUCT_BUNDLE_IDENTIFIER': "PRODUCT_BUNDLE_IDENTIFIER" in output
            }

            all_passed = all(checks.values())

            if result.returncode == 0 and all_passed:
                self.log_result(
                    "scheme_configuration",
                    True,
                    f"All critical build settings present: {list(checks.keys())}"
                )
                return True
            else:
                missing = [k for k, v in checks.items() if not v]
                self.log_result(
                    "scheme_configuration",
                    False,
                    f"Missing build settings: {missing}"
                )
                return False

        except subprocess.TimeoutExpired:
            self.log_result(
                "scheme_configuration",
                False,
                "xcodebuild -showBuildSettings timed out"
            )
            return False
        except Exception as e:
            self.log_result(
                "scheme_configuration",
                False,
                f"Error: {str(e)}"
            )
            return False

    def test_project_targets(self):
        """Test 3: Verify project has expected targets"""
        try:
            result = subprocess.run([
                "xcodebuild", "-list",
                "-project", str(XCODE_PROJECT)
            ], capture_output=True, timeout=30)

            output = result.stdout.decode()

            # Verify main target exists
            has_main_target = "FinanceMate" in output

            if result.returncode == 0 and has_main_target:
                self.log_result(
                    "project_targets",
                    True,
                    "FinanceMate target exists"
                )
                return True
            else:
                self.log_result(
                    "project_targets",
                    False,
                    "FinanceMate target not found"
                )
                return False

        except subprocess.TimeoutExpired:
            self.log_result(
                "project_targets",
                False,
                "xcodebuild -list timed out"
            )
            return False
        except Exception as e:
            self.log_result(
                "project_targets",
                False,
                f"Error: {str(e)}"
            )
            return False

    def test_project_file_exists(self):
        """Test 4: Verify project.pbxproj file exists and is readable"""
        pbxproj = XCODE_PROJECT / "project.pbxproj"

        if not pbxproj.exists():
            self.log_result(
                "project_file_exists",
                False,
                "project.pbxproj not found"
            )
            return False

        # Try to read first line
        try:
            with open(pbxproj, 'r') as f:
                first_line = f.readline()

            # Verify it's a valid pbxproj file
            if "// !$*UTF8*$!" in first_line:
                self.log_result(
                    "project_file_exists",
                    True,
                    f"Valid pbxproj file: {pbxproj.stat().st_size} bytes"
                )
                return True
            else:
                self.log_result(
                    "project_file_exists",
                    False,
                    "Invalid pbxproj file format"
                )
                return False

        except Exception as e:
            self.log_result(
                "project_file_exists",
                False,
                f"Error reading pbxproj: {str(e)}"
            )
            return False

    def run_all_tests(self):
        """Execute all functional tests"""
        print("\n" + "=" * 60)
        print("XCODE PROJECT FUNCTIONAL VALIDATION")
        print("=" * 60 + "\n")

        # Run tests
        self.test_project_file_exists()
        self.test_xcode_project_can_list_schemes()
        self.test_scheme_configuration()
        self.test_project_targets()

        # Summary
        print("\n" + "-" * 60)
        print(f"RESULTS: {self.passed} passed, {self.failed} failed")
        print("-" * 60)

        return self.failed == 0

def main():
    """Main test execution"""
    tester = XcodeProjectFunctionalTest()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
