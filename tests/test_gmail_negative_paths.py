#!/usr/bin/env python3
"""
Gmail Integration Negative Path E2E Validation Test
Validates error handling, authentication failures, network issues, and edge cases
"""

import json
import time
import requests
import os
import tempfile
import re
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('test_gmail_negative_paths.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GmailNegativePathsE2ETest:
    """Comprehensive Gmail negative path validation"""

    def __init__(self):
        self.test_results = []
        self.app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.production_app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.test_data_dir = tempfile.mkdtemp(prefix="gmail_negative_test_")
        self.gmail_test_credentials = self._load_gmail_test_credentials()

    def _load_gmail_test_credentials(self) -> Dict[str, Any]:
        """Load Gmail test account credentials"""
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

    def test_authentication_failure_scenarios(self) -> Dict[str, Any]:
        """Test authentication failure scenarios"""
        test_name = "Authentication Failure Scenarios"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for invalid credentials handling
            invalid_credentials = self._test_invalid_credentials_handling()
            result['details']['invalid_credentials'] = invalid_credentials

            if invalid_credentials['handled']:
                logger.info(" Invalid credentials handling implemented")
            else:
                result['errors'].append("Invalid credentials handling not implemented")
                logger.error(" Invalid credentials handling missing")

            # Test 2: Check for token expiration handling
            token_expiration = self._test_token_expiration_handling()
            result['details']['token_expiration'] = token_expiration

            if token_expiration['handled']:
                logger.info(" Token expiration handling implemented")
            else:
                result['errors'].append("Token expiration handling not implemented")
                logger.error(" Token expiration handling missing")

            # Test 3: Check for permission denial handling
            permission_denial = self._test_permission_denial_handling()
            result['details']['permission_denial'] = permission_denial

            if permission_denial['handled']:
                logger.info(" Permission denial handling implemented")
            else:
                result['errors'].append("Permission denial handling not implemented")
                logger.error(" Permission denial handling missing")

            # Test 4: Check for OAuth flow interruption
            oauth_interruption = self._test_oauth_flow_interruption()
            result['details']['oauth_interruption'] = oauth_interruption

            if oauth_interruption['handled']:
                logger.info(" OAuth flow interruption handling implemented")
            else:
                result['errors'].append("OAuth flow interruption handling not implemented")
                logger.error(" OAuth flow interruption handling missing")

            # Determine overall success
            result['success'] = (
                invalid_credentials['handled'] and
                token_expiration['handled'] and
                permission_denial['handled'] and
                oauth_interruption['handled']
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

    def _test_invalid_credentials_handling(self) -> Dict[str, Any]:
        """Test invalid credentials handling"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'handled': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            # Check for error handling patterns
            error_patterns = {
                '401_handling': ['401', 'unauthorized', 'Unauthorized', 'invalid.*credential'],
                '403_handling': ['403', 'forbidden', 'Forbidden', 'permission.*denied'],
                'error_catching': ['catch', 'Error', 'NSError', 'Swift.Error'],
                'credential_validation': ['validate', 'check', 'verify', 'isValid']
            }

            found_patterns = {}
            for pattern_type, patterns in error_patterns.items():
                found = []
                for pattern in patterns:
                    import re
                    if re.search(pattern, content, re.IGNORECASE):
                        found.append(pattern)
                found_patterns[pattern_type] = found

            # Check for user notification
            user_notification = [
                'Alert', 'alert', 'showError', 'presentError',
                'errorMessage', 'userMessage', 'displayError'
            ]

            found_notification = []
            for notification in user_notification:
                if notification in content:
                    found_notification.append(notification)

            # Check for recovery mechanisms
            recovery_mechanisms = [
                'retry', 'Retry', 'reauthenticate', 'loginAgain',
                'refreshToken', 'reconnect', 'resetAuth'
            ]

            found_recovery = []
            for recovery in recovery_mechanisms:
                if recovery in content:
                    found_recovery.append(recovery)

            handled = (
                len(found_patterns.get('401_handling', [])) > 0 or
                len(found_patterns.get('403_handling', [])) > 0
            )

            return {
                'handled': handled,
                'error_patterns': found_patterns,
                'user_notification': found_notification,
                'recovery_mechanisms': found_recovery,
                'error_handling_score': sum(len(patterns) for patterns in found_patterns.values())
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing invalid credentials handling: {str(e)}']}

    def _test_token_expiration_handling(self) -> Dict[str, Any]:
        """Test token expiration handling"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'handled': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            # Check for expiration detection
            expiration_detection = [
                'expired', 'expiration', 'expires', 'expiry',
                'tokenExpired', 'isExpired', 'willExpire'
            ]

            found_detection = []
            for detection in expiration_detection:
                if detection.lower() in content.lower():
                    found_detection.append(detection)

            # Check for refresh logic
            refresh_logic = [
                'refreshToken', 'refreshAccessToken', 'renewToken',
                'updateToken', 'tokenRefresh', 'refresh.*token'
            ]

            found_refresh = []
            for refresh in refresh_logic:
                if refresh in content:
                    found_refresh.append(refresh)

            # Check for automatic refresh
            auto_refresh = [
                'automatic', 'auto', 'background', 'proactive',
                'beforeExpiration', 'preventExpiration'
            ]

            found_auto = []
            for auto in auto_refresh:
                if auto.lower() in content.lower():
                    found_auto.append(auto)

            # Check for user re-authentication
            reauth = [
                'reauthenticate', 'loginAgain', 'signInAgain',
                'requireLogin', 'forceLogin', 'userLogin'
            ]

            found_reauth = []
            for auth in reauth:
                if auth in content:
                    found_reauth.append(auth)

            handled = (
                len(found_detection) > 0 and
                (len(found_refresh) > 0 or len(found_reauth) > 0)
            )

            return {
                'handled': handled,
                'expiration_detection': found_detection,
                'refresh_logic': found_refresh,
                'auto_refresh': found_auto,
                'reauthentication': found_reauth,
                'expiration_score': len(found_detection) + len(found_refresh) + len(found_auto)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing token expiration handling: {str(e)}']}

    def _test_permission_denial_handling(self) -> Dict[str, Any]:
        """Test permission denial handling"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'handled': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            # Check for permission error detection
            permission_errors = [
                'permission', 'Permission', 'access', 'Access',
                'denied', 'Denied', 'forbidden', 'Forbidden'
            ]

            found_errors = []
            for error in permission_errors:
                if error in content:
                    found_errors.append(error)

            # Check for scope validation
            scope_validation = [
                'scope', 'Scope', 'permission.*scope',
                'validateScope', 'checkScope', 'missingScope'
            ]

            found_scope = []
            for scope in scope_validation:
                if scope in content:
                    found_scope.append(scope)

            # Check for user permission requests
            permission_requests = [
                'requestPermission', 'askPermission', 'grantAccess',
                'requestAccess', 'promptUser', 'askUser'
            ]

            found_requests = []
            for request in permission_requests:
                if request in content:
                    found_requests.append(request)

            # Check for graceful degradation
            graceful_degradation = [
                'fallback', 'Fallback', 'alternative', 'Alternative',
                'degrade', 'limited', 'restricted'
            ]

            found_degradation = []
            for degradation in graceful_degradation:
                if degradation.lower() in content.lower():
                    found_degradation.append(degradation)

            handled = (
                len(found_errors) > 0 and
                (len(found_scope) > 0 or len(found_requests) > 0)
            )

            return {
                'handled': handled,
                'permission_errors': found_errors,
                'scope_validation': found_scope,
                'permission_requests': found_requests,
                'graceful_degradation': found_degradation,
                'permission_score': len(found_errors) + len(found_scope) + len(found_requests)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing permission denial handling: {str(e)}']}

    def _test_oauth_flow_interruption(self) -> Dict[str, Any]:
        """Test OAuth flow interruption handling"""
        try:
            email_connector_path = os.path.join(self.app_path, 'FinanceMate/Services/EmailConnectorService.swift')

            if not os.path.exists(email_connector_path):
                return {'handled': False, 'errors': ['EmailConnectorService.swift not found']}

            with open(email_connector_path, 'r') as f:
                content = f.read()

            # Check for OAuth state management
            state_management = [
                'state', 'State', 'oauthState', 'authState',
                'sessionState', 'connectionState'
            ]

            found_state = []
            for state in state_management:
                if state in content:
                    found_state.append(state)

            # Check for flow interruption detection
            interruption_detection = [
                'cancel', 'Cancel', 'interrupt', 'Interrupt',
                'abort', 'Abort', 'userCancel', 'flowCancelled'
            ]

            found_interruption = []
            for interruption in interruption_detection:
                if interruption.lower() in content.lower():
                    found_interruption.append(interruption)

            # Check for cleanup mechanisms
            cleanup_mechanisms = [
                'cleanup', 'Cleanup', 'reset', 'Reset',
                'clear', 'Clear', 'invalidate', 'Invalidate'
            ]

            found_cleanup = []
            for cleanup in cleanup_mechanisms:
                if cleanup in content:
                    found_cleanup.append(cleanup)

            # Check for retry mechanisms
            retry_mechanisms = [
                'retry', 'Retry', 'restart', 'Restart',
                'tryAgain', 'attemptAgain', 'resume'
            ]

            found_retry = []
            for retry in retry_mechanisms:
                if retry in content:
                    found_retry.append(retry)

            handled = (
                len(found_state) > 0 and
                (len(found_interruption) > 0 or len(found_cleanup) > 0)
            )

            return {
                'handled': handled,
                'state_management': found_state,
                'interruption_detection': found_interruption,
                'cleanup_mechanisms': found_cleanup,
                'retry_mechanisms': found_retry,
                'oauth_score': len(found_state) + len(found_interruption) + len(found_cleanup)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing OAuth flow interruption: {str(e)}']}

    def test_network_connectivity_issues(self) -> Dict[str, Any]:
        """Test network connectivity issues"""
        test_name = "Network Connectivity Issues"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for offline mode handling
            offline_handling = self._test_offline_mode_handling()
            result['details']['offline_handling'] = offline_handling

            if offline_handling['handled']:
                logger.info(" Offline mode handling implemented")
            else:
                result['errors'].append("Offline mode handling not implemented")
                logger.error(" Offline mode handling missing")

            # Test 2: Check for timeout handling
            timeout_handling = self._test_timeout_handling()
            result['details']['timeout_handling'] = timeout_handling

            if timeout_handling['handled']:
                logger.info(" Timeout handling implemented")
            else:
                result['errors'].append("Timeout handling not implemented")
                logger.error(" Timeout handling missing")

            # Test 3: Check for retry mechanisms
            retry_mechanisms = self._test_retry_mechanisms()
            result['details']['retry_mechanisms'] = retry_mechanisms

            if retry_mechanisms['implemented']:
                logger.info(" Retry mechanisms implemented")
            else:
                result['errors'].append("Retry mechanisms not implemented")
                logger.error(" Retry mechanisms missing")

            # Test 4: Check for connection recovery
            connection_recovery = self._test_connection_recovery()
            result['details']['connection_recovery'] = connection_recovery

            if connection_recovery['recoverable']:
                logger.info(" Connection recovery implemented")
            else:
                result['errors'].append("Connection recovery not implemented")
                logger.error(" Connection recovery missing")

            # Determine overall success
            result['success'] = (
                offline_handling['handled'] and
                timeout_handling['handled'] and
                retry_mechanisms['implemented'] and
                connection_recovery['recoverable']
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

    def _test_offline_mode_handling(self) -> Dict[str, Any]:
        """Test offline mode handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for network reachability
            reachability_checks = [
                'network', 'Network', 'connectivity', 'Connectivity',
                'reachable', 'isConnected', 'connectionStatus'
            ]

            found_reachability = []
            for check in reachability_checks:
                if check.lower() in content.lower():
                    found_reachability.append(check)

            # Check for offline indicators
            offline_indicators = [
                'offline', 'Offline', 'noInternet', 'noConnection',
                'disconnected', 'unreachable'
            ]

            found_offline = []
            for indicator in offline_indicators:
                if indicator.lower() in content.lower():
                    found_offline.append(indicator)

            # Check for cached data usage
            cached_usage = [
                'cache', 'Cache', 'local', 'Local',
                'offlineData', 'cachedData', 'storedData'
            ]

            found_cached = []
            for cached in cached_usage:
                if cached in content:
                    found_cached.append(cached)

            # Check for user notifications
            offline_notifications = [
                'Alert', 'alert', 'showMessage', 'displayAlert',
                'offlineMessage', 'networkError'
            ]

            found_notifications = []
            for notification in offline_notifications:
                if notification in content:
                    found_notifications.append(notification)

            handled = (
                len(found_reachability) > 0 and
                len(found_offline) > 0
            )

            return {
                'handled': handled,
                'reachability_checks': found_reachability,
                'offline_indicators': found_offline,
                'cached_usage': found_cached,
                'offline_notifications': found_notifications,
                'offline_score': len(found_reachability) + len(found_offline) + len(found_cached)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing offline mode handling: {str(e)}']}

    def _test_timeout_handling(self) -> Dict[str, Any]:
        """Test timeout handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for timeout configuration
            timeout_config = [
                'timeout', 'Timeout', 'timeLimit', 'interval',
                'duration', 'TimeoutInterval'
            ]

            found_config = []
            for config in timeout_config:
                if config in content:
                    found_config.append(config)

            # Check for timeout error detection
            timeout_errors = [
                'timeout', 'Timeout', 'timedOut', 'timeOut',
                'requestTimeout', 'connectionTimeout'
            ]

            found_errors = []
            for error in timeout_errors:
                if error in content:
                    found_errors.append(error)

            # Check for timeout handling
            timeout_handling = [
                'catch', 'Error', 'timeoutError', 'handleTimeout',
                'timeoutHandler', 'timeoutCallback'
            ]

            found_handling = []
            for handling in timeout_handling:
                if handling in content:
                    found_handling.append(handling)

            # Check for fallback behavior
            fallback_behavior = [
                'fallback', 'Fallback', 'alternative', 'Alternative',
                'default', 'Default', 'backup', 'Backup'
            ]

            found_fallback = []
            for fallback in fallback_behavior:
                if fallback.lower() in content.lower():
                    found_fallback.append(fallback)

            handled = (
                len(found_config) > 0 and
                len(found_errors) > 0
            )

            return {
                'handled': handled,
                'timeout_config': found_config,
                'timeout_errors': found_errors,
                'timeout_handling': found_handling,
                'fallback_behavior': found_fallback,
                'timeout_score': len(found_config) + len(found_errors) + len(found_handling)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing timeout handling: {str(e)}']}

    def _test_retry_mechanisms(self) -> Dict[str, Any]:
        """Test retry mechanisms"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for retry logic
            retry_logic = [
                'retry', 'Retry', 'attempt', 'Attempt',
                'tryAgain', 'repeat', 'reconnect'
            ]

            found_retry = []
            for retry in retry_logic:
                if retry.lower() in content.lower():
                    found_retry.append(retry)

            # Check for retry configuration
            retry_config = [
                'maxRetries', 'retryCount', 'retryLimit',
                'retryDelay', 'retryInterval', 'backoff'
            ]

            found_config = []
            for config in retry_config:
                if config in content:
                    found_config.append(config)

            # Check for exponential backoff
            backoff_logic = [
                'exponential', 'backoff', 'exponentialBackoff',
                'delay', 'sleep', 'wait', 'interval'
            ]

            found_backoff = []
            for backoff in backoff_logic:
                if backoff.lower() in content.lower():
                    found_backoff.append(backoff)

            # Check for retry conditions
            retry_conditions = [
                'shouldRetry', 'retryCondition', 'retryable',
                'canRetry', 'isRetryable'
            ]

            found_conditions = []
            for condition in retry_conditions:
                if condition in content:
                    found_conditions.append(condition)

            implemented = (
                len(found_retry) > 0 and
                len(found_config) > 0
            )

            return {
                'implemented': implemented,
                'retry_logic': found_retry,
                'retry_config': found_config,
                'backoff_logic': found_backoff,
                'retry_conditions': found_conditions,
                'retry_score': len(found_retry) + len(found_config) + len(found_backoff)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error testing retry mechanisms: {str(e)}']}

    def _test_connection_recovery(self) -> Dict[str, Any]:
        """Test connection recovery"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'recoverable': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for connection monitoring
            connection_monitoring = [
                'connection', 'Connection', 'network', 'Network',
                'reachability', 'connectivity', 'isConnected'
            ]

            found_monitoring = []
            for monitor in connection_monitoring:
                if monitor in content:
                    found_monitoring.append(monitor)

            # Check for auto-recovery
            auto_recovery = [
                'autoReconnect', 'autoRecover', 'automaticRecovery',
                'selfHealing', 'autoRepair', 'restoreConnection'
            ]

            found_auto = []
            for auto in auto_recovery:
                if auto.lower() in content.lower():
                    found_auto.append(auto)

            # Check for recovery triggers
            recovery_triggers = [
                'onNetworkChange', 'networkChanged', 'connectionRestored',
                'becameReachable', 'networkAvailable', 'connectionBack'
            ]

            found_triggers = []
            for trigger in recovery_triggers:
                if trigger in content:
                    found_triggers.append(trigger)

            # Check for user-initiated recovery
            user_recovery = [
                'refresh', 'Reload', 'retry', 'Retry',
                'reconnect', 'tryAgain', 'manualRefresh'
            ]

            found_user = []
            for user in user_recovery:
                if user in content:
                    found_user.append(user)

            recoverable = (
                len(found_monitoring) > 0 and
                (len(found_auto) > 0 or len(found_user) > 0)
            )

            return {
                'recoverable': recoverable,
                'connection_monitoring': found_monitoring,
                'auto_recovery': found_auto,
                'recovery_triggers': found_triggers,
                'user_recovery': found_user,
                'recovery_score': len(found_monitoring) + len(found_auto) + len(found_triggers)
            }

        except Exception as e:
            return {'recoverable': False, 'errors': [f'Error testing connection recovery: {str(e)}']}

    def test_data_corruption_scenarios(self) -> Dict[str, Any]:
        """Test data corruption scenarios"""
        test_name = "Data Corruption Scenarios"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for malformed email handling
            malformed_email_handling = self._test_malformed_email_handling()
            result['details']['malformed_email_handling'] = malformed_email_handling

            if malformed_email_handling['handled']:
                logger.info(" Malformed email handling implemented")
            else:
                result['errors'].append("Malformed email handling not implemented")
                logger.error(" Malformed email handling missing")

            # Test 2: Check for incomplete data handling
            incomplete_data_handling = self._test_incomplete_data_handling()
            result['details']['incomplete_data_handling'] = incomplete_data_handling

            if incomplete_data_handling['handled']:
                logger.info(" Incomplete data handling implemented")
            else:
                result['errors'].append("Incomplete data handling not implemented")
                logger.error(" Incomplete data handling missing")

            # Test 3: Check for encoding issues
            encoding_issues = self._test_encoding_issues()
            result['details']['encoding_issues'] = encoding_issues

            if encoding_issues['handled']:
                logger.info(" Encoding issues handling implemented")
            else:
                result['errors'].append("Encoding issues handling not implemented")
                logger.error(" Encoding issues handling missing")

            # Test 4: Check for duplicate detection
            duplicate_detection = self._test_duplicate_detection()
            result['details']['duplicate_detection'] = duplicate_detection

            if duplicate_detection['detected']:
                logger.info(" Duplicate detection implemented")
            else:
                result['errors'].append("Duplicate detection not implemented")
                logger.error(" Duplicate detection missing")

            # Determine overall success
            result['success'] = (
                malformed_email_handling['handled'] and
                incomplete_data_handling['handled'] and
                encoding_issues['handled'] and
                duplicate_detection['detected']
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

    def _test_malformed_email_handling(self) -> Dict[str, Any]:
        """Test malformed email handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for data validation
            data_validation = [
                'validate', 'Validate', 'check', 'Check',
                'verify', 'Verify', 'isValid', 'isvalid'
            ]

            found_validation = []
            for validation in data_validation:
                if validation in content:
                    found_validation.append(validation)

            # Check for nil/null checks
            nil_checks = [
                'nil', 'Nil', 'null', 'Null', 'optional',
                'Optional', 'guard', 'if.*nil', '!= nil'
            ]

            found_nil = []
            for check in nil_checks:
                if check in content:
                    found_nil.append(check)

            # Check for error handling in parsing
            parsing_error_handling = [
                'catch', 'Error', 'do.*catch', 'try.*catch',
                'parseError', 'jsonError', 'decodeError'
            ]

            found_parsing = []
            for parsing in parsing_error_handling:
                if parsing in content:
                    found_parsing.append(parsing)

            # Check for fallback values
            fallback_values = [
                'default', 'Default', 'fallback', 'Fallback',
                'empty', 'Empty', 'placeholder'
            ]

            found_fallback = []
            for fallback in fallback_values:
                if fallback.lower() in content.lower():
                    found_fallback.append(fallback)

            handled = (
                len(found_validation) > 0 and
                len(found_nil) > 0
            )

            return {
                'handled': handled,
                'data_validation': found_validation,
                'nil_checks': found_nil,
                'parsing_error_handling': found_parsing,
                'fallback_values': found_fallback,
                'validation_score': len(found_validation) + len(found_nil) + len(found_parsing)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing malformed email handling: {str(e)}']}

    def _test_incomplete_data_handling(self) -> Dict[str, Any]:
        """Test incomplete data handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for required field validation
            field_validation = [
                'required', 'Required', 'mandatory', 'Mandatory',
                'missing', 'Missing', 'incomplete', 'Incomplete'
            ]

            found_field = []
            for field in field_validation:
                if field.lower() in content.lower():
                    found_field.append(field)

            # Check for partial data handling
            partial_data = [
                'partial', 'Partial', 'incomplete', 'Incomplete',
                'partialData', 'incompleteData'
            ]

            found_partial = []
            for partial in partial_data:
                if partial in content:
                    found_partial.append(partial)

            # Check for data reconstruction
            data_reconstruction = [
                'reconstruct', 'Reconstruct', 'rebuild', 'Rebuild',
                'infer', 'Infer', 'estimate', 'Estimate'
            ]

            found_reconstruction = []
            for reconstruction in data_reconstruction:
                if reconstruction.lower() in content.lower():
                    found_reconstruction.append(reconstruction)

            # Check for user notifications for incomplete data
            incomplete_notifications = [
                'Alert', 'alert', 'showMessage', 'displayAlert',
                'incompleteData', 'missingInfo', 'dataIncomplete'
            ]

            found_notifications = []
            for notification in incomplete_notifications:
                if notification in content:
                    found_notifications.append(notification)

            handled = (
                len(found_field) > 0 and
                (len(found_partial) > 0 or len(found_reconstruction) > 0)
            )

            return {
                'handled': handled,
                'field_validation': found_field,
                'partial_data': found_partial,
                'data_reconstruction': found_reconstruction,
                'incomplete_notifications': found_notifications,
                'incomplete_score': len(found_field) + len(found_partial) + len(found_reconstruction)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing incomplete data handling: {str(e)}']}

    def _test_encoding_issues(self) -> Dict[str, Any]:
        """Test encoding issues handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for encoding handling
            encoding_handling = [
                'encoding', 'Encoding', 'charset', 'Charset',
                'utf8', 'UTF8', 'unicode', 'Unicode'
            ]

            found_encoding = []
            for encoding in encoding_handling:
                if encoding in content:
                    found_encoding.append(encoding)

            # Check for string sanitization
            string_sanitization = [
                'sanitize', 'Sanitize', 'clean', 'Clean',
                'escape', 'Escape', 'filter', 'Filter'
            ]

            found_sanitization = []
            for sanitization in string_sanitization:
                if sanitization.lower() in content.lower():
                    found_sanitization.append(sanitization)

            # Check for character set conversion
            charset_conversion = [
                'convert', 'Convert', 'transform', 'Transform',
                'encode', 'Encode', 'decode', 'Decode'
            ]

            found_conversion = []
            for conversion in charset_conversion:
                if conversion in content:
                    found_conversion.append(conversion)

            # Check for fallback encodings
            fallback_encodings = [
                'fallback', 'Fallback', 'default', 'Default',
                'alternative', 'Alternative'
            ]

            found_fallback = []
            for fallback in fallback_encodings:
                if fallback.lower() in content.lower():
                    found_fallback.append(fallback)

            handled = (
                len(found_encoding) > 0 and
                len(found_sanitization) > 0
            )

            return {
                'handled': handled,
                'encoding_handling': found_encoding,
                'string_sanitization': found_sanitization,
                'charset_conversion': found_conversion,
                'fallback_encodings': found_fallback,
                'encoding_score': len(found_encoding) + len(found_sanitization) + len(found_conversion)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing encoding issues: {str(e)}']}

    def _test_duplicate_detection(self) -> Dict[str, Any]:
        """Test duplicate detection"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'detected': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for unique identifiers
            unique_identifiers = [
                'id', 'Id', 'ID', 'unique', 'Unique',
                'messageId', 'emailId', 'threadId'
            ]

            found_identifiers = []
            for identifier in unique_identifiers:
                if identifier in content:
                    found_identifiers.append(identifier)

            # Check for duplicate checking logic
            duplicate_logic = [
                'duplicate', 'Duplicate', 'exists', 'Exists',
                'alreadyExists', 'findDuplicate', 'checkDuplicate'
            ]

            found_logic = []
            for logic in duplicate_logic:
                if logic.lower() in content.lower():
                    found_logic.append(logic)

            # Check for deduplication
            deduplication = [
                'deduplicate', 'Deduplicate', 'removeDuplicate',
                'filterDuplicate', 'uniqueList', 'distinct'
            ]

            found_deduplication = []
            for dedupe in deduplication:
                if dedupe in content:
                    found_deduplication.append(dedupe)

            # Check for merge strategies
            merge_strategies = [
                'merge', 'Merge', 'combine', 'Combine',
                'update', 'Update', 'replace', 'Replace'
            ]

            found_merge = []
            for merge in merge_strategies:
                if merge in content:
                    found_merge.append(merge)

            detected = (
                len(found_identifiers) > 0 and
                len(found_logic) > 0
            )

            return {
                'detected': detected,
                'unique_identifiers': found_identifiers,
                'duplicate_logic': found_logic,
                'deduplication': found_deduplication,
                'merge_strategies': found_merge,
                'duplicate_score': len(found_identifiers) + len(found_logic) + len(found_deduplication)
            }

        except Exception as e:
            return {'detected': False, 'errors': [f'Error testing duplicate detection: {str(e)}']}

    def test_edge_case_scenarios(self) -> Dict[str, Any]:
        """Test edge case scenarios"""
        test_name = "Edge Case Scenarios"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for empty inbox handling
            empty_inbox_handling = self._test_empty_inbox_handling()
            result['details']['empty_inbox_handling'] = empty_inbox_handling

            if empty_inbox_handling['handled']:
                logger.info(" Empty inbox handling implemented")
            else:
                result['errors'].append("Empty inbox handling not implemented")
                logger.error(" Empty inbox handling missing")

            # Test 2: Check for large volume handling
            large_volume_handling = self._test_large_volume_handling()
            result['details']['large_volume_handling'] = large_volume_handling

            if large_volume_handling['handled']:
                logger.info(" Large volume handling implemented")
            else:
                result['errors'].append("Large volume handling not implemented")
                logger.error(" Large volume handling missing")

            # Test 3: Check for memory pressure handling
            memory_pressure_handling = self._test_memory_pressure_handling()
            result['details']['memory_pressure_handling'] = memory_pressure_handling

            if memory_pressure_handling['handled']:
                logger.info(" Memory pressure handling implemented")
            else:
                result['errors'].append("Memory pressure handling not implemented")
                logger.error(" Memory pressure handling missing")

            # Test 4: Check for API rate limit handling
            api_rate_limit_handling = self._test_api_rate_limit_handling()
            result['details']['api_rate_limit_handling'] = api_rate_limit_handling

            if api_rate_limit_handling['handled']:
                logger.info(" API rate limit handling implemented")
            else:
                result['errors'].append("API rate limit handling not implemented")
                logger.error(" API rate limit handling missing")

            # Determine overall success
            result['success'] = (
                empty_inbox_handling['handled'] and
                large_volume_handling['handled'] and
                memory_pressure_handling['handled'] and
                api_rate_limit_handling['handled']
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

    def _test_empty_inbox_handling(self) -> Dict[str, Any]:
        """Test empty inbox handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for empty array handling
            empty_array_handling = [
                'empty', 'Empty', 'isEmpty', 'count.*0',
                'no.*emails', 'zero.*emails', 'empty.*inbox'
            ]

            found_empty = []
            for empty in empty_array_handling:
                import re
                if re.search(empty, content, re.IGNORECASE):
                    found_empty.append(empty)

            # Check for empty state UI
            empty_state_ui = [
                'EmptyView', 'emptyState', 'placeholder',
                'noData', 'emptyMessage', 'showEmpty'
            ]

            found_ui = []
            for ui in empty_state_ui:
                if ui in content:
                    found_ui.append(ui)

            # Check for user messaging
            empty_messaging = [
                'message', 'Message', 'alert', 'Alert',
                'inform', 'notify', 'showMessage'
            ]

            found_messaging = []
            for messaging in empty_messaging:
                if messaging in content:
                    found_messaging.append(messaging)

            # Check for graceful handling
            graceful_handling = [
                'guard', 'if.*empty', 'optional', 'Optional',
                'safe', 'unwrap', 'nil.*check'
            ]

            found_graceful = []
            for graceful in graceful_handling:
                if graceful in content:
                    found_graceful.append(graceful)

            handled = (
                len(found_empty) > 0 and
                len(found_graceful) > 0
            )

            return {
                'handled': handled,
                'empty_array_handling': found_empty,
                'empty_state_ui': found_ui,
                'empty_messaging': found_messaging,
                'graceful_handling': found_graceful,
                'empty_score': len(found_empty) + len(found_ui) + len(found_graceful)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing empty inbox handling: {str(e)}']}

    def _test_large_volume_handling(self) -> Dict[str, Any]:
        """Test large volume handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for pagination
            pagination = [
                'page', 'Page', 'limit', 'Limit',
                'offset', 'pageSize', 'maxResults'
            ]

            found_pagination = []
            for page in pagination:
                if page in content:
                    found_pagination.append(page)

            # Check for batching
            batching = [
                'batch', 'Batch', 'chunk', 'Chunk',
                'processBatch', 'batchSize', 'group'
            ]

            found_batching = []
            for batch in batching:
                if batch.lower() in content.lower():
                    found_batching.append(batch)

            # Check for lazy loading
            lazy_loading = [
                'lazy', 'Lazy', 'onDemand', 'onAppear',
                'loadMore', 'incremental'
            ]

            found_lazy = []
            for lazy in lazy_loading:
                if lazy in content:
                    found_lazy.append(lazy)

            # Check for progress indication
            progress_indication = [
                'ProgressView', 'progress', 'loading',
                'isLoading', 'processing', 'indicating'
            ]

            found_progress = []
            for progress in progress_indication:
                if progress in content:
                    found_progress.append(progress)

            handled = (
                len(found_pagination) > 0 and
                (len(found_batching) > 0 or len(found_lazy) > 0)
            )

            return {
                'handled': handled,
                'pagination': found_pagination,
                'batching': found_batching,
                'lazy_loading': found_lazy,
                'progress_indication': found_progress,
                'volume_score': len(found_pagination) + len(found_batching) + len(found_lazy)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing large volume handling: {str(e)}']}

    def _test_memory_pressure_handling(self) -> Dict[str, Any]:
        """Test memory pressure handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for memory management
            memory_management = [
                'memory', 'Memory', 'autoreleasepool',
                'weak', 'unowned', 'release'
            ]

            found_memory = []
            for memory in memory_management:
                if memory in content:
                    found_memory.append(memory)

            # Check for resource cleanup
            resource_cleanup = [
                'cleanup', 'Cleanup', 'deinit', 'dealloc',
                'dispose', 'release', 'clear'
            ]

            found_cleanup = []
            for cleanup in resource_cleanup:
                if cleanup in content:
                    found_cleanup.append(cleanup)

            # Check for data streaming
            data_streaming = [
                'stream', 'Stream', 'chunk', 'Chunk',
                'partial', 'incremental', 'progressive'
            ]

            found_streaming = []
            for stream in data_streaming:
                if stream.lower() in content.lower():
                    found_streaming.append(stream)

            # Check for memory warnings
            memory_warnings = [
                'memoryWarning', '.didReceiveMemoryWarning',
                'memoryPressure', 'lowMemory'
            ]

            found_warnings = []
            for warning in memory_warnings:
                if warning in content:
                    found_warnings.append(warning)

            handled = (
                len(found_memory) > 0 and
                len(found_cleanup) > 0
            )

            return {
                'handled': handled,
                'memory_management': found_memory,
                'resource_cleanup': found_cleanup,
                'data_streaming': found_streaming,
                'memory_warnings': found_warnings,
                'memory_score': len(found_memory) + len(found_cleanup) + len(found_streaming)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing memory pressure handling: {str(e)}']}

    def _test_api_rate_limit_handling(self) -> Dict[str, Any]:
        """Test API rate limit handling"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'handled': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for rate limit detection
            rate_limit_detection = [
                '429', 'rateLimit', 'rateLimitExceeded',
                'tooManyRequests', 'quotaExceeded'
            ]

            found_detection = []
            for detection in rate_limit_detection:
                if detection.lower() in content.lower():
                    found_detection.append(detection)

            # Check for rate limit handling
            rate_limit_handling = [
                'backoff', 'Backoff', 'exponentialBackoff',
                'wait', 'delay', 'sleep', 'retryAfter'
            ]

            found_handling = []
            for handling in rate_limit_handling:
                if handling.lower() in content.lower():
                    found_handling.append(handling)

            # Check for request throttling
            request_throttling = [
                'throttle', 'Throttle', 'limit', 'Limit',
                'rateLimit', 'quota', 'requestCount'
            ]

            found_throttling = []
            for throttle in request_throttling:
                if throttle in content:
                    found_throttling.append(throttle)

            # Check for user notification
            rate_limit_notifications = [
                'Alert', 'alert', 'showMessage', 'displayAlert',
                'rateLimitMessage', 'quotaWarning'
            ]

            found_notifications = []
            for notification in rate_limit_notifications:
                if notification in content:
                    found_notifications.append(notification)

            handled = (
                len(found_detection) > 0 and
                len(found_handling) > 0
            )

            return {
                'handled': handled,
                'rate_limit_detection': found_detection,
                'rate_limit_handling': found_handling,
                'request_throttling': found_throttling,
                'rate_limit_notifications': found_notifications,
                'rate_limit_score': len(found_detection) + len(found_handling) + len(found_throttling)
            }

        except Exception as e:
            return {'handled': False, 'errors': [f'Error testing API rate limit handling: {str(e)}']}

    def generate_test_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        logger.info(" Generating Gmail Negative Paths test report")

        total_tests = len(self.test_results)
        passed_tests = sum(1 for test in self.test_results if test['success'])
        failed_tests = total_tests - passed_tests

        report = {
            'test_suite': 'Gmail Negative Paths E2E Validation',
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
            report['summary']['recommendations'].append("All Gmail negative path tests passed - system is resilient to failures")
        else:
            report['summary']['recommendations'].append("Address critical error handling issues before production deployment")

        if self.gmail_test_credentials.get('mock_mode', False):
            report['summary']['warnings'].append("Tests run in mock mode - configure real Gmail credentials for full validation")
            report['summary']['recommendations'].append("Set up Gmail test credentials for comprehensive negative path validation")

        return report

    def save_test_report(self, report: Dict[str, Any]) -> str:
        """Save test report to file"""
        report_file = os.path.join(self.test_data_dir, f"gmail_negative_paths_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")

        try:
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)

            logger.info(f" Test report saved to: {report_file}")
            return report_file

        except Exception as e:
            logger.error(f" Error saving test report: {e}")
            return ""

    def run_all_tests(self) -> Dict[str, Any]:
        """Run all Gmail negative path tests"""
        logger.info(" Starting Gmail Negative Paths E2E Test Suite")

        # Run all test methods
        self.test_authentication_failure_scenarios()
        self.test_network_connectivity_issues()
        self.test_data_corruption_scenarios()
        self.test_edge_case_scenarios()

        # Generate and save report
        report = self.generate_test_report()
        report_file = self.save_test_report(report)

        if report_file:
            report['report_file'] = report_file

        logger.info(f" Gmail Negative Paths E2E Test Suite completed - Success Rate: {report['success_rate']:.1f}%")

        return report

def main():
    """Main test execution function"""
    print(" Gmail Negative Paths E2E Test Suite")
    print("=" * 50)

    # Create and run test suite
    test_suite = GmailNegativePathsE2ETest()
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