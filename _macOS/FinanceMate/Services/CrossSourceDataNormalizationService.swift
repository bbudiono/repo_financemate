//
//  CrossSourceDataNormalizationService.swift
//  FinanceMate
//
//  Created by FinanceMate on 2025-10-07.
//  Copyright © 2025 FinanceMate. All rights reserved.
//

import Foundation
import CoreData

/// Service for normalizing data from different transaction sources
/// Implements enhanced BLUEPRINT Line 180: Cross-Source Data Normalization
@MainActor
class CrossSourceDataNormalizationService: ObservableObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Normalizes transaction fields from different data sources
    func normalizeTransactionFields(transaction: Transaction) -> NormalizedTransactionFields {
        switch transaction.source {
        case "gmail":
            return normalizeGmailData(transaction: transaction)
        case "bank":
            return normalizeBankData(transaction: transaction)
        case "manual":
            return normalizeManualData(transaction: transaction)
        default:
            return normalizeGenericData(transaction: transaction)
        }
    }

    /// Maps data between different source formats
    func mapDataSources(data: [String: Any], from sourceType: String, to targetType: String) -> [String: Any] {
        // Basic field mapping between data sources
        var mappedData: [String: Any] = [:]

        // Map common fields
        if let amount = data["amount"] {
            mappedData["amount"] = amount
        }
        if let date = data["date"] {
            mappedData["date"] = date
        }
        if let description = data["description"] {
            mappedData["description"] = description
        }

        return mappedData
    }

    /// Normalizes Gmail receipt data
    private func normalizeGmailData(transaction: Transaction) -> NormalizedTransactionFields {
        return NormalizedTransactionFields(
            merchant: extractMerchant(from: transaction.itemDescription),
            amount: transaction.amount,
            date: transaction.date,
            description: transaction.itemDescription,
            category: "Uncategorized",
            confidence: 0.8,
            source: "gmail"
        )
    }

    /// Normalizes bank transaction data
    private func normalizeBankData(transaction: Transaction) -> NormalizedTransactionFields {
        return NormalizedTransactionFields(
            merchant: extractMerchant(from: transaction.itemDescription),
            amount: transaction.amount,
            date: transaction.date,
            description: transaction.itemDescription,
            category: "Uncategorized",
            confidence: 0.9,
            source: "bank"
        )
    }

    /// Normalizes manual entry data
    private func normalizeManualData(transaction: Transaction) -> NormalizedTransactionFields {
        return NormalizedTransactionFields(
            merchant: transaction.itemDescription,
            amount: transaction.amount,
            date: transaction.date,
            description: transaction.itemDescription,
            category: "Uncategorized",
            confidence: 1.0,
            source: "manual"
        )
    }

    /// Normalizes generic data
    private func normalizeGenericData(transaction: Transaction) -> NormalizedTransactionFields {
        return NormalizedTransactionFields(
            merchant: transaction.itemDescription,
            amount: transaction.amount,
            date: transaction.date,
            description: transaction.itemDescription,
            category: "Uncategorized",
            confidence: 0.5,
            source: transaction.source
        )
    }

    /// Extracts merchant name from description
    private func extractMerchant(from description: String) -> String {
        // Simple merchant extraction - can be enhanced later
        let components = description.components(separatedBy: " ")
        return components.first ?? description
    }
}

// MARK: - Supporting Types

struct NormalizedTransactionFields {
    let merchant: String
    let amount: Double
    let date: Date
    let description: String
    let category: String
    let confidence: Double
    let source: String
}