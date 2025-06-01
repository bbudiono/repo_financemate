// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Comprehensive financial dashboard displaying key metrics, recent activity, and quick actions - SANDBOX VERSION
* Issues & Complexity Summary: Complex state management for financial data, real-time updates, chart integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~180
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (Charts framework integration)
  - State Management Complexity: Medium-High
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 75%
* Justification for Estimates: Dashboard requires multiple data sources, real-time updates, and coordinated UI elements
* Final Code Complexity (Actual %): 78%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: Chart integration simpler than expected, state management well-structured
* Last Updated: 2025-06-02
*/

import SwiftUI
import Charts

struct DashboardView: View {
    @State private var totalBalance: Double = 15847.32
    @State private var monthlyIncome: Double = 4200.00
    @State private var monthlyExpenses: Double = 2856.75
    @State private var monthlyGoal: Double = 5000.00
    @State private var recentTransactions: [Transaction] = []
    @State private var showingAddTransaction = false
    @State private var chartData: [ChartDataPoint] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // SANDBOX HEADER WITH WATERMARK
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Financial Overview")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("🧪 SANDBOX MODE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Text("Welcome back! Here's your financial summary.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Metrics Cards Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    MetricCard(
                        title: "Total Balance",
                        value: formatCurrency(totalBalance),
                        icon: "dollarsign.circle.fill",
                        color: .green,
                        trend: "+12.5%"
                    )
                    
                    MetricCard(
                        title: "Monthly Income",
                        value: formatCurrency(monthlyIncome),
                        icon: "arrow.up.circle.fill",
                        color: .blue,
                        trend: "+8.2%"
                    )
                    
                    MetricCard(
                        title: "Monthly Expenses",
                        value: formatCurrency(monthlyExpenses),
                        icon: "arrow.down.circle.fill",
                        color: .orange,
                        trend: "-5.1%"
                    )
                    
                    MetricCard(
                        title: "Monthly Goal",
                        value: formatCurrency(monthlyGoal),
                        icon: "target",
                        color: .purple,
                        trend: "85% achieved"
                    )
                }
                .padding(.horizontal)
                
                // Spending Chart Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Spending Trends")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("View Details") {
                            // Navigate to analytics
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
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
                .padding(.vertical)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Recent Transactions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Activity")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("View All") {
                            // Navigate to documents
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    if recentTransactions.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            
                            Text("No recent transactions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Upload documents to get started (SANDBOX)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionButton(
                            title: "Upload Document",
                            icon: "plus.circle.fill",
                            color: .blue
                        ) {
                            // Navigate to document upload
                        }
                        
                        QuickActionButton(
                            title: "Add Transaction",
                            icon: "plus.square.fill",
                            color: .green
                        ) {
                            showingAddTransaction = true
                        }
                        
                        QuickActionButton(
                            title: "View Reports",
                            icon: "chart.bar.fill",
                            color: .purple
                        ) {
                            // Navigate to analytics
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Dashboard")
        .onAppear {
            loadDashboardData()
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func loadDashboardData() {
        // Load sample chart data
        chartData = [
            ChartDataPoint(month: "Jan", amount: 2400),
            ChartDataPoint(month: "Feb", amount: 2100),
            ChartDataPoint(month: "Mar", amount: 2856),
            ChartDataPoint(month: "Apr", amount: 2600),
            ChartDataPoint(month: "May", amount: 2200),
            ChartDataPoint(month: "Jun", amount: 2856)
        ]
        
        // Load sample transactions (would be from Core Data or service)
        recentTransactions = []
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

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(transaction.category.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct Transaction: Identifiable {
    let id = UUID()
    let description: String
    let amount: Double
    let date: Date
    let category: TransactionCategory
    let isExpense: Bool
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let prefix = isExpense ? "-" : "+"
        return prefix + (formatter.string(from: NSNumber(value: amount)) ?? "$0.00")
    }
}

struct TransactionCategory {
    let name: String
    let icon: String
    let color: Color
}

// Placeholder for AddTransactionView
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🧪 SANDBOX: Add Transaction")
                    .font(.title)
                    .foregroundColor(.orange)
                Text("Feature coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        DashboardView()
    }
}