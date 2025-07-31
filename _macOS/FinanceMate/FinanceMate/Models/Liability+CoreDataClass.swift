import Foundation
import CoreData

/**
 * Purpose: Core Data entity for Liability management with Net Wealth integration
 * Issues & Complexity Summary: Complex liability type management with payment tracking
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~280
 *   - Core Algorithm Complexity: Med
 *   - Dependencies: Core Data, FinancialEntity relationships
 *   - State Management Complexity: Med (liability types, payments)
 *   - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 88%
 * Overall Result Score: 94%
 * Key Variances/Learnings: Liability calculations require careful interest rate handling
 * Last Updated: 2025-07-31
 */

@objc(Liability)
public class Liability: NSManagedObject {
    
    // MARK: - Liability Types
    
    @objc public enum LiabilityType: Int32, CaseIterable {
        case mortgage = 0
        case personalLoan = 1
        case creditCard = 2
        case businessLoan = 3
        case other = 4
        
        var stringValue: String {
            switch self {
            case .mortgage:
                return "Mortgage"
            case .personalLoan:
                return "Personal Loan"
            case .creditCard:
                return "Credit Card"
            case .businessLoan:
                return "Business Loan"
            case .other:
                return "Other"
            }
        }
        
        static func from(string: String) -> LiabilityType {
            switch string {
            case "Mortgage":
                return .mortgage
            case "Personal Loan":
                return .personalLoan
            case "Credit Card":
                return .creditCard
            case "Business Loan":
                return .businessLoan
            default:
                return .other
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Liability type as enum
    public var type: LiabilityType {
        get {
            return LiabilityType.from(string: self.liabilityType ?? "Other")
        }
        set {
            self.liabilityType = newValue.stringValue
        }
    }
    
    /// Current balance formatted as currency
    public var formattedCurrentBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: currentBalance)) ?? "$0.00"
    }
    
    /// Original amount formatted as currency (if available)
    public var formattedOriginalAmount: String? {
        guard let originalAmount = originalAmount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: originalAmount))
    }
    
    /// Monthly payment formatted as currency (if available)
    public var formattedMonthlyPayment: String? {
        guard let monthlyPayment = monthlyPayment else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: monthlyPayment))
    }
    
    /// Amount paid down from original (if original amount available)
    public var amountPaidDown: Double? {
        guard let originalAmount = originalAmount else { return nil }
        return originalAmount - currentBalance
    }
    
    /// Percentage paid down from original
    public var percentagePaidDown: Double? {
        guard let originalAmount = originalAmount, originalAmount > 0 else { return nil }
        return ((originalAmount - currentBalance) / originalAmount) * 100
    }
    
    /// Remaining percentage of original debt
    public var remainingPercentage: Double? {
        guard let originalAmount = originalAmount, originalAmount > 0 else { return nil }
        return (currentBalance / originalAmount) * 100
    }
    
    /// Interest rate formatted as percentage
    public var formattedInterestRate: String? {
        guard let interestRate = interestRate else { return nil }
        return String(format: "%.2f%%", interestRate)
    }
    
    /// Annual interest amount (approximate)
    public var annualInterestAmount: Double? {
        guard let interestRate = interestRate else { return nil }
        return currentBalance * (interestRate / 100)
    }
    
    /// Monthly interest amount (approximate)
    public var monthlyInterestAmount: Double? {
        guard let annualInterest = annualInterestAmount else { return nil }
        return annualInterest / 12
    }
    
    /// Total payments made (sum of payment history)
    public var totalPaymentsMade: Double {
        return payments.reduce(0) { total, payment in
            if let liabilityPayment = payment as? LiabilityPayment {
                return total + liabilityPayment.amount
            }
            return total
        }
    }
    
    /// Most recent payment from history
    public var mostRecentPayment: LiabilityPayment? {
        let sortedPayments = payments.compactMap { $0 as? LiabilityPayment }
            .sorted { $0.date > $1.date }
        return sortedPayments.first
    }
    
    /// Average monthly payment (based on payment history)
    public var averageMonthlyPayment: Double? {
        let liabilityPayments = payments.compactMap { $0 as? LiabilityPayment }
        guard !liabilityPayments.isEmpty else { return nil }
        
        let totalPayments = liabilityPayments.reduce(0) { $0 + $1.amount }
        
        // Calculate months between first and last payment
        let sortedPayments = liabilityPayments.sorted { $0.date < $1.date }
        guard let firstPayment = sortedPayments.first,
              let lastPayment = sortedPayments.last else { return nil }
        
        let months = Calendar.current.dateComponents([.month], 
                                                   from: firstPayment.date, 
                                                   to: lastPayment.date).month ?? 1
        
        return totalPayments / Double(max(1, months))
    }
    
    /// Estimated payoff time in months (if monthly payment specified)
    public var estimatedPayoffMonths: Int? {
        guard let monthlyPayment = monthlyPayment,
              let interestRate = interestRate,
              monthlyPayment > 0,
              currentBalance > 0 else { return nil }
        
        let monthlyRate = interestRate / 100 / 12
        
        // If no interest or payment covers interest completely
        if monthlyRate <= 0 || monthlyPayment <= currentBalance * monthlyRate {
            return Int(currentBalance / monthlyPayment)
        }
        
        // Formula: n = -log(1 - (r * P) / A) / log(1 + r)
        // Where: P = principal, r = monthly rate, A = monthly payment
        let numerator = -log(1 - (monthlyRate * currentBalance) / monthlyPayment)
        let denominator = log(1 + monthlyRate)
        
        return Int(ceil(numerator / denominator))
    }
    
    /// Estimated payoff date
    public var estimatedPayoffDate: Date? {
        guard let months = estimatedPayoffMonths else { return nil }
        return Calendar.current.date(byAdding: .month, value: months, to: Date())
    }
    
    // MARK: - Factory Methods
    
    /// Create a new Liability with required fields
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        name: String,
        type: LiabilityType,
        currentBalance: Double,
        originalAmount: Double? = nil,
        interestRate: Double? = nil,
        monthlyPayment: Double? = nil
    ) -> Liability {
        let liability = Liability(context: context)
        liability.id = UUID()
        liability.name = name
        liability.type = type
        liability.currentBalance = currentBalance
        liability.originalAmount = originalAmount
        liability.interestRate = interestRate
        liability.monthlyPayment = monthlyPayment
        liability.createdAt = Date()
        liability.lastUpdated = Date()
        return liability
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateLiability()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateLiability()
    }
    
    private func validateLiability() throws {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.invalidName("Liability name cannot be empty")
        }
        
        guard currentBalance >= 0 else {
            throw ValidationError.invalidValue("Liability current balance cannot be negative")
        }
        
        if let originalAmount = originalAmount, originalAmount < 0 {
            throw ValidationError.invalidValue("Liability original amount cannot be negative")
        }
        
        if let interestRate = interestRate, interestRate < 0 {
            throw ValidationError.invalidValue("Liability interest rate cannot be negative")
        }
        
        if let monthlyPayment = monthlyPayment, monthlyPayment < 0 {
            throw ValidationError.invalidValue("Liability monthly payment cannot be negative")
        }
        
        // Logical validation: current balance shouldn't exceed original amount
        if let originalAmount = originalAmount, currentBalance > originalAmount {
            throw ValidationError.invalidValue("Current balance cannot exceed original amount")
        }
    }
    
    // MARK: - Update Methods
    
    /// Update liability balance and record payment
    public func makePayment(_ amount: Double, date: Date = Date()) {
        guard amount > 0 else { return }
        
        // Record payment in history
        let payment = LiabilityPayment.create(
            in: self.managedObjectContext!,
            amount: amount,
            date: date,
            liability: self
        )
        self.addToPayments(payment)
        
        // Update current balance
        let newBalance = max(0, currentBalance - amount)
        self.currentBalance = newBalance
        self.lastUpdated = date
    }
    
    /// Update liability balance without payment record (for value adjustments)
    public func updateBalance(_ newBalance: Double, date: Date = Date()) {
        guard newBalance >= 0 else { return }
        self.currentBalance = newBalance
        self.lastUpdated = date
    }
    
    /// Add liability to financial entity
    public func assignTo(entity: FinancialEntity) {
        self.financialEntity = entity
        entity.addToLiabilities(self)
    }
    
    /// Remove liability from financial entity
    public func removeFromEntity() {
        self.financialEntity?.removeFromLiabilities(self)
        self.financialEntity = nil
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Liability> {
        return NSFetchRequest<Liability>(entityName: "Liability")
    }
    
    /// Fetch liabilities by type
    public static func fetchLiabilities(
        ofType type: LiabilityType,
        in context: NSManagedObjectContext
    ) -> [Liability] {
        let request: NSFetchRequest<Liability> = Liability.fetchRequest()
        request.predicate = NSPredicate(format: "liabilityType == %@", type.stringValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Liability.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching liabilities by type: \(error)")
            return []
        }
    }
    
    /// Fetch liabilities for financial entity
    public static func fetchLiabilities(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> [Liability] {
        let request: NSFetchRequest<Liability> = Liability.fetchRequest()
        request.predicate = NSPredicate(format: "financialEntity == %@", entity)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Liability.currentBalance, ascending: false),
            NSSortDescriptor(keyPath: \Liability.name, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching liabilities for entity: \(error)")
            return []
        }
    }
    
    /// Calculate total balance of liabilities by type
    public static func totalBalance(
        ofType type: LiabilityType,
        for entity: FinancialEntity? = nil,
        in context: NSManagedObjectContext
    ) -> Double {
        let request: NSFetchRequest<Liability> = Liability.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "liabilityType == %@", type.stringValue)
        ]
        
        if let entity = entity {
            predicates.append(NSPredicate(format: "financialEntity == %@", entity))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let liabilities = try context.fetch(request)
            return liabilities.reduce(0) { $0 + $1.currentBalance }
        } catch {
            print("Error calculating total liability balance: \(error)")
            return 0
        }
    }
    
    /// Calculate total balance of all liabilities for entity
    public static func totalBalance(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> Double {
        let request: NSFetchRequest<Liability> = Liability.fetchRequest()
        request.predicate = NSPredicate(format: "financialEntity == %@", entity)
        
        do {
            let liabilities = try context.fetch(request)
            return liabilities.reduce(0) { $0 + $1.currentBalance }
        } catch {
            print("Error calculating total liability balance for entity: \(error)")
            return 0
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get liability breakdown by type for entity
    public static func getLiabilityBreakdown(
        for entity: FinancialEntity,
        in context: NSManagedObjectContext
    ) -> [LiabilityType: Double] {
        var breakdown: [LiabilityType: Double] = [:]
        
        for liabilityType in LiabilityType.allCases {
            let totalBalance = Liability.totalBalance(ofType: liabilityType, for: entity, in: context)
            if totalBalance > 0 {
                breakdown[liabilityType] = totalBalance
            }
        }
        
        return breakdown
    }
    
    /// Export liability data for reporting
    public func exportData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? "",
            "name": name ?? "",
            "type": type.stringValue,
            "currentBalance": currentBalance,
            "createdAt": createdAt,
            "lastUpdated": lastUpdated
        ]
        
        if let originalAmount = originalAmount {
            data["originalAmount"] = originalAmount
        }
        
        if let interestRate = interestRate {
            data["interestRate"] = interestRate
        }
        
        if let monthlyPayment = monthlyPayment {
            data["monthlyPayment"] = monthlyPayment
        }
        
        if let entity = financialEntity {
            data["financialEntity"] = entity.name
        }
        
        if let amountPaid = amountPaidDown {
            data["amountPaidDown"] = amountPaid
        }
        
        if let percentagePaid = percentagePaidDown {
            data["percentagePaidDown"] = percentagePaid
        }
        
        if let payoffMonths = estimatedPayoffMonths {
            data["estimatedPayoffMonths"] = payoffMonths
        }
        
        data["totalPaymentsMade"] = totalPaymentsMade
        
        return data
    }
}

// MARK: - Generated Accessors

extension Liability {
    
    @objc(addPaymentsObject:)
    @NSManaged public func addToPayments(_ value: LiabilityPayment)
    
    @objc(removePaymentsObject:)
    @NSManaged public func removeFromPayments(_ value: LiabilityPayment)
    
    @objc(addPayments:)
    @NSManaged public func addToPayments(_ values: NSSet)
    
    @objc(removePayments:)
    @NSManaged public func removeFromPayments(_ values: NSSet)
}