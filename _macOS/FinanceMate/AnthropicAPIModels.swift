//
// AnthropicAPIModels.swift
// FinanceMate
//
// Data models for Anthropic Claude API client
// Extracted for KISS compliance (modular architecture)
//

import Foundation

// MARK: - Public Models

/// Message in conversation history
struct AnthropicMessage: Codable, Equatable {
    let role: String  // "user" or "assistant"
    let content: String
}

// MARK: - API Error Types

/// Comprehensive API error handling
enum AnthropicAPIError: Error, LocalizedError {
    case invalidAPIKey
    case rateLimitExceeded(retryAfter: TimeInterval)
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid Anthropic API key. Please check your credentials."
        case .rateLimitExceeded(let retryAfter):
            return "Rate limit exceeded. Please retry after \(Int(retryAfter)) seconds."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Anthropic API."
        case .decodingError(let error):
            return "Failed to decode API response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Anthropic server error (status code: \(statusCode))"
        }
    }
}

// MARK: - Internal Response Models

/// Non-streaming API response format
struct AnthropicMessageResponse: Codable {
    let content: [Content]

    struct Content: Codable {
        let type: String
        let text: String
    }
}

/// Streaming event format (Server-Sent Events)
struct AnthropicStreamEvent: Codable {
    let type: String
    let delta: Delta?

    struct Delta: Codable {
        let type: String
        let text: String?
    }
}
