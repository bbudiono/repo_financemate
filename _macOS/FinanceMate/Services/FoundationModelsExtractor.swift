import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Intelligent extraction using Apple Foundation Models (~3B on-device LLM)
/// BLUEPRINT Section 3.1.1.4: 83% accuracy vs 54% regex baseline
@available(macOS 26.0, *)
class FoundationModelsExtractor {

    /// Extract transaction using Foundation Models with anti-hallucination prompt
    /// - Parameter email: Gmail email to extract from
    /// - Returns: ExtractedTransaction with confidence >0.7 or throws error
    static func extract(from email: GmailEmail) async throws -> ExtractedTransaction {
        #if canImport(FoundationModels)
        // Check availability
        guard case .available = SystemLanguageModel.default.availability else {
            throw ExtractionError.modelUnavailable
        }

        let startTime = Date()

        // Build prompt using ExtractionPromptBuilder
        let prompt = ExtractionPromptBuilder.build(for: email)

        // Call Foundation Model
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)

        let duration = Date().timeIntervalSince(startTime)
        let json = ExtractionValidator.stripMarkdown(response.content)
        let transaction = try ExtractionValidator.parseJSON(json, email: email)

        NSLog("[FM-EXTRACT] %.2fs - \(transaction.merchant) $\(transaction.amount) (\(Int(transaction.confidence*100))%%)")
        return transaction
        #else
        // Foundation Models not available - throw error
        throw ExtractionError.modelUnavailable
        #endif
    }

}

// MARK: - Extraction Errors

enum ExtractionError: LocalizedError {
    case modelUnavailable
    case jsonParsingFailed(String)
    case missingRequiredFields

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Foundation Models not available. Enable Apple Intelligence in System Settings."
        case .jsonParsingFailed(let json):
            return "Failed to parse JSON: \(json.prefix(100))"
        case .missingRequiredFields:
            return "Missing required fields (merchant, amount) in extraction result"
        }
    }
}
