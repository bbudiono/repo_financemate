import Foundation
import OSLog

/// Main contextual help system coordinator
/// Focused responsibility: Coordinate all help system modules and provide unified interface
// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class ContextualHelpSystem: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isHelpEnabled: Bool = true
    @Published var currentContext: HelpContext?
    
    // MARK: - Modular Components
    
    private let helpEngine: HelpEngine
    private let contentGenerator: HelpContentGenerator
    private let walkthroughManager: HelpWalkthroughManager
    private let multimediaManager: HelpMultimediaManager
    private let profileManager: HelpProfileManager
    private let justInTimeManager: HelpJustInTimeManager
    
    // MARK: - Private Properties
    
    private let logger = Logger(subsystem: "com.financemate.help", category: "ContextualHelpSystem")
    
    // MARK: - Initialization
    
    init(featureGatingSystem: FeatureGatingSystem? = nil, userJourneyTracker: UserJourneyTracker? = nil) {
        self.helpEngine = HelpEngine()
        self.contentGenerator = HelpContentGenerator()
        self.walkthroughManager = HelpWalkthroughManager()
        self.multimediaManager = HelpMultimediaManager()
        self.profileManager = HelpProfileManager()
        self.justInTimeManager = HelpJustInTimeManager()
        
        logger.info("ContextualHelpSystem initialized")
    }
    
    // MARK: - Context Detection
    
    /// Detect and set the current help context
    func detectCurrentContext(_ context: HelpContext) -> HelpContext {
        currentContext = context
        helpEngine.updateContext(context)
        logger.debug("Context detected: \(context.rawValue)")
        return context
    }
    
    // MARK: - Help Content Delivery
    
    /// Get contextual help for a specific context
    func getContextualHelp(for context: HelpContext) -> HelpContent {
        let content = contentGenerator.getContextualHelp(for: context)
        logger.debug("Generated contextual help for context: \(context.rawValue)")
        return content
    }
    
    /// Generate contextual suggestions based on current context
    func generateContextualSuggestions() -> [HelpSuggestion] {
        return helpEngine.generateContextualSuggestions()
    }
    
    // MARK: - Just-in-Time Assistance
    
    /// Check if just-in-time help should be shown
    func shouldShowJustInTimeHelp(for context: HelpContext) -> Bool {
        return justInTimeManager.shouldShowJustInTimeHelp(for: context)
    }
    
    /// Get just-in-time help for struggling users
    func getJustInTimeHelp(for context: HelpContext) -> HelpContent {
        justInTimeManager.recordJustInTimeHelpShown(for: context)
        contentGenerator.markContextAsStruggling(context)
        
        let content = contentGenerator.getContextualHelp(for: context)
        logger.info("Just-in-time help triggered for context: \(context.rawValue)")
        return content
    }
    
    /// Record an error in a specific context
    func recordContextError(for context: HelpContext) {
        justInTimeManager.recordContextError(for: context)
    }
    
    /// Record success in a specific context
    func recordContextSuccess(for context: HelpContext) {
        justInTimeManager.recordContextSuccess(for: context)
        contentGenerator.clearStrugglingStatus(for: context)
    }
    
    // MARK: - Interactive Walkthroughs
    
    /// Create an interactive walkthrough for a workflow
    func createInteractiveWalkthrough(for workflow: FinancialWorkflow) -> InteractiveWalkthrough? {
        return walkthroughManager.createInteractiveWalkthrough(for: workflow)
    }
    
    /// Advance to the next walkthrough step
    func advanceWalkthroughStep() {
        walkthroughManager.advanceWalkthroughStep()
    }
    
    /// Get the current walkthrough step
    func getCurrentWalkthroughStep() -> WalkthroughStep? {
        return walkthroughManager.getCurrentWalkthroughStep()
    }
    
    /// Check if a walkthrough is completed
    func isWalkthroughCompleted(_ workflow: FinancialWorkflow) -> Bool {
        return walkthroughManager.isWalkthroughCompleted(workflow)
    }
    
    // MARK: - Multimedia Content
    
    /// Generate video content for a context
    func generateVideoContent(for context: HelpContext) -> VideoContent? {
        return multimediaManager.generateVideoContent(for: context)
    }
    
    /// Generate interactive demos for a context
    func generateInteractiveDemos(for context: HelpContext) -> [InteractiveDemo] {
        return multimediaManager.generateInteractiveDemos(for: context)
    }
    
    /// Check if content is available offline
    func isContentAvailableOffline(for context: HelpContext) -> Bool {
        return multimediaManager.isContentAvailableOffline(for: context)
    }
    
    // MARK: - User Profile Management
    
    /// Set user profile for personalized help
    func setUserProfile(_ profile: UserProfile) {
        profileManager.setUserProfile(profile)
        contentGenerator.setUserProfile(profile)
    }
    
    /// Set user industry for specialized content
    func setUserIndustry(_ industry: UserIndustry) {
        profileManager.setUserIndustry(industry)
        contentGenerator.setUserIndustry(industry)
    }
    
    /// Enable accessibility features
    func enableAccessibilityMode(_ enabled: Bool) {
        profileManager.enableAccessibilityMode(enabled)
        contentGenerator.enableAccessibilityMode(enabled)
        multimediaManager.enableAccessibilityMode(enabled)
    }
    
    /// Set offline mode
    func setOfflineMode(_ enabled: Bool) {
        profileManager.setOfflineMode(enabled)
        multimediaManager.setOfflineMode(enabled)
    }
    
    // MARK: - Help Session Management
    
    /// Start a help session for a topic
    func startHelpSession(for topic: HelpTopic) {
        helpEngine.startHelpSession(for: topic)
    }
    
    /// End the current help session
    func endHelpSession(rating: Int? = nil) {
        helpEngine.endHelpSession(rating: rating)
        justInTimeManager.endJustInTimeHelp()
    }
    
    /// Update user expertise for a topic
    func updateUserExpertise(topic: HelpTopic, level: ExpertiseLevel) {
        helpEngine.updateUserExpertise(topic: topic, level: level)
    }
    
    /// Get user expertise for a topic
    func getUserExpertise(for topic: HelpTopic) -> ExpertiseLevel {
        return helpEngine.getUserExpertise(for: topic)
    }
    
    // MARK: - Computed Properties
    
    /// Get the active walkthrough
    var activeWalkthrough: InteractiveWalkthrough? {
        return walkthroughManager.activeWalkthrough
    }
    
    /// Get the current walkthrough step
    var currentWalkthroughStep: WalkthroughStep? {
        return walkthroughManager.currentWalkthroughStep
    }
    
    /// Check if just-in-time help is active
    var isJustInTimeHelpActive: Bool {
        return justInTimeManager.isJustInTimeHelpActive
    }
    
    // MARK: - Testing Support
    
    /// Simulate missing content for testing
    func simulateMissingContent(_ enabled: Bool) {
        contentGenerator.simulateMissingContent(enabled)
    }
    
    /// Simulate network failure for testing
    func simulateNetworkFailure(_ enabled: Bool) {
        multimediaManager.setOfflineMode(enabled)
    }
}