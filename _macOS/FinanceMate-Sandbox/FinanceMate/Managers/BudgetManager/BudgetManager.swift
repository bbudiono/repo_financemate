import CoreData
import Foundation
import SwiftUI

@MainActor
public class BudgetManager: ObservableObject {
    @Published public var budgets: [Budget] = []
    @Published public var selectedBudget: Budget?
    @Published public var isLoading = false

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
        fetchBudgets()
    }

    // MARK: - Fetch Operations

    public func fetchBudgets() {
        isLoading = true

        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Budget.isActive, ascending: false),
            NSSortDescriptor(keyPath: \Budget.dateCreated, ascending: false)
        ]

        do {
            budgets = try context.fetch(request)
        } catch {
            print("Error fetching budgets: \(error)")
        }

        isLoading = false
    }

    // MARK: - Budget Operations

    @discardableResult
    public func createBudget(
        name: String,
        amount: Double,
        type: BudgetType,
        startDate: Date,
        endDate: Date,
        categories: [BudgetCategoryData] = []
    ) -> Budget {
        let budget = Budget(context: context)
        budget.id = UUID()
        budget.name = name
        budget.totalAmount = NSDecimalNumber(value: amount)
        budget.currency = "USD"
        budget.budgetType = type.rawValue
        budget.startDate = startDate
        budget.endDate = endDate
        budget.isActive = true
        budget.dateCreated = Date()
        budget.dateUpdated = Date()

        // Create categories
        let categoriesToCreate = categories.isEmpty ? BudgetCategoryData.defaultCategories : categories

        for categoryData in categoriesToCreate {
            let category = BudgetCategory(context: context)
            category.id = UUID()
            category.name = categoryData.name
            category.budgetedAmount = NSDecimalNumber(value: categoryData.budgetedAmount)
            category.spentAmount = NSDecimalNumber(value: 0.0)
            category.categoryType = categoryData.type.rawValue
            category.icon = categoryData.type.icon
            category.colorHex = categoryData.color.toHex()
            category.alertThreshold = categoryData.alertThreshold
            category.isActive = true
            category.dateCreated = Date()
            category.dateUpdated = Date()
            category.budget = budget
        }

        saveContext()
        fetchBudgets()

        return budget
    }

    public func updateBudget(_ budget: Budget) {
        budget.dateUpdated = Date()
        saveContext()
        fetchBudgets()
    }

    public func deleteBudget(_ budget: Budget) {
        context.delete(budget)
        saveContext()
        fetchBudgets()
    }

    // MARK: - Category Operations

    public func addCategoryToBudget(_ budget: Budget, categoryData: BudgetCategoryData) {
        let category = BudgetCategory(context: context)
        category.id = UUID()
        category.name = categoryData.name
        category.budgetedAmount = NSDecimalNumber(value: categoryData.budgetedAmount)
        category.spentAmount = NSDecimalNumber(value: 0.0)
        category.categoryType = categoryData.type.rawValue
        category.icon = categoryData.type.icon
        category.colorHex = categoryData.color.toHex()
        category.alertThreshold = categoryData.alertThreshold
        category.isActive = true
        category.dateCreated = Date()
        category.dateUpdated = Date()
        category.budget = budget

        saveContext()
        fetchBudgets()
    }

    public func updateCategory(_ category: BudgetCategory) {
        category.dateUpdated = Date()
        saveContext()
        fetchBudgets()
    }

    public func deleteCategory(_ category: BudgetCategory) {
        context.delete(category)
        saveContext()
        fetchBudgets()
    }

    // MARK: - Spending Operations

    public func addSpending(to category: BudgetCategory, amount: Double, description: String = "") {
        let currentSpent = category.spentAmount?.doubleValue ?? 0.0
        category.spentAmount = NSDecimalNumber(value: currentSpent + amount)
        category.dateUpdated = Date()

        // Create allocation record
        let allocation = BudgetAllocation(context: context)
        allocation.id = UUID()
        allocation.amount = NSDecimalNumber(value: amount)
        allocation.percentage = (amount / (category.budgetedAmount?.doubleValue ?? 1.0)) * 100
        allocation.allocationDate = Date()
        allocation.notes = description
        allocation.isActive = true
        allocation.dateCreated = Date()
        allocation.dateUpdated = Date()
        allocation.budget = category.budget
        allocation.budgetCategory = category

        saveContext()
        fetchBudgets()
    }

    // MARK: - Helper Methods

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving budget context: \(error)")
        }
    }

    public func getActiveBudget() -> Budget? {
        budgets.first { $0.isActive && $0.isActiveComputed }
    }

    public func getBudgetCategories(for budget: Budget) -> [BudgetCategory] {
        guard let categories = budget.categories?.allObjects as? [BudgetCategory] else { return [] }
        return categories.sorted { $0.name ?? "" < $1.name ?? "" }
    }

    public func getTotalSpentAcrossAllBudgets() -> Double {
        budgets.reduce(0.0) { total, budget in
            total + budget.totalSpent
        }
    }

    public func getTotalBudgetedAcrossAllBudgets() -> Double {
        budgets.reduce(0.0) { total, budget in
            total + budget.totalBudgeted
        }
    }
}

// MARK: - Budget Category Data Transfer Object

public struct BudgetCategoryData {
    public let name: String
    public let budgetedAmount: Double
    public let type: BudgetCategoryType
    public let color: Color
    public let alertThreshold: Double

    public init(name: String, budgetedAmount: Double, type: BudgetCategoryType, color: Color, alertThreshold: Double) {
        self.name = name
        self.budgetedAmount = budgetedAmount
        self.type = type
        self.color = color
        self.alertThreshold = alertThreshold
    }

    public static let defaultCategories: [BudgetCategoryData] = [
        BudgetCategoryData(name: "Housing", budgetedAmount: 1200.0, type: .housing, color: .blue, alertThreshold: 80.0),
        BudgetCategoryData(name: "Food & Dining", budgetedAmount: 400.0, type: .food, color: .orange, alertThreshold: 85.0),
        BudgetCategoryData(name: "Transportation", budgetedAmount: 300.0, type: .transportation, color: .green, alertThreshold: 90.0),
        BudgetCategoryData(name: "Utilities", budgetedAmount: 150.0, type: .utilities, color: .yellow, alertThreshold: 75.0),
        BudgetCategoryData(name: "Entertainment", budgetedAmount: 200.0, type: .entertainment, color: .pink, alertThreshold: 100.0),
        BudgetCategoryData(name: "Shopping", budgetedAmount: 150.0, type: .shopping, color: .brown, alertThreshold: 90.0),
        BudgetCategoryData(name: "Healthcare", budgetedAmount: 100.0, type: .healthcare, color: .red, alertThreshold: 80.0),
        BudgetCategoryData(name: "Savings", budgetedAmount: 500.0, type: .savings, color: .mint, alertThreshold: 50.0)
    ]
}

// MARK: - Color Extension for Hex Conversion

extension Color {
    func toHex() -> String {
        let components = self.cgColor?.components ?? [0, 0, 0, 1]
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
