// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Client Core Data properties extension for attribute and relationship definitions
* Issues & Complexity Summary: Core Data managed object properties and relationships for Client entity
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Standard Core Data properties definition for client entity
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    // MARK: - Attributes
    
    /// Unique identifier for the client
    @NSManaged public var id: UUID?
    
    /// Name of the client/company
    @NSManaged public var name: String?
    
    /// Primary email address
    @NSManaged public var email: String?
    
    /// Phone number
    @NSManaged public var phone: String?
    
    /// Street address
    @NSManaged public var address: String?
    
    /// City
    @NSManaged public var city: String?
    
    /// State or province
    @NSManaged public var state: String?
    
    /// ZIP or postal code
    @NSManaged public var zipCode: String?
    
    /// Country
    @NSManaged public var country: String?
    
    /// Type of client (customer, vendor, supplier, etc.)
    @NSManaged public var clientType: String?
    
    /// Whether the client is currently active
    @NSManaged public var isActive: Bool
    
    /// Date when the client was created
    @NSManaged public var dateCreated: Date?
    
    /// Date when the client was last modified
    @NSManaged public var dateModified: Date?
    
    /// Additional notes about the client
    @NSManaged public var notes: String?
    
    /// Tax identification number
    @NSManaged public var taxId: String?
    
    /// Website URL
    @NSManaged public var website: String?
    
    /// Preferred payment method
    @NSManaged public var preferredPaymentMethod: String?
    
    /// Credit limit for the client
    @NSManaged public var creditLimit: NSDecimalNumber?
    
    /// Current balance owed by/to the client
    @NSManaged public var currentBalance: NSDecimalNumber?
    
    /// JSON string containing additional metadata
    @NSManaged public var metadata: String?

    // MARK: - Relationships
    
    /// One-to-many relationship with documents associated with this client
    @NSManaged public var documents: NSSet?
    
    /// One-to-many relationship with projects associated with this client
    @NSManaged public var projects: NSSet?
}

// MARK: - Generated accessors for to-many relationships

extension Client {

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)
    
    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)
}

extension Client : Identifiable {
    // Identifiable conformance using the id property
}

// MARK: - Fetch Request Helpers

extension Client {
    
    /// Fetch request for clients by type
    /// - Parameter clientType: The type of clients to fetch
    /// - Returns: Configured fetch request
    public static func fetchRequest(for clientType: ClientType) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "clientType == %@", clientType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch request for active clients only
    /// - Returns: Configured fetch request for active clients
    public static func fetchActiveClients() -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch request for inactive clients
    /// - Returns: Configured fetch request for inactive clients
    public static func fetchInactiveClients() -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == NO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.dateModified, ascending: false)]
        return request
    }
    
    /// Fetch request for clients by email domain
    /// - Parameter domain: Email domain to filter by (e.g., "apple.com")
    /// - Returns: Configured fetch request
    public static func fetchRequest(emailDomain domain: String) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "email ENDSWITH[cd] %@", "@\(domain)")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch request for clients by city
    /// - Parameter city: City name to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(inCity city: String) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "city ==[cd] %@", city)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch request for clients by state
    /// - Parameter state: State name to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(inState state: String) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "state ==[cd] %@", state)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch request for clients with outstanding balance
    /// - Returns: Configured fetch request for clients with balance > 0
    public static func fetchClientsWithBalance() -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "currentBalance > 0")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.currentBalance, ascending: false)]
        return request
    }
    
    /// Fetch request for clients by credit limit range
    /// - Parameters:
    ///   - minLimit: Minimum credit limit
    ///   - maxLimit: Maximum credit limit
    /// - Returns: Configured fetch request
    public static func fetchRequest(creditLimitBetween minLimit: NSDecimalNumber, and maxLimit: NSDecimalNumber) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "creditLimit >= %@ AND creditLimit <= %@", minLimit, maxLimit)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.creditLimit, ascending: false)]
        return request
    }
    
    /// Fetch request for recently created clients
    /// - Parameter days: Number of days back to search (default 30)
    /// - Returns: Configured fetch request
    public static func fetchRecentClients(within days: Int = 30) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        request.predicate = NSPredicate(format: "dateCreated >= %@", cutoffDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.dateCreated, ascending: false)]
        return request
    }
    
    /// Search clients by name, email, or company information
    /// - Parameter searchText: Text to search for
    /// - Returns: Configured fetch request for search results
    public static func searchClients(containing searchText: String) -> NSFetchRequest<Client> {
        let request = fetchRequest()
        let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", 
                                        searchText, searchText, searchText)
        request.predicate = searchPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
    
    /// Fetch clients with incomplete contact information
    /// - Returns: Configured fetch request for clients missing required fields
    public static func fetchIncompleteClients() -> NSFetchRequest<Client> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "phone == nil OR address == nil OR city == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
        return request
    }
}