
//
//  LLMBenchmarkService.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Comprehensive LLM benchmark testing service for performance optimization
* Issues & Complexity Summary: Multi-LLM performance testing with complex financial document processing queries
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Very High
  - Dependencies: 6 New (HTTP clients, JSON parsing, async coordination, performance measurement, error handling, result analysis)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: High
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 90%
* Problem Estimate (Inherent Problem Difficulty %): 88%
* Initial Code Complexity Estimate %: 89%
* Justification for Estimates: Complex multi-LLM coordination with performance benchmarking and result analysis
* Final Code Complexity (Actual %): TBD - Implementation in progress
* Overall Result Score (Success & Quality %): TBD - Testing phase
* Key Variances/Learnings: Real-world LLM performance comparison requires careful timing and response quality analysis
* Last Updated: 2025-06-02
*/

import Foundation
import SwiftUI

@MainActor
class LLMBenchmarkService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isRunning = false
    @Published var currentTest = ""
    @Published var progress: Double = 0.0
    @Published var results: [BenchmarkResult] = []
    @Published var errorMessage: String?
    
    // MARK: - Test Configuration
    
    private let llmEndpoints = [
        LLMEndpoint(name: "Gemini 2.5", provider: .gemini, endpoint: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"),
        LLMEndpoint(name: "Claude-4-Sonnet", provider: .claude, endpoint: "https://api.anthropic.com/v1/messages"),
        LLMEndpoint(name: "GPT-4.1", provider: .openai, endpoint: "https://api.openai.com/v1/chat/completions")
    ]
    
    private let complexFinancialQuery = """
    COMPLEX FINANCIAL DOCUMENT ANALYSIS BENCHMARK:
    
    Analyze the following multi-format financial document extract and provide:
    
    DOCUMENT DATA:
    ---
    ACME CORPORATION QUARTERLY FINANCIAL STATEMENT
    Q3 2024 - CONSOLIDATED REPORT
    
    INCOME STATEMENT:
    Revenue: $2,456,789.12
    - Product Sales: $1,890,234.56
    - Service Revenue: $566,554.56
    Cost of Goods Sold: $1,234,567.89
    Gross Profit: $1,222,221.23
    
    OPERATING EXPENSES:
    - Salaries & Benefits: $456,789.10
    - Marketing: $123,456.78
    - R&D: $234,567.89
    - Administrative: $87,654.32
    - Depreciation: $45,678.90
    Total Operating Expenses: $948,147.99
    
    EBITDA: $274,073.24
    Interest Expense: $12,345.67
    Tax Expense: $78,234.56
    Net Income: $183,493.01
    
    BALANCE SHEET HIGHLIGHTS:
    Total Assets: $8,456,789.12
    Current Assets: $3,234,567.89
    Cash & Equivalents: $1,456,789.12
    Accounts Receivable: $987,654.32
    Inventory: $790,124.45
    
    Total Liabilities: $4,567,890.12
    Current Liabilities: $1,234,567.89
    Long-term Debt: $2,456,789.10
    Shareholders' Equity: $3,888,899.00
    
    CASH FLOW:
    Operating Cash Flow: $456,789.12
    Investing Cash Flow: ($234,567.89)
    Financing Cash Flow: ($123,456.78)
    Net Cash Flow: $98,764.45
    
    ADDITIONAL TRANSACTIONS:
    Invoice #INV-2024-Q3-001: Consulting Services - $45,678.90 (Due: 30 days)
    Invoice #INV-2024-Q3-002: Software License - $23,456.78 (Due: 15 days)
    Receipt #RCP-789456: Office Supplies - $1,234.56
    Wire Transfer: $567,890.12 to Vendor ABC123
    Credit Card Charges: $12,345.67 (Business Expenses)
    ---
    
    REQUIRED ANALYSIS (Must complete ALL sections):
    
    1. FINANCIAL RATIO ANALYSIS:
       - Calculate and interpret: Current Ratio, Quick Ratio, Debt-to-Equity, ROE, ROA, Gross Margin, Net Margin, EBITDA Margin
       - Provide industry benchmarking context
    
    2. CASH FLOW ANALYSIS:
       - Evaluate cash flow quality and sustainability
       - Identify potential liquidity concerns
       - Assess working capital efficiency
    
    3. PROFITABILITY ASSESSMENT:
       - Analyze revenue mix and growth drivers
       - Evaluate cost structure efficiency
       - Compare margins to industry standards
    
    4. RISK ASSESSMENT:
       - Identify financial risk factors
       - Evaluate debt service capacity
       - Assess operational efficiency metrics
    
    5. INVOICE & RECEIVABLES MANAGEMENT:
       - Calculate Days Sales Outstanding (DSO)
       - Evaluate collection efficiency
       - Recommend payment terms optimization
    
    6. PREDICTIVE INSIGHTS:
       - Forecast next quarter trends based on data
       - Identify optimization opportunities
       - Recommend strategic financial actions
    
    7. STRUCTURED DATA EXTRACTION:
       - Extract all monetary values with classifications
       - Identify transaction patterns and categories
       - Create JSON summary of key metrics
    
    8. COMPLIANCE & REPORTING:
       - Identify potential GAAP/IFRS compliance issues
       - Recommend disclosure improvements
       - Assess audit readiness
    
    FORMAT: Provide comprehensive analysis with calculations, explanations, and actionable recommendations. Include confidence scores for each section.
    """
    
    // MARK: - Public Methods
    
    func runBenchmarkTests() async {
        await MainActor.run {
            isRunning = true
            progress = 0.0
            results = []
            errorMessage = nil
            currentTest = "Initializing benchmark tests..."
        }
        
        let totalTests = llmEndpoints.count
        
        for (index, endpoint) in llmEndpoints.enumerated() {
            await MainActor.run {
                currentTest = "Testing \(endpoint.name)..."
                progress = Double(index) / Double(totalTests)
            }
            
            do {
                let result = await testLLMEndpoint(endpoint)
                await MainActor.run {
                    results.append(result)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error testing \(endpoint.name): \(error.localizedDescription)"
                }
            }
            
            // Small delay between tests to avoid rate limiting
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        await MainActor.run {
            isRunning = false
            progress = 1.0
            currentTest = "Benchmark tests completed"
        }
    }
    
    // MARK: - Private Methods
    
    private func testLLMEndpoint(_ endpoint: LLMEndpoint) async -> BenchmarkResult {
        let startTime = Date()
        
        do {
            let request = createRequest(for: endpoint)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BenchmarkError.invalidResponse
            }
            
            let responseContent = try parseResponse(data: data, for: endpoint.provider)
            let qualityScore = calculateQualityScore(response: responseContent)
            
            return BenchmarkResult(
                llmName: endpoint.name,
                provider: endpoint.provider,
                responseTime: responseTime,
                statusCode: httpResponse.statusCode,
                responseLength: responseContent.count,
                qualityScore: qualityScore,
                tokenEstimate: estimateTokenCount(text: responseContent),
                success: httpResponse.statusCode == 200,
                errorMessage: nil,
                responseContent: responseContent,
                timestamp: Date()
            )
            
        } catch {
            let endTime = Date()
            let responseTime = endTime.timeIntervalSince(startTime)
            
            return BenchmarkResult(
                llmName: endpoint.name,
                provider: endpoint.provider,
                responseTime: responseTime,
                statusCode: 0,
                responseLength: 0,
                qualityScore: 0.0,
                tokenEstimate: 0,
                success: false,
                errorMessage: error.localizedDescription,
                responseContent: "",
                timestamp: Date()
            )
        }
    }
    
    private func createRequest(for endpoint: LLMEndpoint) -> URLRequest {
        var request = URLRequest(url: URL(string: endpoint.endpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any]
        
        switch endpoint.provider {
        case .gemini:
            // Note: In production, use proper API key from environment
            request.setValue("Bearer YOUR_GEMINI_API_KEY", forHTTPHeaderField: "Authorization")
            requestBody = [
                "contents": [
                    [
                        "parts": [
                            ["text": complexFinancialQuery]
                        ]
                    ]
                ],
                "generationConfig": [
                    "temperature": 0.1,
                    "maxOutputTokens": 4000
                ]
            ]
            
        case .claude:
            // Note: In production, use proper API key from environment
            request.setValue("YOUR_CLAUDE_API_KEY", forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            requestBody = [
                "model": "claude-3-5-sonnet-20241022",
                "max_tokens": 4000,
                "temperature": 0.1,
                "messages": [
                    [
                        "role": "user",
                        "content": complexFinancialQuery
                    ]
                ]
            ]
            
        case .openai:
            // Note: In production, use proper API key from environment
            request.setValue("Bearer YOUR_OPENAI_API_KEY", forHTTPHeaderField: "Authorization")
            requestBody = [
                "model": "gpt-4-turbo-preview",
                "messages": [
                    [
                        "role": "user",
                        "content": complexFinancialQuery
                    ]
                ],
                "temperature": 0.1,
                "max_tokens": 4000
            ]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        return request
    }
    
    private func parseResponse(data: Data, for provider: LLMProvider) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw BenchmarkError.invalidResponse
        }
        
        switch provider {
        case .gemini:
            if let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text
            }
            
        case .claude:
            if let content = json["content"] as? [[String: Any]],
               let firstContent = content.first,
               let text = firstContent["text"] as? String {
                return text
            }
            
        case .openai:
            if let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        }
        
        throw BenchmarkError.responseParsingFailed
    }
    
    private func calculateQualityScore(response: String) -> Double {
        var score = 0.0
        
        // Check for comprehensive analysis (each section worth points)
        let requiredSections = [
            "ratio analysis", "cash flow", "profitability", "risk assessment",
            "receivables", "predictive", "structured data", "compliance"
        ]
        
        for section in requiredSections {
            if response.lowercased().contains(section.lowercased()) {
                score += 12.5 // 8 sections × 12.5 = 100%
            }
        }
        
        // Bonus points for specific financial calculations
        let calculations = ["current ratio", "debt-to-equity", "roe", "roa", "ebitda margin"]
        for calculation in calculations {
            if response.lowercased().contains(calculation.lowercased()) {
                score += 5.0
            }
        }
        
        // Quality indicators
        if response.contains("$") && response.contains("%") { score += 10.0 }
        if response.count > 2000 { score += 10.0 }
        if response.contains("recommendation") { score += 5.0 }
        
        return min(score, 100.0) // Cap at 100%
    }
    
    private func estimateTokenCount(text: String) -> Int {
        // Rough token estimation (1 token ≈ 4 characters for English)
        return text.count / 4
    }
}

// MARK: - Data Models

struct LLMEndpoint {
    let name: String
    let provider: LLMProvider
    let endpoint: String
}

enum LLMProvider: String, CaseIterable {
    case gemini = "Gemini"
    case claude = "Claude"
    case openai = "OpenAI"
}

struct BenchmarkResult: Identifiable {
    let id = UUID()
    let llmName: String
    let provider: LLMProvider
    let responseTime: TimeInterval
    let statusCode: Int
    let responseLength: Int
    let qualityScore: Double
    let tokenEstimate: Int
    let success: Bool
    let errorMessage: String?
    let responseContent: String
    let timestamp: Date
    
    var tokensPerSecond: Double {
        return responseTime > 0 ? Double(tokenEstimate) / responseTime : 0
    }
    
    var qualityGrade: String {
        switch qualityScore {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        case 50..<60: return "D"
        default: return "F"
        }
    }
}

enum BenchmarkError: Error {
    case invalidResponse
    case responseParsingFailed
    case networkError
    case authenticationFailed
}

// MARK: - Benchmark Results Analysis Extension

extension LLMBenchmarkService {
    
    func generateComprehensiveReport() -> String {
        guard !results.isEmpty else {
            return "No benchmark results available."
        }
        
        let successfulResults = results.filter { $0.success }
        
        var report = """
        🚀 COMPREHENSIVE LLM BENCHMARK ANALYSIS REPORT
        =============================================
        
        📊 PERFORMANCE OVERVIEW:
        - Total Tests Executed: \(results.count)
        - Successful Tests: \(successfulResults.count)
        - Failed Tests: \(results.count - successfulResults.count)
        - Test Date: \(Date().formatted())
        
        """
        
        if !successfulResults.isEmpty {
            // Speed Analysis
            let sortedBySpeed = successfulResults.sorted { $0.responseTime < $1.responseTime }
            let fastestLLM = sortedBySpeed.first!
            let slowestLLM = sortedBySpeed.last!
            
            report += """
            
            ⚡ SPEED PERFORMANCE RANKING:
            """
            
            for (index, result) in sortedBySpeed.enumerated() {
                let rank = index + 1
                let medal = rank == 1 ? "🥇" : rank == 2 ? "🥈" : rank == 3 ? "🥉" : "🏃"
                report += "\n\(rank). \(medal) \(result.llmName): \(String(format: "%.2f", result.responseTime))s (\(String(format: "%.1f", result.tokensPerSecond)) tokens/sec)"
            }
            
            // Quality Analysis
            let sortedByQuality = successfulResults.sorted { $0.qualityScore > $1.qualityScore }
            
            report += """
            
            
            🎯 QUALITY ANALYSIS RANKING:
            """
            
            for (index, result) in sortedByQuality.enumerated() {
                let rank = index + 1
                let medal = rank == 1 ? "🏆" : rank == 2 ? "🥈" : rank == 3 ? "🥉" : "📝"
                report += "\n\(rank). \(medal) \(result.llmName): \(String(format: "%.1f", result.qualityScore))% (Grade: \(result.qualityGrade))"
            }
            
            // Detailed Performance Metrics
            report += """
            
            
            📈 DETAILED PERFORMANCE METRICS:
            """
            
            for result in successfulResults {
                report += """
                
                \(result.llmName) (\(result.provider.rawValue)):
                  • Response Time: \(String(format: "%.3f", result.responseTime))s
                  • Quality Score: \(String(format: "%.1f", result.qualityScore))% (\(result.qualityGrade))
                  • Token Count: \(result.tokenEstimate) tokens
                  • Tokens/Second: \(String(format: "%.1f", result.tokensPerSecond))
                  • Response Length: \(result.responseLength) characters
                  • Status Code: \(result.statusCode)
                """
            }
            
            // Optimization Recommendations
            report += """
            
            
            🔧 OPTIMIZATION RECOMMENDATIONS:
            
            FASTEST LLM: \(fastestLLM.llmName) (\(String(format: "%.2f", fastestLLM.responseTime))s)
            ✅ Recommended for: Real-time processing, user-facing features
            
            HIGHEST QUALITY: \(sortedByQuality.first!.llmName) (\(String(format: "%.1f", sortedByQuality.first!.qualityScore))%)
            ✅ Recommended for: Complex analysis, detailed reporting
            
            BEST BALANCE: \(findBestBalancedLLM(successfulResults).llmName)
            ✅ Recommended for: General-purpose financial document processing
            """
        }
        
        // Failed Tests Analysis
        let failedResults = results.filter { !$0.success }
        if !failedResults.isEmpty {
            report += """
            
            
            ❌ FAILED TESTS ANALYSIS:
            """
            
            for result in failedResults {
                report += """
                
                \(result.llmName): \(result.errorMessage ?? "Unknown error")
                """
            }
        }
        
        report += """
        
        
        📋 BENCHMARK TEST CONFIGURATION:
        - Query Complexity: Very High (8 analysis sections required)
        - Expected Response Length: 2000+ characters
        - Financial Calculations Required: 15+ metrics
        - Test Environment: Sandbox (Headless)
        - Network Conditions: Standard
        
        🧪 SANDBOX Test Results - For development and optimization purposes only.
        """
        
        return report
    }
    
    private func findBestBalancedLLM(_ results: [BenchmarkResult]) -> BenchmarkResult {
        // Calculate balanced score: 60% quality + 40% speed (inverse)
        let maxResponseTime = results.map { $0.responseTime }.max() ?? 1.0
        
        return results.max { result1, result2 in
            let score1 = (result1.qualityScore * 0.6) + ((maxResponseTime - result1.responseTime) / maxResponseTime * 100 * 0.4)
            let score2 = (result2.qualityScore * 0.6) + ((maxResponseTime - result2.responseTime) / maxResponseTime * 100 * 0.4)
            return score1 < score2
        } ?? results.first!
    }
}