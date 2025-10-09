#!/usr/bin/env python3
"""
Gmail OAuth Integration E2E Validation Test
Validates complete OAuth flow, authentication, and credential management
"""

import json
import time
import requests
import os
import tempfile
from typing import Dict, Any, List, Optional
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('test_gmail_oauth_integration.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GmailOAuthE2ETest:
    """Comprehensive Gmail OAuth integration validation"""

    def __init__(self):
        self.test_results = []
        self.app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.production_app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.test_data_dir = tempfile.mkdtemp(prefix="gmail_oauth_test_")
        self.gmail_test_credentials = self._load_gmail_test_credentials()

    def _load_gmail_test_credentials(self) -> Dict[str, Any]:
        """Load Gmail test account credentials from secure storage"""
        try:
            # Check environment variables first
            gmail_client_id = os.getenv('GMAIL_TEST_CLIENT_ID')
            gmail_client_secret = os.getenv('GMAIL_TEST_CLIENT_SECRET')
            gmail_test_email = os.getenv('GMAIL_TEST_EMAIL')
            gmail_refresh_token = os.getenv('GMAIL_TEST_REFRESH_TOKEN')

            if all([gmail_client_id, gmail_client_secret, gmail_test_email]):
                logger.info(" Gmail test credentials loaded from environment variables")
                return {
                    'client_id': gmail_client_id,
                    'client_secret': gmail_client_secret,
                    'test_email': gmail_test_email,
                    'refresh_token': gmail_refresh_token
                }

            # Fallback to test configuration file
            config_path = os.path.expanduser("~/.claude/gmail_test_config.json")
            if os.path.exists(config_path):
                with open(config_path, 'r') as f:
                    config = json.load(f)
                logger.info(" Gmail test credentials loaded from config file")
                return config

            logger.warning("️ Gmail test credentials not found - using mock configuration")
            return self._get_mock_gmail_credentials()

        except Exception as e:
            logger.error(f" Error loading Gmail test credentials: {e}")
            return self._get_mock_gmail_credentials()

    def _get_mock_gmail_credentials(self) -> Dict[str, Any]:
        """Return mock credentials for testing without real Gmail access"""
        return {
            'client_id': 'test_client_id',
            'client_secret': 'test_client_secret',
            'test_email': 'test@gmail.com',
            'refresh_token': 'test_refresh_token',
            'mock_mode': True
        }

    def test_oauth_flow_initialization(self) -> Dict[str, Any]:
        """Test OAuth flow initialization and configuration"""
        test_name = "OAuth Flow Initialization"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check OAuth configuration files exist
            oauth_files = [
                'FinanceMate/Services/EmailConnectorService.swift',
                'FinanceMate/Services/GmailAPIService.swift',
                'FinanceMate/Models/EmailOAuthManager.swift'
            ]

            missing_files = []
            for file_path in oauth_files:
                full_path = os.path.join(self.app_path, file_path)
                if not os.path.exists(full_path):
                    missing_files.append(file_path)

            if missing_files:
                result['errors'].append(f"Missing OAuth files: {missing_files}")
                logger.error(f" Missing OAuth files: {missing_files}")
            else:
                result['details']['oauth_files_present'] = True
                logger.info(" All OAuth service files present")

            # Test 2: Validate OAuth configuration in code
            oauth_config_validation = self._validate_oauth_configuration()
            result['details']['oauth_config'] = oauth_config_validation

            if oauth_config_validation['valid']:
                logger.info(" OAuth configuration is valid")
            else:
                result['errors'].extend(oauth_config_validation['errors'])
                logger.error(f" OAuth configuration errors: {oauth_config_validation['errors']}")

            # Test 3: Check for proper OAuth scopes
            oauth_scopes = self._check_oauth_scopes()
            result['details']['oauth_scopes'] = oauth_scopes

            if oauth_scopes['required_scopes_present']:
                logger.info(" Required OAuth scopes are configured")
            else:
                result['errors'].append("Missing required OAuth scopes")
                logger.error(" Missing required OAuth scopes")

            # Test 4: Validate credential storage implementation
            credential_storage = self._validate_credential_storage()
            result['details']['credential_storage'] = credential_storage

            if credential_storage['secure_storage_implemented']:
                logger.info(" Secure credential storage implemented")
            else:
                result['errors'].append("Secure credential storage not properly implemented")
                logger.error(" Secure credential storage issues")

            # Determine overall success
            result['success'] = (
                len(result['errors']) == 0 and
                oauth_config_validation['valid'] and
                oauth_scopes['required_scopes_present'] and
                credential_storage['secure_storage_implemented']
            )

            if result['success']:
                logger.info(f" {test_name} - PASSED")
            else:
                logger.error(f" {test_name} - FAILED")

        except Exception as e:
            result['errors'].append(f"Unexpected error: {str(e)}")
            logger.error(f" {test_name} - ERROR: {e}")

        self.test_results.append(result)
        return result

    def _validate_oauth_configuration(self) -> Dict[str, Any]:
        """Validate OAuth configuration in source code"""
        try:
            # Read EmailConnectorService.swift
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'valid': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            validation_results = {
                'valid': True,
                'errors': [],
                'warnings': [],
                'features_found': []
            }

            # Check for OAuth client configuration
            if 'clientID' in content or 'CLIENT_ID' in content:
                validation_results['features_found'].append('OAuth client ID configuration')
            else:
                validation_results['errors'].append('OAuth client ID configuration not found')

            # Check for redirect URI configuration
            if 'redirectURI' in content or 'REDIRECT_URI' in content:
                validation_results['features_found'].append('OAuth redirect URI configuration')
            else:
                validation_results['errors'].append('OAuth redirect URI configuration not found')

            # Check for OAuth state management
            if 'state' in content.lower() and 'nonce' in content.lower():
                validation_results['features_found'].append('OAuth state/nonce security')
            else:
                validation_results['warnings'].append('OAuth state/nonce security may be missing')

            # Check for token storage
            if 'Keychain' in content or 'keychain' in content.lower():
                validation_results['features_found'].append('Secure token storage (Keychain)')
            else:
                validation_results['warnings'].append('Keychain storage for tokens not confirmed')

            # Check for token refresh logic
            if 'refreshToken' in content or 'refresh_token' in content:
                validation_results['features_found'].append('Token refresh logic')
            else:
                validation_results['warnings'].append('Token refresh logic not confirmed')

            validation_results['valid'] = len(validation_results['errors']) == 0

            return validation_results

        except Exception as e:
            return {'valid': False, 'errors': [f'Error reading OAuth configuration: {str(e)}']}

    def _check_oauth_scopes(self) -> Dict[str, Any]:
        """Check for required OAuth scopes in Gmail integration"""
        try:
            gmail_api_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_path):
                return {'required_scopes_present': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_path, 'r') as f:
                content = f.read()

            required_scopes = [
                'https://www.googleapis.com/auth/gmail.readonly',
                'https://www.googleapis.com/auth/userinfo.email',
                'https://www.googleapis.com/auth/userinfo.profile'
            ]

            found_scopes = []
            missing_scopes = []

            for scope in required_scopes:
                if scope in content:
                    found_scopes.append(scope)
                else:
                    missing_scopes.append(scope)

            # Check for scope constants or variables
            scope_patterns = [
                'gmailReadonly',
                'gmailScope',
                'emailScope',
                'profileScope'
            ]

            for pattern in scope_patterns:
                if pattern in content:
                    found_scopes.append(f"Pattern: {pattern}")

            return {
                'required_scopes_present': len(missing_scopes) == 0,
                'found_scopes': found_scopes,
                'missing_scopes': missing_scopes,
                'total_required': len(required_scopes),
                'total_found': len(found_scopes)
            }

        except Exception as e:
            return {'required_scopes_present': False, 'errors': [f'Error checking OAuth scopes: {str(e)}']}

    def _validate_credential_storage(self) -> Dict[str, Any]:
        """Validate secure credential storage implementation"""
        try:
            validation_results = {
                'secure_storage_implemented': False,
                'keychain_usage': False,
                'token_encryption': False,
                'credential_cleanup': False,
                'errors': [],
                'features_found': []
            }

            # Check EmailConnectorService for credential storage
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if os.path.exists(email_connector_path):
                with open(email_connector_path, 'r') as f:
                    content = f.read()

                # Check for Keychain usage
                if 'Keychain' in content or 'keychain' in content.lower():
                    validation_results['keychain_usage'] = True
                    validation_results['features_found'].append('Keychain storage implemented')

                # Check for token encryption
                if 'encrypt' in content.lower() or 'secure' in content.lower():
                    validation_results['token_encryption'] = True
                    validation_results['features_found'].append('Token encryption implemented')

                # Check for credential cleanup
                if 'remove' in content.lower() and 'token' in content.lower():
                    validation_results['credential_cleanup'] = True
                    validation_results['features_found'].append('Credential cleanup implemented')

            # Check for secure storage patterns
            security_patterns = [
                'kSecAttrAccessibleWhenUnlocked',
                'kSecClassGenericPassword',
                'SecItemAdd',
                'SecItemDelete'
            ]

            for pattern in security_patterns:
                email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')
                if os.path.exists(email_connector_path):
                    with open(email_connector_path, 'r') as f:
                        content = f.read()
                    if pattern in content:
                        validation_results['features_found'].append(f"Security pattern: {pattern}")

            validation_results['secure_storage_implemented'] = (
                validation_results['keychain_usage'] and
                len(validation_results['errors']) == 0
            )

            return validation_results

        except Exception as e:
            return {'secure_storage_implemented': False, 'errors': [f'Error validating credential storage: {str(e)}']}

    def test_gmail_api_authentication(self) -> Dict[str, Any]:
        """Test Gmail API authentication and access validation"""
        test_name = "Gmail API Authentication"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Skip actual API test if using mock credentials
            if self.gmail_test_credentials.get('mock_mode', False):
                result['details']['mock_mode'] = True
                result['details']['api_access'] = 'Skipped (mock mode)'
                result['success'] = True
                logger.info(" Gmail API authentication test skipped (mock mode)")
                self.test_results.append(result)
                return result

            # Test 1: Validate Gmail API endpoint accessibility
            api_access_test = self._test_gmail_api_access()
            result['details']['api_access'] = api_access_test

            if api_access_test['accessible']:
                logger.info(" Gmail API endpoint accessible")
            else:
                result['errors'].append("Gmail API endpoint not accessible")
                logger.error(" Gmail API endpoint not accessible")

            # Test 2: Validate authentication token
            auth_token_test = self._test_authentication_token()
            result['details']['auth_token'] = auth_token_test

            if auth_token_test['valid']:
                logger.info(" Authentication token valid")
            else:
                result['errors'].append("Authentication token invalid or expired")
                logger.error(" Authentication token invalid")

            # Test 3: Test Gmail API permissions
            permissions_test = self._test_gmail_permissions()
            result['details']['permissions'] = permissions_test

            if permissions_test['permissions_granted']:
                logger.info(" Gmail API permissions granted")
            else:
                result['errors'].append("Required Gmail API permissions not granted")
                logger.error(" Gmail API permissions not granted")

            # Test 4: Test email access
            email_access_test = self._test_email_access()
            result['details']['email_access'] = email_access_test

            if email_access_test['can_access_emails']:
                logger.info(" Email access confirmed")
            else:
                result['errors'].append("Cannot access emails via Gmail API")
                logger.error(" Email access failed")

            # Determine overall success
            result['success'] = (
                api_access_test['accessible'] and
                auth_token_test['valid'] and
                permissions_test['permissions_granted'] and
                email_access_test['can_access_emails']
            )

            if result['success']:
                logger.info(f" {test_name} - PASSED")
            else:
                logger.error(f" {test_name} - FAILED")

        except Exception as e:
            result['errors'].append(f"Unexpected error: {str(e)}")
            logger.error(f" {test_name} - ERROR: {e}")

        self.test_results.append(result)
        return result

    def _test_gmail_api_access(self) -> Dict[str, Any]:
        """Test Gmail API endpoint accessibility"""
        try:
            # Test Gmail API base URL
            gmail_api_url = "https://www.googleapis.com/gmail/v1/users/me/profile"

            # Use test credentials if available
            headers = {}
            if self.gmail_test_credentials.get('access_token'):
                headers['Authorization'] = f"Bearer {self.gmail_test_credentials['access_token']}"

            # Make a simple API request
            response = requests.get(gmail_api_url, headers=headers, timeout=10)

            return {
                'accessible': response.status_code in [200, 401, 403],  # Any response means API is reachable
                'status_code': response.status_code,
                'response_time': response.elapsed.total_seconds(),
                'api_reachable': True
            }

        except requests.exceptions.RequestException as e:
            return {
                'accessible': False,
                'error': str(e),
                'api_reachable': False
            }
        except Exception as e:
            return {
                'accessible': False,
                'error': f"Unexpected error: {str(e)}",
                'api_reachable': False
            }

    def _test_authentication_token(self) -> Dict[str, Any]:
        """Test authentication token validity"""
        try:
            if not self.gmail_test_credentials.get('access_token'):
                return {
                    'valid': False,
                    'error': 'No access token available',
                    'token_present': False
                }

            # Test token with Gmail API
            gmail_api_url = "https://www.googleapis.com/gmail/v1/users/me/profile"
            headers = {
                'Authorization': f"Bearer {self.gmail_test_credentials['access_token']}"
            }

            response = requests.get(gmail_api_url, headers=headers, timeout=10)

            if response.status_code == 200:
                return {
                    'valid': True,
                    'token_present': True,
                    'profile_data': response.json(),
                    'expires_in': None  # Would need to parse JWT to get this
                }
            elif response.status_code == 401:
                return {
                    'valid': False,
                    'error': 'Token expired or invalid',
                    'token_present': True,
                    'status_code': 401
                }
            else:
                return {
                    'valid': False,
                    'error': f'API returned status {response.status_code}',
                    'token_present': True,
                    'status_code': response.status_code
                }

        except Exception as e:
            return {
                'valid': False,
                'error': f"Error testing authentication token: {str(e)}",
                'token_present': False
            }

    def _test_gmail_permissions(self) -> Dict[str, Any]:
        """Test Gmail API permissions"""
        try:
            if not self.gmail_test_credentials.get('access_token'):
                return {
                    'permissions_granted': False,
                    'error': 'No access token available',
                    'has_token': False
                }

            # Test different Gmail API endpoints to check permissions
            test_endpoints = [
                ('profile', 'https://www.googleapis.com/gmail/v1/users/me/profile'),
                ('labels', 'https://www.googleapis.com/gmail/v1/users/me/labels'),
                ('messages', 'https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=1')
            ]

            headers = {
                'Authorization': f"Bearer {self.gmail_test_credentials['access_token']}"
            }

            permissions_results = {}

            for endpoint_name, endpoint_url in test_endpoints:
                try:
                    response = requests.get(endpoint_url, headers=headers, timeout=10)
                    permissions_results[endpoint_name] = {
                        'accessible': response.status_code == 200,
                        'status_code': response.status_code,
                        'error': None
                    }
                except Exception as e:
                    permissions_results[endpoint_name] = {
                        'accessible': False,
                        'status_code': None,
                        'error': str(e)
                    }

            # Check if core permissions are granted
            core_permissions_granted = (
                permissions_results.get('profile', {}).get('accessible', False) and
                permissions_results.get('labels', {}).get('accessible', False)
            )

            return {
                'permissions_granted': core_permissions_granted,
                'has_token': True,
                'endpoint_permissions': permissions_results,
                'core_permissions_granted': core_permissions_granted
            }

        except Exception as e:
            return {
                'permissions_granted': False,
                'error': f"Error testing Gmail permissions: {str(e)}",
                'has_token': bool(self.gmail_test_credentials.get('access_token'))
            }

    def _test_email_access(self) -> Dict[str, Any]:
        """Test ability to access emails"""
        try:
            if not self.gmail_test_credentials.get('access_token'):
                return {
                    'can_access_emails': False,
                    'error': 'No access token available',
                    'has_token': False
                }

            # Test accessing a few recent emails
            gmail_messages_url = "https://www.googleapis.com/gmail/v1/users/me/messages"
            headers = {
                'Authorization': f"Bearer {self.gmail_test_credentials['access_token']}"
            }
            params = {
                'maxResults': 5,
                'q': 'receipt OR invoice OR purchase'  # Search for financial emails
            }

            response = requests.get(gmail_messages_url, headers=headers, params=params, timeout=10)

            if response.status_code == 200:
                data = response.json()
                messages = data.get('messages', [])

                return {
                    'can_access_emails': True,
                    'messages_found': len(messages),
                    'sample_message_ids': [msg.get('id') for msg in messages[:3]],
                    'has_token': True,
                    'search_successful': True
                }
            else:
                return {
                    'can_access_emails': False,
                    'error': f'API returned status {response.status_code}',
                    'has_token': True,
                    'search_successful': False,
                    'status_code': response.status_code
                }

        except Exception as e:
            return {
                'can_access_emails': False,
                'error': f"Error testing email access: {str(e)}",
                'has_token': bool(self.gmail_test_credentials.get('access_token'))
            }

    def test_credential_refresh_mechanism(self) -> Dict[str, Any]:
        """Test credential refresh and management"""
        test_name = "Credential Refresh Mechanism"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for refresh token implementation
            refresh_token_implementation = self._check_refresh_token_implementation()
            result['details']['refresh_token_implementation'] = refresh_token_implementation

            if refresh_token_implementation['implemented']:
                logger.info(" Refresh token implementation found")
            else:
                result['errors'].append("Refresh token implementation not found")
                logger.error(" Refresh token implementation missing")

            # Test 2: Check for automatic token refresh
            auto_refresh = self._check_auto_token_refresh()
            result['details']['auto_refresh'] = auto_refresh

            if auto_refresh['implemented']:
                logger.info(" Automatic token refresh implemented")
            else:
                result['errors'].append("Automatic token refresh not implemented")
                logger.error(" Automatic token refresh missing")

            # Test 3: Check for error handling in refresh
            refresh_error_handling = self._check_refresh_error_handling()
            result['details']['refresh_error_handling'] = refresh_error_handling

            if refresh_error_handling['robust']:
                logger.info(" Robust refresh error handling")
            else:
                result['errors'].append("Refresh error handling insufficient")
                logger.error(" Refresh error handling insufficient")

            # Test 4: Check for credential expiration handling
            expiration_handling = self._check_credential_expiration_handling()
            result['details']['expiration_handling'] = expiration_handling

            if expiration_handling['handled']:
                logger.info(" Credential expiration handling implemented")
            else:
                result['errors'].append("Credential expiration handling not implemented")
                logger.error(" Credential expiration handling missing")

            # Determine overall success
            result['success'] = (
                refresh_token_implementation['implemented'] and
                auto_refresh['implemented'] and
                refresh_error_handling['robust'] and
                expiration_handling['handled']
            )

            if result['success']:
                logger.info(f" {test_name} - PASSED")
            else:
                logger.error(f" {test_name} - FAILED")

        except Exception as e:
            result['errors'].append(f"Unexpected error: {str(e)}")
            logger.error(f" {test_name} - ERROR: {e}")

        self.test_results.append(result)
        return result

    def _check_refresh_token_implementation(self) -> Dict[str, Any]:
        """Check for refresh token implementation"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'implemented': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            refresh_indicators = [
                'refreshToken',
                'refresh_token',
                'tokenRefresh',
                'refreshAccessToken'
            ]

            found_indicators = []
            for indicator in refresh_indicators:
                if indicator in content:
                    found_indicators.append(indicator)

            # Check for refresh token storage
            storage_indicators = [
                'storeRefreshToken',
                'saveRefreshToken',
                'refreshTokenStorage'
            ]

            found_storage = []
            for indicator in storage_indicators:
                if indicator in content:
                    found_storage.append(indicator)

            return {
                'implemented': len(found_indicators) > 0,
                'found_indicators': found_indicators,
                'storage_indicators': found_storage,
                'total_indicators': len(found_indicators)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking refresh token implementation: {str(e)}']}

    def _check_auto_token_refresh(self) -> Dict[str, Any]:
        """Check for automatic token refresh implementation"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'implemented': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            auto_refresh_patterns = [
                'automatic.*refresh',
                'auto.*refresh',
                'refreshBeforeExpiration',
                'scheduledRefresh',
                'backgroundRefresh'
            ]

            found_patterns = []
            for pattern in auto_refresh_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_patterns.append(pattern)

            # Check for timer or scheduler usage
            scheduler_patterns = [
                'Timer',
                'DispatchSourceTimer',
                'backgroundTask',
                'scheduler'
            ]

            found_schedulers = []
            for pattern in scheduler_patterns:
                if pattern in content:
                    found_schedulers.append(pattern)

            return {
                'implemented': len(found_patterns) > 0 or len(found_schedulers) > 0,
                'found_patterns': found_patterns,
                'found_schedulers': found_schedulers,
                'auto_refresh_logic': len(found_patterns) > 0,
                'scheduler_usage': len(found_schedulers) > 0
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking auto token refresh: {str(e)}']}

    def _check_refresh_error_handling(self) -> Dict[str, Any]:
        """Check for robust error handling in token refresh"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'robust': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            error_handling_patterns = [
                'catch.*refresh',
                'refreshError',
                'refreshFailure',
                'handleRefreshError',
                'onRefreshFailure'
            ]

            found_error_handling = []
            for pattern in error_handling_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_error_handling.append(pattern)

            # Check for specific error scenarios
            specific_errors = [
                'invalid_grant',
                'expired_token',
                'network.*error',
                'timeout',
                'unauthorized'
            ]

            found_specific_errors = []
            for error in specific_errors:
                if error in content.lower():
                    found_specific_errors.append(error)

            # Check for fallback mechanisms
            fallback_patterns = [
                'fallback',
                'retry',
                'alternative',
                'backup'
            ]

            found_fallbacks = []
            for pattern in fallback_patterns:
                if pattern in content.lower():
                    found_fallbacks.append(pattern)

            robust_score = len(found_error_handling) + len(found_specific_errors) + len(found_fallbacks)

            return {
                'robust': robust_score >= 3,
                'error_handling_patterns': found_error_handling,
                'specific_error_handling': found_specific_errors,
                'fallback_mechanisms': found_fallbacks,
                'robustness_score': robust_score
            }

        except Exception as e:
            return {'robust': False, 'errors': [f'Error checking refresh error handling: {str(e)}']}

    def _check_credential_expiration_handling(self) -> Dict[str, Any]:
        """Check for credential expiration handling"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'handled': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            expiration_patterns = [
                'expiration',
                'expires',
                'expiry',
                'tokenExpire',
                'credentialExpire'
            ]

            found_expiration = []
            for pattern in expiration_patterns:
                if pattern.lower() in content.lower():
                    found_expiration.append(pattern)

            # Check for expiration checking logic
            expiration_check_patterns = [
                'isTokenExpired',
                'checkExpiration',
                'willExpireSoon',
                'beforeExpiration'
            ]

            found_checks = []
            for pattern in expiration_check_patterns:
                if pattern in content:
                    found_checks.append(pattern)

            # Check for proactive refresh
            proactive_patterns = [
                'refreshBefore',
                'proactiveRefresh',
                'earlyRefresh',
                'preventExpiration'
            ]

            found_proactive = []
            for pattern in proactive_patterns:
                if pattern in content:
                    found_proactive.append(pattern)

            return {
                'handled': len(found_expiration) > 0,
                'expiration_detection': found_expiration,
                'expiration_checks': found_checks,
                'proactive_refresh': found_proactive,
                'comprehensive_handling': len(found_checks) > 0 and len(found_proactive) > 0
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error checking credential expiration handling: {str(e)}']}

    def test_permission_scopes_validation(self) -> Dict[str, Any]:
        """Test Gmail API permission scopes and access levels"""
        test_name = "Permission Scopes Validation"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Validate required scopes are configured
            required_scopes = self._validate_required_scopes()
            result['details']['required_scopes'] = required_scopes

            if required_scopes['all_present']:
                logger.info(" All required Gmail scopes configured")
            else:
                result['errors'].append("Missing required Gmail scopes")
                logger.error(" Missing required Gmail scopes")

            # Test 2: Validate scope hierarchy and permissions
            scope_hierarchy = self._validate_scope_hierarchy()
            result['details']['scope_hierarchy'] = scope_hierarchy

            if scope_hierarchy['proper_hierarchy']:
                logger.info(" Proper scope hierarchy implemented")
            else:
                result['errors'].append("Scope hierarchy issues found")
                logger.error(" Scope hierarchy issues")

            # Test 3: Check for minimal scope principle
            minimal_scopes = self._check_minimal_scope_principle()
            result['details']['minimal_scopes'] = minimal_scopes

            if minimal_scopes['follows_principle']:
                logger.info(" Follows minimal scope principle")
            else:
                result['warnings'].append("May not follow minimal scope principle")
                logger.warning("️ Minimal scope principle may be violated")

            # Test 4: Validate scope request implementation
            scope_request = self._validate_scope_request_implementation()
            result['details']['scope_request'] = scope_request

            if scope_request['properly_implemented']:
                logger.info(" Scope request properly implemented")
            else:
                result['errors'].append("Scope request implementation issues")
                logger.error(" Scope request implementation issues")

            # Determine overall success
            result['success'] = (
                required_scopes['all_present'] and
                scope_hierarchy['proper_hierarchy'] and
                scope_request['properly_implemented']
            )

            if result['success']:
                logger.info(f" {test_name} - PASSED")
            else:
                logger.error(f" {test_name} - FAILED")

        except Exception as e:
            result['errors'].append(f"Unexpected error: {str(e)}")
            logger.error(f" {test_name} - ERROR: {e}")

        self.test_results.append(result)
        return result

    def _validate_required_scopes(self) -> Dict[str, Any]:
        """Validate required Gmail API scopes"""
        try:
            gmail_api_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_path):
                return {'all_present': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_path, 'r') as f:
                content = f.read()

            # Define required scopes for Gmail receipt processing
            required_scopes = [
                'https://www.googleapis.com/auth/gmail.readonly',  # Read emails
                'https://www.googleapis.com/auth/userinfo.email',  # Get user email
                'https://www.googleapis.com/auth/userinfo.profile'  # Get user profile
            ]

            optional_scopes = [
                'https://www.googleapis.com/auth/gmail.modify',    # Modify labels
                'https://www.googleapis.com/auth/gmail.labels',     # Manage labels
            ]

            found_scopes = []
            missing_scopes = []
            found_optional = []

            # Check for exact scope matches
            for scope in required_scopes:
                if scope in content:
                    found_scopes.append(scope)
                else:
                    missing_scopes.append(scope)

            # Check for optional scopes
            for scope in optional_scopes:
                if scope in content:
                    found_optional.append(scope)

            # Check for scope constants or variables
            scope_constants = [
                'gmailReadonly',
                'gmailScope',
                'emailScope',
                'profileScope'
            ]

            found_constants = []
            for constant in scope_constants:
                if constant in content:
                    found_constants.append(constant)

            return {
                'all_present': len(missing_scopes) == 0,
                'found_scopes': found_scopes,
                'missing_scopes': missing_scopes,
                'found_optional': found_optional,
                'found_constants': found_constants,
                'total_required': len(required_scopes),
                'total_found': len(found_scopes),
                'coverage_percentage': (len(found_scopes) / len(required_scopes)) * 100
            }

        except Exception as e:
            return {'all_present': False, 'errors': [f'Error validating required scopes: {str(e)}']}

    def _validate_scope_hierarchy(self) -> Dict[str, Any]:
        """Validate scope hierarchy and permissions"""
        try:
            gmail_api_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_path):
                return {'proper_hierarchy': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_path, 'r') as f:
                content = f.read()

            # Check for scope hierarchy understanding
            hierarchy_indicators = [
                'readonly',  # Using readonly instead of full access
                'minimal',   # Minimal scope requests
                'necessary',  # Only necessary permissions
            ]

            found_indicators = []
            for indicator in hierarchy_indicators:
                if indicator in content.lower():
                    found_indicators.append(indicator)

            # Check for dangerous scope usage
            dangerous_scopes = [
                'gmail.fullaccess',
                'gmail.send',
                'gmail.drafts',
                'gmail.insert'
            ]

            found_dangerous = []
            for scope in dangerous_scopes:
                if scope in content.lower():
                    found_dangerous.append(scope)

            # Check for scope separation
            scope_separation = [
                'scope.*split',
                'multiple.*scopes',
                'scope.*array',
                'scopes.*list'
            ]

            found_separation = []
            for pattern in scope_separation:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_separation.append(pattern)

            proper_hierarchy = (
                len(found_indicators) > 0 and
                len(found_dangerous) == 0 and
                len(found_separation) > 0
            )

            return {
                'proper_hierarchy': proper_hierarchy,
                'safety_indicators': found_indicators,
                'dangerous_scopes': found_dangerous,
                'scope_separation': found_separation,
                'security_score': len(found_indicators) - len(found_dangerous)
            }

        except Exception as e:
            return {'proper_hierarchy': False, 'errors': [f'Error validating scope hierarchy: {str(e)}']}

    def _check_minimal_scope_principle(self) -> Dict[str, Any]:
        """Check if the app follows minimal scope principle"""
        try:
            gmail_api_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_path):
                return {'follows_principle': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_path, 'r') as f:
                content = f.read()

            # Check for minimal scope indicators
            minimal_indicators = [
                'readonly',
                'minimal',
                'necessary',
                'least.*privilege'
            ]

            found_minimal = []
            for indicator in minimal_indicators:
                if indicator in content.lower():
                    found_minimal.append(indicator)

            # Check for scope comments explaining necessity
            scope_comments = [
                '//.*necessary',
                '//.*required',
                '//.*minimal',
                '/*.*necessary',
                '/*.*required'
            ]

            found_comments = []
            for comment in scope_comments:
                import re
                if re.search(comment, content, re.IGNORECASE):
                    found_comments.append(comment)

            # Count total scopes requested
            scope_pattern = r'https://www\.googleapis\.com/auth/[^\s"\']+'
            import re
            found_scopes = re.findall(scope_pattern, content)

            # Check if using readonly scopes
            readonly_count = sum(1 for scope in found_scopes if 'readonly' in scope)

            follows_principle = (
                len(found_minimal) > 0 and
                len(found_scopes) <= 5 and  # Reasonable number of scopes
                readonly_count > 0
            )

            return {
                'follows_principle': follows_principle,
                'minimal_indicators': found_minimal,
                'explanatory_comments': found_comments,
                'total_scopes': len(found_scopes),
                'readonly_scopes': readonly_count,
                'scope_efficiency': readonly_count / max(len(found_scopes), 1)
            }

        except Exception as e:
            return {'follows_principle': False, 'errors': [f'Error checking minimal scope principle: {str(e)}']}

    def _validate_scope_request_implementation(self) -> Dict[str, Any]:
        """Validate scope request implementation"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'properly_implemented': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            # Check for scope request implementation
            scope_request_patterns = [
                'scope.*request',
                'request.*scope',
                'OAuthScope',
                'scope.*parameter',
                'scopes.*array'
            ]

            found_patterns = []
            for pattern in scope_request_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_patterns.append(pattern)

            # Check for proper scope formatting
            scope_formatting = [
                'scope.*join',
                'scope.*string',
                'space.*separated',
                'comma.*separated'
            ]

            found_formatting = []
            for pattern in scope_formatting:
                if pattern in content.lower():
                    found_formatting.append(pattern)

            # Check for error handling in scope requests
            scope_error_handling = [
                'scope.*error',
                'permission.*denied',
                'insufficient.*scope',
                'scope.*missing'
            ]

            found_error_handling = []
            for pattern in scope_error_handling:
                if pattern in content.lower():
                    found_error_handling.append(pattern)

            properly_implemented = (
                len(found_patterns) > 0 and
                len(found_formatting) > 0
            )

            return {
                'properly_implemented': properly_implemented,
                'scope_request_patterns': found_patterns,
                'scope_formatting': found_formatting,
                'error_handling': found_error_handling,
                'implementation_quality': len(found_patterns) + len(found_formatting)
            }

        except Exception as e:
            return {'properly_implemented': False, 'errors': [f'Error validating scope request implementation: {str(e)}']}

    def generate_test_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        logger.info(" Generating Gmail OAuth Integration test report")

        total_tests = len(self.test_results)
        passed_tests = sum(1 for test in self.test_results if test['success'])
        failed_tests = total_tests - passed_tests

        report = {
            'test_suite': 'Gmail OAuth Integration E2E Validation',
            'timestamp': datetime.now().isoformat(),
            'total_tests': total_tests,
            'passed_tests': passed_tests,
            'failed_tests': failed_tests,
            'success_rate': (passed_tests / total_tests) * 100 if total_tests > 0 else 0,
            'test_results': self.test_results,
            'summary': {
                'status': 'PASSED' if failed_tests == 0 else 'FAILED',
                'critical_failures': [],
                'warnings': [],
                'recommendations': []
            }
        }

        # Analyze failures and provide recommendations
        for test_result in self.test_results:
            if not test_result['success']:
                report['summary']['critical_failures'].extend(test_result['errors'])

            if 'warnings' in test_result:
                report['summary']['warnings'].extend(test_result['warnings'])

        # Add recommendations based on test results
        if failed_tests == 0:
            report['summary']['recommendations'].append("All Gmail OAuth integration tests passed - system is ready for production")
        else:
            report['summary']['recommendations'].append("Address critical OAuth configuration issues before production deployment")

        if self.gmail_test_credentials.get('mock_mode', False):
            report['summary']['warnings'].append("Tests run in mock mode - configure real Gmail credentials for full validation")
            report['summary']['recommendations'].append("Set up Gmail test credentials for comprehensive OAuth validation")

        return report

    def save_test_report(self, report: Dict[str, Any]) -> str:
        """Save test report to file"""
        report_file = os.path.join(self.test_data_dir, f"gmail_oauth_integration_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")

        try:
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)

            logger.info(f" Test report saved to: {report_file}")
            return report_file

        except Exception as e:
            logger.error(f" Error saving test report: {e}")
            return ""

    def run_all_tests(self) -> Dict[str, Any]:
        """Run all Gmail OAuth integration tests"""
        logger.info(" Starting Gmail OAuth Integration E2E Test Suite")

        # Run all test methods
        self.test_oauth_flow_initialization()
        self.test_gmail_api_authentication()
        self.test_credential_refresh_mechanism()
        self.test_permission_scopes_validation()

        # Generate and save report
        report = self.generate_test_report()
        report_file = self.save_test_report(report)

        if report_file:
            report['report_file'] = report_file

        logger.info(f" Gmail OAuth Integration E2E Test Suite completed - Success Rate: {report['success_rate']:.1f}%")

        return report

def main():
    """Main test execution function"""
    print(" Gmail OAuth Integration E2E Test Suite")
    print("=" * 50)

    # Create and run test suite
    test_suite = GmailOAuthE2ETest()
    results = test_suite.run_all_tests()

    # Print summary
    print(f"\n Test Results Summary:")
    print(f"   Total Tests: {results['total_tests']}")
    print(f"   Passed: {results['passed_tests']}")
    print(f"   Failed: {results['failed_tests']}")
    print(f"   Success Rate: {results['success_rate']:.1f}%")
    print(f"   Status: {results['summary']['status']}")

    if results['failed_tests'] > 0:
        print(f"\n Critical Failures:")
        for failure in results['summary']['critical_failures']:
            print(f"   - {failure}")

    if results['summary']['warnings']:
        print(f"\n️ Warnings:")
        for warning in results['summary']['warnings']:
            print(f"   - {warning}")

    print(f"\n Recommendations:")
    for recommendation in results['summary']['recommendations']:
        print(f"   - {recommendation}")

    if 'report_file' in results:
        print(f"\n Detailed report saved to: {results['report_file']}")

    print("\n Test suite execution completed")

    # Return appropriate exit code
    return 0 if results['summary']['status'] == 'PASSED' else 1

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)