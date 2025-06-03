// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Project Core Data model class for expense tracking and project management
* Issues & Complexity Summary: Project entity with budget tracking, status management, and client relationships
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~220
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 3 New (CoreData, Foundation, Financial calculations)
  - State Management Complexity: Medium-High
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 75%
* Initial Code Complexity Estimate %: 78%
* Justification for Estimates: Complex business logic with financial tracking and status management
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

/// Project entity representing business projects for expense and document tracking
/// Manages budget tracking, status workflow, client relationships, and financial calculations
@objc(Project)
public class Project: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    /// Creates a new Project with required properties
    /// - Parameters:
    ///   - context: The managed object context
    ///   - name: Name of the project
    ///   - budget: Initial budget amount
    ///   - client: Associated client (optional)
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        budget: NSDecimalNumber? = nil,
        client: Client? = nil
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.name = name
        self.budget = budget
        self.client = client
        self.dateCreated = Date()
        self.dateModified = Date()
        self.status = ProjectStatus.planning.rawValue
        self.isActive = true
        
        // Set default dates
        self.startDate = Date()
        if let endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) {
            self.endDate = endDate
        }
    }
    
    // MARK: - Computed Properties
    
    /// Computed property for project status enum
    public var statusEnum: ProjectStatus {
        get {
            return ProjectStatus(rawValue: status ?? "") ?? .planning
        }
        set {
            status = newValue.rawValue
        }
    }
    
    /// Computed property for display name
    public var displayName: String {
        return name ?? "Unknown Project"
    }
    
    /// Computed property for project duration in days
    public var durationInDays: Int? {
        guard let startDate = startDate, let endDate = endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day
    }
    
    /// Computed property for days remaining until end date
    public var daysRemaining: Int? {
        guard let endDate = endDate else { return nil }
        let today = Date()
        let components = Calendar.current.dateComponents([.day], from: today, to: endDate)
        return components.day
    }
    
    /// Computed property to check if project is overdue
    public var isOverdue: Bool {
        guard let endDate = endDate else { return false }
        return Date() > endDate && !statusEnum.isCompleted
    }
    
    /// Computed property for completion percentage
    public var completionPercentage: Double {
        guard let startDate = startDate, let endDate = endDate else { return 0.0 }
        
        if statusEnum.isCompleted {
            return 100.0
        }
        
        let today = Date()
        let totalDuration = endDate.timeIntervalSince(startDate)
        let elapsed = today.timeIntervalSince(startDate)
        
        let percentage = (elapsed / totalDuration) * 100.0
        return max(0.0, min(100.0, percentage))
    }
    
    /// Computed property for total expenses (sum of all related documents)
    public var totalExpenses: NSDecimalNumber {
        guard let documents = documents?.allObjects as? [Document] else {
            return NSDecimalNumber.zero
        }
        
        var total = NSDecimalNumber.zero
        for document in documents {
            if let financialData = document.financialData,
               let amount = financialData.totalAmount {
                total = total.adding(amount)
            }
        }
        
        return total
    }
    
    /// Computed property for remaining budget
    public var remainingBudget: NSDecimalNumber? {
        guard let budget = budget else { return nil }
        return budget.subtracting(totalExpenses)
    }
    
    /// Computed property for budget utilization percentage
    public var budgetUtilization: Double {
        guard let budget = budget, budget.doubleValue > 0 else { return 0.0 }
        return (totalExpenses.doubleValue / budget.doubleValue) * 100.0
    }
    
    /// Computed property to check if project is over budget
    public var isOverBudget: Bool {
        guard let budget = budget else { return false }
        return totalExpenses.compare(budget) == .orderedDescending
    }
    
    /// Computed property for document count
    public var documentCount: Int {
        return documents?.count ?? 0
    }
    
    /// Computed property for formatted budget
    public var formattedBudget: String {
        guard let budget = budget else { return "No budget set" }
        return formatCurrency(budget)
    }
    
    /// Computed property for formatted total expenses
    public var formattedTotalExpenses: String {
        return formatCurrency(totalExpenses)
    }
    
    /// Computed property for formatted remaining budget
    public var formattedRemainingBudget: String {
        guard let remaining = remainingBudget else { return "N/A" }
        return formatCurrency(remaining)
    }
    
    // MARK: - Business Logic Methods
    
    /// Updates the project status and handles status transitions
    /// - Parameter newStatus: New project status
    public func updateStatus(_ newStatus: ProjectStatus) {
        let oldStatus = statusEnum
        statusEnum = newStatus
        dateModified = Date()
        
        // Handle status-specific logic
        switch newStatus {
        case .active:
            if oldStatus == .planning {
                // Project is starting - set actual start date if not set
                if startDate == nil || startDate! < Date() {
                    startDate = Date()
                }
            }
            isActive = true
            
        case .completed:
            isActive = false
            // Set completion date if not already set
            if endDate == nil || endDate! > Date() {
                endDate = Date()
            }
            
        case .cancelled:
            isActive = false
            
        case .onHold:
            // Keep isActive true for on-hold projects
            break
            
        case .planning:
            isActive = true
        }
    }
    
    /// Updates the project budget
    /// - Parameter newBudget: New budget amount
    public func updateBudget(_ newBudget: NSDecimalNumber?) {
        budget = newBudget
        dateModified = Date()
    }
    
    /// Extends the project end date
    /// - Parameter days: Number of days to extend
    public func extendDeadline(by days: Int) {
        guard let currentEndDate = endDate else { return }
        endDate = Calendar.current.date(byAdding: .day, value: days, to: currentEndDate)
        dateModified = Date()
    }
    
    /// Adds a note to the project
    /// - Parameter note: Note to add
    public func addNote(_ note: String) {
        let timestamp = DateFormatter().string(from: Date())
        let newNote = "[\(timestamp)] \(note)"
        
        if let existingNotes = notes, !existingNotes.isEmpty {
            notes = existingNotes + "\n" + newNote
        } else {
            notes = newNote
        }
        dateModified = Date()
    }
    
    /// Calculates project health score based on budget and timeline
    /// - Returns: Health score from 0.0 (poor) to 1.0 (excellent)
    public func calculateHealthScore() -> Double {
        var score = 1.0
        
        // Budget health (50% weight)
        if let budget = budget, budget.doubleValue > 0 {
            let budgetHealth = max(0.0, 1.0 - (budgetUtilization / 100.0))
            score *= (0.5 + (budgetHealth * 0.5))
        }
        
        // Timeline health (50% weight)
        if let daysRemaining = daysRemaining, let duration = durationInDays, duration > 0 {
            let timelineHealth = max(0.0, min(1.0, Double(daysRemaining) / Double(duration)))
            score *= (0.5 + (timelineHealth * 0.5))
        }
        
        // Penalize overdue projects
        if isOverdue {
            score *= 0.3
        }
        
        return max(0.0, min(1.0, score))
    }
    
    /// Formats a currency amount using default formatting
    /// - Parameter amount: Amount to format
    /// - Returns: Formatted currency string
    private func formatCurrency(_ amount: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: amount) ?? "$\(amount)"
    }
    
    /// Creates a summary dictionary of the project information
    /// - Returns: Dictionary containing key project information
    public func createSummary() -> [String: Any] {
        var summary: [String: Any] = [:]
        
        summary["id"] = id?.uuidString
        summary["name"] = name
        summary["status"] = statusEnum.displayName
        summary["statusColor"] = statusEnum.statusColor
        summary["isActive"] = isActive
        summary["isOverdue"] = isOverdue
        summary["isOverBudget"] = isOverBudget
        summary["completionPercentage"] = completionPercentage
        summary["budgetUtilization"] = budgetUtilization
        summary["healthScore"] = calculateHealthScore()
        summary["formattedBudget"] = formattedBudget
        summary["formattedTotalExpenses"] = formattedTotalExpenses
        summary["formattedRemainingBudget"] = formattedRemainingBudget
        summary["documentCount"] = documentCount
        summary["durationInDays"] = durationInDays
        summary["daysRemaining"] = daysRemaining
        summary["startDate"] = startDate
        summary["endDate"] = endDate
        summary["dateCreated"] = dateCreated
        
        if let client = client {
            summary["clientName"] = client.name
        }
        
        return summary
    }
    
    /// Validates project properties before saving
    /// - Throws: ValidationError if validation fails
    public func validateForSave() throws {
        // Validate required fields
        guard let name = name, !name.isEmpty else {
            throw ValidationError.missingRequiredField("name")
        }
        
        // Validate name length
        guard name.count <= 100 else {
            throw ValidationError.invalidValue("name", "Name must be 100 characters or less")
        }
        
        // Validate status is valid
        guard let status = status, ProjectStatus(rawValue: status) != nil else {
            throw ValidationError.invalidValue("status", status ?? "nil")
        }
        
        // Validate budget is positive if set
        if let budget = budget {
            guard budget.doubleValue >= 0 else {
                throw ValidationError.invalidValue("budget", "Budget must be non-negative")
            }
        }
        
        // Validate date relationships
        if let startDate = startDate, let endDate = endDate {
            guard endDate >= startDate else {
                throw ValidationError.invalidValue("endDate", "End date cannot be before start date")
            }
        }
        
        // Validate project description length if provided
        if let description = projectDescription {
            guard description.count <= 1000 else {
                throw ValidationError.invalidValue("projectDescription", "Description must be 1000 characters or less")
            }
        }
    }
}

// MARK: - Core Data Validation

extension Project {
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateForSave()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateForSave()
    }
    
    public override func willSave() {
        super.willSave()
        
        // Automatically update dateModified when any property changes
        if isUpdated && !isDeleted {
            dateModified = Date()
        }
    }
}

// MARK: - Supporting Types

/// Project status enumeration
public enum ProjectStatus: String, CaseIterable {
    case planning = "planning"
    case active = "active"
    case onHold = "on_hold"
    case completed = "completed"
    case cancelled = "cancelled"
    
    /// Display name for the project status
    public var displayName: String {
        switch self {
        case .planning: return "Planning"
        case .active: return "Active"
        case .onHold: return "On Hold"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    /// Color for status indicator
    public var statusColor: String {
        switch self {
        case .planning: return "#FFA500"     // Orange
        case .active: return "#34C759"       // Green
        case .onHold: return "#FF9500"       // Yellow
        case .completed: return "#007AFF"    // Blue
        case .cancelled: return "#FF3B30"    // Red
        }
    }
    
    /// Icon name for the project status
    public var iconName: String {
        switch self {
        case .planning: return "lightbulb"
        case .active: return "play.circle"
        case .onHold: return "pause.circle"
        case .completed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        }
    }
    
    /// Check if status represents a completed state
    public var isCompleted: Bool {
        return self == .completed || self == .cancelled
    }
    
    /// Check if status represents an active state
    public var isActiveState: Bool {
        return self == .active || self == .planning
    }
}