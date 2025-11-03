import Foundation
import CoreData
import SwiftUI
import os.log

@MainActor
final class ChatbotViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var messages: [ChatMessage] = []
    @Published var isProcessing: Bool = false
    @Published var isDrawerVisible: Bool = true
    @Published var currentInput: String = ""
    @Published var averageQualityScore: Double = 0.0
    @Published var totalQuestions: Int = 0

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "FinanceMate", category: "ChatbotViewModel")
    private var qualityScores: [Double] = []

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
        initializeWelcomeMessage()
        logger.info("ChatbotViewModel initialized with Australian financial expertise")
    }

    // MARK: - Public Methods

    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(content: content, role: .user)
        messages.append(userMessage)

        isProcessing = true
        defer { isProcessing = false }

        let startTime = Date()

        // Get API key from environment
        let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]

        // Build conversation history (last 10 turns, excluding welcome message)
        let conversationHistory = messages
            .filter { $0.role == .user || $0.role == .assistant }
            .suffix(20) // Last 10 turns = 20 messages (user + assistant pairs)
            .dropLast() // Exclude the current user message (already added)
            .map { AnthropicMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }

        // Call async LLM-powered service with conversation history
        let result = await FinancialKnowledgeService.processQuestion(content, conversationHistory: Array(conversationHistory), context: context, apiKey: apiKey)
        let responseTime = Date().timeIntervalSince(startTime)

        let assistantMessage = ChatMessage(
            content: result.content,
            role: .assistant,
            hasData: result.hasData,
            actionType: result.actionType,
            questionType: result.questionType,
            qualityScore: result.qualityScore,
            responseTime: responseTime
        )

        messages.append(assistantMessage)
        updateQualityMetrics(result.qualityScore)
    }

    func toggleDrawer() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDrawerVisible.toggle()
        }
    }

    func clearConversation() {
        messages.removeAll()
        qualityScores.removeAll()
        totalQuestions = 0
        averageQualityScore = 0.0
        initializeWelcomeMessage()
    }

    // MARK: - Private Methods

    private func initializeWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            content: """
            Hello! I am your AI financial assistant powered by comprehensive Australian financial knowledge. I can help you with:

            • Personal budgeting and expense tracking
            • Australian tax implications and strategies
            • Investment planning and portfolio management
            • FinanceMate features and functionality
            • Financial goal setting and monitoring

            What would you like to know about your finances today?
            """,
            role: .assistant,
            hasData: true,
            questionType: .general
        )
        messages.append(welcomeMessage)
    }

    private func updateQualityMetrics(_ score: Double) {
        qualityScores.append(score)
        totalQuestions += 1
        averageQualityScore = qualityScores.reduce(0, +) / Double(qualityScores.count)
    }
}
