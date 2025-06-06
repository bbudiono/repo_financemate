// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  FinancialGoal+CoreDataProperties.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

import Foundation
import CoreData

extension FinancialGoal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialGoal> {
        return NSFetchRequest<FinancialGoal>(entityName: "FinancialGoal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var targetAmount: NSDecimalNumber?
    @NSManaged public var currentAmount: NSDecimalNumber?
    @NSManaged public var targetDate: Date?
    @NSManaged public var createdDate: Date?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var notes: String?
}