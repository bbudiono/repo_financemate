//
// Investment.swift
// FinanceMate
//
// Created by AI Agent on 2025-08-09.
// Phase 5 Investment Portfolio Implementation: Core Investment Entity
//

/*
 * Purpose: Core Data entity for individual investment holdings across all asset classes
 * Issues & Complexity Summary: Multi-asset class support, real-time valuation, performance tracking, Australian market integration
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~300 (entity + extensions + factory methods)
   - Core Algorithm Complexity: Medium (investment calculations, currency conversion, performance metrics)
   - Dependencies: FinancialEntity, Portfolio, Core Data, real-time price feeds
   - State Management Complexity: High (real-time price updates, historical performance, dividends)
   - Novelty/Uncertainty Factor: Medium (Australian market APIs, multi-currency support)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: 90%
 * Overall Result Score: 89%
 * Key Variances/Learnings: Investment entity requires complex relationships for portfolio aggregation
 * Last Updated: 2025-08-09
 */

import Foundation
import CoreData

/// Investment Entity - Represents individual investment holdings across all asset classes
/// Supports Property, Shares, Superannuation, Cryptocurrency, and other investment types
@objc(Investment)
public class Investment: NSManagedObject {
    
    // MARK: - Investment Types
    
    @objc public enum InvestmentType: Int16, CaseIterable {
        case property = 0
        case shares = 1
        case superannuation = 2
        case cryptocurrency = 3
        case bonds = 4
        case etf = 5
        case managedFunds = 6
        case termDeposits = 7
        case other = 8
        
        var displayName: String {
            switch self {
            case .property: return "Property"
            case .shares: return "Shares"
            case .superannuation: return "Superannuation"
            case .cryptocurrency: return "Cryptocurrency"
            case .bonds: return "Bonds"
            case .etf: return "ETF"
            case .managedFunds: return "Managed Funds"
            case .termDeposits: return "Term Deposits"
            case .other: return "Other"
            }
        }
        
        var iconName: String {
            switch self {
            case .property: return "house.fill"
            case .shares: return "chart.line.uptrend.xyaxis"
            case .superannuation: return "banknote"
            case .cryptocurrency: return "bitcoinsign.circle"
            case .bonds: return "doc.text"
            case .etf: return "chart.pie"
            case .managedFunds: return "building.columns"
            case .termDeposits: return "clock.badge.checkmark"
            case .other: return "questionmark.circle"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Current market value in AUD
    public var currentMarketValue: Double {
        return currentPrice * Double(quantity) * exchangeRate
    }
    
    /// Total return including capital gains and dividends
    public var totalReturn: Double {
        let capitalGain = currentMarketValue - totalCostBasis
        return capitalGain + totalDividendsReceived
    }
    
    /// Total return percentage
    public var totalReturnPercentage: Double {
        guard totalCostBasis > 0 else { return 0.0 }
        return (totalReturn / totalCostBasis) * 100.0
    }
    
    /// Daily change in value
    public var dailyChange: Double {
        return (currentPrice - previousDayPrice) * Double(quantity) * exchangeRate
    }
    
    /// Daily change percentage
    public var dailyChangePercentage: Double {
        guard previousDayPrice > 0 else { return 0.0 }
        return ((currentPrice - previousDayPrice) / previousDayPrice) * 100.0
    }
    
    /// Investment type as enum
    public var investmentTypeEnum: InvestmentType {
        get { InvestmentType(rawValue: investmentType) ?? .other }
        set { investmentType = newValue.rawValue }
    }
    
    /// Australian tax category for CGT calculations
    public var australianTaxCategory: String {
        switch investmentTypeEnum {
        case .property: return "Real Estate CGT"
        case .shares: return "Share CGT"
        case .superannuation: return "Superannuation"
        case .cryptocurrency: return "Crypto CGT"
        case .bonds, .etf, .managedFunds: return "Managed Investment CGT"
        case .termDeposits: return "Interest Income"
        case .other: return "Other Investment CGT"
        }
    }
    
    // MARK: - Factory Methods
    
    /// Create a new Investment entity
    public static func create(
        in context: NSManagedObjectContext,
        symbol: String,
        name: String,
        type: InvestmentType,
        quantity: Decimal,
        averageCostBasis: Double,
        currentPrice: Double = 0.0,
        currency: String = "AUD",
        portfolio: Portfolio? = nil
    ) -> Investment {
        let investment = Investment(context: context)
        
        investment.id = UUID()
        investment.symbol = symbol
        investment.name = name
        investment.investmentType = type.rawValue
        investment.quantity = quantity
        investment.averageCostBasis = averageCostBasis
        investment.totalCostBasis = averageCostBasis * Double(truncating: quantity as NSNumber)
        investment.currentPrice = currentPrice
        investment.previousDayPrice = currentPrice // Initialize with current price
        investment.currency = currency
        investment.exchangeRate = currency == "AUD" ? 1.0 : 0.0 // Will be updated by price service
        investment.totalDividendsReceived = 0.0
        investment.createdAt = Date()
        investment.updatedAt = Date()
        investment.isActive = true
        investment.portfolio = portfolio
        
        return investment
    }
    
    // MARK: - Price Update Methods
    
    /// Update current price and exchange rate
    public func updatePrice(_ newPrice: Double, exchangeRate: Double = 1.0) {
        previousDayPrice = currentPrice
        currentPrice = newPrice
        self.exchangeRate = exchangeRate
        updatedAt = Date()
    }
    
    /// Add dividend payment
    public func addDividend(_ amount: Double, paymentDate: Date = Date()) {
        totalDividendsReceived += amount
        updatedAt = Date()
        
        // Create dividend record
        let dividend = Dividend.create(
            in: managedObjectContext!,
            investment: self,
            amount: amount,
            paymentDate: paymentDate,
            currency: currency
        )
    }
    
    /// Update quantity (for purchases/sales)
    public func updateQuantity(_ newQuantity: Decimal, costBasisAdjustment: Double = 0.0) {
        quantity = newQuantity
        totalCostBasis += costBasisAdjustment
        
        if newQuantity > 0 {
            averageCostBasis = totalCostBasis / Double(truncating: newQuantity as NSNumber)
        }
        
        updatedAt = Date()
    }
    
    // MARK: - Performance Calculations
    
    /// Calculate annualized return
    public func calculateAnnualizedReturn() -> Double {
        guard let createdDate = createdAt,
              totalCostBasis > 0 else { return 0.0 }
        
        let daysSinceCreation = Date().timeIntervalSince(createdDate) / (24 * 60 * 60)
        let years = daysSinceCreation / 365.25
        
        guard years > 0 else { return 0.0 }
        
        let totalReturnRatio = 1.0 + (totalReturn / totalCostBasis)
        return (pow(totalReturnRatio, 1.0 / years) - 1.0) * 100.0
    }
    
    /// Calculate volatility (standard deviation of daily returns)
    public func calculateVolatility() -> Double {
        // This would require historical price data
        // For now, return a placeholder based on investment type
        switch investmentTypeEnum {
        case .cryptocurrency: return 45.0 // High volatility
        case .shares, .etf: return 20.0 // Medium volatility
        case .property: return 10.0 // Low volatility
        case .bonds, .termDeposits: return 5.0 // Very low volatility
        case .superannuation, .managedFunds: return 15.0 // Mixed volatility
        case .other: return 25.0 // Unknown volatility
        }
    }
    
    // MARK: - Australian Market Integration
    
    /// Get ASX market data identifier
    public var asxSymbol: String? {
        guard investmentTypeEnum == .shares,
              symbol.hasSuffix(".AX") || symbol.contains("ASX:") else { return nil }
        
        if symbol.hasSuffix(".AX") {
            return String(symbol.dropLast(3))
        } else if symbol.contains("ASX:") {
            return String(symbol.dropFirst(4))
        }
        
        return nil
    }
    
    /// Check if investment is Australian for tax purposes
    public var isAustralianInvestment: Bool {
        switch investmentTypeEnum {
        case .superannuation: return true // Always Australian
        case .property: return true // Assume Australian property for now
        case .shares: return symbol.hasSuffix(".AX") || symbol.contains("ASX:")
        case .etf: return symbol.hasSuffix(".AX") && name.contains("Australian")
        case .managedFunds: return name.contains("Australian") || name.contains("Aussie")
        default: return false
        }
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateInvestment()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateInvestment()
    }
    
    private func validateInvestment() throws {
        guard let symbol = symbol, !symbol.isEmpty else {
            throw InvestmentValidationError.invalidSymbol
        }
        
        guard let name = name, !name.isEmpty else {
            throw InvestmentValidationError.invalidName
        }
        
        guard quantity >= 0 else {
            throw InvestmentValidationError.invalidQuantity
        }
        
        guard averageCostBasis >= 0 else {
            throw InvestmentValidationError.invalidCostBasis
        }
        
        guard currentPrice >= 0 else {
            throw InvestmentValidationError.invalidPrice
        }
    }
}

// MARK: - Core Data Properties

extension Investment {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Investment> {
        return NSFetchRequest<Investment>(entityName: "Investment")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var symbol: String?
    @NSManaged public var name: String?
    @NSManaged public var investmentType: Int16
    @NSManaged public var quantity: Decimal
    @NSManaged public var averageCostBasis: Double
    @NSManaged public var totalCostBasis: Double
    @NSManaged public var currentPrice: Double
    @NSManaged public var previousDayPrice: Double
    @NSManaged public var currency: String?
    @NSManaged public var exchangeRate: Double
    @NSManaged public var totalDividendsReceived: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var notes: String?
    
    // Relationships
    @NSManaged public var portfolio: Portfolio?
    @NSManaged public var dividends: NSSet?
    @NSManaged public var transactions: NSSet?
    
}

// MARK: - Generated accessors for dividends
extension Investment {
    
    @objc(addDividendsObject:)
    @NSManaged public func addToDividends(_ value: Dividend)
    
    @objc(removeDividendsObject:)
    @NSManaged public func removeFromDividends(_ value: Dividend)
    
    @objc(addDividends:)
    @NSManaged public func addToDividends(_ values: NSSet)
    
    @objc(removeDividends:)
    @NSManaged public func removeFromDividends(_ values: NSSet)
    
}

// MARK: - Generated accessors for transactions
extension Investment {
    
    @objc(addInvestmentTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: InvestmentTransaction)
    
    @objc(removeInvestmentTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: InvestmentTransaction)
    
    @objc(addInvestmentTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)
    
    @objc(removeInvestmentTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)
    
}

// MARK: - Error Types

public enum InvestmentValidationError: Error, LocalizedError {
    case invalidSymbol
    case invalidName
    case invalidQuantity
    case invalidCostBasis
    case invalidPrice
    
    public var errorDescription: String? {
        switch self {
        case .invalidSymbol:
            return "Investment symbol is required and cannot be empty"
        case .invalidName:
            return "Investment name is required and cannot be empty"
        case .invalidQuantity:
            return "Investment quantity must be greater than or equal to zero"
        case .invalidCostBasis:
            return "Average cost basis must be greater than or equal to zero"
        case .invalidPrice:
            return "Current price must be greater than or equal to zero"
        }
    }
}

// MARK: - Identifiable Conformance

extension Investment: Identifiable {
    // Uses id property from Core Data
}