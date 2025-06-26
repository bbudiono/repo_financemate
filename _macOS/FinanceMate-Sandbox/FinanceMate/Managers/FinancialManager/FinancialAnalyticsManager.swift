// FinancialAnalyticsManager.swift
// Purpose: Centralized financial analytics operations extracted from AnalyticsView
// Part of unified Manager architecture for FinanceMate

import CoreData
import Foundation
import SwiftUI

@MainActor
class FinancialAnalyticsManager: ObservableObject {
    @Published var isAnalyzing = false
    @Published var analyticsResults: AnalyticsResults?
    @Published var analysisError: AnalysisError?
    @Published var historicalTrends: [TrendData] = []
    @Published var categoryBreakdown: [CategoryData] = []
    @Published var monthlyInsights: [MonthlyInsight] = []

    private let dataManager = FinancialDataManager()
    private let reportManager = FinancialReportManager()

    // MARK: - Analytics Operations

    func performComprehensiveAnalysis() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            // Fetch all financial data
            let financialData = try await dataManager.fetchAllFinancialData()

            // Generate different types of analysis
            async let trendsTask = generateTrendsAnalysis(from: financialData)
            async let categoryTask = generateCategoryAnalysis(from: financialData)
            async let insightsTask = generateMonthlyInsights(from: financialData)
            async let summaryTask = generateSummaryStatistics(from: financialData)

            let (trends, categories, insights, summary) = await (
                trendsTask, categoryTask, insightsTask, summaryTask
            )

            historicalTrends = trends
            categoryBreakdown = categories
            monthlyInsights = insights

            analyticsResults = AnalyticsResults(
                totalTransactions: financialData.count,
                totalAmount: summary.totalAmount,
                averageTransaction: summary.averageTransaction,
                largestTransaction: summary.largestTransaction,
                smallestTransaction: summary.smallestTransaction,
                trendAnalysis: trends,
                categoryBreakdown: categories,
                monthlyInsights: insights,
                generatedAt: Date()
            )
        } catch {
            analysisError = .analysisInternalError(error)
        }
    }

    func analyzeCategory(_ category: String) async -> CategoryAnalysis? {
        do {
            let categoryData = try await dataManager.fetchFinancialData(for: category)
            return await generateDetailedCategoryAnalysis(for: category, data: categoryData)
        } catch {
            analysisError = .categoryAnalysisError(category, error)
            return nil
        }
    }

    func analyzeTimeRange(from startDate: Date, to endDate: Date) async -> TimeRangeAnalysis? {
        do {
            let data = try await dataManager.fetchFinancialData(from: startDate, to: endDate)
            return await generateTimeRangeAnalysis(data: data, startDate: startDate, endDate: endDate)
        } catch {
            analysisError = .timeRangeAnalysisError(error)
            return nil
        }
    }

    func generatePredictiveInsights() async -> [PredictiveInsight] {
        do {
            let historicalData = try await dataManager.fetchHistoricalData()
            return await analyzePatterns(in: historicalData)
        } catch {
            analysisError = .predictiveAnalysisError(error)
            return []
        }
    }

    // MARK: - Private Analysis Methods

    private func generateTrendsAnalysis(from data: [FinancialRecord]) async -> [TrendData] {
        let calendar = Calendar.current
        let now = Date()

        // Group data by month
        let monthlyData = Dictionary(grouping: data) { record in
            calendar.dateInterval(of: .month, for: record.date)?.start ?? record.date
        }

        var trends: [TrendData] = []

        // Generate last 12 months of data
        for monthOffset in 0..<12 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now),
                  let monthStart = calendar.dateInterval(of: .month, for: monthDate)?.start else {
                continue
            }

            let monthRecords = monthlyData[monthStart] ?? []
            let totalAmount = monthRecords.reduce(0) { $0 + $1.amount }
            let transactionCount = monthRecords.count
            let averageAmount = transactionCount > 0 ? totalAmount / Decimal(transactionCount) : 0

            trends.append(TrendData(
                period: monthStart,
                totalAmount: totalAmount,
                transactionCount: transactionCount,
                averageAmount: averageAmount,
                periodType: .monthly
            ))
        }

        return trends.sorted { $0.period < $1.period }
    }

    private func generateCategoryAnalysis(from data: [FinancialRecord]) async -> [CategoryData] {
        let categoryGroups = Dictionary(grouping: data) { $0.category ?? "Uncategorized" }

        return categoryGroups.map { category, records in
            let totalAmount = records.reduce(0) { $0 + $1.amount }
            let transactionCount = records.count
            let averageAmount = Decimal(transactionCount) > 0 ? totalAmount / Decimal(transactionCount) : 0
            let percentage = data.isEmpty ? 0 : Double(transactionCount) / Double(data.count) * 100

            return CategoryData(
                name: category,
                totalAmount: totalAmount,
                transactionCount: transactionCount,
                averageAmount: averageAmount,
                percentage: percentage,
                color: getCategoryColor(for: category)
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }

    private func generateMonthlyInsights(from data: [FinancialRecord]) async -> [MonthlyInsight] {
        let calendar = Calendar.current
        let monthlyGroups = Dictionary(grouping: data) { record in
            calendar.dateInterval(of: .month, for: record.date)?.start ?? record.date
        }

        return monthlyGroups.compactMap { monthStart, records in
            let totalSpending = records.reduce(0) { $0 + $1.amount }
            let transactionCount = records.count

            // Calculate insights
            let mostExpensiveTransaction = records.max { $0.amount < $1.amount }
            let mostFrequentCategory = getMostFrequentCategory(in: records)
            let spendingPattern = analyzeSpendingPattern(records)

            return MonthlyInsight(
                month: monthStart,
                totalSpending: totalSpending,
                transactionCount: transactionCount,
                mostExpensiveTransaction: mostExpensiveTransaction?.amount ?? 0,
                mostFrequentCategory: mostFrequentCategory,
                spendingPattern: spendingPattern,
                averageDailySpending: calculateAverageDailySpending(for: monthStart, records: records)
            )
        }.sorted { $0.month > $1.month }
    }

    private func generateSummaryStatistics(from data: [FinancialRecord]) async -> SummaryStatistics {
        let amounts = data.map { $0.amount }
        let totalAmount = amounts.reduce(0, +)
        let averageTransaction = !data.isEmpty ? totalAmount / Decimal(data.count) : 0
        let largestTransaction = amounts.max() ?? 0
        let smallestTransaction = amounts.min() ?? 0

        return SummaryStatistics(
            totalAmount: totalAmount,
            averageTransaction: averageTransaction,
            largestTransaction: largestTransaction,
            smallestTransaction: smallestTransaction
        )
    }

    private func generateDetailedCategoryAnalysis(for category: String, data: [FinancialRecord]) async -> CategoryAnalysis {
        let totalAmount = data.reduce(0) { $0 + $1.amount }
        let transactionCount = data.count
        let averageAmount = transactionCount > 0 ? totalAmount / Decimal(transactionCount) : 0

        // Analyze trends within category
        let monthlyTrends = await generateTrendsAnalysis(from: data)

        // Find patterns
        let vendorFrequency = Dictionary(grouping: data) { $0.vendor ?? "Unknown" }
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }

        return CategoryAnalysis(
            categoryName: category,
            totalAmount: totalAmount,
            transactionCount: transactionCount,
            averageAmount: averageAmount,
            monthlyTrends: monthlyTrends,
            topVendors: Array(vendorFrequency.prefix(5)),
            insights: generateCategoryInsights(for: category, data: data)
        )
    }

    private func generateTimeRangeAnalysis(data: [FinancialRecord], startDate: Date, endDate: Date) async -> TimeRangeAnalysis {
        let totalAmount = data.reduce(0) { $0 + $1.amount }
        let transactionCount = data.count
        let daysDifference = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let averageDailySpending = totalAmount / Decimal(daysDifference)

        let categoryBreakdown = await generateCategoryAnalysis(from: data)

        return TimeRangeAnalysis(
            startDate: startDate,
            endDate: endDate,
            totalAmount: totalAmount,
            transactionCount: transactionCount,
            averageDailySpending: averageDailySpending,
            categoryBreakdown: categoryBreakdown,
            dailyTrends: generateDailyTrends(from: data)
        )
    }

    private func analyzePatterns(in data: [FinancialRecord]) async -> [PredictiveInsight] {
        var insights: [PredictiveInsight] = []

        // Analyze spending patterns
        if let seasonalPattern = analyzeSeasonalPattern(data) {
            insights.append(seasonalPattern)
        }

        if let categoryTrend = analyzeCategoryTrends(data) {
            insights.append(categoryTrend)
        }

        if let budgetForecast = generateBudgetForecast(data) {
            insights.append(budgetForecast)
        }

        return insights
    }

    // MARK: - Helper Methods

    private func getCategoryColor(for category: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .yellow, .pink, .indigo]
        let hash = abs(category.hashValue)
        return colors[hash % colors.count]
    }

    private func getMostFrequentCategory(in records: [FinancialRecord]) -> String {
        let categoryGroups = Dictionary(grouping: records) { $0.category ?? "Uncategorized" }
        return categoryGroups.max { $0.value.count < $1.value.count }?.key ?? "Uncategorized"
    }

    private func analyzeSpendingPattern(_ records: [FinancialRecord]) -> SpendingPattern {
        let amounts = records.map { $0.amount }
        let average = amounts.reduce(0, +) / Decimal(amounts.count)
        let variance = amounts.map { pow(Double($0 - average), 2) }.reduce(0, +) / Double(amounts.count)

        if variance < 100 {
            return .consistent
        } else if variance < 500 {
            return .moderate
        } else {
            return .variable
        }
    }

    private func calculateAverageDailySpending(for month: Date, records: [FinancialRecord]) -> Decimal {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let totalSpending = records.reduce(0) { $0 + $1.amount }
        return totalSpending / Decimal(daysInMonth)
    }

    private func generateCategoryInsights(for category: String, data: [FinancialRecord]) -> [String] {
        var insights: [String] = []

        let averageAmount = data.reduce(0) { $0 + $1.amount } / Decimal(data.count)
        insights.append("Average transaction: \(formatCurrency(averageAmount))")

        let mostRecentTransaction = data.max { $0.date < $1.date }
        if let recent = mostRecentTransaction {
            let daysSince = Calendar.current.dateComponents([.day], from: recent.date, to: Date()).day ?? 0
            insights.append("Last transaction: \(daysSince) days ago")
        }

        return insights
    }

    private func generateDailyTrends(from data: [FinancialRecord]) -> [DailyTrend] {
        let calendar = Calendar.current
        let dailyGroups = Dictionary(grouping: data) { record in
            calendar.startOfDay(for: record.date)
        }

        return dailyGroups.map { date, records in
            DailyTrend(
                date: date,
                amount: records.reduce(0) { $0 + $1.amount },
                transactionCount: records.count
            )
        }.sorted { $0.date < $1.date }
    }

    private func analyzeSeasonalPattern(_ data: [FinancialRecord]) -> PredictiveInsight? {
        // Implementation for seasonal pattern analysis
        nil // Placeholder
    }

    private func analyzeCategoryTrends(_ data: [FinancialRecord]) -> PredictiveInsight? {
        // Implementation for category trend analysis
        nil // Placeholder
    }

    private func generateBudgetForecast(_ data: [FinancialRecord]) -> PredictiveInsight? {
        // Implementation for budget forecasting
        nil // Placeholder
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Data Models

struct AnalyticsResults {
    let totalTransactions: Int
    let totalAmount: Decimal
    let averageTransaction: Decimal
    let largestTransaction: Decimal
    let smallestTransaction: Decimal
    let trendAnalysis: [TrendData]
    let categoryBreakdown: [CategoryData]
    let monthlyInsights: [MonthlyInsight]
    let generatedAt: Date
}

struct TrendData: Identifiable {
    let id = UUID()
    let period: Date
    let totalAmount: Decimal
    let transactionCount: Int
    let averageAmount: Decimal
    let periodType: PeriodType
}

enum PeriodType {
    case daily, weekly, monthly, yearly
}

struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let totalAmount: Decimal
    let transactionCount: Int
    let averageAmount: Decimal
    let percentage: Double
    let color: Color
}

struct MonthlyInsight: Identifiable {
    let id = UUID()
    let month: Date
    let totalSpending: Decimal
    let transactionCount: Int
    let mostExpensiveTransaction: Decimal
    let mostFrequentCategory: String
    let spendingPattern: SpendingPattern
    let averageDailySpending: Decimal
}

enum SpendingPattern {
    case consistent, moderate, variable

    var description: String {
        switch self {
        case .consistent: return "Consistent spending"
        case .moderate: return "Moderate variation"
        case .variable: return "Variable spending"
        }
    }
}

struct SummaryStatistics {
    let totalAmount: Decimal
    let averageTransaction: Decimal
    let largestTransaction: Decimal
    let smallestTransaction: Decimal
}

struct CategoryAnalysis {
    let categoryName: String
    let totalAmount: Decimal
    let transactionCount: Int
    let averageAmount: Decimal
    let monthlyTrends: [TrendData]
    let topVendors: [(key: String, value: Int)]
    let insights: [String]
}

struct TimeRangeAnalysis {
    let startDate: Date
    let endDate: Date
    let totalAmount: Decimal
    let transactionCount: Int
    let averageDailySpending: Decimal
    let categoryBreakdown: [CategoryData]
    let dailyTrends: [DailyTrend]
}

struct DailyTrend: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    let transactionCount: Int
}

struct PredictiveInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let confidence: Double
    let type: InsightType
    let actionRecommendation: String?
}

enum InsightType {
    case seasonalPattern, categoryTrend, budgetForecast, anomaly
}

struct FinancialRecord {
    let id: UUID
    let amount: Decimal
    let date: Date
    let category: String?
    let vendor: String?
    let description: String?
}

enum AnalysisError: LocalizedError {
    case analysisInternalError(Error)
    case categoryAnalysisError(String, Error)
    case timeRangeAnalysisError(Error)
    case predictiveAnalysisError(Error)

    var errorDescription: String? {
        switch self {
        case .analysisInternalError(let error):
            return "Analysis failed: \(error.localizedDescription)"
        case .categoryAnalysisError(let category, let error):
            return "Category analysis failed for '\(category)': \(error.localizedDescription)"
        case .timeRangeAnalysisError(let error):
            return "Time range analysis failed: \(error.localizedDescription)"
        case .predictiveAnalysisError(let error):
            return "Predictive analysis failed: \(error.localizedDescription)"
        }
    }
}
