// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Project Core Data properties extension for attribute and relationship definitions
* Issues & Complexity Summary: Core Data managed object properties and relationships for Project entity
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Standard Core Data properties definition for project entity
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    // MARK: - Attributes
    
    /// Unique identifier for the project
    @NSManaged public var id: UUID?
    
    /// Name of the project
    @NSManaged public var name: String?
    
    /// Detailed description of the project
    @NSManaged public var projectDescription: String?
    
    /// Project budget amount
    @NSManaged public var budget: NSDecimalNumber?
    
    /// Project start date
    @NSManaged public var startDate: Date?
    
    /// Project end date (deadline)
    @NSManaged public var endDate: Date?
    
    /// Current status of the project
    @NSManaged public var status: String?
    
    /// Whether the project is currently active
    @NSManaged public var isActive: Bool
    
    /// Date when the project was created
    @NSManaged public var dateCreated: Date?
    
    /// Date when the project was last modified
    @NSManaged public var dateModified: Date?
    
    /// Additional notes about the project
    @NSManaged public var notes: String?
    
    /// Project priority level (1-5, where 5 is highest)
    @NSManaged public var priority: Int16
    
    /// Percentage completion (0-100)
    @NSManaged public var percentComplete: Double
    
    /// Project manager or lead contact
    @NSManaged public var projectManager: String?
    
    /// JSON string containing additional metadata
    @NSManaged public var metadata: String?

    // MARK: - Relationships
    
    /// Many-to-one relationship with the client associated with this project
    @NSManaged public var client: Client?
    
    /// One-to-many relationship with documents associated with this project
    @NSManaged public var documents: NSSet?
}

// MARK: - Generated accessors for to-many relationships

extension Project {

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)
}

extension Project : Identifiable {
    // Identifiable conformance using the id property
}

// MARK: - Fetch Request Helpers

extension Project {
    
    /// Fetch request for projects by status
    /// - Parameter status: Project status to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(with status: ProjectStatus) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", status.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.priority, ascending: false),
                                 NSSortDescriptor(keyPath: \Project.name, ascending: true)]
        return request
    }
    
    /// Fetch request for active projects only
    /// - Returns: Configured fetch request for active projects
    public static func fetchActiveProjects() -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.priority, ascending: false),
                                 NSSortDescriptor(keyPath: \Project.endDate, ascending: true)]
        return request
    }
    
    /// Fetch request for completed projects
    /// - Returns: Configured fetch request for completed projects
    public static func fetchCompletedProjects() -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "status IN %@", [ProjectStatus.completed.rawValue, ProjectStatus.cancelled.rawValue])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.endDate, ascending: false)]
        return request
    }
    
    /// Fetch request for overdue projects
    /// - Returns: Configured fetch request for overdue projects
    public static func fetchOverdueProjects() -> NSFetchRequest<Project> {
        let request = fetchRequest()
        let today = Date()
        request.predicate = NSPredicate(format: "endDate < %@ AND status NOT IN %@", 
                                      today as NSDate, 
                                      [ProjectStatus.completed.rawValue, ProjectStatus.cancelled.rawValue])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.endDate, ascending: true)]
        return request
    }
    
    /// Fetch request for projects by client
    /// - Parameter client: Client to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(for client: Client) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "client == %@", client)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.priority, ascending: false),
                                 NSSortDescriptor(keyPath: \Project.startDate, ascending: false)]
        return request
    }
    
    /// Fetch request for projects within a date range
    /// - Parameters:
    ///   - startDate: Start date of the range
    ///   - endDate: End date of the range
    /// - Returns: Configured fetch request
    public static func fetchRequest(from startDate: Date, to endDate: Date) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "(startDate >= %@ AND startDate <= %@) OR (endDate >= %@ AND endDate <= %@)", 
                                      startDate as NSDate, endDate as NSDate,
                                      startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.startDate, ascending: true)]
        return request
    }
    
    /// Fetch request for projects by priority level
    /// - Parameter priority: Priority level (1-5)
    /// - Returns: Configured fetch request
    public static func fetchRequest(withPriority priority: Int16) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "priority == %d", priority)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.endDate, ascending: true)]
        return request
    }
    
    /// Fetch request for high priority projects (priority 4 or 5)
    /// - Returns: Configured fetch request for high priority projects
    public static func fetchHighPriorityProjects() -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "priority >= 4")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.priority, ascending: false),
                                 NSSortDescriptor(keyPath: \Project.endDate, ascending: true)]
        return request
    }
    
    /// Fetch request for projects by budget range
    /// - Parameters:
    ///   - minBudget: Minimum budget amount
    ///   - maxBudget: Maximum budget amount
    /// - Returns: Configured fetch request
    public static func fetchRequest(budgetBetween minBudget: NSDecimalNumber, and maxBudget: NSDecimalNumber) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "budget >= %@ AND budget <= %@", minBudget, maxBudget)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.budget, ascending: false)]
        return request
    }
    
    /// Fetch request for projects due within specified days
    /// - Parameter days: Number of days from today
    /// - Returns: Configured fetch request
    public static func fetchProjectsDueWithin(_ days: Int) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        let today = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: today)!
        request.predicate = NSPredicate(format: "endDate >= %@ AND endDate <= %@ AND status NOT IN %@", 
                                      today as NSDate, 
                                      futureDate as NSDate,
                                      [ProjectStatus.completed.rawValue, ProjectStatus.cancelled.rawValue])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.endDate, ascending: true)]
        return request
    }
    
    /// Fetch request for recently created projects
    /// - Parameter days: Number of days back to search (default 30)
    /// - Returns: Configured fetch request
    public static func fetchRecentProjects(within days: Int = 30) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        request.predicate = NSPredicate(format: "dateCreated >= %@", cutoffDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.dateCreated, ascending: false)]
        return request
    }
    
    /// Search projects by name, description, or notes
    /// - Parameter searchText: Text to search for
    /// - Returns: Configured fetch request for search results
    public static func searchProjects(containing searchText: String) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@ OR projectDescription CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", 
                                        searchText, searchText, searchText)
        request.predicate = searchPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.name, ascending: true)]
        return request
    }
    
    /// Fetch projects by completion percentage range
    /// - Parameters:
    ///   - minPercent: Minimum completion percentage
    ///   - maxPercent: Maximum completion percentage
    /// - Returns: Configured fetch request
    public static func fetchRequest(completionBetween minPercent: Double, and maxPercent: Double) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "percentComplete >= %f AND percentComplete <= %f", minPercent, maxPercent)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.percentComplete, ascending: false)]
        return request
    }
}