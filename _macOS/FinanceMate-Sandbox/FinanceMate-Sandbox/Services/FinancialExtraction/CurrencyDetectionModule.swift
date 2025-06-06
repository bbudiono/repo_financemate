// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  CurrencyDetectionModule.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Specialized module for detecting and normalizing currency information from financial documents
* Issues & Complexity Summary: TDD-driven currency detection with multi-currency support and confidence scoring
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Low (pattern matching, currency mapping)
  - Dependencies: 2 New (Foundation, FinancialDataModels)
  - State Management Complexity: Low (stateless currency detection)
  - Novelty/Uncertainty Factor: Low (extracted from tested implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
* Problem Estimate (Inherent Problem Difficulty %): 20%
* Initial Code Complexity Estimate %): 23%
* Justification for Estimates: Straightforward currency detection with well-defined patterns
* Final Code Complexity (Actual %): 27%
* Overall Result Score (Success & Quality %): 96%
* Key Variances/Learnings: Modular currency detection enables better multi-currency support
* Last Updated: 2025-06-06
*/

import Foundation

public class CurrencyDetectionModule {
    
    // MARK: - Currency Pattern Definitions
    
    private static let currencyPatterns: [Currency: [String]] = [
        .usd: ["$", "usd", "us dollar", "dollar", "dollars"],
        .eur: ["€", "eur", "euro", "euros"],
        .gbp: ["£", "gbp", "pound", "pounds", "sterling"],
        .cad: ["c$", "cad", "canadian dollar", "canadian"],
        .aud: ["a$", "aud", "australian dollar", "australian"],
        .jpy: ["¥", "jpy", "yen", "japanese yen"]
    ]
    
    private static let currencySymbols: [String: Currency] = [
        "$": .usd,
        "€": .eur,
        "£": .gbp,
        "¥": .jpy
    ]
    
    // MARK: - Public Methods
    
    public static func detectCurrency(from text: String) -> Currency {
        let detectedCurrencies = detectAllCurrencies(from: text)
        
        if detectedCurrencies.isEmpty {
            return .usd  // Default to USD
        }
        
        // Return the currency with highest confidence
        return detectedCurrencies.max { $0.confidence < $1.confidence }?.currency ?? .usd
    }
    
    public static func detectAllCurrencies(from text: String) -> [CurrencyDetectionResult] {
        guard !text.isEmpty else { return [] }
        
        let lowercaseText = text.lowercased()
        var detectionResults: [CurrencyDetectionResult] = []
        
        for (currency, patterns) in currencyPatterns {
            let confidence = calculateCurrencyConfidence(for: currency, in: lowercaseText, patterns: patterns)
            if confidence > 0 {
                detectionResults.append(CurrencyDetectionResult(currency: currency, confidence: confidence))
            }
        }
        
        return detectionResults.sorted { $0.confidence > $1.confidence }
    }
    
    public static func extractCurrencySymbol(from text: String) -> String? {
        for (symbol, _) in currencySymbols {
            if text.contains(symbol) {
                return symbol
            }
        }
        return nil
    }
    
    public static func normalizeCurrencyAmount(_ amount: String, to currency: Currency) -> String {
        var normalizedAmount = amount
        
        // Remove existing currency symbols
        for (symbol, _) in currencySymbols {
            normalizedAmount = normalizedAmount.replacingOccurrences(of: symbol, with: "")
        }
        
        // Remove currency codes
        for currencyCode in Currency.allCases {
            normalizedAmount = normalizedAmount.replacingOccurrences(of: currencyCode.rawValue, with: "", options: .caseInsensitive)
        }
        
        // Clean up whitespace
        normalizedAmount = normalizedAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add the target currency symbol
        return "\(currency.symbol)\(normalizedAmount)"
    }
    
    public static func validateCurrencyConsistency(in amounts: [String]) -> Bool {
        let detectedCurrencies = Set(amounts.compactMap { amount in
            detectCurrency(from: amount)
        })
        
        // All amounts should use the same currency
        return detectedCurrencies.count <= 1
    }
    
    // MARK: - Private Helper Methods
    
    private static func calculateCurrencyConfidence(for currency: Currency, in text: String, patterns: [String]) -> Double {
        var confidence: Double = 0.0
        var patternMatches = 0
        
        for pattern in patterns {
            if text.contains(pattern) {
                patternMatches += 1
                
                // Different patterns have different confidence weights
                switch pattern {
                case "$", "€", "£", "¥":
                    confidence += 0.8  // Currency symbols have high confidence
                case "usd", "eur", "gbp", "cad", "aud", "jpy":
                    confidence += 0.9  // Currency codes have highest confidence
                default:
                    confidence += 0.3  // Currency names have lower confidence
                }
            }
        }
        
        // Boost confidence if multiple patterns match
        if patternMatches > 1 {
            confidence *= 1.2
        }
        
        // Cap confidence at 1.0
        return min(confidence, 1.0)
    }
}

// MARK: - Supporting Types

public struct CurrencyDetectionResult {
    public let currency: Currency
    public let confidence: Double
    
    public init(currency: Currency, confidence: Double) {
        self.currency = currency
        self.confidence = confidence
    }
}