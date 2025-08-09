import Foundation

/// Core help system types and enumerations
/// Focused responsibility: Type definitions for help system

// MARK: - Help Context Types

enum HelpContext: String, CaseIterable {
    case general = "general"
    case transactions = "transactions"
    case budgeting = "budgeting"
    case reports = "reports"
    case settings = "settings"
}

enum HelpTopic: String, CaseIterable {
    case transactions = "transactions"
    case budgeting = "budgeting" 
    case reports = "reports"
    case settings = "settings"
}

enum ExpertiseLevel: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

// MARK: - Help Frequency and Priority

enum HelpFrequency: String, CaseIterable {
    case never = "never"
    case rarely = "rarely"
    case sometimes = "sometimes"
    case often = "often"
}

enum AssistancePriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Assistance and Content Types

enum AssistanceType: String, CaseIterable {
    case tooltip = "tooltip"
    case walkthrough = "walkthrough"
    case tutorial = "tutorial"
    case documentation = "documentation"
}

enum ContentType: String, CaseIterable {
    case text = "text"
    case video = "video"
    case interactive = "interactive"
    case documentation = "documentation"
}

// MARK: - User Learning and Needs

enum LearningStyle: String, CaseIterable {
    case visual = "visual"
    case auditory = "auditory"
    case kinesthetic = "kinesthetic"
    case reading = "reading"
}

enum UserNeed: String, CaseIterable {
    case quickAnswer = "quick_answer"
    case detailedExplanation = "detailed_explanation"
    case stepByStep = "step_by_step"
    case troubleshooting = "troubleshooting"
}

enum DifficultyLevel: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
}