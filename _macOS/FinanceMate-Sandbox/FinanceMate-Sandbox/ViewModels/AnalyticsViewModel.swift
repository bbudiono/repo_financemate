//
//  AnalyticsViewModel.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Analytics view model for real-time financial insights and data visualization in Sandbox
* Issues & Complexity Summary: Initial TDD implementation - will fail tests to drive development
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~350
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 5 New (data processing, chart generation, real-time updates, period filtering, trend analysis)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Complex analytics processing with real-time UI updates and chart data generation
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures robust analytics with proper data binding and performance
* Last Updated: 2025-06-02
*/

import Foundation
import SwiftUI
import Combine

// MARK: - Analytics View Model

@MainActor
public class AnalyticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isLoading: Bool = false
    @Published public var selectedPeriod: AnalyticsPeriod = .monthly
    @Published public var monthlyData: [MonthlyAnalytics] = []
    @Published public var categoryData: [CategoryAnalytics] = []
    @Published public var totalSpending: Double?
    @Published public var averageSpending: Double?
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let documentManager: DocumentManager
    private var cancellables = Set<AnyCancellable>()
    private let analyticsQueue = DispatchQueue(label: "com.financemate.analytics", qos: .userInitiated)
    
    // MARK: - Initialization
    
    public init(documentManager: DocumentManager) {
        self.documentManager = documentManager
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    public func loadAnalyticsData() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let processedDocuments = documentManager.getProcessedDocuments()
        
        // Process monthly trends
        let monthlyTrends = await calculateMonthlyTrends(from: processedDocuments)
        let categoryBreakdown = await calculateCategoryBreakdown(from: processedDocuments)
        let spendingMetrics = await calculateSpendingMetrics(from: processedDocuments)
        
        // Update UI data
        monthlyData = monthlyTrends
        categoryData = categoryBreakdown
        totalSpending = spendingMetrics.total
        averageSpending = spendingMetrics.average
    }
    
    public func refreshAnalyticsData() async {
        await loadAnalyticsData()
    }
    
    // MARK: - Private Analytics Methods
    
    private func calculateMonthlyTrends(from documents: [WorkflowDocument]) async -> [MonthlyAnalytics] {
        _ = Calendar.current
        var monthlyTotals: [String: Double] = [:]
        var monthlyCounts: [String: Int] = [:]
        
        for document in documents {
            guard let financialData = document.financialData,
                  let totalAmountStr = financialData.totalAmount,
                  let amount = Double(totalAmountStr.replacingOccurrences(of: "[^0-9.]", with: "", options: String.CompareOptions.regularExpression)) else {
                continue
            }
            
            let monthKey = getMonthKey(for: document.startTime, period: selectedPeriod)
            monthlyTotals[monthKey, default: 0] += amount
            monthlyCounts[monthKey, default: 0] += 1
        }
        
        return monthlyTotals.map { month, total in
            MonthlyAnalytics(
                period: month,
                totalSpending: total,
                transactionCount: monthlyCounts[month] ?? 0,
                averageTransaction: total / Double(monthlyCounts[month] ?? 1)
            )
        }.sorted { $0.period < $1.period }
    }
    
    private func calculateCategoryBreakdown(from documents: [WorkflowDocument]) async -> [CategoryAnalytics] {
        var categoryTotals: [String: Double] = [:]
        var categoryCounts: [String: Int] = [:]
        
        for document in documents {
            guard let financialData = document.financialData,
                  let totalAmountStr = financialData.totalAmount,
                  let amount = Double(totalAmountStr.replacingOccurrences(of: "[^0-9.]", with: "", options: String.CompareOptions.regularExpression)) else {
                continue
            }
            
            let category = financialData.category.rawValue
            categoryTotals[category, default: 0] += amount
            categoryCounts[category, default: 0] += 1
        }
        
        let totalSpending = categoryTotals.values.reduce(0, +)
        
        return categoryTotals.map { category, total in
            CategoryAnalytics(
                categoryName: category,
                totalAmount: total,
                percentage: totalSpending > 0 ? (total / totalSpending) * 100 : 0,
                transactionCount: categoryCounts[category] ?? 0,
                color: getCategoryColor(for: category)
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private func calculateSpendingMetrics(from documents: [WorkflowDocument]) async -> (total: Double, average: Double) {
        var totalSpending: Double = 0
        var validDocumentCount = 0
        
        for document in documents {
            guard let financialData = document.financialData,
                  let totalAmountStr = financialData.totalAmount,
                  let amount = Double(totalAmountStr.replacingOccurrences(of: "[^0-9.]", with: "", options: String.CompareOptions.regularExpression)) else {
                continue
            }
            
            totalSpending += amount
            validDocumentCount += 1
        }
        
        let averageSpending = validDocumentCount > 0 ? totalSpending / Double(validDocumentCount) : 0
        
        return (total: totalSpending, average: averageSpending)
    }
    
    // MARK: - Helper Methods
    
    private func setupSubscriptions() {
        // Monitor document manager for real-time updates
        documentManager.$processedDocuments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.loadAnalyticsData()
                }
            }
            .store(in: &cancellables)
    }
    
    private func getMonthKey(for date: Date, period: AnalyticsPeriod) -> String {
        let formatter = DateFormatter()
        
        switch period {
        case .weekly:
            formatter.dateFormat = "yyyy-'W'ww"
        case .monthly:
            formatter.dateFormat = "yyyy-MM"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        
        return formatter.string(from: date)
    }
    
    private func getCategoryColor(for category: String) -> Color {
        // Generate consistent colors for categories
        switch category.lowercased() {
        case let c where c.contains("office"):
            return .blue
        case let c where c.contains("travel"):
            return .green
        case let c where c.contains("software"):
            return .purple
        case let c where c.contains("meal"), let c where c.contains("food"):
            return .orange
        case let c where c.contains("transport"):
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Supporting Data Models

public struct MonthlyAnalytics: Identifiable {
    public let id = UUID()
    public let period: String
    public let totalSpending: Double
    public let transactionCount: Int
    public let averageTransaction: Double
    
    public init(period: String, totalSpending: Double, transactionCount: Int, averageTransaction: Double) {
        self.period = period
        self.totalSpending = totalSpending
        self.transactionCount = transactionCount
        self.averageTransaction = averageTransaction
    }
}

public struct CategoryAnalytics: Identifiable {
    public let id = UUID()
    public let categoryName: String
    public let totalAmount: Double
    public let percentage: Double
    public let transactionCount: Int
    public let color: Color
    
    public init(categoryName: String, totalAmount: Double, percentage: Double, transactionCount: Int, color: Color) {
        self.categoryName = categoryName
        self.totalAmount = totalAmount
        self.percentage = percentage
        self.transactionCount = transactionCount
        self.color = color
    }
}

public enum AnalyticsPeriod: String, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    public var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}