import Foundation

// MARK: - Message Roles

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

// MARK: - Action Types

enum ActionType: String, Codable {
    case none
    case createTransaction
    case generateReport
    case analyzeExpenses
    case showDashboard
    case exportData
    case manageGoals
}

// MARK: - Financial Question Types

enum FinancialQuestionType: String, Codable {
    case basicLiteracy
    case personalFinance
    case australianTax
    case financeMateSpecific
    case complexScenarios
    case general
}

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let role: MessageRole
    let timestamp: Date
    let hasData: Bool
    let actionType: ActionType
    let questionType: FinancialQuestionType?
    let qualityScore: Double?
    let responseTime: TimeInterval?

    init(
        content: String,
        role: MessageRole,
        hasData: Bool = false,
        actionType: ActionType = .none,
        questionType: FinancialQuestionType? = nil,
        qualityScore: Double? = nil,
        responseTime: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.hasData = hasData
        self.actionType = actionType
        self.questionType = questionType
        self.qualityScore = qualityScore
        self.responseTime = responseTime
    }
}
