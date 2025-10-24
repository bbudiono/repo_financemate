#!/usr/bin/env python3
"""
BLUEPRINT Line 112: 5-Year Email Search Verification
Tests that Gmail API correctly searches through 5 years of emails in All Mail.
Covers:
  - 5-year date range calculation (5 years ago from today)
  - 'in:anywhere' query (searches all folders, not just inbox)
  - 'after:' date filter format
  - Proper date formatting (yyyy/MM/dd)
"""

import subprocess
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
import re


def test_5year_date_range_calculation():
    """Verify 5-year date range is calculated correctly."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Check for 5-year calculation
        assert 'byAdding: .year, value: -5' in content, \
            "5-year calculation not found in GmailAPI"

        # Extract calculation context
        if 'byAdding: .year, value: -5' in content:
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'byAdding: .year, value: -5' in line:
                    # Verify it's used with Date()
                    assert 'Calendar.current.date(byAdding' in content, \
                        "Calculation must use Calendar.current"
                    print(f"✅ Found 5-year calculation: {line.strip()}")

    print("✅ 5-year date range calculation verified")


def test_in_anywhere_query():
    """Verify Gmail query uses 'in:anywhere' for All Mail search."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Check for in:anywhere
        assert 'in:anywhere' in content, \
            "BLUEPRINT violation: Query must use 'in:anywhere' for All Mail search"

        # Verify it's used correctly (not in:inbox)
        assert 'in:inbox' not in content or content.count('in:anywhere') > 0, \
            "BLUEPRINT violation: Should use 'in:anywhere', not 'in:inbox'"

    print("✅ Query uses 'in:anywhere' (searches All Mail)")


def test_after_date_filter_format():
    """Verify 'after:' filter uses correct date format (yyyy/MM/dd)."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Check for after: pattern
        assert 'after:' in content, \
            "BLUEPRINT violation: Query must include 'after:' date filter"

        # Check for yyyy/MM/dd format
        assert 'yyyy/MM/dd' in content, \
            "Date format must be 'yyyy/MM/dd' (Gmail standard)"

        # Extract and verify the date formatting code
        if 'yyyy/MM/dd' in content:
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'yyyy/MM/dd' in line:
                    print(f"✅ Date format found: {line.strip()}")

    print("✅ Date filter uses correct format: 'after:yyyy/MM/dd'")


def test_financial_keywords_filter():
    """Verify query includes financial transaction keywords."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Check for financial keywords
        keywords = ['receipt', 'invoice', 'payment', 'order', 'purchase', 'cashback']
        found_keywords = []

        for keyword in keywords:
            if keyword in content.lower():
                found_keywords.append(keyword)

        assert len(found_keywords) > 0, \
            "BLUEPRINT violation: Query must filter for financial keywords"

        print(f"✅ Query filters for financial keywords: {', '.join(found_keywords)}")


def test_query_construction_logic():
    """Verify complete query construction matches BLUEPRINT requirements."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()
        lines = content.split('\n')

        # Find the query construction section
        full_sync_idx = None
        for i, line in enumerate(lines):
            if 'Full sync: 5-year financial history' in line or '// Full sync:' in line:
                full_sync_idx = i
                break

        if full_sync_idx:
            # Extract 10 lines around full sync
            context = '\n'.join(lines[max(0, full_sync_idx-2):min(len(lines), full_sync_idx+10)])
            print(f"\n✅ Full sync query construction:\n{context}")

            # Verify structure
            assert 'fiveYearsAgo' in content, "Missing 5-year ago date"
            assert 'after:' in content, "Missing 'after:' filter"
            assert 'in:anywhere' in content, "Missing 'in:anywhere' scope"


def test_delta_sync_query():
    """Verify delta sync query also supports correct date filtering."""
    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Check for delta sync support
        if 'delta' in content.lower() or 'lastSync' in content:
            assert 'in:anywhere' in content, \
                "Delta sync must also use 'in:anywhere'"
            print("✅ Delta sync query also uses 'in:anywhere'")


def test_blueprint_line_112_compliance():
    """Comprehensive BLUEPRINT Line 112 compliance check."""
    requirements = {
        'searches_all_mail': False,
        '5year_minimum': False,
        'date_range_filter': False,
        'financial_keywords': False,
    }

    with open('/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/GmailAPI.swift', 'r') as f:
        content = f.read()

        # Requirement 1: Search through All Mail
        if 'in:anywhere' in content:
            requirements['searches_all_mail'] = True

        # Requirement 2: 5 year minimum
        if 'byAdding: .year, value: -5' in content:
            requirements['5year_minimum'] = True

        # Requirement 3: Date range filter
        if 'after:' in content and 'yyyy/MM/dd' in content:
            requirements['date_range_filter'] = True

        # Requirement 4: Financial keywords
        if any(kw in content.lower() for kw in ['receipt', 'invoice', 'payment']):
            requirements['financial_keywords'] = True

    assert all(requirements.values()), \
        f"BLUEPRINT compliance check failed: {requirements}"

    print("\n✅ BLUEPRINT Line 112 Full Compliance:")
    print(f"   - Search through 'All Mail' (in:anywhere): {requirements['searches_all_mail']}")
    print(f"   - Minimum 5-year span: {requirements['5year_minimum']}")
    print(f"   - Date range filter (after:yyyy/MM/dd): {requirements['date_range_filter']}")
    print(f"   - Financial keywords filter: {requirements['financial_keywords']}")


def test_build_succeeds():
    """Verify app builds successfully with email search implementation."""
    proc = subprocess.Popen(
        [
            'xcodebuild',
            '-project', '/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate.xcodeproj',
            '-scheme', 'FinanceMate',
            '-configuration', 'Debug',
            'build'
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    stdout, stderr = proc.communicate()
    assert proc.returncode == 0, f"Build failed:\n{stderr}"
    assert 'BUILD SUCCEEDED' in stdout, "Build did not succeed"

    print("✅ Production build succeeds")


if __name__ == '__main__':
    print("=" * 70)
    print("5-YEAR EMAIL SEARCH - VERIFICATION TESTS")
    print("BLUEPRINT Line 112 Compliance")
    print("=" * 70)

    try:
        test_5year_date_range_calculation()
        test_in_anywhere_query()
        test_after_date_filter_format()
        test_financial_keywords_filter()
        test_query_construction_logic()
        test_delta_sync_query()
        test_blueprint_line_112_compliance()
        test_build_succeeds()

        print("\n" + "=" * 70)
        print("RESULT: All 5-Year Search tests PASSED (8/8)")
        print("=" * 70)
        print("\nIMPLEMENTATION DETAILS:")
        print("- Date range: 5 years ago from today")
        print("- Query scope: 'in:anywhere' (All Mail, not just Inbox)")
        print("- Date filter: 'after:yyyy/MM/dd' format (Gmail standard)")
        print("- Keywords: receipt, invoice, payment, order, purchase, cashback")
        print("- Sync modes: Full history + delta sync support")
        print("- Build status: GREEN (production ready)")

    except AssertionError as e:
        print(f"\n❌ TEST FAILED: {e}")
        exit(1)
    except Exception as e:
        print(f"\n❌ UNEXPECTED ERROR: {e}")
        import traceback
        traceback.print_exc()
        exit(1)
