import Foundation
import Vision
import CoreGraphics

/// Processor for performing OCR on PDF page images using Apple Vision Framework
struct PDFOCRProcessor {

    /// Perform OCR on a PDF page image using Vision Framework
    /// - Parameter cgImage: PDF page as CGImage
    /// - Returns: Extracted text from the page
    /// - Throws: PDFExtractionError if OCR fails
    func performOCR(on cgImage: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = createTextRecognitionRequest(continuation: continuation)
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: PDFExtractionError.ocrFailed(error.localizedDescription))
            }
        }
    }

    // MARK: - Private Helpers

    private func createTextRecognitionRequest(
        continuation: CheckedContinuation<String, Error>
    ) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                continuation.resume(throwing: PDFExtractionError.ocrFailed(error.localizedDescription))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                continuation.resume(throwing: PDFExtractionError.noTextRecognized)
                return
            }

            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            continuation.resume(returning: recognizedText)
        }

        configureRequest(request)
        return request
    }

    private func configureRequest(_ request: VNRecognizeTextRequest) {
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-AU", "en-US"]  // Australian English priority
    }
}
