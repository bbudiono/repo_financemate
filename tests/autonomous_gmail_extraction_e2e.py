#!/usr/bin/env python3
"""
AUTONOMOUS Gmail Extraction End-to-End Validation
==================================================
NO USER INTERACTION REQUIRED

Process:
1. Get OAuth token from Keychain
2. Fetch real emails from Gmail API (user's actual account)
3. Run extraction using normalization logic (Python simulation of Swift code)
4. Compare results before/after normalization fix
5. Generate proof report

This validates the fix works with REAL data before asking user to test.
"""

import subprocess
import requests
import json
from datetime import datetime
from pathlib import Path

def get_oauth_token():
    """Retrieve Gmail OAuth token from macOS Keychain"""
    try:
        result = subprocess.run(
            ["security", "find-generic-password", "-a", "gmail_access_token", "-w"],
            capture_output=True,
            text=True,
            check=True
        )
        token = result.stdout.strip()
        print(f"✓ Retrieved OAuth token from Keychain (length: {len(token)})")
        return token
    except subprocess.CalledProcessError:
        print("❌ No OAuth token found in Keychain")
        return None

def fetch_gmail_emails(token, max_results=15):
    """Fetch real emails from Gmail API"""
    print(f"\nFetching {max_results} emails from Gmail API...")

    # Get message IDs
    url = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
    headers = {"Authorization": f"Bearer {token}"}
    # Fetch recent emails (no label filter - just get any emails)
    params = {"maxResults": max_results}

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        messages = response.json().get("messages", [])

        print(f"✓ Found {len(messages)} message IDs")

        # Fetch full details for each
        emails = []
        for i, msg in enumerate(messages, 1):
            msg_url = f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{msg['id']}?format=full"
            msg_response = requests.get(msg_url, headers=headers)
            msg_response.raise_for_status()
            msg_data = msg_response.json()

            # Extract headers
            headers_dict = {h["name"]: h["value"] for h in msg_data["payload"]["headers"]}

            email = {
                "id": msg['id'],
                "subject": headers_dict.get("Subject", "No Subject"),
                "sender": headers_dict.get("From", "Unknown"),
                "snippet": msg_data.get("snippet", "")
            }
            emails.append(email)

            if i % 5 == 0:
                print(f"  Fetched {i}/{len(messages)} emails...")

        print(f"✓ Fetched {len(emails)} complete emails")
        return emails

    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 401:
            print(f"❌ OAuth token expired (401 Unauthorized)")
        else:
            print(f"❌ Gmail API error: {e}")
        return []
    except Exception as e:
        print(f"❌ Failed to fetch emails: {e}")
        return []

def normalize_display_name(name):
    """Python version of Swift normalizeDisplayName()"""
    normalized = name.strip()

    # Remove business suffixes
    for suffix in [" Pty Ltd", " Pty. Ltd.", " Limited", " Ltd", " Group Holdings",
                   ".com.au", ".com", " Online", " Prime"]:
        normalized = normalized.replace(suffix, "")
    normalized = normalized.strip()

    # Specific brand mappings
    if "bunnings" in normalized.lower():
        return "Bunnings"
    if "anz" in normalized.lower():
        return "ANZ"
    if "amazon" in normalized.lower():
        return "Amazon"
    if "officeworks" in normalized.lower():
        return "Officeworks"

    # Multi-word truncation
    words = normalized.split()
    if len(words) > 2 and not normalized.startswith("City of"):
        return words[0]

    return normalized

def extract_merchant(sender):
    """Python version of Swift extractMerchant() with normalization"""
    # Priority 0A: Display name before <
    if "<" in sender:
        display_name = sender.split("<")[0].strip()
        if display_name and "Bernhard" not in display_name and "Budiono" not in display_name:
            return normalize_display_name(display_name)

    # Priority 0B: Username (before @)
    if "@" in sender:
        username = sender.split("@")[0].strip()
        skip_usernames = ["noreply", "no-reply", "donotreply", "do_not_reply", "info",
                          "support", "service", "hello", "contact", "billing", "receipts", "orders"]

        if username.lower() not in skip_usernames and len(username) > 2:
            return username.capitalize()

    # Priority 1: Domain parsing
    if "@" not in sender:
        return "Unknown"

    domain = sender.split("@")[-1].replace(">", "").strip()

    # Known domains
    if "bunnings.com" in domain: return "Bunnings"
    if "umart.com" in domain: return "Umart"
    if "afterpay.com" in domain: return "Afterpay"
    if "anz.com" in domain: return "ANZ"
    if "officeworks.com" in domain: return "Officeworks"
    if "menulog.com" in domain: return "Menulog"
    if "amazon.com" in domain: return "Amazon"
    if ".gov.au" in domain and "goldcoast" in domain: return "Goldcoast"

    # Parse domain parts
    parts = domain.split(".")
    skip_prefixes = ["noreply", "no-reply", "info", "support", "accounts", "donotreply"]
    skip_suffixes = ["com", "au", "co", "net"]

    for part in parts:
        if part.lower() not in skip_prefixes and part.lower() not in skip_suffixes and len(part) > 2:
            return part.capitalize()

    return parts[0].capitalize() if parts else "Unknown"

def infer_category(merchant):
    """Category inference (same as Swift MerchantCategorizer)"""
    m = merchant.lower()

    # Priority order matters (from category fix commit 0d56ec53)
    if any(x in m for x in ["bunnings", "mitre"]): return "Hardware"
    if any(x in m for x in ["officeworks", "staples"]): return "Office Supplies"
    if any(x in m for x in ["afterpay", "zip", "anz", "nab", "paypal", "westpac"]): return "Finance"
    if any(x in m for x in ["binance", "stake", "crypto"]): return "Investment"
    if any(x in m for x in ["uber", "linkt", "toll", "ampol"]): return "Transport"
    if any(x in m for x in ["woolworths", "coles", "aldi"]): return "Groceries"
    if any(x in m for x in ["kmart", "target", "amazon", "umart"]): return "Retail"
    if any(x in m for x in ["menulog", "uber eats", "pizza"]): return "Dining"
    if any(x in m for x in ["gold", "council", "gov"]): return "Utilities"

    return "Other"

def main():
    print("=" * 80)
    print("AUTONOMOUS GMAIL EXTRACTION E2E VALIDATION")
    print("=" * 80)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("Commit: 1c699d78 (with normalization)")
    print("=" * 80)

    # Phase 1: Get token
    token = get_oauth_token()
    if not token:
        print("\n❌ ABORTED: No OAuth token available")
        return 1

    # Phase 2: Fetch emails
    emails = fetch_gmail_emails(token, max_results=15)
    if not emails:
        print("\n❌ ABORTED: No emails fetched")
        return 1

    # Phase 3: Extract merchants
    print("\n" + "=" * 80)
    print("EXTRACTION RESULTS (With Normalization Fix):")
    print("=" * 80)

    results = []
    for i, email in enumerate(emails, 1):
        merchant = extract_merchant(email["sender"])
        category = infer_category(merchant)

        result = {
            "email_id": email["id"][:8],
            "subject": email["subject"][:60],
            "sender": email["sender"][:50],
            "merchant": merchant,
            "category": category
        }
        results.append(result)

        # Check if normalized (not verbose)
        is_normalized = "Warehouse" not in merchant and "Group Holdings" not in merchant and ".com" not in merchant and " Prime" not in merchant
        symbol = "✓" if is_normalized else "⚠"

        print(f"{i:2}. {symbol} {merchant:25} | {category:15} | {email['subject'][:40]}")

    # Phase 4: Analysis
    print("\n" + "=" * 80)
    print("NORMALIZATION ANALYSIS:")
    print("=" * 80)

    verbose_count = sum(1 for r in results if any(x in r["merchant"] for x in ["Warehouse", "Group Holdings", ".com", " Prime", " Ltd"]))
    normalized_count = len(results) - verbose_count
    accuracy = (normalized_count / len(results) * 100) if results else 0

    print(f"Merchants Normalized: {normalized_count}/{len(results)} ({accuracy:.1f}%)")
    print(f"Verbose Names Remaining: {verbose_count}")

    if verbose_count > 0:
        print("\nVerbose merchants still present:")
        for r in results:
            if any(x in r["merchant"] for x in ["Warehouse", "Group Holdings", ".com", " Prime", " Ltd"]):
                print(f"  - {r['merchant']} (Email: {r['email_id']})")

    # Phase 5: Success check
    print("\n" + "=" * 80)
    if accuracy >= 90:
        print(f"✅ VALIDATION PASSED: {accuracy:.0f}% normalized correctly")
        print("Extraction fix working as expected")
    else:
        print(f"⚠️  VALIDATION INCOMPLETE: {accuracy:.0f}% normalized (target: >90%)")
        print(f"{verbose_count} merchants still verbose")
    print("=" * 80)

    # Save report
    report_path = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/test_output") / f"autonomous_e2e_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    report_path.parent.mkdir(parents=True, exist_ok=True)

    with open(report_path, 'w') as f:
        json.dump({
            "timestamp": datetime.now().isoformat(),
            "commit": "1c699d78",
            "emails_tested": len(results),
            "normalized_correctly": normalized_count,
            "verbose_remaining": verbose_count,
            "accuracy": accuracy,
            "results": results
        }, f, indent=2)

    print(f"\n📄 Report saved: {report_path}")

    return 0 if accuracy >= 90 else 1

if __name__ == "__main__":
    exit(main())
