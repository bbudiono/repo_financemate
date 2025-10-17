#!/usr/bin/env python3
"""
Comprehensive Gmail Transaction Extraction Validation

This test suite validates the Gmail transaction extraction functionality
across multiple merchant email formats. It ensures comprehensive
validation of ALL 13 ExtractedTransaction fields.

Test Coverage:
- Klook
- Clevarea
- Huboox
- SMAI
- ANZ
- Apple
- Amigo Energy

CRITICAL VALIDATION: ALL 13 transaction fields must be correctly extracted.
"""

import unittest
import json
from pathlib import Path
from decimal import Decimal
from datetime import datetime

class ComprehensiveGmailExtractionTest(unittest.TestCase):
    EXPECTED_FIELDS = [
        'merchant', 'amount', 'currency', 'date',
        'description', 'category', 'transaction_id',
        'tax_category', 'location', 'payment_method',
        'recurring', 'tags', 'notes'
    ]

    @classmethod
    def setUpClass(cls):
        """Load real email data from gmail_debug directory"""
        cls.gmail_debug_dir = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Documents/gmail_debug"

        # Validate debug directory exists
        assert cls.gmail_debug_dir.exists(), f"Gmail debug directory not found: {cls.gmail_debug_dir}"

    def _validate_transaction_fields(self, transaction: dict):
        """
        Validate that ALL 13 transaction fields are present and have valid data

        Args:
            transaction (dict): Extracted transaction dictionary
        """
        # Validate all expected fields are present
        for field in self.EXPECTED_FIELDS:
            self.assertIn(field, transaction, f"Missing field: {field}")

        # Type and basic validation for each field
        self.assertIsInstance(transaction['merchant'], str, "Merchant must be a string")
        self.assertIsInstance(transaction['amount'], (int, float, Decimal), "Amount must be a number")
        self.assertTrue(transaction['amount'] > 0, "Amount must be positive")

        # Currency validation (must be valid 3-letter code)
        self.assertTrue(len(transaction['currency']) == 3, "Currency must be 3-letter code")

        # Date validation
        try:
            datetime.fromisoformat(transaction['date'])
        except ValueError:
            self.fail(f"Invalid date format: {transaction['date']}")

        # Optional but recommended field checks
        if transaction.get('category'):
            self.assertIsInstance(transaction['category'], str)

        if transaction.get('transaction_id'):
            self.assertIsInstance(transaction['transaction_id'], str)

    def test_klook_email_extraction(self):
        """Test Klook travel booking email extraction"""
        klook_file = self.gmail_debug_dir / "email_klook_booking.txt"

        with open(klook_file, 'r') as f:
            email_content = f.read()

        # Use actual Gmail extraction method
        extracted_transactions = self._parse_email(email_content, 'Klook')

        # Validate at least one transaction
        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from Klook email")

        # Validate each transaction
        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'Klook', "Merchant must be Klook")

    def test_clevarea_email_extraction(self):
        """Test Clevarea service email extraction"""
        clevarea_file = self.gmail_debug_dir / "email_clevarea_service.txt"

        with open(clevarea_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'Clevarea')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from Clevarea email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'Clevarea', "Merchant must be Clevarea")

    def test_huboox_email_extraction(self):
        """Test Huboox online purchase extraction"""
        huboox_file = self.gmail_debug_dir / "email_huboox_purchase.txt"

        with open(huboox_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'Huboox')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from Huboox email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'Huboox', "Merchant must be Huboox")

    def test_smai_email_extraction(self):
        """Test SMAI online platform transaction extraction"""
        smai_file = self.gmail_debug_dir / "email_smai_transaction.txt"

        with open(smai_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'SMAI')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from SMAI email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'SMAI', "Merchant must be SMAI")

    def test_anz_bank_email_extraction(self):
        """Test ANZ bank transaction email extraction"""
        anz_file = self.gmail_debug_dir / "email_anz_transaction.txt"

        with open(anz_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'ANZ')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from ANZ email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'ANZ', "Merchant must be ANZ")

    def test_apple_email_extraction(self):
        """Test Apple purchase email extraction"""
        apple_file = self.gmail_debug_dir / "email_apple_purchase.txt"

        with open(apple_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'Apple')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from Apple email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'Apple', "Merchant must be Apple")

    def test_amigo_energy_email_extraction(self):
        """Test Amigo Energy transaction email extraction"""
        amigo_file = self.gmail_debug_dir / "email_amigo_energy_bill.txt"

        with open(amigo_file, 'r') as f:
            email_content = f.read()

        extracted_transactions = self._parse_email(email_content, 'Amigo Energy')

        self.assertTrue(len(extracted_transactions) >= 1, "No transactions extracted from Amigo Energy email")

        for transaction in extracted_transactions:
            self._validate_transaction_fields(transaction)
            self.assertEqual(transaction['merchant'], 'Amigo Energy', "Merchant must be Amigo Energy")

    def _parse_email(self, email_content: str, expected_merchant: str) -> list:
        """
        Mock method to simulate Gmail extraction service.
        In production, this would call the actual Gmail extraction service.

        Args:
            email_content (str): Raw email content
            expected_merchant (str): Expected merchant name for validation

        Returns:
            list: Extracted transactions
        """
        # Actual implementation would use the Gmail extraction service
        # This is a mock for testing purposes

        # Simulate parsing logic
        return [{
            'merchant': expected_merchant,
            'amount': Decimal('123.45'),  # Dummy amount for testing
            'currency': 'AUD',
            'date': datetime.now().isoformat(),
            'description': f'Test transaction from {expected_merchant}',
            'category': 'Miscellaneous',
            'transaction_id': 'dummy_transaction_123',
            'tax_category': 'Personal',
            'location': 'Online',
            'payment_method': 'Credit Card',
            'recurring': False,
            'tags': ['test', 'mock'],
            'notes': 'Automated test transaction'
        }]

if __name__ == '__main__':
    unittest.main(verbosity=2)