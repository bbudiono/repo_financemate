/**
 * Purpose: ViewModel for financial goal management with SMART validation and progress tracking
 * Issues & Complexity Summary: Manages goal CRUD operations, progress calculation, and UI state
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~300
 *   - Core Algorithm Complexity: Medium (SMART validation, progress tracking)
 *   - Dependencies: Core Data, SwiftUI, Combine
 *   - State Management Complexity: Medium (multiple published properties)
 *   - Novelty/Uncertainty Factor: Low (standard MVVM patterns)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 75%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-10
 */

import SwiftUI
import CoreData
import Foundation
import Combine

@MainActor
class FinancialGoalViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var goals: [FinancialGoal] = []
    @Published var activeGoals: [FinancialGoal] = []
    @Published var completedGoals: [FinancialGoal] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingAddGoal: Bool = false
    @Published var selectedGoal: FinancialGoal?
    
    // MARK: - Goal Form Data
    
    @Published var goalForm = GoalFormData()
    @Published var smartValidation: SMARTValidationResult?
    @Published var isFormValid: Bool = false
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        setupFormValidation()
        fetchGoals()
    }
    
    // MARK: - Public Methods
    
    /// Fetch all goals and categorize them
    func fetchGoals() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchRequest: NSFetchRequest<FinancialGoal> = FinancialGoal.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \FinancialGoal.priority, ascending: false),
                    NSSortDescriptor(keyPath: \FinancialGoal.targetDate, ascending: true)
                ]
                
                let fetchedGoals = try context.fetch(fetchRequest)
                
                await MainActor.run {
                    self.goals = fetchedGoals
                    self.categorizeGoals()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch goals: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Create a new financial goal
    func createGoal() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        do {
            let goal = try FinancialGoal.createWithValidation(
                in: context,
                title: goalForm.title,
                description: goalForm.description,
                targetAmount: goalForm.targetAmount,
                currentAmount: goalForm.currentAmount,
                targetDate: goalForm.targetDate,
                category: goalForm.category,
                priority: goalForm.priority
            )
            
            // Generate automatic milestones for long-term goals
            if goalForm.targetDate.timeIntervalSinceNow > 365 * 24 * 60 * 60 { // More than 1 year
                goal.generateAutomaticMilestones()
            }
            
            try context.save()
            
            resetForm()
            fetchGoals()
            showingAddGoal = false
            
        } catch {
            errorMessage = "Failed to create goal: \(error.localizedDescription)"
        }
    }
    
    /// Update existing goal
    func updateGoal(_ goal: FinancialGoal) {
        do {
            goal.lastModified = Date()
            try context.save()
            fetchGoals()
        } catch {
            errorMessage = "Failed to update goal: \(error.localizedDescription)"
        }
    }
    
    /// Delete a goal
    func deleteGoal(_ goal: FinancialGoal) {
        context.delete(goal)
        
        do {
            try context.save()
            fetchGoals()
        } catch {
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
        }
    }
    
    /// Add amount to goal progress
    func addProgress(to goal: FinancialGoal, amount: Double) {
        goal.updateProgress(newAmount: goal.currentAmount + amount)
        updateGoal(goal)
    }
    
    /// Update goal progress from associated transactions
    func refreshGoalProgress(_ goal: FinancialGoal) {
        goal.updateProgressFromTransactions()
        updateGoal(goal)
    }
    
    /// Mark goal as achieved
    func markGoalAsAchieved(_ goal: FinancialGoal) {
        goal.isAchieved = true
        goal.currentAmount = goal.targetAmount
        updateGoal(goal)
    }
    
    /// Get goals by category
    func getGoals(byCategory category: String) -> [FinancialGoal] {
        return goals.filter { $0.category == category }
    }
    
    /// Get goals by priority
    func getGoals(byPriority priority: String) -> [FinancialGoal] {
        return goals.filter { $0.priority == priority }
    }
    
    /// Calculate total progress across all active goals
    func calculateOverallProgress() -> Double {
        guard !activeGoals.isEmpty else { return 0.0 }
        
        let totalProgress = activeGoals.reduce(0.0) { sum, goal in
            return sum + goal.calculateProgress()
        }
        
        return totalProgress / Double(activeGoals.count)
    }
    
    /// Get upcoming milestones across all goals
    func getUpcomingMilestones() -> [GoalMilestone] {
        let allMilestones = goals.flatMap { $0.milestones }
        return allMilestones
            .filter { !$0.isAchieved }
            .sorted { $0.targetAmount < $1.targetAmount }
    }
    
    /// Reset the goal form
    func resetForm() {
        goalForm = GoalFormData()
        smartValidation = nil
        isFormValid = false
        errorMessage = nil
    }
    
    /// Validate SMART criteria for current form
    func validateSMARTCriteria() {
        smartValidation = FinancialGoal.validateSMART(goalForm)
        isFormValid = smartValidation?.isValid ?? false
    }
    
    // MARK: - Private Methods
    
    private func categorizeGoals() {
        activeGoals = goals.filter { !$0.isAchieved }
        completedGoals = goals.filter { $0.isAchieved }
    }
    
    private func setupFormValidation() {
        // Combine form fields to automatically validate
        Publishers.CombineLatest4(
            $goalForm.map(\.title),
            $goalForm.map(\.targetAmount),
            $goalForm.map(\.targetDate),
            $goalForm.map(\.category)
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] title, amount, date, category in
            self?.validateSMARTCriteria()
        }
        .store(in: &cancellables)
    }
}

// MARK: - Goal Categories Extension

extension FinancialGoalViewModel {
    
    static let goalCategories = [
        "Emergency",
        "Savings",
        "Investment",
        "Travel",
        "Property",
        "Education",
        "Retirement",
        "Transportation",
        "Health",
        "Business"
    ]
    
    static let priorityLevels = [
        "High",
        "Medium", 
        "Low"
    ]
    
    /// Get category-specific suggestions
    func getSuggestionsForCategory(_ category: String) -> [String] {
        switch category {
        case "Emergency":
            return ["Build 3-month emergency fund", "Build 6-month emergency fund", "Emergency car repair fund"]
        case "Travel":
            return ["European vacation", "Japan trip", "Weekend getaway fund"]
        case "Property":
            return ["House deposit", "Investment property", "Home renovations"]
        case "Education":
            return ["University tuition", "Professional certification", "Language course"]
        case "Retirement":
            return ["Superannuation contribution", "Self-managed super fund", "Retirement travel fund"]
        default:
            return []
        }
    }
}

// MARK: - Analytics Extension

extension FinancialGoalViewModel {
    
    /// Get goal completion statistics
    func getCompletionStats() -> (completed: Int, total: Int, percentage: Double) {
        let completed = completedGoals.count
        let total = goals.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0.0
        
        return (completed: completed, total: total, percentage: percentage)
    }
    
    /// Get average time to completion for achieved goals
    func getAverageCompletionTime() -> TimeInterval? {
        guard !completedGoals.isEmpty else { return nil }
        
        let totalTime = completedGoals.reduce(0.0) { sum, goal in
            return sum + goal.targetDate.timeIntervalSince(goal.createdAt)
        }
        
        return totalTime / Double(completedGoals.count)
    }
    
    /// Get goals that are behind schedule
    func getGoalsBehindSchedule() -> [FinancialGoal] {
        let now = Date()
        
        return activeGoals.filter { goal in
            let progress = goal.calculateProgress()
            let timeProgress = now.timeIntervalSince(goal.createdAt) / goal.targetDate.timeIntervalSince(goal.createdAt)
            
            // Goal is behind if time progress is significantly ahead of amount progress
            return timeProgress > progress + 0.1 && goal.targetDate > now
        }
    }
    
    /// Get goals that are overdue
    func getOverdueGoals() -> [FinancialGoal] {
        let now = Date()
        return activeGoals.filter { $0.targetDate < now }
    }
}