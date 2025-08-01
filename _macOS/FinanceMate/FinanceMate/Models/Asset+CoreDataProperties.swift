import Foundation
import CoreData

extension Asset {

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var assetType: String
    @NSManaged public var currentValue: Double
    @NSManaged public var purchasePrice: NSNumber?
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastUpdated: Date  
    @NSManaged public var financialEntity: FinancialEntity?
    @NSManaged public var valuationHistory: NSSet
}