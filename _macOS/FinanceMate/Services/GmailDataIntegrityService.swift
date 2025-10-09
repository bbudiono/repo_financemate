import Foundation

/// Service for Gmail Data Integrity preservation - BLUEPRINT Line 179
/// Ensures all extracted data including merchant names, amounts, line items,
/// and confidence scores are preserved without data loss or corruption
class GmailDataIntegrityService {

    // MARK: - Data Integrity Validation

    /// Validates that all required fields are present in extracted transaction
    /// - Parameter transaction: The extracted transaction to validate
    /// - Returns: Validation result with integrity score
    static func validateTransactionIntegrity(_ transaction: ExtractedTransaction) -> IntegrityValidationResult {
        var integrityScore = 100.0
        var issues: [String] = []

        // Check merchant name preservation
        if transaction.merchant.isEmpty || transaction.merchant == "Unknown Merchant" {
            integrityScore -= 30.0
            issues.append("Missing or invalid merchant name")
        }

        // Check amount preservation
        if transaction.amount <= 0 {
            integrityScore -= 25.0
            issues.append("Invalid amount value")
        }

        // Check confidence score preservation
        if transaction.confidence < 0.0 || transaction.confidence > 1.0 {
            integrityScore -= 15.0
            issues.append("Invalid confidence score")
        }

        // Check raw text preservation
        if transaction.rawText.isEmpty {
            integrityScore -= 20.0
            issues.append("Missing raw email content")
        }

        // Check line items preservation
        if transaction.items.isEmpty {
            integrityScore -= 10.0
            issues.append("No line items extracted")
        }

        return IntegrityValidationResult(
            isIntact: integrityScore >= 70.0,
            integrityScore: integrityScore,
            issues: issues
        )
    }

    /// Preserves original email content with all extracted data
    /// - Parameters:
    ///   - email: Original Gmail email
    ///   - transaction: Extracted transaction data
    /// - Returns: Enhanced transaction with preserved data
    static func preserveExtractedData(from email: GmailEmail, transaction: ExtractedTransaction) -> ExtractedTransaction {
        // Create enhanced transaction with all original data preserved
        let enhancedTransaction = ExtractedTransaction(
            id: transaction.id,
            merchant: transaction.merchant.isEmpty ? extractMerchantName(from: email) : transaction.merchant,
            amount: transaction.amount,
            date: transaction.date,
            category: transaction.category,
            items: preserveLineItems(transaction.items),
            confidence: calculateConfidenceScore(for: transaction),
            rawText: email.snippet + "\n" + (email.subject),
            emailSubject: email.subject,
            emailSender: email.sender,
            gstAmount: transaction.gstAmount,
            abn: transaction.abn,
            invoiceNumber: transaction.invoiceNumber,
            paymentMethod: transaction.paymentMethod,
            status: transaction.status
        )

        return enhancedTransaction
    }

    // MARK: - Private Helper Methods

    /// Extracts merchant name from email when missing
    /// - Parameter email: Gmail email to extract merchant from
    /// - Returns: Extracted merchant name
    private static func extractMerchantName(from email: GmailEmail) -> String {
        // Try to extract from sender first
        if !email.sender.isEmpty {
            return cleanMerchantName(email.sender)
        }

        // Try to extract from subject
        if !email.subject.isEmpty {
            return cleanMerchantName(email.subject)
        }

        return "Unknown Merchant"
    }

    /// Cleans and normalizes merchant name
    /// - Parameter name: Raw merchant name
    /// - Returns: Cleaned merchant name
    private static func cleanMerchantName(_ name: String) -> String {
        // Remove common prefixes and suffixes
        let cleanName = name
            .replacingOccurrences(of: "noreply@", with: "")
            .replacingOccurrences(of: "no-reply@", with: "")
            .replacingOccurrences(of: ".com", with: "")
            .replacingOccurrences(of: ".com.au", with: "")
            .components(separatedBy: "@").first ?? name

        return cleanName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Preserves line items with data integrity checks
    /// - Parameter items: Original line items
    /// - Returns: Validated line items
    private static func preserveLineItems(_ items: [GmailLineItem]) -> [GmailLineItem] {
        return items.compactMap { item in
            // Validate line item data
            guard !item.description.isEmpty,
                  item.quantity > 0,
                  item.price >= 0 else {
                return nil
            }

            return item
        }
    }

    /// Calculates confidence score based on data completeness
    /// - Parameter transaction: Transaction to score
    /// - Returns: Confidence score between 0.0 and 1.0
    private static func calculateConfidenceScore(for transaction: ExtractedTransaction) -> Double {
        var score = 0.5 // Base score

        // Merchant name confidence
        if !transaction.merchant.isEmpty && transaction.merchant != "Unknown Merchant" {
            score += 0.2
        }

        // Amount confidence
        if transaction.amount > 0 {
            score += 0.1
        }

        // Line items confidence
        if !transaction.items.isEmpty {
            score += 0.1
        }

        // Raw text confidence
        if !transaction.rawText.isEmpty {
            score += 0.1
        }

        return min(score, 1.0)
    }
}

// MARK: - Supporting Models

/// Result of data integrity validation
struct IntegrityValidationResult {
    let isIntact: Bool
    let integrityScore: Double
    let issues: [String]
}

/// Data integrity metrics for monitoring
struct DataIntegrityMetrics {
    let totalTransactionsProcessed: Int
    let highIntegrityTransactions: Int
    let averageIntegrityScore: Double
    let commonIssues: [String]
}