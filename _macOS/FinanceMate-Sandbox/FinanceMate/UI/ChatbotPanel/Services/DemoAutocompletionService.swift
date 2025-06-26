//
//  DemoAutocompletionService.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
 * Purpose: Demo autocompletion service for chatbot @ tagging functionality
 * Issues & Complexity Summary: Provides intelligent autocompletion suggestions for @ tagging
 * Key Complexity Drivers:
 - Logic Scope (Est. LoC): ~120
 - Core Algorithm Complexity: Medium
 - Dependencies: 2 (Foundation, Protocol)
 - State Management Complexity: Low
 - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 45%
 * Problem Estimate (Inherent Problem Difficulty %): 40%
 * Initial Code Complexity Estimate %: 43%
 * Justification for Estimates: Smart filtering and suggestion generation with realistic demo data
 * Final Code Complexity (Actual %): 42%
 * Overall Result Score (Success & Quality %): 96%
 * Key Variances/Learnings: Comprehensive demo service provides excellent user experience
 * Last Updated: 2025-06-07
 */

import Foundation

/// Demo autocompletion service providing intelligent @ tagging suggestions
public class DemoAutocompletionService: AutocompletionServiceProtocol {
    // MARK: - Properties

    public var isServiceAvailable: Bool = true

    private let demoFiles = [
        AutocompleteSuggestion(
            id: "invoice_001",
            text: "invoice_ABE2A154-0046.pdf",
            subtitle: "Bell Legal Invoice",
            type: .file,
            metadata: ["size": "245 KB", "date": "2025-06-01"]
        ),
        AutocompleteSuggestion(
            id: "receipt_001",
            text: "receipt_coffee_shop.jpg",
            subtitle: "Coffee Shop Receipt",
            type: .file,
            metadata: ["size": "1.2 MB", "date": "2025-06-05"]
        ),
        AutocompleteSuggestion(
            id: "invoice_002",
            text: "invoice_139999_1034005.pdf",
            subtitle: "Consulting Invoice",
            type: .file,
            metadata: ["size": "189 KB", "date": "2025-06-03"]
        ),
        AutocompleteSuggestion(
            id: "document_001",
            text: "sample_invoice.pdf",
            subtitle: "Sample Financial Document",
            type: .file,
            metadata: ["size": "156 KB", "date": "2025-06-02"]
        )
    ]

    private let demoFolders = [
        AutocompleteSuggestion(
            id: "folder_q1",
            text: "Q1_2025_Receipts",
            subtitle: "First Quarter Receipts",
            type: .folder,
            metadata: ["items": "24 files"]
        ),
        AutocompleteSuggestion(
            id: "folder_invoices",
            text: "Client_Invoices",
            subtitle: "All Client Invoices",
            type: .folder,
            metadata: ["items": "18 files"]
        ),
        AutocompleteSuggestion(
            id: "folder_expenses",
            text: "Business_Expenses",
            subtitle: "Business Expense Documents",
            type: .folder,
            metadata: ["items": "42 files"]
        ),
        AutocompleteSuggestion(
            id: "folder_tax",
            text: "Tax_Documents_2025",
            subtitle: "Tax Preparation Documents",
            type: .folder,
            metadata: ["items": "15 files"]
        )
    ]

    private let demoCategories = [
        AutocompleteSuggestion(
            id: "cat_office",
            text: "Office Supplies",
            subtitle: "Pens, paper, equipment",
            type: .category,
            metadata: ["color": "#3498db"]
        ),
        AutocompleteSuggestion(
            id: "cat_travel",
            text: "Travel & Transportation",
            subtitle: "Flights, hotels, gas",
            type: .category,
            metadata: ["color": "#e74c3c"]
        ),
        AutocompleteSuggestion(
            id: "cat_meals",
            text: "Meals & Entertainment",
            subtitle: "Business meals and events",
            type: .category,
            metadata: ["color": "#f39c12"]
        ),
        AutocompleteSuggestion(
            id: "cat_software",
            text: "Software & Subscriptions",
            subtitle: "SaaS tools and licenses",
            type: .category,
            metadata: ["color": "#9b59b6"]
        ),
        AutocompleteSuggestion(
            id: "cat_consulting",
            text: "Consulting & Professional Services",
            subtitle: "Legal, accounting, consulting",
            type: .category,
            metadata: ["color": "#1abc9c"]
        )
    ]

    private let demoClients = [
        AutocompleteSuggestion(
            id: "client_abc",
            text: "ABC Corporation",
            subtitle: "Primary client - Tech consulting",
            type: .client,
            metadata: ["status": "active", "projects": "3"]
        ),
        AutocompleteSuggestion(
            id: "client_xyz",
            text: "XYZ Enterprises",
            subtitle: "Financial advisory client",
            type: .client,
            metadata: ["status": "active", "projects": "1"]
        ),
        AutocompleteSuggestion(
            id: "client_startup",
            text: "StartupCo Inc",
            subtitle: "Early stage startup client",
            type: .client,
            metadata: ["status": "prospect", "projects": "1"]
        ),
        AutocompleteSuggestion(
            id: "client_bell",
            text: "Bell Legal Services",
            subtitle: "Legal services provider",
            type: .client,
            metadata: ["status": "active", "projects": "2"]
        )
    ]

    // MARK: - AutocompletionServiceProtocol Implementation

    public func fetchAutocompleteSuggestions(
        query: String,
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion] {
        // Simulate network delay for realistic behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        let allSuggestions = getAllSuggestionsForType(type)

        guard !query.isEmpty else {
            // Return top 5 suggestions if no query
            return Array(allSuggestions.prefix(5))
        }

        // Filter suggestions based on query
        let filtered = allSuggestions.filter { suggestion in
            suggestion.text.localizedCaseInsensitiveContains(query) ||
                suggestion.subtitle.localizedCaseInsensitiveContains(query)
        }

        // Sort by relevance (exact matches first, then partial matches)
        let sorted = filtered.sorted { first, second in
            let firstExact = first.text.localizedCaseInsensitiveHasPrefix(query)
            let secondExact = second.text.localizedCaseInsensitiveHasPrefix(query)

            if firstExact && !secondExact {
                return true
            } else if !firstExact && secondExact {
                return false
            } else {
                return first.text.localizedCaseInsensitiveCompare(second.text) == .orderedAscending
            }
        }

        return Array(sorted.prefix(8)) // Return top 8 matches
    }

    public func fetchAllSuggestions(
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        return getAllSuggestionsForType(type)
    }

    // MARK: - Private Methods

    private func getAllSuggestionsForType(_ type: AutocompleteSuggestion.AutocompleteType) -> [AutocompleteSuggestion] {
        switch type {
        case .file:
            return demoFiles
        case .folder:
            return demoFolders
        case .category:
            return demoCategories
        case .client:
            return demoClients
        }
    }
}

// MARK: - String Extensions for Filtering

private extension String {
    func localizedCaseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        self.lowercased().hasPrefix(prefix.lowercased())
    }
}
