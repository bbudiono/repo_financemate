#!/usr/bin/env python3
"""
Analyze real Gmail samples and extract ground truth for each email
Creates expected test results for E2E validation
"""

import json
import re
from typing import Dict, Any


def extract_domain_merchant(sender: str) -> str:
    """Extract merchant name from email sender domain (authoritative source)"""
    # Remove display name and angle brackets
    email_only = sender.split('<')[-1].replace('>', '').strip()

    # Extract domain
    if '@' not in email_only:
        return "Unknown"

    domain = email_only.split('@')[1]
    parts = domain.split('.')

    # Skip common prefixes
    skip_prefixes = ["noreply", "no-reply", "info", "mail", "hello", "support", "receipts", "orders", "donotreply", "do_not_reply", "service"]
    skip_suffixes = ["com", "au", "co", "net", "org"]

    # Find first meaningful part
    for part in parts:
        if part.lower() not in skip_prefixes and part.lower() not in skip_suffixes and len(part) > 2:
            # Clean up known merchants
            merchant_map = {
                "umart": "Umart",
                "afterpay": "Afterpay",
                "binance": "Binance",
                "paypal": "PayPal",
                "nintendo": "Nintendo",
                "activepipe": "ActivePipe",
                "gmail": "Gmail",  # Personal emails
                "gymandfitness": "Gym and Fitness",
                "bunnings": "Bunnings",
                "klook": "Klook",
                "clevarea": "Clevarea"
            }
            return merchant_map.get(part.lower(), part.capitalize())

    return parts[0].capitalize() if parts else "Unknown"


def extract_amount(snippet: str) -> float:
    """Extract amount from email snippet"""
    # Look for total patterns
    patterns = [
        r"Total:?\s?\$?(\d{1,6}[,.]?\d{0,2})",
        r"Amount:?\s?\$?(\d{1,6}[,.]?\d{0,2})",
        r"\$(\d{1,6}[,.]\d{2})",  # Generic dollar amount
    ]

    for pattern in patterns:
        match = re.search(pattern, snippet, re.IGNORECASE)
        if match:
            amount_str = match.group(1).replace(',', '')
            try:
                return float(amount_str)
            except ValueError:
                continue

    return 0.0


def analyze_email(email: Dict[str, Any], index: int) -> Dict[str, Any]:
    """Analyze a single email and extract ground truth"""
    sender = email["sender"]
    subject = email["subject"]
    snippet = email["snippet"]

    # Ground truth: Merchant = sender domain (authoritative)
    merchant = extract_domain_merchant(sender)

    # Extract amount
    amount = extract_amount(snippet)

    # Extract payment method
    payment_keywords = ["Visa", "Mastercard", "Amex", "PayPal", "Direct Debit", "BPAY", "Afterpay", "Zip"]
    payment_method = None
    for method in payment_keywords:
        if method.lower() in snippet.lower():
            payment_method = method
            break

    return {
        "email_number": index,
        "email_id": email["id"],
        "expected_merchant": merchant,
        "expected_amount": amount,
        "expected_payment_method": payment_method,
        "sender": sender,
        "subject": subject,
        "snippet_preview": snippet[:200] + "..." if len(snippet) > 200 else snippet
    }


def main():
    # Load real Gmail samples
    fixture_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/real_gmail_samples.json"

    with open(fixture_path, 'r') as f:
        data = json.load(f)

    emails = data["emails"]

    print(f"\n📧 Analyzing {len(emails)} Real Gmail Emails")
    print("=" * 100)

    analyzed = []
    for i, email in enumerate(emails, 1):
        result = analyze_email(email, i)
        analyzed.append(result)

        print(f"\n{'='*100}")
        print(f"EMAIL {i}/10")
        print(f"{'='*100}")
        print(f"From: {result['sender']}")
        print(f"Subject: {result['subject']}")
        print(f"\n✓ EXPECTED MERCHANT: {result['expected_merchant']}")
        print(f"✓ EXPECTED AMOUNT: ${result['expected_amount']}")
        print(f"✓ EXPECTED PAYMENT: {result['expected_payment_method'] or 'Not found'}")
        print(f"\nSnippet Preview:\n{result['snippet_preview']}")

    # Save analysis results
    output_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/gmail_analysis_ground_truth.json"

    with open(output_path, 'w') as f:
        json.dump({
            "analyzed_at": data["fetched_at"],
            "total_analyzed": len(analyzed),
            "ground_truth": analyzed
        }, f, indent=2)

    print(f"\n\n✅ Analysis saved to: {output_path}")
    print(f"\n📊 Merchant Distribution:")

    merchants = {}
    for item in analyzed:
        m = item["expected_merchant"]
        merchants[m] = merchants.get(m, 0) + 1

    for merchant, count in sorted(merchants.items(), key=lambda x: x[1], reverse=True):
        print(f"  {merchant}: {count} emails")


if __name__ == "__main__":
    main()
