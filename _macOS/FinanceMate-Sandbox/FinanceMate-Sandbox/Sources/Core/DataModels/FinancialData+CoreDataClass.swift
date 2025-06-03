// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: FinancialData Core Data model class for extracted financial information
* Issues & Complexity Summary: Financial data entity with monetary calculations, validation, and business rules
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 3 New (CoreData, Foundation, Decimal calculations)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 78%
* Problem Estimate (Inherent Problem Difficulty %): 75%
* Initial Code Complexity Estimate %: 77%
* Justification for Estimates: Financial calculations require precision and business rule validation
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

/// FinancialData entity representing extracted financial information from documents
/// Manages monetary values, tax calculations, and financial metadata
@objc(FinancialData)
public class FinancialData: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    /// Creates a new FinancialData with required properties
    /// - Parameters:
    ///   - context: The managed object context
    ///   - totalAmount: Total amount from the document
    ///   - currency: Currency code (e.g., "USD", "EUR")
    convenience init(
        context: NSManagedObjectContext,
        totalAmount: NSDecimalNumber,
        currency: String
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.totalAmount = totalAmount
        self.currency = currency.uppercased()
        self.dateExtracted = Date()
        self.extractionConfidence = 0.0
    }
    
    // MARK: - Computed Properties
    
    /// Computed property for subtotal (total amount minus tax)
    public var subtotalAmount: NSDecimalNumber {
        guard let totalAmount = totalAmount,
              let taxAmount = taxAmount else {
            return totalAmount ?? NSDecimalNumber.zero
        }
        
        return totalAmount.subtracting(taxAmount)
    }
    
    /// Computed property for effective tax rate
    public var effectiveTaxRate: Double {
        guard let totalAmount = totalAmount,
              let taxAmount = taxAmount,
              totalAmount.doubleValue > 0 else {
            return 0.0
        }
        
        return taxAmount.doubleValue / totalAmount.doubleValue
    }
    
    /// Computed property to check if amounts are consistent
    public var hasConsistentAmounts: Bool {
        guard let totalAmount = totalAmount,
              let taxAmount = taxAmount else {
            return totalAmount != nil
        }
        
        // Check if total = subtotal + tax (within small tolerance for rounding)
        let calculatedTotal = subtotalAmount.adding(taxAmount)
        let difference = abs(totalAmount.doubleValue - calculatedTotal.doubleValue)
        return difference < 0.01 // Allow 1 cent tolerance
    }
    
    /// Computed property for currency symbol
    public var currencySymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.currencySymbol ?? currency ?? "$"
    }
    
    /// Computed property for formatted total amount
    public var formattedTotalAmount: String {
        return formatCurrency(totalAmount)
    }
    
    /// Computed property for formatted tax amount
    public var formattedTaxAmount: String {
        return formatCurrency(taxAmount)
    }
    
    /// Computed property for formatted subtotal amount
    public var formattedSubtotalAmount: String {
        return formatCurrency(subtotalAmount)
    }
    
    /// Computed property to check if data is recent (within last 30 days)
    public var isRecentData: Bool {
        guard let extractionDate = dateExtracted else { return false }
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return extractionDate > thirtyDaysAgo
    }
    
    /// Computed property for confidence level description
    public var confidenceLevel: String {
        switch extractionConfidence {
        case 0.9...1.0: return "High"
        case 0.7..<0.9: return "Medium"
        case 0.5..<0.7: return "Low"
        default: return "Very Low"
        }
    }
    
    // MARK: - Business Logic Methods
    
    /// Updates the extraction confidence score
    /// - Parameter confidence: New confidence score (0.0 to 1.0)
    public func updateConfidence(_ confidence: Double) {
        extractionConfidence = max(0.0, min(1.0, confidence))
    }
    
    /// Calculates tax amount based on subtotal and tax rate
    /// - Parameters:
    ///   - subtotal: Subtotal amount before tax
    ///   - rate: Tax rate as decimal (e.g., 0.08 for 8%)
    public func calculateTax(subtotal: NSDecimalNumber, rate: Double) {
        let rateDecimal = NSDecimalNumber(value: rate)
        taxAmount = subtotal.multiplying(by: rateDecimal)
        taxRate = rate
        totalAmount = subtotal.adding(taxAmount ?? NSDecimalNumber.zero)
    }
    
    /// Updates the due date relative to invoice date
    /// - Parameter daysFromInvoice: Number of days after invoice date
    public func updateDueDate(daysFromInvoice: Int) {
        guard let invoiceDate = invoiceDate else { return }
        dueDate = Calendar.current.date(byAdding: .day, value: daysFromInvoice, to: invoiceDate)
    }
    
    /// Checks if the invoice is overdue
    /// - Returns: True if the invoice is past due date
    public func isOverdue() -> Bool {
        guard let dueDate = dueDate else { return false }
        return Date() > dueDate
    }
    
    /// Calculates days until due date
    /// - Returns: Number of days until due (negative if overdue)
    public func daysUntilDue() -> Int? {
        guard let dueDate = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }
    
    /// Formats a currency amount using the entity's currency
    /// - Parameter amount: Amount to format
    /// - Returns: Formatted currency string
    private func formatCurrency(_ amount: NSDecimalNumber?) -> String {
        guard let amount = amount else { return "N/A" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: amount) ?? "\(currencySymbol)\(amount)"
    }
    
    /// Validates financial data properties before saving
    /// - Throws: ValidationError if validation fails
    public func validateForSave() throws {
        // Validate required fields
        guard let totalAmount = totalAmount, totalAmount.doubleValue >= 0 else {
            throw ValidationError.invalidValue("totalAmount", "Total amount must be non-negative")
        }
        
        guard let currency = currency, !currency.isEmpty else {
            throw ValidationError.missingRequiredField("currency")
        }
        
        // Validate currency code format (should be 3 characters)
        guard currency.count == 3 else {
            throw ValidationError.invalidValue("currency", "Currency code must be 3 characters")
        }
        
        // Validate tax amount if present
        if let taxAmount = taxAmount {
            guard taxAmount.doubleValue >= 0 else {
                throw ValidationError.invalidValue("taxAmount", "Tax amount must be non-negative")
            }
            
            // Tax amount should not exceed total amount
            guard taxAmount.doubleValue <= totalAmount.doubleValue else {
                throw ValidationError.invalidValue("taxAmount", "Tax amount cannot exceed total amount")
            }
        }
        
        // Validate tax rate if present
        if taxRate > 0 {
            guard taxRate <= 1.0 else {
                throw ValidationError.invalidValue("taxRate", "Tax rate must be between 0 and 1")
            }
        }
        
        // Validate confidence score
        guard extractionConfidence >= 0.0 && extractionConfidence <= 1.0 else {
            throw ValidationError.invalidValue("extractionConfidence", "Confidence must be between 0.0 and 1.0")
        }
        
        // Validate date relationships
        if let invoiceDate = invoiceDate, let dueDate = dueDate {
            guard dueDate >= invoiceDate else {
                throw ValidationError.invalidValue("dueDate", "Due date cannot be before invoice date")
            }
        }
        
        // Validate amounts consistency if both total and tax are present
        if !hasConsistentAmounts {
            throw ValidationError.invalidValue("amounts", "Total amount is not consistent with subtotal and tax amounts")
        }
    }
    
    /// Creates a summary dictionary of the financial data
    /// - Returns: Dictionary containing key financial information
    public func createSummary() -> [String: Any] {
        var summary: [String: Any] = [:]
        
        summary["id"] = id?.uuidString
        summary["vendorName"] = vendorName
        summary["totalAmount"] = totalAmount?.doubleValue
        summary["currency"] = currency
        summary["formattedTotal"] = formattedTotalAmount
        summary["invoiceNumber"] = invoiceNumber
        summary["invoiceDate"] = invoiceDate
        summary["dueDate"] = dueDate
        summary["isOverdue"] = isOverdue()
        summary["confidenceLevel"] = confidenceLevel
        summary["extractionDate"] = dateExtracted
        
        if let daysUntil = daysUntilDue() {
            summary["daysUntilDue"] = daysUntil
        }
        
        return summary
    }
}

// MARK: - Core Data Validation

extension FinancialData {
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateForSave()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateForSave()
    }
    
    public override func willSave() {
        super.willSave()
        
        // Ensure currency is always uppercase
        if let currency = currency {
            self.currency = currency.uppercased()
        }
    }
}