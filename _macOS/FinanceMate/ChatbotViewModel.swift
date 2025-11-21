import Foundation
import CoreData
import SwiftUI
import os.log

@MainActor  // Thread safety: All message array access on main thread
final class ChatbotViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var messages: [ChatMessage] = []
    @Published var isProcessing: Bool = false
    @Published var isDrawerVisible: Bool = true
    @Published var currentInput: String = ""
    @Published var averageQualityScore: Double = 0.0
    @Published var totalQuestions: Int = 0

    // BLUEPRINT Line 135: Context-Aware AI Assistant
    @Published var currentContext: ScreenContext = .dashboard

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "FinanceMate", category: "ChatbotViewModel")
    private var qualityScores: [Double] = []

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
        loadChatHistory()
        if messages.isEmpty {
            initializeWelcomeMessage()
        }
        logger.info("ChatbotViewModel initialized with Australian financial expertise")
    }

    // MARK: - Public Methods

    func sendMessage(_ content: String) async {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(content: content, role: .user)
        messages.append(userMessage)
        saveMessage(userMessage)

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
        saveMessage(assistantMessage)
        updateQualityMetrics(result.qualityScore)
    }

    func toggleDrawer() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDrawerVisible.toggle()
        }
    }

    func clearConversation() {
        // Delete all persisted messages
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatMessage")
        if let entities = try? context.fetch(request) {
            entities.forEach { context.delete($0) }
            try? context.save()
        }

        messages.removeAll()
        qualityScores.removeAll()
        totalQuestions = 0
        averageQualityScore = 0.0
        initializeWelcomeMessage()
    }

    // BLUEPRINT Line 135: Update context when navigating to new screen
    func updateContext(to newContext: ScreenContext) {
        guard newContext != currentContext else { return }
        currentContext = newContext
        logger.info("Screen context updated to: \(newContext.rawValue)")
    }

    func sendSuggestedQuery(_ query: SuggestedQuery) async {
        await sendMessage(query.query)
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

    // MARK: - Persistence Methods

    private func saveMessage(_ message: ChatMessage) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "ChatMessage", into: context)

        entity.setValue(message.id, forKey: "id")
        entity.setValue(message.content, forKey: "content")
        entity.setValue(message.role.rawValue, forKey: "role")
        entity.setValue(message.timestamp, forKey: "timestamp")
        entity.setValue(message.hasData, forKey: "hasData")
        entity.setValue(message.questionType?.rawValue, forKey: "questionType")
        entity.setValue(message.qualityScore, forKey: "qualityScore")
        entity.setValue(message.responseTime, forKey: "responseTime")

        do {
            try context.save()
            logger.info("Saved chat message: \(message.id)")
        } catch {
            logger.error("Failed to save chat message: \(error.localizedDescription)")
        }
    }

    private func loadChatHistory() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ChatMessage")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        guard let entities = try? context.fetch(request) else {
            logger.warning("Failed to load chat history")
            return
        }

        messages = entities.compactMap { entity -> ChatMessage? in
            guard let content = entity.value(forKey: "content") as? String,
                  let roleString = entity.value(forKey: "role") as? String,
                  let role = MessageRole(rawValue: roleString) else {
                logger.error("Invalid chat message entity")
                return nil
            }

            let hasData = entity.value(forKey: "hasData") as? Bool ?? false
            let questionTypeString = entity.value(forKey: "questionType") as? String
            let questionType = questionTypeString.flatMap { FinancialQuestionType(rawValue: $0) }
            let qualityScore = entity.value(forKey: "qualityScore") as? Double
            let responseTime = entity.value(forKey: "responseTime") as? Double

            return ChatMessage(
                content: content,
                role: role,
                hasData: hasData,
                actionType: .none,
                questionType: questionType,
                qualityScore: qualityScore,
                responseTime: responseTime
            )
        }

        logger.info("Loaded \(self.messages.count) chat messages from history")
    }
}
