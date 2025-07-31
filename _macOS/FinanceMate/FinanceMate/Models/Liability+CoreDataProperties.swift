import Foundation
import CoreData

extension Liability {

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var liabilityType: String?
    @NSManaged public var currentBalance: Double
    @NSManaged public var originalAmount: Double?
    @NSManaged public var interestRate: Double?
    @NSManaged public var monthlyPayment: Double?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUpdated: Date
    @NSManaged public var financialEntity: FinancialEntity?
    @NSManaged public var payments: NSSet
}