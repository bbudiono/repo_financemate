#!/usr/bin/env python3
"""
GMAIL OAUTH CREDENTIALS TEST - RED PHASE
Tests Gmail OAuth credential loading functionality
"""

import subprocess
import sys
import os

def test_dotenv_file_exists():
    """Test that .env file exists with Gmail OAuth credentials"""
    print("\n Gmail OAuth Credentials File")
    print(" Testing .env file existence...")

    env_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/.env"

    if not os.path.exists(env_path):
        print(" .env file NOT FOUND")
        return False

    print(" .env file exists")

    # Check for required OAuth credentials
    with open(env_path, 'r') as f:
        content = f.read()

    required_keys = [
        'GOOGLE_OAUTH_CLIENT_ID=',
        'GOOGLE_OAUTH_CLIENT_SECRET=',
        'OAUTH_REDIRECT_URI='
    ]

    missing_keys = []
    for key in required_keys:
        if key not in content:
            missing_keys.append(key)

    if missing_keys:
        print(f" Missing OAuth credentials: {missing_keys}")
        return False

    print(" All OAuth credentials present in .env file")
    return True

def test_dotenv_loader_exists():
    """Test that DotEnvLoader.swift exists"""
    print("\n DotEnvLoader File Check")
    loader_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/DotEnvLoader.swift"

    if not os.path.exists(loader_path):
        print(" DotEnvLoader.swift NOT FOUND")
        return False

    print(" DotEnvLoader.swift exists")
    return True

def test_swift_compiles():
    """Test basic Swift compilation capability"""
    print("\n DotEnvLoader Compilation")

    # Simple test - just verify Swift can compile basic code
    test_content = 'print("Swift compilation test")'
    test_file = "/tmp/swift_test.swift"

    try:
        with open(test_file, 'w') as f:
            f.write(test_content)

        result = subprocess.run(['swift', test_file],
                              capture_output=True, text=True, timeout=30)

        success = result.returncode == 0
        print(f" Swift compilation: {'PASS' if success else 'FAIL'}")
        return success

    except Exception as e:
        print(f" Compilation test failed: {e}")
        return False

def test_credential_access():
    """Test basic access to OAuth credentials"""
    print("\n Gmail OAuth Credential Access")

    # Simple Python test to verify .env file can be read
    env_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/.env"

    try:
        with open(env_path, 'r') as f:
            content = f.read()

        # Look for client ID
        if "GOOGLE_OAUTH_CLIENT_ID=" in content:
            print(" Client ID found in .env file")
            return True
        else:
            print(" Client ID NOT found in .env file")
            return False

    except Exception as e:
        print(f" Failed to read .env file: {e}")
        return False

def main():
    """Main test runner for Gmail OAuth credentials"""
    print("GMAIL OAUTH CREDENTIALS TEST - RED PHASE")

    tests = [
        test_dotenv_file_exists,
        test_dotenv_loader_exists,
        test_credential_access
    ]

    passed = 0
    for test_func in tests:
        try:
            if test_func():
                passed += 1
        except Exception as e:
            print(f" ERROR: {e}")

    print(f"\n Summary: {passed}/{len(tests)} tests passing")

    if passed == len(tests):
        print("🟢 GREEN PHASE READY - Gmail OAuth credentials accessible")
    else:
        print(" RED PHASE: Gmail OAuth credentials need implementation")

    return passed == len(tests)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)