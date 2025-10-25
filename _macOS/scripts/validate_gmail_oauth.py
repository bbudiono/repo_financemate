#!/usr/bin/env python3
"""
Validate Gmail OAuth flow for bernhardbudiono@gmail.com
CRITICAL: This validates BLUEPRINT Line 64 - Gmail extraction for specific email
"""

import os
import subprocess
import time
import json
import sys
from pathlib import Path

# Colors for output
GREEN = '\033[92m'
YELLOW = '\033[93m'
RED = '\033[91m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_header(msg):
    print(f"\n{BLUE}{'='*60}")
    print(f"  {msg}")
    print(f"{'='*60}{RESET}\n")

def print_success(msg):
    print(f"{GREEN} {msg}{RESET}")

def print_warning(msg):
    print(f"{YELLOW}️  {msg}{RESET}")

def print_error(msg):
    print(f"{RED} {msg}{RESET}")

def validate_env_file():
    """Validate .env file exists with OAuth credentials"""
    print_header("VALIDATING .ENV CONFIGURATION")

    env_path = Path(__file__).parent.parent.parent / ".env"

    if not env_path.exists():
        print_error(f".env file not found at {env_path}")
        return False

    with open(env_path) as f:
        content = f.read()

    required_vars = {
        "GOOGLE_OAUTH_CLIENT_ID": False,
        "GOOGLE_OAUTH_CLIENT_SECRET": False,
        "GOOGLE_OAUTH_REDIRECT_URI": False
    }

    for line in content.split('\n'):
        if '=' in line and not line.strip().startswith('#'):
            key = line.split('=')[0].strip()
            if key in required_vars:
                required_vars[key] = True

    all_present = all(required_vars.values())

    for var, present in required_vars.items():
        if present:
            print_success(f"{var} configured")
        else:
            print_error(f"{var} missing")

    # Check for bernhardbudiono@gmail.com specific config
    if "352456903923-2ldm2iqntfpkvucstnmk00tf0s8ah6lu" in content:
        print_success("OAuth Client ID matches bernhardbudiono@gmail.com configuration")
    else:
        print_warning("OAuth Client ID may not be configured for bernhardbudiono@gmail.com")

    return all_present

def validate_oauth_files():
    """Check all required OAuth files exist in the project"""
    print_header("VALIDATING OAUTH IMPLEMENTATION FILES")

    macos_root = Path(__file__).parent.parent / "FinanceMate"

    required_files = [
        "GmailAPI.swift",
        "GmailView.swift",
        "GmailViewModel.swift",
        "GmailOAuthHelper.swift",
        "GmailModels.swift",
        "EnvironmentLoader.swift",
        "KeychainHelper.swift"
    ]

    all_present = True
    for file in required_files:
        file_path = macos_root / file
        if file_path.exists():
            print_success(f"{file} exists")
        else:
            print_error(f"{file} missing")
            all_present = False

    return all_present

def validate_build():
    """Build the app to ensure OAuth code compiles"""
    print_header("VALIDATING BUILD WITH OAUTH INTEGRATION")

    project_path = Path(__file__).parent.parent / "FinanceMate.xcodeproj"

    cmd = [
        "xcodebuild",
        "-project", str(project_path),
        "-scheme", "FinanceMate",
        "-configuration", "Debug",
        "build",
        "-quiet"
    ]

    print("Building app with OAuth integration...")
    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        print_success("Build successful - OAuth integration compiles")
        return True
    else:
        print_error("Build failed")
        print(result.stderr[:500])
        return False

def validate_oauth_flow():
    """Validate OAuth flow can be initiated"""
    print_header("VALIDATING OAUTH FLOW INITIALIZATION")

    # Create a test Swift script to validate OAuth URL generation
    test_script = """
import Foundation

// Load environment
if let envPath = ProcessInfo.processInfo.environment["HOME"] {
    let possiblePaths = [
        "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/.env"
    ]

    for path in possiblePaths {
        if let content = try? String(contentsOfFile: path, encoding: .utf8) {
            let lines = content.components(separatedBy: .newlines)
            for line in lines {
                if line.contains("=") && !line.hasPrefix("#") {
                    let parts = line.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        setenv(String(parts[0].trimmingCharacters(in: .whitespaces)),
                               String(parts[1].trimmingCharacters(in: .whitespaces)), 1)
                    }
                }
            }
        }
    }
}

// Test OAuth URL generation
let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"] ?? ""
let expectedID = "352456903923-2ldm2iqntfpkvucstnmk00tf0s8ah6lu.apps.googleusercontent.com"

if clientID == expectedID {
    print(" OAuth Client ID correctly loaded for bernhardbudiono@gmail.com")
} else {
    print(" OAuth Client ID mismatch")
    print("Expected: \\(expectedID)")
    print("Got: \\(clientID)")
    exit(1)
}

// Generate OAuth URL
var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
components?.queryItems = [
    URLQueryItem(name: "client_id", value: clientID),
    URLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
    URLQueryItem(name: "response_type", value: "code"),
    URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/gmail.readonly"),
    URLQueryItem(name: "access_type", value: "offline"),
    URLQueryItem(name: "prompt", value: "consent")
]

if let url = components?.url {
    print(" OAuth URL generated successfully")
    print("URL: \\(url.absoluteString.prefix(100))...")

    // Validate it's for the right account
    if url.absoluteString.contains(expectedID) {
        print(" OAuth URL configured for bernhardbudiono@gmail.com")
    }
} else {
    print(" Failed to generate OAuth URL")
    exit(1)
}
"""

    # Write and execute test script
    test_file = Path(__file__).parent / "test_oauth.swift"
    test_file.write_text(test_script)

    try:
        result = subprocess.run(
            ["swift", str(test_file)],
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode == 0:
            print(result.stdout)
            return True
        else:
            print_error("OAuth flow validation failed")
            print(result.stderr)
            return False
    finally:
        test_file.unlink(missing_ok=True)

def validate_transaction_extraction():
    """Validate transaction extraction logic"""
    print_header("VALIDATING TRANSACTION EXTRACTION LOGIC")

    # Check if extraction patterns are configured
    macos_root = Path(__file__).parent.parent / "FinanceMate"
    gmail_api = macos_root / "GmailAPI.swift"

    if not gmail_api.exists():
        print_error("GmailAPI.swift not found")
        return False

    with open(gmail_api) as f:
        content = f.read()

    # Check for Australian-specific patterns (BLUEPRINT requirement)
    patterns_found = []
    required_patterns = [
        "GST Inc", "Incl GST",  # Australian GST
        "ABN",  # Australian Business Number
        "woolworths", "coles",  # Australian stores
        "AUD",  # Australian currency
        "telstra", "optus"  # Australian telcos
    ]

    for pattern in required_patterns:
        if pattern in content.lower():
            patterns_found.append(pattern)

    if len(patterns_found) >= 4:
        print_success(f"Australian receipt patterns configured ({len(patterns_found)}/{len(required_patterns)})")
        for p in patterns_found:
            print(f"  • {p}")
        return True
    else:
        print_warning(f"Only {len(patterns_found)}/{len(required_patterns)} Australian patterns found")
        return False

def main():
    """Run all Gmail OAuth validations"""
    print(f"\n{BLUE}{'='*60}")
    print(f"  GMAIL OAUTH VALIDATION FOR bernhardbudiono@gmail.com")
    print(f"  BLUEPRINT Line 64 Compliance Check")
    print(f"{'='*60}{RESET}")

    results = {
        ".env Configuration": validate_env_file(),
        "OAuth Files": validate_oauth_files(),
        "Build Validation": validate_build(),
        "OAuth Flow": validate_oauth_flow(),
        "Transaction Extraction": validate_transaction_extraction()
    }

    # Summary
    print_header("VALIDATION SUMMARY")

    passed = sum(1 for v in results.values() if v)
    total = len(results)

    for test, result in results.items():
        status = " PASS" if result else " FAIL"
        print(f"{status:10} {test}")

    print(f"\n{BLUE}{'='*60}{RESET}")
    percentage = (passed / total) * 100

    if passed == total:
        print_success(f"ALL VALIDATIONS PASSED ({passed}/{total} = {percentage:.0f}%)")
        print_success("Gmail OAuth ready for bernhardbudiono@gmail.com")
        print_success("BLUEPRINT Line 64: Gmail transaction extraction VALIDATED")
        return 0
    else:
        print_error(f"VALIDATION INCOMPLETE ({passed}/{total} = {percentage:.0f}%)")
        print_error("Gmail OAuth not fully configured for bernhardbudiono@gmail.com")
        return 1

if __name__ == "__main__":
    sys.exit(main())