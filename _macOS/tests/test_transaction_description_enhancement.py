#!/usr/bin/env python3
"""
ATOMIC TDD - RED PHASE: Transaction Description Enhancement
BLUEPRINT Line 211: Properly extracted descriptions with real merchant data
"""
import subprocess
import sys

def run_test(test_name, condition, expected_result):
    """Run a single test and return pass/fail"""
    print(f"\n[TEST] {test_name}")
    print(f"  Condition: {condition}")

    result = "PASS" if expected_result else "FAIL"
    print(f"  Result: {result}")
    return expected_result

def test_transaction_description_builder_exists():
    """Test 1: TransactionDescriptionBuilder service file exists"""
    result = subprocess.run(
        ['find', '..', '-name', 'TransactionDescriptionBuilder.swift'],
        capture_output=True,
        text=True
    )
    exists = 'TransactionDescriptionBuilder.swift' in result.stdout
    return run_test(
        "Service File Exists",
        "TransactionDescriptionBuilder.swift exists in codebase",
        exists
    )

def test_build_description_method_exists():
    """Test 2: buildDescription method exists"""
    result = subprocess.run(
        ['grep', '-r', 'func buildDescription', '..'],
        capture_output=True,
        text=True
    )
    exists = 'buildDescription' in result.stdout
    return run_test(
        "buildDescription Method Exists",
        "Service has buildDescription(from: ExtractedTransaction) method",
        exists
    )

def test_formatted_description_includes_invoice():
    """Test 3: Formatted descriptions include invoice numbers when available"""
    result = subprocess.run(
        ['grep', '-A', '5', 'func buildDescription', '../FinanceMate/Services/TransactionDescriptionBuilder.swift'],
        capture_output=True,
        text=True
    )
    includes_invoice = 'invoiceNumber' in result.stdout
    return run_test(
        "Invoice Number Included",
        "Description includes invoice number when present",
        includes_invoice
    )

def test_formatted_description_includes_gst():
    """Test 4: Formatted descriptions include GST amounts"""
    result = subprocess.run(
        ['grep', '-A', '5', 'func buildDescription', '../FinanceMate/Services/TransactionDescriptionBuilder.swift'],
        capture_output=True,
        text=True
    )
    includes_gst = 'gstAmount' in result.stdout
    return run_test(
        "GST Amount Included",
        "Description includes GST amount when present",
        includes_gst
    )

def test_formatted_description_includes_payment_method():
    """Test 5: Formatted descriptions include payment method"""
    result = subprocess.run(
        ['grep', '-A', '5', 'func buildDescription', '../FinanceMate/Services/TransactionDescriptionBuilder.swift'],
        capture_output=True,
        text=True
    )
    includes_payment = 'paymentMethod' in result.stdout
    return run_test(
        "Payment Method Included",
        "Description includes payment method when present",
        includes_payment
    )

def test_xcode_build_integration():
    """Test 6: Service is added to Xcode build target"""
    result = subprocess.run(
        ['grep', 'TransactionDescriptionBuilder.swift', '../FinanceMate.xcodeproj/project.pbxproj'],
        capture_output=True,
        text=True
    )
    in_build = 'TransactionDescriptionBuilder.swift' in result.stdout
    return run_test(
        "Xcode Build Integration",
        "Service is in FinanceMate build target",
        in_build
    )

def main():
    print("=" * 80)
    print("ATOMIC TDD - RED PHASE: Transaction Description Enhancement")
    print("=" * 80)
    print("BLUEPRINT Line 211: Transaction descriptions with real merchant data")
    print("Expected: All tests should FAIL (service not yet implemented)")
    print("=" * 80)

    tests = [
        test_transaction_description_builder_exists,
        test_build_description_method_exists,
        test_formatted_description_includes_invoice,
        test_formatted_description_includes_gst,
        test_formatted_description_includes_payment_method,
        test_xcode_build_integration
    ]

    results = [test() for test in tests]

    passed = sum(results)
    failed = len(results) - passed

    print("\n" + "=" * 80)
    print(f"RED PHASE RESULTS: {passed}/{len(results)} passing")
    print(f"Expected: 0/{len(results)} (all should fail before implementation)")

    if passed == 0:
        print(" RED PHASE COMPLETE: All tests failing as expected")
        print("Next: GREEN PHASE - Implement TransactionDescriptionBuilder")
        return 0
    else:
        print(f"️  {passed} tests already passing - unexpected state")
        return 1

if __name__ == "__main__":
    sys.exit(main())
