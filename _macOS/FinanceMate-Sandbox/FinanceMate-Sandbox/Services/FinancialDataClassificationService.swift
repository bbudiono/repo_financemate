// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialDataClassificationService.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Atomic service for classifying and categorizing financial data
* Scope: Single responsibility - expense categorization and line item extraction
* Dependencies: Foundation only
* Testing: Comprehensive unit tests with various financial categories
* Integration: Part of FinancialDocumentProcessor modularization
*/

import Foundation

// MARK: - Financial Data Classification Service

public class FinancialDataClassificationService {
    
    // MARK: - Properties
    
    private let categoryKeywords: [ExtractedExpenseCategory: [String]]
    
    // MARK: - Initialization
    
    public init() {
        self.categoryKeywords = [
            .office: ["office", "supplies", "paper", "pen", "stapler", "desk", "stationery", "folder", "binder"],
            .travel: ["flight", "hotel", "uber", "taxi", "mileage", "airfare", "lodging", "car rental", "train", "bus"],
            .meals: ["restaurant", "lunch", "dinner", "coffee", "food", "catering", "meal", "dining", "breakfast"],
            .utilities: ["electric", "gas", "water", "internet", "phone", "utility", "electricity", "cellular", "wifi"],
            .software: ["software", "subscription", "saas", "license", "app", "cloud", "hosting", "domain"],
            .marketing: ["advertising", "marketing", "promotion", "campaign", "social media", "ads", "branding"],
            .professional: ["legal", "accounting", "consulting", "professional services", "attorney", "consultant"],
            .equipment: ["computer", "laptop", "printer", "equipment", "hardware", "monitor", "keyboard", "mouse"],
            .maintenance: ["repair", "maintenance", "cleaning", "service", "fix", "upkeep", "janitorial"],
            .insurance: ["insurance", "premium", "coverage", "policy", "liability", "health insurance"]
        ]
    }
    
    // MARK: - Public Methods
    
    /// Classifies expense categories from text content
    /// - Parameter text: The text to analyze for expense categories
    /// - Returns: Array of detected expense categories
    public func classifyExpenseCategories(from text: String) -> [ExtractedExpenseCategory] {
        let lowerText = text.lowercased()
        var detectedCategories: Set<ExtractedExpenseCategory> = []
        
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if lowerText.contains(keyword) {
                    detectedCategories.insert(category)
                    break // Found one keyword for this category, move to next category
                }
            }
        }
        
        return detectedCategories.isEmpty ? [.other] : Array(detectedCategories).sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Extracts and classifies line items from text
    /// - Parameter text: The text to analyze for line items
    /// - Returns: Array of extracted line items with classifications
    public func extractLineItems(from text: String) -> [ExtractedLineItem] {
        var lineItems: [ExtractedLineItem] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            if let lineItem = parseLineItem(from: line) {
                lineItems.append(lineItem)
            }
        }
        
        return lineItems
    }
    
    /// Classifies a single item description into an expense category
    /// - Parameter description: The item description to classify
    /// - Returns: The most appropriate expense category
    public func classifyItemCategory(description: String) -> ExtractedExpenseCategory {
        let lowerDescription = description.lowercased()
        
        // Check each category for keyword matches
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if lowerDescription.contains(keyword) {
                    return category
                }
            }
        }
        
        // If no specific category found, return other
        return .other
    }
    
    /// Analyzes text to determine confidence level for expense categorization
    /// - Parameter text: The text to analyze
    /// - Returns: Confidence score between 0.0 and 1.0
    public func getCategorizationConfidence(for text: String) -> Double {
        let categories = classifyExpenseCategories(from: text)
        let lineItems = extractLineItems(from: text)
        
        var confidence = 0.0
        
        // Base confidence for having categories
        if !categories.isEmpty && categories != [.other] {
            confidence += 0.4
        }
        
        // Additional confidence for specific line items
        if !lineItems.isEmpty {
            confidence += 0.3
        }
        
        // Confidence based on text length and content richness
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        if wordCount > 50 {
            confidence += 0.2
        } else if wordCount > 20 {
            confidence += 0.1
        }
        
        return min(confidence, 1.0)
    }
    
    /// Gets category suggestions based on vendor name
    /// - Parameter vendorName: The vendor name to analyze
    /// - Returns: Array of suggested categories for the vendor
    public func suggestCategoriesForVendor(_ vendorName: String) -> [ExtractedExpenseCategory] {
        let lowerVendorName = vendorName.lowercased()
        var suggestions: Set<ExtractedExpenseCategory> = []
        
        // Vendor-specific patterns
        let vendorPatterns: [ExtractedExpenseCategory: [String]] = [
            .travel: ["airline", "hotel", "motel", "car rental", "hertz", "avis", "hilton", "marriott"],
            .meals: ["restaurant", "cafe", "bistro", "grill", "pizza", "starbucks", "mcdonald"],
            .utilities: ["electric", "gas company", "telecom", "internet", "verizon", "att"],
            .software: ["microsoft", "adobe", "google", "amazon", "apple", "dropbox"],
            .office: ["office depot", "staples", "costco", "walmart", "target"],
            .professional: ["law firm", "accounting", "cpa", "consulting", "legal"],
            .equipment: ["best buy", "apple store", "dell", "hp", "lenovo"],
            .insurance: ["insurance", "allstate", "state farm", "geico"]
        ]
        
        for (category, patterns) in vendorPatterns {
            for pattern in patterns {
                if lowerVendorName.contains(pattern) {
                    suggestions.insert(category)
                }
            }
        }
        
        return suggestions.isEmpty ? [.other] : Array(suggestions).sorted { $0.rawValue < $1.rawValue }
    }
    
    /// Validates if a line appears to contain a valid financial line item
    /// - Parameter line: The line of text to validate
    /// - Returns: True if the line appears to be a valid line item
    public func isValidLineItem(_ line: String) -> Bool {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Minimum length check
        guard trimmedLine.count > 5 else { return false }
        
        // Should contain at least one number (quantity or amount)
        let numberPattern = #"\d+(?:\.\d+)?"#
        let numberRegex = try! NSRegularExpression(pattern: numberPattern)
        let numberMatches = numberRegex.matches(in: trimmedLine, range: NSRange(trimmedLine.startIndex..., in: trimmedLine))
        
        guard !numberMatches.isEmpty else { return false }
        
        // Should not be a header or total line
        let excludePatterns = ["total", "subtotal", "tax", "discount", "description", "qty", "amount", "price"]
        let lowerLine = trimmedLine.lowercased()
        
        for pattern in excludePatterns {
            if lowerLine.hasPrefix(pattern) {
                return false
            }
        }
        
        return true
    }
    
    /// Extracts category keywords that were found in the text
    /// - Parameters:
    ///   - text: The text to analyze
    ///   - category: The specific category to check
    /// - Returns: Array of keywords found for the specified category
    public func getFoundKeywords(in text: String, for category: ExtractedExpenseCategory) -> [String] {
        guard let keywords = categoryKeywords[category] else { return [] }
        
        let lowerText = text.lowercased()
        var foundKeywords: [String] = []
        
        for keyword in keywords {
            if lowerText.contains(keyword) {
                foundKeywords.append(keyword)
            }
        }
        
        return foundKeywords
    }
    
    // MARK: - Private Methods
    
    private func parseLineItem(from line: String) -> ExtractedLineItem? {
        guard isValidLineItem(line) else { return nil }
        
        // Pattern for: Description Qty UnitPrice Amount
        let lineItemPattern = #"(.+?)\s+(\d+(?:\.\d+)?)\s+\$?([\d,]+\.?\d*)\s+\$?([\d,]+\.?\d*)"#
        let regex = try! NSRegularExpression(pattern: lineItemPattern)
        let matches = regex.matches(in: line, range: NSRange(line.startIndex..., in: line))
        
        if let match = matches.first, match.numberOfRanges == 5 {
            let descriptionRange = Range(match.range(at: 1), in: line)!
            let quantityRange = Range(match.range(at: 2), in: line)!
            let unitPriceRange = Range(match.range(at: 3), in: line)!
            let totalAmountRange = Range(match.range(at: 4), in: line)!
            
            let description = String(line[descriptionRange]).trimmingCharacters(in: .whitespaces)
            let quantityString = String(line[quantityRange])
            let unitPriceString = String(line[unitPriceRange])
            let totalAmountString = String(line[totalAmountRange])
            
            if let quantity = Double(quantityString),
               let unitPrice = parseAmountValue(from: unitPriceString),
               let totalValue = parseAmountValue(from: totalAmountString) {
                
                let totalAmount = ExtractedAmount(
                    value: totalValue,
                    currency: "USD",
                    formattedString: "$\(totalAmountString)"
                )
                
                return ExtractedLineItem(
                    description: description,
                    quantity: quantity,
                    unitPrice: unitPrice,
                    totalAmount: totalAmount,
                    category: classifyItemCategory(description: description)
                )
            }
        }
        
        // Alternative pattern for simpler line items: Description Amount
        let simplePattern = #"(.+?)\s+\$?([\d,]+\.?\d*)"#
        let simpleRegex = try! NSRegularExpression(pattern: simplePattern)
        let simpleMatches = simpleRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
        
        if let match = simpleMatches.first, match.numberOfRanges == 3 {
            let descriptionRange = Range(match.range(at: 1), in: line)!
            let amountRange = Range(match.range(at: 2), in: line)!
            
            let description = String(line[descriptionRange]).trimmingCharacters(in: .whitespaces)
            let amountString = String(line[amountRange])
            
            if let amountValue = parseAmountValue(from: amountString) {
                let totalAmount = ExtractedAmount(
                    value: amountValue,
                    currency: "USD",
                    formattedString: "$\(amountString)"
                )
                
                return ExtractedLineItem(
                    description: description,
                    quantity: 1.0,
                    unitPrice: amountValue,
                    totalAmount: totalAmount,
                    category: classifyItemCategory(description: description)
                )
            }
        }
        
        return nil
    }
    
    private func parseAmountValue(from string: String) -> Double? {
        let cleanedString = string
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        return Double(cleanedString)
    }
}

// MARK: - Supporting Models (if not already defined)

public struct ExtractedLineItem: Codable, Equatable {
    public let description: String
    public let quantity: Double
    public let unitPrice: Double
    public let totalAmount: ExtractedAmount
    public let category: ExtractedExpenseCategory
    
    public init(description: String, quantity: Double, unitPrice: Double, totalAmount: ExtractedAmount, category: ExtractedExpenseCategory) {
        self.description = description
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalAmount = totalAmount
        self.category = category
    }
}

public enum ExtractedExpenseCategory: String, CaseIterable, Codable, Comparable {
    case office = "Office Supplies"
    case travel = "Travel"
    case meals = "Meals & Entertainment"
    case utilities = "Utilities"
    case software = "Software"
    case marketing = "Marketing"
    case professional = "Professional Services"
    case equipment = "Equipment"
    case maintenance = "Maintenance"
    case insurance = "Insurance"
    case other = "Other"
    
    public static func < (lhs: ExtractedExpenseCategory, rhs: ExtractedExpenseCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public var icon: String {
        switch self {
        case .office: return "pencil.and.outline"
        case .travel: return "airplane"
        case .meals: return "fork.knife"
        case .utilities: return "bolt"
        case .software: return "app.badge"
        case .marketing: return "megaphone"
        case .professional: return "briefcase"
        case .equipment: return "desktopcomputer"
        case .maintenance: return "wrench.and.screwdriver"
        case .insurance: return "shield"
        case .other: return "questionmark.circle"
        }
    }
    
    public var color: String {
        switch self {
        case .office: return "blue"
        case .travel: return "green"
        case .meals: return "orange"
        case .utilities: return "yellow"
        case .software: return "purple"
        case .marketing: return "pink"
        case .professional: return "indigo"
        case .equipment: return "gray"
        case .maintenance: return "brown"
        case .insurance: return "red"
        case .other: return "secondary"
        }
    }
}