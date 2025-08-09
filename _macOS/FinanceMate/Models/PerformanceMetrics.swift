//
// PerformanceMetrics.swift
// FinanceMate
//
// Created by AI Agent on 2025-08-09.
// Phase 5 Investment Portfolio Implementation: Performance Analytics Entity
//

/*
 * Purpose: Historical performance metrics tracking for portfolio and investment analysis
 * Issues & Complexity Summary: Time-series performance data, benchmark comparisons, risk metrics
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~180 (metrics calculation + time-series + benchmarking)
   - Core Algorithm Complexity: High (financial performance calculations, risk metrics)
   - Dependencies: Portfolio, Investment entities, historical data, market benchmarks
   - State Management Complexity: High (time-series data, performance calculations)
   - Novelty/Uncertainty Factor: Medium (Australian market benchmarks, risk calculations)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 86%
 * Initial Code Complexity Estimate: 89%
 * Final Code Complexity: 90%
 * Overall Result Score: 88%
 * Key Variances/Learnings: Performance metrics require careful time-series data management
 * Last Updated: 2025-08-09
 */

import Foundation
import CoreData

/// Performance Metrics Entity - Historical performance tracking for portfolios and investments
@objc(PerformanceMetrics)
public class PerformanceMetrics: NSManagedObject {
    
    // MARK: - Metrics Types
    
    @objc public enum MetricsType: Int16, CaseIterable {
        case daily = 0
        case weekly = 1
        case monthly = 2
        case quarterly = 3
        case yearly = 4
        case custom = 5
        
        var displayName: String {
            switch self {
            case .daily: return "Daily"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .quarterly: return "Quarterly"
            case .yearly: return "Yearly"
            case .custom: return "Custom"
            }
        }
        
        var daysInterval: Int {
            switch self {
            case .daily: return 1
            case .weekly: return 7
            case .monthly: return 30
            case .quarterly: return 90
            case .yearly: return 365
            case .custom: return 30 // Default
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Metrics type as enum
    public var metricsTypeEnum: MetricsType {
        get { MetricsType(rawValue: metricsType) ?? .monthly }
        set { metricsType = newValue.rawValue }
    }
    
    /// Calculate annualized return from total return
    public var annualizedReturn: Double {
        guard let startDate = periodStartDate,
              let endDate = periodEndDate else { return totalReturn }
        
        let daysDifference = endDate.timeIntervalSince(startDate) / (24 * 60 * 60)
        let years = daysDifference / 365.25
        
        guard years > 0 else { return totalReturn }
        
        let returnRatio = 1.0 + (totalReturn / 100.0)
        return (pow(returnRatio, 1.0 / years) - 1.0) * 100.0
    }
    
    /// Calculate Sharpe ratio (risk-adjusted return)
    public var sharpeRatio: Double {
        guard volatility > 0 else { return 0.0 }
        let riskFreeRate = 4.5 // Australian cash rate + margin
        return (annualizedReturn - riskFreeRate) / volatility
    }
    
    /// Calculate maximum drawdown percentage
    public var maxDrawdownPercentage: Double {
        guard maxDrawdown > 0, startingValue > 0 else { return 0.0 }
        return (maxDrawdown / startingValue) * 100.0
    }
    
    /// Calculate information ratio vs benchmark
    public var informationRatio: Double {
        guard trackingError > 0 else { return 0.0 }
        return excessReturn / trackingError
    }
    
    /// Check if performance beat benchmark
    public var beatBenchmark: Bool {
        return excessReturn > 0
    }
    
    // MARK: - Factory Methods
    
    /// Create new Performance Metrics
    public static func create(
        in context: NSManagedObjectContext,
        portfolio: Portfolio? = nil,
        investment: Investment? = nil,
        metricsType: MetricsType = .monthly,
        periodStart: Date,
        periodEnd: Date
    ) -> PerformanceMetrics {
        let metrics = PerformanceMetrics(context: context)
        
        metrics.id = UUID()
        metrics.metricsType = metricsType.rawValue
        metrics.periodStartDate = periodStart
        metrics.periodEndDate = periodEnd
        metrics.calculationDate = Date()
        metrics.currency = "AUD"
        metrics.createdAt = Date()
        metrics.updatedAt = Date()
        metrics.portfolio = portfolio
        metrics.investment = investment
        
        // Initialize values (will be calculated separately)
        metrics.startingValue = 0.0
        metrics.endingValue = 0.0
        metrics.totalReturn = 0.0
        metrics.dividendsReceived = 0.0
        metrics.capitalGains = 0.0
        metrics.volatility = 0.0
        metrics.maxDrawdown = 0.0
        metrics.benchmarkReturn = 0.0
        metrics.excessReturn = 0.0
        metrics.trackingError = 0.0
        metrics.beta = 1.0
        
        return metrics
    }
    
    // MARK: - Performance Calculations
    
    /// Update performance metrics with calculated values
    public func updateMetrics(
        startingValue: Double,
        endingValue: Double,
        dividends: Double = 0.0,
        benchmarkReturn: Double = 0.0
    ) {
        self.startingValue = startingValue
        self.endingValue = endingValue
        self.dividendsReceived = dividends
        
        // Calculate returns
        if startingValue > 0 {
            self.capitalGains = endingValue - startingValue
            self.totalReturn = ((endingValue + dividends - startingValue) / startingValue) * 100.0
        } else {
            self.capitalGains = 0.0
            self.totalReturn = 0.0
        }
        
        // Update benchmark comparison
        self.benchmarkReturn = benchmarkReturn
        self.excessReturn = self.totalReturn - benchmarkReturn
        
        self.updatedAt = Date()
    }
    
    /// Calculate risk metrics (volatility, max drawdown, beta)
    public func updateRiskMetrics(
        volatility: Double,
        maxDrawdown: Double,
        beta: Double = 1.0,
        trackingError: Double = 0.0
    ) {
        self.volatility = volatility
        self.maxDrawdown = maxDrawdown
        self.beta = beta
        self.trackingError = trackingError
        self.updatedAt = Date()
    }
    
    // MARK: - Australian Market Benchmarks
    
    /// Get appropriate benchmark return for comparison
    public static func getBenchmarkReturn(
        for type: MetricsType,
        startDate: Date,
        endDate: Date,
        benchmarkType: BenchmarkType = .asx200
    ) -> Double {
        // In practice, this would fetch actual benchmark data from APIs
        // For now, return simulated benchmark returns based on type
        let daysDifference = endDate.timeIntervalSince(startDate) / (24 * 60 * 60)
        let years = daysDifference / 365.25
        
        let annualBenchmarkReturn: Double
        switch benchmarkType {
        case .asx200: annualBenchmarkReturn = 8.5 // Historical ASX 200 return
        case .asx300: annualBenchmarkReturn = 8.2
        case .allOrdinaries: annualBenchmarkReturn = 8.0
        case .cash: annualBenchmarkReturn = 4.5 // Cash rate
        case .bonds: annualBenchmarkReturn = 5.5 // Government bonds
        case .property: annualBenchmarkReturn = 6.5 // Property index
        case .international: annualBenchmarkReturn = 10.0 // International markets
        }
        
        guard years > 0 else { return 0.0 }
        
        // Convert annual return to period return
        let periodReturn = pow(1.0 + (annualBenchmarkReturn / 100.0), years) - 1.0
        return periodReturn * 100.0
    }
    
    // MARK: - Historical Analysis
    
    /// Get performance metrics for time period
    public static func getMetricsForPeriod(
        _ startDate: Date,
        _ endDate: Date,
        portfolio: Portfolio? = nil,
        investment: Investment? = nil,
        in context: NSManagedObjectContext
    ) -> [PerformanceMetrics] {
        let request: NSFetchRequest<PerformanceMetrics> = PerformanceMetrics.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "periodStartDate >= %@ AND periodEndDate <= %@", startDate as NSDate, endDate as NSDate)
        ]
        
        if let portfolio = portfolio {
            predicates.append(NSPredicate(format: "portfolio == %@", portfolio))
        }
        
        if let investment = investment {
            predicates.append(NSPredicate(format: "investment == %@", investment))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PerformanceMetrics.periodStartDate, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching performance metrics: \(error)")
            return []
        }
    }
    
    /// Calculate rolling performance metrics
    public static func calculateRollingMetrics(
        for portfolio: Portfolio,
        windowDays: Int = 90,
        in context: NSManagedObjectContext
    ) -> [PerformanceMetrics] {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -windowDays, to: endDate)!
        
        // This would typically calculate rolling metrics over the specified window
        // For now, return existing metrics in the period
        return getMetricsForPeriod(startDate, endDate, portfolio: portfolio, in: context)
    }
    
    // MARK: - Performance Comparison
    
    /// Compare performance against benchmark
    public func compareAgainstBenchmark(_ benchmarkType: BenchmarkType = .asx200) -> PerformanceComparison {
        guard let startDate = periodStartDate,
              let endDate = periodEndDate else {
            return PerformanceComparison(outperformance: 0, consistency: 0, correlation: 0)
        }
        
        let benchmarkReturn = Self.getBenchmarkReturn(
            for: metricsTypeEnum,
            startDate: startDate,
            endDate: endDate,
            benchmarkType: benchmarkType
        )
        
        let outperformance = totalReturn - benchmarkReturn
        
        // Simplified correlation and consistency calculations
        let consistency = abs(excessReturn) < 2.0 ? 0.8 : 0.4 // Simplified consistency measure
        let correlation = beta * 0.8 // Simplified correlation based on beta
        
        return PerformanceComparison(
            outperformance: outperformance,
            consistency: consistency,
            correlation: correlation
        )
    }
    
    // MARK: - Validation
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateMetrics()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateMetrics()
    }
    
    private func validateMetrics() throws {
        guard let startDate = periodStartDate,
              let endDate = periodEndDate else {
            throw PerformanceMetricsValidationError.invalidDateRange
        }
        
        guard endDate >= startDate else {
            throw PerformanceMetricsValidationError.invalidDateRange
        }
        
        guard startingValue >= 0 else {
            throw PerformanceMetricsValidationError.invalidStartingValue
        }
        
        guard endingValue >= 0 else {
            throw PerformanceMetricsValidationError.invalidEndingValue
        }
    }
}

// MARK: - Core Data Properties

extension PerformanceMetrics {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PerformanceMetrics> {
        return NSFetchRequest<PerformanceMetrics>(entityName: "PerformanceMetrics")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var metricsType: Int16
    @NSManaged public var periodStartDate: Date?
    @NSManaged public var periodEndDate: Date?
    @NSManaged public var calculationDate: Date?
    @NSManaged public var startingValue: Double
    @NSManaged public var endingValue: Double
    @NSManaged public var totalReturn: Double
    @NSManaged public var dividendsReceived: Double
    @NSManaged public var capitalGains: Double
    @NSManaged public var volatility: Double
    @NSManaged public var maxDrawdown: Double
    @NSManaged public var benchmarkReturn: Double
    @NSManaged public var excessReturn: Double
    @NSManaged public var trackingError: Double
    @NSManaged public var beta: Double
    @NSManaged public var currency: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var notes: String?
    
    // Relationships
    @NSManaged public var portfolio: Portfolio?
    @NSManaged public var investment: Investment?
    
}

// MARK: - Supporting Types

public enum BenchmarkType: CaseIterable {
    case asx200
    case asx300
    case allOrdinaries
    case cash
    case bonds
    case property
    case international
    
    var displayName: String {
        switch self {
        case .asx200: return "ASX 200"
        case .asx300: return "ASX 300"
        case .allOrdinaries: return "All Ordinaries"
        case .cash: return "Cash Rate"
        case .bonds: return "Government Bonds"
        case .property: return "Property Index"
        case .international: return "International"
        }
    }
}

public struct PerformanceComparison {
    let outperformance: Double // Performance vs benchmark
    let consistency: Double    // Consistency of outperformance (0-1)
    let correlation: Double    // Correlation with benchmark (0-1)
}

// MARK: - Error Types

public enum PerformanceMetricsValidationError: Error, LocalizedError {
    case invalidDateRange
    case invalidStartingValue
    case invalidEndingValue
    
    public var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "Period end date must be after start date"
        case .invalidStartingValue:
            return "Starting value must be greater than or equal to zero"
        case .invalidEndingValue:
            return "Ending value must be greater than or equal to zero"
        }
    }
}

// MARK: - Identifiable Conformance

extension PerformanceMetrics: Identifiable {
    // Uses id property from Core Data
}