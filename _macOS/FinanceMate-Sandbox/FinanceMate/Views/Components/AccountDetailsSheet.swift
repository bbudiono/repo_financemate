import Charts
import SwiftUI

struct AccountDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let account: FinancialAccount
    let aggregationService: AccountAggregationService
    @State private var selectedPeriod: TimePeriod = .month
    @State private var accountPerformance: AccountPerformance?
    @State private var showingEditAccount = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Account header
                accountHeaderView

                Divider()

                // Content tabs
                ScrollView {
                    VStack(spacing: 20) {
                        periodSelectorView

                        if let performance = accountPerformance {
                            performanceOverviewView(performance: performance)
                            balanceHistoryChart(performance: performance)
                            recentTransactionsView(performance: performance)
                        } else {
                            ProgressView("Loading account details...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

                        accountSettingsView
                    }
                    .padding()
                }
            }
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { showingEditAccount = true }
                }
            }
        }
        .frame(width: 600, height: 700)
        .onAppear {
            loadAccountPerformance()
        }
        .onChange(of: selectedPeriod) { _, _ in
            loadAccountPerformance()
        }
        .sheet(isPresented: $showingEditAccount) {
            EditAccountSheet(account: account) { _ in
                // Handle account update
            }
        }
    }

    private var accountHeaderView: some View {
        HStack(spacing: 16) {
            // Account icon and type
            VStack {
                Image(systemName: account.accountTypeIcon)
                    .font(.title)
                    .foregroundColor(account.accountTypeColor)
                    .frame(width: 50, height: 50)
                    .background(account.accountTypeColor.opacity(0.1))
                    .cornerRadius(25)

                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Account details
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(account.institutionName)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text(account.maskedAccountNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }

            Spacer()

            // Current balance
            VStack(alignment: .trailing, spacing: 4) {
                Text("Current Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(account.formattedBalance)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)

                if let utilization = account.creditUtilization {
                    Text("\(Int(utilization * 100))% utilized")
                        .font(.caption)
                        .foregroundColor(utilization > 0.8 ? .red : (utilization > 0.5 ? .orange : .green))
                }

                Text("Updated \(account.lastUpdated, formatter: dateFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var periodSelectorView: some View {
        HStack {
            Text("Performance")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 250)
        }
    }

    private func performanceOverviewView(performance: AccountPerformance) -> some View {
        HStack(spacing: 16) {
            PerformanceCard(
                title: "Starting Balance",
                value: formatCurrency(performance.startingBalance),
                icon: "calendar",
                color: .blue
            )

            PerformanceCard(
                title: "Change",
                value: formatCurrency(performance.change),
                icon: performance.isPositive ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                color: performance.isPositive ? .green : .red
            )

            PerformanceCard(
                title: "Percentage Change",
                value: "\(String(format: "%.1f", performance.percentageChange))%",
                icon: "percent",
                color: performance.isPositive ? .green : .red
            )
        }
    }

    private func balanceHistoryChart(performance: AccountPerformance) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance History")
                .font(.subheadline)
                .fontWeight(.medium)

            // Simulated balance history chart
            Chart(generateBalanceHistory(performance: performance), id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(account.accountTypeColor)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [account.accountTypeColor.opacity(0.3), account.accountTypeColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyCompact(amount))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func recentTransactionsView(performance: AccountPerformance) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Button("View All") {
                    // Handle view all transactions
                }
                .font(.caption)
            }

            LazyVStack(spacing: 8) {
                ForEach(performance.transactions.prefix(5)) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }

            if performance.transactions.isEmpty {
                Text("No recent transactions")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var accountSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Settings")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 8) {
                SettingRow(
                    icon: "arrow.clockwise",
                    title: "Sync Account",
                    subtitle: "Update balance and transactions"
                ) {
                    Task {
                        await aggregationService.syncAccount(account)
                    }
                }

                SettingRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Balance alerts and updates"
                ) {
                    // Handle notifications settings
                }

                SettingRow(
                    icon: "lock",
                    title: "Security",
                    subtitle: "Account security settings"
                ) {
                    // Handle security settings
                }

                SettingRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Download transaction history"
                ) {
                    // Handle export
                }

                SettingRow(
                    icon: "trash",
                    title: "Remove Account",
                    subtitle: "Disconnect this account",
                    isDestructive: true
                ) {
                    aggregationService.removeAccount(account)
                    dismiss()
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func loadAccountPerformance() {
        accountPerformance = aggregationService.getAccountPerformance(for: account, period: selectedPeriod)
    }

    private func generateBalanceHistory(performance: AccountPerformance) -> [BalanceDataPoint] {
        var dataPoints: [BalanceDataPoint] = []
        let calendar = Calendar.current
        let daysBack = selectedPeriod.daysBack

        for i in (0...daysBack).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let variation = Double.random(in: -100...100)
            let balance = performance.endingBalance + variation

            dataPoints.append(BalanceDataPoint(date: date, balance: balance))
        }

        return dataPoints
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(amount) >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "$0" + "M"
        } else if abs(amount) >= 1000 {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount / 1000)) ?? "$0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

struct PerformanceCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Image(systemName: transaction.amount >= 0 ? "plus.circle.fill" : "minus.circle.fill")
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.body)
                    .fontWeight(.medium)

                Text(transaction.date, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatCurrency(transaction.amount))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isDestructive ? .red : .primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

struct EditAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    let account: FinancialAccount
    let onUpdate: (FinancialAccount) -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Account - \(account.name)")
                    .font(.title2)
                    .fontWeight(.bold)

                // Add edit form here
                Text("Edit functionality coming soon...")
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

struct BalanceDataPoint {
    let date: Date
    let balance: Double
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    AccountDetailsSheet(
        account: FinancialAccount(
            name: "Primary Checking",
            institutionName: "Chase Bank",
            type: .checking,
            balance: 5420.50,
            accountNumber: "****1234",
            routingNumber: "021000021",
            isActive: true,
            lastUpdated: Date()
        ),
        aggregationService: AccountAggregationService()
    )
}
