#!/usr/bin/env python3
"""
Fetch 10 real Gmail emails for E2E test fixture creation
Uses existing Gmail OAuth tokens from Keychain to authenticate
Saves complete email data as JSON for repeatable testing
"""

import json
import subprocess
from datetime import datetime, timedelta
from typing import Dict, List, Any

try:
    import requests
except ImportError:
    print("❌ requests library not found. Installing...")
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
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to get {account} from Keychain: {e}")
        return None


def fetch_gmail_messages(access_token: str, max_results: int = 10, label_filter: str = None) -> List[str]:
    """Fetch message IDs from Gmail API with optional label filtering"""
    # Search last 6 months of financial emails
    six_months_ago = datetime.now() - timedelta(days=180)
    after_date = six_months_ago.strftime("%Y/%m/%d")

    # Build query with optional label
    if label_filter:
        query = f"label:{label_filter} after:{after_date}"
        print(f"📋 Filtering by label: {label_filter}")
    else:
        query = f"in:anywhere after:{after_date} (receipt OR invoice OR payment OR order)"

    url = "https://gmail.googleapis.com/gmail/v1/users/me/messages"
    headers = {"Authorization": f"Bearer {access_token}"}
    params = {"maxResults": max_results, "q": query}

    print(f"🔍 Query: {query}")

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        return [msg["id"] for msg in data.get("messages", [])]
    except Exception as e:
        print(f"❌ Failed to fetch message list: {e}")
        return []


def fetch_email_details(message_id: str, access_token: str) -> Dict[str, Any]:
    """Fetch full email details including headers and body"""
    url = f"https://gmail.googleapis.com/gmail/v1/users/me/messages/{message_id}?format=full"
    headers = {"Authorization": f"Bearer {access_token}"}

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        message = response.json()

        # Extract headers
        header_dict = {h["name"]: h["value"] for h in message["payload"]["headers"]}

        # Extract body text (simplified - just use snippet for now)
        snippet = message.get("snippet", "")

        return {
            "id": message_id,
            "subject": header_dict.get("Subject", "No Subject"),
            "sender": header_dict.get("From", "Unknown"),
            "date": header_dict.get("Date", ""),
            "snippet": snippet,
            "raw_headers": header_dict
        }
    except Exception as e:
        print(f"❌ Failed to fetch email {message_id}: {e}")
        return None


def main():
    import sys

    # Check for label filter argument
    label_filter = sys.argv[1] if len(sys.argv) > 1 else None
    output_suffix = f"_{label_filter}" if label_filter else ""

    print("🔐 Retrieving Gmail access token from Keychain...")
    access_token = get_keychain_value("gmail_access_token")

    if not access_token:
        print("❌ No access token found. Please authenticate in FinanceMate first.")
        return

    print(f"📧 Fetching 10 real Gmail emails{f' with label: {label_filter}' if label_filter else ''}...")
    message_ids = fetch_gmail_messages(access_token, max_results=10, label_filter=label_filter)

    if not message_ids:
        print("❌ No messages found or API error")
        return

    print(f"✓ Found {len(message_ids)} messages")

    emails = []
    for i, msg_id in enumerate(message_ids, 1):
        print(f"  {i}/10 Fetching email {msg_id[:8]}...")
        email = fetch_email_details(msg_id, access_token)
        if email:
            emails.append(email)
            print(f"    ✓ From: {email['sender'][:40]}")
            print(f"    ✓ Subject: {email['subject'][:60]}")

    # Save to JSON fixture with label suffix
    output_file = f"/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/tests/fixtures/real_gmail_samples{output_suffix}.json"

    with open(output_file, 'w') as f:
        json.dump({
            "fetched_at": datetime.now().isoformat(),
            "label_filter": label_filter,
            "total_emails": len(emails),
            "emails": emails
        }, f, indent=2)

    print(f"\n✅ Saved {len(emails)} emails to: {output_file}")
    print("\n📊 Email Summary:")
    for i, email in enumerate(emails, 1):
        sender_domain = email['sender'].split('@')[-1].split('>')[0] if '@' in email['sender'] else 'unknown'
        print(f"  {i}. {sender_domain[:30]:30} | {email['subject'][:50]}")


if __name__ == "__main__":
    main()
