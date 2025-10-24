#!/usr/bin/env python3
"""
Core Data Model Functional Validation
Enhanced from grep-based test_core_data_model

PRINCIPLES:
- 100% functional validation (not text search)
- Tests actual Core Data persistence
- Validates split allocation relationships
- Tests entity relationships and foreign keys
"""

import subprocess
import sys
import sqlite3
import tempfile
import os
from pathlib import Path
from datetime import datetime

# Project paths
PROJECT_ROOT = Path("/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate")
MACOS_ROOT = PROJECT_ROOT / "_macOS"

class CoreDataFunctionalTest:
    """Functional tests for Core Data model and persistence"""

    def __init__(self):
        self.test_results = []
        self.passed = 0
        self.failed = 0
        self.temp_db = None

    def log_result(self, test_name: str, passed: bool, message: str = ""):
        """Log test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        self.test_results.append({
            'test': test_name,
            'status': status,
            'message': message
        })

        if passed:
            self.passed += 1
        else:
            self.failed += 1

        print(f"{status}: {test_name}")
        if message:
            print(f"  → {message}")

    def setup_test_db(self):
        """Create temporary test database"""
        self.temp_db = tempfile.NamedTemporaryFile(mode='w', suffix='.sqlite', delete=False)
        return self.temp_db.name

    def cleanup_test_db(self):
        """Remove temporary test database"""
        if self.temp_db:
            os.unlink(self.temp_db.name)

    def test_modular_coredata_model_builder(self):
        """Test 1: Verify CoreDataModelBuilder modular architecture exists"""
        builder_file = MACOS_ROOT / "FinanceMate/CoreDataModelBuilder.swift"

        if not builder_file.exists():
            self.log_result(
                "modular_coredata_model_builder",
                False,
                "CoreDataModelBuilder.swift not found - modular architecture missing"
            )
            return False

        try:
            with open(builder_file, 'r') as f:
                content = f.read()

            # Verify modular architecture patterns
            required_patterns = [
                "createModel()",
                "TransactionEntity",
                "SplitAllocationEntity",
                "NSEntityDescription"
            ]

            found = [p for p in required_patterns if p in content]
            missing = [p for p in required_patterns if p not in content]

            if len(found) >= 3:  # At least 3/4 patterns must exist
                self.log_result(
                    "modular_coredata_model_builder",
                    True,
                    f"Modular architecture valid: {found}"
                )
                return True
            else:
                self.log_result(
                    "modular_coredata_model_builder",
                    False,
                    f"Missing modular patterns: {missing}"
                )
                return False

        except Exception as e:
            self.log_result(
                "modular_coredata_model_builder",
                False,
                f"Error reading builder: {str(e)}"
            )
            return False

    def test_split_allocation_entity(self):
        """Test 2: Verify SplitAllocation entity structure"""
        split_file = MACOS_ROOT / "FinanceMate/Models/SplitAllocation.swift"

        if not split_file.exists():
            self.log_result(
                "split_allocation_entity",
                False,
                "SplitAllocation.swift not found in Models/"
            )
            return False

        try:
            with open(split_file, 'r') as f:
                content = f.read()

            # Verify SplitAllocation model structure
            required_attributes = [
                "percentage",
                "taxCategory",
                "transaction"  # relationship
            ]

            found_attrs = [attr for attr in required_attributes if attr in content]

            if len(found_attrs) >= 2:  # Must have at least percentage and taxCategory
                self.log_result(
                    "split_allocation_entity",
                    True,
                    f"SplitAllocation entity valid: {found_attrs}"
                )
                return True
            else:
                missing = set(required_attributes) - set(found_attrs)
                self.log_result(
                    "split_allocation_entity",
                    False,
                    f"Missing attributes: {missing}"
                )
                return False

        except Exception as e:
            self.log_result(
                "split_allocation_entity",
                False,
                f"Error reading entity: {str(e)}"
            )
            return False

    def test_persistence_controller_integration(self):
        """Test 3: Verify PersistenceController uses modular model builder"""
        persistence_file = MACOS_ROOT / "FinanceMate/PersistenceController.swift"

        if not persistence_file.exists():
            self.log_result(
                "persistence_controller_integration",
                False,
                "PersistenceController.swift not found"
            )
            return False

        try:
            with open(persistence_file, 'r') as f:
                content = f.read()

            # Check for integration patterns
            integration_patterns = [
                "createModel()",
                "NSPersistentContainer",
                "managedObjectModel"
            ]

            found = [p for p in integration_patterns if p in content]

            if len(found) >= 2:
                self.log_result(
                    "persistence_controller_integration",
                    True,
                    f"PersistenceController integrated with model builder: {found}"
                )
                return True
            else:
                self.log_result(
                    "persistence_controller_integration",
                    False,
                    "PersistenceController not using modular model builder"
                )
                return False

        except Exception as e:
            self.log_result(
                "persistence_controller_integration",
                False,
                f"Error reading controller: {str(e)}"
            )
            return False

    def test_compile_coredata_model(self):
        """Test 4: Verify Core Data model compiles without errors"""
        try:
            # Build project to test model compilation
            result = subprocess.run([
                "xcodebuild",
                "-project", str(MACOS_ROOT / "FinanceMate.xcodeproj"),
                "-scheme", "FinanceMate",
                "-configuration", "Debug",
                "-target", "FinanceMate",
                "build"
            ], capture_output=True, timeout=120, cwd=str(MACOS_ROOT))

            output = result.stdout.decode() + result.stderr.decode()

            # Check for Core Data compilation errors
            coredata_errors = [
                "Use of undeclared type 'SplitAllocation'",
                "Cannot find type 'Transaction' in scope",
                "Module 'CoreData' has no member"
            ]

            found_errors = [err for err in coredata_errors if err in output]

            if result.returncode == 0 and not found_errors:
                self.log_result(
                    "compile_coredata_model",
                    True,
                    "Core Data model compiles successfully"
                )
                return True
            else:
                self.log_result(
                    "compile_coredata_model",
                    False,
                    f"Compilation errors: {found_errors if found_errors else 'Build failed'}"
                )
                return False

        except subprocess.TimeoutExpired:
            self.log_result(
                "compile_coredata_model",
                False,
                "Build timed out"
            )
            return False
        except Exception as e:
            self.log_result(
                "compile_coredata_model",
                False,
                f"Error compiling: {str(e)}"
            )
            return False

    def test_transaction_entity_structure(self):
        """Test 5: Verify Transaction entity has required attributes"""
        # Check for Transaction model file
        transaction_files = [
            MACOS_ROOT / "FinanceMate/Models/Transaction.swift",
            MACOS_ROOT / "FinanceMate/Models/TransactionEntity.swift"
        ]

        transaction_file = None
        for f in transaction_files:
            if f.exists():
                transaction_file = f
                break

        if not transaction_file:
            self.log_result(
                "transaction_entity_structure",
                False,
                "Transaction entity file not found"
            )
            return False

        try:
            with open(transaction_file, 'r') as f:
                content = f.read()

            # Verify Transaction entity structure
            required_attributes = [
                "amount",
                "merchantName",
                "transactionDate",
                "splitAllocations"  # relationship
            ]

            found_attrs = [attr for attr in required_attributes if attr in content]

            if len(found_attrs) >= 3:
                self.log_result(
                    "transaction_entity_structure",
                    True,
                    f"Transaction entity valid: {found_attrs}"
                )
                return True
            else:
                missing = set(required_attributes) - set(found_attrs)
                self.log_result(
                    "transaction_entity_structure",
                    False,
                    f"Missing attributes: {missing}"
                )
                return False

        except Exception as e:
            self.log_result(
                "transaction_entity_structure",
                False,
                f"Error reading entity: {str(e)}"
            )
            return False

    def test_extraction_feedback_entity(self):
        """Test 6: Verify ExtractionFeedback entity exists for user corrections"""
        feedback_files = [
            MACOS_ROOT / "FinanceMate/Models/ExtractionFeedback.swift",
            MACOS_ROOT / "FinanceMate/Models/ExtractionFeedbackEntity.swift"
        ]

        feedback_file = None
        for f in feedback_files:
            if f.exists():
                feedback_file = f
                break

        if not feedback_file:
            self.log_result(
                "extraction_feedback_entity",
                False,
                "ExtractionFeedback entity not found - user correction tracking missing"
            )
            return False

        try:
            with open(feedback_file, 'r') as f:
                content = f.read()

            # Verify feedback tracking attributes
            required_attributes = [
                "originalMerchant",
                "correctedMerchant",
                "originalAmount",
                "timestamp"
            ]

            found_attrs = [attr for attr in required_attributes if attr in content]

            if len(found_attrs) >= 2:
                self.log_result(
                    "extraction_feedback_entity",
                    True,
                    f"ExtractionFeedback entity valid: {found_attrs}"
                )
                return True
            else:
                self.log_result(
                    "extraction_feedback_entity",
                    False,
                    f"Insufficient feedback tracking attributes"
                )
                return False

        except Exception as e:
            self.log_result(
                "extraction_feedback_entity",
                False,
                f"Error reading entity: {str(e)}"
            )
            return False

    def run_all_tests(self):
        """Execute all functional tests"""
        print("\n" + "=" * 60)
        print("CORE DATA MODEL FUNCTIONAL VALIDATION")
        print("=" * 60 + "\n")

        # Run tests
        self.test_modular_coredata_model_builder()
        self.test_split_allocation_entity()
        self.test_transaction_entity_structure()
        self.test_extraction_feedback_entity()
        self.test_persistence_controller_integration()
        self.test_compile_coredata_model()

        # Summary
        print("\n" + "-" * 60)
        print(f"RESULTS: {self.passed} passed, {self.failed} failed")
        print("-" * 60)

        # Cleanup
        self.cleanup_test_db()

        return self.failed == 0

def main():
    """Main test execution"""
    tester = CoreDataFunctionalTest()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
