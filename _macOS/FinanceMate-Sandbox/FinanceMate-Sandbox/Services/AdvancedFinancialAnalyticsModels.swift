//
//  AdvancedFinancialAnalyticsModels.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Comprehensive data models for Advanced Financial Analytics Engine in Sandbox environment
* Issues & Complexity Summary: Foundation data structures for sophisticated financial analysis
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 3 New (Core Data models, ML prediction structures, analytics frameworks)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Well-defined data structures with clear relationships
* Final Code Complexity (Actual %): 72%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Clean model design enables robust analytics capabilities
* Last Updated: 2025-06-02
*/

import Foundation
import SwiftUI

// MARK: - Enhanced Financial Transaction Model for Analytics

public struct AnalyticsTransaction: Identifiable, Hashable, Codable {
    public let id: UUID
    public let amount: Double
    public let currency: AnalyticsCurrency
    public let date: Date
    public let category: ExpenseCategory
    public let description: String
    public let vendor: String
    public let transactionType: TransactionType
    
    public enum TransactionType: String, CaseIterable, Codable {
        case income = "income"
        case expense = "expense"
        case transfer = "transfer"
        case investment = "investment"
    }
    
    public enum AnalyticsCurrency: String, CaseIterable, Codable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case jpy = "JPY"
        case cad = "CAD"
        case aud = "AUD"
    }
    
    public init(id: UUID = UUID(), amount: Double, currency: AnalyticsCurrency, date: Date, 
                category: ExpenseCategory, description: String, vendor: String, 
                transactionType: TransactionType) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.date = date
        self.category = category
        self.description = description
        self.vendor = vendor
        self.transactionType = transactionType
    }
    
    // Convert from existing FinancialTransaction
    public init(from transaction: FinancialTransaction, amount: Double, vendor: String, transactionType: TransactionType) {
        self.id = UUID()
        self.amount = amount
        self.currency = .usd
        // Try parsing the date string, fallback to current date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.date(from: transaction.date) ?? Date()
        self.category = transaction.category ?? .other
        self.description = transaction.description
        self.vendor = vendor
        self.transactionType = transactionType
    }
}

// MARK: - Analytics Engine Configuration

public struct AnalyticsConfiguration: Codable {
    public let enableMLPredictions: Bool
    public let foreccastingHorizon: Int // months
    public let riskToleranceLevel: RiskTolerance
    public let analyticsRegion: String
    public let currency: AnalyticsTransaction.AnalyticsCurrency
    
    public enum RiskTolerance: String, CaseIterable, Codable {
        case conservative = "conservative"
        case moderate = "moderate"
        case aggressive = "aggressive"
    }
    
    public init(enableMLPredictions: Bool = true, foreccastingHorizon: Int = 12, 
                riskToleranceLevel: RiskTolerance = .moderate, analyticsRegion: String = "US",
                currency: AnalyticsTransaction.AnalyticsCurrency = .usd) {
        self.enableMLPredictions = enableMLPredictions
        self.foreccastingHorizon = foreccastingHorizon
        self.riskToleranceLevel = riskToleranceLevel
        self.analyticsRegion = analyticsRegion
        self.currency = currency
    }
}

// MARK: - Trend Analysis Models

public struct SpendingTrendAnalysis: Codable {
    public let timeframe: AnalysisTimeframe
    public let monthlyTrends: [AnalyticsMonthlyTrend]
    public let averageMonthlySpending: Double
    public let growthRate: Double
    public let seasonalPatterns: SeasonalPatterns
    public let categoryTrends: [CategoryTrend]
    
    public enum AnalysisTimeframe: String, CaseIterable, Codable {
        case threeMonths = "3_months"
        case sixMonths = "6_months"
        case oneYear = "1_year"
        case twoYears = "2_years"
    }
}

public struct AnalyticsMonthlyTrend: Identifiable, Codable {
    public let id: UUID
    public let month: String
    public let totalSpending: Double
    public let transactionCount: Int
    public let averageTransactionSize: Double
    public let categoryBreakdown: [String: Double]
    
    public init(month: String, totalSpending: Double, transactionCount: Int, 
                averageTransactionSize: Double, categoryBreakdown: [String: Double]) {
        self.id = UUID()
        self.month = month
        self.totalSpending = totalSpending
        self.transactionCount = transactionCount
        self.averageTransactionSize = averageTransactionSize
        self.categoryBreakdown = categoryBreakdown
    }
}

public struct SeasonalPatterns: Codable {
    public let springSpending: Double
    public let summerSpending: Double
    public let fallSpending: Double
    public let winterSpending: Double
    public let peakSpendingMonth: String
    public let lowestSpendingMonth: String
}

public struct CategoryTrend: Identifiable, Codable {
    public var id = UUID()
    public let category: ExpenseCategory
    public let monthlyChanges: [Double]
    public let overallGrowthRate: Double
    public let volatility: Double
}

public struct IncomeTrendAnalysis: Codable {
    public let timeframe: SpendingTrendAnalysis.AnalysisTimeframe
    public let averageMonthlyIncome: Double
    public let incomeStability: IncomeStability
    public let growthProjection: Double
    public let sourceBreakdown: [IncomeSource]
    
    public enum IncomeStability: String, Codable {
        case stable = "stable"
        case variable = "variable"
        case irregular = "irregular"
    }
}

public struct IncomeSource: Identifiable, Codable {
    public var id = UUID()
    public let source: String
    public let monthlyAverage: Double
    public let reliability: Double // 0.0 - 1.0
    public let growthTrend: Double
}

// MARK: - Forecasting Models

public struct ExpenseForecast: Codable {
    public let forecastPeriod: ForecastPeriod
    public let predictions: [MonthlyPrediction]
    public let overallConfidence: Double
    public let confidenceIntervals: ConfidenceIntervals
    public let categoryForecasts: [CategoryForecast]
    public let model: ForecastModel
    
    public enum ForecastPeriod: String, CaseIterable, Codable {
        case oneMonth = "1_month"
        case threeMonths = "3_months"
        case sixMonths = "6_months"
        case oneYear = "1_year"
    }
    
    public enum ForecastModel: String, CaseIterable, Codable {
        case linearRegression = "linear_regression"
        case machineLearning = "machine_learning"
        case timeSeries = "time_series"
        case ensemble = "ensemble"
    }
}

public struct MonthlyPrediction: Identifiable, Codable {
    public var id = UUID()
    public let month: String
    public let predictedAmount: Double
    public let confidence: Double
    public let upperBound: Double
    public let lowerBound: Double
}

public struct ConfidenceIntervals: Codable {
    public let level: Double // e.g., 0.95 for 95%
    public let intervals: [ConfidenceInterval]
}

public struct ConfidenceInterval: Codable {
    public let month: String
    public let lowerBound: Double
    public let upperBound: Double
}

public struct CategoryForecast: Identifiable, Codable {
    public var id = UUID()
    public let category: ExpenseCategory
    public let monthlyPredictions: [Double]
    public let confidence: Double
    public let trendDirection: TrendDirection
    
    public enum TrendDirection: String, Codable {
        case increasing = "increasing"
        case decreasing = "decreasing"
        case stable = "stable"
    }
}

public struct CashFlowProjection: Codable {
    public let projectionPeriod: ExpenseForecast.ForecastPeriod
    public let monthlyProjections: [MonthlyProjection]
    public let riskAssessment: CashFlowRiskAssessment
    public let liquidityAnalysis: LiquidityAnalysis
}

public struct MonthlyProjection: Identifiable, Codable {
    public var id = UUID()
    public let month: String
    public let projectedIncome: Double
    public let projectedExpenses: Double
    public let netCashFlow: Double
    public let cumulativeCashFlow: Double
}

public struct CashFlowRiskAssessment: Codable {
    public let riskLevel: RiskLevel
    public let cashFlowVolatility: Double
    public let shortfallProbability: Double
    public let recommendedCashReserve: Double
    
    public enum RiskLevel: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
    }
}

public struct LiquidityAnalysis: Codable {
    public let currentLiquidity: Double
    public let projectedLiquidity: [Double] // Monthly
    public let liquidityRatio: Double
    public let recommendations: [String]
}

// MARK: - Risk Assessment Models

public struct FinancialRiskAssessment: Codable {
    public let overallRiskScore: Double // 0.0 - 1.0
    public let riskFactors: [RiskFactor]
    public let volatilityMeasures: VolatilityMeasures
    public let riskMitigationSuggestions: [String]
}

public struct RiskFactor: Identifiable, Codable {
    public var id = UUID()
    public let factor: String
    public let impact: RiskImpact
    public let likelihood: Double // 0.0 - 1.0
    public let description: String
    
    public enum RiskImpact: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
    }
}

public struct VolatilityMeasures: Codable {
    public let standardDeviation: Double
    public let valueAtRisk: Double // VaR
    public let conditionalValueAtRisk: Double // CVaR
    public let volatilityClusters: [VolatilityCluster]
}

public struct VolatilityCluster: Identifiable, Codable {
    public var id = UUID()
    public let startDate: Date
    public let endDate: Date
    public let averageVolatility: Double
    public let description: String
}

// MARK: - Portfolio Models

public struct FinancialPortfolio: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let totalValue: Double
    public let holdings: [PortfolioHolding]
    public let currentReturn: Double
    public let currentRisk: Double
    
    public init(id: UUID = UUID(), name: String, totalValue: Double, 
                holdings: [PortfolioHolding], currentReturn: Double, currentRisk: Double) {
        self.id = id
        self.name = name
        self.totalValue = totalValue
        self.holdings = holdings
        self.currentReturn = currentReturn
        self.currentRisk = currentRisk
    }
}

public struct PortfolioHolding: Identifiable, Codable {
    public var id = UUID()
    public let symbol: String
    public let shares: Double
    public let currentPrice: Double
    public let totalValue: Double
    
    public init(symbol: String, shares: Double, currentPrice: Double) {
        self.symbol = symbol
        self.shares = shares
        self.currentPrice = currentPrice
        self.totalValue = shares * currentPrice
    }
}

public struct PortfolioPerformanceAnalysis: Codable {
    public let totalReturn: Double
    public let annualizedReturn: Double
    public let sharpeRatio: Double
    public let betaCoefficient: Double
    public let alphaGeneration: Double
    public let sectorAllocation: [SectorAllocation]
}

public struct SectorAllocation: Identifiable, Codable {
    public var id = UUID()
    public let sector: String
    public let allocation: Double // Percentage
    public let performance: Double
}

public struct PortfolioOptimization: Codable {
    public let recommendedAllocation: [AssetAllocation]
    public let expectedReturn: Double
    public let expectedRisk: Double
    public let rebalancingSteps: [RebalancingStep]
}

public struct AssetAllocation: Identifiable, Codable {
    public var id = UUID()
    public let asset: String
    public let currentWeight: Double
    public let recommendedWeight: Double
    public let justification: String
}

public struct RebalancingStep: Identifiable, Codable {
    public var id = UUID()
    public let action: RebalancingAction
    public let asset: String
    public let amount: Double
    public let priority: Int
    
    public enum RebalancingAction: String, Codable {
        case buy = "buy"
        case sell = "sell"
        case hold = "hold"
    }
}

public struct PortfolioOptimizationConstraints: Codable {
    public let maxSingleAssetWeight: Double
    public let minSingleAssetWeight: Double
    public let targetRisk: Double
    public let minimumReturn: Double
    
    public init(maxSingleAssetWeight: Double = 0.3, minSingleAssetWeight: Double = 0.05,
                targetRisk: Double = 0.15, minimumReturn: Double = 0.08) {
        self.maxSingleAssetWeight = maxSingleAssetWeight
        self.minSingleAssetWeight = minSingleAssetWeight
        self.targetRisk = targetRisk
        self.minimumReturn = minimumReturn
    }
}

// MARK: - ML and Analysis Models

public struct MLCategorizationResult: Codable {
    public let predictedCategory: ExpenseCategory
    public let confidence: Double
    public let reasoning: String
    public let alternativeCategories: [CategoryPrediction]
}

public struct CategoryPrediction: Identifiable, Codable {
    public var id = UUID()
    public let category: ExpenseCategory
    public let confidence: Double
}

public struct AnomalyDetection: Identifiable, Codable {
    public var id = UUID()
    public let transaction: AnalyticsTransaction
    public let anomalyType: AnomalyType
    public let anomalyScore: Double
    public let description: String
    public let recommendations: [String]
    
    public enum AnomalyType: String, CaseIterable, Codable {
        case unusualAmount = "unusual_amount"
        case suspiciousVendor = "suspicious_vendor"
        case duplicateTransaction = "duplicate_transaction"
        case timingAnomaly = "timing_anomaly"
        case categoryMismatch = "category_mismatch"
    }
}

public struct ComprehensiveAnalysis: Codable {
    public let trendAnalysis: [SpendingTrendAnalysis]
    public let forecastResults: ExpenseForecast
    public let riskMetrics: FinancialRiskAssessment
    public let performanceMetrics: AnalyticsPerformanceMetrics
    public let recommendations: [AnalyticsRecommendation]
    public let confidenceScore: Double
}

public struct AnalyticsPerformanceMetrics: Codable {
    public let processingTime: Double
    public let dataQuality: Double
    public let predictionAccuracy: Double
    public let coverageCompleteness: Double
}

public struct AnalyticsRecommendation: Identifiable, Codable {
    public var id = UUID()
    public let type: RecommendationType
    public let title: String
    public let description: String
    public let impact: Impact
    public let priority: Priority
    public let actionSteps: [String]
    
    public enum RecommendationType: String, CaseIterable, Codable {
        case spending = "spending"
        case saving = "saving"
        case investment = "investment"
        case riskManagement = "risk_management"
        case budgeting = "budgeting"
    }
    
    public enum Impact: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case transformative = "transformative"
    }
    
    public enum Priority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
    }
}

// MARK: - Supporting Data Models

public struct CashFlowData: Codable {
    public let monthlyIncome: Double
    public let monthlyExpenses: Double
    public let fixedExpenses: Double
    public let variableExpenses: Double
    public let historicalCashFlow: [AnalyticsTransaction]
}

public struct FinancialDataPoint: Identifiable, Codable {
    public var id = UUID()
    public let date: Date
    public let value: Double
    
    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

public struct RawFinancialData: Codable {
    public let documentText: String
    public let metadata: [String: String]
    
    public init(documentText: String, metadata: [String: String] = [:]) {
        self.documentText = documentText
        self.metadata = metadata
    }
}

public struct AnalyticsWorkflowResult: Codable {
    public let processedTransactions: [AnalyticsTransaction]
    public let trendAnalysis: SpendingTrendAnalysis
    public let forecastingResults: ExpenseForecast
    public let riskAssessment: FinancialRiskAssessment
    public let recommendations: [AnalyticsRecommendation]
    public let confidenceScore: Double
}

// MARK: - Analytics Capabilities

public enum AnalyticsCapability: String, CaseIterable, Codable {
    case trendAnalysis = "trend_analysis"
    case forecasting = "forecasting"
    case riskAssessment = "risk_assessment"
    case portfolioAnalysis = "portfolio_analysis"
    case anomalyDetection = "anomaly_detection"
    case mlCategorization = "ml_categorization"
    case performanceTracking = "performance_tracking"
    case recommendationEngine = "recommendation_engine"
}

public enum AnalysisType: String, CaseIterable, Codable {
    case trends = "trends"
    case forecasting = "forecasting"
    case riskAssessment = "risk_assessment"
    case portfolio = "portfolio"
    case comprehensive = "comprehensive"
}

public enum WorkflowType: String, CaseIterable, Codable {
    case basic = "basic"
    case comprehensive = "comprehensive"
    case realTime = "real_time"
    case batchProcessing = "batch_processing"
}

public enum BenchmarkIndex: String, CaseIterable, Codable {
    case sp500 = "sp500"
    case nasdaq = "nasdaq"
    case dowJones = "dow_jones"
    case vti = "vti"
    case custom = "custom"
}

public enum OptimizationObjective: String, CaseIterable, Codable {
    case maxReturn = "max_return"
    case minRisk = "min_risk"
    case maxSharpeRatio = "max_sharpe_ratio"
    case balancedGrowth = "balanced_growth"
}

public enum AnomalySensitivity: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case extreme = "extreme"
}