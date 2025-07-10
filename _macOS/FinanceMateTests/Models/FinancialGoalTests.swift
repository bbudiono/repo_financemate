/**
 * Purpose: Comprehensive unit tests for FinancialGoal Core Data model and SMART goal validation
 * Issues & Complexity Summary: Testing goal creation, progress calculation, SMART validation, and relationships
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~600
 *   - Core Algorithm Complexity: Medium (SMART validation, progress tracking)
 *   - Dependencies: Core Data, Date calculations, validation logic
 *   - State Management Complexity: Medium (goal states, milestone tracking)
 *   - Novelty/Uncertainty Factor: Low (standard patterns with financial domain logic)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */

import XCTest
import CoreData
@testable import FinanceMate

@MainActor
class FinancialGoalTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Basic Setup Test
    
    func testBasicSetup() {
        XCTAssertNotNil(context, "Context should be initialized")
        XCTAssertNotNil(persistenceController, "PersistenceController should be initialized")
    }
    
    // MARK: - Goal Creation Tests
    
    func testFinancialGoalCreation() {
        // Given
        let title = "Emergency Fund"
        let description = "Build emergency fund for 6 months expenses"
        let targetAmount = 30000.0
        let currentAmount = 5000.0
        let targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        let category = "Savings"
        let priority = "High"
        
        // When
        let goal = FinancialGoal.create(
            in: context,
            title: title,
            description: description,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            category: category,
            priority: priority
        )
        
        // Then
        XCTAssertEqual(goal.title, title, "Goal title should match input")
        XCTAssertEqual(goal.goalDescription, description, "Goal description should match input")
        XCTAssertEqual(goal.targetAmount, targetAmount, "Target amount should match input")
        XCTAssertEqual(goal.currentAmount, currentAmount, "Current amount should match input")
        XCTAssertEqual(goal.targetDate, targetDate, "Target date should match input")
        XCTAssertEqual(goal.category, category, "Category should match input")
        XCTAssertEqual(goal.priority, priority, "Priority should match input")
        XCTAssertFalse(goal.isAchieved, "New goal should not be achieved")
        XCTAssertNotNil(goal.id, "Goal should have a UUID")
        XCTAssertNotNil(goal.createdAt, "Goal should have creation date")
    }
    
    func testGoalProgressCalculation() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Test Goal",
            description: "Test description",
            targetAmount: 10000.0,
            currentAmount: 3000.0,
            targetDate: Date(),
            category: "Savings",
            priority: "Medium"
        )
        
        // When
        let progress = goal.calculateProgress()
        
        // Then
        XCTAssertEqual(progress, 0.3, accuracy: 0.001, "Progress should be 30%")
    }
    
    func testGoalProgressCalculationWithZeroTarget() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Test Goal",
            description: "Test description",
            targetAmount: 0.0,
            currentAmount: 1000.0,
            targetDate: Date(),
            category: "Savings",
            priority: "Low"
        )
        
        // When
        let progress = goal.calculateProgress()
        
        // Then
        XCTAssertEqual(progress, 0.0, "Progress should be 0% when target is zero")
    }
    
    func testGoalAchievementDetection() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Test Goal",
            description: "Test description",
            targetAmount: 5000.0,
            currentAmount: 5000.0,
            targetDate: Date(),
            category: "Savings",
            priority: "High"
        )
        
        // When
        goal.updateProgress(newAmount: 5000.0)
        
        // Then
        XCTAssertTrue(goal.isAchieved, "Goal should be marked as achieved when target is reached")
    }
    
    // MARK: - SMART Validation Tests
    
    func testSMARTValidationSuccess() {
        // Given
        let goalData = GoalFormData(
            title: "Save for vacation",
            description: "Save $5000 for European vacation by December 2025",
            targetAmount: 5000.0,
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            category: "Travel"
        )
        
        // When
        let validation = FinancialGoal.validateSMART(goalData)
        
        // Then
        XCTAssertTrue(validation.isValid, "SMART goal should be valid")
        XCTAssertTrue(validation.isSpecific, "Goal should be specific")
        XCTAssertTrue(validation.isMeasurable, "Goal should be measurable")
        XCTAssertTrue(validation.isAchievable, "Goal should be achievable")
        XCTAssertTrue(validation.isRelevant, "Goal should be relevant")
        XCTAssertTrue(validation.isTimeBound, "Goal should be time-bound")
    }
    
    func testSMARTValidationFailureVagueTitle() {
        // Given
        let goalData = GoalFormData(
            title: "Save",
            description: "",
            targetAmount: 1000.0,
            targetDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            category: "Savings"
        )
        
        // When
        let validation = FinancialGoal.validateSMART(goalData)
        
        // Then
        XCTAssertFalse(validation.isValid, "Vague goal should not be valid")
        XCTAssertFalse(validation.isSpecific, "Vague title should fail specific criteria")
    }
    
    func testSMARTValidationFailurePastDate() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let goalData = GoalFormData(
            title: "Build emergency fund",
            description: "Save for emergencies",
            targetAmount: 10000.0,
            targetDate: pastDate,
            category: "Emergency"
        )
        
        // When
        let validation = FinancialGoal.validateSMART(goalData)
        
        // Then
        XCTAssertFalse(validation.isValid, "Goal with past date should not be valid")
        XCTAssertFalse(validation.isTimeBound, "Past date should fail time-bound criteria")
    }
    
    func testSMARTValidationFailureUnrealisticAmount() {
        // Given
        let goalData = GoalFormData(
            title: "Save one million dollars",
            description: "Become a millionaire",
            targetAmount: 1000000.0,
            targetDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            category: "Wealth"
        )
        
        // When
        let validation = FinancialGoal.validateSMART(goalData)
        
        // Then
        XCTAssertFalse(validation.isValid, "Unrealistic goal should not be valid")
        XCTAssertFalse(validation.isAchievable, "Unrealistic amount should fail achievable criteria")
    }
    
    // MARK: - Milestone Tests
    
    func testMilestoneCreation() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Save for house deposit",
            description: "Save $100,000 for house deposit",
            targetAmount: 100000.0,
            currentAmount: 0.0,
            targetDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())!,
            category: "Property",
            priority: "High"
        )
        
        // When
        let milestone = GoalMilestone.create(
            in: context,
            title: "25% milestone",
            targetAmount: 25000.0,
            goal: goal
        )
        
        // Then
        XCTAssertEqual(milestone.title, "25% milestone", "Milestone title should match")
        XCTAssertEqual(milestone.targetAmount, 25000.0, "Milestone target should match")
        XCTAssertEqual(milestone.goal, goal, "Milestone should be linked to goal")
        XCTAssertFalse(milestone.isAchieved, "New milestone should not be achieved")
        XCTAssertNil(milestone.achievedDate, "New milestone should not have achieved date")
    }
    
    func testMilestoneAchievement() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Investment Goal",
            description: "Build investment portfolio",
            targetAmount: 50000.0,
            currentAmount: 15000.0,
            targetDate: Date(),
            category: "Investment",
            priority: "Medium"
        )
        
        let milestone = GoalMilestone.create(
            in: context,
            title: "30% milestone",
            targetAmount: 15000.0,
            goal: goal
        )
        
        // When
        milestone.markAsAchieved()
        
        // Then
        XCTAssertTrue(milestone.isAchieved, "Milestone should be marked as achieved")
        XCTAssertNotNil(milestone.achievedDate, "Achieved milestone should have achieved date")
    }
    
    func testAutomaticMilestoneGeneration() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Retirement Savings",
            description: "Build retirement fund",
            targetAmount: 1000000.0,
            currentAmount: 0.0,
            targetDate: Calendar.current.date(byAdding: .year, value: 30, to: Date())!,
            category: "Retirement",
            priority: "High"
        )
        
        // When
        goal.generateAutomaticMilestones()
        
        // Then
        XCTAssertGreaterThan(goal.milestones.count, 0, "Automatic milestones should be generated")
        XCTAssertEqual(goal.milestones.count, 4, "Should generate 4 milestones (25%, 50%, 75%, 100%)")
    }
    
    // MARK: - Relationship Tests
    
    func testGoalTransactionRelationship() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Car Purchase",
            description: "Save for new car",
            targetAmount: 25000.0,
            currentAmount: 5000.0,
            targetDate: Date(),
            category: "Transportation",
            priority: "Medium"
        )
        
        let transaction = Transaction.create(
            in: context,
            amount: 500.0,
            category: "Car Savings",
            note: "Monthly car fund contribution"
        )
        
        // When
        goal.addTransaction(transaction)
        
        // Then
        XCTAssertTrue(goal.transactions.contains(transaction), "Goal should contain the transaction")
        XCTAssertEqual(transaction.associatedGoal, goal, "Transaction should be linked to goal")
    }
    
    func testGoalProgressUpdateFromTransactions() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Education Fund",
            description: "Save for education",
            targetAmount: 20000.0,
            currentAmount: 0.0,
            targetDate: Date(),
            category: "Education",
            priority: "High"
        )
        
        let transaction1 = Transaction.create(
            in: context,
            amount: 1000.0,
            category: "Education Savings",
            note: "First contribution"
        )
        
        let transaction2 = Transaction.create(
            in: context,
            amount: 500.0,
            category: "Education Savings",
            note: "Second contribution"
        )
        
        // When
        goal.addTransaction(transaction1)
        goal.addTransaction(transaction2)
        goal.updateProgressFromTransactions()
        
        // Then
        XCTAssertEqual(goal.currentAmount, 1500.0, "Current amount should reflect transaction total")
        XCTAssertEqual(goal.calculateProgress(), 0.075, accuracy: 0.001, "Progress should be 7.5%")
    }
    
    // MARK: - Fetch Request Tests
    
    func testFetchGoalsByCategory() async {
        // Given
        let goal1 = FinancialGoal.create(
            in: context,
            title: "Emergency Fund",
            description: "Emergency savings",
            targetAmount: 15000.0,
            currentAmount: 5000.0,
            targetDate: Date(),
            category: "Emergency",
            priority: "High"
        )
        
        let goal2 = FinancialGoal.create(
            in: context,
            title: "Vacation Fund",
            description: "Vacation savings",
            targetAmount: 8000.0,
            currentAmount: 2000.0,
            targetDate: Date(),
            category: "Travel",
            priority: "Medium"
        )
        
        try? context.save()
        
        // When
        let emergencyGoals = try! FinancialGoal.fetchGoals(
            byCategory: "Emergency",
            in: context
        )
        
        // Then
        XCTAssertEqual(emergencyGoals.count, 1, "Should fetch one emergency goal")
        XCTAssertEqual(emergencyGoals.first?.title, "Emergency Fund", "Should fetch correct goal")
    }
    
    func testFetchActiveGoals() async {
        // Given
        let activeGoal = FinancialGoal.create(
            in: context,
            title: "Active Goal",
            description: "Currently working on this",
            targetAmount: 10000.0,
            currentAmount: 3000.0,
            targetDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!,
            category: "Savings",
            priority: "High"
        )
        
        let completedGoal = FinancialGoal.create(
            in: context,
            title: "Completed Goal",
            description: "Already achieved",
            targetAmount: 5000.0,
            currentAmount: 5000.0,
            targetDate: Date(),
            category: "Savings",
            priority: "Low"
        )
        completedGoal.isAchieved = true
        
        try? context.save()
        
        // When
        let activeGoals = try! FinancialGoal.fetchActiveGoals(in: context)
        
        // Then
        XCTAssertEqual(activeGoals.count, 1, "Should fetch only active goals")
        XCTAssertFalse(activeGoals.first!.isAchieved, "Fetched goal should not be achieved")
    }
    
    func testFetchGoalsByPriority() async {
        // Given
        let highPriorityGoal = FinancialGoal.create(
            in: context,
            title: "High Priority Goal",
            description: "Important goal",
            targetAmount: 15000.0,
            currentAmount: 0.0,
            targetDate: Date(),
            category: "Important",
            priority: "High"
        )
        
        let lowPriorityGoal = FinancialGoal.create(
            in: context,
            title: "Low Priority Goal",
            description: "Less important goal",
            targetAmount: 3000.0,
            currentAmount: 0.0,
            targetDate: Date(),
            category: "Optional",
            priority: "Low"
        )
        
        try? context.save()
        
        // When
        let highPriorityGoals = try! FinancialGoal.fetchGoals(
            byPriority: "High",
            in: context
        )
        
        // Then
        XCTAssertEqual(highPriorityGoals.count, 1, "Should fetch one high priority goal")
        XCTAssertEqual(highPriorityGoals.first?.priority, "High", "Fetched goal should be high priority")
    }
    
    // MARK: - Performance Tests
    
    func testGoalCalculationPerformance() {
        // Given
        var goals: [FinancialGoal] = []
        for i in 1...100 {
            let goal = FinancialGoal.create(
                in: context,
                title: "Goal \(i)",
                description: "Test goal \(i)",
                targetAmount: Double(i * 1000),
                currentAmount: Double(i * 100),
                targetDate: Date(),
                category: "Test",
                priority: "Medium"
            )
            goals.append(goal)
        }
        
        // When & Then
        measure {
            for goal in goals {
                _ = goal.calculateProgress()
            }
        }
    }
    
    func testLargeGoalDatasetFetch() {
        // Given
        for i in 1...1000 {
            _ = FinancialGoal.create(
                in: context,
                title: "Goal \(i)",
                description: "Performance test goal \(i)",
                targetAmount: Double(i * 1000),
                currentAmount: Double(i * 100),
                targetDate: Date(),
                category: "Performance",
                priority: "Medium"
            )
        }
        
        try? context.save()
        
        // When & Then
        measure {
            _ = try! FinancialGoal.fetchActiveGoals(in: context)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testGoalCreationWithInvalidData() {
        // Given & When & Then
        XCTAssertThrowsError(try FinancialGoal.create(
            in: context,
            title: "",
            description: "Invalid goal",
            targetAmount: -1000.0,
            currentAmount: 0.0,
            targetDate: Date(),
            category: "",
            priority: "Invalid"
        )) { error in
            XCTAssertTrue(error is GoalValidationError, "Should throw validation error")
        }
    }
    
    func testGoalFetchWithInvalidContext() {
        // Given
        let invalidContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // When & Then
        XCTAssertThrowsError(try FinancialGoal.fetchActiveGoals(in: invalidContext)) { error in
            XCTAssertTrue(error is CoreDataError, "Should throw Core Data error")
        }
    }
}