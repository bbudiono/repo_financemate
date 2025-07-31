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

    lineItemEntity.properties = [
      lineItemIdAttribute, itemDescriptionAttribute, lineItemAmountAttribute,
    ]

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

    splitAllocationEntity.properties = [
      splitIdAttribute, percentageAttribute, taxCategoryAttribute,
    ]

    // Create relationships
    // Transaction -> LineItems (one-to-many)
    let transactionToLineItemsRelationship = NSRelationshipDescription()
    transactionToLineItemsRelationship.name = "lineItems"
    transactionToLineItemsRelationship.destinationEntity = lineItemEntity
    transactionToLineItemsRelationship.minCount = 0
    transactionToLineItemsRelationship.maxCount = 0  // 0 means unlimited for to-many
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
    lineItemToSplitAllocationsRelationship.maxCount = 0  // 0 means unlimited for to-many
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
    lineItemToSplitAllocationsRelationship.inverseRelationship =
      splitAllocationToLineItemRelationship
    splitAllocationToLineItemRelationship.inverseRelationship =
      lineItemToSplitAllocationsRelationship

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
    transactionToEntityRelationship.name = "assignedEntity"
    transactionToEntityRelationship.destinationEntity = financialEntityEntity
    transactionToEntityRelationship.minCount = 0  // Make optional
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
    entityToChildEntitiesRelationship.deleteRule = .nullifyDeleteRule  // Changed to nullify to orphan children

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
      entityToSMSFDetailsRelationship,
    ]

    smsfDetailsEntity.properties = [
      smsfIdAttr,
      smsfAbnAttr,
      trustDeedDateAttr,
      investmentStrategyDateAttr,
      lastAuditDateAttr,
      nextAuditDueDateAttr,
      smsfDetailsToEntityRelationship,
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
      crossTxnToToEntityRelationship,
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
      bankAccountToTransactionsRelationship,
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
      userToAuditLogsRelationship,
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
      auditLogToUserRelationship,
    ]

    // Add owner relationship to financial entity
    financialEntityEntity.properties.append(entityToOwnerRelationship)

    // Create WealthSnapshot entity (Phase 4 - P4-001)
    let wealthSnapshotEntity = NSEntityDescription()
    wealthSnapshotEntity.name = "WealthSnapshot"
    wealthSnapshotEntity.managedObjectClassName = "WealthSnapshot"

    // WealthSnapshot attributes
    let wealthSnapshotIdAttr = NSAttributeDescription()
    wealthSnapshotIdAttr.name = "id"
    wealthSnapshotIdAttr.attributeType = .UUIDAttributeType
    wealthSnapshotIdAttr.isOptional = false

    let wealthDateAttr = NSAttributeDescription()
    wealthDateAttr.name = "date"
    wealthDateAttr.attributeType = .dateAttributeType
    wealthDateAttr.isOptional = false

    let totalAssetsAttr = NSAttributeDescription()
    totalAssetsAttr.name = "totalAssets"
    totalAssetsAttr.attributeType = .doubleAttributeType
    totalAssetsAttr.isOptional = false

    let totalLiabilitiesAttr = NSAttributeDescription()
    totalLiabilitiesAttr.name = "totalLiabilities"
    totalLiabilitiesAttr.attributeType = .doubleAttributeType
    totalLiabilitiesAttr.isOptional = false

    let netWorthAttr = NSAttributeDescription()
    netWorthAttr.name = "netWorth"
    netWorthAttr.attributeType = .doubleAttributeType
    netWorthAttr.isOptional = false

    let cashPositionAttr = NSAttributeDescription()
    cashPositionAttr.name = "cashPosition"
    cashPositionAttr.attributeType = .doubleAttributeType
    cashPositionAttr.isOptional = false

    let investmentValueAttr = NSAttributeDescription()
    investmentValueAttr.name = "investmentValue"
    investmentValueAttr.attributeType = .doubleAttributeType
    investmentValueAttr.isOptional = false

    let propertyValueAttr = NSAttributeDescription()
    propertyValueAttr.name = "propertyValue"
    propertyValueAttr.attributeType = .doubleAttributeType
    propertyValueAttr.isOptional = false

    let wealthCreatedAtAttr = NSAttributeDescription()
    wealthCreatedAtAttr.name = "createdAt"
    wealthCreatedAtAttr.attributeType = .dateAttributeType
    wealthCreatedAtAttr.isOptional = false

    // Create AssetAllocation entity
    let assetAllocationEntity = NSEntityDescription()
    assetAllocationEntity.name = "AssetAllocation"
    assetAllocationEntity.managedObjectClassName = "AssetAllocation"

    // AssetAllocation attributes
    let assetAllocationIdAttr = NSAttributeDescription()
    assetAllocationIdAttr.name = "id"
    assetAllocationIdAttr.attributeType = .UUIDAttributeType
    assetAllocationIdAttr.isOptional = false

    let assetClassAttr = NSAttributeDescription()
    assetClassAttr.name = "assetClass"
    assetClassAttr.attributeType = .stringAttributeType
    assetClassAttr.isOptional = false

    let allocationAttr = NSAttributeDescription()
    allocationAttr.name = "allocation"
    allocationAttr.attributeType = .doubleAttributeType
    allocationAttr.isOptional = false

    let targetAllocationAttr = NSAttributeDescription()
    targetAllocationAttr.name = "targetAllocation"
    targetAllocationAttr.attributeType = .doubleAttributeType
    targetAllocationAttr.isOptional = false

    let currentValueAttr = NSAttributeDescription()
    currentValueAttr.name = "currentValue"
    currentValueAttr.attributeType = .doubleAttributeType
    currentValueAttr.isOptional = false

    let lastUpdatedAttr = NSAttributeDescription()
    lastUpdatedAttr.name = "lastUpdated"
    lastUpdatedAttr.attributeType = .dateAttributeType
    lastUpdatedAttr.isOptional = false

    // Create PerformanceMetrics entity
    let performanceMetricsEntity = NSEntityDescription()
    performanceMetricsEntity.name = "PerformanceMetrics"
    performanceMetricsEntity.managedObjectClassName = "PerformanceMetrics"

    // PerformanceMetrics attributes
    let performanceMetricsIdAttr = NSAttributeDescription()
    performanceMetricsIdAttr.name = "id"
    performanceMetricsIdAttr.attributeType = .UUIDAttributeType
    performanceMetricsIdAttr.isOptional = false

    let metricTypeAttr = NSAttributeDescription()
    metricTypeAttr.name = "metricType"
    metricTypeAttr.attributeType = .stringAttributeType
    metricTypeAttr.isOptional = false

    let valueAttr = NSAttributeDescription()
    valueAttr.name = "value"
    valueAttr.attributeType = .doubleAttributeType
    valueAttr.isOptional = false

    let benchmarkValueAttr = NSAttributeDescription()
    benchmarkValueAttr.name = "benchmarkValue"
    benchmarkValueAttr.attributeType = .doubleAttributeType
    benchmarkValueAttr.isOptional = false

    let periodAttr = NSAttributeDescription()
    periodAttr.name = "period"
    periodAttr.attributeType = .stringAttributeType
    periodAttr.isOptional = false

    let calculatedAtAttr = NSAttributeDescription()
    calculatedAtAttr.name = "calculatedAt"
    calculatedAtAttr.attributeType = .dateAttributeType
    calculatedAtAttr.isOptional = false

    // Create relationships
    // WealthSnapshot -> AssetAllocations (one-to-many)
    let wealthSnapshotToAssetAllocationsRelationship = NSRelationshipDescription()
    wealthSnapshotToAssetAllocationsRelationship.name = "assetAllocations"
    wealthSnapshotToAssetAllocationsRelationship.destinationEntity = assetAllocationEntity
    wealthSnapshotToAssetAllocationsRelationship.minCount = 0
    wealthSnapshotToAssetAllocationsRelationship.maxCount = 0
    wealthSnapshotToAssetAllocationsRelationship.deleteRule = .cascadeDeleteRule

    // AssetAllocation -> WealthSnapshot (many-to-one)
    let assetAllocationToWealthSnapshotRelationship = NSRelationshipDescription()
    assetAllocationToWealthSnapshotRelationship.name = "wealthSnapshot"
    assetAllocationToWealthSnapshotRelationship.destinationEntity = wealthSnapshotEntity
    assetAllocationToWealthSnapshotRelationship.minCount = 1
    assetAllocationToWealthSnapshotRelationship.maxCount = 1
    assetAllocationToWealthSnapshotRelationship.deleteRule = .nullifyDeleteRule

    // WealthSnapshot -> PerformanceMetrics (one-to-many)
    let wealthSnapshotToPerformanceMetricsRelationship = NSRelationshipDescription()
    wealthSnapshotToPerformanceMetricsRelationship.name = "performanceMetrics"
    wealthSnapshotToPerformanceMetricsRelationship.destinationEntity = performanceMetricsEntity
    wealthSnapshotToPerformanceMetricsRelationship.minCount = 0
    wealthSnapshotToPerformanceMetricsRelationship.maxCount = 0
    wealthSnapshotToPerformanceMetricsRelationship.deleteRule = .cascadeDeleteRule

    // PerformanceMetrics -> WealthSnapshot (many-to-one)
    let performanceMetricsToWealthSnapshotRelationship = NSRelationshipDescription()
    performanceMetricsToWealthSnapshotRelationship.name = "wealthSnapshot"
    performanceMetricsToWealthSnapshotRelationship.destinationEntity = wealthSnapshotEntity
    performanceMetricsToWealthSnapshotRelationship.minCount = 1
    performanceMetricsToWealthSnapshotRelationship.maxCount = 1
    performanceMetricsToWealthSnapshotRelationship.deleteRule = .nullifyDeleteRule

    // Set up inverse relationships
    wealthSnapshotToAssetAllocationsRelationship.inverseRelationship =
      assetAllocationToWealthSnapshotRelationship
    assetAllocationToWealthSnapshotRelationship.inverseRelationship =
      wealthSnapshotToAssetAllocationsRelationship
    wealthSnapshotToPerformanceMetricsRelationship.inverseRelationship =
      performanceMetricsToWealthSnapshotRelationship
    performanceMetricsToWealthSnapshotRelationship.inverseRelationship =
      wealthSnapshotToPerformanceMetricsRelationship

    // Set entity properties
    wealthSnapshotEntity.properties = [
      wealthSnapshotIdAttr,
      wealthDateAttr,
      totalAssetsAttr,
      totalLiabilitiesAttr,
      netWorthAttr,
      cashPositionAttr,
      investmentValueAttr,
      propertyValueAttr,
      wealthCreatedAtAttr,
      wealthSnapshotToAssetAllocationsRelationship,
      wealthSnapshotToPerformanceMetricsRelationship,
    ]

    assetAllocationEntity.properties = [
      assetAllocationIdAttr,
      assetClassAttr,
      allocationAttr,
      targetAllocationAttr,
      currentValueAttr,
      lastUpdatedAttr,
      assetAllocationToWealthSnapshotRelationship,
    ]

    performanceMetricsEntity.properties = [
      performanceMetricsIdAttr,
      metricTypeAttr,
      valueAttr,
      benchmarkValueAttr,
      periodAttr,
      calculatedAtAttr,
      performanceMetricsToWealthSnapshotRelationship,
    ]

    // Create FinancialGoal entity (Phase 4 - P4-003)
    let financialGoalEntity = NSEntityDescription()
    financialGoalEntity.name = "FinancialGoal"
    financialGoalEntity.managedObjectClassName = "FinancialGoal"

    // FinancialGoal attributes
    let goalIdAttr = NSAttributeDescription()
    goalIdAttr.name = "id"
    goalIdAttr.attributeType = .UUIDAttributeType
    goalIdAttr.isOptional = false

    let goalTitleAttr = NSAttributeDescription()
    goalTitleAttr.name = "title"
    goalTitleAttr.attributeType = .stringAttributeType
    goalTitleAttr.isOptional = false

    let goalDescriptionAttr = NSAttributeDescription()
    goalDescriptionAttr.name = "description_text"
    goalDescriptionAttr.attributeType = .stringAttributeType
    goalDescriptionAttr.isOptional = true

    let targetAmountAttr = NSAttributeDescription()
    targetAmountAttr.name = "targetAmount"
    targetAmountAttr.attributeType = .doubleAttributeType
    targetAmountAttr.isOptional = false

    let currentAmountAttr = NSAttributeDescription()
    currentAmountAttr.name = "currentAmount"
    currentAmountAttr.attributeType = .doubleAttributeType
    currentAmountAttr.isOptional = false

    let targetDateAttr = NSAttributeDescription()
    targetDateAttr.name = "targetDate"
    targetDateAttr.attributeType = .dateAttributeType
    targetDateAttr.isOptional = false

    let goalCategoryAttr = NSAttributeDescription()
    goalCategoryAttr.name = "category"
    goalCategoryAttr.attributeType = .stringAttributeType
    goalCategoryAttr.isOptional = false

    let goalPriorityAttr = NSAttributeDescription()
    goalPriorityAttr.name = "priority"
    goalPriorityAttr.attributeType = .stringAttributeType
    goalPriorityAttr.isOptional = false

    let goalStatusAttr = NSAttributeDescription()
    goalStatusAttr.name = "status"
    goalStatusAttr.attributeType = .stringAttributeType
    goalStatusAttr.isOptional = false

    let goalCreatedAtAttr = NSAttributeDescription()
    goalCreatedAtAttr.name = "createdAt"
    goalCreatedAtAttr.attributeType = .dateAttributeType
    goalCreatedAtAttr.isOptional = false

    let goalLastModifiedAttr = NSAttributeDescription()
    goalLastModifiedAttr.name = "lastModified"
    goalLastModifiedAttr.attributeType = .dateAttributeType
    goalLastModifiedAttr.isOptional = false

    let isCompletedAttr = NSAttributeDescription()
    isCompletedAttr.name = "isCompleted"
    isCompletedAttr.attributeType = .booleanAttributeType
    isCompletedAttr.isOptional = false

    let completionDateAttr = NSAttributeDescription()
    completionDateAttr.name = "completionDate"
    completionDateAttr.attributeType = .dateAttributeType
    completionDateAttr.isOptional = true

    let progressPercentageAttr = NSAttributeDescription()
    progressPercentageAttr.name = "progressPercentage"
    progressPercentageAttr.attributeType = .doubleAttributeType
    progressPercentageAttr.isOptional = false

    let monthlySavingsRequiredAttr = NSAttributeDescription()
    monthlySavingsRequiredAttr.name = "monthlySavingsRequired"
    monthlySavingsRequiredAttr.attributeType = .doubleAttributeType
    monthlySavingsRequiredAttr.isOptional = false

    let dailySavingsRequiredAttr = NSAttributeDescription()
    dailySavingsRequiredAttr.name = "dailySavingsRequired"
    dailySavingsRequiredAttr.attributeType = .doubleAttributeType
    dailySavingsRequiredAttr.isOptional = false

    let progressVelocityAttr = NSAttributeDescription()
    progressVelocityAttr.name = "progressVelocity"
    progressVelocityAttr.attributeType = .doubleAttributeType
    progressVelocityAttr.isOptional = false

    let isOnTrackAttr = NSAttributeDescription()
    isOnTrackAttr.name = "isOnTrack"
    isOnTrackAttr.attributeType = .booleanAttributeType
    isOnTrackAttr.isOptional = false

    let isOverdueAttr = NSAttributeDescription()
    isOverdueAttr.name = "isOverdue"
    isOverdueAttr.attributeType = .booleanAttributeType
    isOverdueAttr.isOptional = false

    let daysRemainingAttr = NSAttributeDescription()
    daysRemainingAttr.name = "daysRemaining"
    daysRemainingAttr.attributeType = .integer32AttributeType
    daysRemainingAttr.isOptional = false

    let isLongTermGoalAttr = NSAttributeDescription()
    isLongTermGoalAttr.name = "isLongTermGoal"
    isLongTermGoalAttr.attributeType = .booleanAttributeType
    isLongTermGoalAttr.isOptional = false

    let isSpecificAttr = NSAttributeDescription()
    isSpecificAttr.name = "isSpecific"
    isSpecificAttr.attributeType = .booleanAttributeType
    isSpecificAttr.isOptional = false

    let isMeasurableAttr = NSAttributeDescription()
    isMeasurableAttr.name = "isMeasurable"
    isMeasurableAttr.attributeType = .booleanAttributeType
    isMeasurableAttr.isOptional = false

    let isAchievableAttr = NSAttributeDescription()
    isAchievableAttr.name = "isAchievable"
    isAchievableAttr.attributeType = .booleanAttributeType
    isAchievableAttr.isOptional = false

    let isRelevantAttr = NSAttributeDescription()
    isRelevantAttr.name = "isRelevant"
    isRelevantAttr.attributeType = .booleanAttributeType
    isRelevantAttr.isOptional = false

    let isTimeBoundAttr = NSAttributeDescription()
    isTimeBoundAttr.name = "isTimeBound"
    isTimeBoundAttr.attributeType = .booleanAttributeType
    isTimeBoundAttr.isOptional = false

    // Create ProgressEntry entity
    let progressEntryEntity = NSEntityDescription()
    progressEntryEntity.name = "ProgressEntry"
    progressEntryEntity.managedObjectClassName = "ProgressEntry"

    // ProgressEntry attributes
    let progressEntryIdAttr = NSAttributeDescription()
    progressEntryIdAttr.name = "id"
    progressEntryIdAttr.attributeType = .UUIDAttributeType
    progressEntryIdAttr.isOptional = false

    let progressAmountAttr = NSAttributeDescription()
    progressAmountAttr.name = "amount"
    progressAmountAttr.attributeType = .doubleAttributeType
    progressAmountAttr.isOptional = false

    let progressDateAttr = NSAttributeDescription()
    progressDateAttr.name = "date"
    progressDateAttr.attributeType = .dateAttributeType
    progressDateAttr.isOptional = false

    let progressNoteAttr = NSAttributeDescription()
    progressNoteAttr.name = "note"
    progressNoteAttr.attributeType = .stringAttributeType
    progressNoteAttr.isOptional = true

    let progressCreatedAtAttr = NSAttributeDescription()
    progressCreatedAtAttr.name = "createdAt"
    progressCreatedAtAttr.attributeType = .dateAttributeType
    progressCreatedAtAttr.isOptional = false

    let progressLastModifiedAttr = NSAttributeDescription()
    progressLastModifiedAttr.name = "lastModified"
    progressLastModifiedAttr.attributeType = .dateAttributeType
    progressLastModifiedAttr.isOptional = false

    // Create GoalMilestone entity
    let goalMilestoneEntity = NSEntityDescription()
    goalMilestoneEntity.name = "GoalMilestone"
    goalMilestoneEntity.managedObjectClassName = "GoalMilestone"

    // GoalMilestone attributes
    let milestoneIdAttr = NSAttributeDescription()
    milestoneIdAttr.name = "id"
    milestoneIdAttr.attributeType = .UUIDAttributeType
    milestoneIdAttr.isOptional = false

    let milestoneTitleAttr = NSAttributeDescription()
    milestoneTitleAttr.name = "title"
    milestoneTitleAttr.attributeType = .stringAttributeType
    milestoneTitleAttr.isOptional = false

    let milestoneDescriptionAttr = NSAttributeDescription()
    milestoneDescriptionAttr.name = "description_text"
    milestoneDescriptionAttr.attributeType = .stringAttributeType
    milestoneDescriptionAttr.isOptional = true

    let milestoneTargetAmountAttr = NSAttributeDescription()
    milestoneTargetAmountAttr.name = "targetAmount"
    milestoneTargetAmountAttr.attributeType = .doubleAttributeType
    milestoneTargetAmountAttr.isOptional = false

    let milestoneTargetDateAttr = NSAttributeDescription()
    milestoneTargetDateAttr.name = "targetDate"
    milestoneTargetDateAttr.attributeType = .dateAttributeType
    milestoneTargetDateAttr.isOptional = false

    let milestoneCreatedDateAttr = NSAttributeDescription()
    milestoneCreatedDateAttr.name = "createdAt"
    milestoneCreatedDateAttr.attributeType = .dateAttributeType
    milestoneCreatedDateAttr.isOptional = false

    let milestoneLastModifiedAttr = NSAttributeDescription()
    milestoneLastModifiedAttr.name = "lastModified"
    milestoneLastModifiedAttr.attributeType = .dateAttributeType
    milestoneLastModifiedAttr.isOptional = false

    // Create relationships
    // FinancialGoal -> GoalMilestones (one-to-many)
    let goalToMilestonesRelationship = NSRelationshipDescription()
    goalToMilestonesRelationship.name = "milestones"
    goalToMilestonesRelationship.destinationEntity = goalMilestoneEntity
    goalToMilestonesRelationship.minCount = 0
    goalToMilestonesRelationship.maxCount = 0
    goalToMilestonesRelationship.deleteRule = .cascadeDeleteRule

    // GoalMilestone -> FinancialGoal (many-to-one)
    let milestoneToGoalRelationship = NSRelationshipDescription()
    milestoneToGoalRelationship.name = "goal"
    milestoneToGoalRelationship.destinationEntity = financialGoalEntity
    milestoneToGoalRelationship.minCount = 1
    milestoneToGoalRelationship.maxCount = 1
    milestoneToGoalRelationship.deleteRule = .nullifyDeleteRule

    // FinancialGoal -> Transactions (one-to-many)
    let goalToTransactionsRelationship = NSRelationshipDescription()
    goalToTransactionsRelationship.name = "transactions"
    goalToTransactionsRelationship.destinationEntity = transactionEntity
    goalToTransactionsRelationship.minCount = 0
    goalToTransactionsRelationship.maxCount = 0
    goalToTransactionsRelationship.deleteRule = .nullifyDeleteRule

    // Transaction -> FinancialGoal (many-to-one)
    let transactionToGoalRelationship = NSRelationshipDescription()
    transactionToGoalRelationship.name = "associatedGoal"
    transactionToGoalRelationship.destinationEntity = financialGoalEntity
    transactionToGoalRelationship.minCount = 0
    transactionToGoalRelationship.maxCount = 1
    transactionToGoalRelationship.deleteRule = .nullifyDeleteRule

    // FinancialGoal -> ProgressEntries (one-to-many)
    let goalToProgressEntriesRelationship = NSRelationshipDescription()
    goalToProgressEntriesRelationship.name = "progressEntries"
    goalToProgressEntriesRelationship.destinationEntity = progressEntryEntity
    goalToProgressEntriesRelationship.minCount = 0
    goalToProgressEntriesRelationship.maxCount = 0
    goalToProgressEntriesRelationship.deleteRule = .cascadeDeleteRule

    // ProgressEntry -> FinancialGoal (many-to-one)
    let progressEntryToGoalRelationship = NSRelationshipDescription()
    progressEntryToGoalRelationship.name = "goal"
    progressEntryToGoalRelationship.destinationEntity = financialGoalEntity
    progressEntryToGoalRelationship.minCount = 1
    progressEntryToGoalRelationship.maxCount = 1
    progressEntryToGoalRelationship.deleteRule = .nullifyDeleteRule

    // Set up inverse relationships
    goalToMilestonesRelationship.inverseRelationship = milestoneToGoalRelationship
    milestoneToGoalRelationship.inverseRelationship = goalToMilestonesRelationship
    goalToTransactionsRelationship.inverseRelationship = transactionToGoalRelationship
    transactionToGoalRelationship.inverseRelationship = goalToTransactionsRelationship
    goalToProgressEntriesRelationship.inverseRelationship = progressEntryToGoalRelationship
    progressEntryToGoalRelationship.inverseRelationship = goalToProgressEntriesRelationship

    // Set entity properties
    financialGoalEntity.properties = [
      goalIdAttr,
      goalTitleAttr,
      goalDescriptionAttr,
      targetAmountAttr,
      currentAmountAttr,
      targetDateAttr,
      goalCategoryAttr,
      goalPriorityAttr,
      goalStatusAttr,
      goalCreatedAtAttr,
      goalLastModifiedAttr,
      isCompletedAttr,
      completionDateAttr,
      progressPercentageAttr,
      monthlySavingsRequiredAttr,
      dailySavingsRequiredAttr,
      progressVelocityAttr,
      isOnTrackAttr,
      isOverdueAttr,
      daysRemainingAttr,
      isLongTermGoalAttr,
      isSpecificAttr,
      isMeasurableAttr,
      isAchievableAttr,
      isRelevantAttr,
      isTimeBoundAttr,
      goalToMilestonesRelationship,
      goalToTransactionsRelationship,
      goalToProgressEntriesRelationship,
    ]

    progressEntryEntity.properties = [
      progressEntryIdAttr,
      progressAmountAttr,
      progressDateAttr,
      progressNoteAttr,
      progressCreatedAtAttr,
      progressLastModifiedAttr,
      progressEntryToGoalRelationship,
    ]

    goalMilestoneEntity.properties = [
      milestoneIdAttr,
      milestoneTitleAttr,
      milestoneDescriptionAttr,
      milestoneTargetAmountAttr,
      milestoneTargetDateAttr,
      milestoneCreatedDateAttr,
      milestoneLastModifiedAttr,
      milestoneToGoalRelationship,
    ]

    // Add goal relationship to transaction entity
    transactionEntity.properties.append(transactionToGoalRelationship)

    // Create Portfolio entity (Phase 4 - P4-004)
    let portfolioEntity = NSEntityDescription()
    portfolioEntity.name = "Portfolio"
    portfolioEntity.managedObjectClassName = "Portfolio"

    // Portfolio attributes
    let portfolioIdAttr = NSAttributeDescription()
    portfolioIdAttr.name = "id"
    portfolioIdAttr.attributeType = .UUIDAttributeType
    portfolioIdAttr.isOptional = false

    let portfolioNameAttr = NSAttributeDescription()
    portfolioNameAttr.name = "name"
    portfolioNameAttr.attributeType = .stringAttributeType
    portfolioNameAttr.isOptional = false

    let portfolioCurrencyAttr = NSAttributeDescription()
    portfolioCurrencyAttr.name = "currency"
    portfolioCurrencyAttr.attributeType = .stringAttributeType
    portfolioCurrencyAttr.isOptional = false

    let portfolioTotalValueAttr = NSAttributeDescription()
    portfolioTotalValueAttr.name = "totalValue"
    portfolioTotalValueAttr.attributeType = .doubleAttributeType
    portfolioTotalValueAttr.isOptional = false

    let portfolioCreatedAtAttr = NSAttributeDescription()
    portfolioCreatedAtAttr.name = "createdAt"
    portfolioCreatedAtAttr.attributeType = .dateAttributeType
    portfolioCreatedAtAttr.isOptional = false

    let portfolioLastUpdatedAttr = NSAttributeDescription()
    portfolioLastUpdatedAttr.name = "lastUpdated"
    portfolioLastUpdatedAttr.attributeType = .dateAttributeType
    portfolioLastUpdatedAttr.isOptional = false

    // Create Investment entity
    let investmentEntity = NSEntityDescription()
    investmentEntity.name = "Investment"
    investmentEntity.managedObjectClassName = "Investment"

    // Investment attributes
    let investmentIdAttr = NSAttributeDescription()
    investmentIdAttr.name = "id"
    investmentIdAttr.attributeType = .UUIDAttributeType
    investmentIdAttr.isOptional = false

    let investmentSymbolAttr = NSAttributeDescription()
    investmentSymbolAttr.name = "symbol"
    investmentSymbolAttr.attributeType = .stringAttributeType
    investmentSymbolAttr.isOptional = false

    let investmentNameAttr = NSAttributeDescription()
    investmentNameAttr.name = "name"
    investmentNameAttr.attributeType = .stringAttributeType
    investmentNameAttr.isOptional = false

    let assetTypeAttr = NSAttributeDescription()
    assetTypeAttr.name = "assetType"
    assetTypeAttr.attributeType = .stringAttributeType
    assetTypeAttr.isOptional = false

    let quantityAttr = NSAttributeDescription()
    quantityAttr.name = "quantity"
    quantityAttr.attributeType = .doubleAttributeType
    quantityAttr.isOptional = false

    let averageCostAttr = NSAttributeDescription()
    averageCostAttr.name = "averageCost"
    averageCostAttr.attributeType = .doubleAttributeType
    averageCostAttr.isOptional = false

    let currentPriceAttr = NSAttributeDescription()
    currentPriceAttr.name = "currentPrice"
    currentPriceAttr.attributeType = .doubleAttributeType
    currentPriceAttr.isOptional = false

    let investmentLastUpdatedAttr = NSAttributeDescription()
    investmentLastUpdatedAttr.name = "lastUpdated"
    investmentLastUpdatedAttr.attributeType = .dateAttributeType
    investmentLastUpdatedAttr.isOptional = false

    // Create InvestmentTransaction entity
    let investmentTransactionEntity = NSEntityDescription()
    investmentTransactionEntity.name = "InvestmentTransaction"
    investmentTransactionEntity.managedObjectClassName = "InvestmentTransaction"

    // InvestmentTransaction attributes
    let investmentTxnIdAttr = NSAttributeDescription()
    investmentTxnIdAttr.name = "id"
    investmentTxnIdAttr.attributeType = .UUIDAttributeType
    investmentTxnIdAttr.isOptional = false

    let investmentTxnTypeAttr = NSAttributeDescription()
    investmentTxnTypeAttr.name = "type"
    investmentTxnTypeAttr.attributeType = .stringAttributeType
    investmentTxnTypeAttr.isOptional = false

    let investmentTxnQuantityAttr = NSAttributeDescription()
    investmentTxnQuantityAttr.name = "quantity"
    investmentTxnQuantityAttr.attributeType = .doubleAttributeType
    investmentTxnQuantityAttr.isOptional = false

    let investmentTxnPriceAttr = NSAttributeDescription()
    investmentTxnPriceAttr.name = "price"
    investmentTxnPriceAttr.attributeType = .doubleAttributeType
    investmentTxnPriceAttr.isOptional = false

    let investmentTxnFeesAttr = NSAttributeDescription()
    investmentTxnFeesAttr.name = "fees"
    investmentTxnFeesAttr.attributeType = .doubleAttributeType
    investmentTxnFeesAttr.isOptional = false

    let investmentTxnDateAttr = NSAttributeDescription()
    investmentTxnDateAttr.name = "date"
    investmentTxnDateAttr.attributeType = .dateAttributeType
    investmentTxnDateAttr.isOptional = false

    // Create Dividend entity
    let dividendEntity = NSEntityDescription()
    dividendEntity.name = "Dividend"
    dividendEntity.managedObjectClassName = "Dividend"

    // Dividend attributes
    let dividendIdAttr = NSAttributeDescription()
    dividendIdAttr.name = "id"
    dividendIdAttr.attributeType = .UUIDAttributeType
    dividendIdAttr.isOptional = false

    let dividendAmountAttr = NSAttributeDescription()
    dividendAmountAttr.name = "amount"
    dividendAmountAttr.attributeType = .doubleAttributeType
    dividendAmountAttr.isOptional = false

    let frankedAmountAttr = NSAttributeDescription()
    frankedAmountAttr.name = "frankedAmount"
    frankedAmountAttr.attributeType = .doubleAttributeType
    frankedAmountAttr.isOptional = false

    let exDateAttr = NSAttributeDescription()
    exDateAttr.name = "exDate"
    exDateAttr.attributeType = .dateAttributeType
    exDateAttr.isOptional = false

    let payDateAttr = NSAttributeDescription()
    payDateAttr.name = "payDate"
    payDateAttr.attributeType = .dateAttributeType
    payDateAttr.isOptional = false

    // Create Investment relationships
    // Portfolio -> Investments (one-to-many)
    let portfolioToInvestmentsRelationship = NSRelationshipDescription()
    portfolioToInvestmentsRelationship.name = "investments"
    portfolioToInvestmentsRelationship.destinationEntity = investmentEntity
    portfolioToInvestmentsRelationship.minCount = 0
    portfolioToInvestmentsRelationship.maxCount = 0
    portfolioToInvestmentsRelationship.deleteRule = .cascadeDeleteRule

    // Investment -> Portfolio (many-to-one)
    let investmentToPortfolioRelationship = NSRelationshipDescription()
    investmentToPortfolioRelationship.name = "portfolio"
    investmentToPortfolioRelationship.destinationEntity = portfolioEntity
    investmentToPortfolioRelationship.minCount = 1
    investmentToPortfolioRelationship.maxCount = 1
    investmentToPortfolioRelationship.deleteRule = .nullifyDeleteRule

    // Investment -> InvestmentTransactions (one-to-many)
    let investmentToTransactionsRelationship = NSRelationshipDescription()
    investmentToTransactionsRelationship.name = "transactions"
    investmentToTransactionsRelationship.destinationEntity = investmentTransactionEntity
    investmentToTransactionsRelationship.minCount = 0
    investmentToTransactionsRelationship.maxCount = 0
    investmentToTransactionsRelationship.deleteRule = .cascadeDeleteRule

    // InvestmentTransaction -> Investment (many-to-one)
    let investmentTransactionToInvestmentRelationship = NSRelationshipDescription()
    investmentTransactionToInvestmentRelationship.name = "investment"
    investmentTransactionToInvestmentRelationship.destinationEntity = investmentEntity
    investmentTransactionToInvestmentRelationship.minCount = 1
    investmentTransactionToInvestmentRelationship.maxCount = 1
    investmentTransactionToInvestmentRelationship.deleteRule = .nullifyDeleteRule

    // Investment -> Dividends (one-to-many)
    let investmentToDividendsRelationship = NSRelationshipDescription()
    investmentToDividendsRelationship.name = "dividends"
    investmentToDividendsRelationship.destinationEntity = dividendEntity
    investmentToDividendsRelationship.minCount = 0
    investmentToDividendsRelationship.maxCount = 0
    investmentToDividendsRelationship.deleteRule = .cascadeDeleteRule

    // Dividend -> Investment (many-to-one)
    let dividendToInvestmentRelationship = NSRelationshipDescription()
    dividendToInvestmentRelationship.name = "investment"
    dividendToInvestmentRelationship.destinationEntity = investmentEntity
    dividendToInvestmentRelationship.minCount = 1
    dividendToInvestmentRelationship.maxCount = 1
    dividendToInvestmentRelationship.deleteRule = .nullifyDeleteRule

    // Set up inverse relationships
    portfolioToInvestmentsRelationship.inverseRelationship = investmentToPortfolioRelationship
    investmentToPortfolioRelationship.inverseRelationship = portfolioToInvestmentsRelationship
    investmentToTransactionsRelationship.inverseRelationship =
      investmentTransactionToInvestmentRelationship
    investmentTransactionToInvestmentRelationship.inverseRelationship =
      investmentToTransactionsRelationship
    investmentToDividendsRelationship.inverseRelationship = dividendToInvestmentRelationship
    dividendToInvestmentRelationship.inverseRelationship = investmentToDividendsRelationship

    // Set entity properties
    portfolioEntity.properties = [
      portfolioIdAttr,
      portfolioNameAttr,
      portfolioCurrencyAttr,
      portfolioTotalValueAttr,
      portfolioCreatedAtAttr,
      portfolioLastUpdatedAttr,
      portfolioToInvestmentsRelationship,
    ]

    investmentEntity.properties = [
      investmentIdAttr,
      investmentSymbolAttr,
      investmentNameAttr,
      assetTypeAttr,
      quantityAttr,
      averageCostAttr,
      currentPriceAttr,
      investmentLastUpdatedAttr,
      investmentToPortfolioRelationship,
      investmentToTransactionsRelationship,
      investmentToDividendsRelationship,
    ]

    investmentTransactionEntity.properties = [
      investmentTxnIdAttr,
      investmentTxnTypeAttr,
      investmentTxnQuantityAttr,
      investmentTxnPriceAttr,
      investmentTxnFeesAttr,
      investmentTxnDateAttr,
      investmentTransactionToInvestmentRelationship,
    ]

    dividendEntity.properties = [
      dividendIdAttr,
      dividendAmountAttr,
      frankedAmountAttr,
      exDateAttr,
      payDateAttr,
      dividendToInvestmentRelationship,
    ]

    // Create Asset entity (Phase 4 - UR-106)
    let assetEntity = NSEntityDescription()
    assetEntity.name = "Asset"
    assetEntity.managedObjectClassName = "Asset"

    // Asset attributes
    let assetEntityIdAttr = NSAttributeDescription()
    assetEntityIdAttr.name = "id"
    assetEntityIdAttr.attributeType = .UUIDAttributeType
    assetEntityIdAttr.isOptional = false

    let assetEntityNameAttr = NSAttributeDescription()
    assetEntityNameAttr.name = "name"
    assetEntityNameAttr.attributeType = .stringAttributeType
    assetEntityNameAttr.isOptional = false

    let assetEntityTypeAttr = NSAttributeDescription()
    assetEntityTypeAttr.name = "assetType"
    assetEntityTypeAttr.attributeType = .stringAttributeType
    assetEntityTypeAttr.isOptional = false

    let assetCurrentValueAttr = NSAttributeDescription()
    assetCurrentValueAttr.name = "currentValue"
    assetCurrentValueAttr.attributeType = .doubleAttributeType
    assetCurrentValueAttr.isOptional = false

    let assetPurchasePriceAttr = NSAttributeDescription()
    assetPurchasePriceAttr.name = "purchasePrice"
    assetPurchasePriceAttr.attributeType = .doubleAttributeType
    assetPurchasePriceAttr.isOptional = true

    let assetPurchaseDateAttr = NSAttributeDescription()
    assetPurchaseDateAttr.name = "purchaseDate"
    assetPurchaseDateAttr.attributeType = .dateAttributeType
    assetPurchaseDateAttr.isOptional = true

    let assetCreatedAtAttr = NSAttributeDescription()
    assetCreatedAtAttr.name = "createdAt"
    assetCreatedAtAttr.attributeType = .dateAttributeType
    assetCreatedAtAttr.isOptional = false

    let assetLastUpdatedAttr = NSAttributeDescription()
    assetLastUpdatedAttr.name = "lastUpdated"
    assetLastUpdatedAttr.attributeType = .dateAttributeType
    assetLastUpdatedAttr.isOptional = false

    // Create Liability entity (Phase 4 - UR-106)
    let liabilityEntity = NSEntityDescription()
    liabilityEntity.name = "Liability"
    liabilityEntity.managedObjectClassName = "Liability"

    // Liability attributes
    let liabilityIdAttr = NSAttributeDescription()
    liabilityIdAttr.name = "id"
    liabilityIdAttr.attributeType = .UUIDAttributeType
    liabilityIdAttr.isOptional = false

    let liabilityNameAttr = NSAttributeDescription()
    liabilityNameAttr.name = "name"
    liabilityNameAttr.attributeType = .stringAttributeType
    liabilityNameAttr.isOptional = false

    let liabilityTypeAttr = NSAttributeDescription()
    liabilityTypeAttr.name = "liabilityType"
    liabilityTypeAttr.attributeType = .stringAttributeType
    liabilityTypeAttr.isOptional = false

    let liabilityCurrentBalanceAttr = NSAttributeDescription()
    liabilityCurrentBalanceAttr.name = "currentBalance"
    liabilityCurrentBalanceAttr.attributeType = .doubleAttributeType
    liabilityCurrentBalanceAttr.isOptional = false

    let liabilityOriginalAmountAttr = NSAttributeDescription()
    liabilityOriginalAmountAttr.name = "originalAmount"
    liabilityOriginalAmountAttr.attributeType = .doubleAttributeType
    liabilityOriginalAmountAttr.isOptional = true

    let liabilityInterestRateAttr = NSAttributeDescription()
    liabilityInterestRateAttr.name = "interestRate"
    liabilityInterestRateAttr.attributeType = .doubleAttributeType
    liabilityInterestRateAttr.isOptional = true

    let liabilityMonthlyPaymentAttr = NSAttributeDescription()
    liabilityMonthlyPaymentAttr.name = "monthlyPayment"
    liabilityMonthlyPaymentAttr.attributeType = .doubleAttributeType
    liabilityMonthlyPaymentAttr.isOptional = true

    let liabilityCreatedAtAttr = NSAttributeDescription()
    liabilityCreatedAtAttr.name = "createdAt"
    liabilityCreatedAtAttr.attributeType = .dateAttributeType
    liabilityCreatedAtAttr.isOptional = false

    let liabilityLastUpdatedAttr = NSAttributeDescription()
    liabilityLastUpdatedAttr.name = "lastUpdated"
    liabilityLastUpdatedAttr.attributeType = .dateAttributeType
    liabilityLastUpdatedAttr.isOptional = false

    // Create NetWealthSnapshot entity (Phase 4 - UR-106)
    let netWealthSnapshotEntity = NSEntityDescription()
    netWealthSnapshotEntity.name = "NetWealthSnapshot"
    netWealthSnapshotEntity.managedObjectClassName = "NetWealthSnapshot"

    // NetWealthSnapshot attributes
    let netWealthIdAttr = NSAttributeDescription()
    netWealthIdAttr.name = "id"
    netWealthIdAttr.attributeType = .UUIDAttributeType
    netWealthIdAttr.isOptional = false

    let netWealthTotalAssetsAttr = NSAttributeDescription()
    netWealthTotalAssetsAttr.name = "totalAssets"
    netWealthTotalAssetsAttr.attributeType = .doubleAttributeType
    netWealthTotalAssetsAttr.isOptional = false

    let netWealthTotalLiabilitiesAttr = NSAttributeDescription()
    netWealthTotalLiabilitiesAttr.name = "totalLiabilities"
    netWealthTotalLiabilitiesAttr.attributeType = .doubleAttributeType
    netWealthTotalLiabilitiesAttr.isOptional = false

    let netWealthNetWealthAttr = NSAttributeDescription()
    netWealthNetWealthAttr.name = "netWealth"
    netWealthNetWealthAttr.attributeType = .doubleAttributeType
    netWealthNetWealthAttr.isOptional = false

    let netWealthSnapshotDateAttr = NSAttributeDescription()
    netWealthSnapshotDateAttr.name = "snapshotDate"
    netWealthSnapshotDateAttr.attributeType = .dateAttributeType
    netWealthSnapshotDateAttr.isOptional = false

    let netWealthCreatedAtAttr = NSAttributeDescription()
    netWealthCreatedAtAttr.name = "createdAt"
    netWealthCreatedAtAttr.attributeType = .dateAttributeType
    netWealthCreatedAtAttr.isOptional = false

    // Create supporting entities for asset/liability breakdown
    let assetValuationEntity = NSEntityDescription()
    assetValuationEntity.name = "AssetValuation"
    assetValuationEntity.managedObjectClassName = "AssetValuation"

    let assetValuationIdAttr = NSAttributeDescription()
    assetValuationIdAttr.name = "id"
    assetValuationIdAttr.attributeType = .UUIDAttributeType
    assetValuationIdAttr.isOptional = false

    let assetValuationValueAttr = NSAttributeDescription()
    assetValuationValueAttr.name = "value"
    assetValuationValueAttr.attributeType = .doubleAttributeType
    assetValuationValueAttr.isOptional = false

    let assetValuationDateAttr = NSAttributeDescription()
    assetValuationDateAttr.name = "date"
    assetValuationDateAttr.attributeType = .dateAttributeType
    assetValuationDateAttr.isOptional = false

    let liabilityPaymentEntity = NSEntityDescription()
    liabilityPaymentEntity.name = "LiabilityPayment"
    liabilityPaymentEntity.managedObjectClassName = "LiabilityPayment"

    let liabilityPaymentIdAttr = NSAttributeDescription()
    liabilityPaymentIdAttr.name = "id"
    liabilityPaymentIdAttr.attributeType = .UUIDAttributeType
    liabilityPaymentIdAttr.isOptional = false

    let liabilityPaymentAmountAttr = NSAttributeDescription()
    liabilityPaymentAmountAttr.name = "amount"
    liabilityPaymentAmountAttr.attributeType = .doubleAttributeType
    liabilityPaymentAmountAttr.isOptional = false

    let liabilityPaymentDateAttr = NSAttributeDescription()
    liabilityPaymentDateAttr.name = "date"
    liabilityPaymentDateAttr.attributeType = .dateAttributeType
    liabilityPaymentDateAttr.isOptional = false

    // Asset breakdown entities
    let assetBreakdownEntity = NSEntityDescription()
    assetBreakdownEntity.name = "AssetBreakdown"
    assetBreakdownEntity.managedObjectClassName = "AssetBreakdown"

    let assetBreakdownIdAttr = NSAttributeDescription()
    assetBreakdownIdAttr.name = "id"
    assetBreakdownIdAttr.attributeType = .UUIDAttributeType
    assetBreakdownIdAttr.isOptional = false

    let assetBreakdownTypeAttr = NSAttributeDescription()
    assetBreakdownTypeAttr.name = "assetType"
    assetBreakdownTypeAttr.attributeType = .stringAttributeType
    assetBreakdownTypeAttr.isOptional = false

    let assetBreakdownValueAttr = NSAttributeDescription()
    assetBreakdownValueAttr.name = "value"
    assetBreakdownValueAttr.attributeType = .doubleAttributeType
    assetBreakdownValueAttr.isOptional = false

    let liabilityBreakdownEntity = NSEntityDescription()
    liabilityBreakdownEntity.name = "LiabilityBreakdown"
    liabilityBreakdownEntity.managedObjectClassName = "LiabilityBreakdown"

    let liabilityBreakdownIdAttr = NSAttributeDescription()
    liabilityBreakdownIdAttr.name = "id"
    liabilityBreakdownIdAttr.attributeType = .UUIDAttributeType
    liabilityBreakdownIdAttr.isOptional = false

    let liabilityBreakdownTypeAttr = NSAttributeDescription()
    liabilityBreakdownTypeAttr.name = "liabilityType"
    liabilityBreakdownTypeAttr.attributeType = .stringAttributeType
    liabilityBreakdownTypeAttr.isOptional = false

    let liabilityBreakdownValueAttr = NSAttributeDescription()
    liabilityBreakdownValueAttr.name = "value"
    liabilityBreakdownValueAttr.attributeType = .doubleAttributeType
    liabilityBreakdownValueAttr.isOptional = false

    // Create relationships
    // Asset -> FinancialEntity (many-to-one)
    let assetToEntityRelationship = NSRelationshipDescription()
    assetToEntityRelationship.name = "financialEntity"
    assetToEntityRelationship.destinationEntity = financialEntityEntity
    assetToEntityRelationship.minCount = 0
    assetToEntityRelationship.maxCount = 1
    assetToEntityRelationship.deleteRule = .nullifyDeleteRule

    // FinancialEntity -> Assets (one-to-many)
    let entityToAssetsRelationship = NSRelationshipDescription()
    entityToAssetsRelationship.name = "assets"
    entityToAssetsRelationship.destinationEntity = assetEntity
    entityToAssetsRelationship.minCount = 0
    entityToAssetsRelationship.maxCount = 0
    entityToAssetsRelationship.deleteRule = .nullifyDeleteRule

    // Asset -> AssetValuations (one-to-many)
    let assetToValuationsRelationship = NSRelationshipDescription()
    assetToValuationsRelationship.name = "valuationHistory"
    assetToValuationsRelationship.destinationEntity = assetValuationEntity
    assetToValuationsRelationship.minCount = 0
    assetToValuationsRelationship.maxCount = 0
    assetToValuationsRelationship.deleteRule = .cascadeDeleteRule

    // AssetValuation -> Asset (many-to-one)
    let valuationToAssetRelationship = NSRelationshipDescription()
    valuationToAssetRelationship.name = "asset"
    valuationToAssetRelationship.destinationEntity = assetEntity
    valuationToAssetRelationship.minCount = 1
    valuationToAssetRelationship.maxCount = 1
    valuationToAssetRelationship.deleteRule = .nullifyDeleteRule

    // Liability -> FinancialEntity (many-to-one)
    let liabilityToEntityRelationship = NSRelationshipDescription()
    liabilityToEntityRelationship.name = "financialEntity"
    liabilityToEntityRelationship.destinationEntity = financialEntityEntity
    liabilityToEntityRelationship.minCount = 0
    liabilityToEntityRelationship.maxCount = 1
    liabilityToEntityRelationship.deleteRule = .nullifyDeleteRule

    // FinancialEntity -> Liabilities (one-to-many)
    let entityToLiabilitiesRelationship = NSRelationshipDescription()
    entityToLiabilitiesRelationship.name = "liabilities"
    entityToLiabilitiesRelationship.destinationEntity = liabilityEntity
    entityToLiabilitiesRelationship.minCount = 0
    entityToLiabilitiesRelationship.maxCount = 0
    entityToLiabilitiesRelationship.deleteRule = .nullifyDeleteRule

    // Liability -> LiabilityPayments (one-to-many)
    let liabilityToPaymentsRelationship = NSRelationshipDescription()
    liabilityToPaymentsRelationship.name = "payments"
    liabilityToPaymentsRelationship.destinationEntity = liabilityPaymentEntity
    liabilityToPaymentsRelationship.minCount = 0
    liabilityToPaymentsRelationship.maxCount = 0
    liabilityToPaymentsRelationship.deleteRule = .cascadeDeleteRule

    // LiabilityPayment -> Liability (many-to-one)
    let paymentToLiabilityRelationship = NSRelationshipDescription()
    paymentToLiabilityRelationship.name = "liability"
    paymentToLiabilityRelationship.destinationEntity = liabilityEntity
    paymentToLiabilityRelationship.minCount = 1
    paymentToLiabilityRelationship.maxCount = 1
    paymentToLiabilityRelationship.deleteRule = .nullifyDeleteRule

    // NetWealthSnapshot -> FinancialEntity (many-to-one)
    let netWealthSnapshotToEntityRelationship = NSRelationshipDescription()
    netWealthSnapshotToEntityRelationship.name = "financialEntity"
    netWealthSnapshotToEntityRelationship.destinationEntity = financialEntityEntity
    netWealthSnapshotToEntityRelationship.minCount = 1
    netWealthSnapshotToEntityRelationship.maxCount = 1
    netWealthSnapshotToEntityRelationship.deleteRule = .nullifyDeleteRule

    // FinancialEntity -> NetWealthSnapshots (one-to-many)
    let entityToNetWealthSnapshotsRelationship = NSRelationshipDescription()
    entityToNetWealthSnapshotsRelationship.name = "netWealthSnapshots"
    entityToNetWealthSnapshotsRelationship.destinationEntity = netWealthSnapshotEntity
    entityToNetWealthSnapshotsRelationship.minCount = 0
    entityToNetWealthSnapshotsRelationship.maxCount = 0
    entityToNetWealthSnapshotsRelationship.deleteRule = .cascadeDeleteRule

    // NetWealthSnapshot -> AssetBreakdown (one-to-many)
    let netWealthSnapshotToAssetBreakdownRelationship = NSRelationshipDescription()
    netWealthSnapshotToAssetBreakdownRelationship.name = "assetBreakdown"
    netWealthSnapshotToAssetBreakdownRelationship.destinationEntity = assetBreakdownEntity
    netWealthSnapshotToAssetBreakdownRelationship.minCount = 0
    netWealthSnapshotToAssetBreakdownRelationship.maxCount = 0
    netWealthSnapshotToAssetBreakdownRelationship.deleteRule = .cascadeDeleteRule

    // AssetBreakdown -> NetWealthSnapshot (many-to-one)
    let assetBreakdownToSnapshotRelationship = NSRelationshipDescription()
    assetBreakdownToSnapshotRelationship.name = "netWealthSnapshot"
    assetBreakdownToSnapshotRelationship.destinationEntity = netWealthSnapshotEntity
    assetBreakdownToSnapshotRelationship.minCount = 1
    assetBreakdownToSnapshotRelationship.maxCount = 1
    assetBreakdownToSnapshotRelationship.deleteRule = .nullifyDeleteRule

    // NetWealthSnapshot -> LiabilityBreakdown (one-to-many)
    let netWealthSnapshotToLiabilityBreakdownRelationship = NSRelationshipDescription()
    netWealthSnapshotToLiabilityBreakdownRelationship.name = "liabilityBreakdown"
    netWealthSnapshotToLiabilityBreakdownRelationship.destinationEntity = liabilityBreakdownEntity
    netWealthSnapshotToLiabilityBreakdownRelationship.minCount = 0
    netWealthSnapshotToLiabilityBreakdownRelationship.maxCount = 0
    netWealthSnapshotToLiabilityBreakdownRelationship.deleteRule = .cascadeDeleteRule

    // LiabilityBreakdown -> NetWealthSnapshot (many-to-one)
    let liabilityBreakdownToSnapshotRelationship = NSRelationshipDescription()
    liabilityBreakdownToSnapshotRelationship.name = "netWealthSnapshot"
    liabilityBreakdownToSnapshotRelationship.destinationEntity = netWealthSnapshotEntity
    liabilityBreakdownToSnapshotRelationship.minCount = 1
    liabilityBreakdownToSnapshotRelationship.maxCount = 1
    liabilityBreakdownToSnapshotRelationship.deleteRule = .nullifyDeleteRule

    // Set up inverse relationships
    assetToEntityRelationship.inverseRelationship = entityToAssetsRelationship
    entityToAssetsRelationship.inverseRelationship = assetToEntityRelationship

    assetToValuationsRelationship.inverseRelationship = valuationToAssetRelationship
    valuationToAssetRelationship.inverseRelationship = assetToValuationsRelationship

    liabilityToEntityRelationship.inverseRelationship = entityToLiabilitiesRelationship
    entityToLiabilitiesRelationship.inverseRelationship = liabilityToEntityRelationship

    liabilityToPaymentsRelationship.inverseRelationship = paymentToLiabilityRelationship
    paymentToLiabilityRelationship.inverseRelationship = liabilityToPaymentsRelationship

    netWealthSnapshotToEntityRelationship.inverseRelationship = entityToNetWealthSnapshotsRelationship
    entityToNetWealthSnapshotsRelationship.inverseRelationship = netWealthSnapshotToEntityRelationship

    netWealthSnapshotToAssetBreakdownRelationship.inverseRelationship = assetBreakdownToSnapshotRelationship
    assetBreakdownToSnapshotRelationship.inverseRelationship = netWealthSnapshotToAssetBreakdownRelationship

    netWealthSnapshotToLiabilityBreakdownRelationship.inverseRelationship = liabilityBreakdownToSnapshotRelationship
    liabilityBreakdownToSnapshotRelationship.inverseRelationship = netWealthSnapshotToLiabilityBreakdownRelationship

    // Set entity properties
    assetEntity.properties = [
      assetEntityIdAttr,
      assetEntityNameAttr,
      assetEntityTypeAttr,
      assetCurrentValueAttr,
      assetPurchasePriceAttr,
      assetPurchaseDateAttr,
      assetCreatedAtAttr,
      assetLastUpdatedAttr,
      assetToEntityRelationship,
      assetToValuationsRelationship,
    ]

    liabilityEntity.properties = [
      liabilityIdAttr,
      liabilityNameAttr,
      liabilityTypeAttr,
      liabilityCurrentBalanceAttr,
      liabilityOriginalAmountAttr,
      liabilityInterestRateAttr,
      liabilityMonthlyPaymentAttr,
      liabilityCreatedAtAttr,
      liabilityLastUpdatedAttr,
      liabilityToEntityRelationship,
      liabilityToPaymentsRelationship,
    ]

    netWealthSnapshotEntity.properties = [
      netWealthIdAttr,
      netWealthTotalAssetsAttr,
      netWealthTotalLiabilitiesAttr,
      netWealthNetWealthAttr,
      netWealthSnapshotDateAttr,
      netWealthCreatedAtAttr,
      netWealthSnapshotToEntityRelationship,
      netWealthSnapshotToAssetBreakdownRelationship,
      netWealthSnapshotToLiabilityBreakdownRelationship,
    ]

    assetValuationEntity.properties = [
      assetValuationIdAttr,
      assetValuationValueAttr,
      assetValuationDateAttr,
      valuationToAssetRelationship,
    ]

    liabilityPaymentEntity.properties = [
      liabilityPaymentIdAttr,
      liabilityPaymentAmountAttr,
      liabilityPaymentDateAttr,
      paymentToLiabilityRelationship,
    ]

    assetBreakdownEntity.properties = [
      assetBreakdownIdAttr,
      assetBreakdownTypeAttr,
      assetBreakdownValueAttr,
      assetBreakdownToSnapshotRelationship,
    ]

    liabilityBreakdownEntity.properties = [
      liabilityBreakdownIdAttr,
      liabilityBreakdownTypeAttr,
      liabilityBreakdownValueAttr,
      liabilityBreakdownToSnapshotRelationship,
    ]

    // Add asset and liability relationships to financial entity
    financialEntityEntity.properties.append(entityToAssetsRelationship)
    financialEntityEntity.properties.append(entityToLiabilitiesRelationship)
    financialEntityEntity.properties.append(entityToNetWealthSnapshotsRelationship)

    model.entities = [
      transactionEntity,
      lineItemEntity,
      splitAllocationEntity,
      financialEntityEntity,
      smsfDetailsEntity,
      crossEntityTransactionEntity,
      bankAccountEntity,
      userEntity,
      auditLogEntity,
      wealthSnapshotEntity,
      assetAllocationEntity,
      performanceMetricsEntity,
      financialGoalEntity,
      goalMilestoneEntity,
      progressEntryEntity,
      portfolioEntity,
      investmentEntity,
      investmentTransactionEntity,
      dividendEntity,
      assetEntity,
      liabilityEntity,
      netWealthSnapshotEntity,
      assetValuationEntity,
      liabilityPaymentEntity,
      assetBreakdownEntity,
      liabilityBreakdownEntity,
    ]

    // Use only the programmatic model, not the .xcdatamodeld file
    container = NSPersistentContainer(name: "FinanceMateDataStore", managedObjectModel: model)
    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores { [container] description, error in
      if let error = error as NSError? {
        // Check if this is a migration error
        if error.code == 134110 {  // NSMigrationError
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
