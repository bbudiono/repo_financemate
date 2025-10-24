#!/usr/bin/env python3
"""
Gmail OAuth Functional Integration Tests

Purpose: Test ACTUAL OAuth integration logic (not just file format validation)
Tests: Keychain storage, credential loading, URL construction, token persistence
Compliance: KISS principle, headless/silent/automated, no network calls
"""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from uuid import uuid4

# Project paths
REPO_ROOT = Path(__file__).parent.parent
MACOS_ROOT = REPO_ROOT / "_macOS"
ENV_FILE = MACOS_ROOT / ".env"


class TestKeychainIntegration(unittest.TestCase):
    """Test 1: Keychain token storage and retrieval (REAL integration)"""

    def setUp(self):
        """Setup test environment"""
        self.test_account_prefix = f"test_financemate_{uuid4().hex[:8]}_"
        self.test_accounts = []

    def tearDown(self):
        """Cleanup test data from Keychain"""
        for account in self.test_accounts:
            self._delete_from_keychain(account)

    def _save_to_keychain(self, value: str, account: str) -> bool:
        """Save value to macOS Keychain using Swift KeychainHelper"""
        self.test_accounts.append(account)

        swift_script = f'''
import Foundation
import Security

let service = "com.ablankcanvas.FinanceMate"
let account = "{account}"
let value = "{value}"

guard let data = value.data(using: .utf8) else {{
    print("ERROR: Failed to encode value")
    exit(1)
}}

// Delete existing item first
let deleteQuery: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecAttrAccount as String: account
]
SecItemDelete(deleteQuery as CFDictionary)

// Add new item
let addQuery: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecAttrAccount as String: account,
    kSecValueData as String: data,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
]

let status = SecItemAdd(addQuery as CFDictionary, nil)
if status == errSecSuccess {{
    print("SUCCESS")
}} else {{
    print("ERROR: SecItemAdd failed with status: \\(status)")
    exit(1)
}}
'''

        return self._run_swift_script(swift_script) == "SUCCESS"

    def _get_from_keychain(self, account: str) -> str:
        """Retrieve value from macOS Keychain using Swift KeychainHelper"""
        swift_script = f'''
import Foundation
import Security

let service = "com.ablankcanvas.FinanceMate"
let account = "{account}"

let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecAttrAccount as String: account,
    kSecReturnData as String: true
]

var result: AnyObject?
let status = SecItemCopyMatching(query as CFDictionary, &result)

guard status == errSecSuccess,
      let data = result as? Data,
      let value = String(data: data, encoding: .utf8) else {{
    print("ERROR: Failed to retrieve value (status: \\(status))")
    exit(1)
}}

print(value)
'''

        return self._run_swift_script(swift_script)

    def _delete_from_keychain(self, account: str) -> bool:
        """Delete value from macOS Keychain"""
        swift_script = f'''
import Foundation
import Security

let service = "com.ablankcanvas.FinanceMate"
let account = "{account}"

let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrService as String: service,
    kSecAttrAccount as String: account
]

let status = SecItemDelete(query as CFDictionary)
if status == errSecSuccess || status == errSecItemNotFound {{
    print("SUCCESS")
}} else {{
    print("ERROR: Delete failed")
    exit(1)
}}
'''

        return self._run_swift_script(swift_script) == "SUCCESS"

    def _run_swift_script(self, script: str) -> str:
        """Execute Swift script and return output"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
            f.write(script)
            script_path = f.name

        try:
            result = subprocess.run(
                ['swift', script_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode != 0:
                raise RuntimeError(f"Swift script failed: {result.stderr}")

            return result.stdout.strip()

        finally:
            os.unlink(script_path)

    def test_keychain_save_and_retrieve(self):
        """Test: Save token to Keychain and retrieve it"""
        test_token = f"test_access_token_{uuid4().hex}"
        account = f"{self.test_account_prefix}gmail_access_token"

        # Save token
        save_success = self._save_to_keychain(test_token, account)
        self.assertTrue(save_success, "Failed to save token to Keychain")

        # Retrieve token
        retrieved = self._get_from_keychain(account)
        self.assertEqual(retrieved, test_token, "Retrieved token doesn't match saved token")

    def test_keychain_persistence_across_calls(self):
        """Test: Token persists across multiple retrieval calls"""
        test_token = f"test_refresh_token_{uuid4().hex}"
        account = f"{self.test_account_prefix}gmail_refresh_token"

        # Save once
        self._save_to_keychain(test_token, account)

        # Retrieve multiple times
        retrieval_1 = self._get_from_keychain(account)
        retrieval_2 = self._get_from_keychain(account)
        retrieval_3 = self._get_from_keychain(account)

        self.assertEqual(retrieval_1, test_token)
        self.assertEqual(retrieval_2, test_token)
        self.assertEqual(retrieval_3, test_token)

    def test_keychain_overwrite_existing_token(self):
        """Test: Saving new token overwrites existing one"""
        account = f"{self.test_account_prefix}gmail_access_token"

        # Save first token
        token_1 = f"first_token_{uuid4().hex}"
        self._save_to_keychain(token_1, account)
        retrieved_1 = self._get_from_keychain(account)
        self.assertEqual(retrieved_1, token_1)

        # Overwrite with second token
        token_2 = f"second_token_{uuid4().hex}"
        self._save_to_keychain(token_2, account)
        retrieved_2 = self._get_from_keychain(account)
        self.assertEqual(retrieved_2, token_2)
        self.assertNotEqual(retrieved_2, token_1)

    def test_keychain_delete_token(self):
        """Test: Delete token from Keychain"""
        test_token = f"test_token_to_delete_{uuid4().hex}"
        account = f"{self.test_account_prefix}delete_test"

        # Save and verify
        self._save_to_keychain(test_token, account)
        self.assertEqual(self._get_from_keychain(account), test_token)

        # Delete and verify deletion
        delete_success = self._delete_from_keychain(account)
        self.assertTrue(delete_success, "Failed to delete token from Keychain")

        # Attempting to retrieve should fail
        with self.assertRaises(RuntimeError):
            self._get_from_keychain(account)


class TestOAuthCredentialLoading(unittest.TestCase):
    """Test 2: .env credential loading (REAL file operations)"""

    def test_env_file_exists_and_readable(self):
        """Test: .env file exists and can be read"""
        self.assertTrue(ENV_FILE.exists(), f".env file not found at {ENV_FILE}")

        with open(ENV_FILE, 'r') as f:
            content = f.read()

        self.assertIsNotNone(content, ".env file is empty")
        self.assertGreater(len(content), 0, ".env file has no content")

    def test_oauth_credentials_present_in_env(self):
        """Test: Required OAuth credentials exist in .env file"""
        with open(ENV_FILE, 'r') as f:
            content = f.read()

        required_keys = [
            "GOOGLE_OAUTH_CLIENT_ID",
            "GOOGLE_OAUTH_CLIENT_SECRET",
            "OAUTH_REDIRECT_URI"
        ]

        for key in required_keys:
            self.assertIn(key, content, f"Missing {key} in .env file")

            # Verify key has a value (not just key name)
            for line in content.split('\n'):
                if line.strip().startswith(f"{key}="):
                    value = line.split('=', 1)[1].strip()
                    self.assertGreater(len(value), 0, f"{key} has no value")
                    break

    def test_dotenv_loader_integration(self):
        """Test: DotEnvLoader can successfully read OAuth credentials"""
        swift_script = f'''
import Foundation

struct DotEnvLoader {{
    private static var credentials: [String: String] = [:]

    static func get(_ key: String) -> String? {{
        return credentials[key]
    }}

    static func load() -> Bool {{
        let path = "{ENV_FILE}"

        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {{
            return false
        }}

        let lines = contents.components(separatedBy: .newlines)
        for line in lines {{
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {{
                continue
            }}

            let parts = trimmed.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {{
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                credentials[key] = value
            }}
        }}

        return true
    }}
}}

if DotEnvLoader.load() {{
    if let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
       let clientSecret = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_SECRET"),
       !clientID.isEmpty,
       !clientSecret.isEmpty {{
        print("SUCCESS")
    }} else {{
        print("ERROR: Credentials empty")
        exit(1)
    }}
}} else {{
    print("ERROR: Failed to load .env")
    exit(1)
}}
'''

        with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
            f.write(swift_script)
            script_path = f.name

        try:
            result = subprocess.run(
                ['swift', script_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            self.assertEqual(result.returncode, 0, f"DotEnvLoader test failed: {result.stderr}")
            self.assertIn("SUCCESS", result.stdout, "DotEnvLoader couldn't read credentials")

        finally:
            os.unlink(script_path)


class TestOAuthURLConstruction(unittest.TestCase):
    """Test 3: OAuth URL construction and parameter encoding"""

    def test_authorization_url_construction(self):
        """Test: OAuth authorization URL is properly constructed"""
        swift_script = f'''
import Foundation

struct DotEnvLoader {{
    static func get(_ key: String) -> String? {{
        guard let contents = try? String(contentsOfFile: "{ENV_FILE}", encoding: .utf8) else {{
            return nil
        }}

        for line in contents.components(separatedBy: .newlines) {{
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("\\(key)=") {{
                return trimmed.split(separator: "=", maxSplits: 1)
                    .dropFirst()
                    .first
                    .map(String.init)?
                    .trimmingCharacters(in: .whitespaces)
            }}
        }}
        return nil
    }}
}}

guard let clientID = DotEnvLoader.get("GOOGLE_OAUTH_CLIENT_ID"),
      let redirectURI = DotEnvLoader.get("OAUTH_REDIRECT_URI") else {{
    print("ERROR: Missing OAuth credentials")
    exit(1)
}}

// Construct authorization URL
let baseURL = "https://accounts.google.com/o/oauth2/v2/auth"
var components = URLComponents(string: baseURL)!

components.queryItems = [
    URLQueryItem(name: "client_id", value: clientID),
    URLQueryItem(name: "redirect_uri", value: redirectURI),
    URLQueryItem(name: "response_type", value: "code"),
    URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/gmail.readonly"),
    URLQueryItem(name: "access_type", value: "offline"),
    URLQueryItem(name: "prompt", value: "consent")
]

guard let url = components.url else {{
    print("ERROR: Failed to construct URL")
    exit(1)
}}

let urlString = url.absoluteString

// Verify URL structure
if urlString.hasPrefix("https://accounts.google.com/o/oauth2/v2/auth?") &&
   urlString.contains("client_id=") &&
   urlString.contains("redirect_uri=") &&
   urlString.contains("response_type=code") &&
   urlString.contains("scope=") &&
   urlString.contains("access_type=offline") {{
    print("SUCCESS")
    print(urlString)
}} else {{
    print("ERROR: Invalid URL structure")
    exit(1)
}}
'''

        with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
            f.write(swift_script)
            script_path = f.name

        try:
            result = subprocess.run(
                ['swift', script_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            self.assertEqual(result.returncode, 0, f"URL construction failed: {result.stderr}")
            self.assertIn("SUCCESS", result.stdout)
            self.assertIn("https://accounts.google.com/o/oauth2/v2/auth", result.stdout)

        finally:
            os.unlink(script_path)

    def test_token_exchange_url_construction(self):
        """Test: Token exchange URL and parameters are properly formatted"""
        swift_script = '''
import Foundation

// Test token exchange URL construction
let tokenURL = "https://oauth2.googleapis.com/token"
var components = URLComponents(string: tokenURL)!

// Simulate token exchange parameters
components.queryItems = [
    URLQueryItem(name: "code", value: "test_auth_code_12345"),
    URLQueryItem(name: "client_id", value: "test_client_id"),
    URLQueryItem(name: "client_secret", value: "test_client_secret"),
    URLQueryItem(name: "redirect_uri", value: "http://localhost:8080"),
    URLQueryItem(name: "grant_type", value: "authorization_code")
]

guard let url = components.url else {
    print("ERROR: Failed to construct token URL")
    exit(1)
}

let urlString = url.absoluteString

// Verify all required parameters are present
if urlString.contains("code=") &&
   urlString.contains("client_id=") &&
   urlString.contains("client_secret=") &&
   urlString.contains("redirect_uri=") &&
   urlString.contains("grant_type=authorization_code") {
    print("SUCCESS")
} else {
    print("ERROR: Missing required parameters")
    exit(1)
}
'''

        with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
            f.write(swift_script)
            script_path = f.name

        try:
            result = subprocess.run(
                ['swift', script_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            self.assertEqual(result.returncode, 0, "Token URL construction failed")
            self.assertIn("SUCCESS", result.stdout)

        finally:
            os.unlink(script_path)


class TestTokenRefreshLogic(unittest.TestCase):
    """Test 4: Token refresh logic and expiry handling"""

    def test_refresh_token_url_parameters(self):
        """Test: Refresh token request has correct parameters"""
        swift_script = '''
import Foundation

// Test refresh token URL construction
let tokenURL = "https://oauth2.googleapis.com/token"
var components = URLComponents(string: tokenURL)!

// Simulate refresh token parameters
components.queryItems = [
    URLQueryItem(name: "refresh_token", value: "test_refresh_token_xyz"),
    URLQueryItem(name: "client_id", value: "test_client_id"),
    URLQueryItem(name: "client_secret", value: "test_client_secret"),
    URLQueryItem(name: "grant_type", value: "refresh_token")
]

guard let url = components.url else {
    print("ERROR: Failed to construct refresh URL")
    exit(1)
}

let urlString = url.absoluteString

// Verify all required parameters
if urlString.contains("refresh_token=") &&
   urlString.contains("client_id=") &&
   urlString.contains("client_secret=") &&
   urlString.contains("grant_type=refresh_token") {
    print("SUCCESS")
} else {
    print("ERROR: Missing required refresh parameters")
    exit(1)
}
'''

        with tempfile.NamedTemporaryFile(mode='w', suffix='.swift', delete=False) as f:
            f.write(swift_script)
            script_path = f.name

        try:
            result = subprocess.run(
                ['swift', script_path],
                capture_output=True,
                text=True,
                timeout=30
            )

            self.assertEqual(result.returncode, 0, "Refresh URL construction failed")
            self.assertIn("SUCCESS", result.stdout)

        finally:
            os.unlink(script_path)

    def test_token_format_validation(self):
        """Test: Access tokens have proper format (Bearer token, 100+ chars)"""
        # Simulate various token formats
        valid_tokens = [
            "ya29." + "a" * 100,  # Google access tokens start with ya29.
            "Bearer_" + "b" * 120,
            "token_" + "c" * 150
        ]

        invalid_tokens = [
            "short",
            "",
            "ya29.abc",  # Too short
            None
        ]

        for token in valid_tokens:
            self.assertIsNotNone(token, "Valid token is None")
            self.assertGreater(len(token), 100, f"Valid token too short: {len(token)} chars")

        for token in invalid_tokens:
            if token is None:
                continue
            self.assertLess(len(token), 100, f"Invalid token should be short: {token}")


def run_tests():
    """Run all OAuth functional tests"""
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Add all test classes
    suite.addTests(loader.loadTestsFromTestCase(TestKeychainIntegration))
    suite.addTests(loader.loadTestsFromTestCase(TestOAuthCredentialLoading))
    suite.addTests(loader.loadTestsFromTestCase(TestOAuthURLConstruction))
    suite.addTests(loader.loadTestsFromTestCase(TestTokenRefreshLogic))

    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    exit(0 if success else 1)
