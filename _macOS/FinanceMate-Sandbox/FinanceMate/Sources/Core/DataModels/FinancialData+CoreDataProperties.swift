// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: FinancialData Core Data properties extension for attribute and relationship definitions
* Issues & Complexity Summary: Core Data managed object properties and relationships for FinancialData entity
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Standard Core Data properties definition for financial entity
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import CoreData
import Foundation

extension FinancialData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialData> {
        NSFetchRequest<FinancialData>(entityName: "FinancialData")
    }

    // MARK: - Attributes

    /// Unique identifier for the financial data
    @NSManaged public var id: UUID?

    /// Name of the vendor/supplier
    @NSManaged public var vendorName: String?

    /// Total amount from the document
    @NSManaged public var totalAmount: NSDecimalNumber?

    /// Tax amount extracted
    @NSManaged public var taxAmount: NSDecimalNumber?

    /// Tax rate as decimal (e.g., 0.08 for 8%)
    @NSManaged public var taxRate: Double

    /// Currency code (e.g., USD, EUR, GBP)
    @NSManaged public var currency: String?

    /// Invoice number from the document
    @NSManaged public var invoiceNumber: String?

    /// Date on the invoice
    @NSManaged public var invoiceDate: Date?

    /// Due date for payment
    @NSManaged public var dueDate: Date?

    /// Date when the financial data was extracted
    @NSManaged public var dateExtracted: Date?

    /// Confidence score from extraction process (0.0 to 1.0)
    @NSManaged public var extractionConfidence: Double

    /// Purchase order number if available
    @NSManaged public var purchaseOrderNumber: String?

    /// Payment terms (e.g., "Net 30", "Due on receipt")
    @NSManaged public var paymentTerms: String?

    /// Additional notes about the financial data
    @NSManaged public var notes: String?

    /// JSON string containing line items
    @NSManaged public var lineItems: String?

    /// Discount amount if applicable
    @NSManaged public var discountAmount: NSDecimalNumber?

    /// Shipping amount if applicable
    @NSManaged public var shippingAmount: NSDecimalNumber?

    /// JSON string containing additional metadata
    @NSManaged public var metadata: String?

    // MARK: - Relationships

    /// One-to-one relationship with the document containing this financial data
    @NSManaged public var document: Document?
}

// MARK: - Generated accessors for to-many relationships

extension FinancialData: Identifiable {
    // Identifiable conformance using the id property
}

// MARK: - Fetch Request Helpers

extension FinancialData {
    /// Fetch request for financial data by vendor name
    /// - Parameter vendorName: The vendor name to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(for vendorName: String) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "vendorName CONTAINS[cd] %@", vendorName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return request
    }

    /// Fetch request for financial data by currency
    /// - Parameter currency: The currency code to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(withCurrency currency: String) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "currency == %@", currency)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return request
    }

    /// Fetch request for financial data within an amount range
    /// - Parameters:
    ///   - minAmount: Minimum total amount
    ///   - maxAmount: Maximum total amount
    /// - Returns: Configured fetch request
    public static func fetchRequest(minAmount: NSDecimalNumber, maxAmount: NSDecimalNumber) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "totalAmount >= %@ AND totalAmount <= %@", minAmount, maxAmount)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.totalAmount, ascending: false)]
        return request
    }

    /// Fetch request for financial data within a date range
    /// - Parameters:
    ///   - startDate: Start date of the range
    ///   - endDate: End date of the range
    /// - Returns: Configured fetch request
    public static func fetchRequest(from startDate: Date, to endDate: Date) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "invoiceDate >= %@ AND invoiceDate <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return request
    }

    /// Fetch request for overdue invoices
    /// - Returns: Configured fetch request for overdue financial data
    public static func fetchOverdueInvoices() -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        let today = Date()
        request.predicate = NSPredicate(format: "dueDate < %@ AND dueDate != nil", today as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.dueDate, ascending: true)]
        return request
    }

    /// Fetch request for financial data by invoice number
    /// - Parameter invoiceNumber: The invoice number to search for
    /// - Returns: Configured fetch request
    public static func fetchRequest(invoiceNumber: String) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "invoiceNumber == %@", invoiceNumber)
        return request
    }

    /// Fetch request for financial data with low extraction confidence
    /// - Parameter threshold: Confidence threshold (default 0.7)
    /// - Returns: Configured fetch request for low confidence extractions
    public static func fetchLowConfidenceExtractions(threshold: Double = 0.7) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "extractionConfidence < %f", threshold)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.extractionConfidence, ascending: true)]
        return request
    }

    /// Fetch request for financial data with payment terms
    /// - Parameter terms: Payment terms to search for
    /// - Returns: Configured fetch request
    public static func fetchRequest(paymentTerms terms: String) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "paymentTerms CONTAINS[cd] %@", terms)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return request
    }

    /// Fetch request for financial data due within specified days
    /// - Parameter days: Number of days from today
    /// - Returns: Configured fetch request
    public static func fetchDueWithinDays(_ days: Int) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        let today = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
        request.predicate = NSPredicate(format: "dueDate >= %@ AND dueDate <= %@", today as NSDate, futureDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.dueDate, ascending: true)]
        return request
    }

    /// Search financial data by vendor name, invoice number, or notes
    /// - Parameter searchText: Text to search for
    /// - Returns: Configured fetch request for search results
    public static func searchFinancialData(containing searchText: String) -> NSFetchRequest<FinancialData> {
        let request = fetchRequest()
        let searchPredicate = NSPredicate(format: "vendorName CONTAINS[cd] %@ OR invoiceNumber CONTAINS[cd] %@ OR notes CONTAINS[cd] %@",
                                        searchText, searchText, searchText)
        request.predicate = searchPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return request
    }
}
