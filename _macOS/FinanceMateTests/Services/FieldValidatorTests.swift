import XCTest
@testable import FinanceMate

/// BLUEPRINT Line 196: Strict Field Format Validation Tests
/// Validates all 7 field validation rules with confidence penalties
final class FieldValidatorTests: XCTestCase {

    // MARK: - Amount Validation (Rule 1)

    func testAmountValidationRejectsNegative() {
        let result = FieldValidator.validateAmount(-50.0)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Amount must be positive")
    }

    func testAmountValidationRejectsZero() {
        let result = FieldValidator.validateAmount(0.0)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Amount must be positive")
    }

    func testAmountValidationRejectsOverMillion() {
        let result = FieldValidator.validateAmount(1_000_000.00)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Amount exceeds $999,999.99")
    }

    func testAmountValidationAcceptsValidAmount() {
        let result = FieldValidator.validateAmount(158.95)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
        XCTAssertNil(result.reason)
    }

    func testAmountValidationAcceptsMaximumValid() {
        let result = FieldValidator.validateAmount(999_999.99)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    // MARK: - GST Validation (Rule 2)

    func testGSTValidationAccepts10Percent() {
        let result = FieldValidator.validateGST(gst: 10.0, amount: 100.0)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testGSTValidationAcceptsWithin2PercentTolerance() {
        // 10% of $158.95 = $15.895, tolerance ±2% = ±$0.31779
        let result = FieldValidator.validateGST(gst: 15.60, amount: 158.95)  // Within tolerance
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testGSTValidationRejectsBeyond2PercentTolerance() {
        // 10% of $100 = $10, tolerance ±2% = ±$0.20
        let result = FieldValidator.validateGST(gst: 8.0, amount: 100.0)  // 20% off - beyond tolerance
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.1)  // Reduced penalty per BLUEPRINT
        XCTAssertEqual(result.reason, "GST not 10% of amount (±2% tolerance)")
    }

    func testGSTValidationAcceptsNilGST() {
        // GST is optional - nil should be valid
        let result = FieldValidator.validateGST(gst: nil, amount: 100.0)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    // MARK: - ABN Validation (Rule 3)

    func testABNValidationAcceptsValidFormat() {
        let result = FieldValidator.validateABN("51 824 753 556")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testABNValidationAcceptsValidFormatNoSpaces() {
        let result = FieldValidator.validateABN("51824753556")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testABNValidationRejectsPlaceholder() {
        let result = FieldValidator.validateABN("XX XXX XXX XXX")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "ABN format invalid")
    }

    func testABNValidationRejectsWrongDigitCount() {
        let result = FieldValidator.validateABN("51 824 753 55")  // Only 10 digits
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
    }

    func testABNValidationAcceptsNilABN() {
        // ABN is optional
        let result = FieldValidator.validateABN(nil)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    // MARK: - Invoice Number Validation (Rule 4)

    func testInvoiceNumberValidationAcceptsValidFormat() {
        let result = FieldValidator.validateInvoiceNumber("WW-12345")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testInvoiceNumberValidationRejectsGenericPlaceholder() {
        let result = FieldValidator.validateInvoiceNumber("INV123")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Invoice number appears to be placeholder")
    }

    func testInvoiceNumberValidationRejectsInvoiceWord() {
        let result = FieldValidator.validateInvoiceNumber("INVOICE")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
    }

    func testInvoiceNumberValidationRejectsTooShort() {
        let result = FieldValidator.validateInvoiceNumber("AB")  // Only 2 chars
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Invoice number must be 3-20 characters")
    }

    func testInvoiceNumberValidationRejectsTooLong() {
        let result = FieldValidator.validateInvoiceNumber("ABCDEFGHIJKLMNOPQRSTUVWXYZ")  // 26 chars
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
    }

    // MARK: - Date Validation (Rule 5)

    func testDateValidationAcceptsWithinEmailDateRange() {
        let emailDate = Date()
        let transactionDate = Calendar.current.date(byAdding: .day, value: -10, to: emailDate)!
        let result = FieldValidator.validateDate(transactionDate, emailDate: emailDate)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testDateValidationRejectsFutureDate() {
        let emailDate = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: emailDate)!
        let result = FieldValidator.validateDate(futureDate, emailDate: emailDate)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Date is in the future")
    }

    func testDateValidationRejectsOver30DaysOld() {
        let emailDate = Date()
        let oldDate = Calendar.current.date(byAdding: .day, value: -35, to: emailDate)!
        let result = FieldValidator.validateDate(oldDate, emailDate: emailDate)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Date outside valid range (email date ±30 days)")
    }

    func testDateValidationRejectsOver5YearsOld() {
        let emailDate = Date()
        let ancientDate = Calendar.current.date(byAdding: .year, value: -6, to: emailDate)!
        let result = FieldValidator.validateDate(ancientDate, emailDate: emailDate)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Date is more than 5 years old")
    }

    // MARK: - Category Validation (Rule 6)

    func testCategoryValidationAcceptsPredefinedCategory() {
        let result = FieldValidator.validateCategory("Groceries")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testCategoryValidationRejectsUnknownCategory() {
        let result = FieldValidator.validateCategory("RandomCategory")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Category not in predefined Australian categories")
    }

    func testCategoryValidationAcceptsAllAustralianCategories() {
        let categories = ["Groceries", "Retail", "Utilities", "Transport", "Dining", "Healthcare", "Entertainment", "Other"]
        for category in categories {
            let result = FieldValidator.validateCategory(category)
            XCTAssertTrue(result.isValid, "Category '\(category)' should be valid")
        }
    }

    // MARK: - Payment Method Validation (Rule 7)

    func testPaymentMethodValidationAcceptsValidMethod() {
        let result = FieldValidator.validatePaymentMethod("Visa")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testPaymentMethodValidationIsCaseInsensitive() {
        let result = FieldValidator.validatePaymentMethod("visa")
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    func testPaymentMethodValidationRejectsUnknownMethod() {
        let result = FieldValidator.validatePaymentMethod("BitCoin")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.2)
        XCTAssertEqual(result.reason, "Payment method not recognized")
    }

    func testPaymentMethodValidationAcceptsAllAustralianMethods() {
        let methods = ["Visa", "Mastercard", "Amex", "Discover", "PayPal", "Direct Debit", "BPAY", "Cash", "Afterpay", "Zip", "Other"]
        for method in methods {
            let result = FieldValidator.validatePaymentMethod(method)
            XCTAssertTrue(result.isValid, "Payment method '\(method)' should be valid")
        }
    }

    func testPaymentMethodValidationAcceptsNilPaymentMethod() {
        // Payment method is optional
        let result = FieldValidator.validatePaymentMethod(nil)
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.confidencePenalty, 0.0)
    }

    // MARK: - Integration Test: Multiple Validation Failures

    func testValidationResultCombinesConfidencePenalties() {
        // Simulate multiple validation failures
        let amountResult = FieldValidator.validateAmount(-10.0)  // Penalty: 0.2
        let gstResult = FieldValidator.validateGST(gst: 5.0, amount: 100.0)  // Penalty: 0.1
        let abnResult = FieldValidator.validateABN("XX XXX XXX XXX")  // Penalty: 0.2

        let totalPenalty = amountResult.confidencePenalty + gstResult.confidencePenalty + abnResult.confidencePenalty
        XCTAssertEqual(totalPenalty, 0.5, accuracy: 0.01)  // Total penalty should be 0.5
    }
}
