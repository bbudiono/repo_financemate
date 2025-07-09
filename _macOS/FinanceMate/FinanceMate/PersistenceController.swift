import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    /// Shared preview instance for SwiftUI previews and testing
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data for previews
        let context = controller.container.viewContext

        // Create sample transactions for preview
        let sampleTransaction1 = Transaction.create(
            in: context,
            amount: 1_250.00,
            category: "Income",
            note: "Salary payment"
        )

        let sampleTransaction2 = Transaction.create(
            in: context,
            amount: -89.50,
            category: "Food",
            note: "Grocery shopping"
        )

        let sampleTransaction3 = Transaction.create(
            in: context,
            amount: -45.00,
            category: "Transport",
            note: "Gas station"
        )

        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Create a programmatic Core Data model
        let model = NSManagedObjectModel()

        // Create Transaction entity
        let transactionEntity = NSEntityDescription()
        transactionEntity.name = "Transaction"
        transactionEntity.managedObjectClassName = "Transaction"

        // Add attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "date"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false

        let amountAttribute = NSAttributeDescription()
        amountAttribute.name = "amount"
        amountAttribute.attributeType = .doubleAttributeType
        amountAttribute.isOptional = false

        let categoryAttribute = NSAttributeDescription()
        categoryAttribute.name = "category"
        categoryAttribute.attributeType = .stringAttributeType
        categoryAttribute.isOptional = false

        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        // Create LineItem entity
        let lineItemEntity = NSEntityDescription()
        lineItemEntity.name = "LineItem"
        lineItemEntity.managedObjectClassName = "LineItem"

        // LineItem attributes
        let lineItemIdAttribute = NSAttributeDescription()
        lineItemIdAttribute.name = "id"
        lineItemIdAttribute.attributeType = .UUIDAttributeType
        lineItemIdAttribute.isOptional = false

        let itemDescriptionAttribute = NSAttributeDescription()
        itemDescriptionAttribute.name = "itemDescription"
        itemDescriptionAttribute.attributeType = .stringAttributeType
        itemDescriptionAttribute.isOptional = false

        let lineItemAmountAttribute = NSAttributeDescription()
        lineItemAmountAttribute.name = "amount"
        lineItemAmountAttribute.attributeType = .doubleAttributeType
        lineItemAmountAttribute.isOptional = false

        lineItemEntity.properties = [lineItemIdAttribute, itemDescriptionAttribute, lineItemAmountAttribute]

        // Create SplitAllocation entity
        let splitAllocationEntity = NSEntityDescription()
        splitAllocationEntity.name = "SplitAllocation"
        splitAllocationEntity.managedObjectClassName = "SplitAllocation"

        // SplitAllocation attributes
        let splitIdAttribute = NSAttributeDescription()
        splitIdAttribute.name = "id"
        splitIdAttribute.attributeType = .UUIDAttributeType
        splitIdAttribute.isOptional = false

        let percentageAttribute = NSAttributeDescription()
        percentageAttribute.name = "percentage"
        percentageAttribute.attributeType = .doubleAttributeType
        percentageAttribute.isOptional = false

        let taxCategoryAttribute = NSAttributeDescription()
        taxCategoryAttribute.name = "taxCategory"
        taxCategoryAttribute.attributeType = .stringAttributeType
        taxCategoryAttribute.isOptional = false

        splitAllocationEntity.properties = [splitIdAttribute, percentageAttribute, taxCategoryAttribute]

        // Create relationships
        // Transaction -> LineItems (one-to-many)
        let transactionToLineItemsRelationship = NSRelationshipDescription()
        transactionToLineItemsRelationship.name = "lineItems"
        transactionToLineItemsRelationship.destinationEntity = lineItemEntity
        transactionToLineItemsRelationship.minCount = 0
        transactionToLineItemsRelationship.maxCount = 0 // 0 means unlimited for to-many
        transactionToLineItemsRelationship.deleteRule = .cascadeDeleteRule

        // LineItem -> Transaction (many-to-one)
        let lineItemToTransactionRelationship = NSRelationshipDescription()
        lineItemToTransactionRelationship.name = "transaction"
        lineItemToTransactionRelationship.destinationEntity = transactionEntity
        lineItemToTransactionRelationship.minCount = 1
        lineItemToTransactionRelationship.maxCount = 1
        lineItemToTransactionRelationship.deleteRule = .nullifyDeleteRule

        // LineItem -> SplitAllocations (one-to-many)
        let lineItemToSplitAllocationsRelationship = NSRelationshipDescription()
        lineItemToSplitAllocationsRelationship.name = "splitAllocations"
        lineItemToSplitAllocationsRelationship.destinationEntity = splitAllocationEntity
        lineItemToSplitAllocationsRelationship.minCount = 0
        lineItemToSplitAllocationsRelationship.maxCount = 0 // 0 means unlimited for to-many
        lineItemToSplitAllocationsRelationship.deleteRule = .cascadeDeleteRule

        // SplitAllocation -> LineItem (many-to-one)
        let splitAllocationToLineItemRelationship = NSRelationshipDescription()
        splitAllocationToLineItemRelationship.name = "lineItem"
        splitAllocationToLineItemRelationship.destinationEntity = lineItemEntity
        splitAllocationToLineItemRelationship.minCount = 1
        splitAllocationToLineItemRelationship.maxCount = 1
        splitAllocationToLineItemRelationship.deleteRule = .nullifyDeleteRule

        // Set up inverse relationships
        transactionToLineItemsRelationship.inverseRelationship = lineItemToTransactionRelationship
        lineItemToTransactionRelationship.inverseRelationship = transactionToLineItemsRelationship
        lineItemToSplitAllocationsRelationship.inverseRelationship = splitAllocationToLineItemRelationship
        splitAllocationToLineItemRelationship.inverseRelationship = lineItemToSplitAllocationsRelationship

        // Add relationships to entities
        // Add entityId attribute to Transaction for multi-entity support
        let entityIdAttribute = NSAttributeDescription()
        entityIdAttribute.name = "entityId"
        entityIdAttribute.attributeType = .UUIDAttributeType
        entityIdAttribute.isOptional = false
        
        // Add type attribute to Transaction
        let typeAttribute = NSAttributeDescription()
        typeAttribute.name = "type"
        typeAttribute.attributeType = .stringAttributeType
        typeAttribute.isOptional = false
        
        transactionEntity.properties = [
            idAttribute,
            dateAttribute,
            amountAttribute,
            categoryAttribute,
            noteAttribute,
            createdAtAttribute,
            entityIdAttribute,
            typeAttribute,
            transactionToLineItemsRelationship,
        ]
        lineItemEntity.properties = [
            lineItemIdAttribute,
            itemDescriptionAttribute,
            lineItemAmountAttribute,
            lineItemToTransactionRelationship,
            lineItemToSplitAllocationsRelationship,
        ]
        splitAllocationEntity.properties = [
            splitIdAttribute,
            percentageAttribute,
            taxCategoryAttribute,
            splitAllocationToLineItemRelationship,
        ]

        // Create FinancialEntity entity
        let financialEntityEntity = NSEntityDescription()
        financialEntityEntity.name = "FinancialEntity"
        financialEntityEntity.managedObjectClassName = "FinancialEntity"
        
        // FinancialEntity attributes - aligned with FinancialEntity+CoreDataClass.swift
        let entityIdAttr = NSAttributeDescription()
        entityIdAttr.name = "id"
        entityIdAttr.attributeType = .UUIDAttributeType
        entityIdAttr.isOptional = false
        
        let entityNameAttr = NSAttributeDescription()
        entityNameAttr.name = "name"
        entityNameAttr.attributeType = .stringAttributeType
        entityNameAttr.isOptional = false
        
        let entityTypeAttr = NSAttributeDescription()
        entityTypeAttr.name = "type"
        entityTypeAttr.attributeType = .stringAttributeType
        entityTypeAttr.isOptional = false
        
        let isActiveAttr = NSAttributeDescription()
        isActiveAttr.name = "isActive"
        isActiveAttr.attributeType = .booleanAttributeType
        isActiveAttr.isOptional = false
        
        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        
        let lastModifiedAttr = NSAttributeDescription()
        lastModifiedAttr.name = "lastModified"
        lastModifiedAttr.attributeType = .dateAttributeType
        lastModifiedAttr.isOptional = false
        
        let entityDescriptionAttr = NSAttributeDescription()
        entityDescriptionAttr.name = "entityDescription"
        entityDescriptionAttr.attributeType = .stringAttributeType
        entityDescriptionAttr.isOptional = true
        
        let colorCodeAttr = NSAttributeDescription()
        colorCodeAttr.name = "colorCode"
        colorCodeAttr.attributeType = .stringAttributeType
        colorCodeAttr.isOptional = true
        
        // Create SMSFEntityDetails entity
        let smsfDetailsEntity = NSEntityDescription()
        smsfDetailsEntity.name = "SMSFEntityDetails"
        smsfDetailsEntity.managedObjectClassName = "SMSFEntityDetails"
        
        // SMSFEntityDetails attributes
        let smsfIdAttr = NSAttributeDescription()
        smsfIdAttr.name = "id"
        smsfIdAttr.attributeType = .UUIDAttributeType
        smsfIdAttr.isOptional = false
        
        let smsfAbnAttr = NSAttributeDescription()
        smsfAbnAttr.name = "abn"
        smsfAbnAttr.attributeType = .stringAttributeType
        smsfAbnAttr.isOptional = false
        
        let trustDeedDateAttr = NSAttributeDescription()
        trustDeedDateAttr.name = "trustDeedDate"
        trustDeedDateAttr.attributeType = .dateAttributeType
        trustDeedDateAttr.isOptional = false
        
        let investmentStrategyDateAttr = NSAttributeDescription()
        investmentStrategyDateAttr.name = "investmentStrategyDate"
        investmentStrategyDateAttr.attributeType = .dateAttributeType
        investmentStrategyDateAttr.isOptional = false
        
        let lastAuditDateAttr = NSAttributeDescription()
        lastAuditDateAttr.name = "lastAuditDate"
        lastAuditDateAttr.attributeType = .dateAttributeType
        lastAuditDateAttr.isOptional = true
        
        let nextAuditDueDateAttr = NSAttributeDescription()
        nextAuditDueDateAttr.name = "nextAuditDueDate"
        nextAuditDueDateAttr.attributeType = .dateAttributeType
        nextAuditDueDateAttr.isOptional = false
        
        // Create CrossEntityTransaction entity
        let crossEntityTransactionEntity = NSEntityDescription()
        crossEntityTransactionEntity.name = "CrossEntityTransaction"
        crossEntityTransactionEntity.managedObjectClassName = "CrossEntityTransaction"
        
        // CrossEntityTransaction attributes
        let crossTxnIdAttr = NSAttributeDescription()
        crossTxnIdAttr.name = "id"
        crossTxnIdAttr.attributeType = .UUIDAttributeType
        crossTxnIdAttr.isOptional = false
        
        let fromEntityIdAttr = NSAttributeDescription()
        fromEntityIdAttr.name = "fromEntityId"
        fromEntityIdAttr.attributeType = .UUIDAttributeType
        fromEntityIdAttr.isOptional = false
        
        let toEntityIdAttr = NSAttributeDescription()
        toEntityIdAttr.name = "toEntityId"
        toEntityIdAttr.attributeType = .UUIDAttributeType
        toEntityIdAttr.isOptional = false
        
        let crossAmountAttr = NSAttributeDescription()
        crossAmountAttr.name = "amount"
        crossAmountAttr.attributeType = .doubleAttributeType
        crossAmountAttr.isOptional = false
        
        let crossDescriptionAttr = NSAttributeDescription()
        crossDescriptionAttr.name = "description"
        crossDescriptionAttr.attributeType = .stringAttributeType
        crossDescriptionAttr.isOptional = false
        
        let transactionDateAttr = NSAttributeDescription()
        transactionDateAttr.name = "transactionDate"
        transactionDateAttr.attributeType = .dateAttributeType
        transactionDateAttr.isOptional = false
        
        let transactionTypeAttr = NSAttributeDescription()
        transactionTypeAttr.name = "transactionType"
        transactionTypeAttr.attributeType = .stringAttributeType
        transactionTypeAttr.isOptional = false
        
        let auditTrailAttr = NSAttributeDescription()
        auditTrailAttr.name = "auditTrail"
        auditTrailAttr.attributeType = .binaryDataAttributeType
        auditTrailAttr.isOptional = true
        
        // Create relationships
        // Transaction -> FinancialEntity (many-to-one)
        let transactionToEntityRelationship = NSRelationshipDescription()
        transactionToEntityRelationship.name = "entity"
        transactionToEntityRelationship.destinationEntity = financialEntityEntity
        transactionToEntityRelationship.minCount = 1
        transactionToEntityRelationship.maxCount = 1
        transactionToEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // FinancialEntity -> Transactions (one-to-many)
        let entityToTransactionsRelationship = NSRelationshipDescription()
        entityToTransactionsRelationship.name = "transactions"
        entityToTransactionsRelationship.destinationEntity = transactionEntity
        entityToTransactionsRelationship.minCount = 0
        entityToTransactionsRelationship.maxCount = 0
        entityToTransactionsRelationship.deleteRule = .cascadeDeleteRule
        
        // FinancialEntity -> ChildEntities (one-to-many)
        let entityToChildEntitiesRelationship = NSRelationshipDescription()
        entityToChildEntitiesRelationship.name = "childEntities"
        entityToChildEntitiesRelationship.destinationEntity = financialEntityEntity
        entityToChildEntitiesRelationship.minCount = 0
        entityToChildEntitiesRelationship.maxCount = 0
        entityToChildEntitiesRelationship.deleteRule = .nullifyDeleteRule // Changed to nullify to orphan children
        
        // FinancialEntity -> ParentEntity (many-to-one)
        let entityToParentEntityRelationship = NSRelationshipDescription()
        entityToParentEntityRelationship.name = "parentEntity"
        entityToParentEntityRelationship.destinationEntity = financialEntityEntity
        entityToParentEntityRelationship.minCount = 0
        entityToParentEntityRelationship.maxCount = 1
        entityToParentEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // FinancialEntity -> CrossEntityTransactions (one-to-many)
        let entityToCrossTransactionsRelationship = NSRelationshipDescription()
        entityToCrossTransactionsRelationship.name = "crossEntityTransactions"
        entityToCrossTransactionsRelationship.destinationEntity = crossEntityTransactionEntity
        entityToCrossTransactionsRelationship.minCount = 0
        entityToCrossTransactionsRelationship.maxCount = 0
        entityToCrossTransactionsRelationship.deleteRule = .cascadeDeleteRule
        
        // FinancialEntity -> SMSFEntityDetails (one-to-one)
        let entityToSMSFDetailsRelationship = NSRelationshipDescription()
        entityToSMSFDetailsRelationship.name = "smsfDetails"
        entityToSMSFDetailsRelationship.destinationEntity = smsfDetailsEntity
        entityToSMSFDetailsRelationship.minCount = 0
        entityToSMSFDetailsRelationship.maxCount = 1
        entityToSMSFDetailsRelationship.deleteRule = .cascadeDeleteRule
        
        // SMSFEntityDetails -> FinancialEntity (one-to-one)
        let smsfDetailsToEntityRelationship = NSRelationshipDescription()
        smsfDetailsToEntityRelationship.name = "entity"
        smsfDetailsToEntityRelationship.destinationEntity = financialEntityEntity
        smsfDetailsToEntityRelationship.minCount = 1
        smsfDetailsToEntityRelationship.maxCount = 1
        smsfDetailsToEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // CrossEntityTransaction -> FromEntity (many-to-one)
        let crossTxnToFromEntityRelationship = NSRelationshipDescription()
        crossTxnToFromEntityRelationship.name = "fromEntity"
        crossTxnToFromEntityRelationship.destinationEntity = financialEntityEntity
        crossTxnToFromEntityRelationship.minCount = 1
        crossTxnToFromEntityRelationship.maxCount = 1
        crossTxnToFromEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // CrossEntityTransaction -> ToEntity (many-to-one)
        let crossTxnToToEntityRelationship = NSRelationshipDescription()
        crossTxnToToEntityRelationship.name = "toEntity"
        crossTxnToToEntityRelationship.destinationEntity = financialEntityEntity
        crossTxnToToEntityRelationship.minCount = 1
        crossTxnToToEntityRelationship.maxCount = 1
        crossTxnToToEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // Set up inverse relationships
        transactionToEntityRelationship.inverseRelationship = entityToTransactionsRelationship
        entityToTransactionsRelationship.inverseRelationship = transactionToEntityRelationship
        entityToSMSFDetailsRelationship.inverseRelationship = smsfDetailsToEntityRelationship
        smsfDetailsToEntityRelationship.inverseRelationship = entityToSMSFDetailsRelationship
        
        // Set up parent-child entity relationships
        entityToChildEntitiesRelationship.inverseRelationship = entityToParentEntityRelationship
        entityToParentEntityRelationship.inverseRelationship = entityToChildEntitiesRelationship
        
        // Update entity properties
        financialEntityEntity.properties = [
            entityIdAttr,
            entityNameAttr,
            entityTypeAttr,
            isActiveAttr,
            createdAtAttr,
            lastModifiedAttr,
            entityDescriptionAttr,
            colorCodeAttr,
            entityToTransactionsRelationship,
            entityToChildEntitiesRelationship,
            entityToParentEntityRelationship,
            entityToCrossTransactionsRelationship,
            entityToSMSFDetailsRelationship
        ]
        
        smsfDetailsEntity.properties = [
            smsfIdAttr,
            smsfAbnAttr,
            trustDeedDateAttr,
            investmentStrategyDateAttr,
            lastAuditDateAttr,
            nextAuditDueDateAttr,
            smsfDetailsToEntityRelationship
        ]
        
        crossEntityTransactionEntity.properties = [
            crossTxnIdAttr,
            fromEntityIdAttr,
            toEntityIdAttr,
            crossAmountAttr,
            crossDescriptionAttr,
            transactionDateAttr,
            transactionTypeAttr,
            auditTrailAttr,
            crossTxnToFromEntityRelationship,
            crossTxnToToEntityRelationship
        ]
        
        // Create BankAccount entity
        let bankAccountEntity = NSEntityDescription()
        bankAccountEntity.name = "BankAccount"
        bankAccountEntity.managedObjectClassName = "BankAccount"
        
        // BankAccount attributes
        let bankAccountIdAttr = NSAttributeDescription()
        bankAccountIdAttr.name = "id"
        bankAccountIdAttr.attributeType = .UUIDAttributeType
        bankAccountIdAttr.isOptional = false
        
        let bankNameAttr = NSAttributeDescription()
        bankNameAttr.name = "bankName"
        bankNameAttr.attributeType = .stringAttributeType
        bankNameAttr.isOptional = false
        
        let accountNumberAttr = NSAttributeDescription()
        accountNumberAttr.name = "accountNumber"
        accountNumberAttr.attributeType = .stringAttributeType
        accountNumberAttr.isOptional = false
        
        let accountTypeAttr = NSAttributeDescription()
        accountTypeAttr.name = "accountType"
        accountTypeAttr.attributeType = .stringAttributeType
        accountTypeAttr.isOptional = false
        
        let isActiveAccountAttr = NSAttributeDescription()
        isActiveAccountAttr.name = "isActive"
        isActiveAccountAttr.attributeType = .booleanAttributeType
        isActiveAccountAttr.isOptional = false
        
        let lastSyncDateAttr = NSAttributeDescription()
        lastSyncDateAttr.name = "lastSyncDate"
        lastSyncDateAttr.attributeType = .dateAttributeType
        lastSyncDateAttr.isOptional = true
        
        let createdAtAccountAttr = NSAttributeDescription()
        createdAtAccountAttr.name = "createdAt"
        createdAtAccountAttr.attributeType = .dateAttributeType
        createdAtAccountAttr.isOptional = false
        
        let lastModifiedAccountAttr = NSAttributeDescription()
        lastModifiedAccountAttr.name = "lastModified"
        lastModifiedAccountAttr.attributeType = .dateAttributeType
        lastModifiedAccountAttr.isOptional = false
        
        let basiqAccountIdAttr = NSAttributeDescription()
        basiqAccountIdAttr.name = "basiqAccountId"
        basiqAccountIdAttr.attributeType = .stringAttributeType
        basiqAccountIdAttr.isOptional = true
        
        let encryptedCredentialsAttr = NSAttributeDescription()
        encryptedCredentialsAttr.name = "encryptedCredentials"
        encryptedCredentialsAttr.attributeType = .binaryDataAttributeType
        encryptedCredentialsAttr.isOptional = true
        
        let connectionStatusAttr = NSAttributeDescription()
        connectionStatusAttr.name = "connectionStatus"
        connectionStatusAttr.attributeType = .stringAttributeType
        connectionStatusAttr.isOptional = false
        
        let errorMessageAttr = NSAttributeDescription()
        errorMessageAttr.name = "errorMessage"
        errorMessageAttr.attributeType = .stringAttributeType
        errorMessageAttr.isOptional = true
        
        // BankAccount -> FinancialEntity (many-to-one)
        let bankAccountToEntityRelationship = NSRelationshipDescription()
        bankAccountToEntityRelationship.name = "financialEntity"
        bankAccountToEntityRelationship.destinationEntity = financialEntityEntity
        bankAccountToEntityRelationship.minCount = 0
        bankAccountToEntityRelationship.maxCount = 1
        bankAccountToEntityRelationship.deleteRule = .nullifyDeleteRule
        
        // BankAccount -> Transactions (one-to-many)
        let bankAccountToTransactionsRelationship = NSRelationshipDescription()
        bankAccountToTransactionsRelationship.name = "transactions"
        bankAccountToTransactionsRelationship.destinationEntity = transactionEntity
        bankAccountToTransactionsRelationship.minCount = 0
        bankAccountToTransactionsRelationship.maxCount = 0
        bankAccountToTransactionsRelationship.deleteRule = .nullifyDeleteRule
        
        // FinancialEntity -> BankAccounts (one-to-many)
        let entityToBankAccountsRelationship = NSRelationshipDescription()
        entityToBankAccountsRelationship.name = "bankAccounts"
        entityToBankAccountsRelationship.destinationEntity = bankAccountEntity
        entityToBankAccountsRelationship.minCount = 0
        entityToBankAccountsRelationship.maxCount = 0
        entityToBankAccountsRelationship.deleteRule = .nullifyDeleteRule
        
        // Transaction -> BankAccount (many-to-one)
        let transactionToBankAccountRelationship = NSRelationshipDescription()
        transactionToBankAccountRelationship.name = "bankAccount"
        transactionToBankAccountRelationship.destinationEntity = bankAccountEntity
        transactionToBankAccountRelationship.minCount = 0
        transactionToBankAccountRelationship.maxCount = 1
        transactionToBankAccountRelationship.deleteRule = .nullifyDeleteRule
        
        // Set up inverse relationships
        bankAccountToEntityRelationship.inverseRelationship = entityToBankAccountsRelationship
        entityToBankAccountsRelationship.inverseRelationship = bankAccountToEntityRelationship
        bankAccountToTransactionsRelationship.inverseRelationship = transactionToBankAccountRelationship
        transactionToBankAccountRelationship.inverseRelationship = bankAccountToTransactionsRelationship
        
        // Set BankAccount properties
        bankAccountEntity.properties = [
            bankAccountIdAttr,
            bankNameAttr,
            accountNumberAttr,
            accountTypeAttr,
            isActiveAccountAttr,
            lastSyncDateAttr,
            createdAtAccountAttr,
            lastModifiedAccountAttr,
            basiqAccountIdAttr,
            encryptedCredentialsAttr,
            connectionStatusAttr,
            errorMessageAttr,
            bankAccountToEntityRelationship,
            bankAccountToTransactionsRelationship
        ]
        
        // Add entity relationship to transaction
        transactionEntity.properties.append(transactionToEntityRelationship)
        transactionEntity.properties.append(transactionToBankAccountRelationship)
        
        // Add bank accounts relationship to financial entity
        financialEntityEntity.properties.append(entityToBankAccountsRelationship)
        
        // Create User entity
        let userEntity = NSEntityDescription()
        userEntity.name = "User"
        userEntity.managedObjectClassName = "User"
        
        // User attributes
        let userIdAttr = NSAttributeDescription()
        userIdAttr.name = "id"
        userIdAttr.attributeType = .UUIDAttributeType
        userIdAttr.isOptional = false
        
        let userNameAttr = NSAttributeDescription()
        userNameAttr.name = "name"
        userNameAttr.attributeType = .stringAttributeType
        userNameAttr.isOptional = false
        
        let emailAttr = NSAttributeDescription()
        emailAttr.name = "email"
        emailAttr.attributeType = .stringAttributeType
        emailAttr.isOptional = false
        
        let roleAttr = NSAttributeDescription()
        roleAttr.name = "role"
        roleAttr.attributeType = .stringAttributeType
        roleAttr.isOptional = false
        
        let userCreatedAtAttr = NSAttributeDescription()
        userCreatedAtAttr.name = "createdAt"
        userCreatedAtAttr.attributeType = .dateAttributeType
        userCreatedAtAttr.isOptional = false
        
        let lastLoginAtAttr = NSAttributeDescription()
        lastLoginAtAttr.name = "lastLoginAt"
        lastLoginAtAttr.attributeType = .dateAttributeType
        lastLoginAtAttr.isOptional = true
        
        let userIsActiveAttr = NSAttributeDescription()
        userIsActiveAttr.name = "isActive"
        userIsActiveAttr.attributeType = .booleanAttributeType
        userIsActiveAttr.isOptional = false
        
        let profileImageURLAttr = NSAttributeDescription()
        profileImageURLAttr.name = "profileImageURL"
        profileImageURLAttr.attributeType = .stringAttributeType
        profileImageURLAttr.isOptional = true
        
        let phoneNumberAttr = NSAttributeDescription()
        phoneNumberAttr.name = "phoneNumber"
        phoneNumberAttr.attributeType = .stringAttributeType
        phoneNumberAttr.isOptional = true
        
        let preferredCurrencyAttr = NSAttributeDescription()
        preferredCurrencyAttr.name = "preferredCurrency"
        preferredCurrencyAttr.attributeType = .stringAttributeType
        preferredCurrencyAttr.isOptional = true
        
        let timezoneAttr = NSAttributeDescription()
        timezoneAttr.name = "timezone"
        timezoneAttr.attributeType = .stringAttributeType
        timezoneAttr.isOptional = true
        
        // Create AuditLog entity
        let auditLogEntity = NSEntityDescription()
        auditLogEntity.name = "AuditLog"
        auditLogEntity.managedObjectClassName = "AuditLog"
        
        // AuditLog attributes
        let auditLogIdAttr = NSAttributeDescription()
        auditLogIdAttr.name = "id"
        auditLogIdAttr.attributeType = .UUIDAttributeType
        auditLogIdAttr.isOptional = false
        
        let userIdRefAttr = NSAttributeDescription()
        userIdRefAttr.name = "userId"
        userIdRefAttr.attributeType = .UUIDAttributeType
        userIdRefAttr.isOptional = false
        
        let actionAttr = NSAttributeDescription()
        actionAttr.name = "action"
        actionAttr.attributeType = .stringAttributeType
        actionAttr.isOptional = false
        
        let resourceTypeAttr = NSAttributeDescription()
        resourceTypeAttr.name = "resourceType"
        resourceTypeAttr.attributeType = .stringAttributeType
        resourceTypeAttr.isOptional = false
        
        let resourceIdAttr = NSAttributeDescription()
        resourceIdAttr.name = "resourceId"
        resourceIdAttr.attributeType = .UUIDAttributeType
        resourceIdAttr.isOptional = true
        
        let resultAttr = NSAttributeDescription()
        resultAttr.name = "result"
        resultAttr.attributeType = .stringAttributeType
        resultAttr.isOptional = false
        
        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false
        
        let detailsAttr = NSAttributeDescription()
        detailsAttr.name = "details"
        detailsAttr.attributeType = .stringAttributeType
        detailsAttr.isOptional = true
        
        let ipAddressAttr = NSAttributeDescription()
        ipAddressAttr.name = "ipAddress"
        ipAddressAttr.attributeType = .stringAttributeType
        ipAddressAttr.isOptional = true
        
        let userAgentAttr = NSAttributeDescription()
        userAgentAttr.name = "userAgent"
        userAgentAttr.attributeType = .stringAttributeType
        userAgentAttr.isOptional = true
        
        // User -> FinancialEntities (one-to-many)
        let userToOwnedEntitiesRelationship = NSRelationshipDescription()
        userToOwnedEntitiesRelationship.name = "ownedEntities"
        userToOwnedEntitiesRelationship.destinationEntity = financialEntityEntity
        userToOwnedEntitiesRelationship.minCount = 0
        userToOwnedEntitiesRelationship.maxCount = 0
        userToOwnedEntitiesRelationship.deleteRule = .nullifyDeleteRule
        
        // FinancialEntity -> User (many-to-one)
        let entityToOwnerRelationship = NSRelationshipDescription()
        entityToOwnerRelationship.name = "owner"
        entityToOwnerRelationship.destinationEntity = userEntity
        entityToOwnerRelationship.minCount = 0
        entityToOwnerRelationship.maxCount = 1
        entityToOwnerRelationship.deleteRule = .nullifyDeleteRule
        
        // User -> AuditLogs (one-to-many)
        let userToAuditLogsRelationship = NSRelationshipDescription()
        userToAuditLogsRelationship.name = "auditLogs"
        userToAuditLogsRelationship.destinationEntity = auditLogEntity
        userToAuditLogsRelationship.minCount = 0
        userToAuditLogsRelationship.maxCount = 0
        userToAuditLogsRelationship.deleteRule = .cascadeDeleteRule
        
        // AuditLog -> User (many-to-one)
        let auditLogToUserRelationship = NSRelationshipDescription()
        auditLogToUserRelationship.name = "user"
        auditLogToUserRelationship.destinationEntity = userEntity
        auditLogToUserRelationship.minCount = 0
        auditLogToUserRelationship.maxCount = 1
        auditLogToUserRelationship.deleteRule = .nullifyDeleteRule
        
        // Set up inverse relationships
        userToOwnedEntitiesRelationship.inverseRelationship = entityToOwnerRelationship
        entityToOwnerRelationship.inverseRelationship = userToOwnedEntitiesRelationship
        userToAuditLogsRelationship.inverseRelationship = auditLogToUserRelationship
        auditLogToUserRelationship.inverseRelationship = userToAuditLogsRelationship
        
        // Set User properties
        userEntity.properties = [
            userIdAttr,
            userNameAttr,
            emailAttr,
            roleAttr,
            userCreatedAtAttr,
            lastLoginAtAttr,
            userIsActiveAttr,
            profileImageURLAttr,
            phoneNumberAttr,
            preferredCurrencyAttr,
            timezoneAttr,
            userToOwnedEntitiesRelationship,
            userToAuditLogsRelationship
        ]
        
        // Set AuditLog properties
        auditLogEntity.properties = [
            auditLogIdAttr,
            userIdRefAttr,
            actionAttr,
            resourceTypeAttr,
            resourceIdAttr,
            resultAttr,
            timestampAttr,
            detailsAttr,
            ipAddressAttr,
            userAgentAttr,
            auditLogToUserRelationship
        ]
        
        // Add owner relationship to financial entity
        financialEntityEntity.properties.append(entityToOwnerRelationship)
        
        model.entities = [
            transactionEntity, 
            lineItemEntity, 
            splitAllocationEntity,
            financialEntityEntity,
            smsfDetailsEntity,
            crossEntityTransactionEntity,
            bankAccountEntity,
            userEntity,
            auditLogEntity
        ]

        // Use only the programmatic model, not the .xcdatamodeld file
        container = NSPersistentContainer(name: "FinanceMateDataStore", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { [container] description, error in
            if let error = error as NSError? {
                // Check if this is a migration error
                if error.code == 134110 { // NSMigrationError
                    print("Core Data migration error detected. Attempting to recreate store...")
                    
                    // Delete the existing store file and try again
                    if let storeURL = description.url {
                        do {
                            try FileManager.default.removeItem(at: storeURL)
                            // Also remove associated files
                            let shmURL = storeURL.appendingPathExtension("sqlite-shm")
                            let walURL = storeURL.appendingPathExtension("sqlite-wal")
                            try? FileManager.default.removeItem(at: shmURL)
                            try? FileManager.default.removeItem(at: walURL)
                            
                            // Try loading again
                            container.loadPersistentStores { _, retryError in
                                if let retryError = retryError {
                                    fatalError("Failed to recreate Core Data store: \(retryError)")
                                }
                            }
                            return
                        } catch {
                            print("Could not delete existing store: \(error)")
                        }
                    }
                }
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
