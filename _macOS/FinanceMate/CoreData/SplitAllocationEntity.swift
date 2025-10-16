import Foundation
import CoreData

/// Split Allocation entity definition for Core Data
extension PersistenceController {

    /// Create SplitAllocation entity description
    static func createSplitAllocationEntity() -> NSEntityDescription {
        let splitEntity = NSEntityDescription()
        splitEntity.name = "SplitAllocation"
        splitEntity.managedObjectClassName = "SplitAllocation"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let percentageAttr = NSAttributeDescription()
        percentageAttr.name = "percentage"
        percentageAttr.attributeType = .doubleAttributeType
        percentageAttr.isOptional = false
        percentageAttr.defaultValue = 0.0

        let taxCategoryAttr = NSAttributeDescription()
        taxCategoryAttr.name = "taxCategory"
        taxCategoryAttr.attributeType = .stringAttributeType
        taxCategoryAttr.isOptional = false
        taxCategoryAttr.defaultValue = "Personal"

        splitEntity.properties = [idAttr, percentageAttr, taxCategoryAttr]

        return splitEntity
    }
}