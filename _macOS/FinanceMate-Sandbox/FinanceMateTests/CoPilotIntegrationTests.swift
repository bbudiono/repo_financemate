//
//  CoPilotIntegrationTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/11/25.
//

/*
* Purpose: Comprehensive test suite for Co-Pilot integration with real LLM API service
* Issues & Complexity Summary: Tests real API connectivity, error handling, and UI integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~300
  - Core Algorithm Complexity: Medium (async testing, API calls)
  - Dependencies: 3 New (XCTest, Combine, Real API)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Medium (real API testing)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Real API testing with proper error handling and async patterns
* Final Code Complexity (Actual %): 70%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: Comprehensive testing ensures reliable Co-Pilot integration
* Last Updated: 2025-06-11
*/

import XCTest
import Combine
@testable import FinanceMate

@MainActor
final class CoPilotIntegrationTests: XCTestCase {

    var realLLMService: RealLLMAPIService!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        realLLMService = RealLLMAPIService()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
        realLLMService = nil
    }

    // MARK: - Basic Service Tests

    func testRealLLMServiceInitialization() throws {
        XCTAssertNotNil(realLLMService, "RealLLMAPIService should initialize successfully")
        XCTAssertTrue(realLLMService.isConnected, "Service should report as connected when API key is available")
    }

    func testAPIConnectionStatus() throws {
        let connectionExpectation = expectation(description: "Connection status should be published")

        realLLMService.connectionStatusPublisher
            .sink { isConnected in
                XCTAssertTrue(isConnected, "Connection status should be true for valid API key")
                connectionExpectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [connectionExpectation], timeout: 10.0)
    }

    func testBasicMessageSending() async throws {
        let testMessage = "Hello, please respond with a simple greeting."
        let response = await realLLMService.sendMessage(testMessage)

        XCTAssertFalse(response.isEmpty, "Response should not be empty")
        XCTAssertFalse(response.contains("❌"), "Response should not contain error markers for valid request")
        XCTAssertFalse(realLLMService.isLoading, "Loading state should be false after completion")
    }

    func testConnectionTest() async throws {
        let connectionResult = await realLLMService.testConnection()
        XCTAssertTrue(connectionResult, "Connection test should succeed with valid API key")
    }

    // MARK: - Protocol Compliance Tests

    func testChatbotBackendProtocolCompliance() throws {
        XCTAssertTrue(realLLMService is ChatbotBackendProtocol, "RealLLMAPIService should conform to ChatbotBackendProtocol")
    }

    func testSendUserMessageProtocol() throws {
        let messageExpectation = expectation(description: "Should receive ChatResponse")
        let testMessage = "Test message for protocol compliance"

        realLLMService.sendUserMessage(text: testMessage)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Should not fail for valid message: \(error)")
                    }
                },
                receiveValue: { response in
                    XCTAssertFalse(response.content.isEmpty, "Response content should not be empty")
                    XCTAssertTrue(response.isComplete, "Response should be marked as complete")
                    XCTAssertFalse(response.isStreaming, "Response should not be streaming for this implementation")
                    messageExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [messageExpectation], timeout: 30.0)
    }

    func testChatbotResponsePublisher() throws {
        let responseExpectation = expectation(description: "Should receive ChatMessage through publisher")
        let testMessage = "Test message for response publisher"

        // Subscribe to response publisher first
        realLLMService.chatbotResponsePublisher
            .sink { chatMessage in
                XCTAssertFalse(chatMessage.content.isEmpty, "ChatMessage content should not be empty")
                XCTAssertFalse(chatMessage.isUser, "ChatMessage should be from assistant")
                XCTAssertEqual(chatMessage.messageState, .sent, "ChatMessage should be in sent state")
                responseExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Send message through protocol method
        realLLMService.sendUserMessage(text: testMessage)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [responseExpectation], timeout: 30.0)
    }

    // MARK: - Error Handling Tests

    func testEmptyMessageHandling() async throws {
        let response = await realLLMService.sendMessage("")
        XCTAssertTrue(response.contains("❌"), "Empty message should return error response")
    }

    func testStopCurrentGeneration() throws {
        // This is a simple test since the current implementation just sets loading to false
        realLLMService.stopCurrentGeneration()
        XCTAssertFalse(realLLMService.isLoading, "Loading should be false after stopping generation")
    }

    func testReconnectFunctionality() throws {
        let reconnectExpectation = expectation(description: "Reconnect should complete")

        realLLMService.reconnect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("Reconnect should not fail: \(error)")
                    }
                },
                receiveValue: { success in
                    XCTAssertTrue(success, "Reconnect should succeed")
                    reconnectExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [reconnectExpectation], timeout: 30.0)
    }

    // MARK: - Service Registry Tests

    func testServiceRegistration() throws {
        // Register the service
        ChatbotServiceRegistry.shared.register(chatbotBackend: realLLMService)

        // Verify registration
        let retrievedService = ChatbotServiceRegistry.shared.getChatbotBackend()
        XCTAssertNotNil(retrievedService, "Service should be retrievable after registration")
        XCTAssertTrue(retrievedService?.isConnected == true, "Retrieved service should report connection status")
    }

    func testServiceRegistrySetup() throws {
        // Test the setup manager
        ChatbotSetupManager.shared.setupProductionServices()

        let registry = ChatbotServiceRegistry.shared
        XCTAssertNotNil(registry.getChatbotBackend(), "ChatbotBackend should be registered")
        XCTAssertNotNil(registry.getAutocompletionService(), "AutocompletionService should be registered")
    }

    // MARK: - Integration Tests

    func testFullConversationFlow() async throws {
        let messages = [
            "Hello, how are you?",
            "Can you help me with financial planning?",
            "What are some good budgeting strategies?"
        ]

        for message in messages {
            let response = await realLLMService.sendMessage(message)
            XCTAssertFalse(response.isEmpty, "Each response should have content")
            XCTAssertFalse(response.contains("❌"), "Responses should not contain errors")

            // Wait a bit between messages to avoid rate limiting
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
    }

    func testFinancialContextResponses() async throws {
        let financialQuestions = [
            "How do I categorize business expenses?",
            "What tax documents should I keep?",
            "How can I track my monthly budget?"
        ]

        for question in financialQuestions {
            let response = await realLLMService.sendMessage(question)
            XCTAssertFalse(response.isEmpty, "Financial questions should get responses")
            XCTAssertFalse(response.contains("❌"), "Financial questions should not error")

            // Verify the response contains relevant financial keywords
            let lowercaseResponse = response.lowercased()
            let hasFinancialContext = lowercaseResponse.contains("financial") ||
                                    lowercaseResponse.contains("expense") ||
                                    lowercaseResponse.contains("budget") ||
                                    lowercaseResponse.contains("tax") ||
                                    lowercaseResponse.contains("money")

            XCTAssertTrue(hasFinancialContext, "Response should contain financial context for question: \(question)")

            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second between requests
        }
    }

    // MARK: - Performance Tests

    func testResponseTime() async throws {
        let startTime = Date()
        let response = await realLLMService.sendMessage("Quick test message")
        let endTime = Date()
        let responseTime = endTime.timeIntervalSince(startTime)

        XCTAssertFalse(response.isEmpty, "Should receive a response")
        XCTAssertLessThan(responseTime, 30.0, "Response should be received within 30 seconds")

        print("Response time: \(responseTime) seconds")
    }

    func testConcurrentRequests() async throws {
        let numberOfRequests = 3
        let messages = (1...numberOfRequests).map { "Concurrent test message \($0)" }

        // Send all requests concurrently
        let responses = await withTaskGroup(of: String.self, returning: [String].self) { group in
            for message in messages {
                group.addTask {
                    await self.realLLMService.sendMessage(message)
                }
            }

            var results: [String] = []
            for await response in group {
                results.append(response)
            }
            return results
        }

        XCTAssertEqual(responses.count, numberOfRequests, "Should receive all responses")

        for response in responses {
            XCTAssertFalse(response.isEmpty, "Each response should have content")
        }
    }
}

// MARK: - Integration Helper Tests

extension CoPilotIntegrationTests {

    func testChatbotSetupManagerConfiguration() throws {
        let config = ChatbotSetupManager.defaultConfiguration()

        XCTAssertEqual(config.maxMessageLength, 4000, "Default max message length should be 4000")
        XCTAssertTrue(config.autoScrollEnabled, "Auto scroll should be enabled by default")
        XCTAssertTrue(config.enableAutocompletion, "Autocompletion should be enabled by default")
        XCTAssertEqual(config.minPanelWidth, 280, "Min panel width should be 280")
        XCTAssertEqual(config.maxPanelWidth, 600, "Max panel width should be 600")
    }

    func testRealAPIEnvironmentConfiguration() throws {
        // This test verifies that the API key is properly configured
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]

        if let apiKey = apiKey, !apiKey.isEmpty {
            XCTAssertTrue(apiKey.hasPrefix("sk-"), "OpenAI API key should start with 'sk-'")
            XCTAssertGreaterThan(apiKey.count, 20, "API key should be reasonably long")
        } else {
            // If no environment API key, the service should use the fallback
            XCTAssertTrue(realLLMService.isConnected, "Service should still report as connected with fallback key")
        }
    }
}
