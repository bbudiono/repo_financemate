import CoreData
import Foundation
import SwiftUI

/*
 * Purpose: LineItemViewModel for managing line item CRUD operations in transaction splitting workflow
 * Issues & Complexity Summary: Manages complex Core Data relationships, validation, and async operations for line item management
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~200
   - Core Algorithm Complexity: Med-High (CRUD operations with validation)
   - Dependencies: 4 (Core Data, Foundation, SwiftUI, LineItem/SplitAllocation entities)
   - State Management Complexity: Med-High (@Published properties with async operations)
   - Novelty/Uncertainty Factor: Med (Phase 2 splitting feature implementation)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
 * Problem Estimate (Inherent Problem Difficulty %): 80%
 * Initial Code Complexity Estimate %: 75%
 * Justification for Estimates: Complex Core Data relationships with validation and Australian locale compliance
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

/// Data structure for creating new line items
struct LineItemData {
    var itemDescription = ""
    var amount = 0.0
}

/// ViewModel for managing line item operations with Core Data integration
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class LineItemViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var lineItems: [LineItem] = []
    @Published var newLineItem = LineItemData()
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    let currencyFormatter: NumberFormatter

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
        currencyFormatter = NumberFormatter()
        setupCurrencyFormatter()
    }

    private func setupCurrencyFormatter() {
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_AU")
        currencyFormatter.currencyCode = "AUD"
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2
    }

    // MARK: - CRUD Operations

    /// Adds a new line item to the specified transaction
    /// - Parameter transaction: The transaction to add the line item to
    func addLineItem() {
        guard validateNewLineItem() else {
            return
        }

        do {
            isLoading = true
            errorMessage = nil

            _ = LineItem.create(
                in: context,
                itemDescription: newLineItem.itemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: newLineItem.amount,
                transaction: transaction
            )

            try context.save()

            // Reset form data
            newLineItem = LineItemData()

            // Refresh line items
            fetchLineItems(for: transaction)

        } catch {
            errorMessage = "Failed to create line item: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Updates an existing line item
    /// - Parameter lineItem: The line item to update
    func updateLineItem() {
        do {
            isLoading = true
            errorMessage = nil

            // Validate the updated line item
            guard validateDescription(lineItem.itemDescription) && validateAmount(lineItem.amount) else {
                errorMessage = "Invalid line item data: description must be non-empty and amount must be positive"
                isLoading = false
                return
            }

            try context.save()

            // Refresh line items to reflect changes
            fetchLineItems(for: lineItem.transaction)

        } catch {
            errorMessage = "Failed to update line item: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Deletes a line item and its associated split allocations
    /// - Parameter lineItem: The line item to delete
    func deleteLineItem() {
        do {
            isLoading = true
            errorMessage = nil

            let transaction = lineItem.transaction
            context.delete(lineItem)
            try context.save()

            // Refresh line items
            fetchLineItems(for: transaction)

        } catch {
            errorMessage = "Failed to delete line item: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Fetches all line items for a specific transaction
    /// - Parameter transaction: The transaction to fetch line items for
    func fetchLineItems() {
        do {
            isLoading = true
            errorMessage = nil

            let request: NSFetchRequest<LineItem> = LineItem.fetchRequest()
            request.predicate = NSPredicate(format: "transaction == %@", transaction)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \LineItem.itemDescription, ascending: true),
            ]

            lineItems = try context.fetch(request)

        } catch {
            errorMessage = "Failed to fetch line items: \(error.localizedDescription)"
            lineItems = []
        }

        isLoading = false
    }

    // MARK: - Validation Methods

    /// Validates the new line item data
    /// - Returns: True if valid, false otherwise
    private func validateNewLineItem() -> Bool {
        guard validateDescription(newLineItem.itemDescription) else {
            errorMessage = "Description must be between 1 and 200 characters"
            return false
        }

        guard validateAmount(newLineItem.amount) else {
            errorMessage = "Amount must be positive and have at most 2 decimal places"
            return false
        }

        return true
    }

    /// Validates a line item description
    /// - Parameter description: The description to validate
    /// - Returns: True if valid, false otherwise
    func validateDescription(_ description: String) -> Bool {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 200
    }

    /// Validates a line item amount
    /// - Parameter amount: The amount to validate
    /// - Returns: True if valid, false otherwise
    func validateAmount(_ amount: Double) -> Bool {
        guard amount > 0 else { return false }

        // Check for maximum 2 decimal places
        let rounded = (amount * 100).rounded() / 100
        return abs(amount - rounded) < 0.001
    }

    // MARK: - Utility Methods

    /// Formats an amount using Australian currency formatting
    /// - Parameter amount: The amount to format
    /// - Returns: Formatted currency string
    func formatCurrency(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    /// Calculates the total amount for all line items in the current collection
    /// - Returns: Total amount of all line items
    func calculateTotalAmount() -> Double {
        return lineItems.reduce(0.0) { $0 + $1.amount }
    }

    /// Validates that line items total does not exceed transaction amount
    /// - Parameters:
    ///   - transaction: The transaction to validate against
    ///   - excludingItem: Optional line item to exclude from calculation (for updates)
    /// - Returns: True if valid, false otherwise
    func validateTotalAmount(for transaction: Transaction, excludingItem: LineItem? = nil) -> Bool {
        let lineItemsToConsider = excludingItem != nil ?
            lineItems.filter { $0 != excludingItem } : lineItems

        let currentTotal = lineItemsToConsider.reduce(0.0) { $0 + $1.amount }
        let additionalAmount = excludingItem?.amount ?? newLineItem.amount

        return (currentTotal + additionalAmount) <= transaction.amount
    }

    /// Clears any error messages
    func clearError() {
        errorMessage = nil
    }

    /// Resets the new line item form
    func resetForm() {
        newLineItem = LineItemData()
        clearError()
    }
}
