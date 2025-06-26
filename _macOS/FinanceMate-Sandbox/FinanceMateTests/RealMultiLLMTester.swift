//
//  RealMultiLLMTester.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Real Multi-LLM API testing with actual frontier model calls and token consumption
* Issues & Complexity Summary: Actual API integration across multiple LLM providers for comparative analysis
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: High
  - Dependencies: 3 New (AnthropicAPI, OpenAIAPI, GoogleAI)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 82%
* Justification for Estimates: Real API integration with error handling and comparative analysis
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: Implementing actual token-consuming API calls
* Last Updated: 2025-06-02
*/

import Foundation
import Combine

// MARK: - Real Multi-LLM Tester

@MainActor
public class RealMultiLLMTester: ObservableObject {

    // MARK: - Published Properties

    @Published public var isRunning: Bool = false
    @Published public var testResults: [MultiLLMTestResult] = []
    @Published public var totalTokensUsed: Int = 0
    @Published public var currentProgress: Double = 0.0

    // MARK: - API Clients

    private let anthropicClient: AnthropicAPIClient
    private let openAIClient: OpenAIAPIClient
    private let googleAIClient: GoogleAIAPIClient

    // MARK: - Configuration

    private let testPrompts: [String] = [
        "Analyze the financial implications of a $50,000 business loan with 6% APR over 5 years. Calculate monthly payments, total interest, and ROI considerations.",
        "Create a comprehensive budget breakdown for a tech startup with $100,000 initial funding, including operational costs, marketing, and growth projections.",
        "Explain cryptocurrency investment risks and opportunities for a portfolio worth $25,000, focusing on diversification strategies.",
        "Generate a financial report summary for Q3 performance showing 15% revenue growth, 8% increase in expenses, and market expansion opportunities."
    ]

    // MARK: - Initialization

    public init() {
        // Initialize real API clients with environment variables or configuration
        self.anthropicClient = AnthropicAPIClient()
        self.openAIClient = OpenAIAPIClient()
        self.googleAIClient = GoogleAIAPIClient()
    }

    // MARK: - Real Multi-LLM Testing

    public func executeRealMultiLLMTest() async {
        print("🚀 Starting REAL Multi-LLM Testing with API Token Consumption")

        isRunning = true
        testResults.removeAll()
        totalTokensUsed = 0
        currentProgress = 0.0

        let totalTests = testPrompts.count * 3 // 3 models per prompt
        var completedTests = 0

        for (index, prompt) in testPrompts.enumerated() {
            print("\n📝 Testing Prompt \(index + 1): \(prompt.prefix(50))...")

            // Test with Claude (Anthropic)
            if let claudeResult = await testWithClaude(prompt: prompt) {
                testResults.append(claudeResult)
                totalTokensUsed += claudeResult.tokensUsed
                print("✅ Claude response: \(claudeResult.response.prefix(100))...")
            }

            completedTests += 1
            currentProgress = Double(completedTests) / Double(totalTests)

            // Test with GPT-4 (OpenAI)
            if let gptResult = await testWithGPT4(prompt: prompt) {
                testResults.append(gptResult)
                totalTokensUsed += gptResult.tokensUsed
                print("✅ GPT-4 response: \(gptResult.response.prefix(100))...")
            }

            completedTests += 1
            currentProgress = Double(completedTests) / Double(totalTests)

            // Test with Gemini (Google)
            if let geminiResult = await testWithGemini(prompt: prompt) {
                testResults.append(geminiResult)
                totalTokensUsed += geminiResult.tokensUsed
                print("✅ Gemini response: \(geminiResult.response.prefix(100))...")
            }

            completedTests += 1
            currentProgress = Double(completedTests) / Double(totalTests)

            // Small delay between prompts to avoid rate limiting
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }

        // Generate comparative analysis
        await generateComparativeAnalysis()

        isRunning = false
        print("\n🎉 Real Multi-LLM Testing Complete!")
        print("📊 Total API Tokens Consumed: \(totalTokensUsed)")
        print("📈 Test Results: \(testResults.count) successful API calls")
    }

    // MARK: - Individual Model Testing

    private func testWithClaude(prompt: String) async -> MultiLLMTestResult? {
        do {
            let startTime = Date()

            // REAL API CALL TO ANTHROPIC CLAUDE
            let response = try await anthropicClient.complete(
                prompt: prompt,
                model: "claude-3-sonnet-20240229",
                maxTokens: 1000
            )

            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)

            return MultiLLMTestResult(
                model: "Claude-3-Sonnet",
                provider: "Anthropic",
                prompt: prompt,
                response: response.content,
                tokensUsed: response.usage.outputTokens + response.usage.inputTokens,
                responseTime: responseTime,
                timestamp: Date(),
                success: true
            )

        } catch {
            print("❌ Claude API Error: \(error)")
            return MultiLLMTestResult(
                model: "Claude-3-Sonnet",
                provider: "Anthropic",
                prompt: prompt,
                response: "API Error: \(error.localizedDescription)",
                tokensUsed: 0,
                responseTime: 0,
                timestamp: Date(),
                success: false,
                error: error
            )
        }
    }

    private func testWithGPT4(prompt: String) async -> MultiLLMTestResult? {
        do {
            let startTime = Date()

            // REAL API CALL TO OPENAI GPT-4
            let response = try await openAIClient.chatCompletion(
                messages: [
                    OpenAIMessage(role: "user", content: prompt)
                ],
                model: "gpt-4-turbo-preview",
                maxTokens: 1000
            )

            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)

            return MultiLLMTestResult(
                model: "GPT-4-Turbo",
                provider: "OpenAI",
                prompt: prompt,
                response: response.choices.first?.message.content ?? "No response",
                tokensUsed: response.usage.totalTokens,
                responseTime: responseTime,
                timestamp: Date(),
                success: true
            )

        } catch {
            print("❌ GPT-4 API Error: \(error)")
            return MultiLLMTestResult(
                model: "GPT-4-Turbo",
                provider: "OpenAI",
                prompt: prompt,
                response: "API Error: \(error.localizedDescription)",
                tokensUsed: 0,
                responseTime: 0,
                timestamp: Date(),
                success: false,
                error: error
            )
        }
    }

    private func testWithGemini(prompt: String) async -> MultiLLMTestResult? {
        do {
            let startTime = Date()

            // REAL API CALL TO GOOGLE GEMINI
            let response = try await googleAIClient.generateContent(
                prompt: prompt,
                model: "gemini-pro",
                maxTokens: 1000
            )

            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)

            return MultiLLMTestResult(
                model: "Gemini-Pro",
                provider: "Google",
                prompt: prompt,
                response: response.candidates.first?.content.parts.first?.text ?? "No response",
                tokensUsed: response.usageMetadata?.totalTokenCount ?? 0,
                responseTime: responseTime,
                timestamp: Date(),
                success: true
            )

        } catch {
            print("❌ Gemini API Error: \(error)")
            return MultiLLMTestResult(
                model: "Gemini-Pro",
                provider: "Google",
                prompt: prompt,
                response: "API Error: \(error.localizedDescription)",
                tokensUsed: 0,
                responseTime: 0,
                timestamp: Date(),
                success: false,
                error: error
            )
        }
    }

    // MARK: - Comparative Analysis

    private func generateComparativeAnalysis() async {
        print("\n📊 COMPARATIVE ANALYSIS:")
        print(String(repeating: "=", count: 50))

        let successfulResults = testResults.filter { $0.success }

        // Group by model
        let claudeResults = successfulResults.filter { $0.provider == "Anthropic" }
        let gptResults = successfulResults.filter { $0.provider == "OpenAI" }
        let geminiResults = successfulResults.filter { $0.provider == "Google" }

        // Calculate averages
        if !claudeResults.isEmpty {
            let avgTokens = claudeResults.map { $0.tokensUsed }.reduce(0, +) / claudeResults.count
            let avgTime = claudeResults.map { $0.responseTime }.reduce(0, +) / Double(claudeResults.count)
            print("🤖 Claude-3-Sonnet: \(claudeResults.count) tests, avg \(avgTokens) tokens, \(String(format: "%.2f", avgTime))s")
        }

        if !gptResults.isEmpty {
            let avgTokens = gptResults.map { $0.tokensUsed }.reduce(0, +) / gptResults.count
            let avgTime = gptResults.map { $0.responseTime }.reduce(0, +) / Double(gptResults.count)
            print("🤖 GPT-4-Turbo: \(gptResults.count) tests, avg \(avgTokens) tokens, \(String(format: "%.2f", avgTime))s")
        }

        if !geminiResults.isEmpty {
            let avgTokens = geminiResults.map { $0.tokensUsed }.reduce(0, +) / geminiResults.count
            let avgTime = geminiResults.map { $0.responseTime }.reduce(0, +) / Double(geminiResults.count)
            print("🤖 Gemini-Pro: \(geminiResults.count) tests, avg \(avgTokens) tokens, \(String(format: "%.2f", avgTime))s")
        }

        print("\n💰 Total Cost Analysis:")
        print("Total Tokens Consumed: \(totalTokensUsed)")
        print("Successful API Calls: \(successfulResults.count)")
        print("Failed API Calls: \(testResults.count - successfulResults.count)")
    }

    // MARK: - Test Results Export

    public func exportTestResults() -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try jsonEncoder.encode(testResults)
            return String(data: jsonData, encoding: .utf8) ?? "Export failed"
        } catch {
            return "Export error: \(error)"
        }
    }
}

// MARK: - Data Models

public struct MultiLLMTestResult: Codable {
    public let model: String
    public let provider: String
    public let prompt: String
    public let response: String
    public let tokensUsed: Int
    public let responseTime: TimeInterval
    public let timestamp: Date
    public let success: Bool
    public let error: Error?

    public init(
        model: String,
        provider: String,
        prompt: String,
        response: String,
        tokensUsed: Int,
        responseTime: TimeInterval,
        timestamp: Date,
        success: Bool,
        error: Error? = nil
    ) {
        self.model = model
        self.provider = provider
        self.prompt = prompt
        self.response = response
        self.tokensUsed = tokensUsed
        self.responseTime = responseTime
        self.timestamp = timestamp
        self.success = success
        self.error = error
    }

    // Custom Codable implementation to handle Error
    enum CodingKeys: String, CodingKey {
        case model, provider, prompt, response, tokensUsed, responseTime, timestamp, success, errorDescription
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(provider, forKey: .provider)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(response, forKey: .response)
        try container.encode(tokensUsed, forKey: .tokensUsed)
        try container.encode(responseTime, forKey: .responseTime)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(error?.localizedDescription, forKey: .errorDescription)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        model = try container.decode(String.self, forKey: .model)
        provider = try container.decode(String.self, forKey: .provider)
        prompt = try container.decode(String.self, forKey: .prompt)
        response = try container.decode(String.self, forKey: .response)
        tokensUsed = try container.decode(Int.self, forKey: .tokensUsed)
        responseTime = try container.decode(TimeInterval.self, forKey: .responseTime)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        success = try container.decode(Bool.self, forKey: .success)

        if let errorDesc = try container.decodeIfPresent(String.self, forKey: .errorDescription) {
            self.error = NSError(domain: "MultiLLMTest", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDesc])
        } else {
            self.error = nil
        }
    }
}

// MARK: - API Client Protocols and Implementations

// Real Anthropic API Client
public class AnthropicAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"

    public init() {
        // Get API key from environment or configuration
        self.apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    public func complete(prompt: String, model: String, maxTokens: Int) async throws -> AnthropicResponse {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey("ANTHROPIC_API_KEY not set")
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let requestBody = AnthropicRequest(
            model: model,
            maxTokens: maxTokens,
            messages: [AnthropicMessage(role: "user", content: prompt)]
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(AnthropicResponse.self, from: data)
    }
}

// Real OpenAI API Client
public class OpenAIAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    public init() {
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    public func chatCompletion(messages: [OpenAIMessage], model: String, maxTokens: Int) async throws -> OpenAIResponse {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey("OPENAI_API_KEY not set")
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody = OpenAIRequest(
            model: model,
            messages: messages,
            maxTokens: maxTokens
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(OpenAIResponse.self, from: data)
    }
}

// Real Google AI API Client
public class GoogleAIAPIClient {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models"

    public init() {
        self.apiKey = ProcessInfo.processInfo.environment["GOOGLE_AI_API_KEY"] ?? ""
    }

    public func generateContent(prompt: String, model: String, maxTokens: Int) async throws -> GoogleAIResponse {
        guard !apiKey.isEmpty else {
            throw APIError.missingAPIKey("GOOGLE_AI_API_KEY not set")
        }

        let url = "\(baseURL)/\(model):generateContent?key=\(apiKey)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = GoogleAIRequest(
            contents: [GoogleAIContent(parts: [GoogleAIPart(text: prompt)])],
            generationConfig: GoogleAIGenerationConfig(maxOutputTokens: maxTokens)
        )

        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw APIError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(GoogleAIResponse.self, from: data)
    }
}

// MARK: - API Data Models

// Anthropic Models
public struct AnthropicRequest: Codable {
    let model: String
    let maxTokens: Int
    let messages: [AnthropicMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
    }
}

public struct AnthropicMessage: Codable {
    let role: String
    let content: String
}

public struct AnthropicResponse: Codable {
    let content: String
    let usage: AnthropicUsage

    // Handle the actual Anthropic response structure
    enum CodingKeys: String, CodingKey {
        case content
        case usage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Anthropic returns content as array, get first text content
        if let contentArray = try? container.decode([AnthropicContentBlock].self, forKey: .content) {
            self.content = contentArray.first?.text ?? ""
        } else {
            self.content = ""
        }

        self.usage = try container.decode(AnthropicUsage.self, forKey: .usage)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(usage, forKey: .usage)
    }
}

public struct AnthropicContentBlock: Codable {
    let type: String
    let text: String
}

public struct AnthropicUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

// OpenAI Models
public struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
    }
}

public struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

public struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

public struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

public struct OpenAIUsage: Codable {
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case totalTokens = "total_tokens"
    }
}

// Google AI Models
public struct GoogleAIRequest: Codable {
    let contents: [GoogleAIContent]
    let generationConfig: GoogleAIGenerationConfig
}

public struct GoogleAIContent: Codable {
    let parts: [GoogleAIPart]
}

public struct GoogleAIPart: Codable {
    let text: String
}

public struct GoogleAIGenerationConfig: Codable {
    let maxOutputTokens: Int
}

public struct GoogleAIResponse: Codable {
    let candidates: [GoogleAICandidate]
    let usageMetadata: GoogleAIUsageMetadata?
}

public struct GoogleAICandidate: Codable {
    let content: GoogleAIContent
}

public struct GoogleAIUsageMetadata: Codable {
    let totalTokenCount: Int
}

// Error Types
public enum APIError: Error {
    case missingAPIKey(String)
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
}
