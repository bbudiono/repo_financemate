//
// FinancialGoalTests.swift
// FinanceMateTests
//
// P4-003 Financial Goal Setting Framework - TDD Implementation
// Created: 2025-07-11
// Target: FinanceMateTests
//

/*
 * Purpose: Comprehensive unit tests for FinancialGoal Core Data models and SMART validation
 * Issues & Complexity Summary: Testing SMART goal validation, progress calculations, and Core Data relationships
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~800
   - Core Algorithm Complexity: High (SMART validation, progress algorithms, behavioral finance)
   - Dependencies: Core Data, Date calculations, financial algorithms, Australian compliance
   - State Management Complexity: High (goal relationships, milestone tracking, progress updates)
   - Novelty/Uncertainty Factor: Medium (SMART goal validation, behavioral finance patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-11
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
    
    // MARK: - FinancialGoal Creation Tests
    
    func testFinancialGoalCreation() {
        // Given
        let title = "Emergency Fund"
        let description = "Save $10,000 for emergencies"
        let targetAmount = 10000.0
        let category = GoalCategory.emergencyFund
        let deadline = Calendar.current.date(byAdding: .month, value: 12, to: Date())!
        
        // When - This will fail until we implement FinancialGoal.create
        let goal = FinancialGoal.create(
            in: context,
            title: title,
            description: description,
            targetAmount: targetAmount,
            category: category,
            deadline: deadline
        )
        
        // Then
        XCTAssertEqual(goal.title, title, "Goal title should match input")
        XCTAssertEqual(goal.description, description, "Goal description should match input")
        XCTAssertEqual(goal.targetAmount, targetAmount, "Target amount should match input")
        XCTAssertEqual(goal.category, category.rawValue, "Category should match input")
        XCTAssertEqual(goal.deadline, deadline, "Deadline should match input")
        XCTAssertEqual(goal.currentAmount, 0.0, "Initial current amount should be zero")
        XCTAssertFalse(goal.isCompleted, "New goal should not be completed")
        XCTAssertNotNil(goal.id, "Goal should have a UUID")
        XCTAssertNotNil(goal.createdAt, "Goal should have creation date")
        XCTAssertNotNil(goal.lastUpdated, "Goal should have last updated date")
    }
    
    func testFinancialGoalProgressCalculation() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "House Deposit",
            description: "Save for house deposit",
            targetAmount: 100000.0,
            category: .savings,
            deadline: Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        )
        
        // When
        goal.currentAmount = 25000.0
        let progress = goal.calculateProgress()
        
        // Then
        XCTAssertEqual(progress, 0.25, accuracy: 0.001, "Progress should be 25% (25000/100000)")
    }
    
    func testSMARTValidationSpecific() {
        // Given
        let specificGoal = FinancialGoal.create(
            in: context,
            title: "Save $10,000 for emergency fund",
            description: "Build an emergency fund to cover 6 months of expenses",
            targetAmount: 10000.0,
            category: .emergencyFund,
            deadline: Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        )
        
        // When & Then - This will fail until we implement SMART validation
        XCTAssertTrue(specificGoal.isSpecific(), "Specific goal should pass SMART validation")
    }
    
    func testGoalMilestoneCreation() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Investment Goal",
            description: "Invest $50,000",
            targetAmount: 50000.0,
            category: .investment,
            deadline: Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        )
        
        let milestoneDate = Calendar.current.date(byAdding: .month, value: 6, to: Date())!
        let milestoneAmount = 25000.0
        
        // When - This will fail until we implement GoalMilestone.create
        let milestone = GoalMilestone.create(
            in: context,
            goal: goal,
            title: "Halfway Point",
            targetDate: milestoneDate,
            targetAmount: milestoneAmount
        )
        
        // Then
        XCTAssertEqual(milestone.title, "Halfway Point", "Milestone title should match input")
        XCTAssertEqual(milestone.targetDate, milestoneDate, "Target date should match input")
        XCTAssertEqual(milestone.targetAmount, milestoneAmount, "Target amount should match input")
        XCTAssertEqual(milestone.goalId, goal.id, "Milestone should be linked to goal")
        XCTAssertFalse(milestone.isAchieved, "New milestone should not be achieved")
        XCTAssertNotNil(milestone.id, "Milestone should have a UUID")
    }
    
    func testAustralianCurrencyFormatting() {
        // Given
        let goal = FinancialGoal.create(
            in: context,
            title: "Retirement Savings",
            description: "Build retirement fund",
            targetAmount: 500000.0,
            category: .investment,
            deadline: Calendar.current.date(byAdding: .year, value: 10, to: Date())!
        )
        
        goal.currentAmount = 125000.0
        
        // When - This will fail until we implement formatting methods
        let formattedTarget = goal.formattedTargetAmount()
        let formattedCurrent = goal.formattedCurrentAmount()
        
        // Then
        XCTAssertTrue(formattedTarget.contains("$"), "Target amount should be formatted as currency")
        XCTAssertTrue(formattedCurrent.contains("$"), "Current amount should be formatted as currency")
        XCTAssertTrue(formattedTarget.contains("A$") || formattedTarget.hasPrefix("$"), "Should use Australian currency format")
    }
}

// MARK: - Test Implementation Complete
// All mock implementations removed - using real Core Data models