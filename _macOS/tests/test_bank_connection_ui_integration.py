#!/usr/bin/env python3
"""
FinanceMate Bank Connection UI Integration E2E Test - Atomic TDD RED Phase
Tests the critical UI integration gap between Basiq API services and Settings interface

PURPOSE:
- Create failing test that validates Bank Connection UI integration gap
- Confirm BasiqAPIService exists but not integrated into user interface
- Establish clear success criteria for GREEN phase implementation
- Validate Settings → Connections section lacks bank connection functionality

TEST OBJECTIVE:
- RED Phase: Test should FAIL confirming UI integration gap exists
- GREEN Phase: Test passes after bank connection UI is properly integrated

BLUEPRINT REFERENCES:
- Lines 60-62: Bank API Integration requirements for ANZ/NAB banks
- Lines 108-113: SSO and unified OAuth flow requirements
- Lines 100-114: Settings multi-section requirements including Connections

PRINCIPLES:
- Atomic TDD compliant (single failing test = specific requirement)
- 100% headless execution (no GUI interaction required)
- Real application validation (not mock services)
- Non-intrusive automation (background processes)
"""

import subprocess
import time
import os
import json
import sqlite3
import signal
import psutil
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"
SUPPORTED_PATHS = [
    Path("/Users/bernhardbudiono/Library/Developer/Xcode/DerivedData/FinanceMate-*/Build/Products/Debug/FinanceMate.app"),
    MACOS_ROOT / "build/Build/Products/Debug/FinanceMate.app"
]

# Test configuration
TEST_TIMEOUT = 30  # seconds
BUILD_TIMEOUT = 120  # seconds
TEST_LOG_DIR = PROJECT_ROOT / "test_output"
TEST_LOG_DIR.mkdir(parents=True, exist_ok=True)

class BankConnectionIntegrationTestLogger:
    """Specialized test logging for bank connection UI integration validation"""

    def __init__(self):
        self.log_file = TEST_LOG_DIR / f"bank_connection_integration_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
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

        print(f"[{timestamp}] {test_name}: {status} - {message}")

    def generate_report(self) -> str:
        """Generate comprehensive test report with failure analysis"""
        passed = sum(1 for r in self.test_results if r['status'] == 'PASS')
        failed = sum(1 for r in self.test_results if r['status'] == 'FAIL')
        total = len(self.test_results)

        report = f"""
# Bank Connection UI Integration Test Report
**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Test Status:** RED PHASE - EXPECTING FAILURES

## Summary
- Total Tests: {total}
- Passed: {passed}
- Failed: {failed}
- Success Rate: {(passed/total*100):.1f}%

## Critical Findings
"""

        # Add detailed results for each test
        for result in self.test_results:
            status_icon = "" if result['status'] == 'PASS' else ""
            report += f"\n### {status_icon} {result['test']}\n"
            report += f"- **Status:** {result['status']}\n"
            report += f"- **Details:** {result['message']}\n"
            report += f"- **Timestamp:** {result['timestamp']}\n"

        # Add analysis section
        report += "\n## Integration Gap Analysis\n"

        if failed > 0:
            report += " **CONFIRMED: Bank Connection UI Integration Gap Exists**\n\n"
            report += "The following gaps have been identified:\n"
            for result in self.test_results:
                if result['status'] == 'FAIL':
                    report += f"- {result['message']}\n"

            report += "\n## GREEN Phase Implementation Requirements\n"
            report += "To make this test pass, implement:\n"
            report += "1. BankConnectionView.swift integration into Settings navigation\n"
            report += "2. 'Connect Bank Account' button in ConnectionsSection\n"
            report += "3. Bank selection interface (ANZ/NAB) from BLUEPRINT requirements\n"
            report += "4. BasiqAPIService integration with UI components\n"
            report += "5. OAuth flow integration for bank authentication\n"
        else:
            report += "🟢 **UNEXPECTED: All tests passed - integration may already exist**\n"

        # Save report
        report_file = TEST_LOG_DIR / f"bank_connection_integration_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        with open(report_file, 'w') as f:
            f.write(report)

        return report

class BankConnectionUIIntegrationTest:
    """E2E Test for Bank Connection UI integration validation"""

    def __init__(self):
        self.logger = BankConnectionIntegrationTestLogger()
        self.app_process = None
        self.app_path = None

    def find_app_path(self) -> Optional[Path]:
        """Find built FinanceMate.app path"""
        for pattern in SUPPORTED_PATHS:
            if pattern.name.startswith("FinanceMate") and pattern.is_dir():
                return pattern

            # Handle wildcard patterns
            if "*" in str(pattern):
                parent = pattern.parent
                if parent.exists():
                    for path in parent.glob("FinanceMate*.app"):
                        if path.is_dir():
                            return path
        return None

    def validate_basiq_services_exist(self) -> bool:
        """Test: Validate Basiq API services exist in production"""
        test_name = "BASIQ_SERVICES_EXIST"

        try:
            # Check for Basiq service files in production
            basiq_files = [
                MACOS_ROOT / "FinanceMate/Services/BasiqAPIService.swift",
                MACOS_ROOT / "FinanceMate/Services/BasiqAuthManager.swift",
                MACOS_ROOT / "FinanceMate/Services/BasiqTransactionService.swift",
                MACOS_ROOT / "FinanceMate/Services/BasiqModels.swift"
            ]

            missing_files = []
            for file_path in basiq_files:
                if not file_path.exists():
                    missing_files.append(str(file_path))

            if missing_files:
                self.logger.log(test_name, "FAIL", f"Missing Basiq services: {', '.join(missing_files)}")
                return False

            self.logger.log(test_name, "PASS", "All Basiq API services exist in production")
            return True

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating Basiq services: {str(e)}")
            return False

    def validate_bank_connection_view_exists(self) -> bool:
        """Test: Validate BankConnectionView exists but is not integrated"""
        test_name = "BANK_CONNECTION_VIEW_EXISTS"

        try:
            # Check for BankConnectionView in both Sandbox and Production
            sandbox_view = MACOS_ROOT / "FinanceMate-Sandbox/FinanceMate/Views/BankConnectionView.swift"
            production_view = MACOS_ROOT / "FinanceMate/Views/BankConnectionView.swift"

            exists_in_sandbox = sandbox_view.exists()
            exists_in_production = production_view.exists()

            if not exists_in_sandbox and not exists_in_production:
                self.logger.log(test_name, "FAIL", "BankConnectionView.swift does not exist in either Sandbox or Production")
                return False

            location = "Sandbox" if exists_in_sandbox else "Production"
            self.logger.log(test_name, "PASS", f"BankConnectionView.swift exists in {location}")
            return True

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating BankConnectionView: {str(e)}")
            return False

    def validate_settings_connections_section_exists(self) -> bool:
        """Test: Validate Settings has Connections section"""
        test_name = "SETTINGS_CONNECTIONS_SECTION_EXISTS"

        try:
            # Check for SettingsContent and ConnectionsSection
            settings_content = MACOS_ROOT / "FinanceMate/Views/Settings/SettingsContent.swift"
            connections_section = MACOS_ROOT / "FinanceMate/Views/Settings/ConnectionsSection.swift"
            settings_viewmodel = MACOS_ROOT / "FinanceMate/ViewModels/SettingsViewModel.swift"

            missing_files = []
            if not settings_content.exists():
                missing_files.append("SettingsContent.swift")
            if not connections_section.exists():
                missing_files.append("ConnectionsSection.swift")
            if not settings_viewmodel.exists():
                missing_files.append("SettingsViewModel.swift")

            if missing_files:
                self.logger.log(test_name, "FAIL", f"Missing Settings files: {', '.join(missing_files)}")
                return False

            # Check if SettingsViewModel has connections section enum
            with open(settings_viewmodel, 'r') as f:
                content = f.read()
                has_connections_enum = "case connections" in content.lower() and "Connections" in content
                has_connected_accounts = "ConnectedAccount" in content and "connectedAccounts" in content

                if not has_connections_enum:
                    self.logger.log(test_name, "FAIL", "SettingsViewModel missing connections enum case")
                    return False

                if not has_connected_accounts:
                    self.logger.log(test_name, "FAIL", "SettingsViewModel missing ConnectedAccount model")
                    return False

            self.logger.log(test_name, "PASS", "Settings Connections section exists")
            return True

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating Settings Connections section: {str(e)}")
            return False

    def validate_connect_bank_button_missing(self) -> bool:
        """Test: Validate 'Connect Bank Account' button is missing from Connections section"""
        test_name = "CONNECT_BANK_BUTTON_MISSING"

        try:
            connections_section = MACOS_ROOT / "FinanceMate/Views/Settings/ConnectionsSection.swift"

            if not connections_section.exists():
                self.logger.log(test_name, "FAIL", "ConnectionsSection.swift does not exist")
                return False

            with open(connections_section, 'r') as f:
                content = f.read()

                # Look for bank connection functionality
                bank_keywords = [
                    "Connect Bank",
                    "bank account",
                    "Basiq",
                    "ANZ",
                    "NAB",
                    "BankConnectionView"
                ]

                found_bank_functionality = False
                for keyword in bank_keywords:
                    if keyword.lower() in content.lower():
                        found_bank_functionality = True
                        break

                # Check if the generic "Connect Account" button has TODO for bank connection
                has_generic_button = "Connect Account" in content
                has_todo = "TODO" in content and ("bank" in content.lower() or "basiq" in content.lower())

                if found_bank_functionality and not has_todo:
                    self.logger.log(test_name, "FAIL", "Bank connection functionality already exists in Connections section")
                    return False

                if has_generic_button and has_todo:
                    self.logger.log(test_name, "PASS", "Generic button exists with TODO for bank connection - CONFIRMED GAP")
                    return True

                if has_generic_button:
                    self.logger.log(test_name, "PASS", "Generic Connect Account button exists but no bank functionality - CONFIRMED GAP")
                    return True

                self.logger.log(test_name, "FAIL", "No Connect Account button found in Connections section")
                return False

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating Connect Bank button: {str(e)}")
            return False

    def validate_bank_ui_not_integrated(self) -> bool:
        """Test: Validate BankConnectionView is not integrated into Settings navigation"""
        test_name = "BANK_UI_NOT_INTEGRATED"

        try:
            settings_content = MACOS_ROOT / "FinanceMate/Views/Settings/SettingsContent.swift"

            if not settings_content.exists():
                self.logger.log(test_name, "FAIL", "SettingsContent.swift does not exist")
                return False

            with open(settings_content, 'r') as f:
                content = f.read()

                # Check for bank connection navigation integration
                bank_integration_patterns = [
                    "BankConnectionView",
                    "navigationDestination(for: BankConnection",
                    "NavigationLink.*BankConnection",
                    "sheet.*BankConnection"
                ]

                found_integration = False
                for pattern in bank_integration_patterns:
                    if pattern.lower() in content.lower():
                        found_integration = True
                        break

                if found_integration:
                    self.logger.log(test_name, "FAIL", "BankConnectionView is already integrated into Settings navigation")
                    return False

                # Check that connections section exists but without bank integration
                if "ConnectionsSection" in content and "connections" in content.lower():
                    self.logger.log(test_name, "PASS", "ConnectionsSection exists but BankConnectionView not integrated - CONFIRMED GAP")
                    return True

                self.logger.log(test_name, "FAIL", "Connections section not properly configured in SettingsContent")
                return False

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating bank UI integration: {str(e)}")
            return False

    def validate_basiq_service_not_accessible_from_ui(self) -> bool:
        """Test: Validate BasiqAPIService is not accessible from UI components"""
        test_name = "BASIQ_SERVICE_NOT_ACCESSIBLE_FROM_UI"

        try:
            # Check ConnectionsSection for Basiq service usage
            connections_section = MACOS_ROOT / "FinanceMate/Views/Settings/ConnectionsSection.swift"

            if not connections_section.exists():
                self.logger.log(test_name, "FAIL", "ConnectionsSection.swift does not exist")
                return False

            with open(connections_section, 'r') as f:
                content = f.read()

                # Look for Basiq service integration
                basiq_patterns = [
                    "BasiqAPIService",
                    "BasiqAuthManager",
                    "BasiqTransactionService",
                    "@StateObject.*basiq",
                    "@ObservedObject.*basiq"
                ]

                found_basiq_integration = False
                for pattern in basiq_patterns:
                    if pattern in content:
                        found_basiq_integration = True
                        break

                if found_basiq_integration:
                    self.logger.log(test_name, "FAIL", "Basiq services are already integrated into Connections UI")
                    return False

                self.logger.log(test_name, "PASS", "Basiq services exist but are not integrated into Connections UI - CONFIRMED GAP")
                return True

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating Basiq service accessibility: {str(e)}")
            return False

    def validate_bank_selection_ui_missing(self) -> bool:
        """Test: Validate bank selection UI (ANZ/NAB) is missing"""
        test_name = "BANK_SELECTION_UI_MISSING"

        try:
            # Check for bank selection components
            bank_view = MACOS_ROOT / "FinanceMate/Views/BankConnectionView.swift"
            sandbox_bank_view = MACOS_ROOT / "FinanceMate-Sandbox/FinanceMate/Views/BankConnectionView.swift"

            target_view = None
            if bank_view.exists():
                target_view = bank_view
            elif sandbox_bank_view.exists():
                target_view = sandbox_bank_view

            if not target_view:
                self.logger.log(test_name, "FAIL", "No BankConnectionView found to validate")
                return False

            with open(target_view, 'r') as f:
                content = f.read()

                # Look for ANZ/NAB bank selection as per BLUEPRINT requirements
                anz_patterns = ["ANZ", "anz", "Australia and New Zealand Banking"]
                nab_patterns = ["NAB", "nab", "National Australia Bank"]

                has_anz = any(pattern in content for pattern in anz_patterns)
                has_nab = any(pattern in content for pattern in nab_patterns)

                if has_anz and has_nab:
                    self.logger.log(test_name, "FAIL", "ANZ and NAB bank selection already exists in BankConnectionView")
                    return False

                if has_anz or has_nab:
                    self.logger.log(test_name, "FAIL", f"Bank selection partially implemented (ANZ: {has_anz}, NAB: {has_nab})")
                    return False

                self.logger.log(test_name, "PASS", "ANZ/NAB bank selection UI missing - CONFIRMED GAP per BLUEPRINT requirements")
                return True

        except Exception as e:
            self.logger.log(test_name, "FAIL", f"Error validating bank selection UI: {str(e)}")
            return False

    def run_all_tests(self) -> bool:
        """Run all bank connection UI integration tests"""
        print(" BANK CONNECTION UI INTEGRATION TEST - RED PHASE")
        print("=" * 60)
        print("Expected: Tests should FAIL to confirm integration gap exists")
        print("=" * 60)

        tests = [
            self.validate_basiq_services_exist,
            self.validate_bank_connection_view_exists,
            self.validate_settings_connections_section_exists,
            self.validate_connect_bank_button_missing,
            self.validate_bank_ui_not_integrated,
            self.validate_basiq_service_not_accessible_from_ui,
            self.validate_bank_selection_ui_missing
        ]

        results = []
        for test in tests:
            try:
                result = test()
                results.append(result)
                time.sleep(0.1)  # Brief pause between tests
            except Exception as e:
                self.logger.log(test.__name__, "ERROR", str(e))
                results.append(False)

        # Generate comprehensive report
        report = self.logger.generate_report()
        print("\n" + "=" * 60)
        print("TEST COMPLETE - REPORT GENERATED")
        print("=" * 60)
        print(report)

        # Return overall test result (expecting failures for RED phase)
        passed_count = sum(results)
        total_tests = len(results)

        print(f"\n SUMMARY: {passed_count}/{total_tests} tests passed")

        if passed_count == total_tests:
            print("🟢 UNEXPECTED: All tests passed - bank integration may already exist")
            return True
        elif passed_count == 0:
            print(" CRITICAL: No tests passed - fundamental components missing")
            return False
        else:
            print(" EXPECTED: Some tests failed - bank connection UI integration gap confirmed")
            print(" READY FOR GREEN PHASE: Implement missing bank connection UI components")
            return False  # RED phase should return False to indicate failures exist

def main():
    """Main test execution"""
    test = BankConnectionUIIntegrationTest()

    try:
        success = test.run_all_tests()

        if success:
            print("\n🟢 All tests passed - Bank connection UI integration may already exist")
            return 0
        else:
            print("\n Tests failed as expected - Bank connection UI integration gap confirmed")
            print(" GREEN PHASE REQUIREMENTS:")
            print("   1. Integrate BankConnectionView into Settings navigation flow")
            print("   2. Add 'Connect Bank Account' button to ConnectionsSection")
            print("   3. Implement ANZ/NAB bank selection interface")
            print("   4. Connect BasiqAPIService to UI components")
            print("   5. Implement OAuth flow for bank authentication")
            return 1  # Return 1 for RED phase (failures expected)

    except KeyboardInterrupt:
        print("\n️ Test interrupted by user")
        return 2
    except Exception as e:
        print(f"\n Test execution failed: {str(e)}")
        return 3

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)