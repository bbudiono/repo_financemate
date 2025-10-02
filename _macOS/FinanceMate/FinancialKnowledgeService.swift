import Foundation
import CoreData
import os.log

/// LLM-powered financial knowledge service (NO MOCK DATA - BLUEPRINT Line 49 compliant)
struct FinancialKnowledgeService {

    private static let logger = Logger(subsystem: "FinanceMate", category: "FinancialKnowledgeService")

    // MARK: - Q&A Processing (ASYNC - LLM Integration)

    static func processQuestion(_ question: String, context: NSManagedObjectContext? = nil, apiKey: String? = nil) async -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {

        let questionType = classifyQuestion(question)
        logger.info("Processing question (type: \(String(describing: questionType)))")

        // PRIORITY 1: Try LLM with user context (if API key available)
        if let context = context, let apiKey = apiKey, !apiKey.isEmpty {
            do {
                logger.debug("Attempting LLM response with user context")
                let service = LLMFinancialAdvisorService(context: context, apiKey: apiKey)
                let response = try await service.answerQuestion(question)
                let qualityScore = calculateQualityScore(response: response, question: question)
                logger.info("LLM response generated (quality: \(qualityScore)/10)")
                return (response, true, .analyzeExpenses, questionType, qualityScore)
            } catch {
                logger.warning("LLM API failed: \(error.localizedDescription), falling back")
            }
        }

        // PRIORITY 2: Try data-aware responses (no LLM needed)
        if let context = context, let dataResponse = DataAwareResponseGenerator.generate(question: question, context: context) {
            let qualityScore = calculateQualityScore(response: dataResponse.content, question: question)
            logger.info("Data-aware response generated (quality: \(qualityScore)/10)")
            return (dataResponse.content, true, dataResponse.actionType, dataResponse.questionType, qualityScore)
        }

        // PRIORITY 3: Generic fallback (offline or no API key)
        logger.info("Using generic fallback response")
        let fallbackResponse = generateGenericFallback(questionType: questionType)
        let qualityScore = calculateQualityScore(response: fallbackResponse, question: question)
        return (fallbackResponse, false, .none, questionType, qualityScore)
    }

    // MARK: - Question Classification

    private static func classifyQuestion(_ question: String) -> FinancialQuestionType {
        let questionLower = question.lowercased()

        if questionLower.contains("capital gains") || questionLower.contains("negative gearing") || questionLower.contains("smsf") {
            return .australianTax
        }

        if questionLower.contains("financemate") || questionLower.contains("app") || questionLower.contains("dashboard") {
            return .financeMateSpecific
        }

        if questionLower.contains("$") || (questionLower.contains("property") && questionLower.contains("investment")) {
            return .complexScenarios
        }

        if questionLower.contains("budget") || questionLower.contains("save") || questionLower.contains("asset") {
            return .basicLiteracy
        }

        if questionLower.contains("portfolio") || questionLower.contains("invest") || questionLower.contains("retirement") {
            return .personalFinance
        }

        return .general
    }

    private static func generateGenericFallback(questionType: FinancialQuestionType) -> String {
        switch questionType {
        case .basicLiteracy:
            return "This is a fundamental financial concept. Consider using FinanceMate's transaction tracking to better understand your money management. For personalized advice, consult a financial advisor."
        case .personalFinance:
            return "This requires balancing multiple financial factors. FinanceMate can help you track and analyze your financial situation. Consider professional advice for personalized strategies."
        case .australianTax:
            return "This involves Australian tax regulations. FinanceMate supports Australian tax categories for expense tracking. Consult a professional tax advisor for specific guidance."
        case .complexScenarios:
            return "This requires sophisticated financial planning. FinanceMate provides tools for tracking and analysis. Engage qualified financial planners for complex scenarios."
        case .financeMateSpecific:
            return "FinanceMate provides tools for tracking transactions, analyzing spending, and managing your finances. Explore the Dashboard and Transactions tabs for more features."
        case .general:
            return "I can help with your financial questions. Try asking about your balance, spending, or specific financial topics. FinanceMate tracks your transactions and provides insights."
        }
    }

    // MARK: - Quality Scoring

    private static func calculateQualityScore(response: String, question: String) -> Double {
        var score = 0.0

        // Length appropriateness (1.0 points)
        let wordCount = response.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        if wordCount >= 30 && wordCount <= 150 {
            score += 1.0
        } else if wordCount >= 20 && wordCount <= 200 {
            score += 0.7
        }

        // Financial terminology (2.0 points)
        let financialTerms = ["financial", "money", "income", "expenses", "budget", "savings", "investment", "debt", "tax", "asset", "liability", "wealth"]
        let termCount = financialTerms.filter { response.lowercased().contains($0) }.count
        score += min(2.0, Double(termCount) * 0.3)

        // Australian context (1.5 points)
        let australianTerms = ["australia", "australian", "nsw", "ato", "super", "smsf", "cgt"]
        if australianTerms.contains(where: { response.lowercased().contains($0) }) {
            score += 1.5
        }

        // Actionability (2.0 points)
        let actionableWords = ["consider", "start", "track", "set", "review", "calculate", "monitor"]
        let actionableCount = actionableWords.filter { response.lowercased().contains($0) }.count
        score += min(2.0, Double(actionableCount) * 0.4)

        // Professional advice mention (1.0 points)
        if response.lowercased().contains("advisor") || response.lowercased().contains("professional") {
            score += 1.0
        }

        // Completeness (1.5 points)
        if response.hasSuffix(".") || response.hasSuffix("!") {
            score += 0.5
        }
        if response.components(separatedBy: ".").count >= 2 {
            score += 1.0
        }

        return min(10.0, score)
    }
}
