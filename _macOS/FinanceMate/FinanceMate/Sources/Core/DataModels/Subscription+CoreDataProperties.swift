//
//  Subscription+CoreDataProperties.swift
//  FinanceMate
//
//  Created by Assistant on 6/24/25.
//

import CoreData
import Foundation

extension Subscription {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subscription> {
        NSFetchRequest<Subscription>(entityName: "Subscription")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var serviceName: String?
    @NSManaged public var plan: String?
    @NSManaged public var cost: Double
    @NSManaged public var billingCycle: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var nextBillingDate: Date?
    @NSManaged public var status: String?
    @NSManaged public var category: String?
    @NSManaged public var notes: String?
    @NSManaged public var brandColorHex: String?
    @NSManaged public var cancelledDate: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateModified: Date?
    @NSManaged public var metadata: String?
}

// MARK: Generated accessors for relationships
extension Subscription: Identifiable {
}
