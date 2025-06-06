// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialPatternMatchingService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Atomic service for pattern matching and data extraction from financial text
* Scope: Single responsibility - regex patterns and financial data parsing
* Dependencies: Foundation only
* Testing: Comprehensive unit tests with various financial formats
* Integration: Part of FinancialDocumentProcessor modularization
*/

import Foundation

// MARK: - Financial Pattern Matching Service

public class FinancialPatternMatchingService {
    
    // MARK: - Properties
    
    private let currencyFormatter: NumberFormatter
    private let dateDetector: NSDataDetector
    
    // MARK: - Initialization
    
    public init() {
        // Configure currency formatter
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter.numberStyle = .currency
        self.currencyFormatter.currencyCode = "USD"
        
        // Configure date detector
        self.dateDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
    }
    
    // MARK: - Amount Extraction
    
    /// Extracts all monetary amounts from text
    /// - Parameter text: The text to analyze
    /// - Returns: Array of extracted amounts sorted by value (largest first)
    public func extractAmounts(from text: String) -> [ExtractedAmount] {
        var amounts: [ExtractedAmount] = []
        
        let patterns = [
            #"\$[\d,]+\.?\d*"#,              // $1,234.56
            #"USD\s*[\d,]+\.?\d*"#,          // USD 1234.56
            #"[\d,]+\.?\d*\s*USD"#,          // 1234.56 USD
            #"\b\d{1,3}(?:,\d{3})*(?:\.\d{2})?\b"#  // 1,234.56
        ]
        
        for pattern in patterns {
            amounts.append(contentsOf: extractAmountsWithPattern(text: text, pattern: pattern))
        }
        
        // Remove duplicates and sort by value
        let uniqueAmounts = removeDuplicateAmounts(amounts)
        return uniqueAmounts.sorted { $0.value > $1.value }
    }
    
    /// Parses a monetary amount string into structured data
    /// - Parameter amountString: The amount string to parse
    /// - Returns: ExtractedAmount if parsing succeeds, nil otherwise
    public func parseAmount(from amountString: String) -> ExtractedAmount? {
        let cleanedString = amountString
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "USD", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        guard let value = Double(cleanedString) else { return nil }
        
        return ExtractedAmount(
            value: value,
            currency: extractCurrency(from: amountString) ?? "USD",
            formattedString: amountString.trimmingCharacters(in: .whitespaces)
        )
    }
    
    // MARK: - Date Extraction
    
    /// Extracts all dates from text with context classification
    /// - Parameter text: The text to analyze
    /// - Returns: Array of extracted dates with their types and context
    public func extractDates(from text: String) -> [ExtractedDate] {
        var financialDates: [ExtractedDate] = []
        let matches = dateDetector.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches {
            if let date = match.date,
               let range = Range(match.range, in: text) {
                let context = String(text[range])
                let dateType = classifyDateType(context: context, fullText: text)
                
                financialDates.append(ExtractedDate(
                    date: date,
                    type: dateType,
                    context: context
                ))
            }
        }
        
        return financialDates
    }
    
    /// Classifies the type of a date based on surrounding context
    /// - Parameters:
    ///   - context: The immediate context around the date
    ///   - fullText: The full text for additional context
    /// - Returns: The classified date type
    public func classifyDateType(context: String, fullText: String) -> ExtractedDateType {
        let lowerContext = context.lowercased()
        let lowerFullText = fullText.lowercased()
        
        if lowerContext.contains("due") || lowerFullText.contains("due date") {
            return .dueDate
        } else if lowerContext.contains("invoice") || lowerFullText.contains("invoice date") {
            return .invoiceDate
        } else if lowerContext.contains("service") || lowerFullText.contains("service date") {
            return .serviceDate
        } else if lowerContext.contains("payment") {
            return .paymentDate
        } else {
            return .transactionDate
        }
    }
    
    // MARK: - Vendor and Customer Extraction
    
    /// Extracts vendor information from text
    /// - Parameters:
    ///   - text: The text to analyze
    ///   - documentType: The type of document for context
    /// - Returns: Array of extracted vendors
    public func extractVendors(from text: String, documentType: ProcessedDocumentType) -> [ExtractedVendor] {
        var vendors: [ExtractedVendor] = []
        
        let patterns = [
            #"(?:FROM|BILL TO|VENDOR):\s*([^\n]+)"#,
            #"^([A-Z][A-Za-z\s&]+(?:LLC|Inc|Corp|Co\.)?)"#
        ]
        
        for pattern in patterns {
            vendors.append(contentsOf: extractVendorsWithPattern(text: text, pattern: pattern))
        }
        
        return removeDuplicateVendors(vendors)
    }
    
    /// Extracts customer information from text
    /// - Parameter text: The text to analyze
    /// - Returns: Customer information if found
    public func extractCustomer(from text: String) -> ExtractedCustomer? {
        let customerPattern = #"(?:Bill To|Customer):\s*([^\n]+)"#
        let regex = try! NSRegularExpression(pattern: customerPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let customerName = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return ExtractedCustomer(name: customerName, address: nil, email: nil)
        }
        
        return nil
    }
    
    // MARK: - Document-Specific Patterns
    
    /// Extracts invoice number from text
    /// - Parameter text: The text to analyze
    /// - Returns: Invoice number if found
    public func extractInvoiceNumber(from text: String) -> String? {
        let patterns = [
            #"(?:Invoice|INV)(?:\s*#?):\s*([A-Z0-9-]+)"#,
            #"Invoice\s+Number:\s*([A-Z0-9-]+)"#,
            #"#([A-Z0-9-]{4,})"#
        ]
        
        for pattern in patterns {
            if let result = extractFirstMatch(text: text, pattern: pattern) {
                return result
            }
        }
        
        return nil
    }
    
    /// Extracts payment terms from text
    /// - Parameter text: The text to analyze
    /// - Returns: Payment terms if found
    public func extractPaymentTerms(from text: String) -> String? {
        let patterns = [
            #"(?:Payment Terms|Terms):\s*([^\n]+)"#,
            #"Net\s+(\d+)"#,
            #"Due\s+in\s+(\d+)\s+days"#
        ]
        
        for pattern in patterns {
            if let result = extractFirstMatch(text: text, pattern: pattern) {
                return result
            }
        }
        
        return nil
    }
    
    /// Extracts tax information from text
    /// - Parameter text: The text to analyze
    /// - Returns: Tax information structure
    public func extractTaxInformation(from text: String) -> ExtractedTaxInfo {
        let taxAmount = extractTaxAmount(from: text)
        let taxRate = extractTaxRate(from: text)
        let taxId = extractTaxId(from: text)
        let isTaxExempt = text.lowercased().contains("tax exempt")
        
        return ExtractedTaxInfo(
            taxAmount: taxAmount,
            taxRate: taxRate,
            taxId: taxId,
            isTaxExempt: isTaxExempt
        )
    }
    
    /// Extracts currency code from text
    /// - Parameter text: The text to analyze
    /// - Returns: Currency code if found, defaults to USD
    public func extractCurrency(from text: String) -> String? {
        let currencyPattern = #"([A-Z]{3})\s*[\d,]+"#
        let regex = try! NSRegularExpression(pattern: currencyPattern)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range])
        }
        
        return nil
    }
    
    // MARK: - Utility Methods
    
    /// Finds likely subtotal from array of amounts
    /// - Parameter amounts: Array of extracted amounts
    /// - Returns: Most likely subtotal amount
    public func findSubTotal(in amounts: [ExtractedAmount]) -> ExtractedAmount? {
        // Usually the second largest amount is subtotal
        return amounts.count > 1 ? amounts[1] : nil
    }
    
    /// Extracts discount amount from text
    /// - Parameter text: The text to analyze
    /// - Returns: Discount amount if found
    public func extractDiscountAmount(from text: String) -> ExtractedAmount? {
        let discountPattern = #"(?:Discount|Savings):\s*\$?([\d,]+\.?\d*)"#
        let regex = try! NSRegularExpression(pattern: discountPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let amountString = String(text[range])
            return parseAmount(from: amountString)
        }
        
        return nil
    }
    
    // MARK: - Private Helper Methods
    
    private func extractAmountsWithPattern(text: String, pattern: String) -> [ExtractedAmount] {
        var amounts: [ExtractedAmount] = []
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                let amountString = String(text[range])
                if let amount = parseAmount(from: amountString) {
                    amounts.append(amount)
                }
            }
        }
        
        return amounts
    }
    
    private func extractVendorsWithPattern(text: String, pattern: String) -> [ExtractedVendor] {
        var vendors: [ExtractedVendor] = []
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .caseInsensitive])
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        for match in matches {
            if match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: text) {
                let vendorName = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !vendorName.isEmpty && vendorName.count > 2 {
                    vendors.append(ExtractedVendor(
                        name: vendorName,
                        address: extractVendorAddress(near: vendorName, in: text),
                        taxId: extractTaxId(from: text)
                    ))
                }
            }
        }
        
        return vendors
    }
    
    private func extractVendorAddress(near vendorName: String, in text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if line.contains(vendorName) && index + 1 < lines.count {
                let nextLine = lines[index + 1].trimmingCharacters(in: .whitespaces)
                let addressPattern = #"\d+.*(?:St|Ave|Rd|Dr|Blvd)"#
                let regex = try! NSRegularExpression(pattern: addressPattern, options: .caseInsensitive)
                let range = NSRange(nextLine.startIndex..., in: nextLine)
                if regex.firstMatch(in: nextLine, range: range) != nil {
                    return nextLine
                }
            }
        }
        
        return nil
    }
    
    private func extractTaxAmount(from text: String) -> ExtractedAmount? {
        let taxAmountPattern = #"(?:Tax|VAT|GST):\s*\$?([\d,]+\.?\d*)"#
        let regex = try! NSRegularExpression(pattern: taxAmountPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            let amountString = String(text[range])
            return parseAmount(from: amountString)
        }
        
        return nil
    }
    
    private func extractTaxRate(from text: String) -> Double? {
        let taxRatePattern = #"(\d+(?:\.\d+)?)\s*%"#
        let regex = try! NSRegularExpression(pattern: taxRatePattern)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           let range = Range(match.range(at: 1), in: text) {
            let rateString = String(text[range])
            return Double(rateString)
        }
        
        return nil
    }
    
    private func extractTaxId(from text: String) -> String? {
        let taxIdPattern = #"(?:Tax ID|TIN|EIN):\s*(\d{2}-\d{7})"#
        let regex = try! NSRegularExpression(pattern: taxIdPattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range])
        }
        
        return nil
    }
    
    private func extractFirstMatch(text: String, pattern: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        
        if let match = matches.first,
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: text) {
            return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    private func removeDuplicateAmounts(_ amounts: [ExtractedAmount]) -> [ExtractedAmount] {
        var uniqueAmounts: [ExtractedAmount] = []
        var seenValues: Set<Double> = []
        
        for amount in amounts {
            if !seenValues.contains(amount.value) {
                uniqueAmounts.append(amount)
                seenValues.insert(amount.value)
            }
        }
        
        return uniqueAmounts
    }
    
    private func removeDuplicateVendors(_ vendors: [ExtractedVendor]) -> [ExtractedVendor] {
        var uniqueVendors: [ExtractedVendor] = []
        var seenNames: Set<String> = []
        
        for vendor in vendors {
            let normalizedName = vendor.name.lowercased().trimmingCharacters(in: .whitespaces)
            if !seenNames.contains(normalizedName) {
                uniqueVendors.append(vendor)
                seenNames.insert(normalizedName)
            }
        }
        
        return uniqueVendors
    }
}