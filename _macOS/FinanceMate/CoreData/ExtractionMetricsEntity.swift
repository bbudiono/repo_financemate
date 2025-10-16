import Foundation
import CoreData

/// Extraction Metrics entity definition for Core Data
extension PersistenceController {

    /// Create ExtractionMetrics entity description
    static func createExtractionMetricsEntity() -> NSEntityDescription {
        let metricsEntity = NSEntityDescription()
        metricsEntity.name = "ExtractionMetrics"
        metricsEntity.managedObjectClassName = "ExtractionMetrics"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let totalProcessedAttr = NSAttributeDescription()
        totalProcessedAttr.name = "totalProcessed"
        totalProcessedAttr.attributeType = .integer32AttributeType
        totalProcessedAttr.isOptional = false
        totalProcessedAttr.defaultValue = 0

        let successfulExtractionsAttr = NSAttributeDescription()
        successfulExtractionsAttr.name = "successfulExtractions"
        successfulExtractionsAttr.attributeType = .integer32AttributeType
        successfulExtractionsAttr.isOptional = false
        successfulExtractionsAttr.defaultValue = 0

        let falsePositivesAttr = NSAttributeDescription()
        falsePositivesAttr.name = "falsePositives"
        falsePositivesAttr.attributeType = .integer32AttributeType
        falsePositivesAttr.isOptional = false
        falsePositivesAttr.defaultValue = 0

        let processingTimeAttr = NSAttributeDescription()
        processingTimeAttr.name = "averageProcessingTime"
        processingTimeAttr.attributeType = .doubleAttributeType
        processingTimeAttr.isOptional = true

        metricsEntity.properties = [
            idAttr, dateAttr, totalProcessedAttr, successfulExtractionsAttr,
            falsePositivesAttr, processingTimeAttr
        ]

        return metricsEntity
    }
}