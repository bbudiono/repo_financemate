import Foundation
import PDFKit
import AppKit

/// Builder for creating synthetic PDF test data matching BLUEPRINT examples
struct PDFTestDataBuilder {

    /// Create City of Gold Coast invoice PDF (BLUEPRINT Example 1)
    /// Invoice 69804724 with 2 line items
    static func createCityOfGoldCoastPDF() -> Data {
        let text = """
        City of Gold Coast
        Invoice Number: 69804724
        External Reference: PY-4189085

        Rates Assessment: UNIT 1, 173, Olsen Avenue, LABRADOR QLD 4215: 235608361
        $500.00                    GST $0.00

        Merchant Service Fee
        $3.40                      GST $0.00

        Total: $503.40
        """

        return createPDFData(with: text)
    }

    /// Create password-protected PDF (BLUEPRINT Example 2 - Our Sage)
    static func createPasswordProtectedPDF() -> Data {
        let text = """
        Our Sage
        Receipt Number: 249589

        7. Script - Repeat
        $21.00                     GST $0.00

        Total: $21.00
        """

        let data = createPDFData(with: text)

        // Create password-protected PDF
        if let tempPDF = PDFDocument(data: data) {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "temp_protected.pdf")
            tempPDF.write(to: tempURL, withOptions: [.ownerPasswordOption: "test123"])

            if let protectedData = try? Data(contentsOf: tempURL) {
                try? FileManager.default.removeItem(at: tempURL)
                return protectedData
            }
        }

        return data
    }

    /// Create Bunnings invoice PDF (BLUEPRINT Example 3)
    /// Invoice IN2134A-7931 with 2 line items and GST
    static func createBunningsPDF() -> Data {
        let text = """
        Bunnings Marketplace
        Invoice Number: IN2134A-7931
        Company: Sello Products Pty.Ltd.

        Centra Adjustable Parallel Dip Bar
        $71.00                     GST $6.45      Qty 1

        Shipping
        $7.42                      GST $0.67      Qty 1

        Total: $78.42
        """

        return createPDFData(with: text)
    }

    /// Create multi-page PDF with line items across pages
    static func createMultiPagePDF(pages: Int) -> Data {
        var fullText = ""
        for pageNum in 1...pages {
            fullText += """
            Page \(pageNum)

            Line Item \(pageNum): Product \(pageNum)
            $\(pageNum * 10).00                GST $\(pageNum).00

            ---
            """
        }

        return createPDFData(with: fullText)
    }

    /// Create PDF with no line items (edge case)
    static func createNonInvoicePDF() -> Data {
        let text = """
        This is a simple document with no invoice line items.
        It contains text but no dollar amounts or GST information.

        This should return an empty line items array.
        """

        return createPDFData(with: text)
    }

    // MARK: - Private Helpers

    /// Create PDF data from text string
    private static func createPDFData(with text: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator as String: "FinanceMate Test Suite",
            kCGPDFContextAuthor as String: "PDFTestDataBuilder"
        ]

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // US Letter size

        let data = NSMutableData()

        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, pdfMetaData as CFDictionary) else {
            return Data()
        }

        context.beginPDFPage(nil)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: NSColor.black
        ]

        let textRect = CGRect(x: 50, y: 50, width: pageRect.width - 100, height: pageRect.height - 100)

        // Flip coordinate system for macOS (origin is bottom-left)
        context.saveGState()
        context.translateBy(x: 0, y: pageRect.height)
        context.scaleBy(x: 1.0, y: -1.0)

        let nsString = text as NSString
        nsString.draw(in: textRect, withAttributes: attributes)

        context.restoreGState()
        context.endPDFPage()
        context.closePDF()

        return data as Data
    }
}
