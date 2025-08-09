import CoreData

/// Relationship configuration between Core Data entities
/// Focused responsibility: Entity relationship setup only
struct RelationshipConfigurator {
    
    /// Configure all relationships between entities
    /// - Parameters: All entity descriptions that need relationships (some may be nil if not implemented)
    static func configureAllRelationships(
        transaction: NSEntityDescription,
        lineItem: NSEntityDescription,
        splitAllocation: NSEntityDescription,
        user: NSEntityDescription,
        asset: NSEntityDescription,
        liability: NSEntityDescription?,
        netWealthSnapshot: NSEntityDescription?,
        assetValuation: NSEntityDescription?,
        auditLog: NSEntityDescription?,
        financialEntity: NSEntityDescription?
    ) {
        // Configure Transaction relationships
        configureTransactionRelationships(transaction, lineItem, user)
        
        // Configure LineItem relationships
        configureLineItemRelationships(lineItem, transaction, splitAllocation)
        
        // Configure SplitAllocation relationships
        configureSplitAllocationRelationships(splitAllocation, lineItem)
        
        // Configure User relationships (with optional entities)
        configureUserRelationships(user, transaction, asset, liability, auditLog)
        
        // Configure Asset relationships (with optional entities)
        configureAssetRelationships(asset, user, assetValuation, financialEntity)
        
        // Configure additional relationships only if entities exist
        if let liability = liability, let financialEntity = financialEntity {
            configureLiabilityRelationships(liability, user, financialEntity)
        }
        
        if let netWealthSnapshot = netWealthSnapshot, let liability = liability {
            configureNetWealthRelationships(netWealthSnapshot, user, asset, liability)
        }
    }
    
    /// Configure Transaction entity relationships
    private static func configureTransactionRelationships(
        _ transaction: NSEntityDescription,
        _ lineItem: NSEntityDescription,
        _ user: NSEntityDescription
    ) {
        // Transaction -> LineItems (one-to-many)
        let transactionToLineItems = NSRelationshipDescription()
        transactionToLineItems.name = "lineItems"
        transactionToLineItems.destinationEntity = lineItem
        transactionToLineItems.minCount = 0
        transactionToLineItems.maxCount = 0  // unlimited
        transactionToLineItems.deleteRule = .cascadeDeleteRule
        
        // Transaction -> User (many-to-one)
        let transactionToUser = NSRelationshipDescription()
        transactionToUser.name = "user"
        transactionToUser.destinationEntity = user
        transactionToUser.minCount = 1
        transactionToUser.maxCount = 1
        transactionToUser.deleteRule = .nullifyDeleteRule
        
        // Add relationships to transaction properties
        var transactionProperties = transaction.properties
        transactionProperties.append(contentsOf: [transactionToLineItems, transactionToUser])
        transaction.properties = transactionProperties
    }
    
    /// Configure LineItem entity relationships
    private static func configureLineItemRelationships(
        _ lineItem: NSEntityDescription,
        _ transaction: NSEntityDescription,
        _ splitAllocation: NSEntityDescription
    ) {
        // LineItem -> Transaction (many-to-one)
        let lineItemToTransaction = NSRelationshipDescription()
        lineItemToTransaction.name = "transaction"
        lineItemToTransaction.destinationEntity = transaction
        lineItemToTransaction.minCount = 1
        lineItemToTransaction.maxCount = 1
        lineItemToTransaction.deleteRule = .nullifyDeleteRule
        
        // LineItem -> SplitAllocations (one-to-many)
        let lineItemToSplitAllocations = NSRelationshipDescription()
        lineItemToSplitAllocations.name = "splitAllocations"
        lineItemToSplitAllocations.destinationEntity = splitAllocation
        lineItemToSplitAllocations.minCount = 0
        lineItemToSplitAllocations.maxCount = 0  // unlimited
        lineItemToSplitAllocations.deleteRule = .cascadeDeleteRule
        
        // Add relationships to line item properties
        var lineItemProperties = lineItem.properties
        lineItemProperties.append(contentsOf: [lineItemToTransaction, lineItemToSplitAllocations])
        lineItem.properties = lineItemProperties
    }
    
    /// Configure SplitAllocation entity relationships
    private static func configureSplitAllocationRelationships(
        _ splitAllocation: NSEntityDescription,
        _ lineItem: NSEntityDescription
    ) {
        // SplitAllocation -> LineItem (many-to-one)
        let splitAllocationToLineItem = NSRelationshipDescription()
        splitAllocationToLineItem.name = "lineItem"
        splitAllocationToLineItem.destinationEntity = lineItem
        splitAllocationToLineItem.minCount = 1
        splitAllocationToLineItem.maxCount = 1
        splitAllocationToLineItem.deleteRule = .nullifyDeleteRule
        
        // Add relationship to split allocation properties
        var splitAllocationProperties = splitAllocation.properties
        splitAllocationProperties.append(splitAllocationToLineItem)
        splitAllocation.properties = splitAllocationProperties
    }
    
    /// Configure User entity relationships
    private static func configureUserRelationships(
        _ user: NSEntityDescription,
        _ transaction: NSEntityDescription,
        _ asset: NSEntityDescription,
        _ liability: NSEntityDescription?,
        _ auditLog: NSEntityDescription?
    ) {
        // User -> Transactions (one-to-many)
        let userToTransactions = NSRelationshipDescription()
        userToTransactions.name = "transactions"
        userToTransactions.destinationEntity = transaction
        userToTransactions.minCount = 0
        userToTransactions.maxCount = 0  // unlimited
        userToTransactions.deleteRule = .cascadeDeleteRule
        
        // User -> Assets (one-to-many)
        let userToAssets = NSRelationshipDescription()
        userToAssets.name = "assets"
        userToAssets.destinationEntity = asset
        userToAssets.minCount = 0
        userToAssets.maxCount = 0  // unlimited
        userToAssets.deleteRule = .cascadeDeleteRule
        
        // Add relationships to user properties
        var userProperties = user.properties
        userProperties.append(contentsOf: [userToTransactions, userToAssets])
        
        // Add liability relationship if liability entity exists
        if let liability = liability {
            let userToLiabilities = NSRelationshipDescription()
            userToLiabilities.name = "liabilities"
            userToLiabilities.destinationEntity = liability
            userToLiabilities.minCount = 0
            userToLiabilities.maxCount = 0  // unlimited
            userToLiabilities.deleteRule = .cascadeDeleteRule
            userProperties.append(userToLiabilities)
        }
        
        user.properties = userProperties
    }
    
    /// Configure Asset entity relationships
    private static func configureAssetRelationships(
        _ asset: NSEntityDescription,
        _ user: NSEntityDescription,
        _ assetValuation: NSEntityDescription?,
        _ financialEntity: NSEntityDescription?
    ) {
        // Asset -> User (many-to-one)
        let assetToUser = NSRelationshipDescription()
        assetToUser.name = "user"
        assetToUser.destinationEntity = user
        assetToUser.minCount = 1
        assetToUser.maxCount = 1
        assetToUser.deleteRule = .nullifyDeleteRule
        
        // Add relationship to asset properties
        var assetProperties = asset.properties
        assetProperties.append(assetToUser)
        
        // Add asset valuation relationship if available
        if let assetValuation = assetValuation {
            let assetToValuations = NSRelationshipDescription()
            assetToValuations.name = "valuations"
            assetToValuations.destinationEntity = assetValuation
            assetToValuations.minCount = 0
            assetToValuations.maxCount = 0  // unlimited
            assetToValuations.deleteRule = .cascadeDeleteRule
            assetProperties.append(assetToValuations)
        }
        
        asset.properties = assetProperties
    }
    
    /// Configure Liability entity relationships (placeholder)
    private static func configureLiabilityRelationships(
        _ liability: NSEntityDescription,
        _ user: NSEntityDescription,
        _ financialEntity: NSEntityDescription
    ) {
        // Basic liability relationships - can be expanded as needed
    }
    
    /// Configure NetWealth relationships (placeholder)
    private static func configureNetWealthRelationships(
        _ netWealthSnapshot: NSEntityDescription,
        _ user: NSEntityDescription,
        _ asset: NSEntityDescription,
        _ liability: NSEntityDescription
    ) {
        // Basic net wealth relationships - can be expanded as needed
    }
}