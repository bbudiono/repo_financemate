import Foundation
import PDFKit

/// Service for extracting transaction line items from PDF attachments using Apple Vision Framework
/// BLUEPRINT Line 58-69: Handles City of Gold Coast, Our Sage, Bunnings PDF examples
///
/// This service coordinates PDF processing using modular components:
/// - PDFOCRProcessor: Handles Vision Framework OCR operations
/// - PDFLineItemParser: Parses OCR text into structured line items
class PDFExtractionService {

    private let ocrProcessor = PDFOCRProcessor()
    private let lineItemParser = PDFLineItemParser()

    // MARK: - Public API

    /// Extract line items from PDF data using Vision Framework OCR
    /// - Parameter pdfData: Raw PDF file data
    /// - Returns: Array of extracted line items with amounts, GST, quantities
    /// - Throws: PDFExtractionError if password-protected, invalid, or OCR fails
    func extractLineItems(from pdfData: Data) async throws -> [PDFLineItem] {
        try validatePDF(pdfData)
        let pdfDocument = try loadPDF(pdfData)
        let extractedText = try await extractText(from: pdfDocument)
        return lineItemParser.parse(from: extractedText)
    }

    /// Check if PDF is password-protected
    /// - Parameter pdfData: Raw PDF file data
    /// - Returns: True if PDF requires password to open
    func isPasswordProtected(_ pdfData: Data) -> Bool {
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            return false
        }
        return pdfDocument.isLocked
    }

    // MARK: - Private Helpers

    private func validatePDF(_ pdfData: Data) throws {
        if isPasswordProtected(pdfData) {
            throw PDFExtractionError.requiresPassword(filename: "Receipt-249589.pdf")
        }
    }

    private func loadPDF(_ pdfData: Data) throws -> PDFDocument {
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            throw PDFExtractionError.invalidPDFData
        }
        return pdfDocument
    }

    private func extractText(from pdfDocument: PDFDocument) async throws -> String {
        let pageCount = min(pdfDocument.pageCount, 5)
        var allExtractedText = ""

        for pageIndex in 0..<pageCount {
            if let pageText = try await extractTextFromPage(pdfDocument, pageIndex: pageIndex) {
                allExtractedText += pageText + "\n"
            }
        }

        return allExtractedText
    }

    private func extractTextFromPage(_ pdfDocument: PDFDocument, pageIndex: Int) async throws -> String? {
        guard let page = pdfDocument.page(at: pageIndex) else {
            return nil
        }

        // Generate thumbnail image from PDF page
        let thumbnail = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)

        // Convert NSImage to CGImage
        guard let cgImage = thumbnail.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        return try await ocrProcessor.performOCR(on: cgImage)
    }
}
