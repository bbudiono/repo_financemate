
//
//  UpgradeSuggestionEngine.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Intelligent upgrade suggestion engine for transitioning from single to multi-agent mode
* Features: Query complexity analysis, multi-agent benefit assessment, contextual upgrade prompts
* NO MOCK DATA: Uses real query analysis and intelligent suggestion algorithms
*/

import Foundation

// MARK: - Upgrade Suggestion Engine

public class UpgradeSuggestionEngine {
    
    // MARK: - Private Properties
    
    private let complexityAnalyzer: QueryComplexityAnalyzer
    private let benefitCalculator: MultiAgentBenefitCalculator
    private let upgradeMessaging: UpgradeMessagingEngine
    
    // MARK: - Initialization
    
    public init() {
        self.complexityAnalyzer = QueryComplexityAnalyzer()
        self.benefitCalculator = MultiAgentBenefitCalculator()
        self.upgradeMessaging = UpgradeMessagingEngine()
    }
    
    // MARK: - Public Methods
    
    public func analyzeQueryComplexity(userQuery: String) throws -> ComplexityAnalysis {
        let wordCount = countWords(in: userQuery)
        let sentenceCount = countSentences(in: userQuery)
        let questionCount = countQuestions(in: userQuery)
        let taskIndicators = identifyTaskIndicators(in: userQuery)
        let domainComplexity = assessDomainComplexity(in: userQuery)
        let cognitiveLoad = calculateCognitiveLoad(
            wordCount: wordCount,
            taskIndicators: taskIndicators,
            domainComplexity: domainComplexity
        )
        
        let complexity = classifyComplexity(
            wordCount: wordCount,
            sentenceCount: sentenceCount,
            questionCount: questionCount,
            taskIndicators: taskIndicators,
            cognitiveLoad: cognitiveLoad
        )
        
        let benefitsFromMultiAgent = determineBenefitFromMultiAgent(
            complexity: complexity,
            taskIndicators: taskIndicators,
            cognitiveLoad: cognitiveLoad
        )
        
        let suggestedAgentCount = calculateOptimalAgentCount(
            complexity: complexity,
            taskIndicators: taskIndicators
        )
        
        let reasoning = generateComplexityReasoning(
            complexity: complexity,
            taskIndicators: taskIndicators,
            wordCount: wordCount
        )
        
        let potentialImprovements = identifyPotentialImprovements(
            complexity: complexity,
            taskIndicators: taskIndicators
        )
        
        return ComplexityAnalysis(
            complexity: complexity,
            benefitsFromMultiAgent: benefitsFromMultiAgent,
            suggestedAgentCount: suggestedAgentCount,
            reasoning: reasoning,
            potentialImprovements: potentialImprovements
        )
    }
    
    public func suggestMultiAgentBenefits(query: String, currentAgent: LocalAIAgent) throws -> UpgradeSuggestion {
        let complexityAnalysis = try analyzeQueryComplexity(userQuery: query)
        
        guard complexityAnalysis.benefitsFromMultiAgent else {
            return UpgradeSuggestion(
                shouldSuggest: false,
                timing: .delayed,
                message: "",
                benefits: [],
                demonstration: CollaborationExample(
                    title: "",
                    description: "",
                    agentRoles: [],
                    expectedOutcome: "",
                    qualityImprovement: 0.0
                ),
                dismissible: true
            )
        }
        
        let benefits = benefitCalculator.calculateBenefits(
            forComplexity: complexityAnalysis.complexity,
            currentAgent: currentAgent
        )
        
        let demonstration = benefitCalculator.generateCollaborationExample(
            forQuery: query,
            complexity: complexityAnalysis.complexity
        )
        
        let message = upgradeMessaging.generateUpgradeMessage(
            complexity: complexityAnalysis.complexity,
            benefits: benefits
        )
        
        let timing = determineOptimalTiming(complexity: complexityAnalysis.complexity)
        
        return UpgradeSuggestion(
            shouldSuggest: true,
            timing: timing,
            message: message,
            benefits: benefits,
            demonstration: demonstration,
            dismissible: true
        )
    }
    
    // MARK: - Private Analysis Methods
    
    private func countWords(in text: String) -> Int {
        return text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
    
    private func countSentences(in text: String) -> Int {
        return text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }
    
    private func countQuestions(in text: String) -> Int {
        return text.components(separatedBy: "?").count - 1
    }
    
    private func identifyTaskIndicators(in text: String) -> [TaskIndicator] {
        let lowercaseText = text.lowercased()
        var indicators: [TaskIndicator] = []
        
        // Multi-step task indicators
        let multiStepKeywords = ["first", "then", "next", "after", "finally", "step", "phase", "stage"]
        if multiStepKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.multiStep)
        }
        
        // Research indicators
        let researchKeywords = ["analyze", "compare", "research", "investigate", "study", "examine", "evaluate"]
        if researchKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.research)
        }
        
        // Creative task indicators
        let creativeKeywords = ["create", "write", "design", "brainstorm", "imagine", "invent", "compose"]
        if creativeKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.creative)
        }
        
        // Analysis indicators
        let analysisKeywords = ["pros and cons", "advantages", "disadvantages", "implications", "impact", "consequences"]
        if analysisKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.analysis)
        }
        
        // Coding indicators
        let codingKeywords = ["code", "program", "algorithm", "function", "debug", "optimize", "refactor"]
        if codingKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.coding)
        }
        
        // Review indicators
        let reviewKeywords = ["review", "check", "validate", "verify", "assess", "critique", "feedback"]
        if reviewKeywords.contains(where: { lowercaseText.contains($0) }) {
            indicators.append(.review)
        }
        
        return indicators
    }
    
    private func assessDomainComplexity(in text: String) -> DomainComplexity {
        let lowercaseText = text.lowercased()
        
        // Technical domains
        let technicalKeywords = ["technical", "engineering", "scientific", "mathematical", "statistical", "algorithm"]
        let technicalCount = technicalKeywords.filter { lowercaseText.contains($0) }.count
        
        // Business domains
        let businessKeywords = ["business", "market", "financial", "strategic", "competitive", "revenue"]
        let businessCount = businessKeywords.filter { lowercaseText.contains($0) }.count
        
        // Academic domains
        let academicKeywords = ["theory", "methodology", "framework", "paradigm", "hypothesis", "empirical"]
        let academicCount = academicKeywords.filter { lowercaseText.contains($0) }.count
        
        let totalComplexityIndicators = technicalCount + businessCount + academicCount
        
        switch totalComplexityIndicators {
        case 0...1:
            return .simple
        case 2...3:
            return .moderate
        case 4...5:
            return .complex
        default:
            return .veryComplex
        }
    }
    
    private func calculateCognitiveLoad(wordCount: Int, taskIndicators: [TaskIndicator], domainComplexity: DomainComplexity) -> Double {
        var load = 0.0
        
        // Word count contribution (0-40%)
        load += min(0.4, Double(wordCount) / 200.0)
        
        // Task indicator contribution (0-30%)
        load += min(0.3, Double(taskIndicators.count) / 6.0 * 0.3)
        
        // Domain complexity contribution (0-30%)
        switch domainComplexity {
        case .simple: load += 0.0
        case .moderate: load += 0.1
        case .complex: load += 0.2
        case .veryComplex: load += 0.3
        }
        
        return min(1.0, load)
    }
    
    private func classifyComplexity(
        wordCount: Int,
        sentenceCount: Int,
        questionCount: Int,
        taskIndicators: [TaskIndicator],
        cognitiveLoad: Double
    ) -> QueryComplexity {
        let complexityScore = calculateComplexityScore(
            wordCount: wordCount,
            sentenceCount: sentenceCount,
            questionCount: questionCount,
            taskIndicators: taskIndicators,
            cognitiveLoad: cognitiveLoad
        )
        
        switch complexityScore {
        case 0.0...0.25:
            return .simple
        case 0.25...0.5:
            return .moderate
        case 0.5...0.75:
            return .complex
        default:
            return .veryComplex
        }
    }
    
    private func calculateComplexityScore(
        wordCount: Int,
        sentenceCount: Int,
        questionCount: Int,
        taskIndicators: [TaskIndicator],
        cognitiveLoad: Double
    ) -> Double {
        var score = 0.0
        
        // Length indicators (25% weight)
        score += min(0.25, Double(wordCount) / 150.0 * 0.25)
        
        // Structure indicators (25% weight)
        score += min(0.25, Double(sentenceCount) / 8.0 * 0.15)
        score += min(0.1, Double(questionCount) / 3.0 * 0.1)
        
        // Task complexity (25% weight)
        score += min(0.25, Double(taskIndicators.count) / 4.0 * 0.25)
        
        // Cognitive load (25% weight)
        score += cognitiveLoad * 0.25
        
        return min(1.0, score)
    }
    
    private func determineBenefitFromMultiAgent(
        complexity: QueryComplexity,
        taskIndicators: [TaskIndicator],
        cognitiveLoad: Double
    ) -> Bool {
        // Complex queries always benefit
        if complexity == .complex || complexity == .veryComplex {
            return true
        }
        
        // Multiple task types benefit from specialization
        if taskIndicators.count >= 2 {
            return true
        }
        
        // High cognitive load benefits from distribution
        if cognitiveLoad > 0.6 {
            return true
        }
        
        // Specific task types that benefit from collaboration
        let collaborativeTasks: [TaskIndicator] = [.research, .analysis, .review, .multiStep]
        if taskIndicators.contains(where: { collaborativeTasks.contains($0) }) {
            return true
        }
        
        return false
    }
    
    private func calculateOptimalAgentCount(complexity: QueryComplexity, taskIndicators: [TaskIndicator]) -> Int {
        var agentCount = 1
        
        // Base count from complexity
        switch complexity {
        case .simple:
            agentCount = 1
        case .moderate:
            agentCount = 2
        case .complex:
            agentCount = 3
        case .veryComplex:
            agentCount = 4
        }
        
        // Adjust for task diversity
        let uniqueTaskTypes = Set(taskIndicators).count
        agentCount = max(agentCount, min(5, uniqueTaskTypes))
        
        return agentCount
    }
    
    private func generateComplexityReasoning(
        complexity: QueryComplexity,
        taskIndicators: [TaskIndicator],
        wordCount: Int
    ) -> String {
        var reasoning = "This query is classified as \(complexity.rawValue) because "
        
        var reasons: [String] = []
        
        if wordCount > 100 {
            reasons.append("it contains \(wordCount) words indicating detailed requirements")
        }
        
        if taskIndicators.count > 1 {
            reasons.append("it involves multiple task types: \(taskIndicators.map { $0.description }.joined(separator: ", "))")
        }
        
        if taskIndicators.contains(.multiStep) {
            reasons.append("it requires multiple sequential steps")
        }
        
        if taskIndicators.contains(.research) {
            reasons.append("it involves research and analysis components")
        }
        
        if reasons.isEmpty {
            reasons.append("of its overall structure and requirements")
        }
        
        reasoning += reasons.joined(separator: " and ")
        reasoning += "."
        
        return reasoning
    }
    
    private func identifyPotentialImprovements(
        complexity: QueryComplexity,
        taskIndicators: [TaskIndicator]
    ) -> [String] {
        var improvements: [String] = []
        
        if taskIndicators.contains(.research) {
            improvements.append("Specialized research agents for thorough information gathering")
        }
        
        if taskIndicators.contains(.analysis) {
            improvements.append("Dedicated analysis agents for objective evaluation")
        }
        
        if taskIndicators.contains(.creative) {
            improvements.append("Creative specialists for innovative solutions")
        }
        
        if taskIndicators.contains(.review) {
            improvements.append("Independent review agents for quality assurance")
        }
        
        if taskIndicators.contains(.coding) {
            improvements.append("Code-focused agents for technical implementation")
        }
        
        if complexity == .complex || complexity == .veryComplex {
            improvements.append("Parallel processing for faster completion")
            improvements.append("Cross-validation for improved accuracy")
        }
        
        if improvements.isEmpty {
            improvements.append("Enhanced perspective diversity")
            improvements.append("Improved quality through collaboration")
        }
        
        return improvements
    }
    
    private func determineOptimalTiming(complexity: QueryComplexity) -> UpgradeTiming {
        switch complexity {
        case .simple:
            return .delayed
        case .moderate:
            return .afterResponse
        case .complex:
            return .afterResponse
        case .veryComplex:
            return .immediate
        }
    }
}

// MARK: - Multi-Agent Benefit Calculator

private class MultiAgentBenefitCalculator {
    
    func calculateBenefits(forComplexity complexity: QueryComplexity, currentAgent: LocalAIAgent) -> [String] {
        var benefits: [String] = []
        
        // Universal benefits
        benefits.append("Multiple perspectives for more comprehensive solutions")
        benefits.append("Specialized agents for different aspects of your task")
        
        // Complexity-specific benefits
        switch complexity {
        case .simple:
            benefits.append("Quality verification through peer review")
        case .moderate:
            benefits.append("Faster completion through task distribution")
            benefits.append("Enhanced accuracy through cross-checking")
        case .complex:
            benefits.append("Parallel processing of complex sub-tasks")
            benefits.append("Expert specialization for each component")
            benefits.append("Collaborative problem-solving approaches")
        case .veryComplex:
            benefits.append("Advanced coordination for sophisticated workflows")
            benefits.append("Multiple validation layers for accuracy")
            benefits.append("Comprehensive solution synthesis")
        }
        
        // Agent-specific benefits
        if currentAgent.capabilities.count < 5 {
            benefits.append("Access to additional capabilities beyond your current agent")
        }
        
        return benefits
    }
    
    func generateCollaborationExample(forQuery query: String, complexity: QueryComplexity) -> CollaborationExample {
        let lowercaseQuery = query.lowercased()
        
        if lowercaseQuery.contains("business") || lowercaseQuery.contains("strategy") {
            return generateBusinessExample(complexity: complexity)
        } else if lowercaseQuery.contains("code") || lowercaseQuery.contains("program") {
            return generateCodingExample(complexity: complexity)
        } else if lowercaseQuery.contains("research") || lowercaseQuery.contains("analyze") {
            return generateResearchExample(complexity: complexity)
        } else if lowercaseQuery.contains("write") || lowercaseQuery.contains("create") {
            return generateWritingExample(complexity: complexity)
        } else {
            return generateGeneralExample(complexity: complexity)
        }
    }
    
    private func generateBusinessExample(complexity: QueryComplexity) -> CollaborationExample {
        return CollaborationExample(
            title: "Business Strategy Analysis",
            description: "Multiple agents collaborate on different aspects of your business question",
            agentRoles: [
                "Market Research Agent: Analyzes market conditions and competitors",
                "Financial Analysis Agent: Evaluates financial implications and projections",
                "Strategy Review Agent: Validates recommendations and identifies risks"
            ],
            expectedOutcome: "Comprehensive business strategy with validated financial projections and risk assessment",
            qualityImprovement: complexity == .veryComplex ? 0.85 : 0.70
        )
    }
    
    private func generateCodingExample(complexity: QueryComplexity) -> CollaborationExample {
        return CollaborationExample(
            title: "Code Development & Review",
            description: "Specialized agents handle different aspects of code creation",
            agentRoles: [
                "Code Generation Agent: Creates initial implementation",
                "Code Review Agent: Identifies bugs and optimization opportunities", 
                "Documentation Agent: Provides clear explanations and comments"
            ],
            expectedOutcome: "Production-ready code with thorough review and documentation",
            qualityImprovement: complexity == .veryComplex ? 0.90 : 0.75
        )
    }
    
    private func generateResearchExample(complexity: QueryComplexity) -> CollaborationExample {
        return CollaborationExample(
            title: "Research & Analysis",
            description: "Research agents work in parallel to provide comprehensive analysis",
            agentRoles: [
                "Primary Research Agent: Gathers and synthesizes main information",
                "Critical Analysis Agent: Evaluates sources and identifies gaps",
                "Synthesis Agent: Combines findings into coherent conclusions"
            ],
            expectedOutcome: "Thoroughly researched analysis with verified sources and balanced perspectives",
            qualityImprovement: complexity == .veryComplex ? 0.80 : 0.65
        )
    }
    
    private func generateWritingExample(complexity: QueryComplexity) -> CollaborationExample {
        return CollaborationExample(
            title: "Collaborative Writing",
            description: "Writing specialists collaborate to create high-quality content",
            agentRoles: [
                "Content Creation Agent: Develops initial draft and structure",
                "Editorial Agent: Refines style, clarity, and flow",
                "Fact-Checking Agent: Validates information and improves accuracy"
            ],
            expectedOutcome: "Polished, well-structured content with verified accuracy",
            qualityImprovement: complexity == .veryComplex ? 0.75 : 0.60
        )
    }
    
    private func generateGeneralExample(complexity: QueryComplexity) -> CollaborationExample {
        return CollaborationExample(
            title: "Multi-Perspective Analysis",
            description: "Agents provide different viewpoints for comprehensive solutions",
            agentRoles: [
                "Primary Analysis Agent: Provides main response and reasoning",
                "Alternative Perspective Agent: Offers different approaches and considerations",
                "Quality Assurance Agent: Reviews and validates the combined response"
            ],
            expectedOutcome: "Well-rounded solution with multiple perspectives and quality validation",
            qualityImprovement: complexity == .veryComplex ? 0.70 : 0.55
        )
    }
}

// MARK: - Upgrade Messaging Engine

private class UpgradeMessagingEngine {
    
    func generateUpgradeMessage(complexity: QueryComplexity, benefits: [String]) -> String {
        let baseMessage = getBaseMessage(forComplexity: complexity)
        let benefitsSummary = formatBenefits(benefits: Array(benefits.prefix(3)))
        
        return "\(baseMessage)\n\n\(benefitsSummary)\n\nWould you like to try collaborative AI for this task?"
    }
    
    private func getBaseMessage(forComplexity complexity: QueryComplexity) -> String {
        switch complexity {
        case .simple:
            return "💡 This task could benefit from a second opinion. Multiple agents can provide different perspectives and catch details that might be missed."
        case .moderate:
            return "🚀 This looks like a perfect opportunity for agent collaboration! Multiple specialists working together could deliver significantly better results."
        case .complex:
            return "⭐ This complex task is ideal for our collaborative AI approach. Multiple specialized agents can tackle different aspects simultaneously for superior outcomes."
        case .veryComplex:
            return "🌟 This sophisticated request is exactly what our multi-agent system excels at! Let multiple AI specialists collaborate to deliver exceptional results."
        }
    }
    
    private func formatBenefits(benefits: [String]) -> String {
        let formattedBenefits = benefits.enumerated().map { index, benefit in
            "• \(benefit)"
        }.joined(separator: "\n")
        
        return "Key benefits:\n\(formattedBenefits)"
    }
}

// MARK: - Supporting Types

public struct ComplexityAnalysis {
    public let complexity: QueryComplexity
    public let benefitsFromMultiAgent: Bool
    public let suggestedAgentCount: Int
    public let reasoning: String
    public let potentialImprovements: [String]
}

public struct UpgradeSuggestion {
    public let shouldSuggest: Bool
    public let timing: UpgradeTiming
    public let message: String
    public let benefits: [String]
    public let demonstration: CollaborationExample
    public let dismissible: Bool
}

public struct CollaborationExample {
    public let title: String
    public let description: String
    public let agentRoles: [String]
    public let expectedOutcome: String
    public let qualityImprovement: Double
}

public enum QueryComplexity: String, CaseIterable {
    case simple = "simple"
    case moderate = "moderate" 
    case complex = "complex"
    case veryComplex = "very complex"
}

public enum UpgradeTiming {
    case immediate
    case afterResponse
    case delayed
}

public enum TaskIndicator: CaseIterable {
    case multiStep
    case research
    case creative
    case analysis
    case coding
    case review
    
    var description: String {
        switch self {
        case .multiStep: return "multi-step tasks"
        case .research: return "research"
        case .creative: return "creative work"
        case .analysis: return "analysis"
        case .coding: return "coding"
        case .review: return "review"
        }
    }
}

public enum DomainComplexity {
    case simple
    case moderate
    case complex
    case veryComplex
}

// MARK: - Helper Classes

private class QueryComplexityAnalyzer {
    // Implementation details for query analysis
}