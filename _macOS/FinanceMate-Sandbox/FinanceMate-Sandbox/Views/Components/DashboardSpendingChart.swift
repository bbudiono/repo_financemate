// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardSpendingChart.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular spending chart component extracted from DashboardView for reusability
* Issues & Complexity Summary: Chart rendering with data transformation and real-time updates
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Medium (chart data processing, date calculations)
  - Dependencies: 4 New (SwiftUI, Charts, Core Data, TaskMaster wiring)
  - State Management Complexity: Medium (chart data state management)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 30%
* Problem Estimate (Inherent Problem Difficulty %): 25%
* Initial Code Complexity Estimate %): 28%
* Justification for Estimates: Chart component extraction with TaskMaster integration
* Final Code Complexity (Actual %): 32%
* Overall Result Score (Success & Quality %): 93%
* Key Variances/Learnings: TaskMaster integration adds complexity but provides excellent tracking
* Last Updated: 2025-06-06
*/

import SwiftUI
import Charts
import CoreData

struct DashboardSpendingChart: View {
    let allFinancialData: FetchedResults<FinancialData>
    let wiringService: TaskMasterWiringService
    
    @State private var chartData: [ChartDataPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Spending Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Details") {
                    Task {
                        _ = await wiringService.trackButtonAction(
                            buttonId: "dashboard-view-details-btn",
                            viewName: "DashboardView",
                            actionDescription: "View Spending Trends Details",
                            expectedOutcome: "Navigate to AnalyticsView with detailed spending trends",
                            metadata: [
                                "chart_data_points": "\(chartData.count)",
                                "has_data": "\(!chartData.isEmpty)",
                                "navigation_target": "AnalyticsView"
                            ]
                        )
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No financial data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Upload documents with financial data to see trends")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                Chart(chartData) { dataPoint in
                    BarMark(
                        x: .value("Month", dataPoint.month),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            loadChartData()
        }
        .onChange(of: allFinancialData.count) { _ in
            loadChartData()
        }
    }
    
    private func loadChartData() {
        var monthlyData: [String: Double] = [:]
        
        // Get last 6 months of data
        for i in 0..<6 {
            guard let monthDate = Calendar.current.date(byAdding: .month, value: -i, to: Date()) else { continue }
            let monthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: monthDate) - 1]
            let monthAbbr = String(monthName.prefix(3))
            
            let startOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.start ?? monthDate
            let endOfMonth = Calendar.current.dateInterval(of: .month, for: monthDate)?.end ?? monthDate
            
            let monthExpenses = allFinancialData
                .filter { 
                    guard let date = $0.invoiceDate else { return false }
                    return date >= startOfMonth && date <= endOfMonth
                }
                .compactMap { $0.totalAmount?.doubleValue }
                .filter { $0 < 0 }
                .reduce(0, +)
            
            monthlyData[monthAbbr] = abs(monthExpenses)
        }
        
        // Create chart data points
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        var newChartData: [ChartDataPoint] = []
        for i in 0..<6 {
            let monthIndex = (currentMonth - 1 - i + 12) % 12
            let monthName = String(months[monthIndex].prefix(3))
            let amount = monthlyData[monthName] ?? 0
            newChartData.append(ChartDataPoint(month: monthName, amount: amount))
        }
        
        chartData = newChartData.reversed() // Show oldest to newest
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}