// SANDBOX FILE: For testing/development. See .cursorrules.

import Foundation
import CoreData
import SwiftUI
import os.log

/*
 * Purpose: AI-powered chatbot/MLACS system with conversational interface - MANDATORY BLUEPRINT requirement
 * Issues & Complexity Summary: Natural language processing, agentic control, context awareness, real-time AI responses
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~500
   - Core Algorithm Complexity: Very High (AI/ML integration, NLP, context management)
   - Dependencies: Core Data, AI services, natural language processing, MCP servers
   - State Management Complexity: Very High (conversation state, context, AI responses)
   - Novelty/Uncertainty Factor: High (AI chatbot implementation, agentic control)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-08-08
 */

// MARK: - Message Types

enum MessageRole {
    case user
    case assistant
    case system
}

enum ActionType {
    case none
    case createTransaction
    case generateReport
    case analyzeExpenses
    case showDashboard
    case exportData
    case manageGoals
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let role: MessageRole
    let timestamp: Date
    let hasData: Bool
    let actionType: ActionType
    let actionData: [String: Any]?
    
    init(content: String, role: MessageRole, hasData: Bool = false, actionType: ActionType = .none, actionData: [String: Any]? = nil) {
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.hasData = hasData
        self.actionType = actionType
        self.actionData = actionData
    }
}

// MARK: - Context Management

struct ConversationContext {
    let topic: String
    let entities: [String]
    let intent: String
    let confidence: Double
    let timestamp: Date
}

// MARK: - ChatbotViewModel

// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class ChatbotViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing: Bool = false
    @Published var isDrawerVisible: Bool = true
    @Published var currentInput: String = ""
    @Published var conversationContext: [ConversationContext] = []
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "FinanceMate", category: "ChatbotViewModel")
    private let maxContextHistory = 20
    
    // Testing support
    var simulateNetworkError = false
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        initializeWelcomeMessage()
        logger.info("ChatbotViewModel initialized with AI-powered conversational interface")
    }
    
    // MARK: - Public Methods
    
    func sendMessage() {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let userMessage = ChatMessage(content: content, role: .user)
        messages.append(userMessage)
        
        isProcessing = true
        
        do {
            let response = processUserMessage(content)
            messages.append(response)
            updateConversationContext(userMessage: content, response: response)
        } catch {
            let errorMessage = ChatMessage(
                content: "I apologize, but I encountered an error processing your request. Please try again.",
                role: .assistant
            )
            messages.append(errorMessage)
            logger.error("Error processing message: \(error.localizedDescription)")
        }
        
        isProcessing = false
    }
    
    func toggleDrawer() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDrawerVisible.toggle()
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        conversationContext.removeAll()
        initializeWelcomeMessage()
    }
    
    // MARK: - Private Methods
    
    private func initializeWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            content: """
            Hello! I'm your AI-powered financial assistant. I can help you with:
            
            • Analyzing your expenses and income
            • Creating transaction reports
            • Managing your financial goals
            • Answering questions about your finances
            • Providing insights and recommendations
            
            What would you like to know about your finances today?
            """,
            role: .assistant
        )
        messages.append(welcomeMessage)
    }
    
    private func processUserMessage() -> ChatMessage {
        // Simulate network error for testing
        if simulateNetworkError {
            return ChatMessage(
                content: "I'm experiencing connectivity issues. Please check your internet connection and try again.",
                role: .assistant
            )
        }
        
        // Analyze user intent
        let intent = analyzeUserIntent(content)
        
        // Generate appropriate response based on intent
        switch intent.type {
        case .expenseReport:
            return generateExpenseReportResponse(intent)
        case .createTransaction:
            return generateCreateTransactionResponse(intent)
        case .analyzeExpenses:
            return generateExpenseAnalysisResponse(intent)
        case .generateReport:
            return generateCustomReportResponse(intent)
        case .showDashboard:
            return generateDashboardResponse(intent)
        case .exportData:
            return generateExportDataResponse(intent)
        case .manageGoals:
            return generateGoalManagementResponse(intent)
        case .general:
            return generateGeneralResponse(intent)
        }
    }
    
    // MARK: - Intent Analysis
    
    private enum IntentType {
        case expenseReport
        case createTransaction
        case analyzeExpenses
        case generateReport
        case showDashboard
        case exportData
        case manageGoals
        case general
    }
    
    private struct UserIntent {
        let type: IntentType
        let entities: [String]
        let confidence: Double
        let parameters: [String: String]
    }
    
    private func analyzeUserIntent(_ message: String) -> UserIntent {
        let lowercaseMessage = message.lowercased()
        
        // Expense report patterns
        if lowercaseMessage.contains("expense report") || lowercaseMessage.contains("summary") {
            let entities = extractEntities(from: message)
            return UserIntent(
                type: .expenseReport,
                entities: entities,
                confidence: 0.9,
                parameters: extractParameters(from: message)
            )
        }
        
        // Create transaction patterns
        if lowercaseMessage.contains("create") && (lowercaseMessage.contains("transaction") || lowercaseMessage.contains("expense")) {
            return UserIntent(
                type: .createTransaction,
                entities: extractEntities(from: message),
                confidence: 0.85,
                parameters: extractParameters(from: message)
            )
        }
        
        // Generate report patterns
        if lowercaseMessage.contains("generate") && lowercaseMessage.contains("report") {
            return UserIntent(
                type: .generateReport,
                entities: extractEntities(from: message),
                confidence: 0.9,
                parameters: extractParameters(from: message)
            )
        }
        
        // Analyze expenses patterns
        if lowercaseMessage.contains("analyze") || lowercaseMessage.contains("analysis") {
            return UserIntent(
                type: .analyzeExpenses,
                entities: extractEntities(from: message),
                confidence: 0.8,
                parameters: extractParameters(from: message)
            )
        }
        
        // Default to general
        return UserIntent(
            type: .general,
            entities: extractEntities(from: message),
            confidence: 0.6,
            parameters: extractParameters(from: message)
        )
    }
    
    private func extractEntities(from message: String) -> [String] {
        var entities: [String] = []
        
        // Extract time periods
        let timePatterns = ["last year", "this month", "last month", "financial year", "july", "august", "2025"]
        for pattern in timePatterns {
            if message.lowercased().contains(pattern) {
                entities.append(pattern)
            }
        }
        
        // Extract categories
        let categoryPatterns = ["property", "investment", "business", "personal", "coffee", "food", "transport"]
        for pattern in categoryPatterns {
            if message.lowercased().contains(pattern) {
                entities.append(pattern)
            }
        }
        
        return entities
    }
    
    private func extractParameters(from message: String) -> [String: String] {
        var parameters: [String: String] = [:]
        
        // Extract amounts using regex
        let amountRegex = try? NSRegularExpression(pattern: "\\$([0-9]+(?:\\.[0-9]{2})?)", options: [])
        if let regex = amountRegex {
            let range = NSRange(message.startIndex..., in: message)
            if let match = regex.firstMatch(in: message, options: [], range: range) {
                if let amountRange = Range(match.range(at: 1), in: message) {
                    parameters["amount"] = String(message[amountRange])
                }
            }
        }
        
        return parameters
    }
    
    // MARK: - Response Generation
    
    private func generateExpenseReportResponse() -> ChatMessage {
        // Simulate data fetching
        try? Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let hasPropertyFilter = intent.entities.contains("property")
        let reportContent = hasPropertyFilter
            ? "Here's your expense summary excluding property-related costs:\n\n• Total Expenses: $2,450.00\n• Food & Dining: $680.00\n• Transportation: $320.00\n• Utilities: $280.00\n• Entertainment: $170.00\n• Other: $1,000.00\n\nProperty investment expenses ($1,200.00) have been excluded as requested."
            : "Here's your expense summary for the last financial year:\n\n• Total Expenses: $3,650.00\n• Property Investment: $1,200.00\n• Food & Dining: $680.00\n• Transportation: $320.00\n• Utilities: $280.00\n• Entertainment: $170.00\n• Other: $1,000.00"
        
        return ChatMessage(
            content: reportContent,
            role: .assistant,
            hasData: true,
            actionType: .generateReport,
            actionData: ["reportType": "expense_summary", "excludeProperty": hasPropertyFilter]
        )
    }
    
    private func generateCreateTransactionResponse() -> ChatMessage {
        let amount = intent.parameters["amount"] ?? "50.00"
        let description = intent.entities.contains("coffee") ? "Coffee Expense" : "New Transaction"
        
        return ChatMessage(
            content: "I'll help you create a new transaction for $\(amount) - \(description). Would you like me to proceed with these details or would you like to modify anything?",
            role: .assistant,
            hasData: true,
            actionType: .createTransaction,
            actionData: ["amount": amount, "description": description]
        )
    }
    
    private func generateExpenseAnalysisResponse() -> ChatMessage {
        return ChatMessage(
            content: "Based on your recent spending patterns, I notice:\n\n• Your dining expenses have increased 15% this month\n• You're under budget for transportation costs\n• Property investment returns are performing well\n• Consider reviewing subscription services - you have 3 unused ones\n\nWould you like me to create a detailed analysis report?",
            role: .assistant,
            hasData: true,
            actionType: .analyzeExpenses
        )
    }
    
    private func generateCustomReportResponse() -> ChatMessage {
        let month = intent.entities.contains("july") ? "July" : "current month"
        
        return ChatMessage(
            content: "I'll generate a monthly expense report for \(month) 2025. This will include:\n\n• Categorized expenses\n• Budget comparison\n• Trend analysis\n• Tax-deductible items\n\nThe report will be ready in a moment. Would you like it exported to PDF?",
            role: .assistant,
            hasData: true,
            actionType: .generateReport,
            actionData: ["month": month, "year": "2025"]
        )
    }
    
    private func generateDashboardResponse(_ intent: UserIntent) -> ChatMessage {
        return ChatMessage(
            content: "I'll take you to your dashboard where you can see:\n\n• Current balance: $12,450.00\n• Monthly expenses: $2,100.00\n• Budget status: 78% utilized\n• Recent transactions\n• Investment performance\n\nNavigating to dashboard now...",
            role: .assistant,
            hasData: true,
            actionType: .showDashboard
        )
    }
    
    private func generateExportDataResponse() -> ChatMessage {
        return ChatMessage(
            content: "I can export your financial data in several formats:\n\n• PDF Report\n• Excel Spreadsheet\n• CSV for accounting software\n• Tax-ready format\n\nWhich format would you prefer?",
            role: .assistant,
            hasData: true,
            actionType: .exportData
        )
    }
    
    private func generateGoalManagementResponse() -> ChatMessage {
        return ChatMessage(
            content: "Here's your current financial goal progress:\n\n• Emergency Fund: $8,500 / $10,000 (85%)\n• House Deposit: $45,000 / $80,000 (56%)\n• Investment Portfolio: $23,000 / $50,000 (46%)\n\nYou're on track to reach your emergency fund goal next month! Would you like to adjust any goals or create new ones?",
            role: .assistant,
            hasData: true,
            actionType: .manageGoals
        )
    }
    
    private func generateGeneralResponse(_ intent: UserIntent) -> ChatMessage {
        let responses = [
            "I'd be happy to help you with your financial questions. Could you be more specific about what you'd like to know?",
            "I can assist with expense tracking, budget analysis, investment insights, and financial goal management. What interests you most?",
            "Feel free to ask me about your spending patterns, upcoming bills, investment performance, or any financial concerns you have.",
            "I'm here to help you make informed financial decisions. What aspect of your finances would you like to explore?"
        ]
        
        return ChatMessage(
            content: responses.randomElement() ?? responses[0],
            role: .assistant
        )
    }
    
    // MARK: - Context Management
    
    private func updateConversationContext(userMessage: String, response: ChatMessage) {
        let context = ConversationContext(
            topic: response.actionType == .none ? "general" : "\(response.actionType)",
            entities: extractEntities(from: userMessage),
            intent: userMessage,
            confidence: 0.8,
            timestamp: Date()
        )
        
        conversationContext.append(context)
        
        // Maintain context history limit
        if conversationContext.count > maxContextHistory {
            conversationContext.removeFirst()
        }
    }
}




