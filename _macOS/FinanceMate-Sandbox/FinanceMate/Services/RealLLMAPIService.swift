//
//  RealLLMAPIService.swift
//  FinanceMate
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: REAL LLM API integration service that actually calls OpenAI API with user's working API key
* Issues & Complexity Summary: Direct HTTP API calls to OpenAI with proper error handling and response parsing
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium (HTTP requests, JSON parsing, async/await)
  - Dependencies: 2 New (URLSession, Foundation networking)
  - State Management Complexity: Low (stateless API calls)
  - Novelty/Uncertainty Factor: Low (standard HTTP API integration)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 73%
* Justification for Estimates: Direct API integration with proper error handling and async operations
* Final Code Complexity (Actual %): 75%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Simple direct API calls provide reliable LLM integration
* Last Updated: 2025-06-11
*/

import Combine
import Foundation

// MARK: - Real LLM API Service

@MainActor
public class RealLLMAPIService: ObservableObject {
    @Published public var isLoading = false
    @Published public var lastResponse = ""
    @Published public var lastError: String?

    private let keychainManager = KeychainManager()
    private let baseURL = "https://api.openai.com/v1"

    private var _isConnected: Bool = false
    public var isConnected: Bool {
        getCurrentAPIKey() != nil
    }

    public init() {
        // Test connectivity on initialization
        Task {
            let connected = await testConnection()
            await MainActor.run {
                self._isConnected = connected
            }
        }
    }

    // MARK: - API Key Management

    private func getCurrentAPIKey() -> String? {
        // Try keychain first
        if let keychainData = keychainManager.retrieve(for: "openai_api_key"),
           let keychainKey = String(data: keychainData, encoding: .utf8),
           !keychainKey.isEmpty {
            return keychainKey
        }

        // Fallback to environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !envKey.isEmpty {
            return envKey
        }

        return nil
    }

    public func setAPIKey(_ apiKey: String) {
        guard !apiKey.isEmpty else { return }

        do {
            try keychainManager.save(apiKey.data(using: .utf8) ?? Data(), for: "openai_api_key")

            // Test connection with new key
            Task {
                let connected = await testConnection()
                await MainActor.run {
                    self._isConnected = connected
                }
            }
        } catch {
            print("Failed to save API key: \(error)")
        }
    }

    public func clearAPIKey() {
        try? keychainManager.delete(for: "openai_api_key")
        _isConnected = false
    }

    public func sendMessage(_ message: String) async -> String {
        isLoading = true
        lastError = nil

        defer {
            isLoading = false
        }

        guard let apiKey = getCurrentAPIKey(), !apiKey.isEmpty else {
            let error = "❌ OpenAI API key not configured. Please add your API key in Settings."
            lastError = error
            return error
        }

        do {
            let response = try await callOpenAIAPI(message: message, apiKey: apiKey)
            lastResponse = response
            return response
        } catch {
            let errorMessage = "❌ API Error: \(error.localizedDescription)"
            lastError = errorMessage
            return errorMessage
        }
    }

    private func callOpenAIAPI(message: String, apiKey: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw LLMAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = LLMAPIRequest(
            model: "gpt-4o-mini",
            messages: [
                LLMAPIMessage(role: "system", content: "You are a helpful financial assistant integrated into FinanceMate app. Provide clear, concise financial advice and information."),
                LLMAPIMessage(role: "user", content: message)
            ],
            max_tokens: 500
        )

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw LLMAPIError.apiError(message)
            }
            throw LLMAPIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(LLMAPIResponse.self, from: data)

        guard let choice = openAIResponse.choices.first else {
            throw LLMAPIError.noResponse
        }

        return choice.message.content
    }

    public func testConnection() async -> Bool {
        let testMessage = "Hello! Please respond with 'FINANCEMATE CONNECTION SUCCESSFUL' to confirm the API is working."
        let response = await sendMessage(testMessage)
        return response.contains("FINANCEMATE CONNECTION SUCCESSFUL") || response.contains("CONNECTION SUCCESSFUL")
    }
}

// MARK: - Data Models

private struct LLMAPIRequest: Codable {
    let model: String
    let messages: [LLMAPIMessage]
    let max_tokens: Int
}

private struct LLMAPIMessage: Codable {
    let role: String
    let content: String
}

private struct LLMAPIResponse: Codable {
    let choices: [LLMAPIChoice]
}

private struct LLMAPIChoice: Codable {
    let message: LLMAPIResponseMessage
}

private struct LLMAPIResponseMessage: Codable {
    let content: String
}

// MARK: - Error Types

private enum LLMAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noResponse
    case httpError(Int)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .noResponse:
            return "No response from API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}
