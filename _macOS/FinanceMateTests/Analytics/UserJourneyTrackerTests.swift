//
// UserJourneyTrackerTests.swift
// FinanceMateTests
//
// Privacy-Compliant User Journey Analytics Tests
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for user journey tracking and analytics
 * Issues & Complexity Summary: Privacy compliance, funnel analysis, recommendation accuracy
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~350
   - Core Algorithm Complexity: High
   - Dependencies: AnalyticsEngine, OnboardingViewModel, Core Data privacy patterns
   - State Management Complexity: High (journey state, analytics aggregation)
   - Novelty/Uncertainty Factor: Medium (privacy-preserving analytics, A/B testing)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
final class UserJourneyTrackerTests: XCTestCase {
    
    // MARK: - Test Properties
    var userJourneyTracker: UserJourneyTracker!
    var testContext: NSManagedObjectContext!
    var analyticsEngine: AnalyticsEngine!
    
    override func setUp() {
        super.setUp()
        testContext = PersistenceController.preview.container.viewContext
        analyticsEngine = AnalyticsEngine(context: testContext)
        userJourneyTracker = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine)
    }
    
    override func tearDown() {
        userJourneyTracker = nil
        analyticsEngine = nil
        testContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testUserJourneyTrackerInitialization() {
        XCTAssertNotNil(userJourneyTracker, "UserJourneyTracker should initialize successfully")
        XCTAssertEqual(userJourneyTracker.currentJourneyStage, .onboarding, "Initial journey stage should be onboarding")
        XCTAssertTrue(userJourneyTracker.journeyEvents.isEmpty, "Journey events should be empty initially")
    }
    
    // MARK: - Privacy-Compliant Analytics Tests
    
    func testPrivacyCompliantEventTracking() {
        // Given: A user action that should be tracked
        let eventType = JourneyEventType.transactionCreated
        let metadata = ["category": "business", "amount_range": "medium"]
        
        // When: Tracking the event
        userJourneyTracker.trackEvent(eventType, metadata: metadata)
        
        // Then: Event should be recorded without personally identifiable information
        XCTAssertEqual(userJourneyTracker.journeyEvents.count, 1, "One event should be tracked")
        let trackedEvent = userJourneyTracker.journeyEvents.first!
        XCTAssertEqual(trackedEvent.eventType, eventType, "Event type should match")
        XCTAssertFalse(trackedEvent.containsPII(), "Event should not contain PII")
        XCTAssertTrue(trackedEvent.metadata.keys.contains("category"), "Metadata should contain category")
        XCTAssertFalse(trackedEvent.metadata.keys.contains("exact_amount"), "Metadata should not contain exact amounts")
    }
    
    func testPrivacyDataAnonymization() {
        // Given: Various user data types
        let personalData = [
            "user_email": "john.smith@cba.com.au",
            "exact_amount": "1234.56",
            "merchant_name": "Specific Store Name",
            "description": "Personal transaction note"
        ]
        
        // When: Anonymizing the data
        let anonymizedData = userJourneyTracker.anonymizeEventData(personalData)
        
        // Then: Personal information should be removed or generalized
        XCTAssertFalse(anonymizedData.keys.contains("user_email"), "Email should be removed")
        XCTAssertFalse(anonymizedData.keys.contains("exact_amount"), "Exact amount should be removed")
        XCTAssertTrue(anonymizedData.keys.contains("amount_range"), "Amount should be bucketed")
        XCTAssertTrue(anonymizedData.keys.contains("merchant_category"), "Merchant should be categorized")
        XCTAssertFalse(anonymizedData.keys.contains("description"), "Personal descriptions should be removed")
    }
    
    // MARK: - Completion Funnel Analysis Tests
    
    func testFunnelAnalysisForOnboarding() {
        // Given: A series of onboarding events
        let onboardingEvents: [JourneyEventType] = [
            .onboardingStarted,
            .welcomeScreenViewed,
            .featuresExplained,
            .demoCompleted,
            .onboardingCompleted
        ]
        
        // When: Tracking onboarding funnel
        for event in onboardingEvents {
            userJourneyTracker.trackEvent(event)
        }
        
        // Then: Funnel analysis should show completion rates
        let funnelAnalysis = userJourneyTracker.analyzeFunnel(.onboarding)
        XCTAssertEqual(funnelAnalysis.totalSteps, 5, "Should track 5 onboarding steps")
        XCTAssertEqual(funnelAnalysis.completionRate, 1.0, accuracy: 0.01, "Should show 100% completion")
        XCTAssertEqual(funnelAnalysis.dropOffPoints.count, 0, "Should show no drop-off points")
    }
    
    func testFunnelAnalysisWithDropoffs() {
        // Given: Multiple users with different completion patterns
        let userJourneys = [
            [JourneyEventType.onboardingStarted, .welcomeScreenViewed, .featuresExplained, .onboardingCompleted],
            [JourneyEventType.onboardingStarted, .welcomeScreenViewed],
            [JourneyEventType.onboardingStarted, .welcomeScreenViewed, .featuresExplained],
            [JourneyEventType.onboardingStarted]
        ]
        
        // When: Simulating multiple user journeys
        for (index, journey) in userJourneys.enumerated() {
            let tracker = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine, userID: "user_\(index)")
            for event in journey {
                tracker.trackEvent(event)
            }
        }
        
        // Then: Aggregated funnel should show drop-off analysis
        let aggregatedFunnel = userJourneyTracker.analyzeAggregatedFunnel(.onboarding)
        XCTAssertEqual(aggregatedFunnel.totalUsers, 4, "Should track 4 users")
        XCTAssertTrue(aggregatedFunnel.dropOffPoints.contains(.featuresExplained), "Should identify features explanation as drop-off point")
        XCTAssertLessThan(aggregatedFunnel.completionRate, 0.5, "Completion rate should be less than 50%")
    }
    
    // MARK: - Personalized Recommendations Tests
    
    func testPersonalizedRecommendationsBasedOnUsage() async {
        // Given: User with specific usage patterns
        userJourneyTracker.trackEvent(.transactionCreated, metadata: ["category": "business", "frequency": "high"])
        userJourneyTracker.trackEvent(.splitAllocationUsed, metadata: ["complexity": "simple", "categories": "2"])
        userJourneyTracker.trackEvent(.reportGenerated, metadata: ["type": "tax_summary"])
        
        // When: Generating personalized recommendations
        let recommendations = await userJourneyTracker.generatePersonalizedRecommendations()
        
        // Then: Recommendations should be relevant to usage patterns
        XCTAssertGreaterThan(recommendations.count, 0, "Should generate recommendations")
        XCTAssertTrue(recommendations.contains { $0.category == .businessOptimization }, "Should recommend business optimization")
        XCTAssertTrue(recommendations.contains { $0.category == .advancedSplitting }, "Should recommend advanced splitting features")
        XCTAssertTrue(recommendations.first!.confidence > 0.7, "Recommendations should have high confidence")
    }
    
    func testRecommendationPersonalization() async {
        // Given: Different user types with distinct patterns
        let businessUser = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine, userID: "business_user")
        let personalUser = UserJourneyTracker(context: testContext, analyticsEngine: analyticsEngine, userID: "personal_user")
        
        // Business user patterns
        businessUser.trackEvent(.transactionCreated, metadata: ["category": "business", "tax_category": "deductible"])
        businessUser.trackEvent(.reportGenerated, metadata: ["type": "profit_loss"])
        
        // Personal user patterns
        personalUser.trackEvent(.transactionCreated, metadata: ["category": "personal", "type": "expense"])
        personalUser.trackEvent(.budgetSet, metadata: ["category": "household"])
        
        // When: Generating recommendations for each
        let businessRecs = await businessUser.generatePersonalizedRecommendations()
        let personalRecs = await personalUser.generatePersonalizedRecommendations()
        
        // Then: Recommendations should be personalized
        XCTAssertTrue(businessRecs.contains { $0.category == .taxOptimization }, "Business user should get tax optimization")
        XCTAssertTrue(personalRecs.contains { $0.category == .budgetManagement }, "Personal user should get budget management")
        XCTAssertNotEqual(businessRecs.map(\.category), personalRecs.map(\.category), "Recommendations should differ by user type")
    }
    
    // MARK: - Smart Split Allocation Suggestions Tests
    
    func testSplitAllocationSuggestions() async {
        // Given: Transaction with predictable split patterns
        let transaction = createTestTransaction(amount: 1000.0, category: "business_meal", description: "Client lunch")
        
        // When: Getting smart suggestions
        let suggestions = await userJourneyTracker.suggestSplitAllocations(for: transaction)
        
        // Then: Suggestions should be relevant and compliant
        XCTAssertGreaterThan(suggestions.count, 0, "Should provide split suggestions")
        XCTAssertTrue(suggestions.contains { $0.taxCategory == "business_entertainment" }, "Should suggest business entertainment category")
        XCTAssertEqual(suggestions.map(\.percentage).reduce(0, +), 100, "Suggestions should total 100%")
        XCTAssertTrue(suggestions.allSatisfy { $0.confidence > 0.6 }, "All suggestions should have reasonable confidence")
    }
    
    func testAdaptiveSplitLearning() async {
        // Given: User with established split patterns
        for i in 1...10 {
            let transaction = createTestTransaction(amount: Double(i * 100), category: "business_meal")
            userJourneyTracker.recordSplitDecision(transaction: transaction, 
                                                   allocations: [
                                                       SplitAllocation(percentage: 70, taxCategory: "business_entertainment"),
                                                       SplitAllocation(percentage: 30, taxCategory: "personal")
                                                   ])
        }
        
        // When: Getting suggestions for similar transaction
        let newTransaction = createTestTransaction(amount: 500.0, category: "business_meal")
        let learnedSuggestions = await userJourneyTracker.suggestSplitAllocations(for: newTransaction)
        
        // Then: Suggestions should reflect learned patterns
        let businessSuggestion = learnedSuggestions.first { $0.taxCategory == "business_entertainment" }
        XCTAssertNotNil(businessSuggestion, "Should suggest business entertainment category")
        XCTAssertEqual(businessSuggestion!.percentage, 70, accuracy: 5, "Should suggest 70% business split based on history")
        XCTAssertGreaterThan(businessSuggestion!.confidence, 0.8, "Should have high confidence based on pattern learning")
    }
    
    // MARK: - User Engagement Scoring Tests
    
    func testUserEngagementScoring() {
        // Given: Various user activities
        let activities: [(JourneyEventType, Date)] = [
            (.transactionCreated, Date().addingTimeInterval(-86400 * 7)), // 1 week ago
            (.splitAllocationUsed, Date().addingTimeInterval(-86400 * 5)), // 5 days ago
            (.reportGenerated, Date().addingTimeInterval(-86400 * 3)), // 3 days ago
            (.featureExplored, Date().addingTimeInterval(-86400 * 1)), // 1 day ago
            (.appOpened, Date()) // Today
        ]
        
        for (event, date) in activities {
            userJourneyTracker.trackEvent(event, timestamp: date)
        }
        
        // When: Calculating engagement score
        let engagementScore = userJourneyTracker.calculateEngagementScore()
        
        // Then: Score should reflect recent and diverse activity
        XCTAssertGreaterThan(engagementScore.totalScore, 0.7, "Should have high engagement score")
        XCTAssertGreaterThan(engagementScore.recencyScore, 0.8, "Should have high recency score")
        XCTAssertGreaterThan(engagementScore.diversityScore, 0.6, "Should have good diversity score")
        XCTAssertEqual(engagementScore.activityCount, 5, "Should count 5 activities")
    }
    
    func testEngagementTrends() {
        // Given: Activities over multiple weeks
        let weeklyActivity = [5, 8, 3, 12, 7] // Activities per week for 5 weeks
        
        for (week, count) in weeklyActivity.enumerated() {
            let weekStart = Date().addingTimeInterval(-86400 * 7 * Double(4 - week))
            for day in 0..<count {
                let eventDate = weekStart.addingTimeInterval(86400 * Double(day))
                userJourneyTracker.trackEvent(.transactionCreated, timestamp: eventDate)
            }
        }
        
        // When: Analyzing engagement trends
        let trends = userJourneyTracker.analyzeEngagementTrends(weeks: 5)
        
        // Then: Should identify trends and patterns
        XCTAssertEqual(trends.weeklyScores.count, 5, "Should analyze 5 weeks")
        XCTAssertEqual(trends.peakWeek, 3, "Week 4 (index 3) should be peak with 12 activities")
        XCTAssertTrue(trends.isEngagementIncreasing, "Recent weeks should show increasing engagement")
    }
    
    // MARK: - A/B Testing Framework Tests
    
    func testABTestingFramework() {
        // Given: A/B test configuration
        let testConfig = ABTestConfiguration(
            testName: "onboarding_flow_v2",
            variants: ["control", "simplified", "gamified"],
            trafficAllocation: [0.33, 0.33, 0.34]
        )
        
        // When: Setting up A/B test
        userJourneyTracker.configureABTest(testConfig)
        
        // Then: User should be assigned to a variant
        let assignedVariant = userJourneyTracker.getABTestVariant("onboarding_flow_v2")
        XCTAssertNotNil(assignedVariant, "User should be assigned to a variant")
        XCTAssertTrue(testConfig.variants.contains(assignedVariant!), "Assigned variant should be valid")
    }
    
    func testABTestResultAnalysis() {
        // Given: A/B test with recorded results
        let testName = "split_ui_optimization"
        userJourneyTracker.configureABTest(ABTestConfiguration(
            testName: testName,
            variants: ["current", "improved"],
            trafficAllocation: [0.5, 0.5]
        ))
        
        // Simulate test results
        userJourneyTracker.recordABTestEvent(testName: testName, variant: "current", event: .splitAllocationCompleted, success: true)
        userJourneyTracker.recordABTestEvent(testName: testName, variant: "current", event: .splitAllocationCompleted, success: false)
        userJourneyTracker.recordABTestEvent(testName: testName, variant: "improved", event: .splitAllocationCompleted, success: true)
        userJourneyTracker.recordABTestEvent(testName: testName, variant: "improved", event: .splitAllocationCompleted, success: true)
        
        // When: Analyzing test results
        let results = userJourneyTracker.analyzeABTestResults(testName)
        
        // Then: Should provide statistical analysis
        XCTAssertNotNil(results, "Should provide test results")
        XCTAssertEqual(results!.variants.count, 2, "Should analyze both variants")
        XCTAssertGreaterThan(results!.variants["improved"]!.successRate, results!.variants["current"]!.successRate, "Improved variant should perform better")
        XCTAssertTrue(results!.isStatisticallySignificant, "Results should be statistically significant")
    }
    
    // MARK: - User Feedback Collection Tests
    
    func testUserFeedbackCollection() {
        // Given: User feedback on various features
        let feedbackItems = [
            UserFeedback(feature: "split_allocation", rating: 4, comment: "Easy to use but could be faster"),
            UserFeedback(feature: "onboarding", rating: 5, comment: "Very helpful tutorial"),
            UserFeedback(feature: "reporting", rating: 3, comment: "Needs more customization options")
        ]
        
        // When: Collecting feedback
        for feedback in feedbackItems {
            userJourneyTracker.collectUserFeedback(feedback)
        }
        
        // Then: Feedback should be stored and analyzed
        let aggregatedFeedback = userJourneyTracker.getAggregatedFeedback()
        XCTAssertEqual(aggregatedFeedback.count, 3, "Should collect feedback for 3 features")
        XCTAssertEqual(aggregatedFeedback["onboarding"]?.averageRating, 5.0, "Onboarding should have 5.0 rating")
        XCTAssertEqual(aggregatedFeedback["reporting"]?.averageRating, 3.0, "Reporting should have 3.0 rating")
        XCTAssertTrue(aggregatedFeedback["split_allocation"]!.comments.contains("Easy to use but could be faster"), "Should store comments")
    }
    
    func testActionableInsightsFromFeedback() {
        // Given: Pattern of feedback indicating issues
        let negativeReportingFeedback = [
            UserFeedback(feature: "reporting", rating: 2, comment: "Too slow"),
            UserFeedback(feature: "reporting", rating: 2, comment: "Confusing interface"),
            UserFeedback(feature: "reporting", rating: 3, comment: "Limited export options"),
            UserFeedback(feature: "reporting", rating: 2, comment: "Charts are hard to read")
        ]
        
        for feedback in negativeReportingFeedback {
            userJourneyTracker.collectUserFeedback(feedback)
        }
        
        // When: Generating actionable insights
        let insights = userJourneyTracker.generateActionableInsights()
        
        // Then: Should identify improvement opportunities
        XCTAssertGreaterThan(insights.count, 0, "Should generate insights")
        let reportingInsight = insights.first { $0.feature == "reporting" }
        XCTAssertNotNil(reportingInsight, "Should have insights for reporting")
        XCTAssertEqual(reportingInsight!.priority, .high, "Should be high priority due to low ratings")
        XCTAssertTrue(reportingInsight!.suggestedActions.contains("performance_optimization"), "Should suggest performance optimization")
        XCTAssertTrue(reportingInsight!.suggestedActions.contains("ui_improvement"), "Should suggest UI improvement")
    }
    
    // MARK: - Performance and Privacy Tests
    
    func testPerformanceWithLargeDataset() {
        // Given: Large number of journey events
        let eventCount = 10000
        let startTime = Date()
        
        // When: Processing large dataset
        for i in 0..<eventCount {
            let eventType = JourneyEventType.allCases.randomElement()!
            userJourneyTracker.trackEvent(eventType, metadata: ["iteration": "\(i)"])
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        // Then: Should maintain performance
        XCTAssertLessThan(processingTime, 2.0, "Should process 10k events in under 2 seconds")
        XCTAssertEqual(userJourneyTracker.journeyEvents.count, eventCount, "Should track all events")
        
        // Memory usage should be reasonable
        let memoryFootprint = userJourneyTracker.estimateMemoryUsage()
        XCTAssertLessThan(memoryFootprint, 50_000_000, "Memory usage should be under 50MB for 10k events") // 50MB limit
    }
    
    func testPrivacyDataRetention() {
        // Given: Events tracked over time
        let oldEvent = JourneyEvent(type: .transactionCreated, timestamp: Date().addingTimeInterval(-86400 * 365)) // 1 year ago
        let recentEvent = JourneyEvent(type: .transactionCreated, timestamp: Date())
        
        userJourneyTracker.journeyEvents = [oldEvent, recentEvent]
        
        // When: Applying data retention policy
        userJourneyTracker.applyDataRetentionPolicy(maxAge: 86400 * 180) // 6 months
        
        // Then: Old events should be removed
        XCTAssertEqual(userJourneyTracker.journeyEvents.count, 1, "Should remove old events")
        XCTAssertEqual(userJourneyTracker.journeyEvents.first!.type, .transactionCreated, "Should keep recent events")
        XCTAssertGreaterThan(userJourneyTracker.journeyEvents.first!.timestamp, Date().addingTimeInterval(-86400 * 180), "Remaining event should be within retention period")
    }
    
    // MARK: - Helper Methods
    
    private func createTestTransaction(amount: Double, category: String = "general", description: String = "Test transaction") -> Transaction {
        let transaction = Transaction(context: testContext)
        transaction.id = UUID()
        transaction.amount = amount
        transaction.category = category
        transaction.note = description
        transaction.date = Date()
        transaction.createdAt = Date()
        return transaction
    }
}

// MARK: - Test Support Extensions

extension JourneyEvent {
    func containsPII() -> Bool {
        // Check if event contains personally identifiable information
        let piiKeys = ["user_email", "exact_amount", "merchant_name", "description", "user_id"]
        return metadata.keys.contains { piiKeys.contains($0) }
    }
}

extension JourneyEventType: CaseIterable {
    public static var allCases: [JourneyEventType] {
        return [
            .onboardingStarted, .welcomeScreenViewed, .featuresExplained, .demoCompleted, .onboardingCompleted,
            .transactionCreated, .splitAllocationUsed, .reportGenerated, .featureExplored, .appOpened,
            .splitAllocationCompleted, .budgetSet
        ]
    }
}