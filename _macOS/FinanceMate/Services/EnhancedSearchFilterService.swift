//
//  EnhancedSearchFilterService.swift
//  FinanceMate
//
//  Created by FinanceMate on 2025-10-07.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation
import CoreData

/// Service for enhanced search and filter accuracy across transaction data
/// Implements BLUEPRINT Line 181: Enhanced search & filter accuracy
@MainActor
class EnhancedSearchFilterService: ObservableObject {

    private let context: NSManagedObjectContext
    private var searchIndex: [String: [Transaction]] = [:]

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Search across all transaction fields with real extracted descriptions
    func searchAcrossAllFields(query: String) -> [Transaction] {
        let lowercasedQuery = query.lowercased()

        // Check search index first for performance
        if let indexedResults = searchIndex[lowercasedQuery] {
            return indexedResults
        }

        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "itemDescription CONTAINS[cd] %@ OR source CONTAINS[cd] %@", query, query)

        do {
            let results = try context.fetch(request)
            // Cache results for performance
            searchIndex[lowercasedQuery] = results
            return results
        } catch {
            print("Error searching transactions: \(error)")
            return []
        }
    }

    /// Search specifically in real extracted Gmail descriptions
    func realDescriptionSearch(query: String) -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")

        // Focus on Gmail transactions with real extracted descriptions
        let gmailPredicate = NSPredicate(format: "source == %@", "gmail")
        let descriptionPredicate = NSPredicate(format: "itemDescription CONTAINS[cd] %@", query)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [gmailPredicate, descriptionPredicate])

        do {
            return try context.fetch(request)
        } catch {
            print("Error searching Gmail descriptions: \(error)")
            return []
        }
    }

    /// Cross-source field searching with source-specific optimization
    func crossSourceFieldSearch(query: String) -> [Transaction] {
        var allResults: [Transaction] = []

        // Search Gmail receipts with higher priority
        let gmailResults = realDescriptionSearch(query: query)
        allResults.append(contentsOf: gmailResults)

        // Search bank transactions
        let bankResults = searchInSource(source: "bank", query: query)
        allResults.append(contentsOf: bankResults)

        // Search manual entries
        let manualResults = searchInSource(source: "manual", query: query)
        allResults.append(contentsOf: manualResults)

        // Remove duplicates while preserving order
        let uniqueResults = Array(NSOrderedSet(array: allResults)).compactMap { $0 as? Transaction }
        return uniqueResults
    }

    /// Optimize search indexing for performance with large datasets
    func indexingOptimization(transactions: [Transaction]) {
        // Clear existing index
        searchIndex.removeAll()

        // Build search index from keywords in descriptions
        for transaction in transactions {
            let keywords = extractKeywords(from: transaction.itemDescription)
            for keyword in keywords {
                if searchIndex[keyword] == nil {
                    searchIndex[keyword] = []
                }
                searchIndex[keyword]?.append(transaction)
            }
        }

        print("Search indexing optimized with \(searchIndex.count) keywords")
    }

    /// Search within a specific data source
    private func searchInSource(source: String, query: String) -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "source == %@", source),
            NSPredicate(format: "itemDescription CONTAINS[cd] %@", query)
        ])

        do {
            return try context.fetch(request)
        } catch {
            print("Error searching in source \(source): \(error)")
            return []
        }
    }

    /// Extract searchable keywords from transaction descriptions
    private func extractKeywords(from description: String) -> [String] {
        let keywords = description.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count >= 3 } // Only keep words with 3+ characters
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }

        // Remove duplicates
        return Array(Set(keywords))
    }

    /// Clear search index (call when data changes)
    func clearSearchIndex() {
        searchIndex.removeAll()
    }
}

// MARK: - Search Performance Metrics

struct SearchPerformanceMetrics {
    let queryCount: Int
    let averageResponseTime: Double
    let cacheHitRate: Double
    let indexedTransactions: Int
}