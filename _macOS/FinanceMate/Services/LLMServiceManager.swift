import Foundation
import Security
import os.log
import Combine

/**
 * LLMServiceManager.swift
 * 
 * Purpose: Production LLM service with Claude API integration and OpenAI fallback
 * Issues & Complexity Summary: Real LLM integration, API key security, Australian context
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400 (LLM integration + fallback logic + security)
 *   - Core Algorithm Complexity: High (Multi-provider LLM coordination, context enrichment)
 *   - Dependencies: 3 New (Claude API, OpenAI API, Keychain security)
 *   - State Management Complexity: High (Provider state, streaming, error handling)
 *   - Novelty/Uncertainty Factor: Medium (Production LLM integration patterns)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 92%
 * Target Coverage: Production LLM with Australian financial expertise
 * Security Compliance: Keychain API key storage, no hardcoded secrets
 * Last Updated: 2025-08-10
 */

// MARK: - LLM Provider Types

enum LLMProvider: String, CaseIterable {
    case claude = "claude"
    case openai = "openai"
    case localFallback = "local"
    
    var displayName: String {
        switch self {
        case .claude: return "Claude AI"
        case .openai: return "OpenAI"
        case .localFallback: return "Local Knowledge"
        }
    }
}

enum LLMError: LocalizedError {
    case networkUnavailable(String)
    case authenticationFailed(String)
    case rateLimited(String)
    case serverError(String)
    case dataParsingError(String)
    case invalidAPIKey(String)
    case providerUnavailable(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable(let message):
            return "Network Unavailable: \(message)"
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        case .rateLimited(let message):
            return "Rate Limited: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .dataParsingError(let message):
            return "Data Parsing Error: \(message)"
        case .invalidAPIKey(let message):
            return "Invalid API Key: \(message)"
        case .providerUnavailable(let message):
            return "Provider Unavailable: \(message)"
        }
    }
}

struct LLMResponse {
    let content: String
    let qualityScore: Double
    let questionType: FinancialQuestionType
    let responseTime: TimeInterval
    let isFromFallback: Bool
    let provider: LLMProvider
    let contextEnriched: Bool
    
    init(content: String, qualityScore: Double, questionType: FinancialQuestionType, responseTime: TimeInterval, isFromFallback: Bool = false, provider: LLMProvider, contextEnriched: Bool = false) {
        self.content = content
        self.qualityScore = qualityScore
        self.questionType = questionType
        self.responseTime = responseTime
        self.isFromFallback = isFromFallback
        self.provider = provider
        self.contextEnriched = contextEnriched
    }
}

// MARK: - Australian Financial Context

struct AustralianFinancialContext {
    let hasTaxContext: Bool = true
    let hasRegionalCompliance: Bool = true
    let knowledgeBaseSize: Int = 1000
    
    /// Enriches questions with Australian financial context
    func enrichQuestion(_ question: String) -> String {
        let questionLower = question.lowercased()
        
        // Add Australian context for tax questions
        if questionLower.contains("tax") && !questionLower.contains("australia") {
            return question + " (considering Australian tax law and ATO guidelines)"
        }
        
        // Add context for investment questions
        if (questionLower.contains("invest") || questionLower.contains("property")) && !questionLower.contains("australia") {
            return question + " (in the Australian market context)"
        }
        
        // Add context for retirement/super questions
        if (questionLower.contains("retirement") || questionLower.contains("super")) && !questionLower.contains("australia") {
            return question + " (within the Australian superannuation system)"
        }
        
        return question
    }
    
    /// Gets Australian-specific financial context prompt
    var contextPrompt: String {
        return """
        You are an Australian financial expert. Provide advice considering:
        - Australian tax law and ATO guidelines
        - Australian superannuation system
        - NSW/Australian property market conditions
        - Australian investment options and regulations
        - GST, CGT, and other Australian tax implications
        - Australian financial products and regulations
        Always recommend consulting qualified Australian financial advisors for complex scenarios.
        """
    }
}

// MARK: - LLM Service Manager

@MainActor
final class LLMServiceManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isProcessing: Bool = false
    @Published var currentProvider: LLMProvider = .claude
    @Published var lastQueryTime: Date?
    @Published var averageQualityScore: Double = 0.0
    @Published var totalQueries: Int = 0
    
    // MARK: - Properties
    let australianFinancialContext = AustralianFinancialContext()
    private let logger = Logger(subsystem: "FinanceMate", category: "LLMServiceManager")
    private let urlSession: URLSession
    
    // Testing simulation properties
    var simulateClaudeFailure = false
    var simulateAllProvidersFailure = false
    var simulateNetworkFailure = false
    var simulateRateLimit = false
    
    // MARK: - Initialization
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.urlSession = URLSession(configuration: config)
        
        logger.info("LLM Service Manager initialized")
    }
    
    // MARK: - Public Interface
    
    /// Query financial knowledge with automatic provider selection and fallback
    func queryFinancialKnowledge(question: String) async throws -> LLMResponse {
        guard !simulateAllProvidersFailure else {
            return try await provideFallbackResponse(question: question)
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let startTime = Date()
        let enrichedQuestion = australianFinancialContext.enrichQuestion(question)
        let questionType = classifyQuestion(question)
        
        // Try Claude first
        if !simulateClaudeFailure && hasValidAPIKey(for: .claude) {
            do {
                let response = try await queryClaudeAPI(question: enrichedQuestion, type: questionType)
                let responseTime = Date().timeIntervalSince(startTime)
                lastQueryTime = Date()
                
                let llmResponse = LLMResponse(
                    content: response,
                    qualityScore: calculateQualityScore(response: response, question: question),
                    questionType: questionType,
                    responseTime: responseTime,
                    isFromFallback: false,
                    provider: .claude,
                    contextEnriched: true
                )
                
                updateAverageQuality(llmResponse.qualityScore)
                return llmResponse
                
            } catch {
                logger.warning("Claude API failed: \(error.localizedDescription)")
            }
        }
        
        // Try OpenAI as fallback
        if hasValidAPIKey(for: .openai) {
            do {
                let response = try await queryOpenAIAPI(question: enrichedQuestion, type: questionType)
                let responseTime = Date().timeIntervalSince(startTime)
                lastQueryTime = Date()
                
                let llmResponse = LLMResponse(
                    content: response,
                    qualityScore: calculateQualityScore(response: response, question: question),
                    questionType: questionType,
                    responseTime: responseTime,
                    isFromFallback: true,
                    provider: .openai,
                    contextEnriched: true
                )
                
                updateAverageQuality(llmResponse.qualityScore)
                return llmResponse
                
            } catch {
                logger.warning("OpenAI API failed: \(error.localizedDescription)")
            }
        }
        
        // Final fallback to local knowledge
        return try await provideFallbackResponse(question: question)
    }
    
    /// Streaming version of financial knowledge query
    func queryFinancialKnowledgeStream(question: String) -> AnyPublisher<String, LLMError> {
        let subject = PassthroughSubject<String, LLMError>()
        
        Task {
            do {
                let response = try await queryFinancialKnowledge(question: question)
                
                // Simulate streaming by breaking response into chunks
                let words = response.content.components(separatedBy: " ")
                let chunkSize = max(1, words.count / 10)
                
                for i in stride(from: 0, to: words.count, by: chunkSize) {
                    let endIndex = min(i + chunkSize, words.count)
                    let chunk = Array(words[i..<endIndex]).joined(separator: " ")
                    subject.send(chunk + " ")
                    
                    // Small delay to simulate streaming
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                }
                
                subject.send(completion: .finished)
            } catch let error as LLMError {
                subject.send(completion: .failure(error))
            } catch {
                subject.send(completion: .failure(.serverError(error.localizedDescription)))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - API Key Management
    
    func hasValidAPIKey(for provider: LLMProvider) -> Bool {
        switch provider {
        case .claude:
            if let key = retrieveAPIKey(for: .claude) {
                return validateAPIKeyFormat(key, for: .claude)
            }
            // Fall back to config validation
            return ProductionAPIConfig.validateProvider("claude")
        case .openai:
            if let key = retrieveAPIKey(for: .openai) {
                return validateAPIKeyFormat(key, for: .openai)
            }
            // Fall back to config validation
            return ProductionAPIConfig.validateProvider("openai")
        case .localFallback:
            return true
        }
    }
    
    func validateAPIKeyFormat(_ key: String, for provider: LLMProvider) -> Bool {
        guard !key.isEmpty && key.count > 10 else { return false }
        guard !key.contains("your-") && !key.contains("placeholder") else { return false }
        
        switch provider {
        case .claude:
            return key.hasPrefix("sk-ant-")
        case .openai:
            return key.hasPrefix("sk-") || key.hasPrefix("sk-proj-")
        case .localFallback:
            return true
        }
    }
    
    @discardableResult
    func storeAPIKey(_ key: String, for provider: LLMProvider) -> Bool {
        let service = "com.ablankcanvas.financemate"
        let account = "llm_api_key_\(provider.rawValue)"
        
        let keyData = key.data(using: .utf8)!
        
        // Delete existing key first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new key
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieveAPIKey(for provider: LLMProvider) -> String? {
        let service = "com.ablankcanvas.financemate"
        let account = "llm_api_key_\(provider.rawValue)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data,
              let key = String(data: keyData, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    @discardableResult
    func removeAPIKey(for provider: LLMProvider) -> Bool {
        let service = "com.ablankcanvas.financemate"
        let account = "llm_api_key_\(provider.rawValue)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Private Implementation
    
    private func queryClaudeAPI(question: String, type: FinancialQuestionType) async throws -> String {
        guard !simulateClaudeFailure else {
            throw LLMError.providerUnavailable("Simulated Claude failure")
        }
        
        guard !simulateNetworkFailure else {
            throw LLMError.networkUnavailable("Simulated network failure")
        }
        
        guard !simulateRateLimit else {
            throw LLMError.rateLimited("Simulated rate limit")
        }
        
        let apiKey = retrieveAPIKey(for: .claude) ?? ProductionAPIConfig.claudeAPIKey
        guard validateAPIKeyFormat(apiKey, for: .claude) else {
            throw LLMError.invalidAPIKey("Invalid Claude API key format")
        }
        
        let url = URL(string: "\(ProductionAPIConfig.claudeBaseURL)/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let systemPrompt = australianFinancialContext.contextPrompt
        
        let payload: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 1000,
            "system": systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": question
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw LLMError.dataParsingError("Failed to create Claude request payload")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.serverError("Invalid response from Claude API")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try parseClaudeResponse(data: data)
            case 401:
                throw LLMError.authenticationFailed("Invalid Claude API key")
            case 429:
                throw LLMError.rateLimited("Claude API rate limit exceeded")
            case 400...499:
                throw LLMError.serverError("Claude API client error: \(httpResponse.statusCode)")
            case 500...599:
                throw LLMError.serverError("Claude API server error: \(httpResponse.statusCode)")
            default:
                throw LLMError.serverError("Unexpected Claude API response: \(httpResponse.statusCode)")
            }
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkUnavailable("Claude API request failed: \(error.localizedDescription)")
        }
    }
    
    private func queryOpenAIAPI(question: String, type: FinancialQuestionType) async throws -> String {
        guard !simulateNetworkFailure else {
            throw LLMError.networkUnavailable("Simulated network failure")
        }
        
        guard !simulateRateLimit else {
            throw LLMError.rateLimited("Simulated rate limit")
        }
        
        let apiKey = retrieveAPIKey(for: .openai) ?? ProductionAPIConfig.openAIAPIKey
        guard validateAPIKeyFormat(apiKey, for: .openai) else {
            throw LLMError.invalidAPIKey("Invalid OpenAI API key format")
        }
        
        let url = URL(string: "\(ProductionAPIConfig.openAIBaseURL)/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let systemPrompt = australianFinancialContext.contextPrompt
        
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system", 
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": question
                ]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw LLMError.dataParsingError("Failed to create OpenAI request payload")
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.serverError("Invalid response from OpenAI API")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try parseOpenAIResponse(data: data)
            case 401:
                throw LLMError.authenticationFailed("Invalid OpenAI API key")
            case 429:
                throw LLMError.rateLimited("OpenAI API rate limit exceeded")
            case 400...499:
                throw LLMError.serverError("OpenAI API client error: \(httpResponse.statusCode)")
            case 500...599:
                throw LLMError.serverError("OpenAI API server error: \(httpResponse.statusCode)")
            default:
                throw LLMError.serverError("Unexpected OpenAI API response: \(httpResponse.statusCode)")
            }
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.networkUnavailable("OpenAI API request failed: \(error.localizedDescription)")
        }
    }
    
    private func parseClaudeResponse(data: Data) throws -> String {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw LLMError.dataParsingError("Invalid Claude JSON response format")
            }
            
            guard let content = jsonObject["content"] as? [[String: Any]],
                  let firstContent = content.first,
                  let text = firstContent["text"] as? String else {
                throw LLMError.dataParsingError("Unable to parse Claude response content")
            }
            
            return text
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.dataParsingError("Claude JSON parsing failed: \(error.localizedDescription)")
        }
    }
    
    private func parseOpenAIResponse(data: Data) throws -> String {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw LLMError.dataParsingError("Invalid OpenAI JSON response format")
            }
            
            guard let choices = jsonObject["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw LLMError.dataParsingError("Unable to parse OpenAI response content")
            }
            
            return content
            
        } catch let error as LLMError {
            throw error
        } catch {
            throw LLMError.dataParsingError("OpenAI JSON parsing failed: \(error.localizedDescription)")
        }
    }
    
    private func provideFallbackResponse(question: String) async throws -> LLMResponse {
        let startTime = Date()
        let questionType = classifyQuestion(question)
        
        // Use enhanced local knowledge from MCPClientService pattern
        let response = generateLocalResponse(question: question, type: questionType)
        let responseTime = Date().timeIntervalSince(startTime)
        
        return LLMResponse(
            content: response,
            qualityScore: calculateQualityScore(response: response, question: question),
            questionType: questionType,
            responseTime: responseTime,
            isFromFallback: true,
            provider: .localFallback,
            contextEnriched: false
        )
    }
    
    private func generateLocalResponse(question: String, type: FinancialQuestionType) -> String {
        let questionLower = question.lowercased()
        
        // Australian tax expertise
        if questionLower.contains("capital gains") || questionLower.contains("cgt") {
            return "In NSW, capital gains tax applies when you sell an investment property. You'll pay CGT on the profit at your marginal tax rate, but if you've held the property for more than 12 months, you can claim the 50% CGT discount. Primary residence is generally exempt from CGT. Consider consulting a tax advisor for your specific situation."
        }
        
        if questionLower.contains("negative gearing") {
            return "Negative gearing occurs when your rental property costs (interest, maintenance, depreciation) exceed rental income. In Australia, this loss can be offset against your other taxable income, reducing your overall tax liability. It's particularly beneficial for high-income earners, but consider the cash flow implications and total return on investment."
        }
        
        if questionLower.contains("smsf") {
            return "Self-Managed Super Funds give you direct control over investments but require active management and have higher admin costs. Industry super funds offer professional management, lower fees, and better returns for most people. SMSF is typically only cost-effective with balances over $200,000. Seek professional advice before establishing an SMSF."
        }
        
        // FinanceMate specific features
        if questionLower.contains("financemate") || questionLower.contains("net wealth") {
            return "FinanceMate calculates your net wealth by tracking all your assets (cash, investments, property) minus liabilities (debts, loans). The interactive dashboard shows wealth trends over time, helping you monitor progress toward financial goals and make informed decisions about your financial future."
        }
        
        if questionLower.contains("categorize") || questionLower.contains("transaction") {
            return "FinanceMate uses intelligent categorization with customizable categories. You can set rules for automatic categorization, manually assign categories, and analyze spending patterns. The system learns from your patterns to improve future categorization accuracy and provides insights into your spending habits."
        }
        
        // Basic financial knowledge
        if questionLower.contains("compound interest") {
            return "Compound interest is earning interest on your interest. For example, $1,000 at 7% annually becomes $1,070 after year 1, then $1,145 after year 2 (earning interest on $1,070, not just $1,000). Over decades, this creates exponential wealth growth. Albert Einstein reportedly called it the 'eighth wonder of the world.'"
        }
        
        if questionLower.contains("budget") {
            return "Start by tracking income and expenses for a month. Categorize spending (needs vs wants). Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings. Adjust based on your situation. Review monthly and make realistic adjustments to ensure you can stick to it. FinanceMate can help automate this tracking."
        }
        
        if questionLower.contains("assets") || questionLower.contains("liabilities") {
            return "Assets are things you own that have value (cash, investments, property, cars). Liabilities are debts you owe (mortgages, loans, credit cards). Your net worth equals total assets minus total liabilities. Building assets while minimizing liabilities increases wealth over time."
        }
        
        // Default responses by type
        switch type {
        case .basicLiteracy:
            return "This involves fundamental financial concepts. Start with understanding income, expenses, assets, and liabilities. Build an emergency fund, create a budget, and learn about compound interest. Consider speaking with a financial advisor for personalized guidance."
        case .personalFinance:
            return "Personal finance requires balancing multiple factors including your risk tolerance, time horizon, and financial goals. Consider diversification, regular investing, and tax-efficient strategies. Professional advice can help optimize your approach."
        case .australianTax:
            return "Australian tax and investment regulations are complex and change regularly. The optimal strategy depends on your income, assets, and long-term objectives. Professional financial and tax advice is strongly recommended for your specific circumstances."
        case .complexScenarios:
            return "Complex financial planning requires considering tax efficiency, asset protection, estate planning, and risk management. Given the complexity and potential dollar amounts involved, engaging qualified financial planners and tax professionals is essential."
        case .financeMateSpecific:
            return "FinanceMate provides comprehensive financial tracking and analysis tools. The app helps you monitor net wealth, categorize transactions, set financial goals, and track progress over time. Explore the dashboard to discover all available features."
        case .general:
            return "I can help with various financial topics including budgeting, investing, tax planning, and using FinanceMate effectively. Could you be more specific about what you'd like to know? This will help me provide more targeted guidance."
        }
    }
    
    private func classifyQuestion(_ question: String) -> FinancialQuestionType {
        let questionLower = question.lowercased()
        
        // Australian tax terms
        if questionLower.contains("capital gains") || questionLower.contains("negative gearing") || 
           questionLower.contains("smsf") || questionLower.contains("australia") || 
           questionLower.contains("ato") || questionLower.contains("nsw") {
            return .australianTax
        }
        
        // FinanceMate specific terms
        if questionLower.contains("financemate") || questionLower.contains("app") || 
           questionLower.contains("dashboard") || questionLower.contains("net wealth") {
            return .financeMateSpecific
        }
        
        // Complex scenarios (dollar amounts, multiple concepts)
        if questionLower.contains("$") || questionLower.contains("million") ||
           (questionLower.contains("property") && questionLower.contains("investment")) ||
           questionLower.contains("strategy") {
            return .complexScenarios
        }
        
        // Basic financial terms
        if questionLower.contains("budget") || questionLower.contains("save") || 
           questionLower.contains("asset") || questionLower.contains("debt") ||
           questionLower.contains("compound") {
            return .basicLiteracy
        }
        
        // Personal finance management
        if questionLower.contains("portfolio") || questionLower.contains("invest") || 
           questionLower.contains("retirement") || questionLower.contains("goal") {
            return .personalFinance
        }
        
        return .general
    }
    
    private func calculateQualityScore(response: String, question: String) -> Double {
        var score = 0.0
        
        // Length appropriateness (1.5 points)
        let wordCount = response.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        if wordCount >= 30 && wordCount <= 150 {
            score += 1.5
        } else if wordCount >= 20 && wordCount <= 200 {
            score += 1.0
        } else if wordCount >= 10 {
            score += 0.5
        }
        
        // Financial terminology relevance (2.0 points)
        let financialTerms = ["financial", "money", "income", "expenses", "budget", "savings", "investment", "debt", "loan", "interest", "tax", "asset", "liability", "wealth", "portfolio", "return", "risk"]
        let termCount = financialTerms.filter { response.lowercased().contains($0) }.count
        score += min(2.0, Double(termCount) * 0.2)
        
        // Australian context relevance (1.5 points)
        let australianTerms = ["australia", "australian", "nsw", "ato", "super", "smsf", "cgt", "gearing", "franking"]
        let australianTermCount = australianTerms.filter { response.lowercased().contains($0) }.count
        if australianTermCount > 0 {
            score += min(1.5, Double(australianTermCount) * 0.5)
        }
        
        // Actionability and practical advice (2.0 points)
        let actionableWords = ["consider", "start", "track", "set", "review", "calculate", "monitor", "use", "create", "build", "plan", "should", "can", "help"]
        let actionableCount = actionableWords.filter { response.lowercased().contains($0) }.count
        score += min(2.0, Double(actionableCount) * 0.25)
        
        // Professional advice mention (1.0 points)
        if response.lowercased().contains("advisor") || response.lowercased().contains("professional") ||
           response.lowercased().contains("consult") || response.lowercased().contains("seek advice") {
            score += 1.0
        }
        
        // Completeness and structure (1.5 points)
        if response.hasSuffix(".") || response.hasSuffix("!") {
            score += 0.5
        }
        let sentenceCount = response.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
        if sentenceCount >= 2 {
            score += 1.0
        }
        
        // Specificity bonus (0.5 points)
        if response.contains("FinanceMate") || response.contains("NSW") || response.contains("%") {
            score += 0.5
        }
        
        return min(10.0, score)
    }
    
    private func updateAverageQuality(_ newScore: Double) {
        totalQueries += 1
        averageQualityScore = ((averageQualityScore * Double(totalQueries - 1)) + newScore) / Double(totalQueries)
    }
}

// MARK: - Extensions

extension LLMServiceManager {
    
    /// Get configuration summary
    var configurationSummary: String {
        let claudeConfigured = hasValidAPIKey(for: .claude) ? "✅ Claude AI" : "❌ Claude AI"
        let openAIConfigured = hasValidAPIKey(for: .openai) ? "✅ OpenAI" : "❌ OpenAI"
        
        return """
        LLM Service Configuration:
        Current Provider: \(currentProvider.displayName)
        \(claudeConfigured)
        \(openAIConfigured)
        ✅ Local Fallback (always available)
        
        Quality Metrics:
        Average Quality Score: \(String(format: "%.1f", averageQualityScore))/10.0
        Total Queries Processed: \(totalQueries)
        """
    }
    
    /// Check if ready for production
    var isReadyForProduction: Bool {
        return hasValidAPIKey(for: .claude) || hasValidAPIKey(for: .openai)
    }
}