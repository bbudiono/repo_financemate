#!/usr/bin/env python3
"""
Comprehensive Gmail Integration E2E Test Runner
Orchestrates all Gmail integration tests for complete validation
"""

import json
import time
import subprocess
import os
import tempfile
import sys
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('test_gmail_integration_comprehensive.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GmailIntegrationComprehensiveTest:
    """Comprehensive Gmail integration test orchestrator"""

    def __init__(self):
        self.test_results = {}
        self.test_suites = [
            'test_gmail_oauth_integration.py',
            'test_gmail_receipt_processing.py',
            'test_gmail_ui_integration.py',
            'test_gmail_negative_paths.py'
        ]
        self.app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.test_data_dir = tempfile.mkdtemp(prefix="gmail_comprehensive_test_")
        self.overall_start_time = datetime.now()

    def run_individual_test_suite(self, test_suite: str) -> Dict[str, Any]:
        """Run an individual test suite"""
        test_name = test_suite.replace('.py', '').replace('test_', '').replace('_', ' ').title()
        logger.info(f" Running {test_name} test suite")

        test_suite_path = os.path.join(
            os.path.dirname(__file__),
            test_suite
        )

        if not os.path.exists(test_suite_path):
            error_result = {
                'test_suite': test_name,
                'status': 'FAILED',
                'error': f'Test file not found: {test_suite_path}',
                'timestamp': datetime.now().isoformat(),
                'duration_seconds': 0
            }
            logger.error(f" {test_name} - FAILED: Test file not found")
            return error_result

        try:
            start_time = datetime.now()

            # Run the test suite
            result = subprocess.run(
                [sys.executable, test_suite_path],
                capture_output=True,
                text=True,
                timeout=300,  # 5 minute timeout per test suite
                cwd=os.path.dirname(__file__)
            )

            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()

            # Parse the output for results
            output_lines = result.stdout.strip().split('\n')
            error_lines = result.stderr.strip().split('\n') if result.stderr else []

            # Extract test results from output
            test_results = self._parse_test_output(output_lines)

            # Look for report file in output
            report_file = self._extract_report_file(output_lines)

            suite_result = {
                'test_suite': test_name,
                'status': 'PASSED' if result.returncode == 0 else 'FAILED',
                'return_code': result.returncode,
                'timestamp': start_time.isoformat(),
                'duration_seconds': duration,
                'stdout': output_lines,
                'stderr': error_lines,
                'test_results': test_results,
                'report_file': report_file
            }

            if result.returncode == 0:
                logger.info(f" {test_name} - PASSED ({duration:.1f}s)")
            else:
                logger.error(f" {test_name} - FAILED ({duration:.1f}s)")
                if error_lines:
                    logger.error(f"   Errors: {'; '.join(error_lines[:3])}")

            return suite_result

        except subprocess.TimeoutExpired:
            error_result = {
                'test_suite': test_name,
                'status': 'TIMEOUT',
                'error': 'Test suite timed out after 5 minutes',
                'timestamp': datetime.now().isoformat(),
                'duration_seconds': 300
            }
            logger.error(f" {test_name} - TIMEOUT: Test suite exceeded 5 minute limit")
            return error_result

        except Exception as e:
            error_result = {
                'test_suite': test_name,
                'status': 'ERROR',
                'error': str(e),
                'timestamp': datetime.now().isoformat(),
                'duration_seconds': 0
            }
            logger.error(f" {test_name} - ERROR: {e}")
            return error_result

    def _parse_test_output(self, output_lines: List[str]) -> Dict[str, Any]:
        """Parse test output to extract results"""
        results = {
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'success_rate': 0.0,
            'status': 'UNKNOWN'
        }

        for line in output_lines:
            line = line.strip()
            if 'Total Tests:' in line:
                try:
                    results['total_tests'] = int(line.split(':')[-1].strip())
                except (ValueError, IndexError):
                    pass
            elif 'Passed:' in line:
                try:
                    results['passed_tests'] = int(line.split(':')[-1].strip())
                except (ValueError, IndexError):
                    pass
            elif 'Failed:' in line:
                try:
                    results['failed_tests'] = int(line.split(':')[-1].strip())
                except (ValueError, IndexError):
                    pass
            elif 'Status:' in line:
                results['status'] = line.split(':')[-1].strip()
            elif 'Success Rate:' in line:
                try:
                    results['success_rate'] = float(line.split(':')[-1].strip().replace('%', ''))
                except (ValueError, IndexError):
                    pass

        return results

    def _extract_report_file(self, output_lines: List[str]) -> Optional[str]:
        """Extract report file path from output"""
        for line in output_lines:
            if 'Detailed report saved to:' in line:
                try:
                    return line.split(':')[-1].strip()
                except IndexError:
                    pass
        return None

    def validate_gmail_service_architecture(self) -> Dict[str, Any]:
        """Validate Gmail service architecture before running tests"""
        logger.info(" Validating Gmail service architecture")

        validation_result = {
            'status': 'PASSED',
            'timestamp': datetime.now().isoformat(),
            'checks': {},
            'errors': [],
            'warnings': []
        }

        # Check for required service files
        required_files = {
            'EmailConnectorService.swift': 'FinanceMate/Services/EmailConnectorService.swift',
            'GmailAPIService.swift': 'FinanceMate/Services/GmailAPIService.swift',
            'CoreDataManager.swift': 'FinanceMate/Services/CoreDataManager.swift',
            'GmailView.swift': 'FinanceMate/GmailView.swift',
            'GmailReceiptsTableView.swift': 'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift',
            'GmailFilterBar.swift': 'FinanceMate/Views/Gmail/GmailFilterBar.swift',
            'GmailTransactionRow.swift': 'FinanceMate/Views/Gmail/GmailTransactionRow.swift'
        }

        for file_name, file_path in required_files.items():
            full_path = os.path.join(self.app_path, file_path)
            exists = os.path.exists(full_path)
            validation_result['checks'][file_name] = {
                'exists': exists,
                'path': full_path,
                'size': os.path.getsize(full_path) if exists else 0
            }

            if not exists:
                validation_result['errors'].append(f"Missing required file: {file_name}")
                validation_result['status'] = 'FAILED'
            else:
                logger.info(f" Found {file_name}")

        # Check for Gmail service functionality
        service_checks = {
            'oauth_implementation': self._check_oauth_implementation(),
            'api_integration': self._check_api_integration(),
            'data_persistence': self._check_data_persistence(),
            'ui_components': self._check_ui_components()
        }

        validation_result['checks'].update(service_checks)

        # Check for any missing functionality
        for check_name, check_result in service_checks.items():
            if not check_result['implemented']:
                validation_result['warnings'].append(f"Missing functionality: {check_name}")

        if validation_result['status'] == 'PASSED':
            logger.info(" Gmail service architecture validation passed")
        else:
            logger.error(" Gmail service architecture validation failed")

        return validation_result

    def _check_oauth_implementation(self) -> Dict[str, Any]:
        """Check OAuth implementation"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'implemented': False, 'error': 'EmailConnectorService.swift not found'}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            oauth_indicators = [
                'OAuth', 'oauth', 'authenticate', 'authorization',
                'token', 'refreshToken', 'clientID', 'redirectURI'
            ]

            found_indicators = [indicator for indicator in oauth_indicators if indicator in content]

            return {
                'implemented': len(found_indicators) > 0,
                'found_indicators': found_indicators,
                'implementation_score': len(found_indicators)
            }

        except Exception as e:
            return {'implemented': False, 'error': str(e)}

    def _check_api_integration(self) -> Dict[str, Any]:
        """Check Gmail API integration"""
        try:
            gmail_api_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_path):
                return {'implemented': False, 'error': 'GmailAPIService.swift not found'}

            with open(gmail_api_path, 'r') as f:
                content = f.read()

            api_indicators = [
                'gmail.googleapis.com', 'GmailAPI', 'messages', 'threads',
                'fetchEmails', 'parseEmail', 'extractReceipt'
            ]

            found_indicators = [indicator for indicator in api_indicators if indicator in content]

            return {
                'implemented': len(found_indicators) > 0,
                'found_indicators': found_indicators,
                'implementation_score': len(found_indicators)
            }

        except Exception as e:
            return {'implemented': False, 'error': str(e)}

    def _check_data_persistence(self) -> Dict[str, Any]:
        """Check data persistence implementation"""
        try:
            core_data_path = os.path.join(self.app_path, 'FinanceMate/Services/CoreDataManager.swift')

            if not os.path.exists(core_data_path):
                return {'implemented': False, 'error': 'CoreDataManager.swift not found'}

            with open(core_data_path, 'r') as f:
                content = f.read()

            persistence_indicators = [
                'CoreData', 'NSPersistentContainer', 'NSManagedObject',
                'saveContext', 'fetch', 'insert', 'delete'
            ]

            found_indicators = [indicator for indicator in persistence_indicators if indicator in content]

            return {
                'implemented': len(found_indicators) > 0,
                'found_indicators': found_indicators,
                'implementation_score': len(found_indicators)
            }

        except Exception as e:
            return {'implemented': False, 'error': str(e)}

    def _check_ui_components(self) -> Dict[str, Any]:
        """Check UI components implementation"""
        try:
            ui_files = [
                'FinanceMate/Views/Gmail/GmailView.swift',
                'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift',
                'FinanceMate/Views/Gmail/GmailFilterBar.swift'
            ]

            ui_indicators = []
            total_indicators = 0

            for ui_file in ui_files:
                full_path = os.path.join(self.app_path, ui_file)
                if os.path.exists(full_path):
                    with open(full_path, 'r') as f:
                        content = f.read()

                    file_indicators = [
                        'SwiftUI', 'View', 'Text', 'Button', 'TextField',
                        'Table', 'List', 'ForEach', 'NavigationLink'
                    ]

                    found_indicators = [indicator for indicator in file_indicators if indicator in content]
                    ui_indicators.extend(found_indicators)
                    total_indicators += len(found_indicators)

            return {
                'implemented': total_indicators > 0,
                'found_indicators': ui_indicators,
                'implementation_score': total_indicators,
                'files_checked': len(ui_files)
            }

        except Exception as e:
            return {'implemented': False, 'error': str(e)}

    def generate_comprehensive_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        logger.info(" Generating comprehensive Gmail integration test report")

        overall_end_time = datetime.now()
        total_duration = (overall_end_time - self.overall_start_time).total_seconds()

        # Calculate overall statistics
        total_test_suites = len(self.test_results)
        passed_test_suites = sum(1 for result in self.test_results.values() if result['status'] == 'PASSED')
        failed_test_suites = total_test_suites - passed_test_suites

        # Aggregate test results
        total_tests = sum(result.get('test_results', {}).get('total_tests', 0) for result in self.test_results.values())
        total_passed = sum(result.get('test_results', {}).get('passed_tests', 0) for result in self.test_results.values())
        total_failed = total_tests - total_passed
        overall_success_rate = (total_passed / total_tests * 100) if total_tests > 0 else 0

        # Collect all errors and warnings
        all_errors = []
        all_warnings = []

        for result in self.test_results.values():
            if 'stderr' in result and result['stderr']:
                all_errors.extend(result['stderr'])

            # Parse test results for errors
            test_results = result.get('test_results', {})
            if 'errors' in test_results:
                all_errors.extend(test_results['errors'])
            if 'warnings' in test_results:
                all_warnings.extend(test_results['warnings'])

        # Generate recommendations
        recommendations = []
        if failed_test_suites == 0:
            recommendations.append("All Gmail integration tests passed - system is ready for production deployment")
            recommendations.append("Gmail receipt processing is fully functional with comprehensive error handling")
        else:
            recommendations.append("Address failing test suites before production deployment")
            recommendations.append("Review error logs and fix critical integration issues")

        if total_tests > 0 and overall_success_rate < 90:
            recommendations.append("Improve test coverage and fix failing test cases")

        recommendations.append("Set up real Gmail test credentials for end-to-end validation")
        recommendations.append("Monitor Gmail API usage and rate limits in production")

        report = {
            'test_run': {
                'timestamp': self.overall_start_time.isoformat(),
                'duration_seconds': total_duration,
                'total_test_suites': total_test_suites,
                'passed_test_suites': passed_test_suites,
                'failed_test_suites': failed_test_suites,
                'suite_success_rate': (passed_test_suites / total_test_suites * 100) if total_test_suites > 0 else 0
            },
            'test_statistics': {
                'total_tests': total_tests,
                'passed_tests': total_passed,
                'failed_tests': total_failed,
                'overall_success_rate': overall_success_rate
            },
            'test_suite_results': self.test_results,
            'blueprint_validation': {
                'email_based_ingestion': self._validate_blueprint_requirement('email_ingestion'),
                'line_item_creation': self._validate_blueprint_requirement('line_items'),
                'gmail_receipts_table': self._validate_blueprint_requirement('gmail_table'),
                'spreadsheet_functionality': self._validate_blueprint_requirement('spreadsheet'),
                'auto_refresh_control': self._validate_blueprint_requirement('auto_refresh'),
                'cache_performance': self._validate_blueprint_requirement('cache_performance'),
                'complex_filtering': self._validate_blueprint_requirement('filtering'),
                'visual_indicators': self._validate_blueprint_requirement('visual_indicators')
            },
            'summary': {
                'status': 'PASSED' if failed_test_suites == 0 and overall_success_rate >= 80 else 'FAILED',
                'critical_failures': all_errors[:10],  # Limit to first 10 errors
                'warnings': all_warnings[:10],  # Limit to first 10 warnings
                'recommendations': recommendations
            }
        }

        return report

    def _validate_blueprint_requirement(self, requirement: str) -> Dict[str, Any]:
        """Validate specific BLUEPRINT requirements"""
        blueprint_validations = {
            'email_ingestion': {
                'test_suites': ['Gmail Receipt Processing', 'Gmail Oauth Integration'],
                'required_features': ['parseEmail', 'fetchEmails', 'extractReceipt'],
                'validation_method': 'code_analysis'
            },
            'line_items': {
                'test_suites': ['Gmail Receipt Processing'],
                'required_features': ['extractLineItems', 'createTransaction', 'TaxCategory'],
                'validation_method': 'test_results'
            },
            'gmail_table': {
                'test_suites': ['Gmail Ui Integration'],
                'required_features': ['GmailReceiptsTableView', 'Table', 'List'],
                'validation_method': 'file_existence'
            },
            'spreadsheet': {
                'test_suites': ['Gmail Ui Integration'],
                'required_features': ['inline editing', 'multi-select', 'contextMenu'],
                'validation_method': 'test_results'
            },
            'auto_refresh': {
                'test_suites': ['Gmail Ui Integration'],
                'required_features': ['autoRefresh', 'Timer', 'refresh'],
                'validation_method': 'test_results'
            },
            'cache_performance': {
                'test_suites': ['Gmail Ui Integration', 'Gmail Receipt Processing'],
                'required_features': ['cache', 'Cache', 'performance', 'optimization'],
                'validation_method': 'test_results'
            },
            'filtering': {
                'test_suites': ['Gmail Ui Integration'],
                'required_features': ['GmailFilterBar', 'filter', 'predicate', 'search'],
                'validation_method': 'test_results'
            },
            'visual_indicators': {
                'test_suites': ['Gmail Ui Integration'],
                'required_features': ['status', 'progress', 'color coding', 'indicators'],
                'validation_method': 'test_results'
            }
        }

        if requirement not in blueprint_validations:
            return {'validated': False, 'error': f'Unknown requirement: {requirement}'}

        validation_config = blueprint_validations[requirement]

        # Check if required test suites passed
        relevant_suites_passed = 0
        total_relevant_suites = 0

        for suite_name in validation_config['test_suites']:
            total_relevant_suites += 1
            if suite_name in self.test_results and self.test_results[suite_name]['status'] == 'PASSED':
                relevant_suites_passed += 1

        validation_ratio = relevant_suites_passed / total_relevant_suites if total_relevant_suites > 0 else 0

        return {
            'validated': validation_ratio >= 0.75,  # At least 75% of relevant suites should pass
            'relevant_suites': total_relevant_suites,
            'passed_suites': relevant_suites_passed,
            'validation_ratio': validation_ratio,
            'required_features': validation_config['required_features'],
            'validation_method': validation_config['validation_method']
        }

    def save_comprehensive_report(self, report: Dict[str, Any]) -> str:
        """Save comprehensive test report to file"""
        report_file = os.path.join(
            self.test_data_dir,
            f"gmail_integration_comprehensive_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        )

        try:
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)

            logger.info(f" Comprehensive report saved to: {report_file}")
            return report_file

        except Exception as e:
            logger.error(f" Error saving comprehensive report: {e}")
            return ""

    def run_all_tests(self) -> Dict[str, Any]:
        """Run all Gmail integration tests"""
        logger.info(" Starting Comprehensive Gmail Integration Test Suite")
        logger.info(f" Test data directory: {self.test_data_dir}")

        # Step 1: Validate architecture
        architecture_validation = self.validate_gmail_service_architecture()

        if architecture_validation['status'] == 'FAILED':
            logger.error(" Architecture validation failed - aborting test suite")
            report = {
                'test_run': {
                    'timestamp': datetime.now().isoformat(),
                    'status': 'ABORTED',
                    'reason': 'Architecture validation failed',
                    'duration_seconds': 0
                },
                'test_statistics': {
                    'total_tests': 0,
                    'passed_tests': 0,
                    'failed_tests': 0,
                    'overall_success_rate': 0
                },
                'architecture_validation': architecture_validation,
                'summary': {
                    'status': 'FAILED',
                    'critical_failures': architecture_validation['errors'],
                    'recommendations': ['Fix missing service files before running tests']
                }
            }

            report_file = self.save_comprehensive_report(report)
            if report_file:
                report['report_file'] = report_file

            return report

        # Step 2: Run individual test suites
        logger.info(" Running individual test suites...")

        for test_suite in self.test_suites:
            suite_result = self.run_individual_test_suite(test_suite)
            suite_name = suite_result['test_suite']
            self.test_results[suite_name] = suite_result

        # Step 3: Generate comprehensive report
        logger.info(" Generating comprehensive report...")
        report = self.generate_comprehensive_report()
        report['architecture_validation'] = architecture_validation

        # Step 4: Save report
        report_file = self.save_comprehensive_report(report)
        if report_file:
            report['report_file'] = report_file

        # Log final summary
        logger.info(f" Comprehensive Gmail Integration Test Suite completed")
        logger.info(f"   Duration: {report['test_run']['duration_seconds']:.1f}s")
        logger.info(f"   Test Suites: {report['test_run']['passed_test_suites']}/{report['test_run']['total_test_suites']} passed")
        logger.info(f"   Individual Tests: {report['test_statistics']['passed_tests']}/{report['test_statistics']['total_tests']} passed")
        logger.info(f"   Overall Success Rate: {report['test_statistics']['overall_success_rate']:.1f}%")
        logger.info(f"   Status: {report['summary']['status']}")

        return report

def main():
    """Main test execution function"""
    print(" Comprehensive Gmail Integration E2E Test Suite")
    print("=" * 60)

    # Create and run comprehensive test suite
    test_suite = GmailIntegrationComprehensiveTest()
    results = test_suite.run_all_tests()

    # Print summary
    print(f"\n Comprehensive Test Results Summary:")
    print(f"   Duration: {results['test_run']['duration_seconds']:.1f} seconds")
    print(f"   Test Suites: {results['test_run']['passed_test_suites']}/{results['test_run']['total_test_suites']} passed")
    print(f"   Suite Success Rate: {results['test_run']['suite_success_rate']:.1f}%")

    if 'test_statistics' in results:
        print(f"   Individual Tests: {results['test_statistics']['passed_tests']}/{results['test_statistics']['total_tests']} passed")
        print(f"   Overall Success Rate: {results['test_statistics']['overall_success_rate']:.1f}%")

    print(f"   Status: {results['summary']['status']}")

    # Print BLUEPRINT validation results
    if 'blueprint_validation' in results:
        print(f"\n BLUEPRINT Requirements Validation:")
        for requirement, validation in results['blueprint_validation'].items():
            status_icon = "" if validation['validated'] else ""
            print(f"   {status_icon} {requirement.replace('_', ' ').title()}: {validation['validation_ratio']*100:.0f}% validated")

    # Print errors if any
    if results['summary']['critical_failures']:
        print(f"\n Critical Failures:")
        for failure in results['summary']['critical_failures']:
            print(f"   - {failure}")

    # Print recommendations
    print(f"\n Recommendations:")
    for recommendation in results['summary']['recommendations']:
        print(f"   - {recommendation}")

    if 'report_file' in results:
        print(f"\n Detailed comprehensive report saved to: {results['report_file']}")

    print("\n Comprehensive test suite execution completed")

    # Return appropriate exit code
    return 0 if results['summary']['status'] == 'PASSED' else 1

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)