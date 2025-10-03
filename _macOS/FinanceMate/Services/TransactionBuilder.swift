import Foundation
import CoreData

/// Service for building and persisting transactions from Gmail extractions
/// Handles transaction creation, line item creation, and note formatting
class TransactionBuilder {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Create a transaction from extracted Gmail data
    /// - Parameter extracted: Extracted transaction data from email
    /// - Returns: Created transaction or nil on failure
    @discardableResult
    func createTransaction(from extracted: ExtractedTransaction) -> Transaction? {
        NSLog("=== CREATE TRANSACTION CALLED ===")
        NSLog("Merchant: %@", extracted.merchant)
        NSLog("Amount: %.2f", extracted.amount)

        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.amount = extracted.amount
        transaction.itemDescription = extracted.merchant
        transaction.category = extracted.category
        transaction.taxCategory = TaxCategory.personal.rawValue
        transaction.date = extracted.date
        transaction.source = "gmail"
        transaction.sourceEmailID = extracted.id
        transaction.importedDate = Date()
        transaction.note = buildTransactionNote(from: extracted)

        NSLog("Creating %d line items", extracted.items.count)
        createLineItems(for: transaction, from: extracted.items)

        return saveTransaction(transaction) ? transaction : nil
    }

    /// Create line items for a transaction
    private func createLineItems(for transaction: Transaction, from items: [GmailLineItem]) {
        for item in items {
            guard let lineItem = NSEntityDescription.insertNewObject(
                forEntityName: "LineItem",
                into: viewContext
            ) as? LineItem else {
                NSLog("ERROR: Failed to create line item")
                continue
            }
            lineItem.id = UUID()
            lineItem.itemDescription = item.description
            lineItem.quantity = Int32(item.quantity)
            lineItem.price = item.price
            lineItem.taxCategory = TaxCategory.personal.rawValue
            lineItem.transaction = transaction
        }
    }

    /// Build comprehensive note from extracted data
    private func buildTransactionNote(from extracted: ExtractedTransaction) -> String {
        var components = [
            "Email: \(extracted.emailSubject)",
            "From: \(extracted.emailSender)",
            "Confidence: \(Int(extracted.confidence * 100))%"
        ]

        if let gst = extracted.gstAmount {
            components.append("GST: $\(String(format: "%.2f", gst))")
        }
        if let abn = extracted.abn {
            components.append("ABN: \(abn)")
        }
        if let invoice = extracted.invoiceNumber {
            components.append("Invoice#: \(invoice)")
        }
        if let payment = extracted.paymentMethod {
            components.append("Payment: \(payment)")
        }

        return components.joined(separator: " | ")
    }

    /// Save transaction to Core Data
    private func saveTransaction(_ transaction: Transaction) -> Bool {
        do {
            try viewContext.save()
            NSLog(" Transaction saved successfully")
            return true
        } catch {
            NSLog(" Save failed: %@", error.localizedDescription)
            return false
        }
    }
}
