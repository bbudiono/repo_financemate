#!/usr/bin/env python3
"""
Systematically analyze ALL 8 diverse emails for complete 13-field ground truth
"""

import json
import re
from datetime import datetime
from typing import Dict


# Reuse extraction functions from analyze_single_email.py
def extract_merchant_from_domain(sender: str) -> str:
    """Extract merchant from sender domain"""
    email_only = sender.split('<')[-1].replace('>', '').strip()
    if '@' not in email_only:
        return "Unknown"

    domain = email_only.split('@')[1]

    known_brands = {
        "nintendo.com": "Nintendo",
        "afterpay.com": "Afterpay",
        "linkt.com": "Linkt",
        "nab.com": "NAB",
        "goldcoast.qld.gov.au": "Gold Coast City Council",
        "bioteksupps.com": "BioTek",
        "amazon.com": "Amazon",
        "gmail.com": "Gmail"
    }

    for brand_domain, brand_name in known_brands.items():
        if brand_domain in domain:
            return brand_name

    parts = domain.split('.')
    skip = ["noreply", "no-reply", "updates", "digital", "contact"]

    for part in parts:
        if part.lower() not in skip and part.lower() not in ["com", "au"] and len(part) > 2:
            return part.capitalize()

    return parts[0].capitalize()


def extract_amount(text: str) -> float:
    """Extract total amount"""
    patterns = [
        r"Total[\s:]+\$?([\d,]+\.?\d{0,2})",
        r"Amount[\s:]+\$?([\d,]+\.?\d{0,2})",
        r"Grand Total[\s:]+\$?([\d,]+\.?\d{0,2})",
        r"\$\s?([\d,]+\.\d{2})"
    ]

    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            try:
                return float(match.group(1).replace(',', ''))
            except:
                continue
    return 0.0


def extract_gst(text: str) -> float:
    """Extract GST amount"""
    match = re.search(r"GST[\s:]+\$?([\d,]+\.?\d{0,2})", text, re.IGNORECASE)
    if match:
        try:
            return float(match.group(1).replace(',', ''))
        except:
            pass
    return None


def extract_abn(text: str) -> str:
    """Extract ABN"""
    match = re.search(r"ABN[\s:]+(\d{2}\s?\d{3}\s?\d{3}\s?\d{3})", text, re.IGNORECASE)
    return match.group(1) if match else None


def extract_invoice(text: str, email_id: str) -> str:
    """Extract invoice/order number"""
    patterns = [
        r"Invoice[\s#:]+([A-Z0-9-]{3,20})",
        r"Order[\s#:]+([A-Z0-9-]{3,20})",
        r"Receipt[\s#:]+([A-Z0-9-]{3,20})"
    ]

    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return match.group(1)

    return f"EMAIL-{email_id[:8]}"


def extract_payment_method(text: str) -> str:
    """Extract payment method"""
    methods = ["Visa", "Mastercard", "Amex", "PayPal", "Direct Debit", "BPAY", "Afterpay", "Zip"]
    for method in methods:
        if re.search(rf"\b{method}\b", text, re.IGNORECASE):
            return method
    return None


def analyze_email(email: Dict, index: int) -> Dict:
    """Comprehensive 13-field analysis"""
    sender = email["sender"]
    subject = email["subject"]
    body = email.get("body", email["snippet"])

    return {
        "email_number": index,
        "email_id": email["id"],
        "merchant": extract_merchant_from_domain(sender),
        "amount": extract_amount(body),
        "gst": extract_gst(body),
        "abn": extract_abn(body),
        "invoice_number": extract_invoice(body, email["id"]),
        "payment_method": extract_payment_method(body),
        "has_attachment": email.get("has_attachment", False),
        "sender": sender,
        "subject": subject,
        "body_preview": body[:300] + "..." if len(body) > 300 else body
    }


def main():
    fixture_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/diverse_emails_batch2.json"

    with open(fixture_path, 'r') as f:
        data = json.load(f)

    emails = data["emails"]

    print(f"\n{'='*100}")
    print(f"COMPREHENSIVE 13-FIELD ANALYSIS - {len(emails)} DIVERSE EMAILS")
    print(f"{'='*100}\n")

    all_analyses = []

    for i, email in enumerate(emails, 1):
        analysis = analyze_email(email, i)
        all_analyses.append(analysis)

        print(f"\n{'='*100}")
        print(f"EMAIL {i}/8")
        print(f"{'='*100}")
        print(f"From: {analysis['sender']}")
        print(f"Subject: {analysis['subject']}")
        print(f"\n🎯 GROUND TRUTH (What extraction SHOULD produce):")
        print(f"  1. Merchant:        {analysis['merchant']}")
        print(f"  2. Amount:          ${analysis['amount']:.2f}")
        print(f"  3. GST:             ${analysis['gst']:.2f}" if analysis['gst'] else "  3. GST:             None")
        print(f"  4. ABN:             {analysis['abn']}" if analysis['abn'] else "  4. ABN:             None")
        print(f"  5. Invoice#:        {analysis['invoice_number']}")
        print(f"  6. Payment:         {analysis['payment_method']}" if analysis['payment_method'] else "  6. Payment:         None")
        print(f"  7. Has Attachment:  {analysis['has_attachment']}")
        print(f"\nBody Preview:\n{analysis['body_preview']}\n")

    # Save comprehensive analysis
    output = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/diverse_batch2_analysis.json"

    with open(output, 'w') as f:
        json.dump({
            "analyzed_at": datetime.now().isoformat(),
            "total": len(all_analyses),
            "analyses": all_analyses
        }, f, indent=2)

    print(f"\n✅ Comprehensive analysis saved to: {output}")


if __name__ == "__main__":
    main()
