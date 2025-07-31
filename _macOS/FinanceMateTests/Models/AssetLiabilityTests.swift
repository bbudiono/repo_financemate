import XCTest
import CoreData
@testable import FinanceMate

final class AssetLiabilityTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }
    
    // MARK: - Asset Entity Tests (TDD - Write tests first)
    
    func testAssetCreationWithRequiredFields() throws {
        // This test will fail initially until we implement Asset entity
        let asset = Asset.create(
            in: context,
            name: "Primary Residence",
            type: .realEstate,
            currentValue: 850000.0
        )
        
        try context.save()
        
        XCTAssertNotNil(asset.id)
        XCTAssertEqual(asset.name, "Primary Residence")
        XCTAssertEqual(asset.type, .realEstate)
        XCTAssertEqual(asset.currentValue, 850000.0)
        XCTAssertNotNil(asset.createdAt)
        XCTAssertNotNil(asset.lastUpdated)
    }
    
    func testAssetCreationWithOptionalFields() throws {
        let purchaseDate = Date().addingTimeInterval(-365 * 24 * 60 * 60) // 1 year ago
        
        let asset = Asset.create(
            in: context,
            name: "Investment Property",
            type: .realEstate,
            currentValue: 650000.0,
            purchasePrice: 500000.0,
            purchaseDate: purchaseDate
        )
        
        try context.save()
        
        XCTAssertEqual(asset.purchasePrice, 500000.0)
        XCTAssertEqual(asset.purchaseDate, purchaseDate)
    }
    
    func testAssetTypeEnum() throws {
        // Test all asset types
        let realEstate = Asset.create(in: context, name: "House", type: .realEstate, currentValue: 500000.0)
        let vehicle = Asset.create(in: context, name: "Car", type: .vehicle, currentValue: 35000.0)
        let investment = Asset.create(in: context, name: "Stocks", type: .investment, currentValue: 100000.0)
        let cash = Asset.create(in: context, name: "Savings", type: .cash, currentValue: 50000.0)
        let other = Asset.create(in: context, name: "Artwork", type: .other, currentValue: 15000.0)
        
        try context.save()
        
        XCTAssertEqual(realEstate.type, .realEstate)
        XCTAssertEqual(vehicle.type, .vehicle)
        XCTAssertEqual(investment.type, .investment)
        XCTAssertEqual(cash.type, .cash)
        XCTAssertEqual(other.type, .other)
    }
    
    func testAssetFinancialEntityRelationship() throws {
        // Create a financial entity
        let entity = FinancialEntity.create(
            in: context,
            name: "Personal",
            type: .personal
        )
        
        // Create asset linked to entity
        let asset = Asset.create(
            in: context,
            name: "Family Home",
            type: .realEstate,
            currentValue: 750000.0
        )
        asset.financialEntity = entity
        
        try context.save()
        
        XCTAssertEqual(asset.financialEntity, entity)
        XCTAssertTrue(entity.assets.contains(asset))
    }
    
    func testAssetValuationHistory() throws {
        let asset = Asset.create(
            in: context,
            name: "Investment Portfolio",
            type: .investment,
            currentValue: 100000.0
        )
        
        // Create valuation history
        let valuation1 = AssetValuation.create(
            in: context,
            value: 95000.0,
            date: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
            asset: asset
        )
        
        let valuation2 = AssetValuation.create(
            in: context,
            value: 100000.0,
            date: Date(),
            asset: asset
        )
        
        try context.save()
        
        XCTAssertEqual(asset.valuationHistory.count, 2)
        XCTAssertTrue(asset.valuationHistory.contains(valuation1))
        XCTAssertTrue(asset.valuationHistory.contains(valuation2))
    }
    
    // MARK: - Liability Entity Tests (TDD - Write tests first)
    
    func testLiabilityCreationWithRequiredFields() throws {
        let liability = Liability.create(
            in: context,
            name: "Home Mortgage",
            type: .mortgage,
            currentBalance: 350000.0
        )
        
        try context.save()
        
        XCTAssertNotNil(liability.id)
        XCTAssertEqual(liability.name, "Home Mortgage")
        XCTAssertEqual(liability.type, .mortgage)
        XCTAssertEqual(liability.currentBalance, 350000.0)
        XCTAssertNotNil(liability.createdAt)
        XCTAssertNotNil(liability.lastUpdated)
    }
    
    func testLiabilityCreationWithOptionalFields() throws {
        let liability = Liability.create(
            in: context,
            name: "Investment Loan",
            type: .personalLoan,
            currentBalance: 50000.0,
            originalAmount: 75000.0,
            interestRate: 5.5,
            monthlyPayment: 1200.0
        )
        
        try context.save()
        
        XCTAssertEqual(liability.originalAmount, 75000.0)
        XCTAssertEqual(liability.interestRate, 5.5)
        XCTAssertEqual(liability.monthlyPayment, 1200.0)
    }
    
    func testLiabilityTypeEnum() throws {
        let mortgage = Liability.create(in: context, name: "Mortgage", type: .mortgage, currentBalance: 300000.0)
        let personalLoan = Liability.create(in: context, name: "Personal Loan", type: .personalLoan, currentBalance: 25000.0)
        let creditCard = Liability.create(in: context, name: "Credit Card", type: .creditCard, currentBalance: 5000.0)
        let businessLoan = Liability.create(in: context, name: "Business Loan", type: .businessLoan, currentBalance: 100000.0)
        let other = Liability.create(in: context, name: "Other Debt", type: .other, currentBalance: 10000.0)
        
        try context.save()
        
        XCTAssertEqual(mortgage.type, .mortgage)
        XCTAssertEqual(personalLoan.type, .personalLoan)
        XCTAssertEqual(creditCard.type, .creditCard)
        XCTAssertEqual(businessLoan.type, .businessLoan)
        XCTAssertEqual(other.type, .other)
    }
    
    func testLiabilityFinancialEntityRelationship() throws {
        let entity = FinancialEntity.create(
            in: context,
            name: "Business",
            type: .business
        )
        
        let liability = Liability.create(
            in: context,
            name: "Business Credit Line",
            type: .businessLoan,
            currentBalance: 75000.0
        )
        liability.financialEntity = entity
        
        try context.save()
        
        XCTAssertEqual(liability.financialEntity, entity)
        XCTAssertTrue(entity.liabilities.contains(liability))
    }
    
    func testLiabilityPaymentHistory() throws {
        let liability = Liability.create(
            in: context,
            name: "Car Loan",
            type: .personalLoan,
            currentBalance: 20000.0,
            monthlyPayment: 500.0
        )
        
        // Create payment history
        let payment1 = LiabilityPayment.create(
            in: context,
            amount: 500.0,
            date: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
            liability: liability
        )
        
        let payment2 = LiabilityPayment.create(
            in: context,
            amount: 500.0,
            date: Date(),
            liability: liability
        )
        
        try context.save()
        
        XCTAssertEqual(liability.payments.count, 2)
        XCTAssertTrue(liability.payments.contains(payment1))
        XCTAssertTrue(liability.payments.contains(payment2))
    }
    
    // MARK: - NetWealthSnapshot Tests (TDD - Write tests first)
    
    func testNetWealthSnapshotCreation() throws {
        let entity = FinancialEntity.create(
            in: context,
            name: "Personal",
            type: .personal
        )
        
        let snapshot = NetWealthSnapshot.create(
            in: context,
            entity: entity,
            totalAssets: 1000000.0,
            totalLiabilities: 400000.0,
            netWealth: 600000.0
        )
        
        try context.save()
        
        XCTAssertNotNil(snapshot.id)
        XCTAssertEqual(snapshot.financialEntity, entity)
        XCTAssertEqual(snapshot.totalAssets, 1000000.0)
        XCTAssertEqual(snapshot.totalLiabilities, 400000.0)
        XCTAssertEqual(snapshot.netWealth, 600000.0)
        XCTAssertNotNil(snapshot.snapshotDate)
        XCTAssertNotNil(snapshot.createdAt)
    }
    
    func testNetWealthSnapshotAssetBreakdown() throws {
        let entity = FinancialEntity.create(
            in: context,
            name: "Personal",
            type: .personal
        )
        
        let snapshot = NetWealthSnapshot.create(
            in: context,
            entity: entity,
            totalAssets: 1000000.0,
            totalLiabilities: 400000.0,
            netWealth: 600000.0
        )
        
        // Add asset breakdown
        let realEstateBreakdown = AssetBreakdown.create(
            in: context,
            assetType: .realEstate,
            value: 750000.0,
            snapshot: snapshot
        )
        
        let investmentBreakdown = AssetBreakdown.create(
            in: context,
            assetType: .investment,
            value: 200000.0,
            snapshot: snapshot
        )
        
        let cashBreakdown = AssetBreakdown.create(
            in: context,
            assetType: .cash,
            value: 50000.0,
            snapshot: snapshot
        )
        
        try context.save()
        
        XCTAssertEqual(snapshot.assetBreakdown.count, 3)
        XCTAssertTrue(snapshot.assetBreakdown.contains(realEstateBreakdown))
        XCTAssertTrue(snapshot.assetBreakdown.contains(investmentBreakdown))
        XCTAssertTrue(snapshot.assetBreakdown.contains(cashBreakdown))
    }
    
    func testNetWealthSnapshotLiabilityBreakdown() throws {
        let entity = FinancialEntity.create(
            in: context,
            name: "Personal",
            type: .personal
        )
        
        let snapshot = NetWealthSnapshot.create(
            in: context,
            entity: entity,
            totalAssets: 1000000.0,
            totalLiabilities: 400000.0,
            netWealth: 600000.0
        )
        
        // Add liability breakdown
        let mortgageBreakdown = LiabilityBreakdown.create(
            in: context,
            liabilityType: .mortgage,
            value: 350000.0,
            snapshot: snapshot
        )
        
        let creditCardBreakdown = LiabilityBreakdown.create(
            in: context,
            liabilityType: .creditCard,
            value: 50000.0,
            snapshot: snapshot
        )
        
        try context.save()
        
        XCTAssertEqual(snapshot.liabilityBreakdown.count, 2)
        XCTAssertTrue(snapshot.liabilityBreakdown.contains(mortgageBreakdown))
        XCTAssertTrue(snapshot.liabilityBreakdown.contains(creditCardBreakdown))
    }
    
    // MARK: - Integration Tests
    
    func testCompleteNetWealthCalculationScenario() throws {
        // Create financial entity
        let personalEntity = FinancialEntity.create(
            in: context,
            name: "Personal Wealth",
            type: .personal
        )
        
        // Create assets
        let house = Asset.create(
            in: context,
            name: "Primary Residence",
            type: .realEstate,
            currentValue: 800000.0
        )
        house.financialEntity = personalEntity
        
        let investments = Asset.create(
            in: context,
            name: "Stock Portfolio",
            type: .investment,
            currentValue: 150000.0
        )
        investments.financialEntity = personalEntity
        
        let savings = Asset.create(
            in: context,
            name: "Emergency Fund",
            type: .cash,
            currentValue: 25000.0
        )
        savings.financialEntity = personalEntity
        
        // Create liabilities
        let mortgage = Liability.create(
            in: context,
            name: "Home Mortgage",
            type: .mortgage,
            currentBalance: 350000.0
        )
        mortgage.financialEntity = personalEntity
        
        let creditCard = Liability.create(
            in: context,
            name: "Credit Card Debt",
            type: .creditCard,
            currentBalance: 8000.0
        )
        creditCard.financialEntity = personalEntity
        
        // Calculate totals
        let totalAssets = 800000.0 + 150000.0 + 25000.0  // 975,000
        let totalLiabilities = 350000.0 + 8000.0         // 358,000
        let netWealth = totalAssets - totalLiabilities   // 617,000
        
        // Create snapshot
        let snapshot = NetWealthSnapshot.create(
            in: context,
            entity: personalEntity,
            totalAssets: totalAssets,
            totalLiabilities: totalLiabilities,
            netWealth: netWealth
        )
        
        try context.save()
        
        // Verify calculations
        XCTAssertEqual(snapshot.totalAssets, 975000.0)
        XCTAssertEqual(snapshot.totalLiabilities, 358000.0)
        XCTAssertEqual(snapshot.netWealth, 617000.0)
        
        // Verify relationships
        XCTAssertEqual(personalEntity.assets.count, 3)
        XCTAssertEqual(personalEntity.liabilities.count, 2)
        XCTAssertTrue(personalEntity.netWealthSnapshots.contains(snapshot))
    }
    
    func testMultiEntityNetWealthScenario() throws {
        // Create multiple entities
        let personalEntity = FinancialEntity.create(in: context, name: "Personal", type: .personal)
        let businessEntity = FinancialEntity.create(in: context, name: "Business", type: .business)
        
        // Personal assets and liabilities
        let personalAsset = Asset.create(in: context, name: "Home", type: .realEstate, currentValue: 500000.0)
        personalAsset.financialEntity = personalEntity
        
        let personalLiability = Liability.create(in: context, name: "Mortgage", type: .mortgage, currentBalance: 300000.0)
        personalLiability.financialEntity = personalEntity
        
        // Business assets and liabilities
        let businessAsset = Asset.create(in: context, name: "Office Building", type: .realEstate, currentValue: 750000.0)
        businessAsset.financialEntity = businessEntity
        
        let businessLiability = Liability.create(in: context, name: "Business Loan", type: .businessLoan, currentBalance: 200000.0)
        businessLiability.financialEntity = businessEntity
        
        // Create snapshots for each entity
        let personalSnapshot = NetWealthSnapshot.create(
            in: context,
            entity: personalEntity,
            totalAssets: 500000.0,
            totalLiabilities: 300000.0,
            netWealth: 200000.0
        )
        
        let businessSnapshot = NetWealthSnapshot.create(
            in: context,
            entity: businessEntity,
            totalAssets: 750000.0,
            totalLiabilities: 200000.0,
            netWealth: 550000.0
        )
        
        try context.save()
        
        // Verify entity-specific calculations
        XCTAssertEqual(personalEntity.assets.count, 1)
        XCTAssertEqual(personalEntity.liabilities.count, 1)
        XCTAssertEqual(businessEntity.assets.count, 1)
        XCTAssertEqual(businessEntity.liabilities.count, 1)
        
        // Verify total net wealth across entities would be 750,000
        let combinedNetWealth = personalSnapshot.netWealth + businessSnapshot.netWealth
        XCTAssertEqual(combinedNetWealth, 750000.0)
    }
    
    // MARK: - Performance Tests
    
    func testLargeDatasetPerformance() throws {
        let entity = FinancialEntity.create(in: context, name: "Test Entity", type: .personal)
        
        // Create large number of assets and liabilities
        for i in 1...1000 {
            let asset = Asset.create(
                in: context,
                name: "Asset \(i)",
                type: .investment,
                currentValue: Double(i * 1000)
            )
            asset.financialEntity = entity
            
            if i <= 500 {
                let liability = Liability.create(
                    in: context,
                    name: "Liability \(i)",
                    type: .personalLoan,
                    currentBalance: Double(i * 500)
                )
                liability.financialEntity = entity
            }
        }
        
        // Measure save performance
        measure {
            do {
                try context.save()
            } catch {
                XCTFail("Failed to save large dataset: \(error)")
            }
        }
        
        // Verify counts
        XCTAssertEqual(entity.assets.count, 1000)
        XCTAssertEqual(entity.liabilities.count, 500)
    }
}