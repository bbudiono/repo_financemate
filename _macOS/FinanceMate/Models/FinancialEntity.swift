import Foundation
import CoreData

/**
 * FinancialEntity.swift
 * 
 * Purpose: Core Data entity for multi-entity financial architecture with enterprise-grade structure management
 * Issues & Complexity Summary: Complex entity relationships with hierarchies, cross-entity transactions, and Australian compliance
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~200
 *   - Core Algorithm Complexity: Medium-High
 *   - Dependencies: 3 (Core Data, Foundation, Security)
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Medium-High
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 90%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: Enterprise-grade multi-entity architecture with Australian financial compliance
 * Last Updated: 2025-07-08
 */

@objc(FinancialEntity)
public class FinancialEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var entityType: String
    @NSManaged public var abn: String?
    @NSManaged public var createdDate: Date
    @NSManaged public var isActive: Bool
    @NSManaged public var parentEntityId: UUID?
    @NSManaged public var gstRegistered: Bool
    
    // Relationships
    @NSManaged public var transactions: NSSet<Transaction>
    @NSManaged public var childEntities: NSSet<FinancialEntity>
    @NSManaged public var crossEntityTransactions: NSSet<CrossEntityTransaction>
    @NSManaged public var smsfDetails: SMSFEntityDetails?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.createdDate = Date()
        self.isActive = true
        self.gstRegistered = false
    }
}

// MARK: - Core Data Extensions

extension FinancialEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FinancialEntity> {
        return NSFetchRequest<FinancialEntity>(entityName: "FinancialEntity")
    }
    
    static func create(
        in context: NSManagedObjectContext,
        name: String,
        type: EntityType,
        abn: String? = nil
    ) -> FinancialEntity {
        let entity = FinancialEntity(context: context)
        entity.name = name
        entity.entityType = type.rawValue
        entity.abn = abn
        return entity
    }
}

// MARK: - SMSFEntityDetails

@objc(SMSFEntityDetails)
public class SMSFEntityDetails: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var abn: String
    @NSManaged public var trustDeedDate: Date
    @NSManaged public var investmentStrategyDate: Date
    @NSManaged public var lastAuditDate: Date?
    @NSManaged public var nextAuditDueDate: Date
    
    // Relationships
    @NSManaged public var entity: FinancialEntity
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
    }
    
    var isAuditDue: Bool {
        return Date() > nextAuditDueDate
    }
    
    var isInvestmentStrategyDue: Bool {
        return Date() > Calendar.current.date(byAdding: .year, value: 1, to: investmentStrategyDate) ?? Date()
    }
}

// MARK: - CrossEntityTransaction

@objc(CrossEntityTransaction)
public class CrossEntityTransaction: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var fromEntityId: UUID
    @NSManaged public var toEntityId: UUID
    @NSManaged public var amount: Double
    @NSManaged public var description: String
    @NSManaged public var transactionDate: Date
    @NSManaged public var transactionType: String
    @NSManaged public var auditTrail: Data?
    
    // Relationships
    @NSManaged public var fromEntity: FinancialEntity
    @NSManaged public var toEntity: FinancialEntity
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.transactionDate = Date()
    }
}

// MARK: - Transaction Extension for Entity Support

extension Transaction {
    @NSManaged public var entityId: UUID
    @NSManaged public var entity: FinancialEntity
    
    static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        category: String,
        note: String? = nil
    ) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.amount = amount
        transaction.category = category
        transaction.note = note
        transaction.date = Date()
        return transaction
    }
}