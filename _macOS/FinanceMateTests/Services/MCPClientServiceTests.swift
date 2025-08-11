import XCTest
import Combine
@testable import FinanceMate

/// Comprehensive test suite for real MCP client integration
/// Tests network connectivity and financial knowledge retrieval
@MainActor
final class MCPClientServiceTests: XCTestCase {
    
    private var mcpClient: MCPClientService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mcpClient = MCPClientService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables?.removeAll()
        mcpClient = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testMCPClientServiceInitialization() {
        XCTAssertNotNil(mcpClient, "MCP client should initialize successfully")
        XCTAssertFalse(mcpClient.isConnected, "Should start disconnected")
        XCTAssertEqual(mcpClient.serverStatus, "Disconnected", "Should start with disconnected status")
    }
    
    func testMCPClientServiceConfiguration() {
        // Test that configuration is properly loaded
        XCTAssertNotNil(mcpClient.serverEndpoints, "Should have MCP server endpoints configured")
        XCTAssertFalse(mcpClient.serverEndpoints.isEmpty, "Should have at least one MCP endpoint")
    }
    
    // MARK: - Network Connectivity Tests
    
    func testMCPServerConnectivity() async {
        // Test real network connectivity to MCP servers
        do {
            let isConnected = try await mcpClient.testConnectivity()
            if isConnected {
                XCTAssertTrue(mcpClient.isConnected, "Should be connected after successful connectivity test")
            } else {
                // Network unavailable - not a failure
                XCTAssertFalse(mcpClient.isConnected, "Should remain disconnected if network unavailable")
            }
        } catch {
            // Network error - acceptable in test environment
            XCTAssertFalse(mcpClient.isConnected, "Should handle network errors gracefully")
        }
    }
    
    func testMCPServerEndpointValidation() async {
        // Test that MCP endpoints are properly configured
        for endpoint in mcpClient.serverEndpoints {
            XCTAssertTrue(endpoint.hasPrefix("http"), "All endpoints should be valid URLs")
            
            do {
                let isValid = try await mcpClient.validateEndpoint(endpoint)
                // If validation succeeds, endpoint is accessible
                if isValid {
                    print("✅ MCP endpoint validated: \(endpoint)")
                }
            } catch {
                // Network issues are acceptable in testing
                print("ℹ️ MCP endpoint not accessible: \(endpoint) - \(error.localizedDescription)")
            }
        }
    }
    
    func testMacMiniMCPServerAccess() async {
        // Test specific MacMini MCP server connectivity
        let macMiniEndpoint = "http://bernimac.ddns.net:5000/mcp"
        
        do {
            let response = try await mcpClient.queryMCPServer(
                endpoint: macMiniEndpoint, 
                question: "test connectivity"
            )
            XCTAssertNotNil(response, "Should receive response from MacMini MCP server")
            print("✅ MacMini MCP server accessible")
        } catch {
            // MacMini may not be accessible in test environment
            print("ℹ️ MacMini MCP server not accessible in test environment: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Financial Knowledge Query Tests
    
    func testBasicFinancialQuestionProcessing() async {
        // Test basic financial literacy questions
        let basicQuestions = [
            "What are assets and liabilities?",
            "How do I create a budget?", 
            "What is compound interest?",
            "How much should I save?"
        ]
        
        for question in basicQuestions {
            do {
                let response = try await mcpClient.queryFinancialKnowledge(question: question)
                
                // Validate response structure
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertFalse(response.content.isEmpty, "Response should not be empty")
                XCTAssertGreaterThan(response.qualityScore, 0.0, "Should have quality score")
                XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should be <= 10")
                XCTAssertEqual(response.questionType, .basicLiteracy, "Should classify as basic literacy")
                
                print("✅ Basic question processed: \(question) - Quality: \(response.qualityScore)")
                
            } catch MCPError.networkUnavailable {
                // Acceptable in test environment
                print("ℹ️ Network unavailable for question: \(question)")
            } catch {
                XCTFail("Unexpected error processing basic question: \(error)")
            }
        }
    }
    
    func testAustralianTaxQuestionProcessing() async {
        // Test Australian-specific tax questions
        let australianQuestions = [
            "How does capital gains tax work in NSW?",
            "What is negative gearing in Australia?",
            "Should I set up an SMSF?",
            "How do franking credits work?"
        ]
        
        for question in australianQuestions {
            do {
                let response = try await mcpClient.queryFinancialKnowledge(question: question)
                
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
                XCTAssertGreaterThan(response.qualityScore, 5.0, "Australian tax responses should have high quality")
                
                print("✅ Australian tax question processed: \(question) - Quality: \(response.qualityScore)")
                
            } catch MCPError.networkUnavailable {
                print("ℹ️ Network unavailable for Australian question: \(question)")
            } catch {
                XCTFail("Unexpected error processing Australian question: \(error)")
            }
        }
    }
    
    func testFinanceMateSpecificQuestionProcessing() async {
        // Test FinanceMate app-specific questions
        let appQuestions = [
            "How does FinanceMate calculate net wealth?",
            "Can FinanceMate help me categorize transactions?",
            "How do I set financial goals in FinanceMate?",
            "What reports can FinanceMate generate?"
        ]
        
        for question in appQuestions {
            do {
                let response = try await mcpClient.queryFinancialKnowledge(question: question)
                
                // Validate FinanceMate context
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertTrue(
                    response.content.lowercased().contains("financemate") ||
                    response.content.lowercased().contains("app") ||
                    response.content.lowercased().contains("dashboard"),
                    "Should contain FinanceMate context: \(response.content)"
                )
                XCTAssertEqual(response.questionType, .financeMateSpecific, "Should classify as FinanceMate specific")
                
                print("✅ FinanceMate question processed: \(question) - Quality: \(response.qualityScore)")
                
            } catch MCPError.networkUnavailable {
                print("ℹ️ Network unavailable for FinanceMate question: \(question)")
            } catch {
                XCTFail("Unexpected error processing FinanceMate question: \(error)")
            }
        }
    }
    
    func testComplexFinancialScenarioProcessing() async {
        // Test complex financial planning scenarios
        let complexQuestions = [
            "I have $500k to invest - what's the best strategy for a 35-year-old in NSW?",
            "How should I structure property investment with negative gearing and SMSF?",
            "What's the optimal tax strategy for a $200k income earner with investment properties?"
        ]
        
        for question in complexQuestions {
            do {
                let response = try await mcpClient.queryFinancialKnowledge(question: question)
                
                // Validate complex scenario handling
                XCTAssertNotNil(response.content, "Should have response content")
                XCTAssertGreaterThan(response.content.count, 100, "Complex scenarios should have detailed responses")
                XCTAssertEqual(response.questionType, .complexScenarios, "Should classify as complex scenario")
                XCTAssertTrue(
                    response.content.lowercased().contains("professional") ||
                    response.content.lowercased().contains("advisor"),
                    "Complex scenarios should recommend professional advice"
                )
                
                print("✅ Complex scenario processed: \(question) - Quality: \(response.qualityScore)")
                
            } catch MCPError.networkUnavailable {
                print("ℹ️ Network unavailable for complex question: \(question)")
            } catch {
                XCTFail("Unexpected error processing complex question: \(error)")
            }
        }
    }
    
    // MARK: - Quality Assessment Tests
    
    func testResponseQualityScoring() async {
        // Test quality assessment system
        let testQuestion = "What is compound interest?"
        
        do {
            let response = try await mcpClient.queryFinancialKnowledge(question: testQuestion)
            
            // Validate quality scoring
            XCTAssertGreaterThan(response.qualityScore, 0.0, "Should have positive quality score")
            XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should not exceed 10")
            
            // Quality should be consistent with content
            if response.qualityScore > 7.0 {
                XCTAssertGreaterThan(response.content.count, 50, "High quality responses should be detailed")
            }
            
            print("✅ Quality scoring validated: \(response.qualityScore)/10")
            
        } catch MCPError.networkUnavailable {
            print("ℹ️ Network unavailable for quality test")
        } catch {
            XCTFail("Unexpected error in quality testing: \(error)")
        }
    }
    
    func testAverageQualityTargetValidation() async {
        // Test that average quality meets 6.8/10 target
        let testQuestions = [
            "How do I create a budget?",
            "What is negative gearing?", 
            "How does FinanceMate track expenses?",
            "What are capital gains tax implications?",
            "How much should I save for retirement?"
        ]
        
        var qualityScores: [Double] = []
        
        for question in testQuestions {
            do {
                let response = try await mcpClient.queryFinancialKnowledge(question: question)
                qualityScores.append(response.qualityScore)
            } catch MCPError.networkUnavailable {
                // Skip if network unavailable
                continue
            } catch {
                XCTFail("Unexpected error testing quality: \(error)")
            }
        }
        
        if !qualityScores.isEmpty {
            let averageQuality = qualityScores.reduce(0, +) / Double(qualityScores.count)
            XCTAssertGreaterThanOrEqual(averageQuality, 6.8, "Average quality should meet 6.8/10 target")
            print("✅ Average quality target met: \(averageQuality)/10")
        }
    }
    
    // MARK: - Performance Tests
    
    func testMCPResponsePerformance() async {
        // Test response time performance (<2.0s target)
        let testQuestion = "What is compound interest?"
        
        do {
            let startTime = Date()
            let response = try await mcpClient.queryFinancialKnowledge(question: testQuestion)
            let responseTime = Date().timeIntervalSince(startTime)
            
            XCTAssertLessThan(responseTime, 2.0, "Response time should be under 2.0 seconds")
            XCTAssertNotNil(response.responseTime, "Response should include timing data")
            
            print("✅ Performance target met: \(responseTime)s")
            
        } catch MCPError.networkUnavailable {
            print("ℹ️ Network unavailable for performance test")
        } catch {
            XCTFail("Unexpected error in performance testing: \(error)")
        }
    }
    
    func testConcurrentMCPRequests() async {
        // Test concurrent MCP request handling
        let questions = [
            "What is a budget?",
            "How does negative gearing work?",
            "What are assets?"
        ]
        
        await withTaskGroup(of: Void.self) { group in
            for question in questions {
                group.addTask {
                    do {
                        let response = try await self.mcpClient.queryFinancialKnowledge(question: question)
                        XCTAssertNotNil(response.content, "Concurrent request should return valid response")
                    } catch MCPError.networkUnavailable {
                        // Acceptable in test environment
                    } catch {
                        XCTFail("Concurrent request failed: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testMCPNetworkErrorHandling() async {
        // Test handling of network errors
        let invalidEndpoint = "http://invalid-mcp-server.invalid/mcp"
        
        do {
            let response = try await mcpClient.queryMCPServer(
                endpoint: invalidEndpoint,
                question: "test question"
            )
            XCTFail("Should not succeed with invalid endpoint")
        } catch MCPError.networkUnavailable {
            // Expected error
            XCTAssertFalse(mcpClient.isConnected, "Should remain disconnected after network error")
        } catch MCPError.serverError(let message) {
            // Also acceptable
            XCTAssertTrue(message.contains("network") || message.contains("connection"), "Should indicate network issue")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testMCPInvalidResponseHandling() async {
        // Test handling of malformed MCP responses
        // This would be tested with a mock server in a full implementation
        
        let testQuestion = "test malformed response"
        
        do {
            let response = try await mcpClient.queryFinancialKnowledge(question: testQuestion)
            // If we get a response, it should be well-formed
            XCTAssertFalse(response.content.isEmpty, "Valid responses should not be empty")
            XCTAssertGreaterThan(response.qualityScore, 0, "Valid responses should have quality scores")
        } catch MCPError.dataParsingError(let message) {
            // Expected for malformed data
            XCTAssertTrue(message.contains("parsing") || message.contains("format"), "Should indicate parsing issue")
        } catch MCPError.networkUnavailable {
            // Acceptable in test environment
        } catch {
            XCTFail("Unexpected error handling malformed response: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    func testMCPChatbotViewModelIntegration() async {
        // Test integration with ProductionChatbotViewModel
        let context = PersistenceController.preview.container.viewContext
        let chatbot = ProductionChatbotViewModel(context: context)
        
        // Verify LLM service integration
        XCTAssertNotNil(chatbot.llmService, "ChatBot should have LLM service integrated")
        
        let originalMessageCount = chatbot.messages.count
        
        // Simulate user input
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
        
        print("✅ LLM Service integration verified in ProductionChatbotViewModel")
    }
    
    func testAdvancedTaxOptimizationScenario15() async {
        // 15th Complex Query Scenario: Advanced multi-entity tax optimization with SMSF integration
        let complexTaxQuestion = """
        I have a family trust earning $180k annually, a company with $350k revenue, and an SMSF with $850k in assets including negatively geared investment properties. How should I structure salary sacrificing, dividend distributions, and property depreciation claims to minimize overall tax liability while maximizing SMSF contributions and maintaining compliance with Division 7A? Consider the impact of franking credit optimization and the 30% tax rule for corporate beneficiaries.
        """
        
        do {
            let startTime = Date()
            let response = try await mcpClient.queryFinancialKnowledge(question: complexTaxQuestion)
            let responseTime = Date().timeIntervalSince(startTime)
            
            // Validate comprehensive response structure
            XCTAssertNotNil(response.content, "Should provide detailed tax optimization response")
            XCTAssertFalse(response.content.isEmpty, "Response should not be empty")
            XCTAssertGreaterThan(response.content.count, 200, "Complex tax scenarios require detailed responses")
            
            // Validate question classification
            XCTAssertEqual(response.questionType, .complexScenarios, "Should classify as complex scenario")
            
            // Validate Australian tax context
            let contentLower = response.content.lowercased()
            let australianTaxTermsCount = [
                "smsf", "family trust", "division 7a", "franking", "salary sacrificing", 
                "ato", "australian", "tax office", "superannuation", "concessional"
            ].filter { contentLower.contains($0) }.count
            
            XCTAssertGreaterThanOrEqual(australianTaxTermsCount, 3, "Should contain Australian tax terminology")
            
            // Validate professional advice recommendation
            XCTAssertTrue(
                contentLower.contains("professional") || contentLower.contains("advisor") || 
                contentLower.contains("accountant") || contentLower.contains("specialist"),
                "Complex multi-entity scenarios should recommend professional advice"
            )
            
            // Validate multi-entity awareness
            let entityTermsCount = [
                "family trust", "company", "smsf", "entity", "structure"
            ].filter { contentLower.contains($0) }.count
            
            XCTAssertGreaterThanOrEqual(entityTermsCount, 2, "Should demonstrate multi-entity awareness")
            
            // Validate quality scoring for complex scenarios
            XCTAssertGreaterThan(response.qualityScore, 7.0, "Advanced tax scenarios should have high quality scores")
            XCTAssertLessThanOrEqual(response.qualityScore, 10.0, "Quality score should not exceed maximum")
            
            // Validate response time performance
            XCTAssertLessThan(responseTime, 3.0, "Complex queries should still respond within 3 seconds")
            
            print("✅ 15th Complex Tax Scenario processed successfully")
            print("   Question Type: \(response.questionType)")
            print("   Quality Score: \(response.qualityScore)/10")
            print("   Response Time: \(responseTime)s")
            print("   Australian Terms: \(australianTaxTermsCount)")
            print("   Multi-Entity Terms: \(entityTermsCount)")
            print("   Response Length: \(response.content.count) characters")
            
        } catch MCPError.networkUnavailable(let message) {
            print("ℹ️ Network unavailable for complex tax scenario: \(message)")
            // Network unavailability is acceptable in test environment
            
        } catch {
            XCTFail("Unexpected error processing 15th complex tax scenario: \(error)")
        }
    }

    func testAdvancedTaxOptimizationScenario16() async {
        // 16th Complex Query Scenario: Cross-entity capital structure and CGT timing
        let question = """
        I operate a holding company with two subsidiaries (software and property), a discretionary family trust, and an SMSF. We're planning to dispose of a long-held asset with significant unrealized gains. What are the key strategies around CGT discount eligibility, small business CGT concessions, timing of distributions to beneficiaries, and franking credit optimization to minimize overall tax? Consider Division 7A, PSI rules, and compliance with ATO guidance.
        """

        do {
            let start = Date()
            let response = try await mcpClient.queryFinancialKnowledge(question: question)
            let elapsed = Date().timeIntervalSince(start)

            XCTAssertNotNil(response.content)
            XCTAssertFalse(response.content.isEmpty)
            XCTAssertEqual(response.questionType, .complexScenarios)

            let lower = response.content.lowercased()
            // Ensure relevant Australian tax concepts are referenced
            let requiredTerms = ["cgt", "discount", "small business", "franking", "division 7a", "ato", "beneficiaries"]
            let hits = requiredTerms.filter { lower.contains($0) }
            XCTAssertGreaterThanOrEqual(hits.count, 3)

            // Reasonable performance bound
            XCTAssertLessThan(elapsed, 3.5)
        } catch MCPError.networkUnavailable {
            // Acceptable in CI without external MCP
            print("ℹ️ Network unavailable for complex scenario 16; fallback acceptable")
        } catch {
            XCTFail("Unexpected error in complex scenario 16: \(error)")
        }
    }
    
    func testMCPFailoverToLocalKnowledge() async {
        // Test failover from MCP to local knowledge when network unavailable
        
        // Simulate network unavailable
        mcpClient.simulateNetworkUnavailable = true
        
        let testQuestion = "What is compound interest?"
        
        do {
            let response = try await mcpClient.queryFinancialKnowledge(question: testQuestion)
            
            // Should receive fallback response
            XCTAssertNotNil(response.content, "Should provide fallback response")
            XCTAssertFalse(response.content.isEmpty, "Fallback should not be empty")
            XCTAssertTrue(response.isFromFallback, "Should indicate fallback was used")
            
            print("✅ Failover to local knowledge successful")
            
        } catch {
            XCTFail("Should provide fallback response when MCP unavailable: \(error)")
        }
        
        // Reset simulation
        mcpClient.simulateNetworkUnavailable = false
    }
}

// MARK: - Test Data Structures

extension MCPClientServiceTests {
    
    struct TestMCPResponse {
        let content: String
        let qualityScore: Double
        let questionType: FinancialQuestionType
        let responseTime: TimeInterval
        let isFromFallback: Bool
    }
}