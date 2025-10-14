import CoreData
import os.log

struct PersistenceController {
    private static let logger = Logger(subsystem: "FinanceMate", category: "PersistenceController")

    static let shared = PersistenceController()
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        let transaction = Transaction(context: viewContext)

        do {
            try viewContext.save()
        } catch {
            logger.error("Preview save error: \(error.localizedDescription)")
        }
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FinanceMate", managedObjectModel: Self.createModel())

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                Self.logger.error("Core Data load error: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MARK: - LineItem Entity

        let lineItemEntity = NSEntityDescription()
        lineItemEntity.name = "LineItem"
        lineItemEntity.managedObjectClassName = "LineItem"

        let lineItemId = NSAttributeDescription()
        lineItemId.name = "id"
        lineItemId.attributeType = .UUIDAttributeType
        lineItemId.isOptional = false

        let lineItemDescription = NSAttributeDescription()
        lineItemDescription.name = "itemDescription"
        lineItemDescription.attributeType = .stringAttributeType
        lineItemDescription.isOptional = false
        lineItemDescription.defaultValue = ""

        let lineItemQuantity = NSAttributeDescription()
        lineItemQuantity.name = "quantity"
        lineItemQuantity.attributeType = .integer32AttributeType
        lineItemQuantity.isOptional = false
        lineItemQuantity.defaultValue = 1

        let lineItemPrice = NSAttributeDescription()
        lineItemPrice.name = "price"
        lineItemPrice.attributeType = .doubleAttributeType
        lineItemPrice.isOptional = false
        lineItemPrice.defaultValue = 0.0

        let lineItemTaxCategory = NSAttributeDescription()
        lineItemTaxCategory.name = "taxCategory"
        lineItemTaxCategory.attributeType = .stringAttributeType
        lineItemTaxCategory.isOptional = false
        lineItemTaxCategory.defaultValue = "Personal"

        lineItemEntity.properties = [lineItemId, lineItemDescription, lineItemQuantity, lineItemPrice, lineItemTaxCategory]

        // MARK: - Transaction Entity

        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "Transaction"
        transactionEntity.managedObjectClassName = "Transaction"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let amountAttr = NSAttributeDescription()
        amountAttr.name = "amount"
        amountAttr.attributeType = .doubleAttributeType
        amountAttr.isOptional = false
        amountAttr.defaultValue = 0.0

        let descAttr = NSAttributeDescription()
        descAttr.name = "itemDescription"
        descAttr.attributeType = .stringAttributeType
        descAttr.isOptional = false
        descAttr.defaultValue = ""

        let dateAttr = NSAttributeDescription()
        dateAttr.name = "date"
        dateAttr.attributeType = .dateAttributeType
        dateAttr.isOptional = false

        let sourceAttr = NSAttributeDescription()
        sourceAttr.name = "source"
        sourceAttr.attributeType = .stringAttributeType
        sourceAttr.isOptional = false
        sourceAttr.defaultValue = "manual"

        let categoryAttr = NSAttributeDescription()
        categoryAttr.name = "category"
        categoryAttr.attributeType = .stringAttributeType
        categoryAttr.isOptional = false
        categoryAttr.defaultValue = "Other"

        let noteAttr = NSAttributeDescription()
        noteAttr.name = "note"
        noteAttr.attributeType = .stringAttributeType
        noteAttr.isOptional = true

        let taxCategoryAttr = NSAttributeDescription()
        taxCategoryAttr.name = "taxCategory"
        taxCategoryAttr.attributeType = .stringAttributeType
        taxCategoryAttr.isOptional = false
        taxCategoryAttr.defaultValue = "Personal"

        let sourceEmailIDAttr = NSAttributeDescription()
        sourceEmailIDAttr.name = "sourceEmailID"
        sourceEmailIDAttr.attributeType = .stringAttributeType
        sourceEmailIDAttr.isOptional = true

        let importedDateAttr = NSAttributeDescription()
        importedDateAttr.name = "importedDate"
        importedDateAttr.attributeType = .dateAttributeType
        importedDateAttr.isOptional = true

        let transactionTypeAttr = NSAttributeDescription()
        transactionTypeAttr.name = "transactionType"
        transactionTypeAttr.attributeType = .stringAttributeType
        transactionTypeAttr.isOptional = false
        transactionTypeAttr.defaultValue = "expense"

        let contentHashAttr = NSAttributeDescription()
        contentHashAttr.name = "contentHash"
        contentHashAttr.attributeType = .integer64AttributeType
        contentHashAttr.isOptional = false
        contentHashAttr.defaultValue = 0

        transactionEntity.properties = [idAttr, amountAttr, descAttr, dateAttr, sourceAttr, categoryAttr, noteAttr, taxCategoryAttr, sourceEmailIDAttr, importedDateAttr, transactionTypeAttr, contentHashAttr]

        // MARK: - Relationships

        let lineItemsRelationship = NSRelationshipDescription()
        lineItemsRelationship.name = "lineItems"
        lineItemsRelationship.destinationEntity = lineItemEntity
        lineItemsRelationship.minCount = 0
        lineItemsRelationship.maxCount = 0
        lineItemsRelationship.deleteRule = .cascadeDeleteRule
        lineItemsRelationship.isOptional = true

        let transactionRelationship = NSRelationshipDescription()
        transactionRelationship.name = "transaction"
        transactionRelationship.destinationEntity = transactionEntity
        transactionRelationship.minCount = 0
        transactionRelationship.maxCount = 1
        transactionRelationship.deleteRule = .nullifyDeleteRule
        transactionRelationship.isOptional = true

        lineItemsRelationship.inverseRelationship = transactionRelationship
        transactionRelationship.inverseRelationship = lineItemsRelationship

        transactionEntity.properties.append(lineItemsRelationship)
        lineItemEntity.properties.append(transactionRelationship)

        // MARK: - ExtractionFeedback Entity (BLUEPRINT Section 3.1.1.4)

        let feedbackEntity = NSEntityDescription()
        feedbackEntity.name = "ExtractionFeedback"
        feedbackEntity.managedObjectClassName = "ExtractionFeedback"

        let fbID = NSAttributeDescription()
        fbID.name = "id"
        fbID.attributeType = .UUIDAttributeType
        fbID.isOptional = false

        let fbEmailID = NSAttributeDescription()
        fbEmailID.name = "emailID"
        fbEmailID.attributeType = .stringAttributeType
        fbEmailID.isOptional = false

        let fbFieldName = NSAttributeDescription()
        fbFieldName.name = "fieldName"
        fbFieldName.attributeType = .stringAttributeType
        fbFieldName.isOptional = false

        let fbOriginal = NSAttributeDescription()
        fbOriginal.name = "originalValue"
        fbOriginal.attributeType = .stringAttributeType
        fbOriginal.isOptional = false

        let fbCorrected = NSAttributeDescription()
        fbCorrected.name = "correctedValue"
        fbCorrected.attributeType = .stringAttributeType
        fbCorrected.isOptional = false

        let fbMerchant = NSAttributeDescription()
        fbMerchant.name = "merchant"
        fbMerchant.attributeType = .stringAttributeType
        fbMerchant.isOptional = false

        let fbTimestamp = NSAttributeDescription()
        fbTimestamp.name = "timestamp"
        fbTimestamp.attributeType = .dateAttributeType
        fbTimestamp.isOptional = false

        let fbHallucination = NSAttributeDescription()
        fbHallucination.name = "wasHallucination"
        fbHallucination.attributeType = .booleanAttributeType
        fbHallucination.isOptional = false
        fbHallucination.defaultValue = false

        let fbConfidence = NSAttributeDescription()
        fbConfidence.name = "confidence"
        fbConfidence.attributeType = .doubleAttributeType
        fbConfidence.isOptional = false
        fbConfidence.defaultValue = 0.0

        let fbTier = NSAttributeDescription()
        fbTier.name = "extractionTier"
        fbTier.attributeType = .stringAttributeType
        fbTier.isOptional = false
        fbTier.defaultValue = "regex"

        feedbackEntity.properties = [fbID, fbEmailID, fbFieldName, fbOriginal, fbCorrected, fbMerchant, fbTimestamp, fbHallucination, fbConfidence, fbTier]

        // MARK: - SplitAllocation Entity (BLUEPRINT Section 3.1.3 - Tax Splitting)

        let splitEntity = NSEntityDescription()
        splitEntity.name = "SplitAllocation"
        splitEntity.managedObjectClassName = "SplitAllocation"

        let splitID = NSAttributeDescription()
        splitID.name = "id"
        splitID.attributeType = .UUIDAttributeType
        splitID.isOptional = false

        let splitLineItemID = NSAttributeDescription()
        splitLineItemID.name = "lineItemID"
        splitLineItemID.attributeType = .UUIDAttributeType
        splitLineItemID.isOptional = false

        let splitTaxCategory = NSAttributeDescription()
        splitTaxCategory.name = "taxCategory"
        splitTaxCategory.attributeType = .stringAttributeType
        splitTaxCategory.isOptional = false

        let splitPercentage = NSAttributeDescription()
        splitPercentage.name = "percentage"
        splitPercentage.attributeType = .doubleAttributeType
        splitPercentage.isOptional = false
        splitPercentage.defaultValue = 100.0

        let splitAmount = NSAttributeDescription()
        splitAmount.name = "amount"
        splitAmount.attributeType = .doubleAttributeType
        splitAmount.isOptional = false
        splitAmount.defaultValue = 0.0

        splitEntity.properties = [splitID, splitLineItemID, splitTaxCategory, splitPercentage, splitAmount]

        // MARK: - ExtractionMetrics Entity (BLUEPRINT Line 192)

        let metricsEntity = NSEntityDescription()
        metricsEntity.name = "ExtractionMetrics"
        metricsEntity.managedObjectClassName = "ExtractionMetrics"

        let metricsDate = NSAttributeDescription()
        metricsDate.name = "date"
        metricsDate.attributeType = .dateAttributeType
        metricsDate.isOptional = false

        let metricsTotalExtractions = NSAttributeDescription()
        metricsTotalExtractions.name = "totalExtractions"
        metricsTotalExtractions.attributeType = .integer32AttributeType
        metricsTotalExtractions.isOptional = false
        metricsTotalExtractions.defaultValue = 0

        let metricsTier1Count = NSAttributeDescription()
        metricsTier1Count.name = "tier1Count"
        metricsTier1Count.attributeType = .integer32AttributeType
        metricsTier1Count.isOptional = false
        metricsTier1Count.defaultValue = 0

        let metricsTier2Count = NSAttributeDescription()
        metricsTier2Count.name = "tier2Count"
        metricsTier2Count.attributeType = .integer32AttributeType
        metricsTier2Count.isOptional = false
        metricsTier2Count.defaultValue = 0

        let metricsTier3Count = NSAttributeDescription()
        metricsTier3Count.name = "tier3Count"
        metricsTier3Count.attributeType = .integer32AttributeType
        metricsTier3Count.isOptional = false
        metricsTier3Count.defaultValue = 0

        let metricsAvgExtractionTime = NSAttributeDescription()
        metricsAvgExtractionTime.name = "avgExtractionTime"
        metricsAvgExtractionTime.attributeType = .doubleAttributeType
        metricsAvgExtractionTime.isOptional = false
        metricsAvgExtractionTime.defaultValue = 0.0

        let metricsAvgConfidence = NSAttributeDescription()
        metricsAvgConfidence.name = "avgConfidence"
        metricsAvgConfidence.attributeType = .doubleAttributeType
        metricsAvgConfidence.isOptional = false
        metricsAvgConfidence.defaultValue = 0.0

        let metricsHallucinationCount = NSAttributeDescription()
        metricsHallucinationCount.name = "hallucinationCount"
        metricsHallucinationCount.attributeType = .integer32AttributeType
        metricsHallucinationCount.isOptional = false
        metricsHallucinationCount.defaultValue = 0

        let metricsErrorCount = NSAttributeDescription()
        metricsErrorCount.name = "errorCount"
        metricsErrorCount.attributeType = .integer32AttributeType
        metricsErrorCount.isOptional = false
        metricsErrorCount.defaultValue = 0

        let metricsCacheHitRate = NSAttributeDescription()
        metricsCacheHitRate.name = "cacheHitRate"
        metricsCacheHitRate.attributeType = .doubleAttributeType
        metricsCacheHitRate.isOptional = false
        metricsCacheHitRate.defaultValue = 0.0

        metricsEntity.properties = [
            metricsDate,
            metricsTotalExtractions,
            metricsTier1Count,
            metricsTier2Count,
            metricsTier3Count,
            metricsAvgExtractionTime,
            metricsAvgConfidence,
            metricsHallucinationCount,
            metricsErrorCount,
            metricsCacheHitRate
        ]

        model.entities = [transactionEntity, lineItemEntity, feedbackEntity, splitEntity, metricsEntity]
        return model
    }
}
