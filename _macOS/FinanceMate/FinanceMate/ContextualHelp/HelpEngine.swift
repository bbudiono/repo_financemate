import Foundation
import OSLog

/// Core help engine for contextual assistance
/// Focused responsibility: Help logic and context analysis
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class HelpEngine: ObservableObject {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "HelpEngine")
    private let preferences: HelpPreferences
    
    // User expertise tracking
    private var userExpertiseLevels: [HelpTopic: ExpertiseLevel] = [:]
    private var userCompetencyLevels: [HelpTopic: Double] = [:]
    
    // Current context tracking
    @Published var currentContext: HelpContext = .general
    @Published var activeSession: HelpSession?
    
    // MARK: - Initialization
    
    init(preferences: HelpPreferences = .default) {
        self.preferences = preferences
        initializeUserExpertise()
    }
    
    // MARK: - Context Management
    
    /// Update the current help context
    func updateContext(_ newContext: HelpContext) {
        logger.info("Help context updated from \(currentContext.rawValue) to \(newContext.rawValue)")
        currentContext = newContext
    }
    
    /// Start a new help session for the given topic
    func startHelpSession(for topic: HelpTopic) {
        let session = HelpSession(context: currentContext, topic: topic)
        activeSession = session
        logger.info("Started help session for topic: \(topic.rawValue)")
    }
    
    /// End the current help session
    func endHelpSession(rating: Int? = nil) {
        guard var session = activeSession else { return }
        
        session.endTime = Date()
        session.isCompleted = true
        session.userRating = rating
        
        logger.info("Ended help session for topic: \(session.topic.rawValue)")
        activeSession = nil
    }
    
    // MARK: - Suggestion Generation
    
    /// Generate contextual help suggestions based on current context
    func generateContextualSuggestions() -> [HelpSuggestion] {
        guard preferences.isEnabled else { return [] }
        
        var suggestions: [HelpSuggestion] = []
        
        // Generate context-specific suggestions
        switch currentContext {
        case .transactions:
            suggestions.append(contentsOf: generateTransactionSuggestions())
        case .budgeting:
            suggestions.append(contentsOf: generateBudgetingSuggestions())
        case .reports:
            suggestions.append(contentsOf: generateReportsSuggestions())
        case .settings:
            suggestions.append(contentsOf: generateSettingsSuggestions())
        case .general:
            suggestions.append(contentsOf: generateGeneralSuggestions())
        }
        
        // Sort by priority and personalization
        return suggestions.sorted { first, second in
            if first.priority != second.priority {
                return first.priority.sortOrder > second.priority.sortOrder
            }
            return first.isPersonalized && !second.isPersonalized
        }
    }
    
    // MARK: - User Progress Tracking
    
    /// Update user expertise level for a topic
    func updateUserExpertise(topic: HelpTopic, level: ExpertiseLevel) {
        userExpertiseLevels[topic] = level
        logger.info("Updated user expertise for \(topic.rawValue) to \(level.rawValue)")
    }
    
    /// Get user expertise level for a topic
    func getUserExpertise(for topic: HelpTopic) -> ExpertiseLevel {
        return userExpertiseLevels[topic] ?? .beginner
    }
    
    // MARK: - Private Methods
    
    private func initializeUserExpertise() {
        // Initialize with beginner level for all topics
        for topic in HelpTopic.allCases {
            userExpertiseLevels[topic] = .beginner
            userCompetencyLevels[topic] = 0.0
        }
    }
    
    private func generateTransactionSuggestions() -> [HelpSuggestion] {
        return [
            HelpSuggestion(
                title: "Adding Transactions",
                description: "Learn how to add and categorize transactions",
                priority: .high,
                type: .walkthrough,
                context: .transactions
            )
        ]
    }
    
    private func generateBudgetingSuggestions() -> [HelpSuggestion] {
        return [
            HelpSuggestion(
                title: "Creating Budgets",
                description: "Set up your first budget and track spending",
                priority: .medium,
                type: .tutorial,
                context: .budgeting
            )
        ]
    }
    
    private func generateReportsSuggestions() -> [HelpSuggestion] {
        return [
            HelpSuggestion(
                title: "Understanding Reports",
                description: "Navigate financial reports and insights",
                priority: .medium,
                type: .documentation,
                context: .reports
            )
        ]
    }
    
    private func generateSettingsSuggestions() -> [HelpSuggestion] {
        return [
            HelpSuggestion(
                title: "Personalizing Settings",
                description: "Customize FinanceMate to fit your needs",
                priority: .low,
                type: .tooltip,
                context: .settings
            )
        ]
    }
    
    private func generateGeneralSuggestions() -> [HelpSuggestion] {
        return [
            HelpSuggestion(
                title: "Getting Started",
                description: "Welcome to FinanceMate - let's get you started",
                priority: .high,
                type: .walkthrough,
                context: .general,
                isPersonalized: true
            )
        ]
    }
}

// MARK: - Priority Sorting Extension

private extension AssistancePriority {
    var sortOrder: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}