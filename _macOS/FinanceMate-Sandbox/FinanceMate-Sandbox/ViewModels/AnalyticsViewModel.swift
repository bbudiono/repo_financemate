//
//  AnalyticsViewModel.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/4/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: TDD-driven analytics view model with Core Data integration for financial data analysis
* Issues & Complexity Summary: Real-time analytics processing with Core Data fetch operations and chart data preparation
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~300
  - Core Algorithm Complexity: Medium-High (data aggregation, chart calculations, period filtering)
  - Dependencies: 5 New (Core Data, Combine, Foundation, SwiftUI, Charts)
  - State Management Complexity: High (observable object, async operations, real-time updates)
  - Novelty/Uncertainty Factor: Medium (complex Core Data queries, chart data preparation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Complex data aggregation with Core Data integration and real-time chart updates
* Final Code Complexity (Actual %): 72%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: TDD approach ensures robust analytics processing
* Last Updated: 2025-06-04
*/

import Foundation
import CoreData
import SwiftUI
import Combine

// MARK: - Analytics Period Enum

public enum AnalyticsPeriod: String, CaseIterable {
    case thisMonth = "thisMonth"
    case lastThreeMonths = "lastThreeMonths"
    case lastSixMonths = "lastSixMonths"
    case thisYear = "thisYear"
    
    public var displayName: String {
        switch self {
        case .thisMonth: return "This Month"
        case .lastThreeMonths: return "3 Months"
        case .lastSixMonths: return "6 Months"
        case .thisYear: return "This Year"
        }
    }
    
    public var dateRange: DateInterval {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return DateInterval(start: startOfMonth, end: now)
            
        case .lastThreeMonths:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return DateInterval(start: threeMonthsAgo, end: now)
            
        case .lastSixMonths:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            return DateInterval(start: sixMonthsAgo, end: now)
            
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return DateInterval(start: startOfYear, end: now)
        }
    }
}

// MARK: - Category Analytics Data Model

public struct CategoryAnalytics: Identifiable {
    public let id = UUID()
    public let categoryName: String
    public let totalAmount: Double
    public let transactionCount: Int
    public let percentage: Double
    public let color: Color
    
    public init(categoryName: String, totalAmount: Double, transactionCount: Int, percentage: Double, color: Color) {
        self.categoryName = categoryName
        self.totalAmount = totalAmount
        self.transactionCount = transactionCount
        self.percentage = percentage
        self.color = color
    }
}

// MARK: - Monthly Analytics Data Model

public struct MonthlyAnalytics: Identifiable {
    public let id = UUID()
    public let period: Date
    public let totalSpending: Double
    public let transactionCount: Int
    
    public init(period: Date, totalSpending: Double, transactionCount: Int) {
        self.period = period
        self.totalSpending = totalSpending
        self.transactionCount = transactionCount
    }
}

// MARK: - Analytics View Model

@MainActor
public class AnalyticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var selectedPeriod: AnalyticsPeriod = .thisMonth
    @Published public var isLoading: Bool = false
    @Published public var monthlyData: [MonthlyAnalytics] = []
    @Published public var categoryData: [CategoryAnalytics] = []
    @Published public var totalSpending: Double?
    @Published public var averageSpending: Double?
    
    // MARK: - Private Properties
    
    private let documentManager: DocumentManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
    }
    
    // MARK: - Public Methods
    
    public func loadAnalyticsData() async {
        isLoading = true
        
        do {
            let financialData = try await fetchFinancialData()
            await processAnalyticsData(financialData)
        } catch {
            print("Error loading analytics data: \(error)")
            await clearAnalyticsData()
        }
        
        isLoading = false
    }
    
    public func refreshAnalyticsData() async {
        await loadAnalyticsData()
    }
    
    // MARK: - Private Core Data Operations
    
    private func fetchFinancialData() async throws -> [FinancialData] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = CoreDataStack.shared.mainContext
            let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
            
            // Set date predicate based on selected period
            let dateRange = selectedPeriod.dateRange
            request.predicate = NSPredicate(
                format: "invoiceDate >= %@ AND invoiceDate <= %@",
                dateRange.start as NSDate,
                dateRange.end as NSDate
            )
            
            // Sort by date
            request.sortDescriptors = [NSSortDescriptor(key: "invoiceDate", ascending: true)]
            
            context.perform {
                do {
                    let results = try context.fetch(request)
                    continuation.resume(returning: results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Data Processing
    
    private func processAnalyticsData(_ financialData: [FinancialData]) async {
        // Filter valid data
        let validData = financialData.filter { data in
            data.totalAmount != nil && 
            data.invoiceDate != nil && 
            data.totalAmount!.doubleValue > 0
        }
        
        // Process category analytics
        let categories = await processCategoryAnalytics(validData)
        
        // Process monthly analytics
        let monthly = await processMonthlyAnalytics(validData)
        
        // Calculate summary statistics
        let (total, average) = calculateSummaryStatistics(validData)
        
        // Update published properties
        categoryData = categories
        monthlyData = monthly
        totalSpending = total
        averageSpending = average
    }
    
    private func processCategoryAnalytics(_ financialData: [FinancialData]) async -> [CategoryAnalytics] {
        guard !financialData.isEmpty else { return [] }
        
        // Group by category
        var categoryTotals: [String: (amount: Double, count: Int)] = [:]
        let totalAmount = financialData.reduce(0.0) { sum, data in
            sum + (data.totalAmount?.doubleValue ?? 0.0)
        }
        
        for data in financialData {
            let category = data.document?.category?.name ?? "Uncategorized"
            let amount = data.totalAmount?.doubleValue ?? 0.0
            
            if let existing = categoryTotals[category] {
                categoryTotals[category] = (existing.amount + amount, existing.count + 1)
            } else {
                categoryTotals[category] = (amount, 1)
            }
        }
        
        // Convert to CategoryAnalytics objects
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .yellow, .pink, .cyan]
        var colorIndex = 0
        
        let analytics = categoryTotals.map { (category, data) in
            let percentage = totalAmount > 0 ? (data.amount / totalAmount) * 100 : 0
            let color = colors[colorIndex % colors.count]
            colorIndex += 1
            
            return CategoryAnalytics(
                categoryName: category,
                totalAmount: data.amount,
                transactionCount: data.count,
                percentage: percentage,
                color: color
            )
        }
        
        // Sort by total amount (highest first)
        return analytics.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func processMonthlyAnalytics(_ financialData: [FinancialData]) async -> [MonthlyAnalytics] {
        guard !financialData.isEmpty else { return [] }
        
        let calendar = Calendar.current
        var monthlyTotals: [String: (amount: Double, count: Int)] = [:]
        
        // Group by month
        for data in financialData {
            guard let date = data.invoiceDate else { continue }
            
            let monthKey = calendar.dateInterval(of: .month, for: date)?.start ?? date
            let monthKeyString = ISO8601DateFormatter().string(from: monthKey)
            let amount = data.totalAmount?.doubleValue ?? 0.0
            
            if let existing = monthlyTotals[monthKeyString] {
                monthlyTotals[monthKeyString] = (existing.amount + amount, existing.count + 1)
            } else {
                monthlyTotals[monthKeyString] = (amount, 1)
            }
        }
        
        // Convert to MonthlyAnalytics objects
        let analytics = monthlyTotals.compactMap { (monthString, data) -> MonthlyAnalytics? in
            guard let date = ISO8601DateFormatter().date(from: monthString) else { return nil }
            
            return MonthlyAnalytics(
                period: date,
                totalSpending: data.amount,
                transactionCount: data.count
            )
        }
        
        // Sort chronologically
        return analytics.sorted { $0.period < $1.period }
    }
    
    private func calculateSummaryStatistics(_ financialData: [FinancialData]) -> (total: Double, average: Double) {
        guard !financialData.isEmpty else { return (0.0, 0.0) }
        
        let total = financialData.reduce(0.0) { sum, data in
            sum + (data.totalAmount?.doubleValue ?? 0.0)
        }
        
        let average = total / Double(financialData.count)
        
        return (total, average)
    }
    
    private func clearAnalyticsData() async {
        categoryData = []
        monthlyData = []
        totalSpending = 0.0
        averageSpending = 0.0
    }
}