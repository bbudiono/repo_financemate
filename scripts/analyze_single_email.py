#!/usr/bin/env python3
"""
Fetch and analyze a SINGLE Gmail email with complete field extraction
Shows what the current extraction logic produces vs what it SHOULD produce

Usage: python3 analyze_single_email.py <email_index_from_screenshot>
"""

import sys
import json
import re
from typing import Dict, Any


def extract_all_fields_manual(email: Dict[str, Any]) -> Dict[str, Any]:
    """
    Manually analyze email and extract ground truth for ALL 13 fields
    This is what the extraction SHOULD produce
    """
    sender = email["sender"]
    subject = email["subject"]
    snippet = email["snippet"]

    # Field 1: ID (from email)
    email_id = email["id"]

    # Field 2: Merchant (from sender domain - authoritative)
    merchant = extract_merchant_from_domain(sender)

    # Field 3: Amount (final total)
    amount = extract_amount_comprehensive(snippet)

    # Field 4: Date (from email date header)
    date = email.get("date", "Unknown")

    # Field 5: Category (inferred from merchant)
    category = infer_category(merchant, subject, snippet)

    # Field 6: Items (line items)
    items = extract_line_items(snippet)

    # Field 7: Confidence (based on data quality)
    confidence = calculate_confidence(merchant, amount, snippet)

    # Field 8: Email Subject
    email_subject = subject

    # Field 9: Email Sender
    email_sender = sender

    # Field 10: GST Amount (Australian tax)
    gst_amount = extract_gst(snippet)

    # Field 11: ABN (Australian Business Number)
    abn = extract_abn(snippet)

    # Field 12: Invoice Number
    invoice_number = extract_invoice_number(snippet, email_id)

    # Field 13: Payment Method
    payment_method = extract_payment_method(snippet)

    return {
        "id": email_id,
        "merchant": merchant,
        "amount": amount,
        "date": date,
        "category": category,
        "items": items,
        "confidence": confidence,
        "rawText": snippet[:200] + "...",
        "emailSubject": email_subject,
        "emailSender": email_sender,
        "gstAmount": gst_amount,
        "abn": abn,
        "invoiceNumber": invoice_number,
        "paymentMethod": payment_method
    }


def extract_merchant_from_domain(sender: str) -> str:
    """Extract merchant from sender domain (ground truth method)"""
    # Remove display name and extract email
    email_only = sender.split('<')[-1].replace('>', '').strip()

    if '@' not in email_only:
        return "Unknown"

    domain = email_only.split('@')[1]

    # Check for known brands first
    known_brands = {
        "binance.com": "Binance",
        "nintendo.com": "Nintendo",
        "paypal.com": "PayPal",
        "afterpay.com": "Afterpay",
        "bunnings.com": "Bunnings",
        "woolworths.com": "Woolworths",
        "coles.com": "Coles",
        "klook.com": "Klook",
        "umart.com": "Umart",
        "apple.com": "Apple",
        "gymandfitness.com": "Gym and Fitness",
        "clevarea.com": "Clevarea",
        "anz.com": "ANZ",
        "amigoenergy.com": "Amigo Energy"
    }

    for brand_domain, brand_name in known_brands.items():
        if brand_domain in domain:
            return brand_name

    # Parse domain parts
    parts = domain.split('.')
    skip_prefixes = ["noreply", "no-reply", "donotreply", "do_not_reply", "info", "mail", "support", "receipts", "orders", "service", "accounts", "mgdirectmail", "notify"]
    skip_suffixes = ["com", "au", "co", "net", "org"]

    for part in parts:
        if part.lower() not in skip_prefixes and part.lower() not in skip_suffixes and len(part) > 2:
            return part.capitalize()

    return parts[0].capitalize() if parts else "Unknown"


def extract_amount_comprehensive(snippet: str) -> float:
    """Extract final total amount (most aggressive search)"""
    # Priority patterns (in order)
    patterns = [
        r"(?:Total|Grand Total|Amount Due|Total Amount|Final Total|Total Paid|Amount Paid)[\s:]+\$?([\d,]+\.?\d{0,2})",
        r"Total:\s*\$?([\d,]+\.?\d{2})",
        r"Amount:\s*\$?([\d,]+\.?\d{2})",
        r"\$\s?([\d,]+\.\d{2})"  # Generic dollar amount
    ]

    for pattern in patterns:
        match = re.search(pattern, snippet, re.IGNORECASE)
        if match:
            amount_str = match.group(1).replace(',', '').replace('$', '')
            try:
                return float(amount_str)
            except ValueError:
                continue

    return 0.0


def extract_gst(snippet: str) -> float:
    """Extract GST amount"""
    match = re.search(r"GST[\s:]+\$?([\d,]+\.?\d{0,2})", snippet, re.IGNORECASE)
    if match:
        try:
            return float(match.group(1).replace(',', ''))
        except ValueError:
            pass
    return None


def extract_abn(snippet: str) -> str:
    """Extract Australian Business Number"""
    match = re.search(r"ABN[\s:]+(\d{2}\s?\d{3}\s?\d{3}\s?\d{3})", snippet, re.IGNORECASE)
    if match:
        return match.group(1)
    return None


def extract_invoice_number(snippet: str, email_id: str) -> str:
    """Extract invoice/order/receipt number"""
    patterns = [
        r"Invoice[\s#:]+([A-Z0-9-]{3,20})",
        r"Order[\s#:]+([A-Z0-9-]{3,20})",
        r"Receipt[\s#:]+([A-Z0-9-]{3,20})",
        r"Reference[\s#:]+([A-Z0-9-]{3,20})"
    ]

    for pattern in patterns:
        match = re.search(pattern, snippet, re.IGNORECASE)
        if match:
            invoice = match.group(1)
            # Reject generic placeholders
            if invoice not in ["INV123", "INVOICE", "ORDER"]:
                return invoice

    # Fallback: Use email ID prefix
    return f"EMAIL-{email_id[:8]}"


def extract_payment_method(snippet: str) -> str:
    """Extract payment method"""
    methods = ["Visa", "Mastercard", "Amex", "American Express", "PayPal", "Direct Debit", "BPAY", "Afterpay", "Zip", "Apple Pay", "Google Pay"]

    for method in methods:
        if re.search(rf"\b{method}\b", snippet, re.IGNORECASE):
            return method

    return None


def infer_category(merchant: str, subject: str, snippet: str) -> str:
    """Infer category from merchant and content"""
    category_keywords = {
        "Groceries": ["woolworths", "coles", "iga", "aldi"],
        "Retail": ["bunnings", "kmart", "target", "big w", "officeworks"],
        "Dining": ["restaurant", "cafe", "pizza", "uber eats", "menulog", "doordash"],
        "Transport": ["uber", "ola", "taxi", "petrol", "fuel"],
        "Utilities": ["energy", "electricity", "gas", "water", "internet", "phone"],
        "Healthcare": ["chemist", "pharmacy", "doctor", "medical", "dental"],
        "Entertainment": ["netflix", "spotify", "apple music", "cinema", "movie"],
        "Gaming": ["nintendo", "playstation", "xbox", "steam"],
        "Finance": ["anz", "nab", "commonwealth", "westpac", "paypal", "afterpay", "zip"],
        "Investment": ["binance", "coinbase", "stake", "commsec"]
    }

    combined_text = (merchant + " " + subject + " " + snippet).lower()

    for category, keywords in category_keywords.items():
        for keyword in keywords:
            if keyword in combined_text:
                return category

    return "Other"


def extract_line_items(snippet: str) -> int:
    """Count line items (simplified - just return count estimate)"""
    # Look for patterns like "1x Item $10.00" or "Item - $10.00"
    item_pattern = r"\d+x\s+.+?\$[\d,]+\.?\d{0,2}"
    matches = re.findall(item_pattern, snippet, re.IGNORECASE)
    return len(matches)


def calculate_confidence(merchant: str, amount: float, snippet: str) -> float:
    """Calculate extraction confidence"""
    score = 0.0
    if merchant and merchant != "Unknown": score += 0.3
    if amount > 0: score += 0.3
    if "invoice" in snippet.lower() or "receipt" in snippet.lower(): score += 0.2
    if re.search(r"ABN|GST", snippet, re.IGNORECASE): score += 0.2
    return min(score, 1.0)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_single_email.py <email_number_1_to_10>")
        sys.exit(1)

    email_index = int(sys.argv[1]) - 1

    # Load previously fetched emails
    fixture_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/real_gmail_samples.json"

    try:
        with open(fixture_path, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"❌ Fixture file not found. Run fetch_real_gmail_samples.py first.")
        sys.exit(1)

    emails = data["emails"]

    if email_index < 0 or email_index >= len(emails):
        print(f"❌ Email index {email_index + 1} out of range (1-{len(emails)})")
        sys.exit(1)

    email = emails[email_index]

    print("=" * 100)
    print(f"📧 EMAIL #{email_index + 1} - COMPREHENSIVE 13-FIELD ANALYSIS")
    print("=" * 100)

    print(f"\n📨 EMAIL HEADERS:")
    print(f"  From: {email['sender']}")
    print(f"  Subject: {email['subject']}")
    print(f"  Date: {email.get('date', 'Unknown')}")
    print(f"  ID: {email['id']}")

    print(f"\n📄 EMAIL BODY (first 500 chars):")
    print(f"  {email['snippet'][:500]}")
    if len(email['snippet']) > 500:
        print(f"  ... ({len(email['snippet']) - 500} more chars)")

    print("\n" + "=" * 100)
    print("🎯 GROUND TRUTH EXTRACTION (What SHOULD be extracted):")
    print("=" * 100)

    ground_truth = extract_all_fields_manual(email)

    for i, (field, value) in enumerate(ground_truth.items(), 1):
        if isinstance(value, float):
            print(f"  {i:2}. {field:20} = ${value:.2f}" if value > 0 else f"  {i:2}. {field:20} = {value}")
        else:
            print(f"  {i:2}. {field:20} = {value}")

    # Save analysis to file
    output_file = f"/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/email_{email_index + 1}_analysis.json"

    with open(output_file, 'w') as f:
        json.dump({
            "email_number": email_index + 1,
            "email_id": email["id"],
            "original_email": email,
            "ground_truth": ground_truth
        }, f, indent=2)

    print(f"\n✅ Analysis saved to: {output_file}")

    print("\n" + "=" * 100)
    print("📋 NEXT STEPS:")
    print("=" * 100)
    print(f"1. Review ground truth values above")
    print(f"2. Create E2E test in RealGmailExtractionTests.swift:")
    print(f"   func testEmail{email_index + 1}_<MerchantName>_AllFields() async")
    print(f"3. Run test - watch it fail")
    print(f"4. Fix extraction logic to make test pass")
    print(f"5. Validate no regressions in other tests")


if __name__ == "__main__":
    main()
