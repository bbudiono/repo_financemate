import Foundation
import Network
import os.log

/// Real MCP Client Service for Financial Knowledge Integration
/// Replaces static responses with actual MCP server queries
@MainActor
class MCPClientService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isConnected: Bool = false
    @Published var serverStatus: String = "Disconnected"
    @Published var lastQueryTime: Date?
    
    // MARK: - Public Properties
    let serverEndpoints: [String]
    
    // MARK: - Private Properties
    private let urlSession: URLSession
    private let logger = Logger(subsystem: "FinanceMate", category: "MCPClientService")
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isNetworkAvailable = true
    
    // Testing support
    var simulateNetworkUnavailable = false
    
    // MARK: - Initialization
    
    init() {
        // Configure MCP server endpoints
        self.serverEndpoints = [
            "http://bernimac.ddns.net:5000/mcp",  // MacMini MCP server
            "https://api.openai.com/v1/chat/completions", // Fallback OpenAI API
            "https://api.anthropic.com/v1/messages" // Fallback Anthropic API
        ]
        
        // Configure URL session for MCP requests
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        self.urlSession = URLSession(configuration: config)
        
        // Start network monitoring
        startNetworkMonitoring()
        
        logger.info("MCP Client Service initialized with \(self.serverEndpoints.count) endpoints")
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                self?.updateConnectionStatus()
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    private func updateConnectionStatus() {
        if simulateNetworkUnavailable || !isNetworkAvailable {
            isConnected = false
            serverStatus = "Network Unavailable"
        } else {
            serverStatus = "Network Available"
        }
    }
    
    // MARK: - Public Methods
    
    /// Test connectivity to MCP servers
    func testConnectivity() async throws -> Bool {
        guard !simulateNetworkUnavailable && isNetworkAvailable else {
            throw MCPError.networkUnavailable("Network connectivity disabled")
        }
        
        serverStatus = "Testing connectivity..."
        
        // Test primary MacMini endpoint
        let primaryEndpoint = serverEndpoints[0]
        
        do {
            let isConnected = try await validateEndpoint(primaryEndpoint)
            if isConnected {
                self.isConnected = true
                self.serverStatus = "Connected to MCP servers"
                logger.info("Successfully connected to MCP server: \(primaryEndpoint)")
                return true
            }
        } catch {
            logger.warning("Primary MCP endpoint unavailable: \(error.localizedDescription)")
        }
        
        // Test fallback endpoints
        for endpoint in serverEndpoints.dropFirst() {
            do {
                let isConnected = try await validateEndpoint(endpoint)
                if isConnected {
                    self.isConnected = true
                    self.serverStatus = "Connected to fallback MCP server"
                    logger.info("Connected to fallback MCP server: \(endpoint)")
                    return true
                }
            } catch {
                logger.warning("MCP endpoint unavailable: \(endpoint) - \(error.localizedDescription)")
            }
        }
        
        // No servers available
        isConnected = false
        serverStatus = "No MCP servers available"
        return false
    }
    
    /// Validate specific MCP endpoint
    func validateEndpoint(_ endpoint: String) async throws -> Bool {
        guard let url = URL(string: endpoint) else {
            throw MCPError.invalidEndpoint("Invalid URL: \(endpoint)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("FinanceMate/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 5.0 // Quick validation
        
        do {
            let (_, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                // Accept 2xx, 4xx (server exists but may require authentication)
                return httpResponse.statusCode < 500
            }
            
            return false
        } catch {
            throw MCPError.networkUnavailable("Endpoint validation failed: \(error.localizedDescription)")
        }
    }
    
    /// Query MCP server for financial knowledge
    func queryFinancialKnowledge(question: String) async throws -> MCPResponse {
        guard !simulateNetworkUnavailable else {
            return try await provideFallbackResponse(question: question)
        }
        
        // Ensure we have connectivity
        if !isConnected {
            let connected = try await testConnectivity()
            if !connected {
                return try await provideFallbackResponse(question: question)
            }
        }
        
        let startTime = Date()
        
        // Try primary MCP server first
        do {
            let response = try await queryMCPServer(endpoint: serverEndpoints[0], question: question)
            let responseTime = Date().timeIntervalSince(startTime)
            lastQueryTime = Date()
            
            return MCPResponse(
                content: response,
                qualityScore: calculateQualityScore(response: response, question: question),
                questionType: classifyQuestion(question),
                responseTime: responseTime,
                isFromFallback: false
            )
        } catch {
            logger.warning("Primary MCP server failed: \(error.localizedDescription)")
        }
        
        // Try fallback servers
        for endpoint in serverEndpoints.dropFirst() {
            do {
                let response = try await queryMCPServer(endpoint: endpoint, question: question)
                let responseTime = Date().timeIntervalSince(startTime)
                lastQueryTime = Date()
                
                return MCPResponse(
                    content: response,
                    qualityScore: calculateQualityScore(response: response, question: question),
                    questionType: classifyQuestion(question),
                    responseTime: responseTime,
                    isFromFallback: false
                )
            } catch {
                logger.warning("Fallback MCP server failed: \(endpoint) - \(error.localizedDescription)")
                continue
            }
        }
        
        // All servers failed - use local fallback
        return try await provideFallbackResponse(question: question)
    }
    
    /// Query specific MCP server endpoint
    func queryMCPServer(endpoint: String, question: String) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw MCPError.invalidEndpoint("Invalid MCP endpoint: \(endpoint)")
        }
        
        // Prepare MCP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FinanceMate/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30.0
        
        // Create MCP query payload
        let mcpPayload: [String: Any] = [
            "method": "financial_query",
            "params": [
                "question": question,
                "context": "australian_personal_finance",
                "app": "financemate",
                "language": "en-AU"
            ],
            "id": UUID().uuidString
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: mcpPayload)
        } catch {
            throw MCPError.dataParsingError("Failed to create MCP request payload")
        }
        
        logger.info("Querying MCP server: \(endpoint)")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MCPError.serverError("Invalid response from MCP server")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try parseMCPResponse(data: data)
            case 400...499:
                throw MCPError.serverError("Client error: HTTP \(httpResponse.statusCode)")
            case 500...599:
                throw MCPError.serverError("Server error: HTTP \(httpResponse.statusCode)")
            default:
                throw MCPError.serverError("Unexpected response: HTTP \(httpResponse.statusCode)")
            }
            
        } catch let error as MCPError {
            throw error
        } catch {
            throw MCPError.networkUnavailable("MCP server request failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Response Processing
    
    private func parseMCPResponse(data: Data) throws -> String {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw MCPError.dataParsingError("Invalid JSON response format")
            }
            
            // Handle MCP protocol response
            if let result = jsonObject["result"] as? [String: Any],
               let response = result["response"] as? String {
                return response
            }
            
            // Handle direct response
            if let response = jsonObject["response"] as? String {
                return response
            }
            
            // Handle OpenAI API format
            if let choices = jsonObject["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
            
            // Handle error response
            if let error = jsonObject["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw MCPError.serverError("MCP server error: \(message)")
            }
            
            throw MCPError.dataParsingError("Unable to parse MCP response")
            
        } catch let error as MCPError {
            throw error
        } catch {
            throw MCPError.dataParsingError("JSON parsing failed: \(error.localizedDescription)")
        }
    }
    
    private func provideFallbackResponse(question: String) async throws -> MCPResponse {
        let startTime = Date()
        let questionType = classifyQuestion(question)
        
        // Use enhanced local knowledge base
        let response = generateLocalResponse(question: question, type: questionType)
        let responseTime = Date().timeIntervalSince(startTime)
        
        return MCPResponse(
            content: response,
            qualityScore: calculateQualityScore(response: response, question: question),
            questionType: questionType,
            responseTime: responseTime,
            isFromFallback: true
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
}

// MARK: - Supporting Types

enum MCPError: LocalizedError {
    case networkUnavailable(String)
    case serverError(String)
    case dataParsingError(String)
    case invalidEndpoint(String)
    case authenticationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable(let message):
            return "Network Unavailable: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .dataParsingError(let message):
            return "Data Parsing Error: \(message)"
        case .invalidEndpoint(let message):
            return "Invalid Endpoint: \(message)"
        case .authenticationFailed(let message):
            return "Authentication Failed: \(message)"
        }
    }
}

struct MCPResponse {
    let content: String
    let qualityScore: Double
    let questionType: FinancialQuestionType
    let responseTime: TimeInterval
    let isFromFallback: Bool
}

// MARK: - Network Extensions

extension MCPClientService {
    
    /// Get current network status
    var networkStatus: String {
        if simulateNetworkUnavailable {
            return "Simulated Offline"
        }
        return isNetworkAvailable ? "Network Available" : "Network Unavailable"
    }
    
    /// Reset connection state
    func resetConnection() {
        isConnected = false
        serverStatus = "Disconnected"
        lastQueryTime = nil
    }
}