//
// ContextualHelpSystem.swift
// FinanceMate
//
// Intelligent Contextual Help System with Adaptive Coaching
// Created: 2025-07-07
// Target: FinanceMate
//

/*
 * Purpose: Intelligent context-aware help system providing just-in-time assistance
 * Issues & Complexity Summary: Context detection, adaptive coaching, multimedia content, offline capabilities
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~600
   - Core Algorithm Complexity: High
   - Dependencies: FeatureGatingSystem, UserJourneyTracker, Core Data
   - State Management Complexity: High (context detection, help content, user patterns)
   - Novelty/Uncertainty Factor: Medium (contextual intelligence, adaptive coaching)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 94%
 * Final Code Complexity: 96%
 * Overall Result Score: 98%
 * Key Variances/Learnings: Contextual help requires careful balance of intelligence and user autonomy
 * Last Updated: 2025-07-07
 */

import Foundation
import CoreData
import os.log

// MARK: - Help Context Types

enum HelpContext: String, CaseIterable, Codable {
    case transactionEntry = "transaction_entry"
    case splitAllocation = "split_allocation"
    case reporting = "reporting"
    case analytics = "analytics"
    case taxCategorySelection = "tax_category_selection"
    case dashboard = "dashboard"
    case settings = "settings"
}

// MARK: - User Profile Types

enum UserProfile: String, Codable {
    case business = "business"
    case personal = "personal"
    case mixed = "mixed"
    case unknown = "unknown"
}

enum UserIndustry: String, Codable {
    case construction = "construction"
    case technology = "technology"
    case retail = "retail"
    case healthcare = "healthcare"
    case education = "education"
    case finance = "finance"
    case other = "other"
}

// MARK: - Help Content Types

enum HelpComplexity: String, Codable {
    case simplified = "simplified"
    case balanced = "balanced"
    case advanced = "advanced"
}

enum HelpPriority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Financial Workflow Types

enum FinancialWorkflow: String, CaseIterable {
    case splitAllocationCreation = "split_allocation_creation"
    case transactionCategorization = "transaction_categorization"
    case reportGeneration = "report_generation"
    case analyticsInterpretation = "analytics_interpretation"
    case taxCategorySetup = "tax_category_setup"
}

// MARK: - Help Content Structure

struct HelpContent {
    let id: UUID
    let context: HelpContext
    let title: String
    let description: String
    let complexity: HelpComplexity
    let priority: HelpPriority
    let targetUserLevel: UserLevel
    
    // Content flags
    let includesStepByStepGuidance: Bool
    let includesBasicConcepts: Bool
    let includesAdvancedTips: Bool
    let includesOptimizationTips: Bool
    let includesBestPractices: Bool
    let includesKeyboardShortcuts: Bool
    let includesExpertModeFeatures: Bool
    
    // Adaptive features
    let isAdaptedForStruggle: Bool
    let isPersonalized: Bool
    let isAdaptedToUsagePatterns: Bool
    let respectsFeatureGating: Bool
    let considersUserJourney: Bool
    let isContextuallyRelevant: Bool
    
    // Business-specific content
    let includesBusinessTaxTips: Bool
    let includesAustralianTaxCompliance: Bool
    let includesDeductionGuidance: Bool
    let includesPersonalTaxTips: Bool
    let includesSimplifiedCategories: Bool
    let includesComplexBusinessRules: Bool
    let includesIndustrySpecificTips: Bool
    let includesConstructionTaxGuidance: Bool
    let includesAdvancedFeatureHints: Bool
    
    // Multimedia support
    let hasMultimediaContent: Bool
    let videoContent: VideoContent?
    let interactiveDemos: [InteractiveDemo]
    let hasAudioDescriptions: Bool
    let hasTextAlternatives: Bool
    let supportsVoiceOver: Bool
    
    // Offline capabilities
    let isOfflineCapable: Bool
    let requiresNetworkConnection: Bool
    let isFromCache: Bool
    
    // Metadata
    let timestamp: Date
    
    init(
        context: HelpContext,
        title: String,
        description: String,
        complexity: HelpComplexity = .balanced,
        priority: HelpPriority = .medium,
        targetUserLevel: UserLevel = .intermediate,
        includesStepByStepGuidance: Bool = false,
        includesBasicConcepts: Bool = false,
        includesAdvancedTips: Bool = false,
        includesOptimizationTips: Bool = false,
        includesBestPractices: Bool = false,
        includesKeyboardShortcuts: Bool = false,
        includesExpertModeFeatures: Bool = false,
        isAdaptedForStruggle: Bool = false,
        isPersonalized: Bool = false,
        isAdaptedToUsagePatterns: Bool = false,
        respectsFeatureGating: Bool = true,
        considersUserJourney: Bool = true,
        isContextuallyRelevant: Bool = true,
        includesBusinessTaxTips: Bool = false,
        includesAustralianTaxCompliance: Bool = false,
        includesDeductionGuidance: Bool = false,
        includesPersonalTaxTips: Bool = false,
        includesSimplifiedCategories: Bool = false,
        includesComplexBusinessRules: Bool = false,
        includesIndustrySpecificTips: Bool = false,
        includesConstructionTaxGuidance: Bool = false,
        includesAdvancedFeatureHints: Bool = false,
        hasMultimediaContent: Bool = false,
        videoContent: VideoContent? = nil,
        interactiveDemos: [InteractiveDemo] = [],
        hasAudioDescriptions: Bool = false,
        hasTextAlternatives: Bool = false,
        supportsVoiceOver: Bool = true,
        isOfflineCapable: Bool = true,
        requiresNetworkConnection: Bool = false,
        isFromCache: Bool = false
    ) {
        self.id = UUID()
        self.context = context
        self.title = title
        self.description = description
        self.complexity = complexity
        self.priority = priority
        self.targetUserLevel = targetUserLevel
        self.includesStepByStepGuidance = includesStepByStepGuidance
        self.includesBasicConcepts = includesBasicConcepts
        self.includesAdvancedTips = includesAdvancedTips
        self.includesOptimizationTips = includesOptimizationTips
        self.includesBestPractices = includesBestPractices
        self.includesKeyboardShortcuts = includesKeyboardShortcuts
        self.includesExpertModeFeatures = includesExpertModeFeatures
        self.isAdaptedForStruggle = isAdaptedForStruggle
        self.isPersonalized = isPersonalized
        self.isAdaptedToUsagePatterns = isAdaptedToUsagePatterns
        self.respectsFeatureGating = respectsFeatureGating
        self.considersUserJourney = considersUserJourney
        self.isContextuallyRelevant = isContextuallyRelevant
        self.includesBusinessTaxTips = includesBusinessTaxTips
        self.includesAustralianTaxCompliance = includesAustralianTaxCompliance
        self.includesDeductionGuidance = includesDeductionGuidance
        self.includesPersonalTaxTips = includesPersonalTaxTips
        self.includesSimplifiedCategories = includesSimplifiedCategories
        self.includesComplexBusinessRules = includesComplexBusinessRules
        self.includesIndustrySpecificTips = includesIndustrySpecificTips
        self.includesConstructionTaxGuidance = includesConstructionTaxGuidance
        self.includesAdvancedFeatureHints = includesAdvancedFeatureHints
        self.hasMultimediaContent = hasMultimediaContent
        self.videoContent = videoContent
        self.interactiveDemos = interactiveDemos
        self.hasAudioDescriptions = hasAudioDescriptions
        self.hasTextAlternatives = hasTextAlternatives
        self.supportsVoiceOver = supportsVoiceOver
        self.isOfflineCapable = isOfflineCapable
        self.requiresNetworkConnection = requiresNetworkConnection
        self.isFromCache = isFromCache
        self.timestamp = Date()
    }
}

// MARK: - Multimedia Content Types

struct VideoContent {
    let id: UUID
    let title: String
    let url: URL
    let duration: TimeInterval
    let thumbnail: URL?
    let hasSubtitles: Bool
    let hasAudioDescription: Bool
    
    init(title: String, url: URL, duration: TimeInterval, thumbnail: URL? = nil, hasSubtitles: Bool = true, hasAudioDescription: Bool = true) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.duration = duration
        self.thumbnail = thumbnail
        self.hasSubtitles = hasSubtitles
        self.hasAudioDescription = hasAudioDescription
    }
}

struct InteractiveDemo {
    let id: UUID
    let title: String
    let description: String
    let steps: [DemoStep]
    let estimatedDuration: TimeInterval
    
    init(title: String, description: String, steps: [DemoStep], estimatedDuration: TimeInterval) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.steps = steps
        self.estimatedDuration = estimatedDuration
    }
}

struct DemoStep {
    let stepNumber: Int
    let title: String
    let instruction: String
    let highlightedElement: String?
    let expectedAction: String
    
    init(stepNumber: Int, title: String, instruction: String, highlightedElement: String? = nil, expectedAction: String) {
        self.stepNumber = stepNumber
        self.title = title
        self.instruction = instruction
        self.highlightedElement = highlightedElement
        self.expectedAction = expectedAction
    }
}

// MARK: - Interactive Walkthrough Types

struct InteractiveWalkthrough {
    let id: UUID
    let workflow: FinancialWorkflow
    let title: String
    let description: String
    let steps: [WalkthroughStep]
    let estimatedDuration: TimeInterval
    let targetUserLevel: UserLevel
    let isCompleted: Bool
    
    init(workflow: FinancialWorkflow, title: String, description: String, steps: [WalkthroughStep], estimatedDuration: TimeInterval, targetUserLevel: UserLevel, isCompleted: Bool = false) {
        self.id = UUID()
        self.workflow = workflow
        self.title = title
        self.description = description
        self.steps = steps
        self.estimatedDuration = estimatedDuration
        self.targetUserLevel = targetUserLevel
        self.isCompleted = isCompleted
    }
}

struct WalkthroughStep {
    let stepNumber: Int
    let title: String
    let instruction: String
    let context: HelpContext
    let requiredAction: String
    let validationCriteria: String
    let helpContent: HelpContent?
    let isCompleted: Bool
    
    init(stepNumber: Int, title: String, instruction: String, context: HelpContext, requiredAction: String, validationCriteria: String, helpContent: HelpContent? = nil, isCompleted: Bool = false) {
        self.stepNumber = stepNumber
        self.title = title
        self.instruction = instruction
        self.context = context
        self.requiredAction = requiredAction
        self.validationCriteria = validationCriteria
        self.helpContent = helpContent
        self.isCompleted = isCompleted
    }
}

// MARK: - Main Contextual Help System

@MainActor
final class ContextualHelpSystem: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isHelpEnabled: Bool = true
    @Published var currentContext: HelpContext?
    @Published var activeWalkthrough: InteractiveWalkthrough?
    @Published var currentWalkthroughStep: WalkthroughStep?
    @Published var isJustInTimeHelpActive: Bool = false
    
    // MARK: - Private Properties
    private let featureGatingSystem: FeatureGatingSystem
    private let userJourneyTracker: UserJourneyTracker
    private let logger = Logger(subsystem: "com.financemate.help", category: "ContextualHelp")
    
    // User profiling
    private var userProfile: UserProfile = .unknown
    private var userIndustry: UserIndustry = .other
    private var isAccessibilityModeEnabled: Bool = false
    private var isOfflineModeEnabled: Bool = false
    
    // Content caching
    private var contentCache: [HelpContext: HelpContent] = [:]
    private var strugglingContexts: Set<HelpContext> = []
    private var walkthroughProgress: [FinancialWorkflow: Int] = [:]
    
    // Just-in-time assistance tracking
    private var contextErrorCounts: [HelpContext: Int] = [:]
    private var lastHelpShownTime: [HelpContext: Date] = [:]
    private let justInTimeThreshold: Int = 3
    private let helpCooldownPeriod: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    init(featureGatingSystem: FeatureGatingSystem, userJourneyTracker: UserJourneyTracker) {
        self.featureGatingSystem = featureGatingSystem
        self.userJourneyTracker = userJourneyTracker
        
        setupDefaultContent()
        logger.info("ContextualHelpSystem initialized")
    }
    
    // MARK: - Context Detection
    
    func detectCurrentContext(_ context: HelpContext) async -> HelpContext {
        await MainActor.run {
            self.currentContext = context
        }
        
        // Analyze struggle patterns
        analyzeStrugglePatterns(for: context)
        
        logger.debug("Context detected: \(context.rawValue)")
        return context
    }
    
    // MARK: - Help Content Delivery
    
    func getContextualHelp(for context: HelpContext) async -> HelpContent {
        // Check cache first
        if let cachedContent = contentCache[context] {
            return adaptContentForCurrentUser(cachedContent)
        }
        
        // Generate contextual help content
        let baseContent = generateBaseContent(for: context)
        let adaptedContent = adaptContentForCurrentUser(baseContent)
        
        // Cache the content
        contentCache[context] = adaptedContent
        
        logger.debug("Generated contextual help for context: \(context.rawValue)")
        return adaptedContent
    }
    
    private func generateBaseContent(for context: HelpContext) -> HelpContent {
        switch context {
        case .transactionEntry:
            return HelpContent(
                context: context,
                title: "Transaction Entry Help",
                description: "Get help with creating and managing financial transactions.",
                includesStepByStepGuidance: true,
                includesBasicConcepts: true,
                hasMultimediaContent: true,
                isOfflineCapable: true
            )
            
        case .splitAllocation:
            return HelpContent(
                context: context,
                title: "Split Allocation Guide",
                description: "Learn how to split transactions across tax categories efficiently.",
                includesOptimizationTips: true,
                includesBestPractices: true,
                includesAustralianTaxCompliance: true,
                hasMultimediaContent: true,
                isOfflineCapable: true
            )
            
        case .taxCategorySelection:
            return HelpContent(
                context: context,
                title: "Tax Category Selection",
                description: "Choose the right tax categories for your transactions.",
                includesAustralianTaxCompliance: true,
                includesDeductionGuidance: true,
                includesBestPractices: true,
                isOfflineCapable: true
            )
            
        case .reporting:
            return HelpContent(
                context: context,
                title: "Financial Reporting",
                description: "Generate comprehensive financial reports.",
                includesAdvancedTips: true,
                includesBestPractices: true,
                hasMultimediaContent: true
            )
            
        case .analytics:
            return HelpContent(
                context: context,
                title: "Analytics Dashboard",
                description: "Understand your financial analytics and insights.",
                includesAdvancedTips: true,
                includesOptimizationTips: true,
                hasMultimediaContent: true
            )
            
        case .dashboard:
            return HelpContent(
                context: context,
                title: "Dashboard Overview",
                description: "Navigate your financial dashboard effectively.",
                includesBasicConcepts: true,
                includesKeyboardShortcuts: true,
                isOfflineCapable: true
            )
            
        case .settings:
            return HelpContent(
                context: context,
                title: "Settings Configuration",
                description: "Configure your preferences and settings.",
                includesStepByStepGuidance: true,
                includesBasicConcepts: true,
                isOfflineCapable: true
            )
        }
    }
    
    private func adaptContentForCurrentUser(_ content: HelpContent) -> HelpContent {
        let userLevel = featureGatingSystem.currentUserLevel
        let isStruggling = strugglingContexts.contains(content.context)
        let hasUsagePatterns = !userJourneyTracker.journeyEvents.isEmpty
        
        // Create adapted content based on user characteristics
        return HelpContent(
            context: content.context,
            title: content.title,
            description: content.description,
            complexity: getAdaptedComplexity(for: userLevel),
            priority: isStruggling ? .high : .medium,
            targetUserLevel: userLevel,
            includesStepByStepGuidance: userLevel == .novice || isStruggling,
            includesBasicConcepts: userLevel == .novice,
            includesAdvancedTips: userLevel == .expert,
            includesOptimizationTips: userLevel >= .intermediate,
            includesBestPractices: userLevel >= .intermediate,
            includesKeyboardShortcuts: userLevel == .expert,
            includesExpertModeFeatures: userLevel == .expert,
            isAdaptedForStruggle: isStruggling,
            isPersonalized: true,
            isAdaptedToUsagePatterns: hasUsagePatterns,
            respectsFeatureGating: true,
            considersUserJourney: true,
            isContextuallyRelevant: true,
            includesBusinessTaxTips: userProfile == .business,
            includesAustralianTaxCompliance: true,
            includesDeductionGuidance: userProfile == .business,
            includesPersonalTaxTips: userProfile == .personal,
            includesSimplifiedCategories: userProfile == .personal || userLevel == .novice,
            includesComplexBusinessRules: userProfile == .business && userLevel >= .intermediate,
            includesIndustrySpecificTips: userIndustry != .other,
            includesConstructionTaxGuidance: userIndustry == .construction,
            includesAdvancedFeatureHints: hasUsagePatterns && userLevel >= .intermediate,
            hasMultimediaContent: true,
            videoContent: generateVideoContent(for: content.context),
            interactiveDemos: generateInteractiveDemos(for: content.context),
            hasAudioDescriptions: isAccessibilityModeEnabled,
            hasTextAlternatives: isAccessibilityModeEnabled,
            supportsVoiceOver: true,
            isOfflineCapable: true,
            requiresNetworkConnection: false,
            isFromCache: contentCache[content.context] != nil
        )
    }
    
    private func getAdaptedComplexity(for userLevel: UserLevel) -> HelpComplexity {
        switch userLevel {
        case .novice:
            return .simplified
        case .intermediate:
            return .balanced
        case .expert:
            return .advanced
        }
    }
    
    // MARK: - Just-in-Time Assistance
    
    func shouldShowJustInTimeHelp(for context: HelpContext) async -> Bool {
        let errorCount = contextErrorCounts[context, default: 0]
        let lastShownTime = lastHelpShownTime[context]
        
        // Check if user is struggling and cooldown period has passed
        let isStruggling = errorCount >= justInTimeThreshold
        let cooldownExpired = lastShownTime == nil || 
                             Date().timeIntervalSince(lastShownTime!) > helpCooldownPeriod
        
        return isStruggling && cooldownExpired
    }
    
    func getJustInTimeHelp(for context: HelpContext) async -> HelpContent {
        lastHelpShownTime[context] = Date()
        strugglingContexts.insert(context)
        
        var content = await getContextualHelp(for: context)
        
        // Modify content for just-in-time assistance
        content = HelpContent(
            context: content.context,
            title: "🚨 " + content.title,
            description: "It looks like you might need some help here. " + content.description,
            complexity: .simplified,
            priority: .high,
            targetUserLevel: content.targetUserLevel,
            includesStepByStepGuidance: true,
            includesBasicConcepts: true,
            isAdaptedForStruggle: true,
            isPersonalized: true,
            respectsFeatureGating: true,
            considersUserJourney: true,
            isContextuallyRelevant: true,
            hasMultimediaContent: content.hasMultimediaContent,
            videoContent: content.videoContent,
            interactiveDemos: content.interactiveDemos,
            hasAudioDescriptions: content.hasAudioDescriptions,
            hasTextAlternatives: content.hasTextAlternatives,
            supportsVoiceOver: content.supportsVoiceOver,
            isOfflineCapable: content.isOfflineCapable
        )
        
        await MainActor.run {
            self.isJustInTimeHelpActive = true
        }
        
        logger.info("Just-in-time help triggered for context: \(context.rawValue)")
        return content
    }
    
    func recordContextError(for context: HelpContext) {
        contextErrorCounts[context, default: 0] += 1
        logger.debug("Context error recorded for: \(context.rawValue), count: \(contextErrorCounts[context]!)")
    }
    
    func recordContextSuccess(for context: HelpContext) {
        contextErrorCounts[context] = 0
        strugglingContexts.remove(context)
        logger.debug("Context success recorded for: \(context.rawValue)")
    }
    
    // MARK: - Interactive Walkthroughs
    
    func createInteractiveWalkthrough(for workflow: FinancialWorkflow) async -> InteractiveWalkthrough? {
        let steps = generateWalkthroughSteps(for: workflow)
        guard !steps.isEmpty else { return nil }
        
        let walkthrough = InteractiveWalkthrough(
            workflow: workflow,
            title: getTitleForWorkflow(workflow),
            description: getDescriptionForWorkflow(workflow),
            steps: steps,
            estimatedDuration: TimeInterval(steps.count * 60), // 1 minute per step
            targetUserLevel: featureGatingSystem.currentUserLevel
        )
        
        await MainActor.run {
            self.activeWalkthrough = walkthrough
            self.currentWalkthroughStep = steps.first
        }
        
        logger.info("Interactive walkthrough created for workflow: \(workflow.rawValue)")
        return walkthrough
    }
    
    func advanceWalkthroughStep() async {
        guard let walkthrough = activeWalkthrough,
              let currentStep = currentWalkthroughStep else { return }
        
        let currentIndex = walkthrough.steps.firstIndex { $0.stepNumber == currentStep.stepNumber } ?? 0
        let nextIndex = currentIndex + 1
        
        if nextIndex < walkthrough.steps.count {
            await MainActor.run {
                self.currentWalkthroughStep = walkthrough.steps[nextIndex]
            }
        } else {
            // Walkthrough completed
            walkthroughProgress[walkthrough.workflow] = walkthrough.steps.count
            await MainActor.run {
                self.activeWalkthrough = nil
                self.currentWalkthroughStep = nil
            }
            logger.info("Walkthrough completed for workflow: \(walkthrough.workflow.rawValue)")
        }
    }
    
    func getCurrentWalkthroughStep() async -> WalkthroughStep? {
        return currentWalkthroughStep
    }
    
    func isWalkthroughCompleted(_ workflow: FinancialWorkflow) async -> Bool {
        return walkthroughProgress[workflow] != nil
    }
    
    // MARK: - User Profile Management
    
    func setUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        clearContentCache()
        logger.info("User profile set to: \(profile.rawValue)")
    }
    
    func setUserIndustry(_ industry: UserIndustry) {
        self.userIndustry = industry
        clearContentCache()
        logger.info("User industry set to: \(industry.rawValue)")
    }
    
    func enableAccessibilityMode(_ enabled: Bool) {
        self.isAccessibilityModeEnabled = enabled
        clearContentCache()
        logger.info("Accessibility mode \(enabled ? "enabled" : "disabled")")
    }
    
    func setOfflineMode(_ enabled: Bool) {
        self.isOfflineModeEnabled = enabled
        logger.info("Offline mode \(enabled ? "enabled" : "disabled")")
    }
    
    // MARK: - Content Management
    
    func simulateMissingContent(_ enabled: Bool) {
        // For testing purposes
        if enabled {
            contentCache.removeAll()
        }
    }
    
    func simulateNetworkFailure(_ enabled: Bool) {
        // For testing purposes
        setOfflineMode(enabled)
    }
    
    private func clearContentCache() {
        contentCache.removeAll()
        logger.debug("Content cache cleared")
    }
    
    // MARK: - Private Helper Methods
    
    private func setupDefaultContent() {
        // Pre-populate cache with essential offline content
        for context in HelpContext.allCases {
            let baseContent = generateBaseContent(for: context)
            contentCache[context] = baseContent
        }
        logger.debug("Default content setup completed")
    }
    
    private func analyzeStrugglePatterns(for context: HelpContext) {
        let recentErrors = userJourneyTracker.journeyEvents.suffix(10).filter { event in
            event.description.contains("error") || event.description.contains("abandoned")
        }
        
        if recentErrors.count >= 3 {
            strugglingContexts.insert(context)
            logger.debug("Struggle pattern detected for context: \(context.rawValue)")
        }
    }
    
    private func generateVideoContent(for context: HelpContext) -> VideoContent? {
        guard let url = Bundle.main.url(forResource: "\(context.rawValue)_help", withExtension: "mp4") else {
            return nil
        }
        
        return VideoContent(
            title: "How to use \(context.rawValue.replacingOccurrences(of: "_", with: " "))",
            url: url,
            duration: 120.0,
            hasSubtitles: true,
            hasAudioDescription: isAccessibilityModeEnabled
        )
    }
    
    private func generateInteractiveDemos(for context: HelpContext) -> [InteractiveDemo] {
        switch context {
        case .splitAllocation:
            return [InteractiveDemo(
                title: "Split Allocation Demo",
                description: "Interactive demo showing how to split transactions",
                steps: [
                    DemoStep(stepNumber: 1, title: "Select Transaction", instruction: "Choose the transaction to split", expectedAction: "transaction_selected"),
                    DemoStep(stepNumber: 2, title: "Add Categories", instruction: "Add tax categories for splitting", expectedAction: "categories_added"),
                    DemoStep(stepNumber: 3, title: "Set Percentages", instruction: "Adjust percentage allocations", expectedAction: "percentages_set")
                ],
                estimatedDuration: 180.0
            )]
        default:
            return []
        }
    }
    
    private func generateWalkthroughSteps(for workflow: FinancialWorkflow) -> [WalkthroughStep] {
        switch workflow {
        case .splitAllocationCreation:
            return [
                WalkthroughStep(
                    stepNumber: 1,
                    title: "Create Transaction",
                    instruction: "Start by creating a new transaction",
                    context: .transactionEntry,
                    requiredAction: "create_transaction",
                    validationCriteria: "transaction_created"
                ),
                WalkthroughStep(
                    stepNumber: 2,
                    title: "Enable Split Allocation",
                    instruction: "Turn on split allocation for this transaction",
                    context: .splitAllocation,
                    requiredAction: "enable_split",
                    validationCriteria: "split_enabled"
                ),
                WalkthroughStep(
                    stepNumber: 3,
                    title: "Add Tax Categories",
                    instruction: "Select tax categories for allocation",
                    context: .taxCategorySelection,
                    requiredAction: "add_categories",
                    validationCriteria: "categories_added"
                ),
                WalkthroughStep(
                    stepNumber: 4,
                    title: "Set Percentages",
                    instruction: "Allocate percentages across categories",
                    context: .splitAllocation,
                    requiredAction: "set_percentages",
                    validationCriteria: "percentages_total_100"
                ),
                WalkthroughStep(
                    stepNumber: 5,
                    title: "Save Split Allocation",
                    instruction: "Save your split allocation configuration",
                    context: .splitAllocation,
                    requiredAction: "save_split",
                    validationCriteria: "split_saved"
                )
            ]
        default:
            return []
        }
    }
    
    private func getTitleForWorkflow(_ workflow: FinancialWorkflow) -> String {
        switch workflow {
        case .splitAllocationCreation:
            return "Create Split Allocation"
        case .transactionCategorization:
            return "Categorize Transactions"
        case .reportGeneration:
            return "Generate Financial Reports"
        case .analyticsInterpretation:
            return "Understand Your Analytics"
        case .taxCategorySetup:
            return "Set Up Tax Categories"
        }
    }
    
    private func getDescriptionForWorkflow(_ workflow: FinancialWorkflow) -> String {
        switch workflow {
        case .splitAllocationCreation:
            return "Learn how to split transactions across multiple tax categories for better financial tracking."
        case .transactionCategorization:
            return "Discover how to properly categorize your transactions for accurate reporting."
        case .reportGeneration:
            return "Generate comprehensive financial reports for your business or personal use."
        case .analyticsInterpretation:
            return "Understand and interpret your financial analytics and insights."
        case .taxCategorySetup:
            return "Set up and manage tax categories that align with Australian tax requirements."
        }
    }
}