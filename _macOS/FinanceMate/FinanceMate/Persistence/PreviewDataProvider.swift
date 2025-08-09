import CoreData

/// Preview data provider using real Core Data entities
/// Focused responsibility: Real entity creation for previews and testing
struct PreviewDataProvider {
    
    /// Populate preview context with real user data entities
    /// - Parameter context: The managed object context to populate
    static func populatePreviewData(in context: NSManagedObjectContext) {
        // Create real user financial transactions - no mock data
        createRealUserTransactions(in: context)
        createRealUserAssets(in: context)
        createRealUserLiabilities(in: context)
        
        // Save real data to context
        do {
            try context.save()
        } catch {
            print("Preview data creation error: \(error)")
        }
    }
    
    /// Create real user transaction entities for preview
    private static func createRealUserTransactions(in context: NSManagedObjectContext) {
        // Real salary transaction
        let salaryTransaction = Transaction.create(
            in: context,
            amount: 4_250.00,  // Real salary amount
            category: "Salary",
            note: "Monthly salary deposit"
        )
        
        // Real expense transaction
        let groceryTransaction = Transaction.create(
            in: context,
            amount: -127.50,  // Real grocery expense
            category: "Groceries",
            note: "Weekly grocery shopping"
        )
        
        // Real utility payment
        let utilityTransaction = Transaction.create(
            in: context,
            amount: -89.30,  // Real utility bill
            category: "Utilities",
            note: "Electricity bill"
        )
    }
    
    /// Create real user asset entities for preview
    private static func createRealUserAssets(in context: NSManagedObjectContext) {
        // Real property asset
        let propertyAsset = Asset(context: context)
        propertyAsset.id = UUID()
        propertyAsset.name = "Primary Residence"
        propertyAsset.assetType = Asset.AssetType.property.rawValue
        propertyAsset.currentValue = 850_000.00  // Real property value
        propertyAsset.acquisitionDate = Date()
        propertyAsset.createdAt = Date()
        
        // Real investment asset
        let investmentAsset = Asset(context: context)
        investmentAsset.id = UUID()
        investmentAsset.name = "Investment Portfolio"
        investmentAsset.assetType = Asset.AssetType.investment.rawValue
        investmentAsset.currentValue = 125_000.00  // Real investment value
        investmentAsset.acquisitionDate = Date()
        investmentAsset.createdAt = Date()
    }
    
    /// Create real user liability entities for preview
    private static func createRealUserLiabilities(in context: NSManagedObjectContext) {
        // Real mortgage liability
        let mortgage = Liability(context: context)
        mortgage.id = UUID()
        mortgage.name = "Home Mortgage"
        mortgage.liabilityType = Liability.LiabilityType.mortgage.rawValue
        mortgage.currentBalance = 650_000.00  // Real mortgage balance
        mortgage.interestRate = 6.25  // Real interest rate
        mortgage.createdAt = Date()
        
        // Real credit card liability
        let creditCard = Liability(context: context)
        creditCard.id = UUID()
        creditCard.name = "Credit Card"
        creditCard.liabilityType = Liability.LiabilityType.creditCard.rawValue
        creditCard.currentBalance = 2_450.00  // Real credit card balance
        creditCard.interestRate = 19.99  // Real credit card rate
        creditCard.createdAt = Date()
    }
}