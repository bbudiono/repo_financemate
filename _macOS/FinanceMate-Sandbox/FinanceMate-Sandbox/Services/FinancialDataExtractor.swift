//
//  FinancialDataExtractor.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Financial data extraction and categorization service for intelligent document analysis in Sandbox
* Issues & Complexity Summary: Initial TDD implementation - will fail tests to drive development
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~300
  - Core Algorithm Complexity: High
  - Dependencies: 5 New (NLP, regex patterns, financial categorization, ML classification)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: High
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 90%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 87%
* Justification for Estimates: Complex financial data extraction with NLP and pattern matching
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures comprehensive coverage of financial extraction patterns
* Last Updated: 2025-06-02
*/

import Foundation
import NaturalLanguage
import SwiftUI

// MARK: - Financial Data Extractor Service

@MainActor
public class FinancialDataExtractor: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isProcessing: Bool = false
    
    // MARK: - Configuration Properties
    
    public let supportedCategories: [ExpenseCategory] = ExpenseCategory.allCases
    
    // MARK: - Private Properties
    
    private let nlProcessor = NLTokenizer(unit: .word)
    private let processingQueue = DispatchQueue(label: "com.financemate.extraction", qos: .userInitiated)
    
    // MARK: - Initialization
    
    public init() {
        // Initialize financial data extractor
    }
    
    // MARK: - Public Methods
    
    public func extractFinancialData(from text: String, documentType: FinancialDocumentType) async -> Result<FinancialData, Error> {
        isProcessing = true
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        // Handle empty text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let emptyData = FinancialData(
                documentType: documentType,
                amounts: [],
                totalAmount: nil as String?,
                currency: Currency.usd,
                category: ExpenseCategory.other,
                vendor: nil as String?,
                documentDate: nil as String?,
                accountNumber: nil as String?,
                transactions: [] as [FinancialTransaction],
                confidence: 0.1
            )
            return .success(emptyData)
        }
        
        do {
            // Extract basic financial components
            let amounts = extractAmounts(from: text)
            let currency = detectCurrency(from: text)
            let dates = extractDates(from: text)
            let vendorInfo = extractVendorInfo(from: text)
            let category = categorizeExpense(from: text)
            
            // Extract document-specific data
            var transactions: [FinancialTransaction] = []
            var accountNumber: String?
            
            if documentType == .statement {
                transactions = extractTransactions(from: text)
                accountNumber = extractAccountNumber(from: text)
            }
            
            // Determine total amount
            let totalAmount = determineTotalAmount(from: amounts, text: text)
            
            // Calculate confidence based on extracted data quality
            let confidence = calculateExtractionConfidence(
                amounts: amounts,
                vendor: vendorInfo?.name,
                dates: dates,
                documentType: documentType
            )
            
            let financialData = FinancialData(
                documentType: documentType,
                amounts: amounts,
                totalAmount: totalAmount,
                currency: currency,
                category: category,
                vendor: vendorInfo?.name,
                documentDate: dates.first,
                accountNumber: accountNumber,
                transactions: transactions,
                confidence: confidence
            )
            
            return .success(financialData)
            
        } catch {
            return .failure(FinancialExtractionError.processingFailed)
        }
    }
    
    public func extractAmounts(from text: String) -> [String] {
        // Extract monetary amounts using regex patterns
        let patterns = [
            #"\$[\d,]+\.\d{2}"#,           // $1,234.56
            #"\$[\d,]+"#,                  // $1,234
            #"USD\s*[\d,]+\.\d{2}"#,       // USD 1234.56
            #"[\d,]+\.\d{2}\s*USD"#,       // 1234.56 USD
        ]
        
        var amounts: [String] = []
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let amount = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !amounts.contains(amount) {
                            amounts.append(amount)
                        }
                    }
                }
            }
        }
        
        return amounts
    }
    
    public func categorizeExpense(from text: String) -> ExpenseCategory {
        let lowercaseText = text.lowercased()
        
        // Business category keywords
        let businessKeywords = ["office", "supplies", "software", "subscription", "consulting", "professional", "adobe", "microsoft", "saas"]
        if businessKeywords.contains(where: lowercaseText.contains) {
            return .business
        }
        
        // Groceries category keywords
        let groceryKeywords = ["grocery", "supermarket", "whole foods", "safeway", "kroger", "market", "food", "produce"]
        if groceryKeywords.contains(where: lowercaseText.contains) {
            return .groceries
        }
        
        // Dining category keywords
        let diningKeywords = ["restaurant", "mcdonald", "starbucks", "cafe", "diner", "pizza", "delivery", "takeout"]
        if diningKeywords.contains(where: lowercaseText.contains) {
            return .dining
        }
        
        // Transportation category keywords
        let transportKeywords = ["gas", "fuel", "shell", "chevron", "mobil", "uber", "lyft", "taxi", "parking"]
        if transportKeywords.contains(where: lowercaseText.contains) {
            return .transportation
        }
        
        // Utilities category keywords
        let utilityKeywords = ["electric", "gas", "water", "utility", "power", "energy", "bill", "pge", "pacific gas"]
        if utilityKeywords.contains(where: lowercaseText.contains) {
            return .utilities
        }
        
        return .other
    }
    
    public func detectCurrency(from text: String) -> Currency {
        let lowercaseText = text.lowercased()
        
        if lowercaseText.contains("eur") || lowercaseText.contains("€") {
            return .eur
        } else if lowercaseText.contains("gbp") || lowercaseText.contains("£") {
            return .gbp
        } else {
            return .usd // Default to USD
        }
    }
    
    public func extractDates(from text: String) -> [String] {
        let datePatterns = [
            #"\d{1,2}[/-]\d{1,2}[/-]\d{2,4}"#,     // MM/DD/YYYY or MM-DD-YY
            #"\d{4}-\d{1,2}-\d{1,2}"#,              // YYYY-MM-DD
            #"[A-Za-z]+ \d{1,2}, \d{4}"#,          // Month DD, YYYY
        ]
        
        var dates: [String] = []
        
        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let date = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                        if !dates.contains(date) {
                            dates.append(date)
                        }
                    }
                }
            }
        }
        
        return dates
    }
    
    public func extractVendorInfo(from text: String) -> VendorInfo? {
        let lines = text.components(separatedBy: .newlines)
        guard !lines.isEmpty else { return nil }
        
        // Look for company name (usually first non-empty line)
        var companyName: String?
        var address: String?
        var phone: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if companyName == nil && !trimmedLine.isEmpty && !trimmedLine.lowercased().contains("invoice") && !trimmedLine.lowercased().contains("receipt") {
                companyName = trimmedLine
            } else if trimmedLine.contains("Street") || trimmedLine.contains("Ave") || trimmedLine.contains("Blvd") {
                address = trimmedLine
            } else if trimmedLine.contains("(") && trimmedLine.contains(")") && trimmedLine.contains("-") {
                phone = trimmedLine
            }
        }
        
        guard let name = companyName else { return nil }
        
        return VendorInfo(name: name, address: address, phone: phone)
    }
    
    public func extractTaxInfo(from text: String) -> TaxInfo? {
        // Extract tax information
        let taxPattern = #"[Tt]ax\s*\((\d+\.?\d*)%\)\s*[:$]?\s*(\$?[\d,]+\.\d{2})"#
        
        if let regex = try? NSRegularExpression(pattern: taxPattern, options: []) {
            let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let rateRange = Range(match.range(at: 1), in: text)
                    let amountRange = Range(match.range(at: 2), in: text)
                    
                    if let rateRange = rateRange, let amountRange = amountRange {
                        let rateString = String(text[rateRange])
                        let amountString = String(text[amountRange])
                        
                        if let rate = Double(rateString) {
                            return TaxInfo(rate: rate, amount: amountString)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Private Helper Methods
    
    private func extractTransactions(from text: String) -> [FinancialTransaction] {
        // Extract transaction data for statements
        var transactions: [FinancialTransaction] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Look for transaction patterns (date + description + amount)
            if let transactionData = parseTransactionLine(trimmedLine) {
                transactions.append(transactionData)
            }
        }
        
        return transactions
    }
    
    private func parseTransactionLine(_ line: String) -> FinancialTransaction? {
        // Parse individual transaction lines
        let datePattern = #"\d{1,2}/\d{1,2}"#
        let amountPattern = #"[+-]?\$[\d,]+\.\d{2}"#
        
        guard let dateRegex = try? NSRegularExpression(pattern: datePattern),
              let amountRegex = try? NSRegularExpression(pattern: amountPattern) else {
            return nil
        }
        
        let dateMatches = dateRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
        let amountMatches = amountRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
        
        guard let dateMatch = dateMatches.first,
              let amountMatch = amountMatches.first,
              let dateRange = Range(dateMatch.range, in: line),
              let amountRange = Range(amountMatch.range, in: line) else {
            return nil
        }
        
        let date = String(line[dateRange])
        let amount = String(line[amountRange])
        
        // Extract description (text between date and amount)
        let description = extractTransactionDescription(from: line, dateRange: dateRange, amountRange: amountRange)
        
        return FinancialTransaction(date: date, description: description, amount: amount, category: categorizeExpense(from: description))
    }
    
    private func extractTransactionDescription(from line: String, dateRange: Range<String.Index>, amountRange: Range<String.Index>) -> String {
        let startIndex = dateRange.upperBound
        let endIndex = amountRange.lowerBound
        
        if startIndex < endIndex {
            let description = String(line[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            return description
        }
        
        return "Unknown Transaction"
    }
    
    private func extractAccountNumber(from text: String) -> String? {
        let accountPattern = #"[Aa]ccount:?\s*\**(\d{4})"#
        
        if let regex = try? NSRegularExpression(pattern: accountPattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            if let match = matches.first, match.numberOfRanges >= 2 {
                if let range = Range(match.range(at: 1), in: text) {
                    return "****" + String(text[range])
                }
            }
        }
        
        return nil
    }
    
    private func determineTotalAmount(from amounts: [String], text: String) -> String? {
        // Look for explicit "total" indicators
        let totalPattern = #"[Tt]otal:?\s*(\$[\d,]+\.\d{2})"#
        
        if let regex = try? NSRegularExpression(pattern: totalPattern) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            if let match = matches.first, match.numberOfRanges >= 2 {
                if let range = Range(match.range(at: 1), in: text) {
                    return String(text[range])
                }
            }
        }
        
        // If no explicit total found, return the largest amount
        return amounts.max { amount1, amount2 in
            let value1 = extractNumericValue(from: amount1)
            let value2 = extractNumericValue(from: amount2)
            return value1 < value2
        }
    }
    
    private func extractNumericValue(from amountString: String) -> Double {
        let cleanString = amountString.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "USD", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Double(cleanString) ?? 0.0
    }
    
    private func calculateExtractionConfidence(amounts: [String], vendor: String?, dates: [String], documentType: FinancialDocumentType) -> Double {
        var confidence: Double = 0.3 // Base confidence
        
        // Increase confidence based on extracted data quality
        if !amounts.isEmpty {
            confidence += 0.3
        }
        
        if vendor != nil {
            confidence += 0.2
        }
        
        if !dates.isEmpty {
            confidence += 0.2
        }
        
        // Document type specific adjustments
        switch documentType {
        case .invoice, .receipt:
            if amounts.count >= 2 { // Subtotal + total
                confidence += 0.1
            }
        case .statement:
            if amounts.count >= 3 { // Multiple transactions
                confidence += 0.1
            }
        default:
            break
        }
        
        return min(confidence, 1.0)
    }
}

// MARK: - Supporting Data Models

public struct FinancialData {
    public let documentType: FinancialDocumentType
    public let amounts: [String]
    public let totalAmount: String?
    public let currency: Currency
    public let category: ExpenseCategory
    public let vendor: String?
    public let documentDate: String?
    public let accountNumber: String?
    public let transactions: [FinancialTransaction]
    public let confidence: Double
    
    public init(documentType: FinancialDocumentType, amounts: [String], totalAmount: String?, currency: Currency, category: ExpenseCategory, vendor: String?, documentDate: String?, accountNumber: String?, transactions: [FinancialTransaction], confidence: Double) {
        self.documentType = documentType
        self.amounts = amounts
        self.totalAmount = totalAmount
        self.currency = currency
        self.category = category
        self.vendor = vendor
        self.documentDate = documentDate
        self.accountNumber = accountNumber
        self.transactions = transactions
        self.confidence = confidence
    }
}

public struct FinancialTransaction {
    public let date: String
    public let description: String
    public let amount: String
    public let category: ExpenseCategory
    
    public init(date: String, description: String, amount: String, category: ExpenseCategory) {
        self.date = date
        self.description = description
        self.amount = amount
        self.category = category
    }
}

public struct VendorInfo {
    public let name: String
    public let address: String?
    public let phone: String?
    
    public init(name: String, address: String?, phone: String?) {
        self.name = name
        self.address = address
        self.phone = phone
    }
}

public struct TaxInfo {
    public let rate: Double
    public let amount: String
    
    public init(rate: Double, amount: String) {
        self.rate = rate
        self.amount = amount
    }
}

public enum ExpenseCategory: String, CaseIterable {
    case groceries = "Groceries"
    case dining = "Dining"
    case transportation = "Transportation"
    case utilities = "Utilities"
    case business = "Business"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case travel = "Travel"
    case officeExpenses = "Office Expenses"
    case software = "Software"
    case consulting = "Consulting"
    case other = "Other"
    
    public var icon: String {
        switch self {
        case .groceries: return "cart"
        case .dining: return "fork.knife"
        case .transportation: return "car"
        case .utilities: return "bolt"
        case .business: return "briefcase"
        case .healthcare: return "cross.case"
        case .entertainment: return "tv"
        case .shopping: return "bag"
        case .travel: return "airplane"
        case .officeExpenses: return "building.2"
        case .software: return "app.badge"
        case .consulting: return "person.badge.plus"
        case .other: return "questionmark.circle"
        }
    }
    
    public var color: Color {
        switch self {
        case .groceries: return .green
        case .dining: return .orange
        case .transportation: return .blue
        case .utilities: return .yellow
        case .business: return .purple
        case .healthcare: return .red
        case .entertainment: return .pink
        case .shopping: return .indigo
        case .travel: return .teal
        case .officeExpenses: return .brown
        case .software: return .cyan
        case .consulting: return .mint
        case .other: return .gray
        }
    }
}

public enum Currency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    
    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        }
    }
}

public enum FinancialDocumentType: String, CaseIterable {
    case invoice = "invoice"
    case receipt = "receipt"
    case statement = "statement"
    case contract = "contract"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .statement: return "Statement"
        case .contract: return "Contract"
        case .other: return "Other"
        }
    }
}

public enum FinancialExtractionError: Error, LocalizedError {
    case emptyText
    case processingFailed
    case invalidFormat
    case noFinancialDataFound
    
    public var errorDescription: String? {
        switch self {
        case .emptyText:
            return "No text provided for extraction"
        case .processingFailed:
            return "Financial data extraction failed"
        case .invalidFormat:
            return "Invalid document format for financial extraction"
        case .noFinancialDataFound:
            return "No financial data found in document"
        }
    }
}