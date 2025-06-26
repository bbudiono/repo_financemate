import XCTest
import CoreData
@testable import FinanceMate

class BudgetCoreDataTests: XCTestCase {
    var coreDataStack: CoreDataStack!
    var budgetManager: BudgetManager!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack()
        budgetManager = BudgetManager(context: coreDataStack.mainContext)
    }

    override func tearDown() {
        try? coreDataStack.deleteAllData()
        super.tearDown()
    }

    func testBudgetCreation() {
        let budget = budgetManager.createBudget(
            name: "Test Budget",
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )

        XCTAssertNotNil(budget.id)
        XCTAssertEqual(budget.name, "Test Budget")
        XCTAssertEqual(budget.totalBudgeted, 1000.0)
        XCTAssertEqual(budget.budgetTypeEnum, .monthly)
        XCTAssertTrue(budget.isActive)

        // Test that default categories were created
        let categories = budget.categories?.allObjects as? [BudgetCategory] ?? []
        XCTAssertFalse(categories.isEmpty, "Budget should have default categories")
        XCTAssertEqual(categories.count, BudgetCategoryData.defaultCategories.count)
    }

    func testBudgetCategoryRelationship() {
        let budget = budgetManager.createBudget(
            name: "Test Budget",
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )

        let categories = budget.categories?.allObjects as? [BudgetCategory] ?? []
        guard let firstCategory = categories.first else {
            XCTFail("Budget should have categories")
            return
        }

        XCTAssertEqual(firstCategory.budget, budget)
        XCTAssertNotNil(firstCategory.name)
        XCTAssertNotNil(firstCategory.budgetedAmount)
        XCTAssertEqual(firstCategory.spentAmount?.doubleValue, 0.0)
    }

    func testSpendingTracker() {
        let budget = budgetManager.createBudget(
            name: "Test Budget",
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )

        let categories = budget.categories?.allObjects as? [BudgetCategory] ?? []
        guard let category = categories.first else {
            XCTFail("Budget should have categories")
            return
        }

        // Add spending
        budgetManager.addSpending(to: category, amount: 100.0, description: "Test purchase")

        XCTAssertEqual(category.spentAmount?.doubleValue, 100.0)
        XCTAssertEqual(budget.totalSpent, 100.0)
        XCTAssertEqual(budget.remainingAmount, budget.totalBudgeted - 100.0)

        // Test allocation was created
        let allocations = category.allocations?.allObjects as? [BudgetAllocation] ?? []
        XCTAssertEqual(allocations.count, 1)
        XCTAssertEqual(allocations.first?.amount?.doubleValue, 100.0)
    }

    func testBudgetDeletion() {
        let budget = budgetManager.createBudget(
            name: "Test Budget",
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )

        let budgetId = budget.objectID
        budgetManager.deleteBudget(budget)

        // Verify budget is deleted
        XCTAssertFalse(budgetManager.budgets.contains { $0.objectID == budgetId })
    }

    func testFetchBudgets() {
        // Create multiple budgets
        let budget1 = budgetManager.createBudget(
            name: "Budget 1",
            amount: 1000.0,
            type: .monthly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        )

        let budget2 = budgetManager.createBudget(
            name: "Budget 2",
            amount: 2000.0,
            type: .weekly,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        )

        budgetManager.fetchBudgets()

        XCTAssertEqual(budgetManager.budgets.count, 2)
        XCTAssertTrue(budgetManager.budgets.contains(budget1))
        XCTAssertTrue(budgetManager.budgets.contains(budget2))
    }
}
