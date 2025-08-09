//
// Dividend.swift
// FinanceMate
//
// Created by AI Agent on 2025-08-09.
// Phase 5 Investment Portfolio Implementation: Dividend Tracking Entity
//

/*
 * Purpose: Dividend payment tracking entity for investment income management
 * Issues & Complexity Summary: Dividend tracking, tax implications, Australian franking credits
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~150 (dividend entity + tax calculations + franking credits)
   - Core Algorithm Complexity: Medium (dividend yield calculations, tax implications)
   - Dependencies: Investment entity, Australian tax rules, franking credit system
   - State Management Complexity: Medium (dividend history, tax reporting)
   - Novelty/Uncertainty Factor: Medium (Australian franking credit calculations)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 83%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: 87%
 * Overall Result Score: 86%
 * Key Variances/Learnings: Franking credit calculations require careful Australian tax compliance
 * Last Updated: 2025-08-09
 */

import Foundation
import CoreData

/// Dividend Entity - Tracks dividend payments and franking credits for Australian tax compliance
@objc(Dividend)
public class Dividend: NSManagedObject {
    
    // MARK: - Dividend Types
    
    @objc public enum DividendType: Int16, CaseIterable {
        case ordinary = 0
        case special = 1
        case interim = 2
        case final = 3
        case franked = 4
        case unfranked = 5
        case capitalReturn = 6
        case other = 7
        
        var displayName: String {
            switch self {
            case .ordinary: return "Ordinary Dividend"
            case .special: return "Special Dividend"
            case .interim: return "Interim Dividend"
            case .final: return "Final Dividend"
            case .franked: return "Franked Dividend"
            case .unfranked: return "Unfranked Dividend"
            case .capitalReturn: return "Return of Capital"
            case .other: return "Other"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Dividend type as enum
    public var dividendTypeEnum: DividendType {
        get { DividendType(rawValue: dividendType) ?? .ordinary }
        set { dividendType = newValue.rawValue }
    }
    
    /// Franking credit amount (Australian tax system)
    public var frankingCreditAmount: Double {
        guard frankingPercentage > 0 else { return 0.0 }
        let corporateTaxRate = 0.30 // 30% Australian corporate tax rate
        return (amount * frankingPercentage / 100.0) * (corporateTaxRate / (1.0 - corporateTaxRate))
    }
    
    /// Total dividend value including franking credits
    public var grossDividend: Double {
        return amount + frankingCreditAmount
    }
    
    /// Dividend yield based on investment cost basis
    public var dividendYield: Double {
        guard let investment = investment,
              investment.averageCostBasis > 0 else { return 0.0 }
        return (amount / investment.averageCostBasis) * 100.0
    }
    
    /// Tax withheld amount
    public var taxWithheld: Double {
        return amount * (taxWithholdingRate / 100.0)
    }
    
    /// Net dividend received after tax withholding
    public var netDividend: Double {
        return amount - taxWithheld
    }
    
    /// Annual dividend yield projection (if this is quarterly/half-yearly)
    public func annualizedYield() -> Double {
        let multiplier: Double
        switch paymentFrequency {
        case 1: return dividendYield // Annual
        case 2: multiplier = 2.0 // Half-yearly
        case 4: multiplier = 4.0 // Quarterly
        case 12: multiplier = 12.0 // Monthly
        default: multiplier = 1.0
        }
        return dividendYield * multiplier
    }
    
    // MARK: - Factory Methods
    
    /// Create a new Dividend entity
    public static func create(
        in context: NSManagedObjectContext,
        investment: Investment,
        amount: Double,
        paymentDate: Date = Date(),
        currency: String = "AUD",
        type: DividendType = .ordinary
    ) -> Dividend {
        let dividend = Dividend(context: context)
        
        dividend.id = UUID()
        dividend.amount = amount
        dividend.paymentDate = paymentDate
        dividend.currency = currency
        dividend.dividendType = type.rawValue
        dividend.frankingPercentage = 0.0 // Will be set separately for Australian shares
        dividend.taxWithholdingRate = 0.0 // Will be set based on tax jurisdiction
        dividend.paymentFrequency = 4 // Default to quarterly
        dividend.isReinvested = false
        dividend.createdAt = Date()
        dividend.updatedAt = Date()
        dividend.investment = investment
        
        return dividend
    }
    
    /// Create franked dividend (Australian shares)
    public static func createFrankedDividend(
        in context: NSManagedObjectContext,
        investment: Investment,
        amount: Double,
        frankingPercentage: Double,
        paymentDate: Date = Date()
    ) -> Dividend {
        let dividend = create(
            in: context,
            investment: investment,
            amount: amount,
            paymentDate: paymentDate,
            type: .franked
        )
        
        dividend.frankingPercentage = frankingPercentage
        return dividend
    }
    
    // MARK: - Australian Tax Calculations
    
    /// Calculate total assessable income for Australian tax purposes
    public func calculateAssessableIncome() -> Double {
        // For Australian tax purposes, include franking credits in assessable income
        return grossDividend
    }
    
    /// Calculate franking credit for tax offset
    public func calculateFrankingCreditOffset() -> Double {
        // In Australia, franking credits can be used as tax offsets
        return frankingCreditAmount
    }
    
    /// Check if dividend qualifies for franking credit refund
    public var qualifiesForFrankingRefund: Bool {
        // Simplified check - in practice, this depends on individual tax situation
        return frankingPercentage > 0 && investment?.isAustralianInvestment == true
    }
    
    // MARK: - Dividend Reinvestment
    
    /// Mark dividend as reinvested
    public func markAsReinvested(sharesPurchased: Decimal, pricePerShare: Double) {
        isReinvested = true
        reinvestmentShares = sharesPurchased
        reinvestmentPrice = pricePerShare
        updatedAt = Date()
        
        // Update investment quantity
        investment?.updateQuantity(
            (investment?.quantity ?? 0) + sharesPurchased,
            costBasisAdjustment: amount
        )
    }
    
    // MARK: - Reporting Functions
    
    /// Get dividend for tax year (July 1 - June 30 in Australia)
    public static func dividendsForTaxYear(
        _ year: Int,
        in context: NSManagedObjectContext,
        investment: Investment? = nil
    ) -> [Dividend] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: year - 1, month: 7, day: 1))!
        let endDate = calendar.date(from: DateComponents(year: year, month: 6, day: 30))!
        
        let request: NSFetchRequest<Dividend> = Dividend.fetchRequest()
        var predicates: [NSPredicate] = [
            NSPredicate(format: "paymentDate >= %@ AND paymentDate <= %@", startDate as NSDate, endDate as NSDate)
        ]
        
        if let investment = investment {
            predicates.append(NSPredicate(format: "investment == %@", investment))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Dividend.paymentDate, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching dividends for tax year: \(error)")
            return []
        }
    }
    
    /// Calculate total dividends received in tax year
    public static func totalDividendsForTaxYear(
        _ year: Int,
        in context: NSManagedObjectContext,
        includeFrankingCredits: Bool = false
    ) -> Double {
        let dividends = dividendsForTaxYear(year, in: context)
        
        if includeFrankingCredits {
            return dividends.map { $0.grossDividend }.reduce(0, +)
        } else {
            return dividends.map { $0.amount }.reduce(0, +)
        }
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateDividend()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateDividend()
    }
    
    private func validateDividend() throws {
        guard amount > 0 else {
            throw DividendValidationError.invalidAmount
        }
        
        guard frankingPercentage >= 0 && frankingPercentage <= 100 else {
            throw DividendValidationError.invalidFrankingPercentage
        }
        
        guard taxWithholdingRate >= 0 && taxWithholdingRate <= 100 else {
            throw DividendValidationError.invalidTaxWithholdingRate
        }
        
        guard let currency = currency, !currency.isEmpty else {
            throw DividendValidationError.invalidCurrency
        }
    }
}

// MARK: - Core Data Properties

extension Dividend {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dividend> {
        return NSFetchRequest<Dividend>(entityName: "Dividend")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var paymentDate: Date?
    @NSManaged public var currency: String?
    @NSManaged public var dividendType: Int16
    @NSManaged public var frankingPercentage: Double
    @NSManaged public var taxWithholdingRate: Double
    @NSManaged public var paymentFrequency: Int16
    @NSManaged public var isReinvested: Bool
    @NSManaged public var reinvestmentShares: Decimal
    @NSManaged public var reinvestmentPrice: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var notes: String?
    
    // Relationships
    @NSManaged public var investment: Investment?
    
}

// MARK: - Error Types

public enum DividendValidationError: Error, LocalizedError {
    case invalidAmount
    case invalidFrankingPercentage
    case invalidTaxWithholdingRate
    case invalidCurrency
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Dividend amount must be greater than zero"
        case .invalidFrankingPercentage:
            return "Franking percentage must be between 0% and 100%"
        case .invalidTaxWithholdingRate:
            return "Tax withholding rate must be between 0% and 100%"
        case .invalidCurrency:
            return "Currency is required and cannot be empty"
        }
    }
}

// MARK: - Identifiable Conformance

extension Dividend: Identifiable {
    // Uses id property from Core Data
}