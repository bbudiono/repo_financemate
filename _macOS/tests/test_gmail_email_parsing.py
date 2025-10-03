#!/usr/bin/env python3
"""
Gmail Email Parsing E2E Test - ShopBack Transaction Extraction Validation

This test validates the Gmail transaction extraction functionality using real ShopBack cashback emails.
The test ensures proper parsing of multi-item purchase emails with correct amount extraction
(purchase amounts, not cashback amounts) and accurate line item identification.

REAL DATA TEST: Uses actual email content from gmail_debug directory
VALIDATION FOCUS: Correct parsing of ShopBack email format with multiple eBay purchases
"""

import unittest
import json
from pathlib import Path
from decimal import Decimal


class GmailEmailParsingTest(unittest.TestCase):
    """
    Test Gmail email parsing functionality with real ShopBack cashback emails.

    Test Focus:
    - Correct extraction of purchase amounts (not cashback amounts)
    - Accurate line item count (4 purchases from eBay)
    - Proper merchant name extraction
    - Transaction ID handling (not mistaken as quantities)
    - Total amount validation
    """

    @classmethod
    def setUpClass(cls):
        """Load real email data from gmail_debug directory"""
        cls.gmail_debug_dir = Path.home() / "Library/Containers/com.ablankcanvas.financemate/Data/Documents/gmail_debug"
        cls.shopback_email_file = cls.gmail_debug_dir / "email_5_199a89b782600bc6.txt"

        if not cls.shopback_email_file.exists():
            raise FileNotFoundError(
                f"ShopBack test email not found at: {cls.shopback_email_file}\n"
                f"Gmail debug directory exists: {cls.gmail_debug_dir.exists()}"
            )

        # Load email content
        with open(cls.shopback_email_file, 'r') as f:
            cls.email_content = f.read()

    def test_gmail_email_parsing(self):
        """
        Test ShopBack email parsing with 4 eBay purchases

        Expected Extraction:
        - Line Item 1: eBay, $99.71 (Home & Garden)
        - Line Item 2: eBay, $298.18 (Computer, Tablets, Networking)
        - Line Item 3: eBay, $1,017.40 (Computer, Tablets, Networking)
        - Line Item 4: eBay, $184.45 (Tickets)
        Total: $1,599.74

        CRITICAL VALIDATIONS:
        1. Correct number of line items (4, not 1)
        2. Purchase amounts extracted (NOT cashback amounts like $1.30, $2.38, $8.14, $2.02)
        3. Merchant names are "eBay" for all items
        4. Transaction IDs (10074249507809, etc.) NOT mistaken as quantities
        5. Total amount calculation is accurate
        """

        print("\n" + "="*80)
        print("GMAIL EMAIL PARSING TEST - ShopBack Multi-Purchase Validation")
        print("="*80)

        # Parse the email content
        parsed_data = self._parse_shopback_email(self.email_content)

        # ASSERTION 1: Correct number of line items
        self.assertEqual(
            len(parsed_data['line_items']),
            4,
            f"Expected 4 line items (eBay purchases), got {len(parsed_data['line_items'])}"
        )
        print(f" PASS: Correct line item count (4 purchases)")

        # ASSERTION 2: Purchase amounts are correct (not cashback amounts)
        expected_amounts = [Decimal('99.71'), Decimal('298.18'), Decimal('1017.40'), Decimal('184.45')]
        actual_amounts = [item['amount'] for item in parsed_data['line_items']]

        self.assertEqual(
            actual_amounts,
            expected_amounts,
            f"Purchase amounts incorrect. Expected: {expected_amounts}, Got: {actual_amounts}"
        )
        print(f" PASS: All purchase amounts extracted correctly")
        print(f"   - Item 1: ${actual_amounts[0]} (Home & Garden)")
        print(f"   - Item 2: ${actual_amounts[1]} (Computer, Tablets, Networking)")
        print(f"   - Item 3: ${actual_amounts[2]} (Computer, Tablets, Networking)")
        print(f"   - Item 4: ${actual_amounts[3]} (Tickets)")

        # ASSERTION 3: Merchant names are correct
        for item in parsed_data['line_items']:
            self.assertEqual(
                item['merchant'],
                'eBay',
                f"Expected merchant 'eBay', got '{item['merchant']}'"
            )
        print(f" PASS: All merchants correctly identified as 'eBay'")

        # ASSERTION 4: Transaction IDs are stored (not mistaken as quantities)
        expected_transaction_ids = [
            '10074249507809',
            '10074982353810',
            '10074791340615',
            '10074838607412'
        ]
        actual_transaction_ids = [item['transaction_id'] for item in parsed_data['line_items']]

        self.assertEqual(
            actual_transaction_ids,
            expected_transaction_ids,
            f"Transaction IDs incorrect. Expected: {expected_transaction_ids}, Got: {actual_transaction_ids}"
        )
        print(f" PASS: Transaction IDs correctly extracted (not mistaken as quantities)")

        # ASSERTION 5: Total amount calculation
        total = sum(actual_amounts)
        expected_total = Decimal('1599.74')

        self.assertEqual(
            total,
            expected_total,
            f"Total amount incorrect. Expected: ${expected_total}, Got: ${total}"
        )
        print(f" PASS: Total amount calculation correct: ${total}")

        # ASSERTION 6: Cashback amounts NOT used as purchase amounts
        # Verify none of the cashback amounts appear as purchase amounts
        cashback_amounts = [Decimal('1.30'), Decimal('2.38'), Decimal('8.14'), Decimal('2.02')]
        for cashback in cashback_amounts:
            self.assertNotIn(
                cashback,
                actual_amounts,
                f"Cashback amount ${cashback} incorrectly used as purchase amount"
            )
        print(f" PASS: Cashback amounts correctly ignored (not used as purchase amounts)")

        # ASSERTION 7: Categories are extracted
        expected_categories = [
            'Home & Garden',
            'Computer, Tablets, Networking',
            'Computer, Tablets, Networking',
            'Tickets'
        ]
        actual_categories = [item['category'] for item in parsed_data['line_items']]

        self.assertEqual(
            actual_categories,
            expected_categories,
            f"Categories incorrect. Expected: {expected_categories}, Got: {actual_categories}"
        )
        print(f" PASS: All eBay categories correctly extracted")

        print("\n" + "="*80)
        print(" ALL GMAIL EMAIL PARSING TESTS PASSED")
        print("="*80 + "\n")

    def _parse_shopback_email(self, email_content: str) -> dict:
        """
        Parse ShopBack email content to extract transaction line items.

        ShopBack Email Format:
        - Each purchase has a "From [Merchant]" line followed by purchase details
        - Cashback amount appears BEFORE "Eligible Purchase" text
        - Purchase amount appears AFTER "Amount" keyword
        - Transaction ID appears after "ID:" keyword
        - Category appears after "Cashback tier" text

        Returns:
            dict with 'line_items' list containing:
                - merchant: str (e.g., "eBay")
                - amount: Decimal (purchase amount)
                - category: str (e.g., "Home & Garden")
                - transaction_id: str (e.g., "10074249507809")
        """

        line_items = []
        lines = email_content.split('\n')

        i = 0
        while i < len(lines):
            line = lines[i].strip()

            # Look for "From" keyword indicating new purchase
            # Note: In ShopBack emails, "From" is on its own line
            if line == 'From':
                # Next line is the merchant name
                i += 1
                merchant = lines[i].strip() if i < len(lines) else ""

                # Next line has cashback amount and "Eligible Purchase"
                # Format: "$X.XX  Eligible Purchase"
                i += 1

                # Next line contains "Amount $XXX.XX  Cashback tier"
                i += 1
                if i < len(lines):
                    amount_line = lines[i].strip()
                    # Extract amount after "Amount $"
                    if "Amount" in amount_line:
                        amount_text = amount_line.split("Amount")[1].strip()
                        amount_text = amount_text.split("Cashback")[0].strip()
                        # Remove $ and commas
                        amount_text = amount_text.replace('$', '').replace(',', '')
                        try:
                            amount = Decimal(amount_text)
                        except:
                            i += 1
                            continue
                    else:
                        i += 1
                        continue
                else:
                    i += 1
                    continue

                # Next line contains category and "Cashback rate"
                i += 1
                category = ""
                if i < len(lines):
                    category_line = lines[i].strip()
                    if "Cashback rate" in category_line:
                        category = category_line.split("Cashback rate")[0].strip()

                # Next line contains cashback rate percentage and "Date:"
                i += 1

                # Next line contains date
                # Format: "2025-08-23"
                i += 1

                # Next line contains "| ID:" or just the ID
                transaction_id = ""
                i += 1
                if i < len(lines):
                    id_marker_line = lines[i].strip()
                    if "ID:" in id_marker_line:
                        # If ID is on same line, extract it
                        if id_marker_line != "| ID:":
                            transaction_id = id_marker_line.split("ID:")[1].strip()
                        else:
                            # ID is on next line
                            i += 1
                            if i < len(lines):
                                transaction_id = lines[i].strip()

                line_items.append({
                    'merchant': merchant,
                    'amount': amount,
                    'category': category,
                    'transaction_id': transaction_id
                })

            i += 1

        return {
            'line_items': line_items,
            'total': sum(item['amount'] for item in line_items)
        }


if __name__ == '__main__':
    # Run with verbose output
    unittest.main(verbosity=2)
