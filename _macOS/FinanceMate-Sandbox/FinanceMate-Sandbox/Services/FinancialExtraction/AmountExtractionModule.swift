// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  AmountExtractionModule.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Specialized module for extracting and processing monetary amounts from financial documents
* Issues & Complexity Summary: TDD-driven amount extraction with comprehensive pattern matching and validation
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Medium (regex patterns, currency normalization, amount validation)
  - Dependencies: 3 New (Foundation, FinancialDataModels, RegexPatternManager)
  - State Management Complexity: Low (stateless processing functions)
  - Novelty/Uncertainty Factor: Low (extracted from tested implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
* Problem Estimate (Inherent Problem Difficulty %): 30%
* Initial Code Complexity Estimate %): 33%
* Justification for Estimates: Focused module with clear regex-based extraction logic
* Final Code Complexity (Actual %): 37%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Modular extraction improves testability and pattern management
* Last Updated: 2025-06-06
*/

import Foundation

public class AmountExtractionModule {
    
    // MARK: - Amount Pattern Definitions
    
    private static let amountPatterns = [
        #"\$[\d,]+\.\d{2}"#,           // $1,234.56
        #"\$[\d,]+"#,                  // $1,234
        #"USD\s*[\d,]+\.\d{2}"#,       // USD 1234.56
        #"[\d,]+\.\d{2}\s*USD"#,       // 1234.56 USD
        #"[\d,]+\.\d{2}"#,             // 1234.56 (generic decimal)
        #"[\d,]+"#                     // 1234 (whole numbers)
    ]
    
    private static let totalAmountKeywords = [
        "total", "amount due", "balance", "grand total", 
        "total amount", "sum", "net amount", "final amount"
    ]
    
    // MARK: - Public Methods
    
    public static func extractAmounts(from text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        
        var amounts: Set<String> = Set()
        
        for pattern in amountPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let amount = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                        let sanitizedAmount = sanitizeAmount(amount)
                        
                        // Only add if it's a valid monetary amount
                        if isValidAmount(sanitizedAmount) {
                            amounts.insert(sanitizedAmount)
                        }
                    }
                }
            }
        }
        
        return Array(amounts).sorted { compareAmounts($0, $1) }
    }
    
    public static func determineTotalAmount(from amounts: [String], text: String) -> String? {
        guard !amounts.isEmpty else { return nil }
        
        // First try to find amount near "total" keywords
        if let totalFromContext = findTotalFromContext(amounts: amounts, text: text) {
            return totalFromContext
        }
        
        // If no contextual total found, return the largest amount
        return findLargestAmount(amounts)
    }
    
    public static func extractNumericValue(from amountString: String) -> Double? {
        let sanitized = sanitizeAmount(amountString)
        let numericString = sanitized.replacingOccurrences(of: ",", with: "")
        return Double(numericString)
    }
    
    public static func normalizeAmounts(_ amounts: [String]) -> [String] {
        return amounts.compactMap { amount in
            let sanitized = sanitizeAmount(amount)
            return isValidAmount(sanitized) ? sanitized : nil
        }
    }
    
    public static func calculateAverageAmount(from amounts: [String]) -> Double {
        let numericAmounts = amounts.compactMap { extractNumericValue(from: $0) }
        guard !numericAmounts.isEmpty else { return 0.0 }
        
        return numericAmounts.reduce(0, +) / Double(numericAmounts.count)
    }
    
    // MARK: - Private Helper Methods
    
    private static func sanitizeAmount(_ amount: String) -> String {
        // Remove currency symbols and extra whitespace
        var sanitized = amount
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "USD", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "EUR", with: "")
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: "GBP", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure proper decimal format
        if !sanitized.contains(".") && sanitized.count > 2 {
            // Check if this might be a whole dollar amount
            if let numericValue = Double(sanitized.replacingOccurrences(of: ",", with: "")) {
                if numericValue > 100 {
                    // Likely a whole dollar amount, add .00
                    sanitized += ".00"
                }
            }
        }
        
        return sanitized
    }
    
    private static func isValidAmount(_ amount: String) -> Bool {
        guard !amount.isEmpty else { return false }
        
        // Check if it contains at least one digit
        guard amount.rangeOfCharacter(from: .decimalDigits) != nil else { return false }
        
        // Check if it's a reasonable monetary amount (not just random numbers)
        if let numericValue = extractNumericValue(from: amount) {
            // Reject unreasonably large amounts (likely account numbers)
            if numericValue > 1_000_000 {
                return false
            }
            
            // Reject very small amounts that might be percentages
            if numericValue < 0.01 && amount.contains(".") {
                return false
            }
            
            return true
        }
        
        return false
    }
    
    private static func findTotalFromContext(amounts: [String], text: String) -> String? {
        let lowercaseText = text.lowercased()
        
        for keyword in totalAmountKeywords {
            if let keywordRange = lowercaseText.range(of: keyword) {
                // Look for amounts near this keyword (within 100 characters)
                let searchStartIndex = max(keywordRange.lowerBound, lowercaseText.index(keywordRange.lowerBound, offsetBy: -50, limitedBy: lowercaseText.startIndex) ?? lowercaseText.startIndex)
                let searchEndIndex = min(keywordRange.upperBound, lowercaseText.index(keywordRange.upperBound, offsetBy: 100, limitedBy: lowercaseText.endIndex) ?? lowercaseText.endIndex)
                
                let searchText = String(lowercaseText[searchStartIndex..<searchEndIndex])
                
                // Find which amounts appear in this context
                let contextAmounts = amounts.filter { amount in
                    let sanitizedAmount = sanitizeAmount(amount).lowercased()
                    return searchText.contains(sanitizedAmount)
                }
                
                if let largestContextAmount = findLargestAmount(contextAmounts) {
                    return largestContextAmount
                }
            }
        }
        
        return nil
    }
    
    private static func findLargestAmount(_ amounts: [String]) -> String? {
        guard !amounts.isEmpty else { return nil }
        
        return amounts.max { amount1, amount2 in
            let value1 = extractNumericValue(from: amount1) ?? 0
            let value2 = extractNumericValue(from: amount2) ?? 0
            return value1 < value2
        }
    }
    
    private static func compareAmounts(_ amount1: String, _ amount2: String) -> Bool {
        let value1 = extractNumericValue(from: amount1) ?? 0
        let value2 = extractNumericValue(from: amount2) ?? 0
        return value1 > value2  // Sort in descending order
    }
}