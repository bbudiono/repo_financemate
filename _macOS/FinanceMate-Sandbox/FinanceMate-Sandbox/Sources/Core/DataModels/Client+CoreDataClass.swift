// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Client Core Data model class for customer/vendor management
* Issues & Complexity Summary: Client entity with contact information, validation, and document relationships
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (CoreData, Foundation, Contacts framework patterns)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 73%
* Justification for Estimates: Standard contact management with validation patterns
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

/// Client entity representing customers, vendors, and other business contacts
/// Manages contact information, relationships to documents, and business logic
@objc(Client)
public class Client: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    /// Creates a new Client with required properties
    /// - Parameters:
    ///   - context: The managed object context
    ///   - name: Name of the client/company
    ///   - email: Primary email address
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        email: String
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.name = name
        self.email = email
        self.dateCreated = Date()
        self.dateModified = Date()
        self.isActive = true
        self.clientType = ClientType.customer.rawValue
    }
    
    // MARK: - Computed Properties
    
    /// Computed property for client type enum
    public var clientTypeEnum: ClientType {
        get {
            return ClientType(rawValue: clientType ?? "") ?? .customer
        }
        set {
            clientType = newValue.rawValue
        }
    }
    
    /// Computed property for display name
    public var displayName: String {
        return name ?? "Unknown Client"
    }
    
    /// Computed property for full address string
    public var fullAddress: String {
        var addressComponents: [String] = []
        
        if let address = address, !address.isEmpty {
            addressComponents.append(address)
        }
        if let city = city, !city.isEmpty {
            addressComponents.append(city)
        }
        if let state = state, !state.isEmpty {
            addressComponents.append(state)
        }
        if let zipCode = zipCode, !zipCode.isEmpty {
            addressComponents.append(zipCode)
        }
        if let country = country, !country.isEmpty {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
    
    /// Computed property to check if client has complete contact information
    public var hasCompleteContactInfo: Bool {
        return name != nil && email != nil && phone != nil && address != nil
    }
    
    /// Computed property for formatted phone number
    public var formattedPhoneNumber: String {
        guard let phone = phone else { return "N/A" }
        
        // Basic phone number formatting for US numbers
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if cleaned.count == 10 {
            let areaCode = String(cleaned.prefix(3))
            let exchange = String(cleaned.dropFirst(3).prefix(3))
            let number = String(cleaned.suffix(4))
            return "(\(areaCode)) \(exchange)-\(number)"
        } else if cleaned.count == 11 && cleaned.hasPrefix("1") {
            let areaCode = String(cleaned.dropFirst().prefix(3))
            let exchange = String(cleaned.dropFirst(4).prefix(3))
            let number = String(cleaned.suffix(4))
            return "+1 (\(areaCode)) \(exchange)-\(number)"
        }
        
        return phone
    }
    
    /// Computed property for document count
    public var documentCount: Int {
        return documents?.count ?? 0
    }
    
    /// Computed property for most recent document date
    public var mostRecentDocumentDate: Date? {
        return documents?.compactMap { ($0 as? Document)?.dateCreated }
                        .max()
    }
    
    // MARK: - Business Logic Methods
    
    /// Updates the client's active status
    /// - Parameter active: New active status
    public func updateActiveStatus(_ active: Bool) {
        isActive = active
        dateModified = Date()
    }
    
    /// Updates the client's contact information
    /// - Parameters:
    ///   - email: New email address
    ///   - phone: New phone number
    ///   - address: New address
    public func updateContactInfo(email: String? = nil, phone: String? = nil, address: String? = nil) {
        if let email = email {
            self.email = email
        }
        if let phone = phone {
            self.phone = phone
        }
        if let address = address {
            self.address = address
        }
        dateModified = Date()
    }
    
    /// Adds a note to the client's existing notes
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
    
    /// Validates email format
    /// - Parameter email: Email to validate
    /// - Returns: True if email format is valid
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates phone number format
    /// - Parameter phone: Phone number to validate
    /// - Returns: True if phone format is acceptable
    public static func isValidPhone(_ phone: String) -> Bool {
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleaned.count >= 10 && cleaned.count <= 15
    }
    
    /// Creates a summary dictionary of the client information
    /// - Returns: Dictionary containing key client information
    public func createSummary() -> [String: Any] {
        var summary: [String: Any] = [:]
        
        summary["id"] = id?.uuidString
        summary["name"] = name
        summary["email"] = email
        summary["phone"] = formattedPhoneNumber
        summary["address"] = fullAddress
        summary["clientType"] = clientTypeEnum.displayName
        summary["isActive"] = isActive
        summary["documentCount"] = documentCount
        summary["dateCreated"] = dateCreated
        summary["mostRecentDocumentDate"] = mostRecentDocumentDate
        summary["hasCompleteContactInfo"] = hasCompleteContactInfo
        
        return summary
    }
    
    /// Validates client properties before saving
    /// - Throws: ValidationError if validation fails
    public func validateForSave() throws {
        // Validate required fields
        guard let name = name, !name.isEmpty else {
            throw ValidationError.missingRequiredField("name")
        }
        
        guard let email = email, !email.isEmpty else {
            throw ValidationError.missingRequiredField("email")
        }
        
        // Validate email format
        guard Client.isValidEmail(email) else {
            throw ValidationError.invalidValue("email", email)
        }
        
        // Validate phone number if present
        if let phone = phone, !phone.isEmpty {
            guard Client.isValidPhone(phone) else {
                throw ValidationError.invalidValue("phone", phone)
            }
        }
        
        // Validate client type is valid
        guard let clientType = clientType, ClientType(rawValue: clientType) != nil else {
            throw ValidationError.invalidValue("clientType", clientType ?? "nil")
        }
        
        // Validate name length
        guard name.count <= 100 else {
            throw ValidationError.invalidValue("name", "Name must be 100 characters or less")
        }
        
        // Validate email length
        guard email.count <= 255 else {
            throw ValidationError.invalidValue("email", "Email must be 255 characters or less")
        }
    }
}

// MARK: - Core Data Validation

extension Client {
    
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
        
        // Ensure email is always lowercase
        if let email = email {
            self.email = email.lowercased()
        }
    }
}

// MARK: - Supporting Types

/// Client type enumeration
public enum ClientType: String, CaseIterable {
    case customer = "customer"
    case vendor = "vendor"
    case supplier = "supplier"
    case contractor = "contractor"
    case partner = "partner"
    case other = "other"
    
    /// Display name for the client type
    public var displayName: String {
        switch self {
        case .customer: return "Customer"
        case .vendor: return "Vendor"
        case .supplier: return "Supplier"
        case .contractor: return "Contractor"
        case .partner: return "Partner"
        case .other: return "Other"
        }
    }
    
    /// Icon name for the client type
    public var iconName: String {
        switch self {
        case .customer: return "person.circle"
        case .vendor: return "building.2.crop.circle"
        case .supplier: return "shippingbox.circle"
        case .contractor: return "hammer.circle"
        case .partner: return "handshake.circle"
        case .other: return "questionmark.circle"
        }
    }
    
    /// Color for client type indicator
    public var typeColor: String {
        switch self {
        case .customer: return "#007AFF"     // Blue
        case .vendor: return "#34C759"       // Green
        case .supplier: return "#FF9500"     // Orange
        case .contractor: return "#5856D6"   // Purple
        case .partner: return "#FF2D92"      // Pink
        case .other: return "#8E8E93"        // Gray
        }
    }
}