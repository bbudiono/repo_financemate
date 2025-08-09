//
// FeatureGatingSystem.swift
// FinanceMate
//
// Advanced Feature Gating System
// Created: 2025-07-07
// Target: FinanceMate
//

/*
 * Purpose: Intelligent feature gating and progressive disclosure based on user competency
 * Issues & Complexity Summary: User profiling, adaptive features, progressive unlocking
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~550
   - Core Algorithm Complexity: High
   - Dependencies: UserJourneyTracker, OnboardingViewModel, Core Data context
   - State Management Complexity: High (competency scores, feature states, user preferences)
   - Novelty/Uncertainty Factor: Medium (adaptive UX patterns, competency algorithms)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 93%
 * Final Code Complexity: 95%
 * Overall Result Score: 97%
 * Key Variances/Learnings: Adaptive feature gating requires careful balance of intelligence and user control
 * Last Updated: 2025-07-07
 */

import Foundation
import CoreData
import os.log

// MARK: - Feature Types

enum FeatureType: String, CaseIterable, Codable {
    // Basic Features
    case basicTransactionEntry = "basic_transaction_entry"
    case simpleReporting = "simple_reporting"
    
    // Intermediate Features
    case basicSplitAllocation = "basic_split_allocation"
    case customTaxCategories = "custom_tax_categories"
    case advancedReporting = "advanced_reporting"
    
    // Advanced Features
    case advancedSplitAllocation = "advanced_split_allocation"
    case complexTaxCategories = "complex_tax_categories"
    case mlPoweredSuggestions = "ml_powered_suggestions"
    case analytics = "analytics"
    case predictiveAnalytics = "predictive_analytics"
}

// MARK: - User Levels

enum UserLevel: String, Codable, Comparable {
    case novice = "novice"
    case intermediate = "intermediate"
    case expert = "expert"
    
    static func < (lhs: UserLevel, rhs: UserLevel) -> Bool {
        let order: [UserLevel] = [.novice, .intermediate, .expert]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Competency Factors

struct CompetencyFactors {
    let transactionManagementScore: Double
    let splitAllocationScore: Double
    let reportingScore: Double
    let analyticsScore: Double
    let overallScore: Double
    
    init(transactionManagement: Double, splitAllocation: Double, reporting: Double, analytics: Double) {
        self.transactionManagementScore = transactionManagement
        self.splitAllocationScore = splitAllocation
        self.reportingScore = reporting
        self.analyticsScore = analytics
        self.overallScore = (transactionManagement + splitAllocation + reporting + analytics) / 4.0
    }
}

// MARK: - Smart Defaults

enum SplitStrategy: String {
    case simple50_50 = "simple_50_50"
    case seventyThirty = "seventy_thirty"
    case intelligentSuggestion = "intelligent_suggestion"
    case businessOptimized = "business_optimized"
}

struct SmartDefaults {
    let defaultSplitStrategy: SplitStrategy
    let defaultTaxCategory: String
    let enableValidationHelp: Bool
    let enableAdvancedCalculations: Bool
    let learnFromUserPatterns: Bool
    let suggestionConfidence: Double
    let enableBusinessFeatures: Bool
    
    init(
        splitStrategy: SplitStrategy = .simple50_50,
        taxCategory: String = "Personal",
        validationHelp: Bool = true,
        advancedCalculations: Bool = false,
        learnFromPatterns: Bool = false,
        confidence: Double = 0.0,
        businessFeatures: Bool = false
    ) {
        self.defaultSplitStrategy = splitStrategy
        self.defaultTaxCategory = taxCategory
        self.enableValidationHelp = validationHelp
        self.enableAdvancedCalculations = advancedCalculations
        self.learnFromUserPatterns = learnFromPatterns
        self.suggestionConfidence = confidence
        self.enableBusinessFeatures = businessFeatures
    }
}

// MARK: - Usage Analytics

struct FeatureUsageEvent {
    let feature: FeatureType
    let success: Bool
    let timeSpent: TimeInterval
    let timestamp: Date
    
    init(feature: FeatureType, success: Bool, timeSpent: TimeInterval, timestamp: Date = Date()) {
        self.feature = feature
        self.success = success
        self.timeSpent = timeSpent
        self.timestamp = timestamp
    }
}

struct FeatureUsageAnalytics {
    let totalInteractions: Int
    let successRate: Double
    let averageTimeSpent: TimeInterval
    let mostUsedFeatures: [FeatureType]
    let strugglingFeatures: [FeatureType]
}

// MARK: - Usage Insights

enum InsightType {
    case strugglingFeature
    case underutilizedFeature
    case proficientFeature
    case opportunityForAdvancement
}

enum RecommendedAction {
    case provideTutorial
    case simplifyInterface
    case offerAdvancedFeatures
    case personalizeDefaults
}

struct UsageInsight {
    let type: InsightType
    let feature: FeatureType
    let recommendedAction: RecommendedAction
    let confidence: Double
    let description: String
}

// MARK: - UI Configuration

enum ComplexityLevel {
    case simplified
    case balanced
    case advanced
}

struct AdaptiveUIConfiguration {
    let complexityLevel: ComplexityLevel
    let showHelpPrompts: Bool
    let showOptionalHelpPrompts: Bool
    let showAdvancedOptions: Bool
    let enableGuidedWorkflows: Bool
    let enableExpertMode: Bool
    
    init(
        complexity: ComplexityLevel,
        helpPrompts: Bool = false,
        optionalHelp: Bool = false,
        advancedOptions: Bool = false,
        guidedWorkflows: Bool = false,
        expertMode: Bool = false
    ) {
        self.complexityLevel = complexity
        self.showHelpPrompts = helpPrompts
        self.showOptionalHelpPrompts = optionalHelp
        self.showAdvancedOptions = advancedOptions
        self.enableGuidedWorkflows = guidedWorkflows
        self.enableExpertMode = expertMode
    }
}

// MARK: - Context Types

enum FeatureContext {
    case transactionManagement
    case splitAllocation
    case reporting
    case analytics
}

// MARK: - User Preferences

enum UserPreference {
    case alwaysShowAdvancedFields
    case minimizeHelpText
    case enableExpertMode
    case disableAdaptiveUI
}

// MARK: - Main FeatureGatingSystem Class

// EMERGENCY FIX: Removed @MainActor to eliminate Swift Concurrency crashes
final class FeatureGatingSystem: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentUserLevel: UserLevel = .novice
    @Published var availableFeatures: Set<FeatureType> = []
    @Published var isAdvancedFeaturesUnlocked: Bool = false
    @Published var isRollbackModeActive: Bool = false
    @Published var shouldSuggestRollback: Bool = false
    @Published var canOfferAdvancementFromRollback: Bool = false
    
    // MARK: - Private Properties
    private let userJourneyTracker: UserJourneyTracker
    private let logger = Logger(subsystem: "com.financemate.features", category: "FeatureGating")
    
    // Analytics and tracking
    private var featureUsageHistory: [FeatureUsageEvent] = []
    private var competencyScores: [FeatureContext: Double] = [:]
    private var userPreferences: [UserPreference: Bool] = [:]
    
    // Rollback and adaptation
    private var rollbackStartTime: Date?
    private var preRollbackLevel: UserLevel?
    private var adaptationEnabled: Bool = true
    
    // Smart defaults and learning
    private var learnedPatterns: [String: Any] = [:]
    private var defaultsEvolutionScore: Double = 0.0
    
    // MARK: - Initialization
    
    init(userJourneyTracker: UserJourneyTracker) {
        self.userJourneyTracker = userJourneyTracker
        
        // Initialize with basic features
        updateFeatureAvailability()
        logger.info("FeatureGatingSystem initialized with \(self.availableFeatures.count) initial features")
    }
    
    // MARK: - User Competency Calculation
    
    func calculateUserCompetencyScore() -> Double {
        let journeyEvents = userJourneyTracker.journeyEvents
        
        // Early return for insufficient data
        guard !journeyEvents.isEmpty else { return 0.0 }
        
        let transactionScore = calculateTransactionCompetency(events: journeyEvents)
        let splitScore = calculateSplitAllocationCompetency(events: journeyEvents)
        let reportingScore = calculateReportingCompetency(events: journeyEvents)
        let analyticsScore = calculateAnalyticsCompetency(events: journeyEvents)
        
        let overallScore = (transactionScore + splitScore + reportingScore + analyticsScore) / 4.0
        
        // Update user level based on competency
        updateUserLevel(basedOn: overallScore)
        
        return overallScore
    }
    
    func analyzeCompetencyFactors() -> CompetencyFactors {
        let journeyEvents = userJourneyTracker.journeyEvents
        
        let transactionScore = calculateTransactionCompetency(events: journeyEvents)
        let splitScore = calculateSplitAllocationCompetency(events: journeyEvents)
        let reportingScore = calculateReportingCompetency(events: journeyEvents)
        let analyticsScore = calculateAnalyticsCompetency(events: journeyEvents)
        
        return CompetencyFactors(
            transactionManagement: transactionScore,
            splitAllocation: splitScore,
            reporting: reportingScore,
            analytics: analyticsScore
        )
    }
    
    // MARK: - Feature Availability Management
    
    func updateFeatureAvailability() {
        let competencyScore = calculateUserCompetencyScore()
        var newFeatures: Set<FeatureType> = []
        
        // Always available basic features
        newFeatures.insert(.basicTransactionEntry)
        newFeatures.insert(.simpleReporting)
        
        // Intermediate features (competency > 0.3 or onboarding completed)
        if competencyScore > 0.3 || hasCompletedOnboarding() {
            newFeatures.insert(.basicSplitAllocation)
            newFeatures.insert(.customTaxCategories)
            newFeatures.insert(.advancedReporting)
        }
        
        // Advanced features (competency > 0.7 or mastery demonstrated)
        if competencyScore > 0.7 || hasDemonstratedMastery() {
            newFeatures.insert(.advancedSplitAllocation)
            newFeatures.insert(.complexTaxCategories)
            newFeatures.insert(.analytics)
        }
        
        // Expert features (competency > 0.85)
        if competencyScore > 0.85 {
            newFeatures.insert(.mlPoweredSuggestions)
            newFeatures.insert(.predictiveAnalytics)
            isAdvancedFeaturesUnlocked = true
        }
        
        // Apply rollback mode if active
        if isRollbackModeActive {
            newFeatures = applyRollbackFiltering(to: newFeatures)
        }
        
        // Apply user preference overrides
        newFeatures = applyUserPreferences(to: newFeatures)
        
        availableFeatures = newFeatures
        logger.info("Updated feature availability: \(newFeatures.count) features available")
    }
    
    func isFeatureAvailable(_ feature: FeatureType) -> Bool {
        return availableFeatures.contains(feature)
    }
    
    // MARK: - Adaptive UI Configuration
    
    func getAdaptiveUIConfiguration() -> AdaptiveUIConfiguration {
        guard adaptationEnabled && !hasUserOverridePreferences() else {
            return AdaptiveUIConfiguration(complexity: .advanced, advancedOptions: true, expertMode: true)
        }
        
        switch currentUserLevel {
        case .novice:
            return AdaptiveUIConfiguration(
                complexity: .simplified,
                helpPrompts: true,
                guidedWorkflows: true
            )
        case .intermediate:
            return AdaptiveUIConfiguration(
                complexity: .balanced,
                optionalHelp: true,
                advancedOptions: true
            )
        case .expert:
            return AdaptiveUIConfiguration(
                complexity: .advanced,
                advancedOptions: true,
                expertMode: true
            )
        }
    }
    
    func getContextualUIConfiguration(for context: FeatureContext) -> AdaptiveUIConfiguration {
        let contextualScore = competencyScores[context] ?? 0.0
        
        switch contextualScore {
        case 0.0..<0.4:
            return AdaptiveUIConfiguration(complexity: .simplified, helpPrompts: true)
        case 0.4..<0.8:
            return AdaptiveUIConfiguration(complexity: .balanced, optionalHelp: true, advancedOptions: true)
        default:
            return AdaptiveUIConfiguration(complexity: .advanced, advancedOptions: true, expertMode: true)
        }
    }
    
    // MARK: - Smart Defaults
    
    func getSmartDefaults() -> SmartDefaults {
        let competencyScore = calculateUserCompetencyScore()
        let businessRatio = calculateBusinessTransactionRatio()
        
        if competencyScore < 0.3 {
            return SmartDefaults() // Basic defaults for novice users
        } else if competencyScore < 0.7 {
            return SmartDefaults(
                splitStrategy: defaultsEvolutionScore > 0.5 ? .intelligentSuggestion : .seventyThirty,
                validationHelp: true,
                learnFromPatterns: true,
                confidence: min(defaultsEvolutionScore, 0.8)
            )
        } else {
            // Expert level defaults
            let splitStrategy: SplitStrategy = businessRatio > 0.6 ? .businessOptimized : .intelligentSuggestion
            return SmartDefaults(
                splitStrategy: splitStrategy,
                taxCategory: businessRatio > 0.5 ? "Business" : "Personal",
                validationHelp: false,
                advancedCalculations: true,
                learnFromPatterns: true,
                confidence: defaultsEvolutionScore,
                businessFeatures: businessRatio > 0.5
            )
        }
    }
    
    // MARK: - Feature Usage Analytics
    
    func recordFeatureUsage(_ feature: FeatureType, success: Bool, timeSpent: TimeInterval) {
        let event = FeatureUsageEvent(feature: feature, success: success, timeSpent: timeSpent)
        featureUsageHistory.append(event)
        
        // Maintain memory limits
        if featureUsageHistory.count > 1000 {
            featureUsageHistory.removeFirst(featureUsageHistory.count - 1000)
        }
        
        // Update competency scores based on usage
        updateCompetencyFromUsage(event)
        
        // Check for struggling patterns
        checkForStrugglingPatterns()
        
        logger.info("Recorded feature usage: \(feature.rawValue), success: \(success)")
    }
    
    func getFeatureUsageAnalytics() -> FeatureUsageAnalytics {
        guard !featureUsageHistory.isEmpty else {
            return FeatureUsageAnalytics(
                totalInteractions: 0,
                successRate: 0.0,
                averageTimeSpent: 0.0,
                mostUsedFeatures: [],
                strugglingFeatures: []
            )
        }
        
        let totalInteractions = featureUsageHistory.count
        let successfulInteractions = featureUsageHistory.filter { $0.success }.count
        let successRate = Double(successfulInteractions) / Double(totalInteractions)
        let averageTimeSpent = featureUsageHistory.map { $0.timeSpent }.reduce(0, +) / Double(totalInteractions)
        
        // Analyze feature usage patterns
        let featureUsageCount = Dictionary(grouping: featureUsageHistory) { $0.feature }
        let mostUsedFeatures = featureUsageCount
            .sorted { $0.value.count > $1.value.count }
            .prefix(3)
            .map { $0.key }
        
        let strugglingFeatures = featureUsageCount
            .filter { _, events in
                let failureRate = Double(events.filter { !$0.success }.count) / Double(events.count)
                return failureRate > 0.6 && events.count >= 3
            }
            .map { $0.key }
        
        return FeatureUsageAnalytics(
            totalInteractions: totalInteractions,
            successRate: successRate,
            averageTimeSpent: averageTimeSpent,
            mostUsedFeatures: Array(mostUsedFeatures),
            strugglingFeatures: strugglingFeatures
        )
    }
    
    func generateUsageInsights() -> [UsageInsight] {
        let analytics = getFeatureUsageAnalytics()
        var insights: [UsageInsight] = []
        
        // Generate insights for struggling features
        for feature in analytics.strugglingFeatures {
            insights.append(UsageInsight(
                type: .strugglingFeature,
                feature: feature,
                recommendedAction: .provideTutorial,
                confidence: 0.85,
                description: "User is struggling with \(feature.rawValue). Consider providing additional guidance."
            ))
        }
        
        // Generate advancement opportunities
        if currentUserLevel == .intermediate && analytics.successRate > 0.8 {
            insights.append(UsageInsight(
                type: .opportunityForAdvancement,
                feature: .advancedSplitAllocation,
                recommendedAction: .offerAdvancedFeatures,
                confidence: 0.75,
                description: "User demonstrates competency and may benefit from advanced features."
            ))
        }
        
        return insights
    }
    
    // MARK: - Rollback Capabilities
    
    func requestInterfaceSimplification() {
        preRollbackLevel = currentUserLevel
        rollbackStartTime = Date()
        isRollbackModeActive = true
        currentUserLevel = .intermediate // Step down one level
        updateFeatureAvailability()
        
        logger.info("User requested interface simplification")
    }
    
    func acceptAutomaticRollback() {
        preRollbackLevel = currentUserLevel
        rollbackStartTime = Date()
        isRollbackModeActive = true
        currentUserLevel = .novice // Roll back to basics
        shouldSuggestRollback = false
        updateFeatureAvailability()
        
        logger.info("User accepted automatic rollback to simplified interface")
    }
    
    func acceptAdvancementFromRollback() {
        if let originalLevel = preRollbackLevel {
            currentUserLevel = min(originalLevel, .intermediate) // Gradual advancement
        }
        isRollbackModeActive = false
        canOfferAdvancementFromRollback = false
        rollbackStartTime = nil
        preRollbackLevel = nil
        updateFeatureAvailability()
        
        logger.info("User accepted advancement from rollback mode")
    }
    
    // MARK: - User Preferences
    
    func setUserPreference(_ preference: UserPreference, value: Bool) {
        userPreferences[preference] = value
        
        if preference == .disableAdaptiveUI {
            adaptationEnabled = !value
        }
        
        updateFeatureAvailability()
        logger.info("Updated user preference: \(preference)")
    }
    
    func setAdaptationEnabled(_ enabled: Bool) {
        adaptationEnabled = enabled
        updateFeatureAvailability()
    }
    
    var isAdaptationEnabled: Bool {
        return adaptationEnabled
    }
    
    var hasActiveUserOverrides: Bool {
        return userPreferences.values.contains(true)
    }
    
    // MARK: - Temporary Advanced Mode
    
    private var temporaryAdvancedModeExpiryTime: Date?
    
    func enableTemporaryAdvancedMode(duration: TimeInterval) {
        temporaryAdvancedModeExpiryTime = Date().addingTimeInterval(duration)
        updateFeatureAvailability()
        
        logger.info("Enabled temporary advanced mode for \(duration) seconds")
    }
    
    var isTemporaryAdvancedModeActive: Bool {
        guard let expiryTime = temporaryAdvancedModeExpiryTime else { return false }
        return Date() < expiryTime
    }
    
    func updateTemporaryModeStatus() {
        if let expiryTime = temporaryAdvancedModeExpiryTime, Date() >= expiryTime {
            temporaryAdvancedModeExpiryTime = nil
            updateFeatureAvailability()
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateTransactionCompetency(events: [JourneyEvent]) -> Double {
        let transactionEvents = events.filter { $0.type == .transactionCreated }
        let successfulTransactions = transactionEvents.filter { $0.metadata["success"] == "true" }
        
        guard !transactionEvents.isEmpty else { return 0.0 }
        
        let successRate = Double(successfulTransactions.count) / Double(transactionEvents.count)
        let frequencyScore = min(Double(transactionEvents.count) / 10.0, 1.0)
        
        return (successRate + frequencyScore) / 2.0
    }
    
    private func calculateSplitAllocationCompetency(events: [JourneyEvent]) -> Double {
        let splitEvents = events.filter { $0.type == .splitAllocationUsed || $0.type == .splitAllocationCompleted }
        let successfulSplits = splitEvents.filter { $0.metadata["success"] == "true" }
        
        guard !splitEvents.isEmpty else { return 0.0 }
        
        let successRate = Double(successfulSplits.count) / Double(splitEvents.count)
        let complexityScore = calculateAverageComplexity(from: splitEvents)
        
        return (successRate + complexityScore) / 2.0
    }
    
    private func calculateReportingCompetency(events: [JourneyEvent]) -> Double {
        let reportEvents = events.filter { $0.type == .reportGenerated }
        let advancedReports = reportEvents.filter { $0.metadata["type"] == "advanced" }
        
        guard !reportEvents.isEmpty else { return 0.0 }
        
        let frequencyScore = min(Double(reportEvents.count) / 5.0, 1.0)
        let complexityScore = Double(advancedReports.count) / Double(reportEvents.count)
        
        return (frequencyScore + complexityScore) / 2.0
    }
    
    private func calculateAnalyticsCompetency(events: [JourneyEvent]) -> Double {
        let analyticsEvents = events.filter { $0.type == .featureExplored && $0.metadata["feature"]?.contains("analytics") == true }
        
        let baseScore = min(Double(analyticsEvents.count) / 3.0, 1.0)
        return baseScore * 0.8 // Analytics is advanced, so scale down
    }
    
    private func calculateAverageComplexity(from events: [JourneyEvent]) -> Double {
        let complexityValues = events.compactMap { event in
            guard let categoriesString = event.metadata["categories"],
                  let categories = Int(categoriesString) else { return nil }
            return Double(categories) / 5.0 // Normalize to 0-1 scale
        }
        
        guard !complexityValues.isEmpty else { return 0.0 }
        return complexityValues.reduce(0, +) / Double(complexityValues.count)
    }
    
    private func updateUserLevel(basedOn competencyScore: Double) {
        let newLevel: UserLevel
        
        switch competencyScore {
        case 0.0..<0.4:
            newLevel = .novice
        case 0.4..<0.8:
            newLevel = .intermediate
        default:
            newLevel = .expert
        }
        
        if newLevel != currentUserLevel {
            currentUserLevel = newLevel
            logger.info("User level updated to: \(newLevel.rawValue)")
        }
    }
    
    private func hasCompletedOnboarding() -> Bool {
        return userJourneyTracker.journeyEvents.contains { $0.type == .onboardingCompleted }
    }
    
    private func hasDemonstratedMastery() -> Bool {
        let splitEvents = userJourneyTracker.journeyEvents.filter { $0.type == .splitAllocationCompleted }
        let successfulComplexSplits = splitEvents.filter { event in
            guard let categoriesString = event.metadata["categories"],
                  let categories = Int(categoriesString),
                  event.metadata["success"] == "true" else { return false }
            return categories >= 3
        }
        
        return successfulComplexSplits.count >= 5
    }
    
    private func calculateBusinessTransactionRatio() -> Double {
        let allTransactions = userJourneyTracker.journeyEvents.filter { $0.type == .transactionCreated }
        let businessTransactions = allTransactions.filter { $0.metadata["category"] == "business" }
        
        guard !allTransactions.isEmpty else { return 0.0 }
        return Double(businessTransactions.count) / Double(allTransactions.count)
    }
    
    private func applyRollbackFiltering(to features: Set<FeatureType>) -> Set<FeatureType> {
        // In rollback mode, limit to basic and some intermediate features
        let allowedFeatures: Set<FeatureType> = [
            .basicTransactionEntry,
            .simpleReporting,
            .basicSplitAllocation,
            .customTaxCategories
        ]
        
        return features.intersection(allowedFeatures)
    }
    
    private func applyUserPreferences(to features: Set<FeatureType>) -> Set<FeatureType> {
        var filteredFeatures = features
        
        if userPreferences[.alwaysShowAdvancedFields] == true {
            // Add advanced features regardless of competency
            filteredFeatures.insert(.advancedSplitAllocation)
            filteredFeatures.insert(.complexTaxCategories)
        }
        
        if userPreferences[.enableExpertMode] == true {
            // Add all expert features
            filteredFeatures.formUnion(FeatureType.allCases)
        }
        
        return filteredFeatures
    }
    
    private func hasUserOverridePreferences() -> Bool {
        return userPreferences[.alwaysShowAdvancedFields] == true ||
               userPreferences[.enableExpertMode] == true ||
               userPreferences[.disableAdaptiveUI] == true
    }
    
    private func updateCompetencyFromUsage(_ event: FeatureUsageEvent) {
        let context = mapFeatureToContext(event.feature)
        let currentScore = competencyScores[context] ?? 0.0
        
        // Simple learning algorithm: success increases score, failure decreases
        let impact = event.success ? 0.1 : -0.05
        let newScore = max(0.0, min(1.0, currentScore + impact))
        
        competencyScores[context] = newScore
        
        // Update defaults evolution based on successful patterns
        if event.success {
            defaultsEvolutionScore = min(1.0, defaultsEvolutionScore + 0.02)
        }
    }
    
    private func mapFeatureToContext(_ feature: FeatureType) -> FeatureContext {
        switch feature {
        case .basicTransactionEntry:
            return .transactionManagement
        case .basicSplitAllocation, .advancedSplitAllocation, .complexTaxCategories:
            return .splitAllocation
        case .simpleReporting, .advancedReporting:
            return .reporting
        case .analytics, .predictiveAnalytics, .mlPoweredSuggestions:
            return .analytics
        case .customTaxCategories:
            return .splitAllocation
        }
    }
    
    private func checkForStrugglingPatterns() {
        let recentEvents = featureUsageHistory.suffix(10)
        let failureRate = Double(recentEvents.filter { !$0.success }.count) / Double(recentEvents.count)
        
        if failureRate > 0.7 && recentEvents.count >= 5 {
            shouldSuggestRollback = true
            logger.warning("Detected struggling pattern, suggesting rollback")
        }
        
        // Check for improvement after rollback
        if isRollbackModeActive, let rollbackStart = rollbackStartTime {
            let eventsAfterRollback = featureUsageHistory.filter { $0.timestamp > rollbackStart }
            if eventsAfterRollback.count >= 5 {
                let postRollbackSuccessRate = Double(eventsAfterRollback.filter { $0.success }.count) / Double(eventsAfterRollback.count)
                if postRollbackSuccessRate > 0.8 {
                    canOfferAdvancementFromRollback = true
                }
            }
        }
    }
}

// MARK: - Extensions for Testing Support

extension FeatureGatingSystem {
    func setUserLevel(_ level: UserLevel) {
        currentUserLevel = level
        updateFeatureAvailability()
    }
    
    func setContextualCompetency(_ context: FeatureContext, score: Double) {
        competencyScores[context] = score
    }
}