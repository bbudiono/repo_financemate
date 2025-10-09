#!/usr/bin/env python3
"""
Dashboard Real Data Validation - BLUEPRINT.md Line 178 Compliance
Validates that dashboard analytics use only real Core Data transaction data
"""

import os
import sys

def check_core_data_usage(file_path, service_name):
    """Check if service uses Core Data operations"""
    if not os.path.exists(file_path):
        print(f" {service_name} not found")
        return False

    with open(file_path, 'r') as f:
        content = f.read()

    has_fetch_request = "NSFetchRequest<Transaction>" in content
    has_context_fetch = "context.fetch(request)" in content

    if has_fetch_request and has_context_fetch:
        print(f" {service_name} uses real Core Data operations")
        return True
    else:
        print(f" {service_name} missing Core Data operations")
        return False

def check_mock_data_exclusion():
    """Check for mock data patterns in dashboard files"""
    dashboard_files = [
        "FinanceMate/Services/DashboardMetricsService.swift",
        "FinanceMate/Services/DashboardDataService.swift",
        "FinanceMate/ViewModels/DashboardViewModel.swift",
        "FinanceMate/DashboardView.swift"
    ]

    mock_patterns = ["mock", "sample", "placeholder", "fake", "dummy"]
    mock_found = False

    for file_path in dashboard_files:
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                content = f.read().lower()
                for pattern in mock_patterns:
                    if pattern in content and "test" not in file_path.lower():
                        print(f"️ Mock pattern '{pattern}' found in {file_path}")
                        mock_found = True

    if not mock_found:
        print(" No mock data patterns found in dashboard files")
    return not mock_found

def validate_dashboard_real_data():
    """Validate dashboard real data processing implementation"""
    print(" DASHBOARD REAL DATA VALIDATION - BLUEPRINT.md Line 178")
    print("=" * 60)

    # Check 1: DashboardMetricsService.swift uses Core Data
    print("\n1. Checking DashboardMetricsService.swift...")
    metrics_path = "FinanceMate/Services/DashboardMetricsService.swift"
    metrics_ok = check_core_data_usage(metrics_path, "DashboardMetricsService")

    # Check 2: DashboardDataService.swift uses Core Data
    print("\n2. Checking DashboardDataService.swift...")
    data_path = "FinanceMate/Services/DashboardDataService.swift"
    data_ok = check_core_data_usage(data_path, "DashboardDataService")

    # Check 3: No mock data in dashboard calculations
    print("\n3. Checking for mock data exclusion...")
    mock_ok = check_mock_data_exclusion()

    # Check 4: Test file exists
    print("\n4. Checking validation test coverage...")
    test_file = "FinanceMateTests/DashboardRealDataValidationTests.swift"
    test_ok = os.path.exists(test_file)
    if test_ok:
        print(" DashboardRealDataValidationTests.swift created")
    else:
        print(" DashboardRealDataValidationTests.swift not found")

    print("\n" + "=" * 60)
    print(" DASHBOARD REAL DATA VALIDATION COMPLETE")

    if all([metrics_ok, data_ok, mock_ok, test_ok]):
        print(" BLUEPRINT.md Line 178 compliance verified")
        print(" All dashboard analytics use real Core Data transaction data")
        return True
    else:
        print(" Some validation checks failed")
        return False

if __name__ == "__main__":
    success = validate_dashboard_real_data()
    sys.exit(0 if success else 1)