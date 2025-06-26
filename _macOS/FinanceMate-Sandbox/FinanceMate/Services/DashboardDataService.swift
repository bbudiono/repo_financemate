//
//  DashboardDataService.swift
//  FinanceMate
//
//  Purpose: Real data service for dashboard - NO MOCK DATA
//

import CoreData
import Foundation
import SwiftUI

class DashboardDataService: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.context = context
    }

    // MARK: - Category Analysis

    func getCategorizedExpenses() throws -> [CategoryExpense] {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        request.predicate = NSPredicate(format: "totalAmount < 0") // Only expenses

        let allExpenses = try context.fetch(request)

        // Group by category
        var categoryMap: [String: [FinancialData]] = [:]

        for expense in allExpenses {
            let category = expense.category ?? detectCategory(for: expense)
            if categoryMap[category] == nil {
                categoryMap[category] = []
            }
            categoryMap[category]?.append(expense)
        }

        // Calculate totals and trends
        var categories: [CategoryExpense] = []

        for (categoryName, expenses) in categoryMap {
            let totalAmount = expenses
                .compactMap { $0.totalAmount?.doubleValue }
                .map { abs($0) }
                .reduce(0, +)

            let trend = calculateTrend(for: categoryName, expenses: expenses)

            categories.append(CategoryExpense(
                name: categoryName,
                totalAmount: totalAmount,
                transactionCount: expenses.count,
                trend: trend
            ))
        }

        return categories.sorted { $0.totalAmount > $1.totalAmount }
    }

    private func detectCategory(for data: FinancialData) -> String {
        guard let vendor = data.vendorName?.lowercased() else { return "Other" }

        // Smart categorization based on vendor name
        if vendor.contains("restaurant") || vendor.contains("cafe") || vendor.contains("food") {
            return "Food & Dining"
        } else if vendor.contains("gas") || vendor.contains("uber") || vendor.contains("lyft") || vendor.contains("transport") {
            return "Transportation"
        } else if vendor.contains("store") || vendor.contains("amazon") || vendor.contains("walmart") {
            return "Shopping"
        } else if vendor.contains("netflix") || vendor.contains("spotify") || vendor.contains("entertainment") {
            return "Entertainment"
        } else if vendor.contains("electric") || vendor.contains("water") || vendor.contains("utility") || vendor.contains("internet") {
            return "Utilities"
        } else if vendor.contains("health") || vendor.contains("doctor") || vendor.contains("pharmacy") {
            return "Healthcare"
        } else if vendor.contains("rent") || vendor.contains("mortgage") {
            return "Housing"
        }

        return "Other"
    }

    private func calculateTrend(for category: String, expenses: [FinancialData]) -> TrendDirection {
        let now = Date()
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: now)?.start ?? now
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? lastMonth

        let currentMonthTotal = expenses
            .filter { ($0.invoiceDate ?? Date.distantPast) >= startOfMonth }
            .compactMap { $0.totalAmount?.doubleValue }
            .map { abs($0) }
            .reduce(0, +)

        let lastMonthTotal = expenses
            .filter {
                let date = $0.invoiceDate ?? Date.distantPast
                return date >= startOfLastMonth && date < startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .map { abs($0) }
            .reduce(0, +)

        if lastMonthTotal == 0 { return .stable }

        let changePercentage = ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100

        if changePercentage > 5 {
            return .up
        } else if changePercentage < -5 {
            return .down
        } else {
            return .stable
        }
    }

    private func calculateTrendPercentage(for category: String, expenses: [FinancialData]) -> Double {
        let now = Date()
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: now)?.start ?? now
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? lastMonth

        let currentMonthTotal = expenses
            .filter { ($0.invoiceDate ?? Date.distantPast) >= startOfMonth }
            .compactMap { $0.totalAmount?.doubleValue }
            .map { abs($0) }
            .reduce(0, +)

        let lastMonthTotal = expenses
            .filter {
                let date = $0.invoiceDate ?? Date.distantPast
                return date >= startOfLastMonth && date < startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .map { abs($0) }
            .reduce(0, +)

        if lastMonthTotal == 0 { return 0 }

        return ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100
    }

    // MARK: - Subscription Detection

    func detectSubscriptions() throws -> [DetectedSubscription] {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        request.predicate = NSPredicate(format: "totalAmount < 0") // Only expenses
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FinancialData.invoiceDate, ascending: false)]

        let allExpenses = try context.fetch(request)

        // Group by vendor and amount
        var vendorPayments: [String: [(amount: Double, date: Date)]] = [:]

        for expense in allExpenses {
            guard let vendor = expense.vendorName,
                  let date = expense.invoiceDate,
                  let amount = expense.totalAmount?.doubleValue else { continue }

            let key = "\(vendor)_\(abs(amount))"
            if vendorPayments[key] == nil {
                vendorPayments[key] = []
            }
            vendorPayments[key]?.append((amount: abs(amount), date: date))
        }

        // Detect recurring payments
        var subscriptions: [DetectedSubscription] = []

        for (key, payments) in vendorPayments {
            guard payments.count >= 2 else { continue } // Need at least 2 payments

            let components = key.split(separator: "_")
            guard components.count >= 2 else { continue }

            let vendor = String(components[0])
            let amount = Double(components[1]) ?? 0

            // Check if payments are regular
            let sortedPayments = payments.sorted { $0.date > $1.date }
            let frequency = detectFrequency(payments: sortedPayments)

            if let frequency = frequency {
                let lastPayment = sortedPayments.first?.date ?? Date()
                let isActive = isSubscriptionActive(lastPayment: lastPayment, frequency: frequency)
                let nextBilling = calculateNextBilling(lastPayment: lastPayment, frequency: frequency)

                subscriptions.append(DetectedSubscription(
                    name: vendor,
                    amount: amount,
                    isActive: isActive,
                    nextBillingDate: nextBilling
                ))
            }
        }

        return subscriptions.sorted { $0.amount > $1.amount }
    }

    private func detectFrequency(payments: [(amount: Double, date: Date)]) -> SubscriptionFrequency? {
        guard payments.count >= 2 else { return nil }

        var intervals: [TimeInterval] = []

        for i in 1..<payments.count {
            let interval = payments[i - 1].date.timeIntervalSince(payments[i].date)
            intervals.append(interval)
        }

        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        let days = averageInterval / (24 * 60 * 60)

        // Allow some variance in payment dates
        if days >= 6 && days <= 8 {
            return .weekly
        } else if days >= 25 && days <= 35 {
            return .monthly
        } else if days >= 80 && days <= 100 {
            return .quarterly
        } else if days >= 350 && days <= 380 {
            return .yearly
        }

        return nil
    }

    private func isSubscriptionActive(lastPayment: Date, frequency: SubscriptionFrequency) -> Bool {
        let daysSinceLastPayment = Date().timeIntervalSince(lastPayment) / (24 * 60 * 60)

        switch frequency {
        case .weekly:
            return daysSinceLastPayment <= 14 // 2 weeks grace period
        case .monthly:
            return daysSinceLastPayment <= 45 // 1.5 months grace period
        case .quarterly:
            return daysSinceLastPayment <= 120 // 4 months grace period
        case .yearly:
            return daysSinceLastPayment <= 380 // 13 months grace period
        case .annual:
            return daysSinceLastPayment <= 380 // 13 months grace period
        }
    }

    private func calculateNextBilling(lastPayment: Date, frequency: SubscriptionFrequency) -> Date? {
        switch frequency {
        case .weekly:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: lastPayment)
        case .monthly:
            return Calendar.current.date(byAdding: .month, value: 1, to: lastPayment)
        case .quarterly:
            return Calendar.current.date(byAdding: .month, value: 3, to: lastPayment)
        case .yearly:
            return Calendar.current.date(byAdding: .year, value: 1, to: lastPayment)
        case .annual:
            return Calendar.current.date(byAdding: .year, value: 1, to: lastPayment)
        }
    }

    // MARK: - Financial Forecasting

    func generateForecasts() throws -> [FinancialForecast] {
        let request: NSFetchRequest<FinancialData> = FinancialData.fetchRequest()
        let allData = try context.fetch(request)

        var forecasts: [FinancialForecast] = []

        // Next month projection
        if let nextMonthForecast = projectNextMonth(data: allData) {
            forecasts.append(nextMonthForecast)
        }

        // Year-end projection
        if let yearEndForecast = projectYearEnd(data: allData) {
            forecasts.append(yearEndForecast)
        }

        // Savings potential
        if let savingsPotential = calculateSavingsPotential(data: allData) {
            forecasts.append(savingsPotential)
        }

        return forecasts
    }

    private func projectNextMonth(data: [FinancialData]) -> FinancialForecast? {
        // Get last 6 months of expenses
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()

        var monthlyTotals: [Double] = []

        for monthOffset in 0..<6 {
            let monthDate = Calendar.current.date(byAdding: .month, value: -monthOffset, to: Date()) ?? Date()
            let startOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.start ?? monthDate
            let endOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.end ?? monthDate

            let monthTotal = data
                .filter {
                    guard let date = $0.invoiceDate else { return false }
                    return date >= startOfMonth && date < endOfMonth
                }
                .compactMap { $0.totalAmount?.doubleValue }
                .filter { $0 < 0 }
                .map { abs($0) }
                .reduce(0, +)

            if monthTotal > 0 {
                monthlyTotals.append(monthTotal)
            }
        }

        guard !monthlyTotals.isEmpty else { return nil }

        // Calculate trend
        let average = monthlyTotals.reduce(0, +) / Double(monthlyTotals.count)

        // Simple linear regression for trend
        var trend = 0.0
        if monthlyTotals.count >= 3 {
            let firstHalf = Array(monthlyTotals.prefix(monthlyTotals.count / 2))
            let secondHalf = Array(monthlyTotals.suffix(monthlyTotals.count / 2))

            let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
            let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)

            trend = (secondAvg - firstAvg) / firstAvg
        }

        let projection = average * (1 + trend)
        let lastMonth = monthlyTotals.first ?? average
        let changePercentage = ((projection - lastMonth) / lastMonth) * 100

        return FinancialForecast(
            type: .nextMonth,
            projectedAmount: projection,
            changePercentage: changePercentage,
            description: "Based on spending patterns"
        )
    }

    private func projectYearEnd(data: [FinancialData]) -> FinancialForecast? {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startOfYear = Calendar.current.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? Date()

        let yearToDateTotal = data
            .filter { ($0.invoiceDate ?? Date.distantPast) >= startOfYear }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .map { abs($0) }
            .reduce(0, +)

        let monthsElapsed = Double(Calendar.current.component(.month, from: Date()))
        guard monthsElapsed > 0 else { return nil }

        let monthlyAverage = yearToDateTotal / monthsElapsed
        let yearProjection = monthlyAverage * 12

        // Compare to last year if available
        let lastYear = currentYear - 1
        let startOfLastYear = Calendar.current.date(from: DateComponents(year: lastYear, month: 1, day: 1)) ?? Date()
        let endOfLastYear = Calendar.current.date(from: DateComponents(year: lastYear, month: 12, day: 31)) ?? Date()

        let lastYearTotal = data
            .filter {
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastYear && date <= endOfLastYear
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .map { abs($0) }
            .reduce(0, +)

        let changePercentage = lastYearTotal > 0 ? ((yearProjection - lastYearTotal) / lastYearTotal) * 100 : 0

        return FinancialForecast(
            type: .yearEnd,
            projectedAmount: yearProjection,
            changePercentage: changePercentage,
            description: "Estimated annual spending"
        )
    }

    private func calculateSavingsPotential(data: [FinancialData]) -> FinancialForecast? {
        let currentMonth = Date()
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth

        let currentMonthExpenses = data
            .filter { ($0.invoiceDate ?? Date.distantPast) >= startOfMonth }
            .compactMap { expense -> (category: String, amount: Double)? in
                guard let amount = expense.totalAmount?.doubleValue,
                      amount < 0 else { return nil }
                let category = expense.category ?? detectCategory(for: expense)
                return (category: category, amount: abs(amount))
            }

        // Calculate discretionary spending
        let discretionaryCategories = ["Entertainment", "Food & Dining", "Shopping"]
        let discretionaryTotal = currentMonthExpenses
            .filter { discretionaryCategories.contains($0.category) }
            .map { $0.amount }
            .reduce(0, +)

        // Suggest 20% reduction in discretionary spending
        let savingsPotential = discretionaryTotal * 0.2

        return FinancialForecast(
            type: .savingsPotential,
            projectedAmount: savingsPotential,
            changePercentage: 20.0,
            description: "Optimized budget scenario"
        )
    }
}

// MARK: - Core Data Extensions

extension FinancialData {
    var category: String? {
        get {
            // Store category in a transient property or parse from description
            self.transientCategory
        }
        set {
            self.transientCategory = newValue
        }
    }

    @objc private var transientCategory: String? {
        get {
            // Could store in description field or add a category field to Core Data model
            nil
        }
        set {
            // Store category
        }
    }
}
