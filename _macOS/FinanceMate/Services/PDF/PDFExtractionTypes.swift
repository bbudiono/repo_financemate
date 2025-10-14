import Foundation

/// Error types for PDF extraction
enum PDFExtractionError: LocalizedError {
    case requiresPassword(filename: String)
    case invalidPDFData
    case ocrFailed(String)
    case noTextRecognized

    var errorDescription: String? {
        switch self {
        case .requiresPassword(let filename):
            return "PDF '\(filename)' requires a password. Please enter password or skip."
        case .invalidPDFData:
            return "Invalid PDF data provided"
        case .ocrFailed(let reason):
            return "OCR processing failed: \(reason)"
        case .noTextRecognized:
            return "No text could be recognized in PDF"
        }
    }
}

/// Represents a line item extracted from a PDF invoice/receipt
struct PDFLineItem: Equatable {
    let description: String
    let amount: Double
    let gst: Double
    let quantity: Int
    let rawText: String  // Original OCR text for debugging
}
