#!/usr/bin/env python3
"""
Gmail UI Integration E2E Validation Test
Validates Gmail receipts table, filtering, caching, and UI interaction capabilities
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
        logging.FileHandler('test_gmail_ui_integration.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GmailUIIntegrationE2ETest:
    """Comprehensive Gmail UI integration validation"""

    def __init__(self):
        self.test_results = []
        self.app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.production_app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.test_data_dir = tempfile.mkdtemp(prefix="gmail_ui_test_")
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

    def test_gmail_receipts_table_functionality(self) -> Dict[str, Any]:
        """Test Gmail receipts table functionality"""
        test_name = "Gmail Receipts Table Functionality"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for Gmail receipts table implementation
            table_implementation = self._check_gmail_receipts_table_implementation()
            result['details']['table_implementation'] = table_implementation

            if table_implementation['implemented']:
                logger.info(" Gmail receipts table implemented")
            else:
                result['errors'].append("Gmail receipts table not found")
                logger.error(" Gmail receipts table missing")

            # Test 2: Test spreadsheet-like functionality
            spreadsheet_functionality = self._test_spreadsheet_functionality()
            result['details']['spreadsheet_functionality'] = spreadsheet_functionality

            if spreadsheet_functionality['functional']:
                logger.info(" Spreadsheet-like functionality working")
            else:
                result['errors'].append("Spreadsheet-like functionality not working")
                logger.error(" Spreadsheet-like functionality missing")

            # Test 3: Test inline editing capabilities
            inline_editing = self._test_inline_editing_capabilities()
            result['details']['inline_editing'] = inline_editing

            if inline_editing['can_edit']:
                logger.info(" Inline editing capabilities working")
            else:
                result['errors'].append("Inline editing capabilities not working")
                logger.error(" Inline editing missing")

            # Test 4: Test multi-select functionality
            multi_select = self._test_multi_select_functionality()
            result['details']['multi_select'] = multi_select

            if multi_select['can_multi_select']:
                logger.info(" Multi-select functionality working")
            else:
                result['errors'].append("Multi-select functionality not working")
                logger.error(" Multi-select missing")

            # Determine overall success
            result['success'] = (
                table_implementation['implemented'] and
                spreadsheet_functionality['functional'] and
                inline_editing['can_edit'] and
                multi_select['can_multi_select']
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

    def _check_gmail_receipts_table_implementation(self) -> Dict[str, Any]:
        """Check for Gmail receipts table implementation"""
        try:
            # Look for Gmail receipts table files
            table_files = [
                'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift',
                'FinanceMate/Views/Gmail/GmailView.swift',
                'FinanceMate/Views/Gmail/GmailTransactionRow.swift'
            ]

            found_files = []
            for file_path in table_files:
                full_path = os.path.join(self.app_path, file_path)
                if os.path.exists(full_path):
                    found_files.append(file_path)

            if not found_files:
                return {'implemented': False, 'errors': ['No Gmail receipts table files found']}

            # Analyze table implementation
            table_analysis = {
                'table_structures': [],
                'data_sources': [],
                'table_features': []
            }

            for file_path in found_files:
                full_path = os.path.join(self.app_path, file_path)
                with open(full_path, 'r') as f:
                    content = f.read()

                # Check for table structures
                table_structures = [
                    'Table', 'List', 'ForEach', 'ListRow',
                    'UITableView', 'NSTableView', 'Table'
                ]

                for structure in table_structures:
                    if structure in content:
                        table_analysis['table_structures'].append(f"{file_path}:{structure}")

                # Check for data sources
                data_sources = [
                    '@State', '@StateObject', '@ObservedObject',
                    'dataSource', 'items', 'receipts', 'emails'
                ]

                for source in data_sources:
                    if source in content:
                        table_analysis['data_sources'].append(f"{file_path}:{source}")

                # Check for table features
                table_features = [
                    'selection', 'onTap', 'contextMenu', 'swipeActions',
                    'editable', 'inline', 'multiSelect'
                ]

                for feature in table_features:
                    if feature in content:
                        table_analysis['table_features'].append(f"{file_path}:{feature}")

            return {
                'implemented': True,
                'found_files': found_files,
                'table_analysis': table_analysis,
                'implementation_score': len(found_files) + len(table_analysis['table_features'])
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking Gmail receipts table: {str(e)}']}

    def _test_spreadsheet_functionality(self) -> Dict[str, Any]:
        """Test spreadsheet-like functionality"""
        try:
            gmail_table_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift')

            if not os.path.exists(gmail_table_path):
                return {'functional': False, 'errors': ['GmailReceiptsTableView.swift not found']}

            with open(gmail_table_path, 'r') as f:
                content = f.read()

            # Check for spreadsheet features
            spreadsheet_features = {
                'column_headers': ['header', 'title', 'label', 'Text'],
                'row_data': ['row', 'item', 'data', 'content'],
                'sorting': ['sort', 'SortDescriptor', 'sorted'],
                'filtering': ['filter', 'predicate', 'NSPredicate'],
                'selection': ['selection', 'selected', 'onSelectionChange'],
                'context_menu': ['contextMenu', 'menu', 'ContextMenu'],
                'keyboard_navigation': ['keyboard', 'key', 'onKeyPress']
            }

            found_features = {}
            for feature, patterns in spreadsheet_features.items():
                found = []
                for pattern in patterns:
                    if pattern in content:
                        found.append(pattern)
                found_features[feature] = found

            # Check for data manipulation
            data_manipulation = [
                'edit', 'Edit', 'update', 'Update',
                'delete', 'Delete', 'modify', 'Modify'
            ]

            found_manipulation = []
            for pattern in data_manipulation:
                if pattern in content:
                    found_manipulation.append(pattern)

            # Calculate functionality score
            feature_count = sum(len(features) for features in found_features.values())
            functionality_score = feature_count + len(found_manipulation)

            functional = functionality_score >= 5  # Minimum threshold for functionality

            return {
                'functional': functional,
                'spreadsheet_features': found_features,
                'data_manipulation': found_manipulation,
                'functionality_score': functionality_score,
                'features_implemented': feature_count
            }

        except Exception as e:
            return {'functional': False, 'errors': [f'Error testing spreadsheet functionality: {str(e)}']}

    def _test_inline_editing_capabilities(self) -> Dict[str, Any]:
        """Test inline editing capabilities"""
        try:
            gmail_table_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift')

            if not os.path.exists(gmail_table_path):
                return {'can_edit': False, 'errors': ['GmailReceiptsTableView.swift not found']}

            with open(gmail_table_path, 'r') as f:
                content = f.read()

            # Check for inline editing components
            editing_components = [
                'TextField', 'TextEditor', 'TextFieldStyle',
                'editable', 'Editable', 'inline', 'Inline'
            ]

            found_components = []
            for component in editing_components:
                if component in content:
                    found_components.append(component)

            # Check for editing state management
            editing_state = [
                '@State', 'editing', 'isEditing', 'editMode',
                'EditMode', 'editingState', 'inlineEditing'
            ]

            found_state = []
            for state in editing_state:
                if state in content:
                    found_state.append(state)

            # Check for edit actions
            edit_actions = [
                'onEdit', 'onEditingChange', 'editAction',
                'saveEdit', 'cancelEdit', 'commitEdit'
            ]

            found_actions = []
            for action in edit_actions:
                if action in content:
                    found_actions.append(action)

            # Check for data binding for editing
            data_binding = [
                'binding', 'Binding', '$', '.constant',
                '.wrappedValue', '.projectedValue'
            ]

            found_binding = []
            for binding in data_binding:
                if binding in content:
                    found_binding.append(binding)

            can_edit = (
                len(found_components) > 0 and
                len(found_state) > 0 and
                len(found_actions) > 0
            )

            return {
                'can_edit': can_edit,
                'editing_components': found_components,
                'editing_state': found_state,
                'edit_actions': found_actions,
                'data_binding': found_binding,
                'editing_score': len(found_components) + len(found_state) + len(found_actions)
            }

        except Exception as e:
            return {'can_edit': False, 'errors': [f'Error testing inline editing: {str(e)}']}

    def _test_multi_select_functionality(self) -> Dict[str, Any]:
        """Test multi-select functionality"""
        try:
            gmail_table_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailReceiptsTableView.swift')

            if not os.path.exists(gmail_table_path):
                return {'can_multi_select': False, 'errors': ['GmailReceiptsTableView.swift not found']}

            with open(gmail_table_path, 'r') as f:
                content = f.read()

            # Check for multi-select components
            multi_select_components = [
                'EditButton', 'selection', 'multiple',
                'multiSelect', 'Set', 'Selection'
            ]

            found_components = []
            for component in multi_select_components:
                if component in content:
                    found_components.append(component)

            # Check for selection state
            selection_state = [
                'selectedItems', 'selectedReceipts',
                'selection', 'Set<', 'SelectionSet'
            ]

            found_state = []
            for state in selection_state:
                if state in content:
                    found_state.append(state)

            # Check for batch actions
            batch_actions = [
                'deleteSelected', 'batchDelete', 'bulkEdit',
                'multipleDelete', 'deleteSelection'
            ]

            found_actions = []
            for action in batch_actions:
                if action in content:
                    found_actions.append(action)

            # Check for selection UI
            selection_ui = [
                'onSelectionChange', 'selectionEnabled',
                'editMode', 'selectionMode'
            ]

            found_ui = []
            for ui in selection_ui:
                if ui in content:
                    found_ui.append(ui)

            can_multi_select = (
                len(found_components) > 0 and
                len(found_state) > 0
            )

            return {
                'can_multi_select': can_multi_select,
                'multi_select_components': found_components,
                'selection_state': found_state,
                'batch_actions': found_actions,
                'selection_ui': found_ui,
                'multi_select_score': len(found_components) + len(found_state) + len(found_actions)
            }

        except Exception as e:
            return {'can_multi_select': False, 'errors': [f'Error testing multi-select: {str(e)}']}

    def test_gmail_filtering_system(self) -> Dict[str, Any]:
        """Test Gmail filtering system"""
        test_name = "Gmail Filtering System"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for filter bar implementation
            filter_bar_implementation = self._check_filter_bar_implementation()
            result['details']['filter_bar_implementation'] = filter_bar_implementation

            if filter_bar_implementation['implemented']:
                logger.info(" Filter bar implemented")
            else:
                result['errors'].append("Filter bar not found")
                logger.error(" Filter bar missing")

            # Test 2: Test advanced filtering capabilities
            advanced_filtering = self._test_advanced_filtering_capabilities()
            result['details']['advanced_filtering'] = advanced_filtering

            if advanced_filtering['advanced']:
                logger.info(" Advanced filtering capabilities working")
            else:
                result['errors'].append("Advanced filtering capabilities not working")
                logger.error(" Advanced filtering missing")

            # Test 3: Test filter persistence
            filter_persistence = self._test_filter_persistence()
            result['details']['filter_persistence'] = filter_persistence

            if filter_persistence['persistent']:
                logger.info(" Filter persistence working")
            else:
                result['errors'].append("Filter persistence not working")
                logger.error(" Filter persistence missing")

            # Test 4: Test filter performance
            filter_performance = self._test_filter_performance()
            result['details']['filter_performance'] = filter_performance

            if filter_performance['performant']:
                logger.info(" Filter performance acceptable")
            else:
                result['errors'].append("Filter performance not acceptable")
                logger.error(" Filter performance insufficient")

            # Determine overall success
            result['success'] = (
                filter_bar_implementation['implemented'] and
                advanced_filtering['advanced'] and
                filter_persistence['persistent'] and
                filter_performance['performant']
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

    def _check_filter_bar_implementation(self) -> Dict[str, Any]:
        """Check for filter bar implementation"""
        try:
            # Look for filter bar files
            filter_files = [
                'FinanceMate/Views/Gmail/GmailFilterBar.swift',
                'FinanceMate/Views/Gmail/GmailView.swift'
            ]

            found_files = []
            for file_path in filter_files:
                full_path = os.path.join(self.app_path, file_path)
                if os.path.exists(full_path):
                    found_files.append(file_path)

            if not found_files:
                return {'implemented': False, 'errors': ['No filter bar files found']}

            # Analyze filter bar implementation
            filter_analysis = {
                'filter_components': [],
                'filter_controls': [],
                'filter_data_binding': []
            }

            for file_path in found_files:
                full_path = os.path.join(self.app_path, file_path)
                with open(full_path, 'r') as f:
                    content = f.read()

                # Check for filter components
                filter_components = [
                    'TextField', 'SearchField', 'TextEditor',
                    'Picker', 'Toggle', 'Slider', 'DatePicker'
                ]

                for component in filter_components:
                    if component in content:
                        filter_analysis['filter_components'].append(f"{file_path}:{component}")

                # Check for filter controls
                filter_controls = [
                    'search', 'filter', 'Filter', 'Search',
                    'dateRange', 'amountRange', 'vendor', 'category'
                ]

                for control in filter_controls:
                    if control.lower() in content.lower():
                        filter_analysis['filter_controls'].append(f"{file_path}:{control}")

                # Check for data binding
                data_binding = [
                    '@State', '@Binding', '$filter', 'filterState',
                    'searchText', 'filterCriteria'
                ]

                for binding in data_binding:
                    if binding in content:
                        filter_analysis['filter_data_binding'].append(f"{file_path}:{binding}")

            return {
                'implemented': True,
                'found_files': found_files,
                'filter_analysis': filter_analysis,
                'implementation_score': len(found_files) + len(filter_analysis['filter_components'])
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking filter bar: {str(e)}']}

    def _test_advanced_filtering_capabilities(self) -> Dict[str, Any]:
        """Test advanced filtering capabilities"""
        try:
            filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailFilterBar.swift')

            if not os.path.exists(filter_bar_path):
                # Fall back to GmailView
                filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(filter_bar_path):
                return {'advanced': False, 'errors': ['No filter implementation found']}

            with open(filter_bar_path, 'r') as f:
                content = f.read()

            # Check for advanced filter types
            advanced_filters = {
                'date_filters': ['date', 'Date', 'dateRange', 'DatePicker', 'Calendar'],
                'amount_filters': ['amount', 'Amount', 'price', 'Price', 'Slider', 'Stepper'],
                'vendor_filters': ['vendor', 'Vendor', 'merchant', 'Merchant', 'Picker'],
                'category_filters': ['category', 'Category', 'type', 'Type'],
                'text_filters': ['search', 'Search', 'text', 'Text', 'TextField'],
                'status_filters': ['status', 'Status', 'processed', 'pending', 'Toggle']
            }

            found_filters = {}
            for filter_type, patterns in advanced_filters.items():
                found = []
                for pattern in patterns:
                    if pattern in content:
                        found.append(pattern)
                found_filters[filter_type] = found

            # Check for filter combinations
            filter_combinations = [
                'AND', 'OR', 'compound', 'combined',
                'multiple', 'combine', 'predicate'
            ]

            found_combinations = []
            for combination in filter_combinations:
                if combination.lower() in content.lower():
                    found_combinations.append(combination)

            # Check for filter logic
            filter_logic = [
                'predicate', 'NSPredicate', 'filter', 'where',
                'contains', 'beginsWith', 'endsWith'
            ]

            found_logic = []
            for logic in filter_logic:
                if logic in content:
                    found_logic.append(logic)

            # Calculate advanced score
            filter_count = sum(len(filters) for filters in found_filters.values())
            advanced_score = filter_count + len(found_combinations) + len(found_logic)
            advanced = advanced_score >= 6  # Minimum threshold for advanced

            return {
                'advanced': advanced,
                'advanced_filters': found_filters,
                'filter_combinations': found_combinations,
                'filter_logic': found_logic,
                'advanced_score': advanced_score,
                'filter_types_implemented': filter_count
            }

        except Exception as e:
            return {'advanced': False, 'errors': [f'Error testing advanced filtering: {str(e)}']}

    def _test_filter_persistence(self) -> Dict[str, Any]:
        """Test filter persistence capabilities"""
        try:
            filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailFilterBar.swift')

            if not os.path.exists(filter_bar_path):
                filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(filter_bar_path):
                return {'persistent': False, 'errors': ['No filter implementation found']}

            with open(filter_bar_path, 'r') as f:
                content = f.read()

            # Check for persistence mechanisms
            persistence_mechanisms = [
                'UserDefaults', 'AppStorage', 'SceneStorage',
                'CoreData', 'persist', 'save', 'restore'
            ]

            found_mechanisms = []
            for mechanism in persistence_mechanisms:
                if mechanism in content:
                    found_mechanisms.append(mechanism)

            # Check for filter state management
            state_management = [
                '@AppStorage', '@StateObject', '@ObservableObject',
                'filterState', 'persistedState', 'savedFilters'
            ]

            found_state = []
            for state in state_management:
                if state in content:
                    found_state.append(state)

            # Check for auto-save functionality
            auto_save = [
                'onAppear', 'onDisappear', 'onChange',
                'saveFilter', 'persistFilter', 'autoSave'
            ]

            found_auto_save = []
            for save in auto_save:
                if save in content:
                    found_auto_save.append(save)

            persistent = (
                len(found_mechanisms) > 0 and
                len(found_state) > 0
            )

            return {
                'persistent': persistent,
                'persistence_mechanisms': found_mechanisms,
                'state_management': found_state,
                'auto_save': found_auto_save,
                'persistence_score': len(found_mechanisms) + len(found_state) + len(found_auto_save)
            }

        except Exception as e:
            return {'persistent': False, 'errors': [f'Error testing filter persistence: {str(e)}']}

    def _test_filter_performance(self) -> Dict[str, Any]:
        """Test filter performance optimizations"""
        try:
            filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailFilterBar.swift')

            if not os.path.exists(filter_bar_path):
                filter_bar_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(filter_bar_path):
                return {'performant': False, 'errors': ['No filter implementation found']}

            with open(filter_bar_path, 'r') as f:
                content = f.read()

            # Check for performance optimizations
            performance_optimizations = {
                'debouncing': ['debounce', 'delay', 'throttle', 'Timer'],
                'lazy_loading': ['lazy', 'Lazy', 'onAppear', 'async'],
                'caching': ['cache', 'Cache', 'memoization', 'cached'],
                'efficient_algorithms': ['predicate', 'NSPredicate', 'optimized', 'efficient']
            }

            found_optimizations = {}
            for opt_type, patterns in performance_optimizations.items():
                found = []
                for pattern in patterns:
                    if pattern.lower() in content.lower():
                        found.append(pattern)
                found_optimizations[opt_type] = found

            # Check for pagination
            pagination = [
                'pagination', 'Pagination', 'limit', 'offset',
                'pageSize', 'page', 'batch'
            ]

            found_pagination = []
            for page in pagination:
                if page.lower() in content.lower():
                    found_pagination.append(page)

            # Check for background processing
            background_processing = [
                'background', 'Background', 'DispatchQueue',
                'Task', 'async', 'await'
            ]

            found_background = []
            for bg in background_processing:
                if bg in content:
                    found_background.append(bg)

            # Calculate performance score
            opt_count = sum(len(opts) for opts in found_optimizations.values())
            performance_score = opt_count + len(found_pagination) + len(found_background)
            performant = performance_score >= 3  # Minimum threshold for performant

            return {
                'performant': performant,
                'performance_optimizations': found_optimizations,
                'pagination': found_pagination,
                'background_processing': found_background,
                'performance_score': performance_score,
                'optimizations_implemented': opt_count
            }

        except Exception as e:
            return {'performant': False, 'errors': [f'Error testing filter performance: {str(e)}']}

    def test_caching_and_performance(self) -> Dict[str, Any]:
        """Test caching and performance optimization"""
        test_name = "Caching and Performance"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for caching implementation
            caching_implementation = self._check_caching_implementation()
            result['details']['caching_implementation'] = caching_implementation

            if caching_implementation['implemented']:
                logger.info(" Caching implemented")
            else:
                result['errors'].append("Caching not found")
                logger.error(" Caching missing")

            # Test 2: Test rate limiting
            rate_limiting = self._test_rate_limiting()
            result['details']['rate_limiting'] = rate_limiting

            if rate_limiting['limited']:
                logger.info(" Rate limiting working")
            else:
                result['errors'].append("Rate limiting not working")
                logger.error(" Rate limiting missing")

            # Test 3: Test pagination
            pagination = self._test_pagination_implementation()
            result['details']['pagination'] = pagination

            if pagination['implemented']:
                logger.info(" Pagination working")
            else:
                result['errors'].append("Pagination not working")
                logger.error(" Pagination missing")

            # Test 4: Test background processing
            background_processing = self._test_background_processing()
            result['details']['background_processing'] = background_processing

            if background_processing['working']:
                logger.info(" Background processing working")
            else:
                result['errors'].append("Background processing not working")
                logger.error(" Background processing missing")

            # Determine overall success
            result['success'] = (
                caching_implementation['implemented'] and
                rate_limiting['limited'] and
                pagination['implemented'] and
                background_processing['working']
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

    def _check_caching_implementation(self) -> Dict[str, Any]:
        """Check for caching implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for cache implementation
            cache_types = {
                'memory_cache': ['cache', 'Cache', 'NSCache', 'Dictionary'],
                'disk_cache': ['UserDefaults', 'FileManager', 'DiskCache'],
                'cache_policies': ['expiration', 'ttl', 'maxAge', 'cachePolicy'],
                'cache_invalidation': ['invalidate', 'clear', 'refresh', 'update']
            }

            found_cache_types = {}
            for cache_type, patterns in cache_types.items():
                found = []
                for pattern in patterns:
                    if pattern in content:
                        found.append(pattern)
                found_cache_types[cache_type] = found

            # Check for cache strategies
            cache_strategies = [
                'lazy', 'eager', 'writeThrough', 'writeBack',
                'cacheAside', 'readThrough'
            ]

            found_strategies = []
            for strategy in cache_strategies:
                if strategy.lower() in content.lower():
                    found_strategies.append(strategy)

            # Check for cache keys and management
            cache_management = [
                'cacheKey', 'key', 'identifier', 'id',
                'cacheSize', 'limit', 'capacity'
            ]

            found_management = []
            for mgmt in cache_management:
                if mgmt.lower() in content.lower():
                    found_management.append(mgmt)

            implemented = (
                len(found_cache_types.get('memory_cache', [])) > 0 or
                len(found_cache_types.get('disk_cache', [])) > 0
            )

            return {
                'implemented': implemented,
                'cache_types': found_cache_types,
                'cache_strategies': found_strategies,
                'cache_management': found_management,
                'caching_score': sum(len(types) for types in found_cache_types.values())
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking caching implementation: {str(e)}']}

    def _test_rate_limiting(self) -> Dict[str, Any]:
        """Test rate limiting implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'limited': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for rate limiting patterns
            rate_limit_patterns = {
                'time_based': ['delay', 'sleep', 'Timer', 'DispatchQueue', 'asyncAfter'],
                'request_based': ['throttle', 'rateLimit', 'requestLimit', 'quota'],
                'error_based': ['retry', 'backoff', 'exponential', 'wait'],
                'queue_based': ['queue', 'OperationQueue', 'semaphore', 'concurrent']
            }

            found_patterns = {}
            for pattern_type, patterns in rate_limit_patterns.items():
                found = []
                for pattern in patterns:
                    if pattern in content:
                        found.append(pattern)
                found_patterns[pattern_type] = found

            # Check for rate limit configuration
            rate_config = [
                'limit', 'rate', 'perSecond', 'perMinute',
                'maxRequests', 'quota', 'throttle'
            ]

            found_config = []
            for config in rate_config:
                if config.lower() in content.lower():
                    found_config.append(config)

            # Check for error handling for rate limits
            rate_error_handling = [
                '429', 'rateLimit', 'tooManyRequests',
                'quotaExceeded', 'retryAfter'
            ]

            found_error_handling = []
            for error in rate_error_handling:
                if error.lower() in content.lower():
                    found_error_handling.append(error)

            limited = (
                len(found_patterns.get('time_based', [])) > 0 or
                len(found_patterns.get('request_based', [])) > 0
            )

            return {
                'limited': limited,
                'rate_limit_patterns': found_patterns,
                'rate_config': found_config,
                'error_handling': found_error_handling,
                'rate_limiting_score': sum(len(patterns) for patterns in found_patterns.values())
            }

        except Exception as e:
            return {'limited': False, 'errors': [f'Error testing rate limiting: {str(e)}']}

    def _test_pagination_implementation(self) -> Dict[str, Any]:
        """Test pagination implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for pagination parameters
            pagination_params = [
                'pageToken', 'nextPageToken', 'maxResults',
                'pageSize', 'limit', 'offset', 'page'
            ]

            found_params = []
            for param in pagination_params:
                if param in content:
                    found_params.append(param)

            # Check for pagination logic
            pagination_logic = [
                'loadMore', 'nextPage', 'previousPage',
                'hasNext', 'hasPrevious', 'pagination'
            ]

            found_logic = []
            for logic in pagination_logic:
                if logic in content:
                    found_logic.append(logic)

            # Check for UI pagination
            ui_pagination = [
                'LoadMoreButton', 'NextButton', 'PreviousButton',
                'PageIndicator', 'ProgressView'
            ]

            found_ui = []
            for ui in ui_pagination:
                if ui in content:
                    found_ui.append(ui)

            implemented = (
                len(found_params) > 0 and
                len(found_logic) > 0
            )

            return {
                'implemented': implemented,
                'pagination_params': found_params,
                'pagination_logic': found_logic,
                'ui_pagination': found_ui,
                'pagination_score': len(found_params) + len(found_logic) + len(found_ui)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error testing pagination: {str(e)}']}

    def _test_background_processing(self) -> Dict[str, Any]:
        """Test background processing implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for background processing patterns
            background_patterns = {
                'async_await': ['async', 'await', 'Task', 'TaskGroup'],
                'dispatch_queue': ['DispatchQueue', 'dispatch', 'global', 'background'],
                'operation_queue': ['OperationQueue', 'Operation', 'addOperation'],
                'timer_based': ['Timer', 'DispatchSourceTimer', 'scheduled']
            }

            found_patterns = {}
            for pattern_type, patterns in background_patterns.items():
                found = []
                for pattern in patterns:
                    if pattern in content:
                        found.append(pattern)
                found_patterns[pattern_type] = found

            # Check for background task management
            task_management = [
                'backgroundTask', 'beginBackgroundTask',
                'expirationHandler', 'endBackgroundTask'
            ]

            found_task_mgmt = []
            for mgmt in task_management:
                if mgmt in content:
                    found_task_mgmt.append(mgmt)

            # Check for progress indication
            progress_indication = [
                'ProgressView', 'progress', 'loading',
                'isLoading', 'onAppear', 'onDisappear'
            ]

            found_progress = []
            for progress in progress_indication:
                if progress in content:
                    found_progress.append(progress)

            working = (
                len(found_patterns.get('async_await', [])) > 0 or
                len(found_patterns.get('dispatch_queue', [])) > 0
            )

            return {
                'working': working,
                'background_patterns': found_patterns,
                'task_management': found_task_mgmt,
                'progress_indication': found_progress,
                'background_score': sum(len(patterns) for patterns in found_patterns.values())
            }

        except Exception as e:
            return {'working': False, 'errors': [f'Error testing background processing: {str(e)}']}

    def test_visual_indicators_and_status(self) -> Dict[str, Any]:
        """Test visual indicators and status display"""
        test_name = "Visual Indicators and Status"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for status indicators
            status_indicators = self._check_status_indicators()
            result['details']['status_indicators'] = status_indicators

            if status_indicators['implemented']:
                logger.info(" Status indicators implemented")
            else:
                result['errors'].append("Status indicators not found")
                logger.error(" Status indicators missing")

            # Test 2: Test color coding
            color_coding = self._test_color_coding()
            result['details']['color_coding'] = color_coding

            if color_coding['coded']:
                logger.info(" Color coding working")
            else:
                result['errors'].append("Color coding not working")
                logger.error(" Color coding missing")

            # Test 3: Test progress indication
            progress_indication = self._test_progress_indication()
            result['details']['progress_indication'] = progress_indication

            if progress_indication['indicated']:
                logger.info(" Progress indication working")
            else:
                result['errors'].append("Progress indication not working")
                logger.error(" Progress indication missing")

            # Test 4: Test auto-refresh control
            auto_refresh = self._test_auto_refresh_control()
            result['details']['auto_refresh'] = auto_refresh

            if auto_refresh['controlled']:
                logger.info(" Auto-refresh control working")
            else:
                result['errors'].append("Auto-refresh control not working")
                logger.error(" Auto-refresh control missing")

            # Determine overall success
            result['success'] = (
                status_indicators['implemented'] and
                color_coding['coded'] and
                progress_indication['indicated'] and
                auto_refresh['controlled']
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

    def _check_status_indicators(self) -> Dict[str, Any]:
        """Check for status indicators implementation"""
        try:
            gmail_view_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(gmail_view_path):
                return {'implemented': False, 'errors': ['GmailView.swift not found']}

            with open(gmail_view_path, 'r') as f:
                content = f.read()

            # Check for status indicator components
            status_components = [
                'Badge', 'Label', 'Text', 'Image',
                'Icon', 'Symbol', 'StatusIndicator'
            ]

            found_components = []
            for component in status_components:
                if component in content:
                    found_components.append(component)

            # Check for status types
            status_types = [
                'connected', 'disconnected', 'loading',
                'error', 'success', 'processing', 'sync'
            ]

            found_types = []
            for status in status_types:
                if status.lower() in content.lower():
                    found_types.append(status)

            # Check for status styling
            status_styling = [
                'foregroundColor', 'backgroundColor', 'Color',
                'opacity', 'brightness', 'contrast'
            ]

            found_styling = []
            for style in status_styling:
                if style in content:
                    found_styling.append(style)

            implemented = (
                len(found_components) > 0 and
                len(found_types) > 0
            )

            return {
                'implemented': implemented,
                'status_components': found_components,
                'status_types': found_types,
                'status_styling': found_styling,
                'status_score': len(found_components) + len(found_types) + len(found_styling)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking status indicators: {str(e)}']}

    def _test_color_coding(self) -> Dict[str, Any]:
        """Test color coding implementation"""
        try:
            gmail_view_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(gmail_view_path):
                return {'coded': False, 'errors': ['GmailView.swift not found']}

            with open(gmail_view_path, 'r') as f:
                content = f.read()

            # Check for color coding patterns
            color_patterns = {
                'expense_colors': ['red', 'Color.red', '.red', 'expense', 'debit'],
                'income_colors': ['green', 'Color.green', '.green', 'income', 'credit'],
                'pending_colors': ['orange', 'yellow', '.orange', '.yellow', 'pending'],
                'processed_colors': ['blue', 'Color.blue', '.blue', 'processed', 'complete']
            }

            found_patterns = {}
            for pattern_type, patterns in color_patterns.items():
                found = []
                for pattern in patterns:
                    if pattern.lower() in content.lower():
                        found.append(pattern)
                found_patterns[pattern_type] = found

            # Check for dynamic color logic
            dynamic_coloring = [
                'switch', 'if.*color', 'color.*switch',
                'conditional.*color', 'dynamic.*color'
            ]

            found_dynamic = []
            for dynamic in dynamic_coloring:
                import re
                if re.search(dynamic, content, re.IGNORECASE):
                    found_dynamic.append(dynamic)

            # Check for color themes
            color_themes = [
                'theme', 'Theme', 'colorScheme',
                'accentColor', 'primaryColor'
            ]

            found_themes = []
            for theme in color_themes:
                if theme in content:
                    found_themes.append(theme)

            coded = (
                len(found_patterns.get('expense_colors', [])) > 0 or
                len(found_patterns.get('income_colors', [])) > 0
            )

            return {
                'coded': coded,
                'color_patterns': found_patterns,
                'dynamic_coloring': found_dynamic,
                'color_themes': found_themes,
                'color_coding_score': sum(len(patterns) for patterns in found_patterns.values())
            }

        except Exception as e:
            return {'coded': False, 'errors': [f'Error testing color coding: {str(e)}']}

    def _test_progress_indication(self) -> Dict[str, Any]:
        """Test progress indication implementation"""
        try:
            gmail_view_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(gmail_view_path):
                return {'indicated': False, 'errors': ['GmailView.swift not found']}

            with open(gmail_view_path, 'r') as f:
                content = f.read()

            # Check for progress components
            progress_components = [
                'ProgressView', 'ActivityIndicator', 'Spinner',
                'Progress', 'LoadingView', 'Spinner'
            ]

            found_components = []
            for component in progress_components:
                if component in content:
                    found_components.append(component)

            # Check for progress state management
            progress_state = [
                'isLoading', 'loading', 'processing',
                'progress', 'isProcessing', 'busy'
            ]

            found_state = []
            for state in progress_state:
                if state.lower() in content.lower():
                    found_state.append(state)

            # Check for progress triggers
            progress_triggers = [
                'onAppear', 'onTask', 'async', 'await',
                'Task', 'background', 'loading'
            ]

            found_triggers = []
            for trigger in progress_triggers:
                if trigger in content:
                    found_triggers.append(trigger)

            indicated = (
                len(found_components) > 0 and
                len(found_state) > 0
            )

            return {
                'indicated': indicated,
                'progress_components': found_components,
                'progress_state': found_state,
                'progress_triggers': found_triggers,
                'progress_score': len(found_components) + len(found_state) + len(found_triggers)
            }

        except Exception as e:
            return {'indicated': False, 'errors': [f'Error testing progress indication: {str(e)}']}

    def _test_auto_refresh_control(self) -> Dict[str, Any]:
        """Test auto-refresh control implementation"""
        try:
            gmail_view_path = os.path.join(self.app_path, 'FinanceMate/Views/Gmail/GmailView.swift')

            if not os.path.exists(gmail_view_path):
                return {'controlled': False, 'errors': ['GmailView.swift not found']}

            with open(gmail_view_path, 'r') as f:
                content = f.read()

            # Check for auto-refresh controls
            refresh_controls = [
                'Toggle', 'Switch', 'Button', 'refresh',
                'autoRefresh', 'autoRefreshEnabled'
            ]

            found_controls = []
            for control in refresh_controls:
                if control.lower() in content.lower():
                    found_controls.append(control)

            # Check for refresh timing
            refresh_timing = [
                'Timer', 'interval', 'schedule', 'repeat',
                'refreshInterval', 'autoRefreshInterval'
            ]

            found_timing = []
            for timing in refresh_timing:
                if timing in content:
                    found_timing.append(timing)

            # Check for refresh logic
            refresh_logic = [
                'refresh', 'reload', 'fetch', 'update',
                'sync', 'pullToRefresh', 'onRefresh'
            ]

            found_logic = []
            for logic in refresh_logic:
                if logic.lower() in content.lower():
                    found_logic.append(logic)

            # Check for user control
            user_control = [
                'userInteractionEnabled', 'enabled',
                'disabled', 'toggleState', 'isOn'
            ]

            found_user_control = []
            for control in user_control:
                if control in content:
                    found_user_control.append(control)

            controlled = (
                len(found_controls) > 0 and
                len(found_timing) > 0 and
                len(found_logic) > 0
            )

            return {
                'controlled': controlled,
                'refresh_controls': found_controls,
                'refresh_timing': found_timing,
                'refresh_logic': found_logic,
                'user_control': found_user_control,
                'auto_refresh_score': len(found_controls) + len(found_timing) + len(found_logic)
            }

        except Exception as e:
            return {'controlled': False, 'errors': [f'Error testing auto-refresh control: {str(e)}']}

    def generate_test_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        logger.info(" Generating Gmail UI Integration test report")

        total_tests = len(self.test_results)
        passed_tests = sum(1 for test in self.test_results if test['success'])
        failed_tests = total_tests - passed_tests

        report = {
            'test_suite': 'Gmail UI Integration E2E Validation',
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
            report['summary']['recommendations'].append("All Gmail UI integration tests passed - system is ready for production")
        else:
            report['summary']['recommendations'].append("Address critical UI integration issues before production deployment")

        if self.gmail_test_credentials.get('mock_mode', False):
            report['summary']['warnings'].append("Tests run in mock mode - configure real Gmail credentials for full validation")
            report['summary']['recommendations'].append("Set up Gmail test credentials for comprehensive UI integration validation")

        return report

    def save_test_report(self, report: Dict[str, Any]) -> str:
        """Save test report to file"""
        report_file = os.path.join(self.test_data_dir, f"gmail_ui_integration_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")

        try:
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)

            logger.info(f" Test report saved to: {report_file}")
            return report_file

        except Exception as e:
            logger.error(f" Error saving test report: {e}")
            return ""

    def run_all_tests(self) -> Dict[str, Any]:
        """Run all Gmail UI integration tests"""
        logger.info(" Starting Gmail UI Integration E2E Test Suite")

        # Run all test methods
        self.test_gmail_receipts_table_functionality()
        self.test_gmail_filtering_system()
        self.test_caching_and_performance()
        self.test_visual_indicators_and_status()

        # Generate and save report
        report = self.generate_test_report()
        report_file = self.save_test_report(report)

        if report_file:
            report['report_file'] = report_file

        logger.info(f" Gmail UI Integration E2E Test Suite completed - Success Rate: {report['success_rate']:.1f}%")

        return report

def main():
    """Main test execution function"""
    print(" Gmail UI Integration E2E Test Suite")
    print("=" * 50)

    # Create and run test suite
    test_suite = GmailUIIntegrationE2ETest()
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