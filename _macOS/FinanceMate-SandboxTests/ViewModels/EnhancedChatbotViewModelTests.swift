// SANDBOX FILE: Enhanced Chatbot ViewModel Tests with MCP Integration

import XCTest
import CoreData
@testable import FinanceMate

/*
 * Purpose: Comprehensive testing for Enhanced ChatbotViewModel with MCP server integration
 * Issues & Complexity Summary: Async testing, MCP simulation, financial Q&A validation
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: High (async testing, MCP mocking, financial validation)
   - Dependencies: XCTest, Core Data, Swift Concurrency, MCP integration
   - State Management Complexity: High (async state, conversation context, server health)
   - Novelty/Uncertainty Factor: Medium (established testing patterns with MCP extensions)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: 89%
 * Overall Result Score: 91%
 * Key Variances/Learnings: Async testing requires careful state management and timing
 * Last Updated: 2025-08-08
 */

final class EnhancedChatbotViewModelTests: XCTestCase {
    
    var viewModel: EnhancedChatbotViewModel!
    var testContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        testContext = PersistenceController.preview.container.viewContext
        viewModel = await EnhancedChatbotViewModel(context: testContext)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        testContext = nil
    }
    
    // MARK: - MCP Server Health Tests
    
    func testMCPServerHealthCheck() async throws {
        // Given: Fresh ViewModel
        XCTAssertTrue(viewModel.mcpServerStatus.isEmpty, "Initial MCP server status should be empty")
        
        // When: Check server health
        await viewModel.checkMCPServerHealth()
        
        // Then: Status should be populated
        await MainActor.run {
            XCTAssertFalse(viewModel.mcpServerStatus.isEmpty, "MCP server status should be populated after health check")
            XCTAssertTrue(viewModel.mcpServerStatus.keys.contains("perplexity-ask"), "Should include perplexity-ask server")
            XCTAssertTrue(viewModel.mcpServerStatus.keys.contains("taskmaster-ai"), "Should include taskmaster-ai server")
            XCTAssertTrue(viewModel.mcpServerStatus.keys.contains("context7"), "Should include context7 server")
        }
    }
    
    func testMCPServerRefresh() async throws {
        // Given: Initial health check
        await viewModel.checkMCPServerHealth()
        let initialCount = await viewModel.mcpServerStatus.count
        
        // When: Refresh servers
        await viewModel.refreshMCPServers()
        
        // Then: Status should be maintained or updated
        await MainActor.run {
            XCTAssertEqual(viewModel.mcpServerStatus.count, initialCount, "Server count should be consistent")
        }
    }
    
    // MARK: - Enhanced Message Processing Tests
    
    func testBasicFinancialQuestionProcessing() async throws {
        // Given: Budget-related question
        let budgetQuestion = "What is a budget?"
        await MainActor.run {
            viewModel.currentInput = budgetQuestion
        }
        
        // When: Send message
        await viewModel.sendMessage()
        
        // Then: Response should be financial and relevant
        await MainActor.run {
            XCTAssertGreaterThan(viewModel.messages.count, 1, "Should have user message and response")
            
            let lastMessage = viewModel.messages.last!
            XCTAssertEqual(lastMessage.role, .assistant, "Last message should be from assistant")
            XCTAssertTrue(lastMessage.content.lowercased().contains("budget"), "Response should mention budget")
            XCTAssertTrue(lastMessage.content.lowercased().contains("financial") || lastMessage.content.lowercased().contains("income") || lastMessage.content.lowercased().contains("expenses"), "Response should be financially relevant")
            XCTAssertGreaterThan(viewModel.responseQuality, 5.0, "Response quality should be reasonable")
        }
    }
    
    func testInvestmentAdviceProcessing() async throws {
        // Given: Investment question
        let investmentQuestion = "How should I start investing in Australia?"
        await MainActor.run {
            viewModel.currentInput = investmentQuestion
        }
        
        // When: Send message
        await viewModel.sendMessage()
        
        // Then: Response should include investment guidance
        await MainActor.run {
            let response = viewModel.messages.last!
            XCTAssertTrue(response.content.lowercased().contains("invest"), "Should mention investment")
            XCTAssertTrue(response.content.lowercased().contains("super") || response.content.lowercased().contains("emergency fund") || response.content.lowercased().contains("index fund"), "Should include specific investment advice")
            XCTAssertGreaterThan(viewModel.responseQuality, 6.0, "Investment advice should have good quality")
        }
    }
    
    func testTaxQuestionProcessing() async throws {
        // Given: Australian tax question
        let taxQuestion = "What tax deductions can I claim in Australia?"
        await MainActor.run {
            viewModel.currentInput = taxQuestion
        }
        
        // When: Send message
        await viewModel.sendMessage()
        
        // Then: Response should include Australian tax context
        await MainActor.run {
            let response = viewModel.messages.last!
            XCTAssertTrue(response.content.lowercased().contains("tax") || response.content.lowercased().contains("deduction"), "Should mention tax/deductions")
            XCTAssertTrue(response.content.lowercased().contains("australia") || response.content.lowercased().contains("work-related") || response.content.lowercased().contains("donation"), "Should include Australian context")
        }
    }
    
    func testComplexFinancialScenario() async throws {
        // Given: Complex financial planning question
        let complexQuestion = "I want to buy a $800,000 property while paying off $50,000 debt and saving for retirement"
        await MainActor.run {
            viewModel.currentInput = complexQuestion
        }
        
        // When: Send message
        await viewModel.sendMessage()
        
        // Then: Response should address multiple financial aspects
        await MainActor.run {
            let response = viewModel.messages.last!
            XCTAssertTrue(response.hasData, "Complex scenarios should have data flag")
            XCTAssertGreaterThan(response.content.count, 100, "Should provide detailed response")
            XCTAssertGreaterThan(viewModel.responseQuality, 7.0, "Complex responses should have high quality")
            
            // Check if response addresses key elements
            let contentLower = response.content.lowercased()
            XCTAssertTrue(contentLower.contains("debt") || contentLower.contains("property") || contentLower.contains("retirement"), "Should address key financial elements")
        }
    }
    
    // MARK: - Financial Intent Analysis Tests
    
    func testBudgetingIntentRecognition() async throws {
        // Test various budget-related phrases
        let budgetingQueries = [
            "How do I create a budget?",
            "Track my monthly expenses",
            "Budget planning help"
        ]
        
        for query in budgetingQueries {
            await MainActor.run {
                viewModel.currentInput = query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                let response = viewModel.messages.last!
                XCTAssertTrue(response.actionType == .analyzeExpenses || response.hasData, "Budget queries should trigger appropriate actions: \(query)")
            }
        }
    }
    
    func testInvestmentIntentRecognition() async throws {
        // Test investment-related intent recognition
        let investmentQueries = [
            "Should I invest in property?",
            "What are good shares to buy?",
            "Investment portfolio advice"
        ]
        
        for query in investmentQueries {
            await MainActor.run {
                viewModel.currentInput = query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                let response = viewModel.messages.last!
                XCTAssertTrue(response.hasData, "Investment queries should have data flag: \(query)")
                XCTAssertTrue(response.content.lowercased().contains("invest") || response.content.lowercased().contains("property") || response.content.lowercased().contains("shares"), "Should contain investment terms: \(query)")
            }
        }
    }
    
    // MARK: - Conversation Context Tests
    
    func testConversationContextBuilding() async throws {
        // Given: Series of related questions
        let questions = [
            "What is a budget?",
            "How do I track expenses?", 
            "Should I use FinanceMate for budgeting?"
        ]
        
        for question in questions {
            await MainActor.run {
                viewModel.currentInput = question
            }
            await viewModel.sendMessage()
        }
        
        // Then: Context should build up
        await MainActor.run {
            XCTAssertGreaterThan(viewModel.conversationContext.count, 0, "Should have conversation context")
            XCTAssertLessThanOrEqual(viewModel.conversationContext.count, questions.count, "Context count should not exceed questions")
            
            // Check context contains relevant topics
            let topics = viewModel.conversationContext.map { $0.topic }
            XCTAssertTrue(topics.contains { $0.contains("budget") || $0.contains("financial") }, "Context should include budget-related topics")
        }
    }
    
    func testConversationContextLimit() async throws {
        // Given: Many messages to test limit
        for i in 1...30 {
            await MainActor.run {
                viewModel.currentInput = "Question number \(i) about finances"
            }
            await viewModel.sendMessage()
        }
        
        // Then: Context should be limited
        await MainActor.run {
            XCTAssertLessThanOrEqual(viewModel.conversationContext.count, 25, "Context should be limited to max history")
        }
    }
    
    // MARK: - Quality Assessment Tests
    
    func testResponseQualityCalculation() async throws {
        // Test different quality responses
        let testCases = [
            (query: "What is money?", expectedMinQuality: 3.0),
            (query: "How do I create a comprehensive budget for my Australian household including investment planning?", expectedMinQuality: 6.0),
            (query: "abc", expectedMinQuality: 1.0)
        ]
        
        for testCase in testCases {
            await MainActor.run {
                viewModel.currentInput = testCase.query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                XCTAssertGreaterThanOrEqual(viewModel.responseQuality, testCase.expectedMinQuality, "Quality should meet minimum for: \(testCase.query)")
                XCTAssertLessThanOrEqual(viewModel.responseQuality, 10.0, "Quality should not exceed maximum")
            }
        }
    }
    
    // MARK: - Financial Knowledge Base Tests
    
    func testFinancialKnowledgeBase() async throws {
        let knowledgeTests = [
            (query: "emergency fund", expectedKeywords: ["emergency", "months", "expenses"]),
            (query: "net wealth calculation", expectedKeywords: ["assets", "liabilities", "net"]),
            (query: "property investment Australia", expectedKeywords: ["property", "tax", "Australia"])
        ]
        
        for test in knowledgeTests {
            await MainActor.run {
                viewModel.currentInput = test.query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                let response = viewModel.messages.last!
                let contentLower = response.content.lowercased()
                
                let foundKeywords = test.expectedKeywords.filter { contentLower.contains($0.lowercased()) }
                XCTAssertGreaterThan(foundKeywords.count, 0, "Should contain at least one expected keyword for: \(test.query)")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testEmptyMessageHandling() async throws {
        // Given: Empty input
        await MainActor.run {
            viewModel.currentInput = ""
        }
        
        let initialMessageCount = await viewModel.messages.count
        
        // When: Send empty message
        await viewModel.sendMessage()
        
        // Then: Should not add messages
        await MainActor.run {
            XCTAssertEqual(viewModel.messages.count, initialMessageCount, "Empty messages should not be processed")
            XCTAssertFalse(viewModel.isProcessing, "Should not be processing after empty message")
        }
    }
    
    func testWhitespaceMessageHandling() async throws {
        // Given: Whitespace-only input
        await MainActor.run {
            viewModel.currentInput = "   \n\t  "
        }
        
        let initialMessageCount = await viewModel.messages.count
        
        // When: Send whitespace message
        await viewModel.sendMessage()
        
        // Then: Should not add messages
        await MainActor.run {
            XCTAssertEqual(viewModel.messages.count, initialMessageCount, "Whitespace-only messages should not be processed")
        }
    }
    
    // MARK: - UI State Tests
    
    func testDrawerToggle() async throws {
        // Given: Initial drawer state
        let initialState = await viewModel.isDrawerVisible
        
        // When: Toggle drawer
        await MainActor.run {
            viewModel.toggleDrawer()
        }
        
        // Then: State should change
        await MainActor.run {
            XCTAssertNotEqual(viewModel.isDrawerVisible, initialState, "Drawer visibility should toggle")
        }
    }
    
    func testConversationClear() async throws {
        // Given: Some messages and context
        await MainActor.run {
            viewModel.currentInput = "Test financial question"
        }
        await viewModel.sendMessage()
        
        // When: Clear conversation
        await MainActor.run {
            viewModel.clearConversation()
        }
        
        // Then: Should reset state
        await MainActor.run {
            XCTAssertGreaterThan(viewModel.messages.count, 0, "Should have welcome message after clear")
            XCTAssertEqual(viewModel.conversationContext.count, 0, "Context should be cleared")
            XCTAssertEqual(viewModel.responseQuality, 0.0, "Quality should reset")
            
            // Welcome message should be present
            let firstMessage = viewModel.messages.first!
            XCTAssertEqual(firstMessage.role, .assistant, "First message should be welcome from assistant")
            XCTAssertTrue(firstMessage.content.contains("Welcome"), "Should contain welcome content")
        }
    }
    
    // MARK: - Integration Tests
    
    func testFinanceMateContextualIntegration() async throws {
        // Test FinanceMate-specific responses
        let financeMateQueries = [
            "How does FinanceMate help with budgeting?",
            "Can I track investments in this app?",
            "Using FinanceMate for expense tracking"
        ]
        
        for query in financeMateQueries {
            await MainActor.run {
                viewModel.currentInput = query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                let response = viewModel.messages.last!
                XCTAssertTrue(response.content.lowercased().contains("financemate") || response.content.contains("Dashboard") || response.content.contains("track"), "Should reference FinanceMate features: \(query)")
            }
        }
    }
    
    func testAustralianFinancialContext() async throws {
        // Test Australian-specific financial advice
        let australianQueries = [
            "Australian superannuation advice",
            "ATO tax requirements", 
            "Negative gearing in Australia"
        ]
        
        for query in australianQueries {
            await MainActor.run {
                viewModel.currentInput = query
            }
            await viewModel.sendMessage()
            
            await MainActor.run {
                let response = viewModel.messages.last!
                let contentLower = response.content.lowercased()
                XCTAssertTrue(contentLower.contains("australia") || contentLower.contains("super") || contentLower.contains("ato") || contentLower.contains("australian"), "Should include Australian context: \(query)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testResponseTimePerformance() async throws {
        // Given: Financial question
        await MainActor.run {
            viewModel.currentInput = "How do I calculate net wealth?"
        }
        
        // When: Measure response time
        let startTime = Date()
        await viewModel.sendMessage()
        let endTime = Date()
        
        // Then: Should respond within reasonable time
        let responseTime = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(responseTime, 5.0, "Response should be within 5 seconds")
        
        await MainActor.run {
            XCTAssertFalse(viewModel.isProcessing, "Should not be processing after completion")
        }
    }
}