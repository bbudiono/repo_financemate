import Foundation

/// BLUEPRINT Line 196: Strict Field Format Validation
/// Validates extracted transaction fields before creating ExtractedTransaction
/// Reduces confidence and sets reviewStatus to 'needsReview' if validation fails
struct FieldValidator {

    // MARK: - Rule 1: Amount Validation

    /// Validates transaction amount (Rule 1: >0.0 and <=999,999.99)
    static func validateAmount(_ amount: Double) -> ValidationResult {
        guard amount > 0.0 else {
            return .invalid(penalty: 0.2, reason: "Amount must be positive")
        }
        guard amount <= 999_999.99 else {
            return .invalid(penalty: 0.2, reason: "Amount exceeds $999,999.99")
        }
        return .valid
    }

    // MARK: - Rule 2: GST Validation

    /// Validates GST is ~10% of amount (Rule 2: tolerance ±2%)
    static func validateGST(gst: Double?, amount: Double) -> ValidationResult {
        guard let gst = gst else { return .valid }  // GST is optional

        let expected = amount * 0.1
        let tolerance = expected * 0.02  // ±2% tolerance
        let difference = abs(gst - expected)

        guard difference <= tolerance else {
            return .invalid(penalty: 0.1, reason: "GST not 10% of amount (±2% tolerance)")
        }
        return .valid
    }

    // MARK: - Rule 3: ABN Validation

    /// Validates ABN format (Rule 3: regex ^\d{2}\s?\d{3}\s?\d{3}\s?\d{3}$)
    static func validateABN(_ abn: String?) -> ValidationResult {
        guard let abn = abn else { return .valid }  // ABN is optional

        // Remove all whitespace for digit validation
        let digitsOnly = abn.replacingOccurrences(of: " ", with: "")

        // Check for placeholder pattern
        guard abn != "XX XXX XXX XXX" else {
            return .invalid(penalty: 0.2, reason: "ABN format invalid")
        }

        // Validate exactly 11 digits
        guard digitsOnly.count == 11, digitsOnly.allSatisfy({ $0.isNumber }) else {
            return .invalid(penalty: 0.2, reason: "ABN format invalid")
        }

        // Validate format with optional spaces: \d{2}\s?\d{3}\s?\d{3}\s?\d{3}
        let abnPattern = "^\\d{2}\\s?\\d{3}\\s?\\d{3}\\s?\\d{3}$"
        guard abn.range(of: abnPattern, options: .regularExpression) != nil else {
            return .invalid(penalty: 0.2, reason: "ABN format invalid")
        }

        return .valid
    }

    // MARK: - Rule 4: Invoice Number Validation

    /// Validates invoice number (Rule 4: 3-20 alphanumeric ^[A-Z0-9-]{3,20}$)
    static func validateInvoiceNumber(_ invoiceNumber: String) -> ValidationResult {
        // Check length
        guard invoiceNumber.count >= 3 && invoiceNumber.count <= 20 else {
            return .invalid(penalty: 0.2, reason: "Invoice number must be 3-20 characters")
        }

        // Check for generic placeholders
        let placeholders = ["INV123", "INVOICE", "INV-", "RECEIPT"]
        let upperInvoice = invoiceNumber.uppercased()
        for placeholder in placeholders {
            if upperInvoice.contains(placeholder) || upperInvoice == placeholder {
                return .invalid(penalty: 0.2, reason: "Invoice number appears to be placeholder")
            }
        }

        // Validate alphanumeric pattern (allow hyphens)
        let invoicePattern = "^[A-Z0-9-]{3,20}$"
        guard upperInvoice.range(of: invoicePattern, options: .regularExpression) != nil else {
            return .invalid(penalty: 0.2, reason: "Invoice number format invalid")
        }

        return .valid
    }

    // MARK: - Rule 5: Date Validation

    /// Validates date is within email date ±30 days and not >5 years old (Rule 5)
    static func validateDate(_ date: Date, emailDate: Date) -> ValidationResult {
        // Check if date is more than 5 years old
        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        guard date >= fiveYearsAgo else {
            return .invalid(penalty: 0.2, reason: "Date is more than 5 years old")
        }

        // Check if date is in the future (allow 1 day tolerance per BLUEPRINT)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: emailDate)!
        guard date <= tomorrow else {
            return .invalid(penalty: 0.2, reason: "Date is in the future")
        }

        // Check if date is within ±30 days of email date
        let thirtyDaysBefore = Calendar.current.date(byAdding: .day, value: -30, to: emailDate)!
        guard date >= thirtyDaysBefore else {
            return .invalid(penalty: 0.2, reason: "Date outside valid range (email date ±30 days)")
        }

        return .valid
    }

    // MARK: - Rule 6: Category Validation

    /// Validates category is one of predefined Australian categories (Rule 6)
    static func validateCategory(_ category: String) -> ValidationResult {
        let validCategories = [
            "Groceries", "Retail", "Utilities", "Transport", "Dining",
            "Healthcare", "Entertainment", "Other"
        ]

        guard validCategories.contains(category) else {
            return .invalid(penalty: 0.2, reason: "Category not in predefined Australian categories")
        }

        return .valid
    }

    // MARK: - Rule 7: Payment Method Validation

    /// Validates payment method (Rule 7: case-insensitive matching)
    static func validatePaymentMethod(_ paymentMethod: String?) -> ValidationResult {
        guard let paymentMethod = paymentMethod else { return .valid }  // Payment method is optional

        let validMethods = [
            "visa", "mastercard", "amex", "discover", "paypal",
            "direct debit", "bpay", "cash", "afterpay", "zip", "other"
        ]

        let lowercaseMethod = paymentMethod.lowercased()
        guard validMethods.contains(lowercaseMethod) else {
            return .invalid(penalty: 0.2, reason: "Payment method not recognized")
        }

        return .valid
    }
}

// MARK: - Validation Result Model

/// Result of field validation with confidence penalty
struct ValidationResult {
    let isValid: Bool
    let confidencePenalty: Double
    let reason: String?

    static var valid: ValidationResult {
        ValidationResult(isValid: true, confidencePenalty: 0.0, reason: nil)
    }

    static func invalid(penalty: Double, reason: String) -> ValidationResult {
        ValidationResult(isValid: false, confidencePenalty: penalty, reason: reason)
    }
}
