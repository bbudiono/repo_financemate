import Foundation
import CoreData

/// Financial knowledge base with Australian compliance and FinanceMate-specific expertise
struct FinancialKnowledgeService {

    // MARK: - Knowledge Base (REAL DATA - NO MOCKS)

    private static let australianFinancialKnowledge: [String: String] = [
        "capital gains tax": "In NSW, capital gains tax applies when you sell an investment property. You'll pay CGT on the profit at your marginal tax rate, but if you've held the property for more than 12 months, you can claim the 50% CGT discount. Primary residence is generally exempt from CGT.",

        "negative gearing": "Negative gearing occurs when your rental property costs (interest, maintenance, depreciation) exceed rental income. In Australia, this loss can be offset against your other taxable income, reducing your overall tax liability. It's particularly beneficial for high-income earners.",

        "smsf": "Self-Managed Super Funds give you direct control over investments but require active management and have higher admin costs. Industry super funds offer professional management, lower fees, and better returns for most people. SMSF is typically only cost-effective with balances over $200,000."
    ]

    private static let financeMateFeatures: [String: String] = [
        "net wealth": "FinanceMate calculates your net wealth by tracking all your assets (cash, investments, property) minus liabilities (debts, loans). The interactive dashboard shows wealth trends over time, helping you monitor progress toward financial goals and make informed decisions.",

        "categorize transactions": "FinanceMate uses intelligent categorization with customizable categories. You can set rules for automatic categorization, manually assign categories, and analyze spending patterns. The system learns from your patterns to improve future categorization accuracy.",

        "financial goals": "Set SMART goals in FinanceMate by defining specific amounts, timeframes, and priorities. The app tracks progress automatically, shows projected completion dates, and suggests optimization strategies based on your current income and spending patterns."
    ]

    private static let basicFinancialConcepts: [String: String] = [
        "assets and liabilities": "Assets are things you own that have value (cash, investments, property, cars). Liabilities are debts you owe (mortgages, loans, credit cards). Your net worth equals total assets minus total liabilities. Building assets while minimizing liabilities increases wealth over time.",

        "create budget": "Start by tracking income and expenses for a month. Categorize spending (needs vs wants). Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings. Adjust based on your situation. Review monthly and make realistic adjustments to ensure you can stick to it.",

        "save percentage": "The general rule is saving 20% of gross income, but this depends on age, income, and goals. Younger people might save 10-15% and increase over time. High earners could save 30%+. Start with what's achievable and increase gradually.",

        "compound interest": "Compound interest is earning interest on your interest. For example, $1,000 at 7% annually becomes $1,070 after year 1, then $1,145 after year 2 (earning interest on $1,070, not just $1,000). Over decades, this creates exponential wealth growth."
    ]

    // MARK: - Q&A Processing

    static func processQuestion(_ question: String, context: NSManagedObjectContext? = nil) -> (content: String, hasData: Bool, actionType: ActionType, questionType: FinancialQuestionType?, qualityScore: Double) {
        let questionLower = question.lowercased()
        let questionType = classifyQuestion(question)

        // PRIORITY 1: Check user's actual data FIRST (if context available)
        if let context = context, let dataResponse = DataAwareResponseGenerator.generate(question: question, context: context) {
            let qualityScore = calculateQualityScore(response: dataResponse.content, question: question)
            return (dataResponse.content, true, dataResponse.actionType, dataResponse.questionType, qualityScore)
        }

        // PRIORITY 2: Fall back to knowledge base
        var response = ""
        var hasData = false
        var actionType: ActionType = .none

        // Search knowledge bases
        for (key, value) in australianFinancialKnowledge {
            if questionLower.contains(key) {
                response = value
                hasData = true
                actionType = .analyzeExpenses
                break
            }
        }

        if response.isEmpty {
            for (key, value) in financeMateFeatures {
                if questionLower.contains(key) {
                    response = value
                    hasData = true
                    actionType = .showDashboard
                    break
                }
            }
        }

        if response.isEmpty {
            for (key, value) in basicFinancialConcepts {
                if questionLower.contains(key) {
                    response = value
                    hasData = true
                    actionType = .analyzeExpenses
                    break
                }
            }
        }

        // Fallback responses by question type
        if response.isEmpty {
            response = generateFallbackResponse(questionType: questionType)
            hasData = true
            actionType = questionType == .financeMateSpecific ? .showDashboard : .none
        }

        let qualityScore = calculateQualityScore(response: response, question: question)
        return (response, hasData, actionType, questionType, qualityScore)
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

    private static func generateFallbackResponse(questionType: FinancialQuestionType) -> String {
        switch questionType {
        case .basicLiteracy:
            return "This is a fundamental financial concept that involves understanding basic money management principles. The key is to start simple and build your knowledge gradually. Consider speaking with a financial advisor for personalized advice."
        case .personalFinance:
            return "This requires balancing multiple financial factors and understanding your personal situation. Consider your risk tolerance, time horizon, and financial goals when making decisions. Professional advice can help optimize your strategy."
        case .australianTax:
            return "This involves complex Australian tax and investment regulations. The optimal approach depends on your complete financial picture, tax situation, and long-term objectives. Professional financial and tax advice is strongly recommended."
        case .complexScenarios:
            return "This requires sophisticated financial planning considering tax efficiency, asset protection, estate planning, and risk management. Given the complexity, engaging qualified financial planners and tax professionals is essential."
        case .financeMateSpecific:
            return "FinanceMate can help you track and analyze this aspect of your finances. The app provides tools for monitoring progress, setting goals, and making informed financial decisions based on your actual data."
        case .general:
            return "I'd be happy to help you with your financial questions. Could you be more specific? I can assist with expense tracking, budget analysis, investment insights, and financial goal management."
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
