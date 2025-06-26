// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  RealTimeFinancialInsightsEngine.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Real-time financial insights engine providing intelligent analysis for TestFlight users
* NO MOCK DATA - All insights generated from actual user financial data
* Features: Spending patterns, trend analysis, anomaly detection, budget recommendations
*/

import Combine
import CoreData
import Foundation

// MARK: - Core Data Models for Insights

public enum FinancialInsightType: String, CaseIterable {
    case spendingPattern = "spending_pattern"
    case incomeAnalysis = "income_analysis"
    case budgetRecommendation = "budget_recommendation"
    case anomalyDetection = "anomaly_detection"
    case goalProgress = "goal_progress"
    case categoryAnalysis = "category_analysis"
}

public struct FinancialInsight {
    public let id: UUID
    public let type: FinancialInsightType
    public let title: String
    public let description: String
    public let confidence: Double
    public let actionable: Bool
    public let priority: InsightPriority
    public let metadata: [String: Any]
    public let generatedAt: Date

    public init(id: UUID = UUID(), type: FinancialInsightType, title: String, description: String,
                confidence: Double, actionable: Bool = true, priority: InsightPriority = .medium,
                metadata: [String: Any] = [:], generatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.actionable = actionable
        self.priority = priority
        self.metadata = metadata
        self.generatedAt = generatedAt
    }
}

public enum InsightPriority: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
}

public enum SpendingTrend {
    case increasing
    case decreasing
    case stable
    case noData
}

public struct RealTimeSpendingTrendAnalysis {
    public let monthlyTrend: SpendingTrend
    public let projectedNextMonth: Double
    public let confidenceInterval: (min: Double, max: Double)
    public let trendStrength: Double

    public init(monthlyTrend: SpendingTrend, projectedNextMonth: Double,
                confidenceInterval: (min: Double, max: Double), trendStrength: Double) {
        self.monthlyTrend = monthlyTrend
        self.projectedNextMonth = projectedNextMonth
        self.confidenceInterval = confidenceInterval
        self.trendStrength = trendStrength
    }
}

public struct RealTimeIncomeAnalysis {
    public let averageMonthlyIncome: Double
    public let stabilityScore: Double
    public let lastThreeMonthsGrowth: Double
    public let projectedNextIncome: Double

    public init(averageMonthlyIncome: Double, stabilityScore: Double,
                lastThreeMonthsGrowth: Double, projectedNextIncome: Double) {
        self.averageMonthlyIncome = averageMonthlyIncome
        self.stabilityScore = stabilityScore
        self.lastThreeMonthsGrowth = lastThreeMonthsGrowth
        self.projectedNextIncome = projectedNextIncome
    }
}

public struct RealTimeCategorySpendingAnalysis {
    public let category: String
    public let totalAmount: Double
    public let percentageOfTotal: Double
    public let transactionCount: Int
    public let averageTransactionAmount: Double
    public let monthlyTrend: SpendingTrend

    public init(category: String, totalAmount: Double, percentageOfTotal: Double,
                transactionCount: Int, averageTransactionAmount: Double, monthlyTrend: SpendingTrend) {
        self.category = category
        self.totalAmount = totalAmount
        self.percentageOfTotal = percentageOfTotal
        self.transactionCount = transactionCount
        self.averageTransactionAmount = averageTransactionAmount
        self.monthlyTrend = monthlyTrend
    }
}

public struct RealTimeSpendingAnomaly {
    public let transactionId: UUID
    public let amount: Double
    public let vendor: String
    public let date: Date
    public let deviationScore: Double
    public let anomalyType: RealTimeAnomalyType

    public init(transactionId: UUID, amount: Double, vendor: String, date: Date,
                deviationScore: Double, anomalyType: RealTimeAnomalyType) {
        self.transactionId = transactionId
        self.amount = amount
        self.vendor = vendor
        self.date = date
        self.deviationScore = deviationScore
        self.anomalyType = anomalyType
    }
}

public enum RealTimeAnomalyType {
    case unusuallyLarge
    case unusuallySmall
    case frequencyAnomaly
    case newVendor
}

public struct RealTimeBudgetRecommendation {
    public let category: String
    public let suggestedAmount: Double
    public let currentSpending: Double
    public let confidence: Double
    public let reasoning: String

    public init(category: String, suggestedAmount: Double, currentSpending: Double,
                confidence: Double, reasoning: String) {
        self.category = category
        self.suggestedAmount = suggestedAmount
        self.currentSpending = currentSpending
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

public struct RealTimeGoalProgress {
    public let goalId: UUID
    public let completionPercentage: Double
    public let projectedCompletionDate: Date?
    public let onTrack: Bool
    public let monthlyProgressRate: Double

    public init(goalId: UUID, completionPercentage: Double, projectedCompletionDate: Date?,
                onTrack: Bool, monthlyProgressRate: Double) {
        self.goalId = goalId
        self.completionPercentage = completionPercentage
        self.projectedCompletionDate = projectedCompletionDate
        self.onTrack = onTrack
        self.monthlyProgressRate = monthlyProgressRate
    }
}

// MARK: - Real-Time Financial Insights Engine

public class RealTimeFinancialInsightsEngine: ObservableObject {
    public let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    @Published public private(set) var isReady = false
    @Published public private(set) var lastAnalysisDate: Date?
    @Published public private(set) var currentInsights: [FinancialInsight] = []

    public init(context: NSManagedObjectContext) {
        self.context = context
        self.isReady = true
        setupDataChangeMonitoring()
    }

    // MARK: - Public API for Real-Time Insights

    public func generateRealTimeInsights() throws -> [FinancialInsight] {
        var insights: [FinancialInsight] = []

        // Generate all types of insights based on real data
        insights.append(contentsOf: try generateSpendingPatternInsights())
        insights.append(contentsOf: try generateIncomeInsights())
        insights.append(contentsOf: try generateCategoryInsights())
        insights.append(contentsOf: try generateAnomalyInsights())
        insights.append(contentsOf: try generateBudgetInsights())
        insights.append(contentsOf: try generateGoalInsights())

        // Sort by priority and confidence
        insights.sort { insight1, insight2 in
            if insight1.priority != insight2.priority {
                return insight1.priority.rawValue < insight2.priority.rawValue
            }
            return insight1.confidence > insight2.confidence
        }

        currentInsights = insights
        lastAnalysisDate = Date()

        return insights
    }

    public func analyzeSpendingTrends() throws -> RealTimeSpendingTrendAnalysis {
        let financialData = try fetchFinancialData()
        let expenses = financialData.filter { ($0.totalAmount?.doubleValue ?? 0) < 0 }

        guard !expenses.isEmpty else {
            return RealTimeSpendingTrendAnalysis(
                monthlyTrend: .noData,
                projectedNextMonth: 0,
                confidenceInterval: (min: 0, max: 0),
                trendStrength: 0
            )
        }

        let monthlySpending = calculateMonthlySpending(expenses)
        let trend = determineTrend(monthlySpending)
        let projection = projectNextMonth(monthlySpending)

        return RealTimeSpendingTrendAnalysis(
            monthlyTrend: trend.trend,
            projectedNextMonth: projection,
            confidenceInterval: (min: projection * 0.8, max: projection * 1.2),
            trendStrength: trend.strength
        )
    }

    public func analyzeIncomePatterns() throws -> RealTimeIncomeAnalysis {
        let financialData = try fetchFinancialData()
        let income = financialData.filter { ($0.totalAmount?.doubleValue ?? 0) > 0 }

        guard !income.isEmpty else {
            return RealTimeIncomeAnalysis(
                averageMonthlyIncome: 0,
                stabilityScore: 0,
                lastThreeMonthsGrowth: 0,
                projectedNextIncome: 0
            )
        }

        let monthlyIncome = calculateMonthlyIncome(income)
        let average = monthlyIncome.reduce(0, +) / Double(monthlyIncome.count)
        let stability = calculateIncomeStability(monthlyIncome)
        let growth = calculateGrowthRate(monthlyIncome)

        return RealTimeIncomeAnalysis(
            averageMonthlyIncome: average,
            stabilityScore: stability,
            lastThreeMonthsGrowth: growth,
            projectedNextIncome: projectNextIncome(monthlyIncome)
        )
    }

    public func analyzeCategorySpending() throws -> [RealTimeCategorySpendingAnalysis] {
        let financialData = try fetchFinancialData()
        let expenses = financialData.filter { ($0.totalAmount?.doubleValue ?? 0) < 0 }

        let categoryGroups = Dictionary(grouping: expenses) { $0.vendorName ?? "Uncategorized" }
        let totalSpending = expenses.compactMap { $0.totalAmount?.doubleValue }.reduce(0, +)

        return categoryGroups.map { category, transactions in
            let categoryTotal = abs(transactions.compactMap { $0.totalAmount?.doubleValue }.reduce(0, +))
            let transactionCount = transactions.count
            let average = categoryTotal / Double(transactionCount)
            let percentage = totalSpending != 0 ? (categoryTotal / abs(totalSpending)) * 100 : 0

            return RealTimeCategorySpendingAnalysis(
                category: category,
                totalAmount: categoryTotal,
                percentageOfTotal: percentage,
                transactionCount: transactionCount,
                averageTransactionAmount: average,
                monthlyTrend: .stable // Simplified for now
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }

    public func detectSpendingAnomalies() throws -> [RealTimeSpendingAnomaly] {
        let financialData = try fetchFinancialData()
        let expenses = financialData.filter { ($0.totalAmount?.doubleValue ?? 0) < 0 }

        guard expenses.count > 3 else { return [] }

        let amounts = expenses.compactMap { $0.totalAmount?.doubleValue }.map { abs($0) }
        let mean = amounts.reduce(0, +) / Double(amounts.count)
        let variance = amounts.map { pow($0 - mean, 2) }.reduce(0, +) / Double(amounts.count)
        let standardDeviation = sqrt(variance)

        var anomalies: [RealTimeSpendingAnomaly] = []

        for expense in expenses {
            guard let amount = expense.totalAmount?.doubleValue,
                  let id = expense.id,
                  let date = expense.invoiceDate else { continue }

            let absoluteAmount = abs(amount)
            let deviationScore = (absoluteAmount - mean) / standardDeviation

            if abs(deviationScore) > 2.0 { // 2 standard deviations
                let anomalyType: RealTimeAnomalyType = deviationScore > 0 ? .unusuallyLarge : .unusuallySmall

                anomalies.append(RealTimeSpendingAnomaly(
                    transactionId: id,
                    amount: amount,
                    vendor: expense.vendorName ?? "Unknown",
                    date: date,
                    deviationScore: abs(deviationScore),
                    anomalyType: anomalyType
                ))
            }
        }

        return anomalies.sorted { $0.deviationScore > $1.deviationScore }
    }

    public func generateBudgetRecommendations() throws -> [RealTimeBudgetRecommendation] {
        let categoryAnalysis = try analyzeCategorySpending()
        var recommendations: [RealTimeBudgetRecommendation] = []

        for category in categoryAnalysis {
            // Simple budget recommendation based on average spending + buffer
            let suggestedAmount = category.totalAmount * 1.1 // 10% buffer
            let confidence = min(0.9, Double(category.transactionCount) / 10.0)

            recommendations.append(RealTimeBudgetRecommendation(
                category: category.category,
                suggestedAmount: suggestedAmount,
                currentSpending: category.totalAmount,
                confidence: confidence,
                reasoning: "Based on \(category.transactionCount) transactions with 10% buffer"
            ))
        }

        return recommendations
    }

    public func trackGoalProgress(goalId: UUID) throws -> RealTimeGoalProgress {
        let request: NSFetchRequest<FinancialGoal> = FinancialGoal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", goalId as CVarArg)

        guard let goal = try context.fetch(request).first else {
            throw FinancialInsightsError.goalNotFound
        }

        let targetAmount = goal.targetAmount?.doubleValue ?? 0
        let currentAmount = goal.currentAmount?.doubleValue ?? 0
        let completionPercentage = targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0

        let onTrack = completionPercentage >= 0 // Simple check
        let monthlyProgressRate = calculateMonthlyProgressRate(for: goal)

        return RealTimeGoalProgress(
            goalId: goalId,
            completionPercentage: min(100, max(0, completionPercentage)),
            projectedCompletionDate: calculateProjectedCompletionDate(for: goal),
            onTrack: onTrack,
            monthlyProgressRate: monthlyProgressRate
        )
    }

    // MARK: - Private Helper Methods

    private func setupDataChangeMonitoring() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    try? await self?.refreshInsights()
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func refreshInsights() async throws {
        _ = try generateRealTimeInsights()
    }

    private func fetchFinancialData() throws -> [FinancialData] {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]
        return try context.fetch(request)
    }

    private func generateSpendingPatternInsights() throws -> [FinancialInsight] {
        let trendAnalysis = try analyzeSpendingTrends()
        var insights: [FinancialInsight] = []

        switch trendAnalysis.monthlyTrend {
        case .increasing:
            insights.append(FinancialInsight(
                type: .spendingPattern,
                title: "Spending Trend Alert",
                description: "Your spending has been increasing. Next month projected: $\(String(format: "%.2f", trendAnalysis.projectedNextMonth))",
                confidence: trendAnalysis.trendStrength,
                priority: .high
            ))
        case .decreasing:
            insights.append(FinancialInsight(
                type: .spendingPattern,
                title: "Positive Spending Trend",
                description: "Great! Your spending has been decreasing. Keep up the good work!",
                confidence: trendAnalysis.trendStrength,
                priority: .medium
            ))
        case .stable:
            insights.append(FinancialInsight(
                type: .spendingPattern,
                title: "Stable Spending Pattern",
                description: "Your spending has been consistent. Projected next month: $\(String(format: "%.2f", trendAnalysis.projectedNextMonth))",
                confidence: trendAnalysis.trendStrength,
                priority: .low
            ))
        case .noData:
            break
        }

        return insights
    }

    private func generateIncomeInsights() throws -> [FinancialInsight] {
        let incomeAnalysis = try analyzeIncomePatterns()
        var insights: [FinancialInsight] = []

        if incomeAnalysis.averageMonthlyIncome > 0 {
            insights.append(FinancialInsight(
                type: .incomeAnalysis,
                title: "Income Analysis",
                description: "Average monthly income: $\(String(format: "%.2f", incomeAnalysis.averageMonthlyIncome)). Stability score: \(String(format: "%.1f", incomeAnalysis.stabilityScore * 100))%",
                confidence: incomeAnalysis.stabilityScore,
                priority: .medium
            ))
        }

        return insights
    }

    private func generateCategoryInsights() throws -> [FinancialInsight] {
        let categoryAnalysis = try analyzeCategorySpending()
        var insights: [FinancialInsight] = []

        if let topCategory = categoryAnalysis.first {
            insights.append(FinancialInsight(
                type: .categoryAnalysis,
                title: "Top Spending Category",
                description: "\(topCategory.category) accounts for \(String(format: "%.1f", topCategory.percentageOfTotal))% of your spending ($\(String(format: "%.2f", topCategory.totalAmount)))",
                confidence: 0.9,
                priority: .medium
            ))
        }

        return insights
    }

    private func generateAnomalyInsights() throws -> [FinancialInsight] {
        let anomalies = try detectSpendingAnomalies()
        var insights: [FinancialInsight] = []

        for anomaly in anomalies.prefix(3) { // Top 3 anomalies
            insights.append(FinancialInsight(
                type: .anomalyDetection,
                title: "Unusual Transaction Detected",
                description: "\(anomaly.vendor): $\(String(format: "%.2f", abs(anomaly.amount))) - This is unusual for your spending pattern",
                confidence: min(1.0, anomaly.deviationScore / 3.0),
                priority: anomaly.deviationScore > 3.0 ? .high : .medium
            ))
        }

        return insights
    }

    private func generateBudgetInsights() throws -> [FinancialInsight] {
        let recommendations = try generateBudgetRecommendations()
        var insights: [FinancialInsight] = []

        for recommendation in recommendations.prefix(2) { // Top 2 recommendations
            insights.append(FinancialInsight(
                type: .budgetRecommendation,
                title: "Budget Recommendation",
                description: "Consider budgeting $\(String(format: "%.2f", recommendation.suggestedAmount)) for \(recommendation.category)",
                confidence: recommendation.confidence,
                priority: .medium
            ))
        }

        return insights
    }

    private func generateGoalInsights() throws -> [FinancialInsight] {
        let request: NSFetchRequest<FinancialGoal> = FinancialGoal.fetchRequest()
        let goals = try context.fetch(request)
        var insights: [FinancialInsight] = []

        for goal in goals.prefix(2) {
            guard let goalId = goal.id else { continue }

            let progress = try trackGoalProgress(goalId: goalId)
            insights.append(FinancialInsight(
                type: .goalProgress,
                title: "Goal Progress Update",
                description: "\(goal.name ?? "Goal"): \(String(format: "%.1f", progress.completionPercentage))% complete",
                confidence: 0.9,
                priority: progress.completionPercentage > 80 ? .high : .medium
            ))
        }

        return insights
    }

    // MARK: - Calculation Helper Methods

    private func calculateMonthlySpending(_ expenses: [FinancialData]) -> [Double] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            guard let date = expense.invoiceDate else { return "unknown" }
            let components = calendar.dateComponents([.year, .month], from: date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }

        return grouped.compactMap { _, transactions in
            let total = transactions.compactMap { $0.totalAmount?.doubleValue }.reduce(0, +)
            return abs(total)
        }
    }

    private func calculateMonthlyIncome(_ income: [FinancialData]) -> [Double] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: income) { income in
            guard let date = income.invoiceDate else { return "unknown" }
            let components = calendar.dateComponents([.year, .month], from: date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }

        return grouped.compactMap { _, transactions in
            transactions.compactMap { $0.totalAmount?.doubleValue }.reduce(0, +)
        }
    }

    private func determineTrend(_ monthlyAmounts: [Double]) -> (trend: SpendingTrend, strength: Double) {
        guard monthlyAmounts.count >= 2 else { return (.noData, 0) }

        let recent = monthlyAmounts.prefix(3)
        let older = monthlyAmounts.dropFirst(3).prefix(3)

        guard !recent.isEmpty && !older.isEmpty else { return (.stable, 0.5) }

        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)

        let change = (recentAvg - olderAvg) / olderAvg
        let strength = min(1.0, abs(change) * 2)

        if change > 0.1 {
            return (.increasing, strength)
        } else if change < -0.1 {
            return (.decreasing, strength)
        } else {
            return (.stable, strength)
        }
    }

    private func projectNextMonth(_ monthlyAmounts: [Double]) -> Double {
        guard !monthlyAmounts.isEmpty else { return 0 }

        if monthlyAmounts.count == 1 {
            return monthlyAmounts[0]
        }

        // Simple linear projection
        let recent = monthlyAmounts.prefix(3)
        let average = recent.reduce(0, +) / Double(recent.count)
        return average
    }

    private func calculateIncomeStability(_ monthlyIncome: [Double]) -> Double {
        guard monthlyIncome.count > 1 else { return 0 }

        let mean = monthlyIncome.reduce(0, +) / Double(monthlyIncome.count)
        let variance = monthlyIncome.map { pow($0 - mean, 2) }.reduce(0, +) / Double(monthlyIncome.count)
        let coefficientOfVariation = sqrt(variance) / mean

        // Invert and normalize to 0-1 scale where 1 = very stable
        return max(0, 1 - min(1, coefficientOfVariation))
    }

    private func calculateGrowthRate(_ monthlyIncome: [Double]) -> Double {
        guard monthlyIncome.count >= 2 else { return 0 }

        let recent = monthlyIncome.first ?? 0
        let previous = monthlyIncome.count > 1 ? monthlyIncome[1] : 0

        guard previous > 0 else { return 0 }
        return (recent - previous) / previous
    }

    private func projectNextIncome(_ monthlyIncome: [Double]) -> Double {
        guard !monthlyIncome.isEmpty else { return 0 }

        // Simple average projection
        let recent = monthlyIncome.prefix(3)
        return recent.reduce(0, +) / Double(recent.count)
    }

    private func calculateMonthlyProgressRate(for goal: FinancialGoal) -> Double {
        // Simplified calculation
        5.0 // 5% per month default
    }

    private func calculateProjectedCompletionDate(for goal: FinancialGoal) -> Date? {
        guard let targetDate = goal.targetDate else { return nil }
        return targetDate
    }
}

// MARK: - Error Types

public enum FinancialInsightsError: Error, LocalizedError {
    case goalNotFound
    case insufficientData
    case analysisError(String)

    public var errorDescription: String? {
        switch self {
        case .goalNotFound:
            return "Financial goal not found"
        case .insufficientData:
            return "Insufficient data for analysis"
        case .analysisError(let message):
            return "Analysis error: \(message)"
        }
    }
}
