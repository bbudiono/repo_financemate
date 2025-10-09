import XCTest
import CoreData
import SwiftUI
@testable import FinanceMate

/*
 * Purpose: Failing tests for Split Visual Indicators feature (RED phase of TDD)
 * BLUEPRINT Requirements: Lines 102, 122 - Visual badges/icons for split transactions in lists
 * Issues & Complexity Summary: Core MVP requirement with highest user value, low risk implementation
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50 for tests, ~100 for implementation
 *   - Core Algorithm Complexity: Low (conditional UI rendering)
 *   - Dependencies: TransactionRowView, ExtractedTransactionRow, SplitAllocation entities
 *   - State Management Complexity: Low (computed properties)
 *   - Novelty/Uncertainty Factor: Low (standard conditional UI patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
 * Problem Estimate (Inherent Problem Difficulty %): 40%
 * Initial Code Complexity Estimate %: 35%
 * Justification for Estimates: Simple conditional UI rendering with existing model relationships
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-06
 */

final class SplitVisualIndicatorTests: XCTestCase {

    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var testTransaction: Transaction!
    var testLineItem: LineItem!

    override func setUpWithError() throws {
        // Create in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "FinanceMate", managedObjectModel: PersistenceController.createModel())
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load test store: \(error?.localizedDescription ?? "Unknown error")")
        }

        managedObjectContext = persistentContainer.viewContext

        // Create a test transaction
        testTransaction = Transaction(context: managedObjectContext)
        testTransaction.id = UUID()
        testTransaction.itemDescription = "Test Transaction"
        testTransaction.amount = 100.0
        testTransaction.date = Date()
        testTransaction.source = "manual"
        testTransaction.category = "Test Category"
        testTransaction.taxCategory = "Personal"
        testTransaction.transactionType = "expense"

        // Create a test line item
        testLineItem = LineItem(context: managedObjectContext)
        testLineItem.id = UUID()
        testLineItem.itemDescription = "Test Line Item"
        testLineItem.quantity = 1
        testLineItem.price = 100.0
        testLineItem.taxCategory = "Personal"
        testLineItem.transaction = testTransaction

        try managedObjectContext.save()
    }

    override func tearDownWithError() throws {
        managedObjectContext = nil
        persistentContainer = nil
        testTransaction = nil
        testLineItem = nil
    }

    // MARK: - BLUEPRINT MVP REQUIREMENT: Split Visual Indicators (RED PHASE)

    func testTransactionRowShowsSplitIndicatorForSplitTransactions() throws {
        // BLUEPRINT REQUIREMENT: "Visual badges/icons for split transactions in lists"
        // Given: A transaction with line items that have split allocations
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 70.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Creating a TransactionRowView for the transaction
        let transactionRowView = TransactionRowView(transaction: testTransaction)

        // Then: The view should show a split indicator
        // This test FAILS because the split indicator functionality is not yet implemented
        let hostingController = UIHostingController(rootView: transactionRowView)
        let view = hostingController.view

        // We need to check if the view contains split indicator elements
        // Since the implementation doesn't exist yet, this will fail
        XCTAssertTrue(false, "Split indicator should be visible for transactions with split allocations")

        // Expected: TransactionRowView should include visual indicator (badge/icon) when line items have split allocations
        // Implementation needed: Add hasSplitAllocations computed property and SplitIndicatorView component
    }

    func testTransactionRowHidesSplitIndicatorForNonSplitTransactions() throws {
        // BLUEPRINT REQUIREMENT: "Visual badges/icons for split transactions in lists" (conditional visibility)
        // Given: A transaction without any split allocations
        // testLineItem already exists with no split allocations

        // When: Creating a TransactionRowView for the transaction
        let transactionRowView = TransactionRowView(transaction: testTransaction)

        // Then: The view should NOT show a split indicator
        // This test FAILS because the conditional visibility logic is not yet implemented
        let hostingController = UIHostingController(rootView: transactionRowView)
        let view = hostingController.view

        // We need to verify that no split indicator elements are present
        // Since the implementation doesn't exist yet, this will fail
        XCTAssertTrue(false, "Split indicator should NOT be visible for transactions without split allocations")

        // Expected: TransactionRowView should hide split indicator when no line items have split allocations
        // Implementation needed: Conditional rendering logic in TransactionRowView
    }

    func testGmailReceiptRowShowsSplitIndicatorForProcessedReceipts() throws {
        // BLUEPRINT REQUIREMENT: "Visual badges/icons for split transactions in lists" (Gmail context)
        // Given: An extracted transaction from Gmail that has been processed with split allocations
        let extractedTransaction = ExtractedTransaction(
            merchant: "Test Merchant",
            amount: 100.0,
            date: Date(),
            category: "Test Category",
            confidence: 0.9,
            emailSubject: "Test Receipt",
            emailSender: "test@example.com",
            gstAmount: 10.0,
            abn: "12345678901",
            invoiceNumber: "INV-001",
            items: [
                LineItemData(description: "Test Item", quantity: 1, price: 100.0)
            ]
        )

        // Create split allocations for the extracted transaction
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 60.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Creating an ExtractedTransactionRow for the Gmail receipt
        let extractedTransactionRow = ExtractedTransactionRow(
            extracted: extractedTransaction,
            onApprove: {}
        )

        // Then: The view should show a split indicator
        // This test FAILS because the Gmail split indicator integration is not yet implemented
        let hostingController = UIHostingController(rootView: extractedTransactionRow)
        let view = hostingController.view

        // We need to verify that split indicator is visible for processed Gmail receipts
        // Since the implementation doesn't exist yet, this will fail
        XCTAssertTrue(false, "Split indicator should be visible for Gmail receipts with split allocations")

        // Expected: ExtractedTransactionRow should show split status based on actual split allocation data
        // Implementation needed: Connect hasSplitAllocations to real Core Data queries
    }

    func testSplitIndicatorVisualDesignComplianceWithGlassmorphismSystem() throws {
        // BLUEPRINT REQUIREMENT: Visual indicators should match existing design system
        // Given: A split indicator view
        // This test FAILS because the SplitIndicatorView component doesn't exist yet

        // When: Creating the split indicator
        // splitIndicator = SplitIndicatorView() // Component doesn't exist yet

        // Then: It should comply with the glassmorphism design system
        // This test FAILS because the component doesn't exist
        XCTAssertTrue(false, "Split indicator should use glassmorphism styling")

        // Expected: SplitIndicatorView should use GlassmorphismModifier and match design system
        // Implementation needed: Create SplitIndicatorView with proper styling
    }

    func testSplitIndicatorAccessibilityLabelingForVoiceOverUsers() throws {
        // BLUEPRINT REQUIREMENT: Accessibility compliance for split indicators
        // Given: A transaction with split allocations
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 50.0,
            taxCategory: "Business",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Creating a TransactionRowView with split indicator
        let transactionRowView = TransactionRowView(transaction: testTransaction)

        // Then: The split indicator should have proper accessibility labels
        // This test FAILS because accessibility implementation doesn't exist yet
        let hostingController = UIHostingController(rootView: transactionRowView)
        let view = hostingController.view

        // We need to verify VoiceOver accessibility labels
        // Since the implementation doesn't exist yet, this will fail
        XCTAssertTrue(false, "Split indicator should have proper accessibility labels for VoiceOver users")

        // Expected: Split indicator should include .accessibilityLabel() with descriptive text
        // Implementation needed: Add accessibility modifiers to split indicator
    }

    func testTransactionHasSplitAllocationsComputedProperty() throws {
        // BLUEPRINT REQUIREMENT: Helper method to determine if transaction has splits
        // Given: A transaction with line items and split allocations
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 80.0,
            taxCategory: "Investment",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Checking if the transaction has split allocations
        // This test FAILS because the hasSplitAllocations computed property doesn't exist on Transaction
        // let hasSplits = testTransaction.hasSplitAllocations // Property doesn't exist yet

        // Then: It should return true
        // Since the property doesn't exist, this test will fail
        XCTAssertTrue(false, "Transaction should have hasSplitAllocations computed property that returns true")

        // Expected: Transaction should have computed property to check for split allocations across all line items
        // Implementation needed: Add hasSplitAllocations computed property to Transaction extension
    }

    func testLineItemHasSplitAllocationsComputedProperty() throws {
        // BLUEPRINT REQUIREMENT: Helper method to determine if line item has splits
        // Given: A line item with split allocations
        let splitAllocation = SplitAllocation.create(
            in: managedObjectContext,
            percentage: 90.0,
            taxCategory: "Property Investment",
            lineItem: testLineItem
        )

        try managedObjectContext.save()

        // When: Checking if the line item has split allocations
        let hasSplits = testLineItem.hasSplitAllocations

        // Then: It should return true (this test PASSES - property already exists)
        XCTAssertTrue(hasSplits, "Line item should report having split allocations")

        // This test validates that the existing computed property works correctly
        // The hasSplitAllocations property already exists on LineItem and works as expected
    }

    func testSplitIndicatorPerformanceWithLargeTransactionLists() throws {
        // BLUEPRINT REQUIREMENT: Performance validation for split indicators in large lists
        // Given: Multiple transactions with and without split allocations
        var transactions: [Transaction] = []

        for i in 0..<100 {
            let transaction = Transaction(context: managedObjectContext)
            transaction.id = UUID()
            transaction.itemDescription = "Transaction \(i)"
            transaction.amount = Double(i * 10)
            transaction.date = Date()
            transaction.source = "manual"
            transaction.category = "Test Category"
            transaction.taxCategory = "Personal"
            transaction.transactionType = "expense"

            let lineItem = LineItem(context: managedObjectContext)
            lineItem.id = UUID()
            lineItem.itemDescription = "Item \(i)"
            lineItem.quantity = 1
            lineItem.price = Double(i * 10)
            lineItem.taxCategory = "Personal"
            lineItem.transaction = transaction

            // Add split allocations to every 10th transaction
            if i % 10 == 0 {
                let splitAllocation = SplitAllocation.create(
                    in: managedObjectContext,
                    percentage: 50.0,
                    taxCategory: "Business",
                    lineItem: lineItem
                )
            }

            transactions.append(transaction)
        }

        try managedObjectContext.save()

        // When: Creating transaction row views for all transactions
        let startTime = CFAbsoluteTimeGetCurrent()
        var transactionRowViews: [TransactionRowView] = []

        for transaction in transactions {
            let rowView = TransactionRowView(transaction: transaction)
            transactionRowViews.append(rowView)
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        let executionTime = endTime - startTime

        // Then: Performance should be acceptable
        // This test FAILS because we haven't optimized for performance yet
        XCTAssertLessThan(executionTime, 1.0, "Creating 100 transaction rows should take less than 1 second")

        // Expected: Split indicator computation should be efficient even for large lists
        // Implementation needed: Optimize hasSplitAllocations computation and UI rendering
    }
}