#!/usr/bin/env python3
"""
Fetch 10 diverse Gmail emails targeting specific extraction scenarios
Each email type tests different aspects of the extraction pipeline
"""

import json
import subprocess
from datetime import datetime, timedelta
from typing import Dict, List, Any

try:
    import requests
except ImportError:
    subprocess.run(["pip3", "install", "requests"], check=True)
    import requests


def get_keychain_value(account: str) -> str:
    """Retrieve value from macOS Keychain"""
    try:
        result = subprocess.run(
            ["security", "find-generic-password", "-a", account, "-w"],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None


def fetch_emails_by_query(access_token: str, query: str, max_results: int = 2) -> List[str]:
    """Fetch message IDs from Gmail API with specific query"""
    url = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
    headers = {"Authorization": f"Bearer {access_token}"}
    params = {"maxResults": max_results, "q": query}

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        return [msg["id"] for msg in data.get("messages", [])]
    except Exception as e:
        print(f"  ❌ Query failed: {e}")
        return []


def fetch_email_details(message_id: str, access_token: str) -> Dict[str, Any]:
    """Fetch full email with body and attachments"""
    url = f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{message_id}?format=full"
    headers = {"Authorization": f"Bearer {access_token}"}

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        message = response.json()

        headers_dict = {h["name"]: h["value"] for h in message["payload"]["headers"]}

        # Get full body (not just snippet)
        body = ""
        if "parts" in message["payload"]:
            for part in message["payload"]["parts"]:
                if part.get("mimeType") == "text/plain" and "data" in part.get("body", {}):
                    import base64
                    body = base64.urlsafe_b64decode(part["body"]["data"]).decode('utf-8', errors='ignore')
                    break

        if not body:
            body = message.get("snippet", "")

        # Check for attachments
        has_attachment = any("filename" in part and part["filename"] for part in message["payload"].get("parts", []))

        return {
            "id": message_id,
            "subject": headers_dict.get("Subject", "No Subject"),
            "sender": headers_dict.get("From", "Unknown"),
            "date": headers_dict.get("Date", ""),
            "snippet": message.get("snippet", ""),
            "body": body,
            "has_attachment": has_attachment,
            "raw_headers": headers_dict
        }
    except Exception as e:
        print(f"  ❌ Failed to fetch email: {e}")
        return None


def main():
    print("🔐 Retrieving Gmail access token...")
    access_token = get_keychain_value("gmail_access_token")

    if not access_token:
        print("❌ No access token. Please authenticate in FinanceMate first.")
        return

    # Define diverse email queries to test different extraction scenarios
    queries = [
        ("has:attachment invoice OR receipt", "PDF attachments"),
        ("ABN GST tax invoice", "Australian ABN invoices"),
        ("Bunnings OR Woolworths OR Coles", "Major retailers"),
        ("Afterpay OR Zip payment", "BNPL intermediaries"),
        ("Uber OR taxi OR petrol", "Transport"),
        ("electricity OR gas OR internet bill", "Utilities"),
        ("council rates OR fine", "Government"),
        ("chemist OR pharmacy", "Healthcare"),
        ("subscription OR membership", "Subscriptions"),
        ("restaurant OR cafe OR food", "Dining")
    ]

    print(f"\n📧 Fetching 10 diverse emails (1 per category)...")
    print("=" * 80)

    all_emails = []
    email_ids_seen = set()

    for query, description in queries:
        print(f"\n🔍 {description}: {query}")

        message_ids = fetch_emails_by_query(access_token, query, max_results=1)

        if not message_ids:
            print("  ⚠️  No emails found")
            continue

        for msg_id in message_ids:
            if msg_id in email_ids_seen:
                continue

            email = fetch_email_details(msg_id, access_token)
            if email:
                all_emails.append(email)
                email_ids_seen.add(msg_id)
                print(f"  ✓ From: {email['sender'][:50]}")
                print(f"  ✓ Subject: {email['subject'][:60]}")
                print(f"  ✓ Has Attachment: {email['has_attachment']}")
                break

    # Save to fixture
    output_file = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/diverse_emails_batch2.json"

    with open(output_file, 'w') as f:
        json.dump({
            "fetched_at": datetime.now().isoformat(),
            "total_emails": len(all_emails),
            "emails": all_emails
        }, f, indent=2)

    print(f"\n\n✅ Saved {len(all_emails)} diverse emails to: {output_file}")

    print("\n📊 Email Summary:")
    for i, email in enumerate(all_emails, 1):
        domain = email['sender'].split('@')[-1].split('>')[0] if '@' in email['sender'] else 'unknown'
        attachment = "📎" if email['has_attachment'] else "  "
        print(f"  {i}. {attachment} {domain[:35]:35} | {email['subject'][:45]}")


if __name__ == "__main__":
    main()
