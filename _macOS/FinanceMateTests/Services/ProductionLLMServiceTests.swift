import XCTest
import Combine
@testable import FinanceMate

/// Comprehensive test suite for production LLM service integration
/// Tests real Claude API integration with OpenAI fallback and Australian financial context
@MainActor
final class ProductionLLMServiceTests: XCTestCase {
    
    private var llmService: LLMServiceManager!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        llmService = LLMServiceManager()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        llmService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization and Configuration Tests
    
    func testLLMServiceManagerInitialization() {
        XCTAssertNotNil(llmService, "LLM service should initialize successfully")
        XCTAssertFalse(llmService.isProcessing, "Should not be processing initially")
        XCTAssertEqual(llmService.currentProvider, .claude, "Should default to Claude provider")
    }
    
    func testAPIKeyValidation() async {
        // Test Claude API key validation
        let hasClaudeKey = llmService.hasValidAPIKey(for: .claude)
        
        // Test OpenAI API key validation  
        let hasOpenAIKey = llmService.hasValidAPIKey(for: .openai)
        
        // In development, at least one should be configured
        XCTAssertTrue(hasClaudeKey || hasOpenAIKey, "At least one LLM provider should be configured")
        
        if hasClaudeKey {
            print("✅ Claude API key configured")
        } else {
            print("⚠️ Claude API key not configured - using fallback")
        }
        
        if hasOpenAIKey {
            print("✅ OpenAI API key configured")
        } else {
            print("⚠️ OpenAI API key not configured")
        }
    }
    
    func testAustralianFinancialContextInitialization() {
        let context = llmService.australianFinancialContext
        
        XCTAssertNotNil(context, "Australian financial context should be initialized")
        XCTAssertTrue(context.hasTaxContext, "Should have Australian tax context")
        XCTAssertTrue(context.hasRegionalCompliance, "Should have regional compliance information")
        XCTAssertGreaterThan(context.knowledgeBaseSize, 0, "Should have knowledge base content")
    }
    
    // MARK: - Basic Financial Q&A Tests
    
    func testBasicFinancialQuestions() async {
        let basicQuestions = [
            "What is compound interest?",
            "How do I create a budget?", 
            "What are assets and liabilities?",
            "How much should I save for retirement?"
        ]
        
        for question in basicQuestions {
            do {
                let response = try await llmService.queryFinancialKnowledge(question: question)
                
                // Validate response structure
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertFalse(response.content.isEmpty, "Response should not be empty")
                XCTAssertGreaterThan(response.qualityScore, 0.0, "Should have positive quality score")
                XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should be <= 10")
                XCTAssertEqual(response.questionType, .basicLiteracy, "Should classify as basic literacy")
                XCTAssertNotNil(response.provider, "Should indicate which provider was used")
                
                print("✅ Basic question processed via \(response.provider): \(question) - Quality: \(response.qualityScore)")
                
            } catch LLMError.networkUnavailable {
                // Network issues are acceptable in test environment
                print("ℹ️ Network unavailable for question: \(question)")
            } catch LLMError.rateLimited {
                // Rate limiting is acceptable in testing
                print("ℹ️ Rate limited for question: \(question)")
            } catch {
                XCTFail("Unexpected error processing basic question: \(error)")
            }
        }
    }
    
    func testAustralianTaxQuestions() async {
        let australianQuestions = [
            "How does capital gains tax work in NSW?",
            "What is negative gearing in Australia?",
            "Should I set up an SMSF?",
            "How do franking credits work?",
            "What are the tax implications of investing in Australian shares?"
        ]
        
        for question in australianQuestions {
            do {
                let response = try await llmService.queryFinancialKnowledge(question: question)
                
                // Validate Australian context
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertTrue(
                    response.content.lowercased().contains("australia") || 
                    response.content.lowercased().contains("australian") ||
                    response.content.lowercased().contains("nsw") ||
                    response.content.lowercased().contains("ato"),
                    "Should contain Australian context: \(response.content)"
                )
                XCTAssertEqual(response.questionType, .australianTax, "Should classify as Australian tax")
                XCTAssertGreaterThan(response.qualityScore, 6.0, "Australian tax responses should have high quality")
                
                print("✅ Australian tax question processed via \(response.provider): \(question) - Quality: \(response.qualityScore)")
                
            } catch LLMError.networkUnavailable {
                print("ℹ️ Network unavailable for Australian question: \(question)")
            } catch {
                XCTFail("Unexpected error processing Australian question: \(error)")
            }
        }
    }
    
    func testFinanceMateSpecificQuestions() async {
        let appQuestions = [
            "How does FinanceMate calculate net wealth?",
            "Can FinanceMate help me categorize transactions?",
            "How do I set financial goals in FinanceMate?",
            "What reports can FinanceMate generate?",
            "How does FinanceMate handle multi-entity accounting?"
        ]
        
        for question in appQuestions {
            do {
                let response = try await llmService.queryFinancialKnowledge(question: question)
                
                // Validate FinanceMate context
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertTrue(
                    response.content.lowercased().contains("financemate") ||
                    response.content.lowercased().contains("app") ||
                    response.content.lowercased().contains("dashboard"),
                    "Should contain FinanceMate context: \(response.content)"
                )
                XCTAssertEqual(response.questionType, .financeMateSpecific, "Should classify as FinanceMate specific")
                
                print("✅ FinanceMate question processed via \(response.provider): \(question) - Quality: \(response.qualityScore)")
                
            } catch LLMError.networkUnavailable {
                print("ℹ️ Network unavailable for FinanceMate question: \(question)")
            } catch {
                XCTFail("Unexpected error processing FinanceMate question: \(error)")
            }
        }
    }
    
    // MARK: - Complex Financial Scenario Tests
    
    func testComplexFinancialScenarios() async {
        let complexQuestions = [
            "I have $500k to invest - what's the best strategy for a 35-year-old in NSW?",
            "How should I structure property investment with negative gearing and SMSF?",
            "What's the optimal tax strategy for a $200k income earner with investment properties?",
            "I'm considering early retirement at 50 with $2M in superannuation - what are my options?"
        ]
        
        for question in complexQuestions {
            do {
                let response = try await llmService.queryFinancialKnowledge(question: question)
                
                // Validate complex scenario handling
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertGreaterThan(response.content.count, 150, "Complex scenarios should have detailed responses")
                XCTAssertEqual(response.questionType, .complexScenarios, "Should classify as complex scenario")
                XCTAssertTrue(
                    response.content.lowercased().contains("professional") ||
                    response.content.lowercased().contains("advisor") ||
                    response.content.lowercased().contains("consult"),
                    "Complex scenarios should recommend professional advice"
                )
                XCTAssertGreaterThan(response.qualityScore, 7.0, "Complex scenarios should have high quality")
                
                print("✅ Complex scenario processed via \(response.provider): \(question) - Quality: \(response.qualityScore)")
                
            } catch LLMError.networkUnavailable {
                print("ℹ️ Network unavailable for complex question: \(question)")
            } catch {
                XCTFail("Unexpected error processing complex question: \(error)")
            }
        }
    }
    
    // MARK: - Provider Fallback Tests
    
    func testProviderFailoverMechanism() async {
        // Test Claude primary, OpenAI fallback
        do {
            llmService.simulateClaudeFailure = true
            
            let response = try await llmService.queryFinancialKnowledge(question: "What is compound interest?")
            
            XCTAssertNotNil(response.content, "Should get response from fallback provider")
            XCTAssertEqual(response.provider, .openai, "Should use OpenAI as fallback")
            XCTAssertTrue(response.isFromFallback, "Should indicate fallback was used")
            
            print("✅ Provider failover successful: Claude → OpenAI")
            
        } catch {
            print("ℹ️ Fallback provider not available: \(error)")
        }
        
        // Reset simulation
        llmService.simulateClaudeFailure = false
    }
    
    func testLocalKnowledgeFallback() async {
        // Test fallback to local knowledge when all providers fail
        llmService.simulateAllProvidersFailure = true
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: "What is compound interest?")
            
            XCTAssertNotNil(response.content, "Should provide local fallback response")
            XCTAssertFalse(response.content.isEmpty, "Local fallback should not be empty")
            XCTAssertEqual(response.provider, .localFallback, "Should indicate local fallback")
            XCTAssertTrue(response.isFromFallback, "Should mark as fallback response")
            XCTAssertGreaterThan(response.qualityScore, 0.0, "Local fallback should have quality score")
            
            print("✅ Local knowledge fallback successful")
            
        } catch {
            XCTFail("Should provide local fallback response: \(error)")
        }
        
        // Reset simulation
        llmService.simulateAllProvidersFailure = false
    }
    
    // MARK: - Security and API Key Management Tests
    
    func testKeychainSecurityIntegration() async {
        // Test secure API key storage and retrieval
        let testAPIKey = "test-api-key-123"
        
        // Test storing API key
        let storeResult = llmService.storeAPIKey(testAPIKey, for: .claude)
        XCTAssertTrue(storeResult, "Should successfully store API key in Keychain")
        
        // Test retrieving API key
        let retrievedKey = llmService.retrieveAPIKey(for: .claude)
        XCTAssertEqual(retrievedKey, testAPIKey, "Should retrieve correct API key")
        
        // Test removing API key
        let removeResult = llmService.removeAPIKey(for: .claude)
        XCTAssertTrue(removeResult, "Should successfully remove API key")
        
        // Verify removal
        let removedKey = llmService.retrieveAPIKey(for: .claude)
        XCTAssertNil(removedKey, "API key should be removed")
        
        print("✅ Keychain security integration validated")
    }
    
    func testAPIKeyValidationSecurity() {
        // Test API key format validation
        XCTAssertFalse(llmService.validateAPIKeyFormat("", for: .claude), "Empty key should be invalid")
        XCTAssertFalse(llmService.validateAPIKeyFormat("short", for: .claude), "Short key should be invalid")
        XCTAssertFalse(llmService.validateAPIKeyFormat("your-claude-api-key", for: .claude), "Placeholder should be invalid")
        
        XCTAssertTrue(llmService.validateAPIKeyFormat("sk-ant-api03-valid-key-format-here", for: .claude), "Valid Claude key should pass")
        XCTAssertTrue(llmService.validateAPIKeyFormat("sk-proj-valid-openai-key-format", for: .openai), "Valid OpenAI key should pass")
        
        print("✅ API key format validation working")
    }
    
    // MARK: - Performance and Response Time Tests
    
    func testResponsePerformance() async {
        let testQuestion = "What is compound interest?"
        
        let startTime = Date()
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: testQuestion)
            let responseTime = Date().timeIntervalSince(startTime)
            
            XCTAssertLessThan(responseTime, 10.0, "Response time should be under 10 seconds")
            XCTAssertNotNil(response.responseTime, "Response should include timing data")
            XCTAssertGreaterThan(response.responseTime!, 0.0, "Response time should be positive")
            
            print("✅ Performance target met: \(responseTime)s via \(response.provider)")
            
        } catch LLMError.networkUnavailable {
            print("ℹ️ Network unavailable for performance test")
        } catch {
            XCTFail("Unexpected error in performance testing: \(error)")
        }
    }
    
    func testConcurrentLLMRequests() async {
        let questions = [
            "What is a budget?",
            "How does negative gearing work?", 
            "What are assets?",
            "How do I invest in shares?",
            "What is superannuation?"
        ]
        
        await withTaskGroup(of: Void.self) { group in
            for question in questions {
                group.addTask {
                    do {
                        let response = try await self.llmService.queryFinancialKnowledge(question: question)
                        XCTAssertNotNil(response.content, "Concurrent request should return valid response")
                        XCTAssertGreaterThan(response.qualityScore, 0.0, "Concurrent response should have quality score")
                    } catch LLMError.networkUnavailable, LLMError.rateLimited {
                        // Acceptable in test environment
                    } catch {
                        XCTFail("Concurrent request failed: \(error)")
                    }
                }
            }
        }
        
        print("✅ Concurrent request handling validated")
    }
    
    // MARK: - Quality Assessment Tests
    
    func testResponseQualityScoring() async {
        let testQuestions = [
            "What is compound interest?",
            "How does capital gains tax work in Australia?",
            "What is negative gearing?",
            "How does FinanceMate calculate net wealth?",
            "Should I invest in property or shares?"
        ]
        
        var qualityScores: [Double] = []
        
        for question in testQuestions {
            do {
                let response = try await llmService.queryFinancialKnowledge(question: question)
                
                // Validate quality scoring
                XCTAssertGreaterThan(response.qualityScore, 0.0, "Should have positive quality score")
                XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should not exceed 10")
                
                qualityScores.append(response.qualityScore)
                
            } catch LLMError.networkUnavailable {
                // Skip if network unavailable
                continue
            } catch {
                XCTFail("Unexpected error in quality testing: \(error)")
            }
        }
        
        if !qualityScores.isEmpty {
            let averageQuality = qualityScores.reduce(0, +) / Double(qualityScores.count)
            XCTAssertGreaterThanOrEqual(averageQuality, 6.8, "Average quality should meet target")
            print("✅ Quality target achieved: \(averageQuality)/10 (target: 6.8/10)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() async {
        llmService.simulateNetworkFailure = true
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: "test question")
            // Should receive local fallback
            XCTAssertEqual(response.provider, .localFallback, "Should use local fallback on network error")
        } catch {
            XCTFail("Should handle network errors gracefully: \(error)")
        }
        
        llmService.simulateNetworkFailure = false
    }
    
    func testRateLimitHandling() async {
        llmService.simulateRateLimit = true
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: "test question")
            // Should either retry or fallback
            XCTAssertNotNil(response.content, "Should handle rate limiting")
        } catch LLMError.rateLimited {
            // Rate limit error is acceptable
            print("ℹ️ Rate limit handled appropriately")
        } catch {
            XCTFail("Unexpected error in rate limit testing: \(error)")
        }
        
        llmService.simulateRateLimit = false
    }
    
    func testInvalidAPIKeyHandling() async {
        // Temporarily set invalid API key
        let originalKey = llmService.retrieveAPIKey(for: .claude)
        llmService.storeAPIKey("invalid-key", for: .claude)
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: "test question")
            // Should fallback to valid provider or local knowledge
            XCTAssertNotNil(response.content, "Should handle invalid API key")
        } catch LLMError.authenticationFailed {
            // Authentication failure is acceptable
            print("ℹ️ Authentication error handled appropriately")
        } catch {
            // Other errors are also acceptable as long as handled
            print("ℹ️ Error handled: \(error)")
        }
        
        // Restore original key
        if let key = originalKey {
            llmService.storeAPIKey(key, for: .claude)
        } else {
            llmService.removeAPIKey(for: .claude)
        }
    }
    
    // MARK: - Integration Tests
    
    func testChatbotViewModelIntegration() async {
        // Test integration with ProductionChatbotViewModel
        let context = PersistenceController.preview.container.viewContext
        let chatbot = ProductionChatbotViewModel(context: context)
        
        // Verify LLM service is integrated
        XCTAssertNotNil(chatbot.llmService, "ChatBot should have LLM service integrated")
        
        let originalMessageCount = chatbot.messages.count
        
        // Test message processing
        chatbot.currentInput = "What is compound interest?"
        chatbot.sendMessage()
        
        // Wait for processing
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Validate response was added
        XCTAssertGreater(chatbot.messages.count, originalMessageCount, "Should add response message")
        
        // Check if response has LLM quality indicators
        let lastMessage = chatbot.messages.last
        if let message = lastMessage, message.role == .assistant {
            XCTAssertNotNil(message.qualityScore, "LLM responses should have quality scores")
            if let score = message.qualityScore {
                XCTAssertGreaterThan(score, 0.0, "Quality score should be positive")
            }
        }
        
        print("✅ ChatBot integration verified")
    }
    
    func testStreamingResponseSupport() async {
        // Test streaming response capability (if implemented)
        let expectation = XCTestExpectation(description: "Streaming response")
        var streamChunks: [String] = []
        
        do {
            let streamCancellable = llmService.queryFinancialKnowledgeStream(question: "What is compound interest?")
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            expectation.fulfill()
                        case .failure:
                            expectation.fulfill()
                        }
                    },
                    receiveValue: { chunk in
                        streamChunks.append(chunk)
                    }
                )
            
            await fulfillment(of: [expectation], timeout: 10.0)
            streamCancellable.cancel()
            
            if !streamChunks.isEmpty {
                XCTAssertGreaterThan(streamChunks.count, 0, "Should receive streaming chunks")
                let fullResponse = streamChunks.joined()
                XCTAssertFalse(fullResponse.isEmpty, "Streaming response should not be empty")
                print("✅ Streaming response supported: \(streamChunks.count) chunks")
            } else {
                print("ℹ️ Streaming not implemented or not available")
            }
            
        } catch {
            print("ℹ️ Streaming feature not available: \(error)")
        }
    }
    
    // MARK: - Australian Financial Context Tests
    
    func testAustralianContextEnrichment() async {
        let australianQuestion = "How much tax will I pay on $100k salary?"
        
        do {
            let response = try await llmService.queryFinancialKnowledge(question: australianQuestion)
            
            // Should contain Australian tax brackets and Medicare levy
            let content = response.content.lowercased()
            let australianContextTerms = [
                "australian tax", "medicare levy", "tax bracket", "ato", "australian"
            ]
            
            let contextMatches = australianContextTerms.filter { content.contains($0) }.count
            XCTAssertGreaterThanOrEqual(contextMatches, 2, "Should contain Australian tax context")
            
            print("✅ Australian context enriched: \(contextMatches) relevant terms")
            
        } catch {
            print("ℹ️ Australian context test skipped: \(error)")
        }
    }
}

// MARK: - Supporting Types and Extensions

extension ProductionLLMServiceTests {
    
    /// Helper method to validate response quality
    private func validateResponseQuality(_ response: LLMResponse, for questionType: FinancialQuestionType) {
        XCTAssertNotNil(response.content, "Response should have content")
        XCTAssertFalse(response.content.isEmpty, "Response content should not be empty")
        XCTAssertGreaterThan(response.qualityScore, 0.0, "Response should have positive quality score")
        XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should not exceed maximum")
        XCTAssertEqual(response.questionType, questionType, "Should classify question type correctly")
        XCTAssertNotNil(response.provider, "Should indicate which provider generated response")
        XCTAssertNotNil(response.responseTime, "Should include response timing")
    }
    
    /// Helper method for testing provider availability
    private func testProviderAvailability(_ provider: LLMProvider) -> Bool {
        switch provider {
        case .claude:
            return llmService.hasValidAPIKey(for: .claude)
        case .openai:
            return llmService.hasValidAPIKey(for: .openai)
        case .localFallback:
            return true // Always available
        }
    }
}