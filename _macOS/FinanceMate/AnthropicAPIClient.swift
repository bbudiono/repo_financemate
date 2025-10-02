//
// AnthropicAPIClient.swift
// FinanceMate
//
// Production-ready Anthropic Claude API client with streaming support
// Implements Messages API with comprehensive error handling and security
// KISS compliant: Modular architecture with extracted models and stream handler
//

import Foundation
import OSLog

/// Production-ready client for Anthropic Claude API
/// Supports both streaming and non-streaming responses with robust error handling
struct AnthropicAPIClient {

    // MARK: - Properties

    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-20250514"
    private let anthropicVersion = "2023-06-01"
    private let logger = Logger(subsystem: "com.financemate.api", category: "AnthropicClient")
    private let streamHandler = AnthropicStreamHandler()

    // MARK: - Configuration

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 300.0
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    // MARK: - Initialization

    /// Initialize with API key
    /// - Parameter apiKey: Anthropic API key (should start with "sk-ant-")
    init(apiKey: String) {
        self.apiKey = apiKey
        if !apiKey.starts(with: "sk-ant-") {
            logger.warning("API key format may be invalid - expected to start with 'sk-ant-'")
        }
    }

    // MARK: - Public API

    /// Send message with streaming response
    /// - Parameters:
    ///   - messages: Conversation history
    ///   - systemPrompt: Optional system prompt for context
    /// - Returns: AsyncThrowingStream of response chunks
    func sendMessage(
        messages: [AnthropicMessage],
        systemPrompt: String? = nil
    ) async throws -> AsyncThrowingStream<String, Error> {
        logger.info("Sending streaming message request with \(messages.count) messages")

        let request = try buildRequest(messages: messages, systemPrompt: systemPrompt, stream: true)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await session.bytes(for: request)
                    try validateResponse(response)

                    // Delegate stream processing to handler
                    for try await content in streamHandler.processStream(bytes) {
                        continuation.yield(content)
                    }

                    continuation.finish()
                    logger.info("Streaming completed successfully")

                } catch {
                    logger.error("Streaming failed: \(error.localizedDescription)")
                    continuation.finish(throwing: mapError(error))
                }
            }
        }
    }

    /// Send message with synchronous response
    /// - Parameters:
    ///   - messages: Conversation history
    ///   - systemPrompt: Optional system prompt for context
    /// - Returns: Complete response text
    func sendMessageSync(
        messages: [AnthropicMessage],
        systemPrompt: String? = nil
    ) async throws -> String {
        logger.info("Sending synchronous message request with \(messages.count) messages")

        let request = try buildRequest(messages: messages, systemPrompt: systemPrompt, stream: false)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        let apiResponse = try JSONDecoder().decode(AnthropicMessageResponse.self, from: data)

        guard let firstContent = apiResponse.content.first else {
            logger.error("Empty response content")
            throw AnthropicAPIError.invalidResponse
        }

        logger.info("Received synchronous response: \(firstContent.text.prefix(100))...")
        return firstContent.text
    }

    // MARK: - Private Helpers

    /// Build HTTP request for API call
    private func buildRequest(
        messages: [AnthropicMessage],
        systemPrompt: String?,
        stream: Bool
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw AnthropicAPIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        var requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "stream": stream
        ]

        if let systemPrompt = systemPrompt {
            requestBody["system"] = systemPrompt
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }

    /// Validate HTTP response status
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnthropicAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            logger.error("Invalid API key (401)")
            throw AnthropicAPIError.invalidAPIKey
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "retry-after")
                .flatMap { TimeInterval($0) } ?? 60.0
            logger.warning("Rate limit exceeded, retry after \(retryAfter)s")
            throw AnthropicAPIError.rateLimitExceeded(retryAfter: retryAfter)
        case 500...599:
            logger.error("Server error: \(httpResponse.statusCode)")
            throw AnthropicAPIError.serverError(statusCode: httpResponse.statusCode)
        default:
            logger.error("Unexpected status code: \(httpResponse.statusCode)")
            throw AnthropicAPIError.invalidResponse
        }
    }

    /// Map generic errors to API-specific errors
    private func mapError(_ error: Error) -> Error {
        if let apiError = error as? AnthropicAPIError {
            return apiError
        }

        if let urlError = error as? URLError {
            logger.error("Network error: \(urlError.localizedDescription)")
            return AnthropicAPIError.networkError(urlError)
        }

        if error is DecodingError {
            logger.error("Decoding error: \(error.localizedDescription)")
            return AnthropicAPIError.decodingError(error)
        }

        return error
    }
}
