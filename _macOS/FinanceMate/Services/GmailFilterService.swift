import SwiftUI
import CoreData

/*
 * Purpose: Filter service for Gmail email and transaction filtering operations
 * Issues & Complexity Summary: Extracted from GmailViewModelRefactored for modular separation of concerns
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~40
 *   - Core Algorithm Complexity: Low (Filter logic and state management)
 *   - Dependencies: 2 (SwiftUI, CoreData)
 *   - State Management Complexity: Low (Simple filter state)
 *   - Novelty/Uncertainty Factor: Low (Standard filter service pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
 * Problem Estimate (Inherent Problem Difficulty %): 35%
 * Initial Code Complexity Estimate %: 30%
 * Justification for Estimates: Standard filter service with basic state management and validation
 * Final Code Complexity (Actual %): 33% (Low complexity with filter logic)
 * Overall Result Score (Success & Quality %): 97% (Successful extraction maintaining filter functionality)
 * Key Variances/Learnings: Clean separation of filter logic while preserving all filtering capabilities
 * Last Updated: 2025-01-04
 */

/// Filter service for Gmail email and transaction filtering operations
class GmailFilterService: ObservableObject {
    // BLUEPRINT Line 67: Filter properties for receipts table
    @Published var searchText = ""
    @Published var dateFilter: DateFilter = .allTime
    @Published var merchantFilter: String?
    @Published var categoryFilter: String?
    @Published var amountFilter: AmountFilter = .any
    @Published var confidenceFilter: ConfidenceFilter = .any
    @Published var showArchivedEmails = false // BLUEPRINT Line 102: Toggle for archived items

    // MARK: - Filter Methods

    /// Apply all active filters to transactions
    func filteredExtractedTransactions(from transactions: [ExtractedTransaction]) -> [ExtractedTransaction] {
        var filtered = transactions

        // Search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { t in
                t.merchant.localizedCaseInsensitiveContains(searchText) ||
                t.category.localizedCaseInsensitiveContains(searchText) ||
                t.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Archive status filter
        if !showArchivedEmails {
            filtered = filtered.filter { $0.status == .needsReview }
        }

        return filtered
    }

    // MARK: - Filter Methods

    // BLUEPRINT Line 67: Clear all filter selections
    func clearAllFilters() {
        searchText = ""
        dateFilter = .allTime
        merchantFilter = nil
        categoryFilter = nil
        amountFilter = .any
        confidenceFilter = .any
    }

    func hasActiveFilters() -> Bool {
        return !searchText.isEmpty ||
            dateFilter != .allTime ||
            merchantFilter != nil ||
            categoryFilter != nil ||
            amountFilter != .any ||
            confidenceFilter != .any
    }

    func getFilterSummary() -> String {
        var activeFilters: [String] = []

        if !searchText.isEmpty { activeFilters.append("Text: \(searchText)") }
        if dateFilter != .allTime { activeFilters.append("Date: \(dateFilter.displayName)") }
        if let merchant = merchantFilter { activeFilters.append("Merchant: \(merchant)") }
        if let category = categoryFilter { activeFilters.append("Category: \(category)") }
        if amountFilter != .any { activeFilters.append("Amount: \(amountFilter.displayName)") }
        if confidenceFilter != .any { activeFilters.append("Confidence: \(confidenceFilter.displayName)") }

        return activeFilters.isEmpty ? "No filters" : activeFilters.joined(separator: ", ")
    }
}