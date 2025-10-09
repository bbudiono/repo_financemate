#!/usr/bin/env python3
"""
ATOMIC TDD Cycle 1 - RED PHASE: Gmail Table Merchant Column
BLUEPRINT Line 68: Information dense spreadsheet-like table with all extracted data
"""
import subprocess
import sys

def test_merchant_column_exists():
    """Test 1: GmailTableRow displays merchant column"""
    result = subprocess.run(
        ['grep', '-n', 'Merchant', '../FinanceMate/Views/Gmail/GmailTableRow.swift'],
        capture_output=True,
        text=True
    )

    has_merchant_label = 'Merchant' in result.stdout or 'merchant' in result.stdout
    print(f"[TEST] Merchant column exists: {'PASS' if has_merchant_label else 'FAIL'}")
    return has_merchant_label

def test_merchant_displayed_in_row():
    """Test 2: Merchant value displayed in collapsed row"""
    result = subprocess.run(
        ['grep', '-A', '5', '-B', '2', 'transaction.merchant', '../FinanceMate/Views/Gmail/GmailTableRow.swift'],
        capture_output=True,
        text=True
    )

    # Check if merchant is displayed as Text() in the main HStack
    displays_merchant = 'Text(' in result.stdout and 'transaction.merchant' in result.stdout
    print(f"[TEST] Merchant displayed in row: {'PASS' if displays_merchant else 'FAIL'}")
    return displays_merchant

def test_merchant_column_after_date():
    """Test 3: Merchant column positioned after Date column"""
    with open('../FinanceMate/Views/Gmail/GmailTableRow.swift', 'r') as f:
        content = f.read()

    # Find positions of Date and Merchant in the HStack
    date_pos = content.find('transaction.date')
    merchant_pos = content.find('transaction.merchant')

    # Merchant should come after Date in the layout
    correct_order = merchant_pos > date_pos > 0 if (date_pos > 0 and merchant_pos > 0) else False
    print(f"[TEST] Merchant after Date: {'PASS' if correct_order else 'FAIL'}")
    return correct_order

def test_merchant_editable():
    """Test 4: Merchant column supports inline editing"""
    result = subprocess.run(
        ['grep', '-C', '3', 'transaction.merchant', '../FinanceMate/Views/Gmail/GmailTableRow.swift'],
        capture_output=True,
        text=True
    )

    # Check for TextField or editable binding
    is_editable = 'TextField' in result.stdout or '@Published' in result.stdout
    print(f"[TEST] Merchant inline editable: {'PASS' if is_editable else 'FAIL'}")
    return is_editable

def test_merchant_column_width():
    """Test 5: Merchant column has defined width (~140px)"""
    result = subprocess.run(
        ['grep', '-A', '10', 'transaction.merchant', '../FinanceMate/Views/Gmail/GmailTableRow.swift'],
        capture_output=True,
        text=True
    )

    has_width = '.frame(width:' in result.stdout
    print(f"[TEST] Merchant column width defined: {'PASS' if has_width else 'FAIL'}")
    return has_width

def main():
    print("=" * 80)
    print("ATOMIC TDD - RED PHASE: Gmail Table Merchant Column")
    print("=" * 80)
    print("BLUEPRINT Line 68: Information dense spreadsheet with ALL extracted data")
    print("Expected: All tests FAIL (merchant column not yet in main row)")
    print("=" * 80)

    tests = [
        test_merchant_column_exists,
        test_merchant_displayed_in_row,
        test_merchant_column_after_date,
        test_merchant_editable,
        test_merchant_column_width
    ]

    results = [test() for test in tests]
    passed = sum(results)

    print("\n" + "=" * 80)
    print(f"RED PHASE RESULTS: {passed}/{len(results)} passing")
    print(f"Expected: 0-1/{len(results)} (merchant currently in detail panel only)")

    if passed < 3:
        print(" RED PHASE VALID: Merchant not prominent in main row - needs implementation")
        return 0
    else:
        print(f"️  {passed} tests passing - merchant may already be partially implemented")
        return 0

if __name__ == "__main__":
    sys.exit(main())
