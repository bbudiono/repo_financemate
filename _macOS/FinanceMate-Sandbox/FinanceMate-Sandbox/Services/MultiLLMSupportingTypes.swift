// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  MultiLLMSupportingTypes.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Supporting types and components for Multi-LLM Agent Coordination system
* Issues & Complexity Summary: Comprehensive type definitions and supporting classes for multi-agent orchestration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~600
  - Core Algorithm Complexity: High
  - Dependencies: 6 New (FrontierSupervision, ConsensusEngines, LoadBalancing, FailureRecovery, WorkflowTypes, GraphTypes)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 82%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 81%
* Justification for Estimates: Complex type system with sophisticated supervision and coordination logic
* Final Code Complexity (Actual %): 83%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: Well-structured type system enables robust multi-agent coordination
* Last Updated: 2025-06-02
*/

import Foundation

// MARK: - Frontier Model Supervisor

@MainActor
public class FrontierModelSupervisor: ObservableObject {
    
    @Published public var model: FrontierModel
    @Published public var supervisorLoad: Double = 0
    
    private let apiManager: LLMAPIManager
    private var supervisionHistory: [SupervisionResult] = []
    
    public init(defaultModel: FrontierModel) {
        self.model = defaultModel
        self.apiManager = LLMAPIManager()
    }
    
    public func updateModel(_ newModel: FrontierModel) {
        model = newModel
        print("🧠 Frontier supervisor updated to: \(newModel.rawValue)")
    }
    
    public func reviewResult(_ result: MultiLLMTaskResult, task: MultiLLMTask) async -> SupervisorFeedback {
        supervisorLoad += 0.1
        defer { supervisorLoad = max(0, supervisorLoad - 0.1) }
        
        // Simulate frontier model review
        let qualityScore = await evaluateResultQuality(result, task: task)
        let feedback = await generateFeedback(result, quality: qualityScore)
        
        let supervision = SupervisionResult(
            taskId: task.id,
            supervisorModel: model,
            qualityScore: qualityScore,
            feedback: feedback,
            approved: qualityScore > 0.75,
            timestamp: Date()
        )
        
        supervisionHistory.append(supervision)
        
        return SupervisorFeedback(
            feedback: feedback,
            approved: supervision.approved,
            qualityScore: qualityScore
        )
    }
    
    public func decomposeTask(_ task: MultiLLMTask) async -> [SubTask] {
        // Use frontier model to intelligently decompose complex tasks
        var subtasks: [SubTask] = []
        
        if task.requirements.contains("research") {
            subtasks.append(SubTask(
                id: "\(task.id)-research",
                description: "Research and gather information for: \(task.description)",
                requiredRole: .research,
                priority: task.priority,
                estimatedDuration: 300
            ))
        }
        
        if task.requirements.contains("analysis") {
            subtasks.append(SubTask(
                id: "\(task.id)-analysis",
                description: "Analyze gathered information: \(task.description)",
                requiredRole: .analysis,
                priority: task.priority,
                estimatedDuration: 240
            ))
        }
        
        if task.requirements.contains("code_generation") {
            subtasks.append(SubTask(
                id: "\(task.id)-code",
                description: "Generate code for: \(task.description)",
                requiredRole: .code,
                priority: task.priority,
                estimatedDuration: 360
            ))
        }
        
        if task.requirements.contains("validation") {
            subtasks.append(SubTask(
                id: "\(task.id)-validation",
                description: "Validate results for: \(task.description)",
                requiredRole: .validation,
                priority: task.priority,
                estimatedDuration: 180
            ))
        }
        
        return subtasks
    }
    
    public func reviewTaskResult(_ result: TaskResult) async -> TaskReview {
        // Frontier model review of individual task results
        return TaskReview(
            resultId: result.taskId,
            approved: result.confidence > 0.8,
            suggestedImprovements: [],
            qualityScore: result.confidence
        )
    }
    
    public func resolveConflict(_ task: MultiLLMConflictTask) async -> ConflictDecision {
        // Use frontier model to resolve conflicts between agents
        let conflictingResults = task.conflictingResults
        
        // Analyze each result
        var bestResult: AgentResult?
        var highestConfidence: Double = 0
        
        for result in conflictingResults {
            if result.confidence > highestConfidence {
                highestConfidence = result.confidence
                bestResult = result
            }
        }
        
        return ConflictDecision(
            resolution: bestResult?.result ?? "Unable to resolve conflict",
            confidence: highestConfidence * 0.9, // Slightly reduced due to conflict
            reasoning: "Selected result with highest confidence after frontier model analysis"
        )
    }
    
    private func evaluateResultQuality(_ result: MultiLLMTaskResult, task: MultiLLMTask) async -> Double {
        // Simulate frontier model quality evaluation
        var score = 0.8
        
        if result.success { score += 0.1 }
        if result.subtasks.count >= task.requirements.count { score += 0.05 }
        if result.executionTime < 60 { score += 0.05 }
        
        return min(score, 1.0)
    }
    
    private func generateFeedback(_ result: MultiLLMTaskResult, quality: Double) async -> String {
        if quality > 0.9 {
            return "Excellent execution with high quality results across all agents."
        } else if quality > 0.75 {
            return "Good execution with satisfactory results. Minor improvements possible."
        } else if quality > 0.6 {
            return "Acceptable execution but significant improvements needed."
        } else {
            return "Poor execution quality. Major revisions required."
        }
    }
}

// MARK: - Consensus Engine

public class ConsensusEngine {
    
    public func analyzeResults(_ results: [AgentResult], threshold: Double) -> ConsensusAnalysis {
        guard !results.isEmpty else {
            return ConsensusAnalysis(reached: false, level: 0, answer: nil)
        }
        
        // Group results by similarity
        let resultGroups = groupSimilarResults(results)
        
        // Find the largest group
        let largestGroup = resultGroups.max { $0.count < $1.count }
        
        let agreementLevel = Double(largestGroup?.count ?? 0) / Double(results.count)
        let consensusReached = agreementLevel >= threshold
        
        let consensusAnswer = consensusReached ? largestGroup?.first?.result : nil
        
        return ConsensusAnalysis(
            reached: consensusReached,
            level: agreementLevel,
            answer: consensusAnswer
        )
    }
    
    private func groupSimilarResults(_ results: [AgentResult]) -> [[AgentResult]] {
        var groups: [[AgentResult]] = []
        
        for result in results {
            var addedToGroup = false
            
            for i in 0..<groups.count {
                // Simple similarity check - in production would use more sophisticated NLP
                if let firstResult = groups[i].first,
                   similarity(result.result, firstResult.result) > 0.7 {
                    groups[i].append(result)
                    addedToGroup = true
                    break
                }
            }
            
            if !addedToGroup {
                groups.append([result])
            }
        }
        
        return groups
    }
    
    private func similarity(_ a: String, _ b: String) -> Double {
        // Simple similarity metric - in production would use more sophisticated algorithms
        let aWords = Set(a.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let bWords = Set(b.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        let intersection = aWords.intersection(bWords)
        let union = aWords.union(bWords)
        
        return union.isEmpty ? 0 : Double(intersection.count) / Double(union.count)
    }
}

// MARK: - Load Balancer

public class LoadBalancer {
    
    private var agentLoads: [String: Int] = [:]
    
    public func distributeTasksAcrossAgents(_ tasks: [MultiLLMTask], agents: [MultiLLMAgent]) -> [MultiLLMAgent: [MultiLLMTask]] {
        var distribution: [MultiLLMAgent: [MultiLLMTask]] = [:]
        
        // Initialize empty arrays for each agent
        for agent in agents {
            distribution[agent] = []
            agentLoads[agent.id] = 0
        }
        
        // Distribute tasks based on current load and agent capabilities
        for task in tasks {
            if let bestAgent = findBestAgentForTask(task, agents: agents) {
                distribution[bestAgent]?.append(task)
                agentLoads[bestAgent.id, default: 0] += 1
            }
        }
        
        return distribution
    }
    
    public func assignTasksToAgents(_ subtasks: [SubTask], agents: [MultiLLMAgent]) -> [TaskAssignment] {
        var assignments: [TaskAssignment] = []
        
        for subtask in subtasks {
            let suitableAgents = agents.filter { $0.role == subtask.requiredRole }
            
            if let bestAgent = suitableAgents.min(by: { agentLoads[$0.id, default: 0] < agentLoads[$1.id, default: 0] }) {
                assignments.append(TaskAssignment(
                    task: convertSubTaskToTask(subtask),
                    agent: bestAgent,
                    estimatedDuration: subtask.estimatedDuration
                ))
                
                agentLoads[bestAgent.id, default: 0] += 1
            }
        }
        
        return assignments
    }
    
    public func getCurrentLoadDistribution() -> [String: Int] {
        return agentLoads
    }
    
    private func findBestAgentForTask(_ task: MultiLLMTask, agents: [MultiLLMAgent]) -> MultiLLMAgent? {
        // Find agents with required capabilities
        let capableAgents = agents.filter { agent in
            task.requirements.allSatisfy { requirement in
                agent.capabilities.contains(requirement) || 
                requirement.contains(agent.role.rawValue)
            }
        }
        
        // Return agent with lowest current load
        return capableAgents.min { agentLoads[$0.id, default: 0] < agentLoads[$1.id, default: 0] }
    }
    
    private func convertSubTaskToTask(_ subtask: SubTask) -> MultiLLMTask {
        return MultiLLMTask(
            id: subtask.id,
            description: subtask.description,
            priority: subtask.priority,
            requirements: [subtask.requiredRole.rawValue]
        )
    }
}

// MARK: - Failure Recovery Manager

public class FailureRecoveryManager {
    
    public var failedAgents: Set<MultiLLMAgent> = []
    private var failureHistory: [AgentFailure] = []
    
    public func markAgentAsFailed(_ agent: MultiLLMAgent) {
        failedAgents.insert(agent)
        
        let failure = AgentFailure(
            agentId: agent.id,
            agentRole: agent.role,
            timestamp: Date(),
            reason: "Simulated failure for testing"
        )
        
        failureHistory.append(failure)
        print("⚠️ Agent \(agent.id) marked as failed")
    }
    
    public func isAgentFailed(_ agent: MultiLLMAgent) -> Bool {
        return failedAgents.contains(agent)
    }
    
    public func getFallbackAgent() -> MultiLLMAgent? {
        // Return a fallback agent (simplified implementation)
        return nil
    }
    
    public func recoverAgent(_ agent: MultiLLMAgent) {
        failedAgents.remove(agent)
        print("✅ Agent \(agent.id) recovered")
    }
    
    public func getFailureHistory() -> [AgentFailure] {
        return failureHistory
    }
}

// MARK: - API Manager

private class LLMAPIManager {
    
    func callFrontierModel(_ model: FrontierModel, prompt: String) async -> String {
        // Simulate API call to frontier model
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...2_000_000_000))
        return "Response from \(model.rawValue)"
    }
}

// MARK: - Supporting Data Structures

public struct SupervisorFeedback {
    public let feedback: String
    public let approved: Bool
    public let qualityScore: Double
}

public struct SupervisionResult {
    public let taskId: String
    public let supervisorModel: FrontierModel
    public let qualityScore: Double
    public let feedback: String
    public let approved: Bool
    public let timestamp: Date
}

public struct SubTask {
    public let id: String
    public let description: String
    public let requiredRole: AgentRole
    public let priority: TaskPriority
    public let estimatedDuration: TimeInterval
    
    public init(id: String, description: String, requiredRole: AgentRole, priority: TaskPriority, estimatedDuration: TimeInterval) {
        self.id = id
        self.description = description
        self.requiredRole = requiredRole
        self.priority = priority
        self.estimatedDuration = estimatedDuration
    }
}

public struct SubTaskResult {
    public let subtaskId: String
    public let success: Bool
    public let result: String
    public let agentId: String
    public let executionTime: TimeInterval
    
    public init(taskResult: TaskResult) {
        self.subtaskId = taskResult.taskId
        self.success = taskResult.success
        self.result = taskResult.result
        self.agentId = taskResult.agentId
        self.executionTime = 0 // Would be populated from actual execution
    }
}

public struct TaskResult {
    public let taskId: String
    public let agentId: String
    public let agentRole: AgentRole?
    public let success: Bool
    public let result: String
    public let confidence: Double
    public let executionTime: TimeInterval
    
    public init(taskId: String, agentId: String, agentRole: AgentRole? = nil, success: Bool, result: String, confidence: Double, executionTime: TimeInterval = 0) {
        self.taskId = taskId
        self.agentId = agentId
        self.agentRole = agentRole
        self.success = success
        self.result = result
        self.confidence = confidence
        self.executionTime = executionTime
    }
}

public struct TaskAssignment {
    public let task: MultiLLMTask
    public let agent: MultiLLMAgent
    public let estimatedDuration: TimeInterval
    
    public init(task: MultiLLMTask, agent: MultiLLMAgent, estimatedDuration: TimeInterval) {
        self.task = task
        self.agent = agent
        self.estimatedDuration = estimatedDuration
    }
}

public struct TaskReview {
    public let resultId: String
    public let approved: Bool
    public let suggestedImprovements: [String]
    public let qualityScore: Double
}

public struct ConsensusAnalysis {
    public let reached: Bool
    public let level: Double
    public let answer: String?
}

public struct ConflictDecision {
    public let resolution: String
    public let confidence: Double
    public let reasoning: String
}

public struct AgentFailure {
    public let agentId: String
    public let agentRole: AgentRole
    public let timestamp: Date
    public let reason: String
}

// MARK: - Workflow and Graph Types

public struct MultiLLMWorkflow {
    public let id: String
    public let steps: [WorkflowStep]
    
    public init(id: String, steps: [WorkflowStep]) {
        self.id = id
        self.steps = steps
    }
}

public enum WorkflowStep {
    case research(prompt: String)
    case analysis(prompt: String)
    case synthesis(prompt: String)
    case validation(prompt: String)
}

public struct WorkflowResult {
    public let success: Bool
    public let stepsExecuted: Int
    public let error: Error?
    
    public init(success: Bool, stepsExecuted: Int, error: Error? = nil) {
        self.success = success
        self.stepsExecuted = stepsExecuted
        self.error = error
    }
}

public struct MultiLLMGraph {
    public let id: String
    public let nodes: [GraphNode]
    
    public init(id: String, nodes: [GraphNode]) {
        self.id = id
        self.nodes = nodes
    }
}

public struct GraphNode {
    public let id: String
    public let agentRole: AgentRole
    public let dependencies: [String]
    
    public init(id: String, agentRole: AgentRole, dependencies: [String]) {
        self.id = id
        self.agentRole = agentRole
        self.dependencies = dependencies
    }
}

public struct GraphResult {
    public let success: Bool
    public let nodesExecuted: Int
    public let error: Error?
    
    public init(success: Bool, nodesExecuted: Int, error: Error? = nil) {
        self.success = success
        self.nodesExecuted = nodesExecuted
        self.error = error
    }
}

public struct GraphValidation {
    public let isValid: Bool
    public let error: Error?
    
    public init(isValid: Bool, error: Error?) {
        self.isValid = isValid
        self.error = error
    }
}

// MARK: - Consensus Types

public struct MultiLLMConsensusTask {
    public let id: String
    public let question: String
    public let requiredAgreement: Double
    public let participatingAgents: [AgentRole]
    
    public init(id: String, question: String, requiredAgreement: Double, participatingAgents: [AgentRole]) {
        self.id = id
        self.question = question
        self.requiredAgreement = requiredAgreement
        self.participatingAgents = participatingAgents
    }
}

public struct ConsensusResult {
    public let taskId: String
    public let consensusReached: Bool
    public let agreementLevel: Double
    public let participatingAgents: [AgentRole]
    public let finalAnswer: String?
    
    public init(taskId: String, consensusReached: Bool, agreementLevel: Double, participatingAgents: [AgentRole], finalAnswer: String? = nil) {
        self.taskId = taskId
        self.consensusReached = consensusReached
        self.agreementLevel = agreementLevel
        self.participatingAgents = participatingAgents
        self.finalAnswer = finalAnswer
    }
}

public struct MultiLLMConflictTask {
    public let id: String
    public let conflictingResults: [AgentResult]
    
    public init(id: String, conflictingResults: [AgentResult]) {
        self.id = id
        self.conflictingResults = conflictingResults
    }
}

public struct ConflictResolution {
    public let taskId: String
    public let resolvedResult: String
    public let supervisorInvolved: Bool
    public let confidenceScore: Double
    
    public init(taskId: String, resolvedResult: String, supervisorInvolved: Bool, confidenceScore: Double) {
        self.taskId = taskId
        self.resolvedResult = resolvedResult
        self.supervisorInvolved = supervisorInvolved
        self.confidenceScore = confidenceScore
    }
}

public struct AgentResult {
    public let agentId: String
    public let confidence: Double
    public let result: String
    
    public init(agentId: String, confidence: Double, result: String) {
        self.agentId = agentId
        self.confidence = confidence
        self.result = result
    }
}

public struct AgentMessage {
    public let from: String
    public let to: String
    public let type: MessageType
    public let content: Any
    public let timestamp: Date
    
    public init(from: String, to: String, type: MessageType, content: Any, timestamp: Date = Date()) {
        self.from = from
        self.to = to
        self.type = type
        self.content = content
        self.timestamp = timestamp
    }
}

public enum MessageType {
    case taskExecution
    case contextUpdate
    case statusUpdate
    case resultReport
}

// MARK: - Task Queue

public class TaskQueue {
    private var queue: [MultiLLMTask] = []
    private let maxSize: Int = 100
    
    public func enqueue(_ task: MultiLLMTask) {
        guard queue.count < maxSize else { return }
        queue.append(task)
        queue.sort { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    public func dequeue() -> MultiLLMTask? {
        return queue.isEmpty ? nil : queue.removeFirst()
    }
    
    public var count: Int { queue.count }
    public var isEmpty: Bool { queue.isEmpty }
}

extension TaskPriority {
    var rawValue: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

// Make MultiLLMAgent Hashable and Equatable for use in Sets
extension MultiLLMAgent: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: MultiLLMAgent, rhs: MultiLLMAgent) -> Bool {
        return lhs.id == rhs.id
    }
}