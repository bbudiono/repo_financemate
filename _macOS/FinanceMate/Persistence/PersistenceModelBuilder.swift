import CoreData

/// Persistence model builder - Entity definitions and relationships
/// Extracted from PersistenceController.swift for KISS principle compliance
struct PersistenceModelBuilder {

    /// Creates the complete Core Data model with all entities and relationships
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create all entities
        let transactionEntity = createTransactionEntity()
        let lineItemEntity = createLineItemEntity()
        let feedbackEntity = createExtractionFeedbackEntity()
        let splitEntity = createSplitAllocationEntity()
        let gmailEmailEntity = createGmailEmailEntity()
        let metricsEntity = createExtractionMetricsEntity()

        // Configure relationships between entities
        configureRelationships(transaction: transactionEntity, lineItem: lineItemEntity)

        // Apply indexes for performance optimization
        PersistenceIndexConfiguration.configureIndexes(for: transactionEntity)

        model.entities = [transactionEntity, lineItemEntity, feedbackEntity, splitEntity, metricsEntity, gmailEmailEntity]
        return model
    }

    // MARK: - Transaction Entity

    private static func createTransactionEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "Transaction"
        entity.managedObjectClassName = "Transaction"

        // Core attributes
        let id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
        let amount = createAttribute(name: "amount", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
        let itemDescription = createAttribute(name: "itemDescription", type: .stringAttributeType, optional: false, defaultValue: "")
        let date = createAttribute(name: "date", type: .dateAttributeType, optional: false)
        let source = createAttribute(name: "source", type: .stringAttributeType, optional: false, defaultValue: "manual")
        let category = createAttribute(name: "category", type: .stringAttributeType, optional: false, defaultValue: "Other")
        let note = createAttribute(name: "note", type: .stringAttributeType, optional: true)
        let taxCategory = createAttribute(name: "taxCategory", type: .stringAttributeType, optional: false, defaultValue: "Personal")

        // Gmail integration attributes
        let sourceEmailID = createAttribute(name: "sourceEmailID", type: .stringAttributeType, optional: true)
        let importedDate = createAttribute(name: "importedDate", type: .dateAttributeType, optional: true)
        let emailSource = createAttribute(name: "emailSource", type: .stringAttributeType, optional: true)

        // Transaction metadata
        let transactionType = createAttribute(name: "transactionType", type: .stringAttributeType, optional: false, defaultValue: "expense")
        let contentHash = createAttribute(name: "contentHash", type: .integer64AttributeType, optional: false, defaultValue: 0)

        // Basiq bank integration
        let externalTransactionId = createAttribute(name: "externalTransactionId", type: .stringAttributeType, optional: true)

        entity.properties = [id, amount, itemDescription, date, source, category, note, taxCategory,
                           sourceEmailID, importedDate, transactionType, contentHash, emailSource, externalTransactionId]

        // Add unique constraint to prevent duplicate Gmail extractions
        entity.uniquenessConstraints = [[sourceEmailID]]

        return entity
    }

    // MARK: - LineItem Entity

    private static func createLineItemEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "LineItem"
        entity.managedObjectClassName = "LineItem"

        let id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
        let itemDescription = createAttribute(name: "itemDescription", type: .stringAttributeType, optional: false, defaultValue: "")
        let quantity = createAttribute(name: "quantity", type: .integer32AttributeType, optional: false, defaultValue: 1)
        let price = createAttribute(name: "price", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
        let taxCategory = createAttribute(name: "taxCategory", type: .stringAttributeType, optional: false, defaultValue: "Personal")

        entity.properties = [id, itemDescription, quantity, price, taxCategory]
        return entity
    }

    // MARK: - ExtractionFeedback Entity (BLUEPRINT Section 3.1.1.4)

    private static func createExtractionFeedbackEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "ExtractionFeedback"
        entity.managedObjectClassName = "ExtractionFeedback"

        let id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
        let emailID = createAttribute(name: "emailID", type: .stringAttributeType, optional: false)
        let fieldName = createAttribute(name: "fieldName", type: .stringAttributeType, optional: false)
        let originalValue = createAttribute(name: "originalValue", type: .stringAttributeType, optional: false)
        let correctedValue = createAttribute(name: "correctedValue", type: .stringAttributeType, optional: false)
        let merchant = createAttribute(name: "merchant", type: .stringAttributeType, optional: false)
        let timestamp = createAttribute(name: "timestamp", type: .dateAttributeType, optional: false)
        let wasHallucination = createAttribute(name: "wasHallucination", type: .booleanAttributeType, optional: false, defaultValue: false)
        let confidence = createAttribute(name: "confidence", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
        let extractionTier = createAttribute(name: "extractionTier", type: .stringAttributeType, optional: false, defaultValue: "regex")

        entity.properties = [id, emailID, fieldName, originalValue, correctedValue, merchant,
                           timestamp, wasHallucination, confidence, extractionTier]
        return entity
    }

    // MARK: - SplitAllocation Entity (BLUEPRINT Section 3.1.3 - Tax Splitting)

    private static func createSplitAllocationEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "SplitAllocation"
        entity.managedObjectClassName = "SplitAllocation"

        let id = createAttribute(name: "id", type: .UUIDAttributeType, optional: false)
        let lineItemID = createAttribute(name: "lineItemID", type: .UUIDAttributeType, optional: false)
        let taxCategory = createAttribute(name: "taxCategory", type: .stringAttributeType, optional: false)
        let percentage = createAttribute(name: "percentage", type: .doubleAttributeType, optional: false, defaultValue: 100.0)
        let amount = createAttribute(name: "amount", type: .doubleAttributeType, optional: false, defaultValue: 0.0)

        entity.properties = [id, lineItemID, taxCategory, percentage, amount]
        return entity
    }

    // MARK: - GmailEmail Entity (BLUEPRINT Lines 74, 91: Permanent storage)

    private static func createGmailEmailEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "GmailEmailEntity"
        entity.managedObjectClassName = "GmailEmailEntity"

        let id = createAttribute(name: "id", type: .stringAttributeType, optional: false)
        let subject = createAttribute(name: "subject", type: .stringAttributeType, optional: false)
        let sender = createAttribute(name: "sender", type: .stringAttributeType, optional: false)
        let date = createAttribute(name: "date", type: .dateAttributeType, optional: false)
        let snippet = createAttribute(name: "snippet", type: .stringAttributeType, optional: false)
        let status = createAttribute(name: "status", type: .stringAttributeType, optional: false, defaultValue: "unprocessed")
        let fetchedAt = createAttribute(name: "fetchedAt", type: .dateAttributeType, optional: false)
        let attachmentsData = createAttribute(name: "attachmentsData", type: .binaryDataAttributeType, optional: true)

        entity.properties = [id, subject, sender, date, snippet, status, fetchedAt, attachmentsData]
        return entity
    }

    // MARK: - ExtractionMetrics Entity (BLUEPRINT Line 192)

    private static func createExtractionMetricsEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "ExtractionMetrics"
        entity.managedObjectClassName = "ExtractionMetrics"

        let date = createAttribute(name: "date", type: .dateAttributeType, optional: false)
        let totalExtractions = createAttribute(name: "totalExtractions", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let tier1Count = createAttribute(name: "tier1Count", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let tier2Count = createAttribute(name: "tier2Count", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let tier3Count = createAttribute(name: "tier3Count", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let avgExtractionTime = createAttribute(name: "avgExtractionTime", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
        let avgConfidence = createAttribute(name: "avgConfidence", type: .doubleAttributeType, optional: false, defaultValue: 0.0)
        let hallucinationCount = createAttribute(name: "hallucinationCount", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let errorCount = createAttribute(name: "errorCount", type: .integer32AttributeType, optional: false, defaultValue: 0)
        let cacheHitRate = createAttribute(name: "cacheHitRate", type: .doubleAttributeType, optional: false, defaultValue: 0.0)

        entity.properties = [date, totalExtractions, tier1Count, tier2Count, tier3Count,
                           avgExtractionTime, avgConfidence, hallucinationCount, errorCount, cacheHitRate]
        return entity
    }

    // MARK: - Relationship Configuration

    private static func configureRelationships(transaction: NSEntityDescription, lineItem: NSEntityDescription) {
        let lineItemsRelationship = NSRelationshipDescription()
        lineItemsRelationship.name = "lineItems"
        lineItemsRelationship.destinationEntity = lineItem
        lineItemsRelationship.minCount = 0
        lineItemsRelationship.maxCount = 0
        lineItemsRelationship.deleteRule = .cascadeDeleteRule
        lineItemsRelationship.isOptional = true

        let transactionRelationship = NSRelationshipDescription()
        transactionRelationship.name = "transaction"
        transactionRelationship.destinationEntity = transaction
        transactionRelationship.minCount = 0
        transactionRelationship.maxCount = 1
        transactionRelationship.deleteRule = .nullifyDeleteRule
        transactionRelationship.isOptional = true

        lineItemsRelationship.inverseRelationship = transactionRelationship
        transactionRelationship.inverseRelationship = lineItemsRelationship

        transaction.properties.append(lineItemsRelationship)
        lineItem.properties.append(transactionRelationship)
    }

    // MARK: - Helper Methods

    private static func createAttribute(
        name: String,
        type: NSAttributeType,
        optional: Bool,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = optional
        if let defaultValue = defaultValue {
            attr.defaultValue = defaultValue
        }
        return attr
    }
}
