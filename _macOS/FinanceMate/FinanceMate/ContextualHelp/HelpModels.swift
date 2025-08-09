import Foundation

/// Help system data models and structures
/// Focused responsibility: Help-related data models

// MARK: - Help Session Model

struct HelpSession: Identifiable, Codable {
    let id = UUID()
    let context: HelpContext
    let topic: HelpTopic
    let startTime: Date
    var endTime: Date?
    var isCompleted: Bool = false
    var userRating: Int?
    
    init(context: HelpContext, topic: HelpTopic) {
        self.context = context
        self.topic = topic
        self.startTime = Date()
    }
}

// MARK: - Help Suggestion Model

struct HelpSuggestion: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let priority: AssistancePriority
    let type: AssistanceType
    let context: HelpContext
    let estimatedDuration: TimeInterval
    let isPersonalized: Bool
    
    init(
        title: String,
        description: String,
        priority: AssistancePriority = .medium,
        type: AssistanceType = .tooltip,
        context: HelpContext = .general,
        estimatedDuration: TimeInterval = 60,
        isPersonalized: Bool = false
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.type = type
        self.context = context
        self.estimatedDuration = estimatedDuration
        self.isPersonalized = isPersonalized
    }
}

// MARK: - User Struggle Tracking

struct UserStruggle: Identifiable, Codable {
    let id = UUID()
    let context: HelpContext
    let topic: HelpTopic
    let timestamp: Date
    let description: String
    let difficulty: DifficultyLevel
    var resolved: Bool = false
    
    init(
        context: HelpContext,
        topic: HelpTopic,
        description: String,
        difficulty: DifficultyLevel = .medium
    ) {
        self.context = context
        self.topic = topic
        self.description = description
        self.difficulty = difficulty
        self.timestamp = Date()
    }
}

// MARK: - Help Content Model

struct HelpContent: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let type: ContentType
    let topic: HelpTopic
    let difficulty: DifficultyLevel
    let estimatedReadTime: TimeInterval
    let tags: [String]
    
    init(
        title: String,
        content: String,
        type: ContentType = .text,
        topic: HelpTopic,
        difficulty: DifficultyLevel = .medium,
        estimatedReadTime: TimeInterval = 120,
        tags: [String] = []
    ) {
        self.title = title
        self.content = content
        self.type = type
        self.topic = topic
        self.difficulty = difficulty
        self.estimatedReadTime = estimatedReadTime
        self.tags = tags
    }
}

// MARK: - User Preferences Model

struct HelpPreferences: Codable {
    var isEnabled: Bool = true
    var preferredLearningStyle: LearningStyle = .visual
    var preferredContentType: ContentType = .interactive
    var helpFrequency: HelpFrequency = .sometimes
    var showTooltips: Bool = true
    var enableWalkthroughs: Bool = true
    var personalizedRecommendations: Bool = true
    
    static let `default` = HelpPreferences()
}