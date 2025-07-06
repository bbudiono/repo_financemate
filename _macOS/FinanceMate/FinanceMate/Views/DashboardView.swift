//
// DashboardView.swift
// FinanceMate
//
// Purpose: Dashboard UI implementation with glassmorphism styling and MVVM architecture
// Issues & Complexity Summary: SwiftUI view with glassmorphism effects, data binding, and responsive layout
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~200
//   - Core Algorithm Complexity: Medium
//   - Dependencies: 3 (SwiftUI, DashboardViewModel, GlassmorphismModifier)
//   - State Management Complexity: Medium
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 88%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: 87%
// Overall Result Score: 92%
// Key Variances/Learnings: Clean MVVM integration with glassmorphism design system
// Last Updated: 2025-07-05

import CoreData
import SwiftUI

/// Dashboard view displaying financial overview with glassmorphism styling
///
/// This view provides a comprehensive dashboard for financial data including:
/// - Total balance display with color-coded indicators
/// - Transaction count and summary information
/// - Recent transactions preview
/// - Loading states and error handling
/// - Responsive layout with glassmorphism design
struct DashboardView: View {

    @EnvironmentObject private var viewModel: DashboardViewModel
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Main Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Dashboard Header
                dashboardHeader

                // Balance Card
                balanceCard

                // Quick Stats Cards
                quickStatsSection

                // Recent Transactions
                if !viewModel.recentTransactions.isEmpty {
                    recentTransactionsSection
                }

                // Action Buttons
                actionButtonsSection
            }
            .padding()
        }
        .accessibilityIdentifier("DashboardView")
        .background(dashboardBackground)
        .onAppear {
            viewModel.fetchDashboardData()
        }
        .refreshable {
            viewModel.refreshData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Dashboard Header

    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Financial Overview")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Refresh Button
            Button(action: {
                viewModel.refreshData()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .accessibilityIdentifier("RefreshData")
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 16) {
            // Balance Header
            HStack {
                Image(systemName: viewModel.balanceIcon)
                    .font(.title2)
                    .foregroundColor(viewModel.balanceColor)

                Text("Total Balance")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }

            // Balance Amount
            HStack {
                Text(viewModel.formattedTotalBalance)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.balanceColor)
                    .accessibilityIdentifier("BalanceDisplay")

                Spacer()
            }

            // Balance Subtitle
            HStack {
                Text(viewModel.transactionCountDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("TransactionCount")

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(20)
        .glassmorphism(.primary, cornerRadius: 16)
        .accessibilityIdentifier("BalanceCard")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Total balance: \(viewModel.formattedTotalBalance), \(viewModel.transactionCountDescription)"
        )
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            // Transaction Count Stat
            quickStatCard(
                title: "Transactions",
                value: "\(viewModel.transactionCount)",
                icon: "list.bullet.rectangle",
                color: .blue
            )

            // Average Transaction Stat
            quickStatCard(
                title: "Average",
                value: averageTransactionValue,
                icon: "chart.line.uptrend.xyaxis",
                color: .green
            )

            // Status Indicator
            quickStatCard(
                title: "Status",
                value: viewModel.isEmpty ? "Empty" : "Active",
                icon: viewModel.isEmpty ? "exclamationmark.circle" : "checkmark.circle",
                color: viewModel.isEmpty ? .orange : .green
            )
        }
    }

    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .glassmorphism(.secondary, cornerRadius: 12)
    }

    // MARK: - Recent Transactions Section

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button("View All") {
                    // TODO: Navigate to full transactions view
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 4)

            // Transactions List
            VStack(spacing: 8) {
                ForEach(viewModel.recentTransactions.prefix(5), id: \.id) { transaction in
                    recentTransactionRow(transaction)
                }
            }
            .padding(16)
            .glassmorphism(.secondary, cornerRadius: 12)
            .accessibilityIdentifier("RecentTransactionsCard")
        }
    }

    private func recentTransactionRow(_ transaction: Transaction) -> some View {
        HStack {
            // Transaction Category Icon
            Image(systemName: categoryIcon(for: transaction.category))
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            // Transaction Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Transaction Amount and Date
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.formatCurrency(transaction.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.amount >= 0 ? .green : .red)

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            // Add Transaction Button
            actionButton(
                title: "Add Transaction",
                icon: "plus.circle.fill",
                color: .blue
            ) {
                // TODO: Navigate to add transaction
            }

            // View Reports Button
            actionButton(
                title: "View Reports",
                icon: "chart.bar.fill",
                color: .green
            ) {
                // TODO: Navigate to reports
            }
        }
    }

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.gradient)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helper Views and Computed Properties

    private var dashboardBackground: some View {
        LinearGradient(
            colors: colorScheme == .light ?
                [Color.blue.opacity(0.1), Color.purple.opacity(0.1)] :
                [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .accessibilityIdentifier("GlassmorphismContainer")
    }

    private var averageTransactionValue: String {
        guard viewModel.transactionCount > 0 else { return "$0.00" }
        let average = viewModel.totalBalance / Double(viewModel.transactionCount)
        return viewModel.formatCurrency(average)
    }

    // MARK: - Helper Functions

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "food", "dining":
            return "fork.knife"
        case "transportation", "travel":
            return "car.fill"
        case "shopping", "retail":
            return "bag.fill"
        case "entertainment":
            return "tv.fill"
        case "utilities", "bills":
            return "lightbulb.fill"
        case "income", "salary":
            return "dollarsign.circle.fill"
        case "healthcare", "medical":
            return "cross.fill"
        case "education":
            return "book.fill"
        default:
            return "circle.fill"
        }
    }
}

// MARK: - Preview Provider

#Preview("Dashboard with Data") {
    DashboardView()
        .environmentObject(DashboardViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.light)
}

#Preview("Dashboard Empty State") {
    DashboardView()
        .environmentObject(DashboardViewModel(context: PersistenceController(inMemory: true).container.viewContext))
        .environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
        .preferredColorScheme(.light)
}

#Preview("Dashboard Dark Mode") {
    DashboardView()
        .environmentObject(DashboardViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
