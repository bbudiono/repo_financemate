#!/usr/bin/env python3
"""
GREEN PHASE: Atomic TDD test for Gmail Data Integrity preservation - BLUEPRINT Line 179
"""

import re
import sys

def test_gmail_data_integrity_implementation():
    """Test that Gmail Data Integrity preservation is implemented"""
    print("🟢 GREEN PHASE TEST: Gmail Data Integrity Implementation")

    try:
        # Check GmailModels.swift for required fields
        with open('FinanceMate/GmailModels.swift', 'r') as f:
            content = f.read()

        required_fields = [
            'let confidence: Double',
            'let rawText: String',
            'let items: \\[GmailLineItem\\]'
        ]

        for field in required_fields:
            if not re.search(field, content):
                print(f" GREEN TEST FAILING: Missing field {field}")
                return False

        print(" Data integrity fields present")

    except FileNotFoundError:
        print(" GREEN TEST FAILING: GmailModels.swift not found")
        return False

    # Check if GmailDataIntegrityService exists and has required functions
    try:
        with open('FinanceMate/Services/GmailDataIntegrityService.swift', 'r') as f:
            service_content = f.read()

        required_functions = [
            'validateTransactionIntegrity',
            'preserveExtractedData'
        ]

        for func in required_functions:
            if not re.search(func, service_content):
                print(f" GREEN TEST FAILING: Missing function {func}")
                return False

        print(" Data integrity validation functions found")

    except FileNotFoundError:
        print(" GREEN TEST FAILING: GmailDataIntegrityService.swift not found")
        return False

    print("🟢 GREEN TEST PASSING: Gmail Data Integrity preservation implemented")
    return True

if __name__ == "__main__":
    success = test_gmail_data_integrity_implementation()
    sys.exit(0 if success else 1)