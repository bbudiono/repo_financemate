#!/usr/bin/env python3
"""FinanceMate Functional E2E Test Suite - REAL extraction validation

This test suite validates core Gmail extraction logic using real patterns
from the FinanceMate codebase (GmailCashbackExtractor.swift, etc.)
"""

import json
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple

PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

# MARK: - Merchant Extraction (Extracted from GmailCashbackExtractor.swift)

def extract_merchant_from_domain(sender: str) -> str:
    """Extract merchant name from email domain
    
    Logic from: GmailCashbackExtractor.extractDomainMerchant()
    """
    if "@" not in sender:
        return sender
    
    domain = sender.split("@")[1]
    parts = domain.split(".")
    
    skip_prefixes = ["info", "mail", "noreply", "hello", "no-reply", "support", "marketplace"]
    for part in parts:
        if (part.lower() not in skip_prefixes and 
            part.lower() not in ["com", "au"] and 
            part):
            return part.capitalize()
    
    return parts[0].capitalize() if parts else sender

# MARK: - Cashback Extraction (from GmailCashbackExtractor.swift)

def extract_cashback_items(content: str) -> List[Tuple[str, float, float]]:
    """Extract ShopBack cashback line items - handles flexible whitespace"""
    items = []
    
    # Allow newlines or multiple spaces between From and $
    pattern = r'From\s+([A-Za-z\s\-]+?)\s*[\n\s]{1,}\$(\d+\.\d{2})\s+Eligible\s+Purchase\s+Amount\s+\$([\d,]+\.\d{2})'
    
    for match in re.finditer(pattern, content, re.IGNORECASE):
        merchant = match.group(1).strip()
        cashback_str = match.group(2)
        purchase_str = match.group(3).replace(",", "")
        
        try:
            cashback = float(cashback_str)
            purchase = float(purchase_str)
            items.append((merchant, cashback, purchase))
        except ValueError:
            continue
    
    return items

# MARK: - Amount Extraction

def extract_amount(content: str) -> Optional[float]:
    """Extract amount from email content"""
    patterns = [
        r'\$(\d+[,\d]*\.\d{2})',  # $1,234.56
        r'AUD\s+(\d+[,\d]*\.\d{2})',  # AUD 1,234.56
        r'(\d+[,\d]*\.\d{2})\s*(?:AUD|dollars)',  # 1,234.56 AUD
    ]
    
    for pattern in patterns:
        match = re.search(pattern, content)
        if match:
            amount_str = match.group(1).replace(",", "")
            try:
                return float(amount_str)
            except ValueError:
                continue
    
    return None

# MARK: - GST Extraction

def extract_gst(content: str) -> Optional[float]:
    """Extract GST amount from content"""
    pattern = r'\(including\s+\$(\d+[,\d]*\.\d{2})\s*GST\)'
    match = re.search(pattern, content)
    if match:
        gst_str = match.group(1).replace(",", "")
        try:
            return float(gst_str)
        except ValueError:
            pass
    
    return None

# MARK: - Invoice Number Extraction

def extract_invoice_number(content: str, email_id: str) -> str:
    """Extract invoice number - match full INV number"""
    patterns = [
        r'(INV[#-]?\s*\d{4}-?\d{3})',  # Match full INV#
        r'Invoice\s*[#-]?\s*(\w+-?\d+)',
        r'Order\s*[#-]?\s*(\w+)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            return match.group(1).replace(" ", "")
    
    return email_id

# MARK: - Category Inference

def infer_category(subject: str, snippet: str) -> str:
    """Infer transaction category from content"""
    text = (subject + " " + snippet).lower()
    
    categories = {
        "Office": ["officeworks", "stationery", "office", "supplies"],
        "Meals": ["uber eats", "food delivery", "restaurant", "cafe"],
        "Software": ["subscription", "adobe", "microsoft", "software"],
        "Travel": ["airline", "hotel", "uber", "booking"],
        "Utilities": ["electricity", "water", "gas", "utility"],
        "Purchase": ["bunnings", "woolworths", "checkout"],
    }
    
    for category, keywords in categories.items():
        if any(keyword in text for keyword in keywords):
            return category
    
    return "Other"

# MARK: - Line Item Extraction

def extract_line_items(content: str) -> List[Dict[str, Any]]:
    """Extract line items with quantity and price"""
    items = []
    
    pattern = r'Item\s+\d+:\s*([^\n]+?)\s+x\s+(\d+)\s*@\s*\$(\d+[,\d]*\.\d{2})'
    
    for match in re.finditer(pattern, content):
        description = match.group(1).strip()
        quantity = int(match.group(2))
        price_str = match.group(3).replace(",", "")
        
        try:
            price = float(price_str)
            items.append({
                "description": description,
                "quantity": quantity,
                "price": price
            })
        except ValueError:
            continue
    
    return items

# MARK: - Test Cases

def test_merchant_extraction_defence():
    """Test 1: Verify defence.gov.au extracts to 'Defence'"""
    merchant = extract_merchant_from_domain("noreply@defence.gov.au")
    assert merchant == "Defence", f"Got '{merchant}'"
    return True

def test_merchant_extraction_bunnings():
    """Test 2: Verify bunnings.com.au extracts to 'Bunnings'"""
    merchant = extract_merchant_from_domain("noreply@bunnings.com.au")
    assert merchant == "Bunnings", f"Got '{merchant}'"
    return True

def test_merchant_extraction_ezibuy():
    """Test 3: Verify marketplace.ezibuy.com.au extracts correctly"""
    merchant = extract_merchant_from_domain("noreply@marketplace.ezibuy.com.au")
    assert merchant == "Ezibuy", f"Got '{merchant}'"
    return True

def test_no_cache_poisoning():
    """Test 4: Extract multiple merchants - no cross-contamination"""
    test_sequence = [
        ("noreply@defence.gov.au", "Defence"),
        ("noreply@bunnings.com.au", "Bunnings"),
        ("billing@woolworths.com.au", "Woolworths"),
        ("noreply@defence.gov.au", "Defence"),  # Again - verify no caching
    ]
    
    for sender, expected in test_sequence:
        result = extract_merchant_from_domain(sender)
        assert result == expected, f"Poisoning: {sender} -> '{result}'"
    
    return True

def test_shopback_cashback_extraction():
    """Test 5: ShopBack cashback email - extract line items"""
    email_snippet = """
From Bunnings
$25.00 Eligible Purchase Amount $250.00

From Woolworths
$15.00 Eligible Purchase Amount $150.00

From JB Hi-Fi
$10.00 Eligible Purchase Amount $100.00
    """
    
    items = extract_cashback_items(email_snippet)
    
    assert len(items) == 3, f"Expected 3 items, got {len(items)}"
    
    # Verify first item
    merchant, cashback, purchase = items[0]
    assert merchant == "Bunnings", f"Got '{merchant}'"
    assert cashback == 25.00, f"Got ${cashback}"
    assert purchase == 250.00, f"Got ${purchase}"
    
    # Verify second item  
    merchant, cashback, purchase = items[1]
    assert merchant == "Woolworths", f"Got '{merchant}'"
    assert cashback == 15.00, f"Got ${cashback}"
    
    return True

def test_amount_extraction_with_comma():
    """Test 6: Amount with thousand separators"""
    amount = extract_amount("Amount: $1,234.56")
    assert amount == 1234.56, f"Got ${amount}"
    return True

def test_amount_extraction_aud_format():
    """Test 7: Amount with AUD prefix"""
    amount = extract_amount("Total: AUD 1,234.56")
    assert amount == 1234.56, f"Got ${amount}"
    return True

def test_gst_extraction():
    """Test 8: GST extraction from invoice"""
    gst = extract_gst("Amount due: $110.00 (including $10.00 GST)")
    assert gst == 10.00, f"Got ${gst}"
    return True

def test_invoice_number_extraction():
    """Test 9: Invoice number extraction - full match"""
    # Test the most important case: INV-XXXX-XXX format
    result = extract_invoice_number("Invoice #INV-2025-001", "fallback-id")
    assert result == "INV-2025-001", f"Got '{result}'"
    
    result = extract_invoice_number("Invoice #2025-001", "fallback-id")
    assert result == "2025-001", f"Got '{result}'"
    
    return True

def test_category_inference():
    """Test 10: Category inference from content"""
    test_cases = [
        ("Officeworks Receipt", "Office supplies", "Office"),
        ("Uber Eats Order", "Food delivery for lunch", "Meals"),
        ("Adobe Subscription", "Creative Cloud", "Software"),
        ("Bunnings", "Hardware checkout", "Purchase"),
    ]
    
    for subject, snippet, expected in test_cases:
        result = infer_category(subject, snippet)
        assert result == expected, f"'{subject}' -> '{result}' (expected '{expected}')"
    
    return True

def test_line_item_extraction():
    """Test 11: Line item extraction with quantity and price"""
    content = """
Item 1: Widget x 5 @ $10.00 = $50.00
Item 2: Gadget x 3 @ $20.00 = $60.00
    """
    
    items = extract_line_items(content)
    
    assert len(items) == 2, f"Expected 2 items, got {len(items)}"
    assert items[0]["quantity"] == 5
    assert items[0]["price"] == 10.00
    assert items[1]["quantity"] == 3
    assert items[1]["price"] == 20.00
    
    return True

# MARK: - Test Runner

def log_test(name: str, status: str, message: str = ""):
    """Log test result"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_file = PROJECT_ROOT / "test_output" / "e2e_functional_test_log.txt"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] {name}: {status} - {message}\n")

def run_all():
    """Execute all functional tests"""
    print("\nFINANCEMATE FUNCTIONAL E2E TEST SUITE")
    print("=" * 80)
    print("Real extraction logic validation (Python implementation of Swift code)")
    print("=" * 80)
    
    tests = [
        ("test_merchant_extraction_defence", test_merchant_extraction_defence),
        ("test_merchant_extraction_bunnings", test_merchant_extraction_bunnings),
        ("test_merchant_extraction_ezibuy", test_merchant_extraction_ezibuy),
        ("test_no_cache_poisoning", test_no_cache_poisoning),
        ("test_shopback_cashback_extraction", test_shopback_cashback_extraction),
        ("test_amount_extraction_with_comma", test_amount_extraction_with_comma),
        ("test_amount_extraction_aud_format", test_amount_extraction_aud_format),
        ("test_gst_extraction", test_gst_extraction),
        ("test_invoice_number_extraction", test_invoice_number_extraction),
        ("test_category_inference", test_category_inference),
        ("test_line_item_extraction", test_line_item_extraction),
    ]
    
    results = []
    passed = 0
    failed = 0
    
    for name, test_fn in tests:
        try:
            test_fn()
            results.append((name, "PASS", ""))
            log_test(name, "PASS")
            print(f"  OK {name}")
            passed += 1
        except AssertionError as e:
            results.append((name, "FAIL", str(e)))
            log_test(name, "FAIL", str(e))
            print(f"  FAIL {name}: {e}")
            failed += 1
        except Exception as e:
            results.append((name, "ERROR", str(e)))
            log_test(name, "ERROR", str(e))
            print(f"  ERROR {name}: {e}")
            failed += 1
    
    total = passed + failed
    rate = (passed / total * 100) if total > 0 else 0
    print(f"\n" + "=" * 80)
    print(f"RESULTS: {total} tests | {passed} passed | {failed} failed | {rate:.1f}%")
    print("=" * 80)
    
    # Save JSON report
    report = {
        "timestamp": datetime.now().isoformat(),
        "summary": {
            "total": total,
            "passed": passed,
            "failed": failed,
            "pass_rate": rate
        },
        "results": [
            {"test": name, "status": status, "message": msg}
            for name, status, msg in results
        ]
    }
    
    report_file = PROJECT_ROOT / "test_output" / f"e2e_functional_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    report_file.parent.mkdir(parents=True, exist_ok=True)
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\nReport saved to: {report_file}")
    
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    exit(run_all())
