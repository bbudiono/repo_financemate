#!/usr/bin/env python3
"""
Gmail OAuth Token Exchange Helper
Facilitates programmatic OAuth token exchange for testing
"""

import json
import time
import subprocess
import requests
from pathlib import Path
from typing import Dict, Optional
import webbrowser
import http.server
import socketserver
import threading
import urllib.parse

class OAuthTokenExchanger:
    """Helper class for Gmail OAuth token exchange"""

    def __init__(self):
        # Load from environment - NEVER hardcode credentials
        import os
        self.client_id = os.getenv("GOOGLE_OAUTH_CLIENT_ID", "")
        self.client_secret = os.getenv("GOOGLE_OAUTH_CLIENT_SECRET", "")
        self.redirect_uri = os.getenv("GOOGLE_OAUTH_REDIRECT_URI", "http://localhost:8080/callback")
        self.auth_code = None
        self.tokens = None

        if not self.client_id or not self.client_secret:
            raise ValueError("OAuth credentials not found in environment. Set GOOGLE_OAUTH_CLIENT_ID and GOOGLE_OAUTH_CLIENT_SECRET")

    def get_authorization_url(self) -> str:
        """Generate the OAuth authorization URL"""
        base_url = "https://accounts.google.com/o/oauth2/v2/auth"
        params = {
            "client_id": self.client_id,
            "redirect_uri": self.redirect_uri,
            "response_type": "code",
            "scope": "https://www.googleapis.com/auth/gmail.readonly",
            "access_type": "offline",
            "prompt": "consent"
        }

        query_string = urllib.parse.urlencode(params)
        return f"{base_url}?{query_string}"

    def exchange_code_for_tokens(self, auth_code: str) -> Dict:
        """Exchange authorization code for access and refresh tokens"""
        token_url = "https://oauth2.googleapis.com/token"

        data = {
            "code": auth_code,
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "redirect_uri": self.redirect_uri,
            "grant_type": "authorization_code"
        }

        response = requests.post(token_url, data=data)

        if response.status_code == 200:
            self.tokens = response.json()
            return self.tokens
        else:
            raise Exception(f"Token exchange failed: {response.text}")

    def save_tokens_to_file(self, filepath: str):
        """Save tokens to a JSON file"""
        if not self.tokens:
            raise Exception("No tokens to save. Exchange code first.")

        with open(filepath, 'w') as f:
            json.dump(self.tokens, f, indent=2)

        print(f" Tokens saved to: {filepath}")

    def load_tokens_from_file(self, filepath: str) -> Dict:
        """Load tokens from a JSON file"""
        with open(filepath, 'r') as f:
            self.tokens = json.load(f)
        return self.tokens


class LocalOAuthServer:
    """Simple HTTP server to capture OAuth callback"""

    def __init__(self, port: int = 8080):
        self.port = port
        self.auth_code = None
        self.server = None
        self.handler_class = None

    def start(self):
        """Start the local server"""

        # Create custom handler that captures auth code
        parent_server = self

        class OAuthCallbackHandler(http.server.SimpleHTTPRequestHandler):
            def do_GET(self):
                # Parse the query string
                parsed_path = urllib.parse.urlparse(self.path)
                query_params = urllib.parse.parse_qs(parsed_path.query)

                if 'code' in query_params:
                    parent_server.auth_code = query_params['code'][0]

                    # Send success response
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()

                    success_html = """
                    <html>
                    <body style="font-family: Arial; text-align: center; padding: 50px;">
                        <h1> Authorization Successful!</h1>
                        <p>You can close this window and return to the terminal.</p>
                        <p>Authorization code captured successfully.</p>
                    </body>
                    </html>
                    """
                    self.wfile.write(success_html.encode())
                else:
                    self.send_response(400)
                    self.send_header('Content-type', 'text/html')
                    self.end_headers()

                    error_html = """
                    <html>
                    <body style="font-family: Arial; text-align: center; padding: 50px;">
                        <h1> Authorization Failed</h1>
                        <p>No authorization code received.</p>
                    </body>
                    </html>
                    """
                    self.wfile.write(error_html.encode())

            def log_message(self, format, *args):
                # Suppress server logs
                pass

        # Start server in a separate thread
        def run_server():
            with socketserver.TCPServer(("", self.port), OAuthCallbackHandler) as httpd:
                self.server = httpd
                print(f" OAuth callback server started on http://localhost:{self.port}")
                httpd.serve_forever()

        server_thread = threading.Thread(target=run_server, daemon=True)
        server_thread.start()

        return server_thread

    def stop(self):
        """Stop the local server"""
        if self.server:
            self.server.shutdown()


def _wait_for_auth_code(server, timeout=120):
    """Wait for OAuth authorization callback"""
    start_time = time.time()
    while not server.auth_code and (time.time() - start_time) < timeout:
        time.sleep(1)
    return server.auth_code


def _save_tokens(exchanger, tokens):
    """Save OAuth tokens to file"""
    output_dir = Path(__file__).parent.parent / "test_output"
    output_dir.mkdir(exist_ok=True)
    tokens_file = output_dir / f"oauth_tokens_{int(time.time())}.json"
    exchanger.save_tokens_to_file(str(tokens_file))
    return tokens_file


def _start_oauth_server(server, exchanger):
    """Start OAuth server and open browser"""
    server.start()
    time.sleep(1)
    auth_url = exchanger.get_authorization_url()
    print(f"\n Opening browser: {auth_url[:100]}...")
    webbrowser.open(auth_url)


def _exchange_and_save(exchanger, auth_code):
    """Exchange auth code for tokens and save"""
    print("\n Exchanging code for tokens...")
    tokens = exchanger.exchange_code_for_tokens(auth_code)

    print("\n Tokens received!")
    print(f"   Access: {tokens['access_token'][:30]}...")
    print(f"   Refresh: {tokens.get('refresh_token', 'N/A')[:30]}...")

    tokens_file = _save_tokens(exchanger, tokens)
    print(f"\n Saved to: {tokens_file}")
    return tokens


def interactive_oauth_flow():
    """Run interactive OAuth flow"""
    print("=" * 60)
    print("GMAIL OAUTH TOKEN EXCHANGE")
    print("=" * 60)

    exchanger = OAuthTokenExchanger()
    server = LocalOAuthServer(port=8080)

    try:
        _start_oauth_server(server, exchanger)

        print("\n Waiting for authorization...")
        print("   1. Sign in with bernhardbudiono@gmail.com")
        print("   2. Grant Gmail read access")

        auth_code = _wait_for_auth_code(server)

        if not auth_code:
            print("\n Timeout waiting for authorization")
            return

        print(f"\n Code received: {auth_code[:20]}...")
        _exchange_and_save(exchanger, auth_code)
        print("\n OAuth flow complete!")

    except Exception as e:
        print(f"\n Failed: {e}")

    finally:
        server.stop()


if __name__ == "__main__":
    interactive_oauth_flow()