import Charts
import SwiftUI

struct MultiAccountDashboard: View {
    @StateObject private var aggregationService = AccountAggregationService()
    @State private var selectedTimePeriod: TimePeriod = .month
    @State private var selectedTab = 0
    @State private var showingAddAccount = false
    @State private var showingAccountDetails: FinancialAccount?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView

            if aggregationService.accounts.isEmpty {
                emptyStateView
            } else {
                tabView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            aggregationService.loadAccounts()
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountSheet { account in
                aggregationService.addAccount(account)
            }
        }
        .sheet(item: $showingAccountDetails) { account in
            AccountDetailsSheet(account: account, aggregationService: aggregationService)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "building.columns.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text("Multi-Account Dashboard")
                    .font(.headline)
                    .fontWeight(.semibold)

                if let lastSync = aggregationService.lastSyncTime {
                    Text("Last synced: \(lastSync, formatter: lastSyncFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Connect your accounts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                if aggregationService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button(action: {
                        Task {
                            await aggregationService.syncAllAccounts()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sync")
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Button(action: { showingAddAccount = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Account")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.columns")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Accounts Connected")
                .font(.headline)

            Text("Connect your bank accounts, credit cards, and investments to get a complete financial picture")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Connect Your First Account") {
                showingAddAccount = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var tabView: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                TabButton(title: "Overview", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "All Accounts", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Net Worth", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "Cash Flow", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.bottom, 16)

            // Tab content
            switch selectedTab {
            case 0:
                overviewTab
            case 1:
                allAccountsTab
            case 2:
                netWorthTab
            case 3:
                cashFlowTab
            default:
                overviewTab
            }
        }
    }

    private var overviewTab: some View {
        VStack(spacing: 16) {
            netWorthSummaryCards
            accountsByInstitutionView
            recentAccountActivityView
        }
    }

    private var allAccountsTab: some View {
        AllAccountsTabView(
            accounts: aggregationService.accounts,
            onAccountTapped: { account in
                showingAccountDetails = account
            },
            onRemoveAccount: { account in
                aggregationService.removeAccount(account)
            }
        )
    }

    private var netWorthTab: some View {
        NetWorthTabView(
            aggregationService: aggregationService,
            selectedPeriod: $selectedTimePeriod
        )
    }

    private var cashFlowTab: some View {
        CashFlowTabView(
            aggregationService: aggregationService,
            selectedPeriod: $selectedTimePeriod
        )
    }

    private var netWorthSummaryCards: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Net Worth",
                value: formatCurrency(aggregationService.totalNetWorth),
                icon: "chart.line.uptrend.xyaxis",
                color: aggregationService.totalNetWorth >= 0 ? .green : .red
            )

            SummaryCard(
                title: "Total Assets",
                value: formatCurrency(aggregationService.totalAssets),
                icon: "plus.circle.fill",
                color: .blue
            )

            SummaryCard(
                title: "Total Liabilities",
                value: formatCurrency(aggregationService.totalLiabilities),
                icon: "minus.circle.fill",
                color: .orange
            )
        }
    }

    private var accountsByInstitutionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accounts by Institution")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVStack(spacing: 8) {
                ForEach(Array(aggregationService.accountsByInstitution.keys.sorted()), id: \.self) { institution in
                    if let accounts = aggregationService.accountsByInstitution[institution] {
                        InstitutionGroupView(
                            institutionName: institution,
                            accounts: accounts
                        ) { account in
                                showingAccountDetails = account
                            }
                    }
                }
            }
        }
    }

    private var recentAccountActivityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 8) {
                ForEach(aggregationService.accounts.prefix(5)) { account in
                    HStack {
                        Image(systemName: account.accountTypeIcon)
                            .foregroundColor(account.accountTypeColor)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .font(.body)
                                .fontWeight(.medium)

                            Text(account.institutionName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(account.formattedBalance)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(account.balance >= 0 ? .primary : .red)

                            Text("Updated \(account.lastUpdated, formatter: timeFormatter)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views

struct InstitutionGroupView: View {
    let institutionName: String
    let accounts: [FinancialAccount]
    let onAccountTapped: (FinancialAccount) -> Void

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(institutionName)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Text(formatCurrency(totalBalance))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(totalBalance >= 0 ? .primary : .red)
            }

            LazyVStack(spacing: 4) {
                ForEach(accounts) { account in
                    AccountRowView(account: account) {
                        onAccountTapped(account)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct AccountRowView: View {
    let account: FinancialAccount
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack {
                Image(systemName: account.accountTypeIcon)
                    .foregroundColor(account.accountTypeColor)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(account.maskedAccountNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(account.formattedBalance)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(account.balance >= 0 ? .primary : .red)

                    if let utilization = account.creditUtilization {
                        Text("\(Int(utilization * 100))% used")
                            .font(.caption2)
                            .foregroundColor(utilization > 0.8 ? .red : (utilization > 0.5 ? .orange : .green))
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct AllAccountsTabView: View {
    let accounts: [FinancialAccount]
    let onAccountTapped: (FinancialAccount) -> Void
    let onRemoveAccount: (FinancialAccount) -> Void

    var accountsByType: [AccountType: [FinancialAccount]] {
        Dictionary(grouping: accounts) { $0.type }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(AccountType.allCases, id: \.self) { accountType in
                    if let typeAccounts = accountsByType[accountType], !typeAccounts.isEmpty {
                        AccountTypeGroupView(
                            accountType: accountType,
                            accounts: typeAccounts,
                            onAccountTapped: onAccountTapped,
                            onRemoveAccount: onRemoveAccount
                        )
                    }
                }
            }
        }
    }
}

struct AccountTypeGroupView: View {
    let accountType: AccountType
    let accounts: [FinancialAccount]
    let onAccountTapped: (FinancialAccount) -> Void
    let onRemoveAccount: (FinancialAccount) -> Void

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: accountType.icon)
                    .foregroundColor(accountType.color)
                    .frame(width: 24)

                Text(accountType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text(formatCurrency(totalBalance))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(totalBalance >= 0 ? .primary : .red)
            }

            LazyVStack(spacing: 8) {
                ForEach(accounts) { account in
                    EnhancedAccountRowView(
                        account: account,
                        onTapped: { onAccountTapped(account) },
                        onRemove: { onRemoveAccount(account) }
                    )
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct EnhancedAccountRowView: View {
    let account: FinancialAccount
    let onTapped: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Image(systemName: account.accountTypeIcon)
                .foregroundColor(account.accountTypeColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack {
                    Text(account.institutionName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(account.maskedAccountNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(account.formattedBalance)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(account.balance >= 0 ? .primary : .red)

                if let utilization = account.creditUtilization {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(utilization > 0.8 ? .red : (utilization > 0.5 ? .orange : .green))
                            .frame(width: 30 * utilization, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: utilization)

                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30 * (1 - utilization), height: 4)
                    }

                    Text("\(Int(utilization * 100))% used")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text("Updated \(account.lastUpdated, formatter: timeFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Menu {
                Button("View Details", action: onTapped)
                Button("Remove Account", role: .destructive, action: onRemove)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onTapGesture {
            onTapped()
        }
    }
}

// MARK: - Formatters

private let lastSyncFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    MultiAccountDashboard()
        .frame(width: 800, height: 700)
}
