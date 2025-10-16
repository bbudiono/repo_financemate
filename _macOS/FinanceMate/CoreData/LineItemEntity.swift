import Foundation
import CoreData

/// Line Item entity definition for Core Data
extension PersistenceController {

    /// Create LineItem entity description
    static func createLineItemEntity() -> NSEntityDescription {
        let lineItemEntity = NSEntityDescription()
        lineItemEntity.name = "LineItem"
        lineItemEntity.managedObjectClassName = "LineItem"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let descAttr = NSAttributeDescription()
        descAttr.name = "itemDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = false
        descAttr.defaultValue = ""

        let quantityAttr = NSAttributeDescription()
        quantityAttr.name = "quantity"
        quantityAttr.attributeType = .doubleAttributeType
        quantityAttr.isOptional = false
        quantityAttr.defaultValue = 1.0

        let unitPriceAttr = NSAttributeDescription()
        unitPriceAttr.name = "unitPrice"
        unitPriceAttr.attributeType = .doubleAttributeType
        unitPriceAttr.isOptional = false
        unitPriceAttr.defaultValue = 0.0

        let amountAttr = NSAttributeDescription()
        amountAttr.name = "amount"
        amountAttr.attributeType = .doubleAttributeType
        amountAttr.isOptional = false
        amountAttr.defaultValue = 0.0

        let gstAttr = NSAttributeDescription()
        gstAttr.name = "gst"
        gstAttr.attributeType = .doubleAttributeType
        gstAttr.isOptional = true

        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = true

        lineItemEntity.properties = [
            idAttr, descAttr, quantityAttr, unitPriceAttr, amountAttr, gstAttr, categoryAttr
        ]

        return lineItemEntity
    }
}