#!/usr/bin/env python3
"""
OAuth Credentials Validator Module - Simplified for KISS compliance
"""

import re
import tempfile
import subprocess
import os
from pathlib import Path


def validate_oauth_credentials(env_file_path: Path) -> tuple:
    """
    Simple OAuth credentials validation

    Returns:
        tuple: (success: bool, messages: list)
    """
    messages = []

    # Check .env file exists
    if not env_file_path.exists():
        return False, [f".env file not found at {env_file_path}"]
    messages.append(f".env file found: {env_file_path}")

    # Load and check credentials
    try:
        with open(env_file_path, 'r') as f:
            env_contents = f.read()
    except Exception as e:
        return False, [f"Error reading .env file: {e}"]

    # Check for required keys
    required_keys = ["GOOGLE_OAUTH_CLIENT_ID", "GOOGLE_OAUTH_CLIENT_SECRET"]
    found_keys = []

    for key in required_keys:
        if key in env_contents and "=" in env_contents:
            for line in env_contents.split('\n'):
                if line.strip().startswith(f"{key}="):
                    value = line.split('=', 1)[1].strip().strip('"\'')
                    if value and len(value) > 10:
                        found_keys.append(key)
                        messages.append(f" Found valid {key}: {value[:20]}...")
                    break

    if len(found_keys) != len(required_keys):
        return False, [f"Missing OAuth credentials: {set(required_keys) - set(found_keys)}"]

    # Validate format with regex
    client_id_pattern = r'\d{6,}-[\w\-]+\.apps\.googleusercontent\.com'
    client_secret_pattern = r'GOCSPX-[\w\-]+'

    if not re.search(client_id_pattern, env_contents):
        return False, ["Google OAuth Client ID format invalid"]

    if not re.search(client_secret_pattern, env_contents):
        return False, ["Google OAuth Client Secret format invalid"]

    messages.append("OAuth credentials properly formatted")
    return True, messages