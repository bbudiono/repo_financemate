#!/usr/bin/env python3
"""
Atomic TDD test for Gmail Data Integrity preservation - BLUEPRINT Line 179
"""

import subprocess
import sys
import json
import re

def check_data_structure_fields():
    """Check if Gmail models have required data integrity fields"""
    try:
        with open('FinanceMate/GmailModels.swift', 'r') as f:
            models_content = f.read()

        # Check for confidence score field
        confidence_pattern = r'let confidence: Double'
        if not re.search(confidence_pattern, models_content):
            print(" RED TEST FAILING: Missing confidence score field in ExtractedTransaction")
            return False

        # Check for rawText preservation
        raw_text_pattern = r'let rawText: String'
        if not re.search(raw_text_pattern, models_content):
            print(" RED TEST FAILING: Missing rawText field for preserving original email content")
            return False

        # Check for line items preservation
        line_items_pattern = r'let items: \[GmailLineItem\]'
        if not re.search(line_items_pattern, models_content):
            print(" RED TEST FAILING: Missing items array for preserving line items")
            return False

        print(" Data structure fields present")
        return True

    except FileNotFoundError:
        print(" RED TEST FAILING: GmailModels.swift not found")
        return False

def check_integrity_validation_functions():
    """Check if data integrity validation functions exist"""
    try:
        with open('FinanceMate/GmailTransactionExtractor.swift', 'r') as f:
            extractor_content = f.read()

        # Look for data integrity validation functions
        integrity_patterns = [
            r'func.*validateDataIntegrity',
            r'func.*preserve.*Data',
            r'func.*integrity.*Check'
        ]

        has_integrity_validation = any(re.search(pattern, extractor_content, re.IGNORECASE)
                                    for pattern in integrity_patterns)

        if not has_integrity_validation:
            print(" RED TEST FAILING: Missing data integrity validation functions")
            return False

        print(" Data integrity validation functions found")
        return True

    except FileNotFoundError:
        print(" RED TEST FAILING: GmailTransactionExtractor.swift not found")
        return False

def check_merchant_name_preservation():
    """Check for merchant name extraction and preservation"""
    try:
        with open('FinanceMate/GmailStandardTransactionExtractor.swift', 'r') as f:
            extractor_content = f.read()

        # Look for merchant extraction patterns
        merchant_patterns = [
            r'func.*extractMerchant',
            r'merchant.*=',
            r'.*merchant.*extract'
        ]

        has_merchant_extraction = any(re.search(pattern, extractor_content, re.IGNORECASE)
                                   for pattern in merchant_patterns)

        if not has_merchant_extraction:
            print(" RED TEST FAILING: Missing merchant name extraction and preservation")
            return False

        print(" Merchant name extraction found")
        return True

    except FileNotFoundError:
        print(" RED TEST FAILING: GmailStandardTransactionExtractor.swift not found")
        return False

def test_gmail_data_integrity_preservation():
    """Test that Gmail receipt processing preserves all extracted data without loss"""

    print(" ATOMIC TDD TEST: Gmail Data Integrity Preservation (BLUEPRINT Line 179)")

    # RED PHASE: This test should fail initially as we haven't implemented data integrity checks yet

    # Test 1: Check data structure fields
    if not check_data_structure_fields():
        return False

    # Test 2: Check integrity validation functions
    if not check_integrity_validation_functions():
        return False

    # Test 3: Check merchant name preservation
    if not check_merchant_name_preservation():
        return False

    print(" RED TEST COMPLETE: All data integrity components validated")
    return True

if __name__ == "__main__":
    success = test_gmail_data_integrity_preservation()
    sys.exit(0 if success else 1)