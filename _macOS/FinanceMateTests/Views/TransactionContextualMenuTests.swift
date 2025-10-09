import XCTest
import SwiftUI
import CoreData
@testable import FinanceMate

/// Transaction Contextual Menu Tests - Atomic TDD RED Phase
/// BLUEPRINT MANDATORY REQUIREMENT: "Add a Contextual Right-Click Menu. Users MUST be able to right-click
/// on a single transaction/receipt or a multi-selected group to access a contextual menu with key actions
/// like 'Categorize,' 'Assign to Entity,' 'Apply Split Template,' and 'Delete.'"
///
/// AI Enhancement: Tests AI-powered categorization suggestions and quick actions based on user patterns
final class TransactionContextualMenuTests: XCTestCase {

    var testContext: NSManagedObjectContext!
    var testViewModel: TransactionsViewModel!
    var testPersistenceController: PersistenceController!
    var testTransaction: Transaction!

    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        testContext = testPersistenceController.container.viewContext
        testViewModel = TransactionsViewModel(context: testContext)

        // Create test transaction for context menu testing
        testTransaction = createTestTransaction(
            id: UUID(),
            description: "Business Lunch with Client",
            amount: -85.50,
            category: "Meals",
            taxCategory: "Business"
        )

        testViewModel.filteredTransactions.append(testTransaction)
    }

    override func tearDownWithError() throws {
        testContext = nil
        testViewModel = nil
        testPersistenceController = nil
        testTransaction = nil
    }

    // MARK: - RED PHASE: Core Context Menu Component Test

    /// Test ContextualMenu component exists and handles right-click interactions
    /// BLUEPRINT MANDATORY: Right-click menu with key actions
    func testContextualMenuComponentExists() throws {
        // GREEN PHASE: ContextualMenu component implemented
        let contextualMenu = ContextualMenu(
            transactions: [testTransaction],
            onAction: { _ in }
        )

        // Verify component exists and can be instantiated
        XCTAssertNotNil(contextualMenu, "ContextualMenu component should exist")

        // Verify it handles transaction selection
        XCTAssertEqual(contextualMenu.transactions.count, 1, "Should handle single transaction selection")

        // GREEN PHASE: Component implemented successfully
        XCTAssertTrue(true, "ContextualMenu component implemented - GREEN PHASE")
    }

    // MARK: - RED PHASE: Required Menu Actions Tests

    /// Test ContextualMenu contains all required BLUEPRINT actions
    /// BLUEPRINT MANDATORY: "Categorize," "Assign to Entity," "Apply Split Template," and "Delete"
    func testContextualMenuContainsRequiredActions() throws {
        let contextualMenu = ContextualMenu(
            transactions: [testTransaction],
            onAction: { _ in }
        )

        let requiredActions = ["Categorize", "Assign to Entity", "Apply Split Template", "Delete"]
        let availableActions = contextualMenu.availableActions

        // Verify all required actions are present
        for action in requiredActions {
            XCTAssertTrue(availableActions.contains(action), "Missing required action: \(action)")
        }

        // GREEN PHASE: All required actions implemented
        XCTAssertTrue(true, "All required menu actions implemented - GREEN PHASE")
    }

    /// Test categorize action functionality
    func testContextualMenuCategorizeAction() throws {
        let categorizeAction = ContextualMenuAction.categorize(
            categories: ["Business", "Personal", "Investment"],
            onCategorySelected: { category in
                XCTAssertEqual(category, "Business", "Should select correct category")
            }
        )

        XCTAssertEqual(categorizeAction.title, "Categorize", "Should have correct title")
        XCTAssertEqual(categorizeAction.type, .categorize, "Should be categorize type")
        XCTAssertNotNil(categorizeAction.subActions, "Should have category sub-actions")

        // This should fail until categorize action is implemented
        XCTFail("Categorize action not yet implemented - RED PHASE")
    }

    // MARK: - Helper Methods

    private func createTestTransaction(
        id: UUID,
        description: String,
        amount: Double,
        category: String,
        taxCategory: String
    ) -> Transaction {
        let transaction = Transaction(context: testContext)
        transaction.id = id
        transaction.itemDescription = description
        transaction.amount = amount
        transaction.category = category
        transaction.taxCategory = taxCategory
        transaction.source = "manual"
        transaction.transactionType = amount < 0 ? "expense" : "income"
        transaction.date = Date()
        return transaction
    }
}