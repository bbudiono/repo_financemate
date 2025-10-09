import Foundation

/// Configuration for LLM-as-a-Judge system
/// BLUEPRINT.md 3.1.1.9: LLM-as-a-Judge Architecture
struct LLMJudgeConfiguration: Codable {
    var judgeModel: AIModel?
    var generatorModels: [AIModel] = []
    var evaluationCriteria: [EvaluationCriterion] = []
    var autoSelectBest: Bool = true
    var healthCheckInterval: TimeInterval = 300 // 5 minutes

    init() {}
}

/// Evaluation criterion for model selection
struct EvaluationCriterion: Codable, Identifiable {
    let id = UUID()
    let name: String
    let weight: Double
    let isEnabled: Bool

    init(name: String, weight: Double, isEnabled: Bool = true) {
        self.name = name
        self.weight = weight
        self.isEnabled = isEnabled
    }
}