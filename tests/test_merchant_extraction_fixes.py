#!/usr/bin/env python3
"""
Comprehensive merchant extraction diagnostic tool
Analyzes the user's ACTUAL 63 emails from Core Data to identify ALL merchant extraction bugs

This script:
1. Reads Core Data SQLite database directly
2. Extracts ALL transactions with their source emails
3. Analyzes merchant extraction for each email
4. Identifies specific bugs causing wrong merchants
5. Validates against the 3 specific examples the user provided:
   - "Merchant Name" (generic placeholder)
   - "Zip Money Payments Pty Ltd" vs "Zip Pay" (inconsistent normalization)
   - "Bunnings" for "Spaceshipinvest.com.au" (wrong domain mapping)
"""

import sqlite3
import json
import re
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple

# Core Data database location
CORE_DATA_DB = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Library/Application Support/FinanceMate/FinanceMate.sqlite"

class MerchantExtractionDiagnostics:
    def __init__(self):
        self.conn = None
        self.issues = defaultdict(list)

    def connect(self):
        """Connect to Core Data SQLite database"""
        if not CORE_DATA_DB.exists():
            raise FileNotFoundError(f"Core Data database not found at: {CORE_DATA_DB}")

        self.conn = sqlite3.connect(str(CORE_DATA_DB))
        self.conn.row_factory = sqlite3.Row
        print(f"✅ Connected to Core Data: {CORE_DATA_DB}")

    def analyze_all_transactions(self) -> List[Dict]:
        """Extract all transactions with their source emails"""
        cursor = self.conn.cursor()

        # Query all transactions with source email info
        query = """
        SELECT
            ZITEMDESCRIPTION as merchant,
            ZAMOUNT as amount,
            ZEMAILSOURCE as email_source,
            ZNOTE as email_subject,
            ZSOURCEEMAILID as source_email_id,
            ZCONTENTHASH as content_hash
        FROM ZTRANSACTION
        WHERE ZEMAILSOURCE IS NOT NULL
        ORDER BY ZDATE DESC
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        print(f"\n📊 Found {len(rows)} transactions with email sources")

        transactions = []
        for row in rows:
            tx = {
                'merchant': row['merchant'],
                'amount': row['amount'],
                'email_source': row['email_source'],
                'email_subject': row['email_subject'],
                'source_email_id': row['source_email_id'],
                'content_hash': row['content_hash']
            }
            transactions.append(tx)

        return transactions

    def extract_domain_from_email(self, email: str) -> str:
        """Extract domain from email address"""
        match = re.search(r'@(.+?)(?:>|$)', email)
        return match.group(1).lower() if match else ""

    def extract_display_name(self, email: str) -> str:
        """Extract display name from email (before <)"""
        match = re.search(r'^(.+?)\s*<', email)
        return match.group(1).strip() if match else ""

    def analyze_merchant_extraction(self, transaction: Dict):
        """Analyze merchant extraction for a single transaction"""
        merchant = transaction['merchant']
        email_source = transaction['email_source']
        email_subject = transaction['email_subject'] or ""

        domain = self.extract_domain_from_email(email_source)
        display_name = self.extract_display_name(email_source)

        # Check for specific bugs
        self._check_generic_placeholder(merchant, transaction)
        self._check_normalization_inconsistency(merchant, display_name, email_source, transaction)
        self._check_wrong_domain_mapping(merchant, domain, email_source, transaction)
        self._check_bunnings_contamination(merchant, domain, email_subject, transaction)

        return {
            'merchant': merchant,
            'domain': domain,
            'display_name': display_name,
            'email_source': email_source,
            'email_subject': email_subject
        }

    def _check_generic_placeholder(self, merchant: str, transaction: Dict):
        """Check for generic placeholder like 'Merchant Name'"""
        generic_patterns = [
            'Merchant Name',
            'merchant',
            'unknown',
            'Unknown',
            'Unknown Merchant',
            'N/A'
        ]

        for pattern in generic_patterns:
            if merchant == pattern or merchant.lower() == pattern.lower():
                self.issues['generic_placeholder'].append({
                    'merchant': merchant,
                    'email_source': transaction['email_source'],
                    'email_subject': transaction['email_subject'],
                    'bug': f"Generic placeholder '{merchant}' instead of extracted merchant"
                })

    def _check_normalization_inconsistency(self, merchant: str, display_name: str, email_source: str, transaction: Dict):
        """Check for inconsistent normalization of same company"""
        # Known inconsistent pairs
        inconsistent_pairs = [
            (['Zip Money', 'Zip Pay', 'Zip Money Payments', 'Zip Money Payments Pty Ltd'], 'Zip'),
            (['Bunnings Warehouse', 'Bunnings'], 'Bunnings'),
            (['Amazon', 'Amazon Australia', 'Amazon Prime'], 'Amazon')
        ]

        for variations, normalized in inconsistent_pairs:
            if merchant in variations and merchant != normalized:
                self.issues['normalization_inconsistency'].append({
                    'merchant': merchant,
                    'display_name': display_name,
                    'email_source': email_source,
                    'expected_normalized': normalized,
                    'bug': f"Should normalize '{merchant}' to '{normalized}' for consistency"
                })

    def _check_wrong_domain_mapping(self, merchant: str, domain: str, email_source: str, transaction: Dict):
        """Check if merchant doesn't match the domain"""
        # Known correct domain → merchant mappings
        domain_mappings = {
            'spaceshipinvest.com.au': 'Spaceship',
            'spaceship.com.au': 'Spaceship',
            'shopback.com.au': 'Shopback',
            'info.shopback.com.au': 'Shopback',
            'zip.co': 'Zip',
            'zipmoney.com.au': 'Zip',
            'bunnings.com.au': 'Bunnings',
            'officeworks.com.au': 'Officeworks'
        }

        expected_merchant = domain_mappings.get(domain)
        if expected_merchant and merchant != expected_merchant:
            self.issues['wrong_domain_mapping'].append({
                'merchant': merchant,
                'domain': domain,
                'email_source': email_source,
                'expected_merchant': expected_merchant,
                'bug': f"Domain '{domain}' should map to '{expected_merchant}', not '{merchant}'"
            })

    def _check_bunnings_contamination(self, merchant: str, domain: str, email_subject: str, transaction: Dict):
        """Check if 'Bunnings' appears where it shouldn't"""
        if merchant == 'Bunnings':
            # List of domains that should NEVER be Bunnings
            non_bunnings_domains = [
                'spaceshipinvest.com.au',
                'spaceship.com.au',
                'shopback.com.au',
                'zip.co',
                'zipmoney.com.au',
                'afterpay.com',
                'paypal.com'
            ]

            if domain in non_bunnings_domains:
                self.issues['bunnings_contamination'].append({
                    'merchant': merchant,
                    'domain': domain,
                    'email_subject': email_subject,
                    'bug': f"'Bunnings' appearing for '{domain}' - wrong merchant extraction"
                })

    def generate_report(self):
        """Generate comprehensive diagnostic report"""
        print("\n" + "="*80)
        print("🔍 MERCHANT EXTRACTION DIAGNOSTIC REPORT")
        print("="*80)

        total_issues = sum(len(issues) for issues in self.issues.values())

        if total_issues == 0:
            print("\n✅ No merchant extraction issues found!")
            return

        print(f"\n❌ Found {total_issues} merchant extraction issues across {len(self.issues)} categories:")
        print()

        # Report each issue category
        for category, issues_list in self.issues.items():
            print(f"\n{'─'*80}")
            print(f"🐛 {category.replace('_', ' ').title()}: {len(issues_list)} issues")
            print(f"{'─'*80}")

            for i, issue in enumerate(issues_list[:10], 1):  # Show first 10 of each type
                print(f"\n{i}. {issue['bug']}")
                print(f"   Merchant: '{issue['merchant']}'")
                print(f"   Email: {issue.get('email_source', 'N/A')}")
                if 'domain' in issue:
                    print(f"   Domain: {issue['domain']}")
                if 'expected_merchant' in issue:
                    print(f"   Expected: '{issue['expected_merchant']}'")
                if 'expected_normalized' in issue:
                    print(f"   Expected Normalized: '{issue['expected_normalized']}'")

            if len(issues_list) > 10:
                print(f"\n   ... and {len(issues_list) - 10} more")

        # User's specific examples
        print(f"\n{'='*80}")
        print("🎯 USER'S SPECIFIC EXAMPLES ANALYSIS")
        print(f"{'='*80}")

        print("\n1. 'Merchant Name' appearing as actual merchant:")
        if self.issues['generic_placeholder']:
            print(f"   ✓ CONFIRMED - {len(self.issues['generic_placeholder'])} instances found")
        else:
            print("   ✗ NOT FOUND in current data")

        print("\n2. 'Zip Money Payments Pty Ltd' vs 'Zip Pay' inconsistency:")
        zip_issues = [i for i in self.issues['normalization_inconsistency'] if 'Zip' in i['merchant']]
        if zip_issues:
            print(f"   ✓ CONFIRMED - {len(zip_issues)} instances found")
        else:
            print("   ✗ NOT FOUND in current data")

        print("\n3. 'Bunnings' for 'Spaceshipinvest.com.au':")
        spaceship_bunnings = [i for i in self.issues['bunnings_contamination'] if 'spaceship' in i['domain']]
        if spaceship_bunnings:
            print(f"   ✓ CONFIRMED - {len(spaceship_bunnings)} instances found")
        else:
            print("   ✗ NOT FOUND in current data")

    def run_full_diagnostics(self):
        """Run complete diagnostic analysis"""
        print("🚀 Starting merchant extraction diagnostics...")

        self.connect()
        transactions = self.analyze_all_transactions()

        print("\n🔬 Analyzing merchant extraction for all transactions...")
        for tx in transactions:
            self.analyze_merchant_extraction(tx)

        self.generate_report()

        # Save raw data for further analysis
        report_file = Path(__file__).parent / f"merchant_extraction_diagnostics_{Path(CORE_DATA_DB).stat().st_mtime:.0f}.json"
        with open(report_file, 'w') as f:
            json.dump({
                'total_transactions': len(transactions),
                'issues': dict(self.issues),
                'transactions_sample': transactions[:20]
            }, f, indent=2)

        print(f"\n📝 Full diagnostic data saved to: {report_file}")

if __name__ == '__main__':
    diagnostics = MerchantExtractionDiagnostics()
    try:
        diagnostics.run_full_diagnostics()
    except Exception as e:
        print(f"\n❌ Error running diagnostics: {e}")
        import traceback
        traceback.print_exc()
