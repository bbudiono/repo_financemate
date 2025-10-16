import Foundation
import CoreData

/// Transaction entity definition for Core Data
extension PersistenceController {

    /// Create Transaction entity description
    static func createTransactionEntity() -> NSEntityDescription {
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

        // BLUEPRINT 205-208: Gmail extraction fields
        let reviewStatusAttr = NSAttributeDescription()
        reviewStatusAttr.name = "reviewStatus"
        reviewStatusAttr.attributeType = .stringAttributeType
        reviewStatusAttr.isOptional = false
        reviewStatusAttr.defaultValue = "needsReview"

        let extractionTierAttr = NSAttributeDescription()
        extractionTierAttr.name = "extractionTier"
        extractionTierAttr.attributeType = .integer16AttributeType
        extractionTierAttr.isOptional = false
        extractionTierAttr.defaultValue = 0 // 0=regex, 1=foundation models, 2=manual

        let extractionTimeAttr = NSAttributeDescription()
        extractionTimeAttr.name = "extractionTime"
        extractionTimeAttr.attributeType = .doubleAttributeType
        extractionTimeAttr.isOptional = false
        extractionTimeAttr.defaultValue = 0.0

        let emailHashAttr = NSAttributeDescription()
        emailHashAttr.name = "emailHash"
        emailHashAttr.attributeType = .stringAttributeType
        emailHashAttr.isOptional = true

        let retryCountAttr = NSAttributeDescription()
        retryCountAttr.name = "retryCount"
        retryCountAttr.attributeType = .integer16AttributeType
        retryCountAttr.isOptional = false
        retryCountAttr.defaultValue = 0

        let extractionErrorAttr = NSAttributeDescription()
        extractionErrorAttr.name = "extractionError"
        extractionErrorAttr.attributeType = .stringAttributeType
        extractionErrorAttr.isOptional = true

        let extractionTimestampAttr = NSAttributeDescription()
        extractionTimestampAttr.name = "extractionTimestamp"
        extractionTimestampAttr.attributeType = .dateAttributeType
        extractionTimestampAttr.isOptional = true

        let foundationModelsVersionAttr = NSAttributeDescription()
        foundationModelsVersionAttr.name = "foundationModelsVersion"
        foundationModelsVersionAttr.attributeType = .stringAttributeType
        foundationModelsVersionAttr.isOptional = true

        // Gmail-specific fields
        let confidenceAttr = NSAttributeDescription()
        confidenceAttr.name = "confidence"
        confidenceAttr.attributeType = .doubleAttributeType
        confidenceAttr.isOptional = false
        confidenceAttr.defaultValue = 0.0

        let rawEmailTextAttr = NSAttributeDescription()
        rawEmailTextAttr.name = "rawEmailText"
        rawEmailTextAttr.attributeType = .stringAttributeType
        rawEmailTextAttr.isOptional = true

        let emailSubjectAttr = NSAttributeDescription()
        emailSubjectAttr.name = "emailSubject"
        emailSubjectAttr.attributeType = .stringAttributeType
        emailSubjectAttr.isOptional = true

        let emailSenderAttr = NSAttributeDescription()
        emailSenderAttr.name = "emailSender"
        emailSenderAttr.attributeType = .stringAttributeType
        emailSenderAttr.isOptional = true

        let gstAmountAttr = NSAttributeDescription()
        gstAmountAttr.name = "gstAmount"
        gstAmountAttr.attributeType = .doubleAttributeType
        gstAmountAttr.isOptional = true

        let abnAttr = NSAttributeDescription()
        abnAttr.name = "abn"
        abnAttr.attributeType = .stringAttributeType
        abnAttr.isOptional = true

        let invoiceNumberAttr = NSAttributeDescription()
        invoiceNumberAttr.name = "invoiceNumber"
        invoiceNumberAttr.attributeType = .stringAttributeType
        invoiceNumberAttr.isOptional = true

        let paymentMethodAttr = NSAttributeDescription()
        paymentMethodAttr.name = "paymentMethod"
        paymentMethodAttr.attributeType = .stringAttributeType
        paymentMethodAttr.isOptional = true

        // Multi-currency fields
        let originalCurrencyAttr = NSAttributeDescription()
        originalCurrencyAttr.name = "originalCurrency"
        originalCurrencyAttr.attributeType = .stringAttributeType
        originalCurrencyAttr.isOptional = true

        let originalAmountAttr = NSAttributeDescription()
        originalAmountAttr.name = "originalAmount"
        originalAmountAttr.attributeType = .doubleAttributeType
        originalAmountAttr.isOptional = true

        let exchangeRateAttr = NSAttributeDescription()
        exchangeRateAttr.name = "exchangeRate"
        exchangeRateAttr.attributeType = .doubleAttributeType
        exchangeRateAttr.isOptional = true

        transactionEntity.properties = [
            idAttr, amountAttr, descAttr, dateAttr, sourceAttr, categoryAttr,
            noteAttr, taxCategoryAttr, sourceEmailIDAttr, importedDateAttr,
            transactionTypeAttr, contentHashAttr,
            // Gmail extraction fields
            reviewStatusAttr, extractionTierAttr, extractionTimeAttr, emailHashAttr,
            retryCountAttr, extractionErrorAttr, extractionTimestampAttr, foundationModelsVersionAttr,
            confidenceAttr, rawEmailTextAttr, emailSubjectAttr, emailSenderAttr,
            gstAmountAttr, abnAttr, invoiceNumberAttr, paymentMethodAttr,
            originalCurrencyAttr, originalAmountAttr, exchangeRateAttr
        ]

        return transactionEntity
    }
}