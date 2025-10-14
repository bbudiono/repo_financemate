import XCTest
@testable import FinanceMate

/// Tests for PDF extraction using Apple Vision Framework (BLUEPRINT Line 58-69)
/// Validates OCR accuracy for 3 real-world examples
class PDFExtractionServiceTests: XCTestCase {

    var service: PDFExtractionService!

    override func setUp() {
        super.setUp()
        service = PDFExtractionService()
    }

    // MARK: - BLUEPRINT Example 1: City of Gold Coast

    /// Test extraction of City of Gold Coast PDF invoice (69804724)
    /// BLUEPRINT requirement: 2 line items with amounts and GST
    /// Expected: Line Item 1: Rates Assessment $500.00 GST $0.00
    ///           Line Item 2: Merchant Service Fee $3.40 GST $0.00
    func testCityOfGoldCoastPDFExtraction() async throws {
        // Arrange: Create synthetic PDF with City of Gold Coast invoice format
        let pdfData = PDFTestDataBuilder.createCityOfGoldCoastPDF()

        // Act: Extract line items using Vision OCR
        let lineItems = try await service.extractLineItems(from: pdfData)

        // Assert: Verify 2 line items extracted
        XCTAssertEqual(lineItems.count, 2, "Should extract 2 line items")

        // Assert: Verify Line Item 1 details
        let ratesItem = lineItems.first(where: { $0.description.contains("Rates Assessment") })
        XCTAssertNotNil(ratesItem, "Should find Rates Assessment line item")
        XCTAssertEqual(ratesItem?.amount, 500.00, accuracy: 0.01)
        XCTAssertEqual(ratesItem?.gst, 0.00, accuracy: 0.01)

        // Assert: Verify Line Item 2 details
        let feeItem = lineItems.first(where: { $0.description.contains("Merchant Service Fee") })
        XCTAssertNotNil(feeItem, "Should find Merchant Service Fee line item")
        XCTAssertEqual(feeItem?.amount, 3.40, accuracy: 0.01)
        XCTAssertEqual(feeItem?.gst, 0.00, accuracy: 0.01)
    }

    // MARK: - BLUEPRINT Example 2: Our Sage (Password-Protected)

    /// Test detection of password-protected PDF (Our Sage Receipt-249589)
    /// BLUEPRINT requirement: Detect password protection and escalate to user
    /// Expected: Throws PDFRequiresPasswordError
    func testOurSagePDFPasswordDetection() async throws {
        // Arrange: Create password-protected PDF
        let pdfData = PDFTestDataBuilder.createPasswordProtectedPDF()

        // Act & Assert: Should throw password error
        do {
            _ = try await service.extractLineItems(from: pdfData)
            XCTFail("Should throw PDFRequiresPasswordError for password-protected PDF")
        } catch PDFExtractionError.requiresPassword(let filename) {
            XCTAssertEqual(filename, "Receipt-249589.pdf")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        // Assert: Helper method correctly identifies password protection
        XCTAssertTrue(service.isPasswordProtected(pdfData))
    }

    // MARK: - BLUEPRINT Example 3: Bunnings (Multi-Line with GST)

    /// Test extraction of Bunnings invoice (IN2134A-7931)
    /// BLUEPRINT requirement: 2 line items with separate GST per item
    /// Expected: Line Item 1: Dip Bar $71.00 GST $6.45 Qty 1
    ///           Line Item 2: Shipping $7.42 GST $0.67 Qty 1
    func testBunningsPDFMultiLineItemsWithGST() async throws {
        // Arrange: Create synthetic PDF with Bunnings invoice format
        let pdfData = PDFTestDataBuilder.createBunningsPDF()

        // Act: Extract line items using Vision OCR
        let lineItems = try await service.extractLineItems(from: pdfData)

        // Assert: Verify 2 line items extracted
        XCTAssertEqual(lineItems.count, 2, "Should extract 2 line items")

        // Assert: Verify Line Item 1 (Dip Bar)
        let dipBarItem = lineItems.first(where: { $0.description.contains("Dip Bar") })
        XCTAssertNotNil(dipBarItem, "Should find Dip Bar line item")
        XCTAssertEqual(dipBarItem?.amount, 71.00, accuracy: 0.01)
        XCTAssertEqual(dipBarItem?.gst, 6.45, accuracy: 0.01)
        XCTAssertEqual(dipBarItem?.quantity, 1)

        // Assert: Verify Line Item 2 (Shipping)
        let shippingItem = lineItems.first(where: { $0.description.contains("Shipping") })
        XCTAssertNotNil(shippingItem, "Should find Shipping line item")
        XCTAssertEqual(shippingItem?.amount, 7.42, accuracy: 0.01)
        XCTAssertEqual(shippingItem?.gst, 0.67, accuracy: 0.01)
        XCTAssertEqual(shippingItem?.quantity, 1)
    }

    // MARK: - Additional Tests

    /// Test multi-page PDF extraction
    func testMultiPagePDFExtraction() async throws {
        // Arrange: Create 3-page PDF with line items spread across pages
        let pdfData = PDFTestDataBuilder.createMultiPagePDF(pages: 3)

        // Act: Extract line items (should process all pages)
        let lineItems = try await service.extractLineItems(from: pdfData)

        // Assert: Should find line items from multiple pages
        XCTAssertGreaterThan(lineItems.count, 0, "Should extract line items from multi-page PDF")
    }

    /// Test PDF with no line items (edge case)
    func testPDFWithNoLineItems() async throws {
        // Arrange: Create PDF with text but no line items
        let pdfData = PDFTestDataBuilder.createNonInvoicePDF()

        // Act: Extract line items
        let lineItems = try await service.extractLineItems(from: pdfData)

        // Assert: Should return empty array (not crash)
        XCTAssertEqual(lineItems.count, 0, "Should return empty array for PDF with no line items")
    }
}
