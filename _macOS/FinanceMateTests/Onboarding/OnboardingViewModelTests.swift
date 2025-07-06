//
// OnboardingViewModelTests.swift
// FinanceMateTests
//
// Comprehensive Onboarding System Test Suite for First-Time User Experience
// Created: 2025-07-07
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive test suite for OnboardingViewModel with multi-step user experience
 * Issues & Complexity Summary: Complex onboarding flow, progress tracking, sample data, tutorial system
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300
   - Core Algorithm Complexity: High
   - Dependencies: Core Data, UserDefaults, sample data generation
   - State Management Complexity: High (multi-step flow, progress tracking, completion states)
   - Novelty/Uncertainty Factor: Medium (onboarding best practices, user engagement)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 88%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-07-07
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
class OnboardingViewModelTests: XCTestCase {
    
    var onboardingViewModel: OnboardingViewModel!
    var testContext: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        testContext = persistenceController.container.viewContext
        
        // Clear any existing onboarding state
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
        UserDefaults.standard.removeObject(forKey: "currentOnboardingStep")
        
        // Initialize onboarding view model
        onboardingViewModel = OnboardingViewModel(context: testContext)
    }
    
    override func tearDown() async throws {
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingProgress")
        UserDefaults.standard.removeObject(forKey: "currentOnboardingStep")
        
        onboardingViewModel = nil
        testContext = nil
        persistenceController = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testOnboardingViewModelInitialization() {
        XCTAssertNotNil(onboardingViewModel, "OnboardingViewModel should initialize successfully")
        XCTAssertEqual(onboardingViewModel.context, testContext, "Context should be properly assigned")
        XCTAssertFalse(onboardingViewModel.hasCompletedOnboarding, "Should not have completed onboarding initially")
        XCTAssertEqual(onboardingViewModel.currentStep, 0, "Should start at step 0")
    }
    
    func testOnboardingStepsConfiguration() {
        let steps = onboardingViewModel.onboardingSteps
        XCTAssertTrue(steps.count >= 5, "Should have at least 5 onboarding steps")
        
        // Verify step types exist
        let stepTypes = steps.map { $0.type }
        XCTAssertTrue(stepTypes.contains(.welcome), "Should include welcome step")
        XCTAssertTrue(stepTypes.contains(.coreFeatures), "Should include core features step")
        XCTAssertTrue(stepTypes.contains(.lineItemDemo), "Should include line item demo step")
        XCTAssertTrue(stepTypes.contains(.taxCategoryEducation), "Should include tax category education step")
        XCTAssertTrue(stepTypes.contains(.sampleDataPlayground), "Should include sample data playground step")
    }
    
    // MARK: - Step Navigation Tests
    
    func testStepProgression() async throws {
        let initialStep = onboardingViewModel.currentStep
        let totalSteps = onboardingViewModel.onboardingSteps.count
        
        // Test forward navigation
        await onboardingViewModel.nextStep()
        XCTAssertEqual(onboardingViewModel.currentStep, initialStep + 1, "Should advance to next step")
        
        // Test progress calculation
        let expectedProgress = Double(onboardingViewModel.currentStep) / Double(totalSteps)
        XCTAssertEqual(onboardingViewModel.progress, expectedProgress, accuracy: 0.01, "Progress should be calculated correctly")
    }
    
    func testStepNavigationBoundaries() async throws {
        let totalSteps = onboardingViewModel.onboardingSteps.count
        
        // Test backward navigation from beginning
        await onboardingViewModel.previousStep()
        XCTAssertEqual(onboardingViewModel.currentStep, 0, "Should not go below step 0")
        
        // Navigate to last step
        onboardingViewModel.currentStep = totalSteps - 1
        
        // Test forward navigation from end
        await onboardingViewModel.nextStep()
        XCTAssertLessThan(onboardingViewModel.currentStep, totalSteps, "Should not exceed total steps")
    }
    
    func testSkipStep() async throws {
        let initialStep = onboardingViewModel.currentStep
        await onboardingViewModel.skipStep()
        
        XCTAssertEqual(onboardingViewModel.currentStep, initialStep + 1, "Skip should advance to next step")
        XCTAssertTrue(onboardingViewModel.skippedSteps.contains(initialStep), "Should track skipped step")
    }
    
    // MARK: - Progress Tracking Tests
    
    func testProgressCalculation() {
        let totalSteps = onboardingViewModel.onboardingSteps.count
        
        for step in 0..<totalSteps {
            onboardingViewModel.currentStep = step
            let expectedProgress = Double(step) / Double(totalSteps)
            XCTAssertEqual(onboardingViewModel.progress, expectedProgress, accuracy: 0.01, "Progress should be calculated correctly for step \(step)")
        }
    }
    
    func testProgressPersistence() async throws {
        // Set progress
        onboardingViewModel.currentStep = 3
        await onboardingViewModel.saveProgress()
        
        // Create new view model to test persistence
        let newViewModel = OnboardingViewModel(context: testContext)
        XCTAssertEqual(newViewModel.currentStep, 3, "Progress should be persisted across app launches")
    }
    
    func testCompletionTracking() async throws {
        let totalSteps = onboardingViewModel.onboardingSteps.count
        
        // Navigate to last step
        onboardingViewModel.currentStep = totalSteps - 1
        await onboardingViewModel.completeOnboarding()
        
        XCTAssertTrue(onboardingViewModel.hasCompletedOnboarding, "Should mark onboarding as completed")
        XCTAssertEqual(onboardingViewModel.progress, 1.0, accuracy: 0.01, "Progress should be 100% when completed")
    }
    
    // MARK: - Sample Data Generation Tests
    
    func testSampleDataGeneration() async throws {
        await onboardingViewModel.generateSampleData()
        
        // Verify sample transactions were created
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let sampleTransactions = try testContext.fetch(fetchRequest)
        
        XCTAssertGreaterThan(sampleTransactions.count, 0, "Should generate sample transactions")
        XCTAssertLessThanOrEqual(sampleTransactions.count, 20, "Should not generate excessive sample data")
        
        // Verify sample data includes line items with splits
        let transactionsWithLineItems = sampleTransactions.filter { transaction in
            guard let lineItems = transaction.lineItems as? Set<LineItem> else { return false }
            return !lineItems.isEmpty
        }
        
        XCTAssertGreaterThan(transactionsWithLineItems.count, 0, "Some sample transactions should have line items")
    }
    
    func testSampleDataVariety() async throws {
        await onboardingViewModel.generateSampleData()
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let sampleTransactions = try testContext.fetch(fetchRequest)
        
        // Check for category diversity
        let categories = Set(sampleTransactions.map { $0.category })
        XCTAssertGreaterThan(categories.count, 3, "Sample data should include diverse categories")
        
        // Check for amount diversity
        let amounts = sampleTransactions.map { $0.amount }
        let uniqueAmounts = Set(amounts)
        XCTAssertGreaterThan(uniqueAmounts.count, sampleTransactions.count / 2, "Sample data should have varied amounts")
    }
    
    func testSampleDataCleanup() async throws {
        // Generate sample data
        await onboardingViewModel.generateSampleData()
        
        // Verify sample data exists
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let sampleTransactions = try testContext.fetch(fetchRequest)
        XCTAssertGreaterThan(sampleTransactions.count, 0, "Sample data should exist")
        
        // Clean up sample data
        await onboardingViewModel.clearSampleData()
        
        // Verify sample data is removed
        let remainingTransactions = try testContext.fetch(fetchRequest)
        let sampleCount = remainingTransactions.filter { $0.note?.contains("Sample") == true }.count
        XCTAssertEqual(sampleCount, 0, "Sample data should be cleaned up")
    }
    
    // MARK: - Feature Discovery Tests
    
    func testFeatureHighlights() {
        let coreFeatures = onboardingViewModel.getCoreFeatureHighlights()
        
        XCTAssertGreaterThan(coreFeatures.count, 3, "Should highlight multiple core features")
        
        // Verify essential features are included
        let featureTitles = coreFeatures.map { $0.title }
        XCTAssertTrue(featureTitles.contains(where: { $0.contains("Transaction") }), "Should highlight transaction management")
        XCTAssertTrue(featureTitles.contains(where: { $0.contains("Split") }), "Should highlight split allocation")
        XCTAssertTrue(featureTitles.contains(where: { $0.contains("Tax") || $0.contains("Category") }), "Should highlight tax categories")
    }
    
    func testInteractiveDemo() async throws {
        // Start demo mode
        await onboardingViewModel.startInteractiveDemo()
        XCTAssertTrue(onboardingViewModel.isDemoMode, "Should enter demo mode")
        
        // Test demo transaction creation
        await onboardingViewModel.createDemoTransaction()
        
        // Verify demo transaction exists
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "note CONTAINS[c] %@", "Demo")
        let demoTransactions = try testContext.fetch(fetchRequest)
        
        XCTAssertGreaterThan(demoTransactions.count, 0, "Should create demo transaction")
        
        // End demo mode
        await onboardingViewModel.endInteractiveDemo()
        XCTAssertFalse(onboardingViewModel.isDemoMode, "Should exit demo mode")
    }
    
    // MARK: - Tutorial System Tests
    
    func testTutorialAvailability() {
        let tutorials = onboardingViewModel.getAvailableTutorials()
        
        XCTAssertGreaterThan(tutorials.count, 0, "Should have available tutorials")
        
        // Verify specific tutorials exist
        let tutorialTypes = tutorials.map { $0.type }
        XCTAssertTrue(tutorialTypes.contains(.transactionCreation), "Should include transaction creation tutorial")
        XCTAssertTrue(tutorialTypes.contains(.lineItemSplitting), "Should include line item splitting tutorial")
        XCTAssertTrue(tutorialTypes.contains(.taxCategoryManagement), "Should include tax category management tutorial")
    }
    
    func testTutorialCompletion() async throws {
        let tutorial = Tutorial(type: .transactionCreation, isCompleted: false)
        
        await onboardingViewModel.completeTutorial(tutorial)
        
        let completedTutorials = onboardingViewModel.getCompletedTutorials()
        XCTAssertTrue(completedTutorials.contains(where: { $0.type == .transactionCreation }), "Should mark tutorial as completed")
    }
    
    func testTutorialProgress() {
        let totalTutorials = onboardingViewModel.getAvailableTutorials().count
        let completedCount = onboardingViewModel.getCompletedTutorials().count
        
        let expectedProgress = totalTutorials > 0 ? Double(completedCount) / Double(totalTutorials) : 0.0
        XCTAssertEqual(onboardingViewModel.tutorialProgress, expectedProgress, accuracy: 0.01, "Tutorial progress should be calculated correctly")
    }
    
    // MARK: - User Engagement Tests
    
    func testEngagementTracking() async throws {
        let initialEngagement = onboardingViewModel.engagementScore
        
        // Simulate user interactions
        await onboardingViewModel.recordInteraction(.stepCompleted)
        await onboardingViewModel.recordInteraction(.featureExplored)
        await onboardingViewModel.recordInteraction(.tutorialStarted)
        
        XCTAssertGreaterThan(onboardingViewModel.engagementScore, initialEngagement, "Engagement score should increase with interactions")
    }
    
    func testEngagementMilestones() async throws {
        // Simulate high engagement
        for _ in 0..<10 {
            await onboardingViewModel.recordInteraction(.stepCompleted)
        }
        
        let milestones = onboardingViewModel.getAchievedMilestones()
        XCTAssertGreaterThan(milestones.count, 0, "Should achieve engagement milestones")
    }
    
    // MARK: - Skip and Resume Functionality Tests
    
    func testSkipOnboarding() async throws {
        await onboardingViewModel.skipOnboarding()
        
        XCTAssertTrue(onboardingViewModel.hasCompletedOnboarding, "Should mark onboarding as completed when skipped")
        XCTAssertEqual(onboardingViewModel.progress, 1.0, accuracy: 0.01, "Progress should be 100% when skipped")
    }
    
    func testResumeOnboarding() async throws {
        // Complete partial onboarding
        onboardingViewModel.currentStep = 3
        await onboardingViewModel.saveProgress()
        
        // Skip to completion
        await onboardingViewModel.skipOnboarding()
        
        // Resume onboarding
        await onboardingViewModel.resumeOnboarding()
        
        XCTAssertFalse(onboardingViewModel.hasCompletedOnboarding, "Should allow resuming onboarding")
        XCTAssertEqual(onboardingViewModel.currentStep, 3, "Should resume from previous step")
    }
    
    // MARK: - Error Handling Tests
    
    func testSampleDataGenerationFailure() async throws {
        // Simulate Core Data context failure
        let invalidContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let invalidViewModel = OnboardingViewModel(context: invalidContext)
        
        await invalidViewModel.generateSampleData()
        
        XCTAssertNotNil(invalidViewModel.errorMessage, "Should handle sample data generation errors")
        XCTAssertTrue(invalidViewModel.errorMessage?.contains("sample data") == true, "Error message should be descriptive")
    }
    
    func testProgressSaveFailure() async throws {
        // Test with invalid user defaults scenario
        let viewModel = OnboardingViewModel(context: testContext)
        viewModel.currentStep = -1  // Invalid step
        
        await viewModel.saveProgress()
        
        // Should handle gracefully and not crash
        XCTAssertNotNil(viewModel, "Should handle invalid progress save gracefully")
    }
    
    // MARK: - Australian Locale Compliance Tests
    
    func testAustralianLocaleFormatting() async throws {
        await onboardingViewModel.generateSampleData()
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let sampleTransactions = try testContext.fetch(fetchRequest)
        
        // Verify Australian currency formatting in sample data
        for transaction in sampleTransactions {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_AU")
            formatter.currencyCode = "AUD"
            
            let formattedAmount = formatter.string(from: NSNumber(value: transaction.amount))
            XCTAssertNotNil(formattedAmount, "Sample transaction amounts should be formattable in AUD")
            XCTAssertTrue(formattedAmount?.contains("$") == true, "Should use Australian dollar symbol")
        }
    }
    
    func testDateFormattingCompliance() {
        let formatter = onboardingViewModel.getDateFormatter()
        
        XCTAssertEqual(formatter.locale?.identifier, "en_AU", "Should use Australian locale")
        XCTAssertEqual(formatter.dateFormat, "dd/MM/yyyy", "Should use Australian date format")
        
        // Test date formatting
        let testDate = Date()
        let formattedDate = formatter.string(from: testDate)
        let components = formattedDate.components(separatedBy: "/")
        
        XCTAssertEqual(components.count, 3, "Should format date as dd/MM/yyyy")
    }
    
    // MARK: - Performance Tests
    
    func testOnboardingPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Test onboarding flow performance
        await onboardingViewModel.generateSampleData()
        await onboardingViewModel.startInteractiveDemo()
        
        for _ in 0..<5 {
            await onboardingViewModel.nextStep()
        }
        
        await onboardingViewModel.completeOnboarding()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, 3.0, "Onboarding flow should complete within 3 seconds")
    }
    
    func testSampleDataGenerationPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        await onboardingViewModel.generateSampleData()
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        XCTAssertLessThan(timeElapsed, 1.0, "Sample data generation should complete within 1 second")
    }
}