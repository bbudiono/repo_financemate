#!/usr/bin/env python3
"""
Comprehensive Merchant Extraction Validation Test
================================================
Purpose: Validate that the merchant extraction fixes (commit 2abe276f) work correctly

BUGS FIXED:
1. MerchantDatabase bidirectional .contains() - caused cross-contamination
2. SemanticValidator preservation logic - prevented overwriting correct merchants

USER-REPORTED ISSUES:
- Spaceship emails showing as "Bunnings" - MUST return "Spaceship"
- Zip variants inconsistent - MUST normalize to "Zip"
- Generic "Merchant Name" placeholders - MUST not appear

Last Updated: 2025-11-08
"""

import unittest
import re
import json
import os
from datetime import datetime
from typing import Optional, Dict, List


class MerchantDatabaseSimulator:
    """
    Python simulation of MerchantDatabase.swift logic
    This validates the FIXED extraction algorithm
    """

    # Mirror of merchantMappings from MerchantDatabase.swift
    MERCHANT_MAPPINGS: Dict[str, str] = {
        # Payment & Financial Services
        "afterpay.com": "Afterpay",
        "afterpay.com.au": "Afterpay",
        "paypal.com": "PayPal",
        "zip.co": "Zip",
        "zipmoney.com.au": "Zip",
        "zip.com.au": "Zip",
        "klarna.com": "Klarna",
        "shopback.com": "Shopback",
        "shopback.com.au": "Shopback",
        "spaceshipinvest.com.au": "Spaceship",  # CRITICAL - must NOT match Bunnings
        "spaceship.com.au": "Spaceship",

        # Banks & Financial Institutions
        "commbank.com.au": "Commonwealth Bank",
        "anz.com": "ANZ",
        "anz.com.au": "ANZ",
        "westpac.com.au": "Westpac",
        "ing.com.au": "ING",
        "nab.com.au": "NAB",

        # Retail (including Bunnings)
        "bunnings.com.au": "Bunnings",  # ONLY this domain should return Bunnings
        "kmart.com.au": "Kmart",
        "target.com.au": "Target",
        "woolworths.com.au": "Woolworths",
        "coles.com.au": "Coles",
        "officeworks.com.au": "Officeworks",
        "harveynorman.com.au": "Harvey Norman",
        "jbhifi.com.au": "JB Hi-Fi",

        # Online Services
        "amazon.com.au": "Amazon",
        "amazon.com": "Amazon",
        "ebay.com.au": "eBay",
        "netflix.com": "Netflix",
        "spotify.com": "Spotify",
    }

    @classmethod
    def extract_merchant(cls, subject: str, sender: str) -> Optional[str]:
        """
        Python equivalent of MerchantDatabase.extractMerchant()
        Uses FIXED logic from commit 2abe276f
        """
        # First try subject line extraction
        match = re.search(r'(from|at) ([A-Za-z\s]+)', subject)
        if match:
            merchant_name = match.group(2).strip()
            if merchant_name:
                return merchant_name

        # Enhanced domain-based extraction
        return cls._extract_merchant_from_domain(sender)

    @classmethod
    def _extract_merchant_from_domain(cls, sender: str) -> Optional[str]:
        """
        Python equivalent of extractMerchantFromDomain()
        Uses FIXED subdomain matching logic
        """
        if "@" not in sender:
            return None

        domain = sender.split("@")[1].lower()

        # Check exact domain matches first
        if domain in cls.MERCHANT_MAPPINGS:
            return cls.MERCHANT_MAPPINGS[domain]

        # FIXED LOGIC: Check subdomain matches using proper hasSuffix equivalent
        # OLD (buggy): domain.contains(mapped) or mapped.contains(domain)
        # NEW (fixed): domain == mapped or domain.endswith("." + mapped)
        for mapped_domain, merchant in cls.MERCHANT_MAPPINGS.items():
            if domain == mapped_domain or domain.endswith("." + mapped_domain):
                return merchant

        # Fallback: extract brand from domain
        return cls._extract_brand_from_domain(domain)

    @classmethod
    def _extract_brand_from_domain(cls, domain: str) -> Optional[str]:
        """Fallback brand extraction from domain parts"""
        parts = domain.split(".")

        # Government domain handling
        if ".gov.au" in domain or ".gov" in domain:
            return "Government"

        # Skip common prefixes/suffixes
        skip_parts = ["info", "noreply", "no-reply", "support", "contact",
                      "hello", "team", "orders", "service", "mail", "email",
                      "com", "au", "net", "org", "online", "store", "shop"]

        for part in parts:
            if part.lower() not in skip_parts and len(part) > 2:
                return part.capitalize()

        return parts[0].capitalize() if parts else None


class TestMerchantExtractionBugFixes(unittest.TestCase):
    """
    Tests for user-reported bug fixes
    These MUST ALL PASS for the fix to be validated
    """

    def test_spaceship_not_bunnings(self):
        """
        BUG #1: Spaceship emails showing as "Bunnings"
        User: "Merchant says 'Bunnings' but from is 'Spaceshipinvest.com.au'"
        """
        test_cases = [
            ("noreply@spaceshipinvest.com.au", "Spaceship"),
            ("support@spaceshipinvest.com.au", "Spaceship"),
            ("info@spaceship.com.au", "Spaceship"),
            ("notifications@spaceshipinvest.com.au", "Spaceship"),
        ]

        for sender, expected in test_cases:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your investment update", sender
                )
                self.assertEqual(result, expected,
                    f"Spaceship email from {sender} should return '{expected}', "
                    f"got '{result}' instead")
                # CRITICAL: Must NOT return Bunnings
                self.assertNotEqual(result, "Bunnings",
                    f"CRITICAL BUG: Spaceship email incorrectly showing as Bunnings")

    def test_zip_normalization(self):
        """
        BUG #2: Zip variants inconsistent
        User: "Zip Money Payments Pty Ltd and Zip Pay are not consistent"
        All Zip variants should normalize to "Zip"
        """
        zip_domains = [
            ("noreply@zip.co", "Zip"),
            ("support@zipmoney.com.au", "Zip"),
            ("info@zip.com.au", "Zip"),
            ("notifications@zip.co", "Zip"),
        ]

        for sender, expected in zip_domains:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your payment receipt", sender
                )
                self.assertEqual(result, expected,
                    f"Zip email from {sender} should return '{expected}', "
                    f"got '{result}' instead")

    def test_no_bunnings_false_positives(self):
        """
        BUG #1 continued: No Bunnings false positives
        Only emails from actual bunnings.com.au domain should return Bunnings
        """
        non_bunnings_domains = [
            "noreply@spaceshipinvest.com.au",  # Should be Spaceship
            "support@anz.com.au",              # Should be ANZ
            "info@commbank.com.au",            # Should be Commonwealth Bank
            "noreply@amazon.com.au",           # Should be Amazon
            "notifications@netflix.com",       # Should be Netflix
        ]

        for sender in non_bunnings_domains:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your receipt", sender
                )
                self.assertNotEqual(result, "Bunnings",
                    f"Email from {sender} incorrectly returned 'Bunnings'")

    def test_real_bunnings_email(self):
        """
        Ensure actual Bunnings emails still work correctly
        """
        bunnings_domains = [
            "noreply@bunnings.com.au",
            "orders@bunnings.com.au",
            "support@bunnings.com.au",
        ]

        for sender in bunnings_domains:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your Bunnings order", sender
                )
                self.assertEqual(result, "Bunnings",
                    f"Real Bunnings email from {sender} should return 'Bunnings', "
                    f"got '{result}' instead")

    def test_subdomain_matching_correctness(self):
        """
        Verify subdomain matching works correctly
        "info.shopback.com.au" should match "shopback.com.au" -> "Shopback"
        """
        test_cases = [
            ("info@info.shopback.com.au", "Shopback"),
            ("noreply@mail.afterpay.com.au", "Afterpay"),
            ("support@help.netflix.com", "Netflix"),
        ]

        for sender, expected in test_cases:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your receipt", sender
                )
                self.assertEqual(result, expected,
                    f"Subdomain email {sender} should return '{expected}', "
                    f"got '{result}' instead")


class TestMerchantExtractionRegression(unittest.TestCase):
    """
    Regression tests to ensure existing functionality still works
    """

    def test_major_retailers(self):
        """Test major Australian retailers are correctly identified"""
        retailers = [
            ("noreply@woolworths.com.au", "Woolworths"),
            ("orders@coles.com.au", "Coles"),
            ("support@kmart.com.au", "Kmart"),
            ("noreply@target.com.au", "Target"),
            ("orders@officeworks.com.au", "Officeworks"),
            ("noreply@harveynorman.com.au", "Harvey Norman"),
            ("support@jbhifi.com.au", "JB Hi-Fi"),
        ]

        for sender, expected in retailers:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your order confirmation", sender
                )
                self.assertEqual(result, expected)

    def test_banks(self):
        """Test Australian banks are correctly identified"""
        banks = [
            ("alerts@commbank.com.au", "Commonwealth Bank"),
            ("noreply@anz.com.au", "ANZ"),
            ("statements@westpac.com.au", "Westpac"),
            ("alerts@nab.com.au", "NAB"),
            ("info@ing.com.au", "ING"),
        ]

        for sender, expected in banks:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your statement", sender
                )
                self.assertEqual(result, expected)

    def test_streaming_services(self):
        """Test streaming services are correctly identified"""
        services = [
            ("info@netflix.com", "Netflix"),
            ("noreply@spotify.com", "Spotify"),
        ]

        for sender, expected in services:
            with self.subTest(sender=sender):
                result = MerchantDatabaseSimulator.extract_merchant(
                    "Your subscription", sender
                )
                self.assertEqual(result, expected)


class TestMerchantExtractionEdgeCases(unittest.TestCase):
    """
    Edge cases and boundary conditions
    """

    def test_unknown_domain_fallback(self):
        """Test unknown domains get reasonable fallback"""
        result = MerchantDatabaseSimulator.extract_merchant(
            "Your receipt", "noreply@someunknownstore.com.au"
        )
        # Should extract brand from domain, not return None or "Merchant Name"
        self.assertIsNotNone(result)
        self.assertNotEqual(result, "Merchant Name")
        self.assertNotEqual(result, "")

    def test_subject_extraction_priority(self):
        """Test subject line extraction takes priority when available"""
        result = MerchantDatabaseSimulator.extract_merchant(
            "Receipt from Kmart", "noreply@someemail.com"
        )
        self.assertEqual(result, "Kmart")

    def test_empty_inputs(self):
        """Test handling of empty/malformed inputs"""
        # Empty sender
        result = MerchantDatabaseSimulator.extract_merchant(
            "Your receipt", ""
        )
        # Should not crash, may return None

        # No @ symbol
        result = MerchantDatabaseSimulator.extract_merchant(
            "Your receipt", "invalidemail"
        )
        self.assertIsNone(result)


def generate_validation_report(results: unittest.TestResult) -> Dict:
    """Generate detailed validation report"""
    report = {
        "timestamp": datetime.now().isoformat(),
        "commit": "2abe276f",
        "tests_run": results.testsRun,
        "failures": len(results.failures),
        "errors": len(results.errors),
        "success_rate": ((results.testsRun - len(results.failures) - len(results.errors))
                         / results.testsRun * 100) if results.testsRun > 0 else 0,
        "status": "PASS" if results.wasSuccessful() else "FAIL",
        "failure_details": [
            {"test": str(test), "message": msg}
            for test, msg in results.failures
        ],
        "error_details": [
            {"test": str(test), "message": msg}
            for test, msg in results.errors
        ],
    }
    return report


if __name__ == "__main__":
    print("=" * 80)
    print("MERCHANT EXTRACTION COMPREHENSIVE VALIDATION")
    print("=" * 80)
    print(f"Timestamp: {datetime.now().isoformat()}")
    print(f"Validating commit: 2abe276f")
    print("=" * 80)

    # Run tests
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Add test classes
    suite.addTests(loader.loadTestsFromTestCase(TestMerchantExtractionBugFixes))
    suite.addTests(loader.loadTestsFromTestCase(TestMerchantExtractionRegression))
    suite.addTests(loader.loadTestsFromTestCase(TestMerchantExtractionEdgeCases))

    # Run with verbosity
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # Generate and save report
    report = generate_validation_report(result)

    # Ensure output directory exists
    output_dir = os.path.join(os.path.dirname(__file__), "..", "test_output")
    os.makedirs(output_dir, exist_ok=True)

    report_path = os.path.join(output_dir, "merchant_validation_comprehensive.json")
    with open(report_path, "w") as f:
        json.dump(report, f, indent=2)

    print("\n" + "=" * 80)
    print("VALIDATION SUMMARY")
    print("=" * 80)
    print(f"Tests Run: {report['tests_run']}")
    print(f"Passed: {report['tests_run'] - report['failures'] - len(report['error_details'])}")
    print(f"Failed: {report['failures']}")
    print(f"Errors: {len(report['error_details'])}")
    print(f"Success Rate: {report['success_rate']:.1f}%")
    print(f"Overall Status: {report['status']}")
    print(f"Report saved to: {report_path}")
    print("=" * 80)

    # Exit with appropriate code
    exit(0 if result.wasSuccessful() else 1)
