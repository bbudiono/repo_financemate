import Foundation
import CoreData

/// Currency Exchange Service - Minimal Implementation
/// Handles FX conversion with historical rates and Core Data storage
class CurrencyExchangeService {
    private let context: NSManagedObjectContext
    private var rateCache: [String: Double] = [:]

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Get exchange rate for currency pair on specific date
    func getExchangeRate(from: String, to: String, date: Date) throws -> Double {
        let cacheKey = "\(from)-\(to)-\(date.timeIntervalSince1970)"

        // Check cache first
        if let cachedRate = rateCache[cacheKey] {
            return cachedRate
        }

        // Get rate (mock implementation for now)
        let rate = fetchMockRate(from: from, to: to, date: date)
        rateCache[cacheKey] = rate
        return rate
    }

    /// Convert amount using historical exchange rate
    func convertAmount(_ amount: Double, from: String, to: String, date: Date) throws -> Double {
        let rate = try getExchangeRate(from: from, to: to, date: date)
        return amount * rate
    }

    /// Convert and store transaction amounts
    func convertAndStoreTransaction(_ transaction: NSManagedObject) throws {
        guard let originalAmount = transaction.value(forKey: "originalAmount") as? Double,
              let originalCurrency = transaction.value(forKey: "originalCurrency") as? String,
              let transactionDate = transaction.value(forKey: "date") as? Date else {
            return
        }

        // If original currency is AUD, no conversion needed
        if originalCurrency == "AUD" {
            transaction.setValue(originalAmount, forKey: "amount")
            return
        }

        // Convert to AUD
        let convertedAmount = try convertAmount(
            originalAmount,
            from: originalCurrency,
            to: "AUD",
            date: transactionDate
        )

        // Store converted amount
        transaction.setValue(convertedAmount, forKey: "amount")
    }

    /// Mock exchange rate fetcher (minimal implementation)
    private func fetchMockRate(from: String, to: String, date: Date) -> Double {
        // Simple mock rates for common currencies
        let rates: [String: Double] = [
            "USD-AUD": 1.5,
            "EUR-AUD": 1.65,
            "GBP-AUD": 1.95,
            "JPY-AUD": 0.010,
            "CAD-AUD": 1.10
        ]

        let key = "\(from)-\(to)"
        return rates[key] ?? 1.0 // Default to 1.0 if rate not found
    }
}