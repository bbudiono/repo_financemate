#!/usr/bin/env python3
"""
Gmail Transaction Extraction CLI Validation Tool

Provides command-line interface for testing transaction extraction
from Gmail emails with comprehensive field validation.
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, Any

class GmailExtractionValidator:
    REQUIRED_FIELDS = [
        'merchant', 'amount', 'currency', 'date',
        'description', 'category', 'transaction_id',
        'tax_category', 'location', 'payment_method',
        'recurring', 'tags', 'notes'
    ]

    @classmethod
    def validate_email(cls, email_file_path: Path) -> Dict[str, Any]:
        """
        Validate email transaction extraction

        Args:
            email_file_path (Path): Path to email text file

        Returns:
            dict: Validation results
        """
        try:
            with open(email_file_path, 'r') as f:
                email_content = f.read()
        except FileNotFoundError:
            return {
                'status': 'ERROR',
                'message': f'Email file not found: {email_file_path}'
            }

        try:
            # Call actual Gmail extraction service
            transactions = cls._extract_transactions(email_content)

            # Validate transactions
            validation_results = {
                'status': 'SUCCESS',
                'total_transactions': len(transactions),
                'transactions': []
            }

            for i, transaction in enumerate(transactions, 1):
                transaction_validation = cls._validate_transaction(transaction)
                validation_results['transactions'].append({
                    f'transaction_{i}': transaction_validation
                })

            return validation_results

        except Exception as e:
            return {
                'status': 'ERROR',
                'message': str(e)
            }

    @classmethod
    def _extract_transactions(cls, email_content: str):
        """
        Mock method to simulate Gmail extraction service.
        In production, this would call the actual Gmail extraction service.

        Args:
            email_content (str): Raw email content

        Returns:
            list: Extracted transactions
        """
        # TODO: Replace with actual extraction service call
        from decimal import Decimal
        from datetime import datetime

        return [{
            'merchant': 'Test Merchant',
            'amount': Decimal('123.45'),
            'currency': 'AUD',
            'date': datetime.now().isoformat(),
            'description': 'Test transaction',
            'category': 'Miscellaneous',
            'transaction_id': 'dummy_123',
            'tax_category': 'Personal',
            'location': 'Online',
            'payment_method': 'Credit Card',
            'recurring': False,
            'tags': ['test'],
            'notes': 'CLI validation test'
        }]

    @classmethod
    def _validate_transaction(cls, transaction: Dict[str, Any]) -> Dict[str, Any]:
        """
        Validate individual transaction fields

        Args:
            transaction (dict): Transaction to validate

        Returns:
            dict: Validation results for the transaction
        """
        validation_results = {
            'is_valid': True,
            'missing_fields': [],
            'invalid_fields': []
        }

        # Check for required fields
        for field in cls.REQUIRED_FIELDS:
            if field not in transaction:
                validation_results['is_valid'] = False
                validation_results['missing_fields'].append(field)

        # Basic field type and value validations
        if transaction.get('amount', 0) <= 0:
            validation_results['is_valid'] = False
            validation_results['invalid_fields'].append('amount')

        if len(transaction.get('currency', '')) != 3:
            validation_results['is_valid'] = False
            validation_results['invalid_fields'].append('currency')

        return validation_results

def main():
    parser = argparse.ArgumentParser(description='Gmail Transaction Extraction Validator')
    parser.add_argument('email_file', type=Path, help='Path to email text file')
    parser.add_argument('--output', type=Path, help='Optional output file for validation results')

    args = parser.parse_args()

    validation_results = GmailExtractionValidator.validate_email(args.email_file)

    # Pretty print results
    print(json.dumps(validation_results, indent=2))

    # Optional file output
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(validation_results, f, indent=2)

    # Exit with appropriate status code
    sys.exit(0 if validation_results['status'] == 'SUCCESS' else 1)

if __name__ == '__main__':
    main()