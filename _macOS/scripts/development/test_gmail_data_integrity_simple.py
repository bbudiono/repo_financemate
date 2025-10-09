#!/usr/bin/env python3
"""
Atomic TDD test for Gmail Data Integrity preservation - BLUEPRINT Line 179
"""

import re
import sys

def test_gmail_data_integrity_basic():
    """Basic test for Gmail data integrity components"""
    print(" ATOMIC TDD TEST: Gmail Data Integrity (BLUEPRINT Line 179)")

    try:
        # Check GmailModels.swift for required fields
        with open('FinanceMate/GmailModels.swift', 'r') as f:
            content = f.read()

        required_fields = [
            'let confidence: Double',
            'let rawText: String',
            'let items: [GmailLineItem]'
        ]

        for field in required_fields:
            if not re.search(field, content):
                print(f" RED TEST FAILING: Missing field {field}")
                return False

        print(" RED TEST PASSING: Data integrity fields found")
        return True

    except FileNotFoundError:
        print(" RED TEST FAILING: GmailModels.swift not found")
        return False

if __name__ == "__main__":
    success = test_gmail_data_integrity_basic()
    sys.exit(0 if success else 1)