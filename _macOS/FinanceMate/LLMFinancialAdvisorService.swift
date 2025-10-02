import Foundation
import CoreData
import os.log

/// LLM-powered financial advisor service with Core Data context injection
struct LLMFinancialAdvisorService {

    private let client: AnthropicAPIClient
    private let context: NSManagedObjectContext
    private let logger = Logger(subsystem: "FinanceMate", category: "LLMFinancialAdvisorService")

    // MARK: - Initialization

    init(context: NSManagedObjectContext, apiKey: String) {
        self.context = context
        self.client = AnthropicAPIClient(apiKey: apiKey)
        logger.info("LLM service initialized with Claude Sonnet 4")
    }

    // MARK: - Question Answering

    /// Answer financial question with user context injection
    func answerQuestion(_ question: String) async throws -> String {
        logger.info("Processing question with LLM: \(question.prefix(50))...")

        let systemPrompt = buildSystemPrompt()
        let userContext = buildUserContext()

        let fullQuestion = """
        \(userContext)

        User Question: \(question)
        """

        let messages = [AnthropicMessage(role: "user", content: fullQuestion)]

        let response = try await client.sendMessageSync(messages: messages, systemPrompt: systemPrompt)
        logger.info("LLM response generated (\(response.count) chars)")

        return response
    }

    // MARK: - Streaming Support

    /// Answer question with streaming response
    func answerQuestionStreaming(_ question: String) async throws -> AsyncThrowingStream<String, Error> {
        logger.info("Processing question with streaming: \(question.prefix(50))...")

        let systemPrompt = buildSystemPrompt()
        let userContext = buildUserContext()

        let fullQuestion = """
        \(userContext)

        User Question: \(question)
        """

        let messages = [AnthropicMessage(role: "user", content: fullQuestion)]

        return try await client.sendMessage(messages: messages, systemPrompt: systemPrompt)
    }

    // MARK: - System Prompt Engineering

    private func buildSystemPrompt() -> String {
        return """
        You are a professional Australian financial advisor assistant integrated into FinanceMate, a wealth management application.

        Your expertise includes:
        - Australian taxation (ATO compliance, CGT, negative gearing, SMSF, franking credits)
        - Personal budgeting and expense tracking strategies
        - Investment planning (ASX shares, property, cryptocurrency, superannuation)
        - Financial goal setting and wealth accumulation
        - Australian regulatory compliance (Consumer Data Right, Privacy Act)

        Guidelines:
        - Provide concise, actionable advice (2-4 sentences preferred)
        - Always consider Australian tax implications and ATO requirements
        - Be professional yet friendly and approachable
        - When user asks about "my" data, reference the financial context provided
        - Recommend consulting licensed professionals for complex tax/legal matters
        - Use Australian dollar ($AUD) and date formats (DD/MM/YYYY)
        - Consider Australian financial year (July 1 - June 30)

        Response style: Direct, helpful, Australian-focused
        """
    }

    // MARK: - Context Injection

    private func buildUserContext() -> String {
        let balance = TransactionQueryHelper.getTotalBalance(context: context)
        let count = TransactionQueryHelper.getTransactionCount(context: context)
        let recent = TransactionQueryHelper.getRecentTransactions(context: context, limit: 5)

        var contextText = """
        ===== USER FINANCIAL CONTEXT =====
        Current Balance: $\(String(format: "%.2f", balance)) AUD
        Total Transactions: \(count)
        """

        if !recent.isEmpty {
            contextText += "\n\nRecent Transactions:"
            for (index, tx) in recent.enumerated() {
                let dateStr = tx.date.formatted(date: .abbreviated, time: .omitted)
                contextText += "\n\(index + 1). \(tx.itemDescription) - $\(String(format: "%.2f", tx.amount)) on \(dateStr) (\(tx.category))"
            }
        } else {
            contextText += "\n\nNote: User has no transactions yet (new account)"
        }

        contextText += "\n=================================="

        logger.debug("Context built: \(count) transactions, balance $\(balance)")
        return contextText
    }
}
