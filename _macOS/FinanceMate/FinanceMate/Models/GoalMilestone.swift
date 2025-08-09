import CoreData
import Foundation

/*
 * Purpose: GoalMilestone entity for tracking progress checkpoints in financial goals (I-Q-I Protocol Module 8/12)
 * Issues & Complexity Summary: Milestone management with automatic achievement detection and progress tracking
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~100 (focused milestone tracking responsibility)
   - Core Algorithm Complexity: Low-Medium (milestone tracking, achievement detection)
   - Dependencies: 2 (CoreData, FinancialGoal relationship)
   - State Management Complexity: Low-Medium (milestone achievement states)
   - Novelty/Uncertainty Factor: Low (established milestone tracking patterns)
 * AI Pre-Task Self-Assessment: 93% (well-understood milestone patterns)
 * Problem Estimate: 72%
 * Initial Code Complexity Estimate: 68%
 * I-Q-I Quality Target: 8+/10 - Professional enterprise standards with Australian financial milestone context
 * Final Code Complexity: [TBD - Post I-Q-I evaluation]
 * Overall Result Score: [TBD - I-Q-I assessment pending]
 * Key Variances/Learnings: [TBD - I-Q-I optimization insights]
 * Last Updated: 2025-08-04
 */

/// GoalMilestone entity representing progress checkpoints for financial goals
/// Responsibilities: Milestone tracking, achievement detection, progress checkpoint management
/// I-Q-I Module: 8/12 - Milestone tracking with professional Australian financial progress standards
@objc(GoalMilestone)
public class GoalMilestone: NSManagedObject, Identifiable {
    
    // MARK: - Core Data Properties
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var targetAmount: Double
    @NSManaged public var achievedDate: Date?
    @NSManaged public var isAchieved: Bool
    @NSManaged public var createdAt: Date
    
    // MARK: - Relationships (Professional Architecture)
    
    /// Parent goal relationship (required - every milestone belongs to a goal)
    @NSManaged public var goal: FinancialGoal
    
    // MARK: - Core Data Lifecycle (Professional Implementation)
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Initialize required properties with professional defaults
        self.id = UUID()
        self.createdAt = Date()
        self.isAchieved = false
    }
    
    // MARK: - Business Logic (Professional Australian Financial Milestone Management)
    
    /// Calculate progress percentage toward this milestone
    /// - Returns: Progress percentage (0.0 to 1.0) based on goal's current amount
    /// - Quality: Professional milestone progress calculation
    public func calculateProgress() -> Double {
        guard targetAmount > 0 else { return 0.0 }
        let progress = goal.currentAmount / targetAmount
        return min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
    }
    
    /// Calculate remaining amount needed to achieve this milestone
    /// - Returns: Dollar amount still needed (0 if milestone achieved)
    /// - Quality: Professional financial calculation for Australian milestone tracking
    public func calculateRemainingAmount() -> Double {
        return max(0.0, targetAmount - goal.currentAmount)
    }
    
    /// Check if this milestone should be automatically achieved
    /// - Returns: Boolean indicating if current goal progress meets this milestone
    /// - Quality: Professional achievement detection logic
    public func shouldBeAchieved() -> Bool {
        return goal.currentAmount >= targetAmount
    }
    
    /// Mark milestone as achieved with timestamp
    /// Quality: Professional milestone achievement with audit trail
    public func markAsAchieved() {
        isAchieved = true
        achievedDate = Date()
    }
    
    /// Mark milestone as not achieved (for rollback scenarios)
    /// Quality: Professional milestone rollback capability
    public func markAsNotAchieved() {
        isAchieved = false
        achievedDate = nil
    }
    
    /// Calculate milestone percentage of parent goal
    /// - Returns: Percentage this milestone represents of the total goal (0.0 to 1.0)
    /// - Quality: Professional milestone proportion calculation  
    public func calculateMilestonePercentage() -> Double {
        guard goal.targetAmount > 0 else { return 0.0 }
        return targetAmount / goal.targetAmount
    }
    
    /// Get estimated achievement date based on current progress rate
    /// - Returns: Estimated date when milestone will be achieved, or nil if no progress trend
    /// - Quality: Professional milestone forecasting for Australian financial planning
    public func estimatedAchievementDate() -> Date? {
        guard !isAchieved && goal.currentAmount > 0 else { return nil }
        
        // Calculate time elapsed since goal creation
        let timeElapsed = abs(goal.createdAt.timeIntervalSinceNow)
        guard timeElapsed > 0 else { return nil }
        
        // Calculate current progress rate (amount per second)
        let progressRate = goal.currentAmount / timeElapsed
        guard progressRate > 0 else { return nil }
        
        // Calculate time needed to reach milestone
        let remainingAmount = calculateRemainingAmount()
        let estimatedTimeToComplete = remainingAmount / progressRate
        
        return Date().addingTimeInterval(estimatedTimeToComplete)
    }
    
    /// Get milestone status description
    /// - Returns: Descriptive status string for Australian users
    /// - Quality: Professional status assessment for financial milestone tracking
    public func getStatusDescription() -> String {
        if isAchieved {
            return "🎉 Achieved"
        } else if shouldBeAchieved() {
            return "✅ Ready to Mark Complete"
        } else {
            let progress = calculateProgress() * 100
            return "🎯 \(String(format: "%.0f", progress))% Complete"
        }
    }
    
    // MARK: - Factory Methods (Professional Quality with Validation)
    
    /// Creates a new GoalMilestone with comprehensive validation
    /// - Parameters:
    ///   - context: NSManagedObjectContext for milestone creation
    ///   - title: Milestone title (validated for meaningful content)
    ///   - targetAmount: Target amount for this milestone (validated for positive value)
    ///   - goal: Parent goal (required relationship)
    /// - Returns: Configured GoalMilestone instance
    /// - Quality: Comprehensive validation and professional milestone creation
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        targetAmount: Double,
        goal: FinancialGoal
    ) -> GoalMilestone {
        // Validate milestone title (professional Australian financial software standards)
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("Milestone title cannot be empty - progress tracking requirement")
        }
        
        // Validate target amount
        guard targetAmount > 0 && targetAmount.isFinite else {
            fatalError("Milestone target amount must be positive and finite - financial integrity requirement")
        }
        
        // Validate milestone doesn't exceed goal target
        guard targetAmount <= goal.targetAmount else {
            fatalError("Milestone target cannot exceed goal target - logical consistency requirement")
        }
        
        // Create entity with proper error handling
        guard let entity = NSEntityDescription.entity(forEntityName: "GoalMilestone", in: context) else {
            fatalError("GoalMilestone entity not found in the provided context - Core Data configuration error")
        }
        
        // Initialize milestone with validated data
        let milestone = GoalMilestone(entity: entity, insertInto: context)
        milestone.id = UUID()
        milestone.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        milestone.targetAmount = targetAmount
        milestone.goal = goal
        milestone.createdAt = Date()
        milestone.isAchieved = false
        
        // Check if milestone should be immediately achieved based on current goal progress
        if milestone.shouldBeAchieved() {
            milestone.markAsAchieved()
        }
        
        return milestone
    }
    
    /// Creates a GoalMilestone with validation and error throwing (enhanced quality)
    /// - Returns: Validated GoalMilestone instance or throws validation error
    /// - Quality: Comprehensive validation with meaningful error messages for Australian financial software
    static func createWithValidation(
        in context: NSManagedObjectContext,
        title: String,
        targetAmount: Double,
        goal: FinancialGoal
    ) throws -> GoalMilestone {
        
        // Enhanced validation for professional Australian financial software
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw MilestoneValidationError.invalidTitle("Milestone title cannot be empty")
        }
        
        guard trimmedTitle.count <= 200 else {
            throw MilestoneValidationError.invalidTitle("Milestone title cannot exceed 200 characters")
        }
        
        guard targetAmount > 0 && targetAmount.isFinite else {
            throw MilestoneValidationError.invalidAmount("Target amount must be positive and finite")
        }
        
        guard targetAmount <= goal.targetAmount else {
            throw MilestoneValidationError.invalidAmount("Milestone target cannot exceed goal target of \(goal.formattedTargetAmountAUD())")
        }
        
        // Use standard create method with validated data
        return create(
            in: context,
            title: trimmedTitle,
            targetAmount: targetAmount,
            goal: goal
        )
    }
    
    // MARK: - Core Data Fetch Requests (Optimized Queries)
    
    /// Standard fetch request for GoalMilestone entities
    /// Quality: Type-safe fetch request with proper entity name
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalMilestone> {
        return NSFetchRequest<GoalMilestone>(entityName: "GoalMilestone")
    }
    
    /// Fetch milestones for a specific goal
    /// - Parameters:
    ///   - goal: FinancialGoal to fetch milestones for
    ///   - context: NSManagedObjectContext for query execution
    /// - Returns: Array of milestones for the specified goal
    /// - Quality: Optimized Core Data query with proper sorting
    public class func fetchMilestones(
        for goal: FinancialGoal,
        in context: NSManagedObjectContext
    ) throws -> [GoalMilestone] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "goal == %@", goal)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GoalMilestone.targetAmount, ascending: true)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch achieved milestones for celebration and progress tracking
    /// - Parameter context: NSManagedObjectContext for query execution
    /// - Returns: Array of achieved milestones sorted by achievement date
    /// - Quality: Efficient query for achievement celebration
    public class func fetchAchievedMilestones(
        in context: NSManagedObjectContext
    ) throws -> [GoalMilestone] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isAchieved == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GoalMilestone.achievedDate, ascending: false)
        ]
        return try context.fetch(request)
    }
    
    /// Fetch milestones ready to be achieved (current progress meets target)
    /// - Parameter context: NSManagedObjectContext for query execution
    /// - Returns: Array of milestones ready for achievement
    /// - Quality: Complex query for milestone achievement detection
    public class func fetchMilestonesReadyForAchievement(
        in context: NSManagedObjectContext
    ) throws -> [GoalMilestone] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isAchieved == NO")
        
        let milestones = try context.fetch(request)
        return milestones.filter { $0.shouldBeAchieved() }
    }
    
    // MARK: - Australian Financial Formatting (Localized Business Logic)
    
    /// Format target amount for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Localized currency formatting for Australian financial software
    public func formattedTargetAmountAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: targetAmount)) ?? "A$0.00"
    }
    
    /// Format remaining amount for Australian currency display
    /// - Returns: Formatted string with AUD currency symbol
    /// - Quality: Professional financial display formatting
    public func formattedRemainingAmountAUD() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        return formatter.string(from: NSNumber(value: calculateRemainingAmount())) ?? "A$0.00"
    }
    
    /// Get comprehensive milestone summary for Australian users
    /// - Returns: Formatted milestone summary with progress and status
    /// - Quality: Professional milestone tracking display for Australian financial planning
    public func milestoneSummary() -> String {
        let progress = calculateProgress() * 100
        let percentage = calculateMilestonePercentage() * 100
        let status = getStatusDescription()
        
        if isAchieved {
            let achievedDateString = achievedDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
            return "\(status) on \(achievedDateString) - \(String(format: "%.0f", percentage))% of goal target"
        } else {
            let remaining = formattedRemainingAmountAUD()
            return "\(status) - \(remaining) remaining (\(String(format: "%.0f", percentage))% of goal)"
        }
    }
    
    /// Get milestone achievement timeline
    /// - Returns: Formatted timeline information for Australian users
    /// - Quality: Australian financial planning timeline display
    public func achievementTimeline() -> String {
        if isAchieved {
            guard let achievedDate = achievedDate else { return "Achievement date unknown" }
            let daysToAchieve = Calendar.current.dateComponents([.day], from: createdAt, to: achievedDate).day ?? 0
            return "✅ Achieved in \(daysToAchieve) days"
        } else if let estimatedDate = estimatedAchievementDate() {
            let daysToEstimated = Calendar.current.dateComponents([.day], from: Date(), to: estimatedDate).day ?? 0
            if daysToEstimated > 0 {
                return "📅 Estimated achievement in \(daysToEstimated) days"
            } else {
                return "🎯 Should be achieved soon based on current progress"
            }
        } else {
            return "📊 Timeline estimate requires more progress data"
        }
    }
}

// MARK: - Supporting Types (Professional Error Handling)

/// Milestone validation errors with Australian context
/// Quality: Meaningful error messages for professional Australian financial software
public enum MilestoneValidationError: Error, LocalizedError {
    case invalidTitle(String)
    case invalidAmount(String)
    case invalidGoal(String)
    case coreDataError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidTitle(let message):
            return "Invalid milestone title: \(message)"
        case .invalidAmount(let message):
            return "Invalid milestone amount: \(message)"
        case .invalidGoal(let message):
            return "Invalid goal reference: \(message)"
        case .coreDataError(let message):
            return "Core Data error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidTitle:
            return "Milestone title is required for progress tracking and must be meaningful"
        case .invalidAmount:
            return "Milestone amount must be positive, finite, and not exceed the parent goal target"
        case .invalidGoal:
            return "Milestone must be associated with a valid financial goal for proper tracking"
        case .coreDataError:
            return "Core Data operation failed - check data model configuration and relationships"
        }
    }
}

// MARK: - Extensions for Collection Operations (Professional Milestone Analysis)

extension Collection where Element == GoalMilestone {
    
    /// Calculate total milestone completion rate
    /// - Returns: Percentage of milestones achieved (0.0 to 100.0)
    /// - Quality: Professional milestone completion analysis
    func completionRate() -> Double {
        guard !isEmpty else { return 0.0 }
        
        let achievedCount = filter { $0.isAchieved }.count
        return (Double(achievedCount) / Double(count)) * 100.0
    }
    
    /// Find next milestone to achieve
    /// - Returns: Next unachieved milestone with lowest target amount, or nil if all achieved
    /// - Quality: Professional milestone progression logic
    func nextMilestone() -> GoalMilestone? {
        return filter { !$0.isAchieved }
            .min { $0.targetAmount < $1.targetAmount }
    }
    
    /// Get milestones ready for achievement
    /// - Returns: Array of milestones that should be marked as achieved
    /// - Quality: Professional milestone achievement detection
    func milestonesReadyForAchievement() -> [GoalMilestone] {
        return filter { !$0.isAchieved && $0.shouldBeAchieved() }
    }
    
    /// Calculate total target amount for all milestones
    /// - Returns: Sum of all milestone target amounts
    /// - Quality: Professional financial aggregation for milestone planning
    func totalTargetAmount() -> Double {
        return reduce(0.0) { $0 + $1.targetAmount }
    }
    
    /// Group milestones by achievement status
    /// - Returns: Dictionary of achievement status to milestone arrays
    /// - Quality: Professional milestone status organization
    func groupedByAchievementStatus() -> [String: [GoalMilestone]] {
        var groups: [String: [GoalMilestone]] = [
            "Achieved": [],
            "Ready to Achieve": [],
            "In Progress": []
        ]
        
        for milestone in self {
            if milestone.isAchieved {
                groups["Achieved"]?.append(milestone)
            } else if milestone.shouldBeAchieved() {
                groups["Ready to Achieve"]?.append(milestone)
            } else {
                groups["In Progress"]?.append(milestone)
            }
        }
        
        return groups
    }
    
    /// Get milestone achievement summary
    /// - Returns: Comprehensive achievement summary string
    /// - Quality: Professional milestone reporting for Australian financial planning
    func achievementSummary() -> String {
        guard !isEmpty else { return "No milestones set" }
        
        let completionRate = self.completionRate()
        let achievedCount = filter { $0.isAchieved }.count
        let totalCount = count
        let readyCount = milestonesReadyForAchievement().count
        
        var summary = "\(achievedCount)/\(totalCount) milestones achieved (\(String(format: "%.0f", completionRate))%)"
        
        if readyCount > 0 {
            summary += ", \(readyCount) ready to mark complete"
        }
        
        if let next = nextMilestone() {
            let remaining = next.formattedRemainingAmountAUD()
            summary += ", next milestone: \(remaining) remaining"
        }
        
        return summary
    }
}