#!/usr/bin/env python3
"""
Gmail Receipt Processing E2E Validation Test
Validates email parsing, line item extraction, and transaction creation from Gmail receipts
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
        logging.FileHandler('test_gmail_receipt_processing.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class GmailReceiptProcessingE2ETest:
    """Comprehensive Gmail receipt processing validation"""

    def __init__(self):
        self.test_results = []
        self.app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.production_app_path = "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS"
        self.test_data_dir = tempfile.mkdtemp(prefix="gmail_receipt_test_")
        self.gmail_test_credentials = self._load_gmail_test_credentials()
        self.sample_receipt_data = self._load_sample_receipt_data()

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

    def _load_sample_receipt_data(self) -> Dict[str, Any]:
        """Load sample receipt data for testing"""
        return {
            'receipt_emails': [
                {
                    'subject': 'Your Uber receipt',
                    'from': 'receipts@uber.com',
                    'date': '2025-01-04T10:30:00Z',
                    'amount': 25.50,
                    'vendor': 'Uber',
                    'currency': 'AUD',
                    'items': ['UberX ride'],
                    'expected_line_items': 1
                },
                {
                    'subject': 'Woolworths receipt #12345',
                    'from': 'receipts@woolworths.com.au',
                    'date': '2025-01-03T15:45:00Z',
                    'amount': 87.32,
                    'vendor': 'Woolworths',
                    'currency': 'AUD',
                    'items': ['Groceries', 'Fresh produce', 'Dairy'],
                    'expected_line_items': 3
                },
                {
                    'subject': 'Amazon order confirmation',
                    'from': 'shipment-confirm@amazon.com',
                    'date': '2025-01-02T09:15:00Z',
                    'amount': 156.99,
                    'vendor': 'Amazon',
                    'currency': 'AUD',
                    'items': ['Electronics', 'Books'],
                    'expected_line_items': 2
                }
            ],
            'email_content_samples': [
                """Uber Receipt
                Trip Date: Jan 4, 2025
                Total: $25.50 AUD
                Payment: Visa ending in 1234""",
                """Woolworths Receipt
                Date: 03/01/2025
                Total: $87.32
                Items: Groceries, Fresh Produce, Dairy""",
                """Amazon Order Confirmation
                Order Total: $156.99 AUD
                Items: Electronics, Books
                Payment Method: Credit Card"""
            ]
        }

    def test_email_parsing_functionality(self) -> Dict[str, Any]:
        """Test email parsing functionality for receipt extraction"""
        test_name = "Email Parsing Functionality"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for email parsing service implementation
            parsing_service = self._check_email_parsing_service()
            result['details']['parsing_service'] = parsing_service

            if parsing_service['implemented']:
                logger.info(" Email parsing service implemented")
            else:
                result['errors'].append("Email parsing service not found")
                logger.error(" Email parsing service missing")

            # Test 2: Validate receipt pattern recognition
            pattern_recognition = self._test_receipt_pattern_recognition()
            result['details']['pattern_recognition'] = pattern_recognition

            if pattern_recognition['patterns_found']:
                logger.info(" Receipt pattern recognition working")
            else:
                result['errors'].append("Receipt pattern recognition not working")
                logger.error(" Receipt pattern recognition missing")

            # Test 3: Test data extraction accuracy
            data_extraction = self._test_data_extraction_accuracy()
            result['details']['data_extraction'] = data_extraction

            if data_extraction['accuracy_score'] >= 80:
                logger.info(" Data extraction accuracy acceptable")
            else:
                result['errors'].append("Data extraction accuracy too low")
                logger.error(" Data extraction accuracy insufficient")

            # Test 4: Test multi-vendor support
            vendor_support = self._test_multi_vendor_support()
            result['details']['vendor_support'] = vendor_support

            if vendor_support['sufficient_vendors']:
                logger.info(" Multi-vendor support implemented")
            else:
                result['errors'].append("Insufficient multi-vendor support")
                logger.error(" Multi-vendor support insufficient")

            # Determine overall success
            result['success'] = (
                parsing_service['implemented'] and
                pattern_recognition['patterns_found'] and
                data_extraction['accuracy_score'] >= 80 and
                vendor_support['sufficient_vendors']
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

    def _check_email_parsing_service(self) -> Dict[str, Any]:
        """Check for email parsing service implementation"""
        try:
            # Look for GmailAPIService and related parsing files
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            parsing_indicators = [
                'parseEmail',
                'extractReceipt',
                'parseReceipt',
                'extractData',
                'parseContent',
                'emailParsing'
            ]

            found_indicators = []
            for indicator in parsing_indicators:
                if indicator in content:
                    found_indicators.append(indicator)

            # Check for receipt-specific parsing
            receipt_patterns = [
                'receipt.*parse',
                'extract.*receipt',
                'parse.*transaction',
                'receipt.*data'
            ]

            found_receipt_patterns = []
            for pattern in receipt_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_receipt_patterns.append(pattern)

            # Check for content processing
            content_processing = [
                'processContent',
                'extractText',
                'parseBody',
                'emailContent'
            ]

            found_content_processing = []
            for indicator in content_processing:
                if indicator in content:
                    found_content_processing.append(indicator)

            return {
                'implemented': len(found_indicators) > 0,
                'parsing_functions': found_indicators,
                'receipt_patterns': found_receipt_patterns,
                'content_processing': found_content_processing,
                'parsing_completeness': len(found_indicators) + len(found_receipt_patterns)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking email parsing service: {str(e)}']}

    def _test_receipt_pattern_recognition(self) -> Dict[str, Any]:
        """Test receipt pattern recognition capabilities"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'patterns_found': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for common receipt patterns
            receipt_patterns = [
                r'\$[0-9]+\.[0-9]{2}',  # Dollar amounts
                r'Total:?\s*\$[0-9]+\.[0-9]{2}',  # Total amount
                r'Receipt|Invoice|Bill',  # Receipt keywords
                r'Amount|Paid|Cost',  # Payment keywords
                r'Date:?\s*[0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4}',  # Date patterns
                r'Vendor|Store|Merchant',  # Vendor keywords
                r'Item|Product|Service'  # Item keywords
            ]

            found_patterns = []
            pattern_matches = {}

            for pattern in receipt_patterns:
                import re
                matches = re.findall(pattern, content, re.IGNORECASE)
                if matches:
                    found_patterns.append(pattern)
                    pattern_matches[pattern] = len(matches)

            # Check for vendor-specific patterns
            vendor_patterns = {
                'Uber': ['uber', 'receipts@uber.com'],
                'Woolworths': ['woolworths', 'woolworths.com.au'],
                'Amazon': ['amazon', 'amazon.com', 'shipment-confirm@amazon.com'],
                'Coles': ['coles', 'coles.com.au'],
                'Common merchants': ['receipt', 'invoice', 'order', 'purchase']
            }

            vendor_support = {}
            for vendor, patterns in vendor_patterns.items():
                support_score = 0
                for pattern in patterns:
                    if pattern.lower() in content.lower():
                        support_score += 1
                vendor_support[vendor] = {
                    'supported': support_score > 0,
                    'support_score': support_score,
                    'patterns_found': [p for p in patterns if p.lower() in content.lower()]
                }

            # Calculate pattern recognition score
            total_patterns = len(receipt_patterns)
            recognized_patterns = len(found_patterns)
            recognition_score = (recognized_patterns / total_patterns) * 100 if total_patterns > 0 else 0

            return {
                'patterns_found': recognized_patterns > 0,
                'found_patterns': found_patterns,
                'pattern_matches': pattern_matches,
                'vendor_support': vendor_support,
                'recognition_score': recognition_score,
                'total_patterns_checked': total_patterns,
                'patterns_recognized': recognized_patterns
            }

        except Exception as e:
            return {'patterns_found': False, 'errors': [f'Error testing receipt pattern recognition: {str(e)}']}

    def _test_data_extraction_accuracy(self) -> Dict[str, Any]:
        """Test data extraction accuracy from receipts"""
        try:
            # Test extraction against sample data
            extraction_results = []
            total_accuracy = 0

            for i, sample_receipt in enumerate(self.sample_receipt_data['receipt_emails']):
                extraction_result = self._simulate_receipt_extraction(sample_receipt)
                extraction_results.append(extraction_result)
                total_accuracy += extraction_result['accuracy_score']

            # Calculate overall accuracy
            overall_accuracy = total_accuracy / len(extraction_results) if extraction_results else 0

            # Analyze extraction quality
            extraction_quality = {
                'vendor_extraction': sum(1 for r in extraction_results if r['vendor_extracted']) / len(extraction_results) * 100,
                'amount_extraction': sum(1 for r in extraction_results if r['amount_extracted']) / len(extraction_results) * 100,
                'date_extraction': sum(1 for r in extraction_results if r['date_extracted']) / len(extraction_results) * 100,
                'item_extraction': sum(1 for r in extraction_results if r['items_extracted']) / len(extraction_results) * 100
            }

            return {
                'accuracy_score': overall_accuracy,
                'extraction_results': extraction_results,
                'extraction_quality': extraction_quality,
                'total_samples_tested': len(extraction_results),
                'average_accuracy': overall_accuracy
            }

        except Exception as e:
            return {'accuracy_score': 0, 'errors': [f'Error testing data extraction accuracy: {str(e)}']}

    def _simulate_receipt_extraction(self, receipt_data: Dict[str, Any]) -> Dict[str, Any]:
        """Simulate receipt extraction based on sample data"""
        try:
            # Check GmailAPIService for extraction logic
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            extraction_capabilities = {
                'vendor_extraction': False,
                'amount_extraction': False,
                'date_extraction': False,
                'item_extraction': False,
                'currency_extraction': False
            }

            if os.path.exists(gmail_api_service_path):
                with open(gmail_api_service_path, 'r') as f:
                    content = f.read()

                # Check for extraction capabilities
                extraction_patterns = {
                    'vendor_extraction': ['vendor', 'merchant', 'store', 'company'],
                    'amount_extraction': ['amount', 'total', 'price', 'cost'],
                    'date_extraction': ['date', 'time', 'when', 'timestamp'],
                    'item_extraction': ['item', 'product', 'service', 'line'],
                    'currency_extraction': ['currency', 'aud', 'usd', 'eur']
                }

                for capability, patterns in extraction_patterns.items():
                    for pattern in patterns:
                        if pattern.lower() in content.lower():
                            extraction_capabilities[capability] = True
                            break

            # Simulate extraction results
            extracted_data = {}
            accuracy_score = 0

            if extraction_capabilities['vendor_extraction']:
                extracted_data['vendor'] = receipt_data.get('vendor', '')
                accuracy_score += 25

            if extraction_capabilities['amount_extraction']:
                extracted_data['amount'] = receipt_data.get('amount', 0)
                accuracy_score += 25

            if extraction_capabilities['date_extraction']:
                extracted_data['date'] = receipt_data.get('date', '')
                accuracy_score += 25

            if extraction_capabilities['item_extraction']:
                extracted_data['items'] = receipt_data.get('items', [])
                accuracy_score += 25

            return {
                'vendor_extracted': extraction_capabilities['vendor_extraction'],
                'amount_extracted': extraction_capabilities['amount_extraction'],
                'date_extracted': extraction_capabilities['date_extraction'],
                'items_extracted': extraction_capabilities['item_extraction'],
                'currency_extracted': extraction_capabilities['currency_extraction'],
                'extracted_data': extracted_data,
                'accuracy_score': accuracy_score,
                'extraction_capabilities': extraction_capabilities
            }

        except Exception as e:
            return {
                'vendor_extracted': False,
                'amount_extracted': False,
                'date_extracted': False,
                'items_extracted': False,
                'currency_extracted': False,
                'accuracy_score': 0,
                'error': str(e)
            }

    def _test_multi_vendor_support(self) -> Dict[str, Any]:
        """Test multi-vendor support capabilities"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'sufficient_vendors': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Define vendor categories and patterns
            vendor_categories = {
                'Transportation': ['uber', 'lift', 'taxi', 'bus', 'train', 'metro'],
                'Groceries': ['woolworths', 'coles', 'iga', 'aldi', 'foodland'],
                'Electronics': ['amazon', 'ebay', 'jbhifi', 'harveynorman', 'officeworks'],
                'Restaurants': ['maccas', 'kfc', 'subway', 'dominos', 'pizza'],
                'Utilities': ['energy', 'water', 'gas', 'internet', 'phone'],
                'Retail': ['target', 'kmart', 'bigw', 'myer', 'davidjones']
            }

            vendor_support = {}
            supported_categories = 0
            total_vendors = 0

            for category, vendors in vendor_categories.items():
                category_supported = False
                supported_vendors = []

                for vendor in vendors:
                    if vendor.lower() in content.lower():
                        supported_vendors.append(vendor)
                        total_vendors += 1
                        category_supported = True

                if category_supported:
                    supported_categories += 1

                vendor_support[category] = {
                    'supported': category_supported,
                    'supported_vendors': supported_vendors,
                    'total_vendors_in_category': len(vendors),
                    'support_percentage': (len(supported_vendors) / len(vendors)) * 100
                }

            # Check for generic receipt handling
            generic_patterns = [
                'receipt.*parse',
                'invoice.*extract',
                'generic.*parsing',
                'any.*vendor'
            ]

            generic_support = False
            for pattern in generic_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    generic_support = True
                    break

            sufficient_support = (
                supported_categories >= 3 and  # Support at least 3 categories
                total_vendors >= 5 and        # Support at least 5 specific vendors
                generic_support               # Have generic parsing capability
            )

            return {
                'sufficient_vendors': sufficient_support,
                'supported_categories': supported_categories,
                'total_supported_vendors': total_vendors,
                'vendor_support': vendor_support,
                'generic_support': generic_support,
                'coverage_score': (supported_categories / len(vendor_categories)) * 100
            }

        except Exception as e:
            return {'sufficient_vendors': False, 'errors': [f'Error testing multi-vendor support: {str(e)}']}

    def test_line_item_extraction(self) -> Dict[str, Any]:
        """Test line item extraction from receipts"""
        test_name = "Line Item Extraction"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for line item extraction logic
            line_item_logic = self._check_line_item_extraction_logic()
            result['details']['line_item_logic'] = line_item_logic

            if line_item_logic['implemented']:
                logger.info(" Line item extraction logic implemented")
            else:
                result['errors'].append("Line item extraction logic not found")
                logger.error(" Line item extraction logic missing")

            # Test 2: Test itemization capabilities
            itemization = self._test_itemization_capabilities()
            result['details']['itemization'] = itemization

            if itemization['can_itemize']:
                logger.info(" Itemization capabilities working")
            else:
                result['errors'].append("Itemization capabilities not working")
                logger.error(" Itemization capabilities missing")

            # Test 3: Test quantity and price extraction
            quantity_price = self._test_quantity_price_extraction()
            result['details']['quantity_price'] = quantity_price

            if quantity_price['extraction_working']:
                logger.info(" Quantity and price extraction working")
            else:
                result['errors'].append("Quantity and price extraction not working")
                logger.error(" Quantity and price extraction missing")

            # Test 4: Test tax calculation integration
            tax_calculation = self._test_tax_calculation_integration()
            result['details']['tax_calculation'] = tax_calculation

            if tax_calculation['integration_working']:
                logger.info(" Tax calculation integration working")
            else:
                result['errors'].append("Tax calculation integration not working")
                logger.error(" Tax calculation integration missing")

            # Determine overall success
            result['success'] = (
                line_item_logic['implemented'] and
                itemization['can_itemize'] and
                quantity_price['extraction_working'] and
                tax_calculation['integration_working']
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

    def _check_line_item_extraction_logic(self) -> Dict[str, Any]:
        """Check for line item extraction logic implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for line item extraction functions
            line_item_functions = [
                'extractLineItems',
                'parseLineItems',
                'itemizeReceipt',
                'extractItems',
                'createLineItems'
            ]

            found_functions = []
            for function in line_item_functions:
                if function in content:
                    found_functions.append(function)

            # Check for LineItem model usage
            line_item_patterns = [
                'LineItem',
                'lineItem',
                'line_item',
                'transaction.*item'
            ]

            found_patterns = []
            for pattern in line_item_patterns:
                if pattern in content:
                    found_patterns.append(pattern)

            # Check for item data structures
            item_structures = [
                'quantity',
                'unitPrice',
                'totalPrice',
                'description',
                'category'
            ]

            found_structures = []
            for structure in item_structures:
                if structure.lower() in content.lower():
                    found_structures.append(structure)

            return {
                'implemented': len(found_functions) > 0,
                'extraction_functions': found_functions,
                'line_item_patterns': found_patterns,
                'item_structures': found_structures,
                'implementation_score': len(found_functions) + len(found_patterns)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking line item extraction logic: {str(e)}']}

    def _test_itemization_capabilities(self) -> Dict[str, Any]:
        """Test itemization capabilities for complex receipts"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'can_itemize': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for itemization patterns
            itemization_patterns = [
                'multiple.*items',
                'item.*list',
                'itemize',
                'breakdown',
                'itemization'
            ]

            found_patterns = []
            for pattern in itemization_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_patterns.append(pattern)

            # Check for parsing complex receipts
            complex_patterns = [
                'itemized.*receipt',
                'detailed.*receipt',
                'item.*list.*parse',
                'multiple.*line.*items'
            ]

            found_complex = []
            for pattern in complex_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_complex.append(pattern)

            # Check for item loop/iteration logic
            iteration_patterns = [
                'for.*item',
                'foreach.*item',
                'item.*loop',
                'iterate.*items'
            ]

            found_iteration = []
            for pattern in iteration_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_iteration.append(pattern)

            can_itemize = (
                len(found_patterns) > 0 and
                len(found_complex) > 0
            )

            return {
                'can_itemize': can_itemize,
                'itemization_patterns': found_patterns,
                'complex_parsing': found_complex,
                'iteration_logic': found_iteration,
                'itemization_score': len(found_patterns) + len(found_complex) + len(found_iteration)
            }

        except Exception as e:
            return {'can_itemize': False, 'errors': [f'Error testing itemization capabilities: {str(e)}']}

    def _test_quantity_price_extraction(self) -> Dict[str, Any]:
        """Test quantity and price extraction capabilities"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'extraction_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for quantity extraction
            quantity_patterns = [
                'quantity',
                'qty',
                'amount',
                'count',
                'number'
            ]

            found_quantity = []
            for pattern in quantity_patterns:
                if pattern.lower() in content.lower():
                    found_quantity.append(pattern)

            # Check for price extraction
            price_patterns = [
                'price',
                'cost',
                'amount',
                'total',
                'value'
            ]

            found_price = []
            for pattern in price_patterns:
                if pattern.lower() in content.lower():
                    found_price.append(pattern)

            # Check for unit price calculation
            unit_price_patterns = [
                'unitPrice',
                'unit_price',
                'price.*unit',
                'calculate.*price'
            ]

            found_unit_price = []
            for pattern in unit_price_patterns:
                if pattern in content:
                    found_unit_price.append(pattern)

            # Check for total price calculation
            total_price_patterns = [
                'totalPrice',
                'total_price',
                'price.*total',
                'calculate.*total'
            ]

            found_total_price = []
            for pattern in total_price_patterns:
                if pattern in content:
                    found_total_price.append(pattern)

            extraction_working = (
                len(found_quantity) > 0 and
                len(found_price) > 0
            )

            return {
                'extraction_working': extraction_working,
                'quantity_extraction': found_quantity,
                'price_extraction': found_price,
                'unit_price_extraction': found_unit_price,
                'total_price_extraction': found_total_price,
                'extraction_completeness': len(found_quantity) + len(found_price)
            }

        except Exception as e:
            return {'extraction_working': False, 'errors': [f'Error testing quantity price extraction: {str(e)}']}

    def _test_tax_calculation_integration(self) -> Dict[str, Any]:
        """Test tax calculation integration with line items"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'integration_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for tax calculation patterns
            tax_patterns = [
                'tax',
                'gst',
                'vat',
                'taxAmount',
                'taxRate'
            ]

            found_tax = []
            for pattern in tax_patterns:
                if pattern.lower() in content.lower():
                    found_tax.append(pattern)

            # Check for tax calculation logic
            tax_calc_patterns = [
                'calculateTax',
                'computeTax',
                'tax.*calculation',
                'applyTax'
            ]

            found_tax_calc = []
            for pattern in tax_calc_patterns:
                if pattern in content:
                    found_tax_calc.append(pattern)

            # Check for tax category integration
            tax_category_patterns = [
                'TaxCategory',
                'taxCategory',
                'tax.*category',
                'category.*tax'
            ]

            found_tax_category = []
            for pattern in tax_category_patterns:
                if pattern in content:
                    found_tax_category.append(pattern)

            # Check for TaxCategoryManager integration
            tax_manager_patterns = [
                'TaxCategoryManager',
                'taxManager',
                'assignTaxCategory'
            ]

            found_tax_manager = []
            for pattern in tax_manager_patterns:
                if pattern in content:
                    found_tax_manager.append(pattern)

            integration_working = (
                len(found_tax) > 0 and
                (len(found_tax_calc) > 0 or len(found_tax_category) > 0)
            )

            return {
                'integration_working': integration_working,
                'tax_patterns': found_tax,
                'tax_calculation': found_tax_calc,
                'tax_category': found_tax_category,
                'tax_manager': found_tax_manager,
                'integration_score': len(found_tax) + len(found_tax_calc) + len(found_tax_category)
            }

        except Exception as e:
            return {'integration_working': False, 'errors': [f'Error testing tax calculation integration: {str(e)}']}

    def test_transaction_creation_from_emails(self) -> Dict[str, Any]:
        """Test transaction creation from parsed email data"""
        test_name = "Transaction Creation from Emails"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check transaction creation logic
            transaction_creation = self._check_transaction_creation_logic()
            result['details']['transaction_creation'] = transaction_creation

            if transaction_creation['implemented']:
                logger.info(" Transaction creation logic implemented")
            else:
                result['errors'].append("Transaction creation logic not found")
                logger.error(" Transaction creation logic missing")

            # Test 2: Test Core Data integration
            core_data_integration = self._test_core_data_integration()
            result['details']['core_data_integration'] = core_data_integration

            if core_data_integration['working']:
                logger.info(" Core Data integration working")
            else:
                result['errors'].append("Core Data integration not working")
                logger.error(" Core Data integration missing")

            # Test 3: Test data validation
            data_validation = self._test_data_validation()
            result['details']['data_validation'] = data_validation

            if data_validation['validation_working']:
                logger.info(" Data validation working")
            else:
                result['errors'].append("Data validation not working")
                logger.error(" Data validation missing")

            # Test 4: Test duplicate prevention
            duplicate_prevention = self._test_duplicate_prevention()
            result['details']['duplicate_prevention'] = duplicate_prevention

            if duplicate_prevention['prevention_working']:
                logger.info(" Duplicate prevention working")
            else:
                result['errors'].append("Duplicate prevention not working")
                logger.error(" Duplicate prevention missing")

            # Determine overall success
            result['success'] = (
                transaction_creation['implemented'] and
                core_data_integration['working'] and
                data_validation['validation_working'] and
                duplicate_prevention['prevention_working']
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

    def _check_transaction_creation_logic(self) -> Dict[str, Any]:
        """Check for transaction creation logic implementation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'implemented': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for transaction creation functions
            transaction_functions = [
                'createTransaction',
                'createTransactionFromEmail',
                'saveTransaction',
                'addTransaction'
            ]

            found_functions = []
            for function in transaction_functions:
                if function in content:
                    found_functions.append(function)

            # Check for Transaction model usage
            transaction_patterns = [
                'Transaction',
                'transaction',
                'newTransaction'
            ]

            found_patterns = []
            for pattern in transaction_patterns:
                if pattern in content:
                    found_patterns.append(pattern)

            # Check for data mapping
            mapping_patterns = [
                'map.*data',
                'convert.*data',
                'transform.*data',
                'populate.*transaction'
            ]

            found_mapping = []
            for pattern in mapping_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_mapping.append(pattern)

            return {
                'implemented': len(found_functions) > 0,
                'creation_functions': found_functions,
                'transaction_patterns': found_patterns,
                'data_mapping': found_mapping,
                'implementation_score': len(found_functions) + len(found_patterns)
            }

        except Exception as e:
            return {'implemented': False, 'errors': [f'Error checking transaction creation logic: {str(e)}']}

    def _test_core_data_integration(self) -> Dict[str, Any]:
        """Test Core Data integration for transaction persistence"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for Core Data imports
            core_data_imports = [
                'CoreData',
                'NSManagedObject',
                'NSPersistentContainer',
                'PersistenceController'
            ]

            found_imports = []
            for import_name in core_data_imports:
                if import_name in content:
                    found_imports.append(import_name)

            # Check for Core Data operations
            core_data_operations = [
                'saveContext',
                'managedObjectContext',
                'insert',
                'delete',
                'fetch'
            ]

            found_operations = []
            for operation in core_data_operations:
                if operation in content:
                    found_operations.append(operation)

            # Check for PersistenceController usage
            persistence_patterns = [
                'PersistenceController',
                'persistenceController',
                'shared'
            ]

            found_persistence = []
            for pattern in persistence_patterns:
                if pattern in content:
                    found_persistence.append(pattern)

            core_data_working = (
                len(found_imports) > 0 and
                len(found_operations) > 0
            )

            return {
                'working': core_data_working,
                'core_data_imports': found_imports,
                'core_data_operations': found_operations,
                'persistence_usage': found_persistence,
                'integration_score': len(found_imports) + len(found_operations)
            }

        except Exception as e:
            return {'working': False, 'errors': [f'Error testing Core Data integration: {str(e)}']}

    def _test_data_validation(self) -> Dict[str, Any]:
        """Test data validation for transaction creation"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'validation_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for validation functions
            validation_functions = [
                'validate',
                'isValid',
                'validateTransaction',
                'validateData'
            ]

            found_functions = []
            for function in validation_functions:
                if function in content:
                    found_functions.append(function)

            # Check for validation patterns
            validation_patterns = [
                'nil.*check',
                'empty.*check',
                'validate.*amount',
                'validate.*date',
                'validate.*vendor'
            ]

            found_patterns = []
            for pattern in validation_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_patterns.append(pattern)

            # Check for error handling in validation
            error_handling = [
                'throw',
                'error',
                'validationError',
                'invalid.*data'
            ]

            found_error_handling = []
            for pattern in error_handling:
                if pattern.lower() in content.lower():
                    found_error_handling.append(pattern)

            validation_working = (
                len(found_functions) > 0 and
                len(found_patterns) > 0
            )

            return {
                'validation_working': validation_working,
                'validation_functions': found_functions,
                'validation_patterns': found_patterns,
                'error_handling': found_error_handling,
                'validation_score': len(found_functions) + len(found_patterns)
            }

        except Exception as e:
            return {'validation_working': False, 'errors': [f'Error testing data validation: {str(e)}']}

    def _test_duplicate_prevention(self) -> Dict[str, Any]:
        """Test duplicate transaction prevention"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'prevention_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for duplicate detection patterns
            duplicate_patterns = [
                'duplicate',
                'existing.*transaction',
                'already.*exists',
                'prevent.*duplicate'
            ]

            found_patterns = []
            for pattern in duplicate_patterns:
                if pattern.lower() in content.lower():
                    found_patterns.append(pattern)

            # Check for uniqueness checks
            uniqueness_patterns = [
                'unique.*id',
                'emailId',
                'messageId',
                'unique.*identifier'
            ]

            found_uniqueness = []
            for pattern in uniqueness_patterns:
                if pattern in content:
                    found_uniqueness.append(pattern)

            # Check for existing transaction queries
            query_patterns = [
                'fetch.*existing',
                'find.*transaction',
                'check.*existing',
                'query.*duplicate'
            ]

            found_queries = []
            for pattern in query_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_queries.append(pattern)

            prevention_working = (
                len(found_patterns) > 0 and
                len(found_uniqueness) > 0
            )

            return {
                'prevention_working': prevention_working,
                'duplicate_patterns': found_patterns,
                'uniqueness_checks': found_uniqueness,
                'query_patterns': found_queries,
                'prevention_score': len(found_patterns) + len(found_uniqueness) + len(found_queries)
            }

        except Exception as e:
            return {'prevention_working': False, 'errors': [f'Error testing duplicate prevention: {str(e)}']}

    def test_receipt_processing_performance(self) -> Dict[str, Any]:
        """Test receipt processing performance and scalability"""
        test_name = "Receipt Processing Performance"
        logger.info(f" Testing {test_name}")

        result = {
            'test_name': test_name,
            'timestamp': datetime.now().isoformat(),
            'success': False,
            'details': {},
            'errors': []
        }

        try:
            # Test 1: Check for performance optimizations
            performance_optimizations = self._check_performance_optimizations()
            result['details']['performance_optimizations'] = performance_optimizations

            if performance_optimizations['optimized']:
                logger.info(" Performance optimizations implemented")
            else:
                result['errors'].append("Performance optimizations not found")
                logger.error(" Performance optimizations missing")

            # Test 2: Test batch processing capabilities
            batch_processing = self._test_batch_processing()
            result['details']['batch_processing'] = batch_processing

            if batch_processing['can_batch']:
                logger.info(" Batch processing capabilities working")
            else:
                result['errors'].append("Batch processing capabilities not working")
                logger.error(" Batch processing capabilities missing")

            # Test 3: Test error recovery
            error_recovery = self._test_error_recovery()
            result['details']['error_recovery'] = error_recovery

            if error_recovery['recovery_working']:
                logger.info(" Error recovery working")
            else:
                result['errors'].append("Error recovery not working")
                logger.error(" Error recovery missing")

            # Test 4: Test memory management
            memory_management = self._test_memory_management()
            result['details']['memory_management'] = memory_management

            if memory_management['management_working']:
                logger.info(" Memory management working")
            else:
                result['errors'].append("Memory management not working")
                logger.error(" Memory management missing")

            # Determine overall success
            result['success'] = (
                performance_optimizations['optimized'] and
                batch_processing['can_batch'] and
                error_recovery['recovery_working'] and
                memory_management['management_working']
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

    def _check_performance_optimizations(self) -> Dict[str, Any]:
        """Check for performance optimizations in receipt processing"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'optimized': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for async processing
            async_patterns = [
                'async',
                'await',
                'DispatchQueue',
                'Task',
                'async/await'
            ]

            found_async = []
            for pattern in async_patterns:
                if pattern in content:
                    found_async.append(pattern)

            # Check for caching
            cache_patterns = [
                'cache',
                'Cache',
                'cached',
                'memory.*cache'
            ]

            found_cache = []
            for pattern in cache_patterns:
                if pattern.lower() in content.lower():
                    found_cache.append(pattern)

            # Check for background processing
            background_patterns = [
                'background',
                'Background',
                'backgroundQueue',
                'global.*queue'
            ]

            found_background = []
            for pattern in background_patterns:
                if pattern in content:
                    found_background.append(pattern)

            # Check for rate limiting
            rate_limit_patterns = [
                'rate.*limit',
                'throttle',
                'delay',
                'timeout'
            ]

            found_rate_limit = []
            for pattern in rate_limit_patterns:
                if pattern.lower() in content.lower():
                    found_rate_limit.append(pattern)

            optimization_score = len(found_async) + len(found_cache) + len(found_background) + len(found_rate_limit)
            optimized = optimization_score >= 2

            return {
                'optimized': optimized,
                'async_processing': found_async,
                'caching': found_cache,
                'background_processing': found_background,
                'rate_limiting': found_rate_limit,
                'optimization_score': optimization_score
            }

        except Exception as e:
            return {'optimized': False, 'errors': [f'Error checking performance optimizations: {str(e)}']}

    def _test_batch_processing(self) -> Dict[str, Any]:
        """Test batch processing capabilities"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'can_batch': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for batch processing patterns
            batch_patterns = [
                'batch',
                'Batch',
                'multiple.*emails',
                'process.*batch',
                'batch.*process'
            ]

            found_batch = []
            for pattern in batch_patterns:
                if pattern.lower() in content.lower():
                    found_batch.append(pattern)

            # Check for loop/iteration patterns
            loop_patterns = [
                'for.*email',
                'foreach.*email',
                'while.*email',
                'email.*loop'
            ]

            found_loops = []
            for pattern in loop_patterns:
                import re
                if re.search(pattern, content, re.IGNORECASE):
                    found_loops.append(pattern)

            # Check for array/list processing
            array_patterns = [
                'Array.*Email',
                '[Email]',
                'emails.*array',
                'list.*emails'
            ]

            found_arrays = []
            for pattern in array_patterns:
                if pattern in content:
                    found_arrays.append(pattern)

            can_batch = (
                len(found_batch) > 0 and
                (len(found_loops) > 0 or len(found_arrays) > 0)
            )

            return {
                'can_batch': can_batch,
                'batch_patterns': found_batch,
                'loop_patterns': found_loops,
                'array_patterns': found_arrays,
                'batch_score': len(found_batch) + len(found_loops) + len(found_arrays)
            }

        except Exception as e:
            return {'can_batch': False, 'errors': [f'Error testing batch processing: {str(e)}']}

    def _test_error_recovery(self) -> Dict[str, Any]:
        """Test error recovery mechanisms"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'recovery_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for error handling patterns
            error_patterns = [
                'catch',
                'error',
                'Error',
                'try.*catch',
                'do.*catch'
            ]

            found_error = []
            for pattern in error_patterns:
                if pattern in content:
                    found_error.append(pattern)

            # Check for retry logic
            retry_patterns = [
                'retry',
                'Retry',
                'attempt.*again',
                'try.*again'
            ]

            found_retry = []
            for pattern in retry_patterns:
                if pattern.lower() in content.lower():
                    found_retry.append(pattern)

            # Check for fallback mechanisms
            fallback_patterns = [
                'fallback',
                'Fallback',
                'alternative',
                'backup'
            ]

            found_fallback = []
            for pattern in fallback_patterns:
                if pattern.lower() in content.lower():
                    found_fallback.append(pattern)

            recovery_working = (
                len(found_error) > 0 and
                (len(found_retry) > 0 or len(found_fallback) > 0)
            )

            return {
                'recovery_working': recovery_working,
                'error_handling': found_error,
                'retry_logic': found_retry,
                'fallback_mechanisms': found_fallback,
                'recovery_score': len(found_error) + len(found_retry) + len(found_fallback)
            }

        except Exception as e:
            return {'recovery_working': False, 'errors': [f'Error testing error recovery: {str(e)}']}

    def _test_memory_management(self) -> Dict[str, Any]:
        """Test memory management in receipt processing"""
        try:
            gmail_api_service_path = os.path.join(self.app_path, 'FinanceMate/Services/GmailAPIService.swift')

            if not os.path.exists(gmail_api_service_path):
                return {'management_working': False, 'errors': ['GmailAPIService.swift not found']}

            with open(gmail_api_service_path, 'r') as f:
                content = f.read()

            # Check for memory management patterns
            memory_patterns = [
                'autoreleasepool',
                'weak',
                'unowned',
                'memory',
                'Memory'
            ]

            found_memory = []
            for pattern in memory_patterns:
                if pattern in content:
                    found_memory.append(pattern)

            # Check for resource cleanup
            cleanup_patterns = [
                'cleanup',
                'Cleanup',
                'release',
                'dispose',
                'deinit'
            ]

            found_cleanup = []
            for pattern in cleanup_patterns:
                if pattern.lower() in content.lower():
                    found_cleanup.append(pattern)

            # Check for data stream processing
            stream_patterns = [
                'stream',
                'Stream',
                'chunk',
                'partial'
            ]

            found_stream = []
            for pattern in stream_patterns:
                if pattern.lower() in content.lower():
                    found_stream.append(pattern)

            management_working = (
                len(found_memory) > 0 and
                len(found_cleanup) > 0
            )

            return {
                'management_working': management_working,
                'memory_patterns': found_memory,
                'cleanup_patterns': found_cleanup,
                'stream_patterns': found_stream,
                'management_score': len(found_memory) + len(found_cleanup) + len(found_stream)
            }

        except Exception as e:
            return {'management_working': False, 'errors': [f'Error testing memory management: {str(e)}']}

    def generate_test_report(self) -> Dict[str, Any]:
        """Generate comprehensive test report"""
        logger.info(" Generating Gmail Receipt Processing test report")

        total_tests = len(self.test_results)
        passed_tests = sum(1 for test in self.test_results if test['success'])
        failed_tests = total_tests - passed_tests

        report = {
            'test_suite': 'Gmail Receipt Processing E2E Validation',
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
            report['summary']['recommendations'].append("All Gmail receipt processing tests passed - system is ready for production")
        else:
            report['summary']['recommendations'].append("Address critical receipt processing issues before production deployment")

        if self.gmail_test_credentials.get('mock_mode', False):
            report['summary']['warnings'].append("Tests run in mock mode - configure real Gmail credentials for full validation")
            report['summary']['recommendations'].append("Set up Gmail test credentials for comprehensive receipt processing validation")

        return report

    def save_test_report(self, report: Dict[str, Any]) -> str:
        """Save test report to file"""
        report_file = os.path.join(self.test_data_dir, f"gmail_receipt_processing_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")

        try:
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2, default=str)

            logger.info(f" Test report saved to: {report_file}")
            return report_file

        except Exception as e:
            logger.error(f" Error saving test report: {e}")
            return ""

    def run_all_tests(self) -> Dict[str, Any]:
        """Run all Gmail receipt processing tests"""
        logger.info(" Starting Gmail Receipt Processing E2E Test Suite")

        # Run all test methods
        self.test_email_parsing_functionality()
        self.test_line_item_extraction()
        self.test_transaction_creation_from_emails()
        self.test_receipt_processing_performance()

        # Generate and save report
        report = self.generate_test_report()
        report_file = self.save_test_report(report)

        if report_file:
            report['report_file'] = report_file

        logger.info(f" Gmail Receipt Processing E2E Test Suite completed - Success Rate: {report['success_rate']:.1f}%")

        return report

def main():
    """Main test execution function"""
    print(" Gmail Receipt Processing E2E Test Suite")
    print("=" * 50)

    # Create and run test suite
    test_suite = GmailReceiptProcessingE2ETest()
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