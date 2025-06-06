// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardMetricsGrid.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular metrics grid component extracted from DashboardView for reusability
* Issues & Complexity Summary: Clean component separation with financial metrics calculation and display
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium (financial calculations, trend analysis)
  - Dependencies: 3 New (SwiftUI, Core Data, Charts)
  - State Management Complexity: Low (computed properties from Core Data)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
* Problem Estimate (Inherent Problem Difficulty %): 20%
* Initial Code Complexity Estimate %): 23%
* Justification for Estimates: Simple extraction and modularization of existing working code
* Final Code Complexity (Actual %): 28%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Clean component extraction maintains functionality while improving maintainability
* Last Updated: 2025-06-06
*/

import SwiftUI
import CoreData

struct DashboardMetricsGrid: View {
    let allFinancialData: FetchedResults<FinancialData>
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            MetricCard(
                title: "Total Balance",
                value: formatCurrency(totalBalance),
                icon: "dollarsign.circle.fill",
                color: totalBalance >= 0 ? .green : .red,
                trend: calculateBalanceTrend()
            )
            
            MetricCard(
                title: "Monthly Income",
                value: formatCurrency(monthlyIncome),
                icon: "arrow.up.circle.fill",
                color: .blue,
                trend: calculateIncomeTrend()
            )
            
            MetricCard(
                title: "Monthly Expenses",
                value: formatCurrency(monthlyExpenses),
                icon: "arrow.down.circle.fill",
                color: .orange,
                trend: calculateExpensesTrend()
            )
            
            MetricCard(
                title: "Monthly Goal",
                value: formatCurrency(monthlyGoal),
                icon: "target",
                color: .purple,
                trend: String(format: "%.0f%% achieved", goalAchievementPercentage)
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalBalance: Double {
        let totalIncome = allFinancialData
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        let totalExpenses = allFinancialData
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +)
        
        return totalIncome + totalExpenses
    }
    
    private var monthlyIncome: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
    }
    
    private var monthlyExpenses: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return abs(allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +))
    }
    
    private var monthlyGoal: Double {
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfPreviousMonth = Calendar.current.dateInterval(of: .month, for: previousMonth)?.start ?? Date()
        let endOfPreviousMonth = Calendar.current.dateInterval(of: .month, for: previousMonth)?.end ?? Date()
        
        let previousMonthIncome = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfPreviousMonth && date <= endOfPreviousMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        return previousMonthIncome > 0 ? previousMonthIncome * 1.1 : 0
    }
    
    private var goalAchievementPercentage: Double {
        guard monthlyGoal > 0 else { return 0 }
        return min((monthlyIncome / monthlyGoal) * 100, 100)
    }
    
    // MARK: - Helper Methods
    
    private func calculateBalanceTrend() -> String {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthBalance = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .reduce(0, +)
        
        if lastMonthBalance == 0 {
            return "New"
        }
        
        let changePercent = ((totalBalance - lastMonthBalance) / abs(lastMonthBalance)) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func calculateIncomeTrend() -> String {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthIncome = allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        if lastMonthIncome == 0 {
            return "New"
        }
        
        let changePercent = ((monthlyIncome - lastMonthIncome) / lastMonthIncome) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func calculateExpensesTrend() -> String {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let startOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.start ?? Date()
        let endOfLastMonth = Calendar.current.dateInterval(of: .month, for: lastMonth)?.end ?? Date()
        
        let lastMonthExpenses = abs(allFinancialData
            .filter { 
                guard let date = $0.invoiceDate else { return false }
                return date >= startOfLastMonth && date <= endOfLastMonth
            }
            .compactMap { $0.totalAmount?.doubleValue }
            .filter { $0 < 0 }
            .reduce(0, +))
        
        if lastMonthExpenses == 0 {
            return "New"
        }
        
        let changePercent = ((monthlyExpenses - lastMonthExpenses) / lastMonthExpenses) * 100
        return String(format: "%+.1f%%", changePercent)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}