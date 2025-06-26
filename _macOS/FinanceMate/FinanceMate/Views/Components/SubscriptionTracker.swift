import CoreData
import SwiftUI

struct SubscriptionTracker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var detectionEngine = SubscriptionDetectionEngine()
    @State private var subscriptions: [Subscription] = []
    @State private var totalMonthlyAmount: Double = 0
    @State private var upcomingRenewals: [Subscription] = []
    @State private var optimizationSuggestions: [OptimizationSuggestion] = []
    @State private var recurringPatterns: [RecurringPattern] = []
    @State private var showingAddSubscription = false
    @State private var showingOptimizations = false
    @State private var showingDetectedSubscriptions = false
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView

            if subscriptions.isEmpty {
                emptyStateView
            } else {
                tabView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            loadSubscriptions()
            runAutoDetection()
            generateOptimizations()
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionSheet { subscription in
                addSubscription(subscription)
            }
        }
        .sheet(isPresented: $showingOptimizations) {
            OptimizationSheet(suggestions: optimizationSuggestions)
        }
        .sheet(isPresented: $showingDetectedSubscriptions) {
            DetectedSubscriptionsSheet(patterns: recurringPatterns) { pattern in
                convertPatternToSubscription(pattern)
            }
        }
    }

    private var tabView: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                TabButton(title: "Overview", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "All Subscriptions", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "Optimize", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "Auto-Detect", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.bottom, 16)

            // Tab content
            switch selectedTab {
            case 0:
                overviewTab
            case 1:
                allSubscriptionsTab
            case 2:
                optimizationTab
            case 3:
                autoDetectTab
            default:
                overviewTab
            }
        }
    }

    private var overviewTab: some View {
        VStack(spacing: 16) {
            summaryCardsView
            upcomingRenewalsView
            recentActivityView
        }
    }

    private var allSubscriptionsTab: some View {
        allSubscriptionsView
    }

    private var optimizationTab: some View {
        OptimizationTabView(
            suggestions: optimizationSuggestions,
            totalMonthlySavings: optimizationSuggestions.reduce(0) { $0 + $1.potentialSavings }
        )
    }

    private var autoDetectTab: some View {
        AutoDetectTabView(
            patterns: recurringPatterns
        ) { pattern in
                convertPatternToSubscription(pattern)
            }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "repeat.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text("Subscription Tracker")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Monitor recurring payments")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showingAddSubscription = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Subscription")
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "repeat.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Subscriptions Yet")
                .font(.headline)

            Text("Start tracking your recurring payments")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Add Your First Subscription") {
                showingAddSubscription = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var summaryCardsView: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Monthly Total",
                value: formatCurrency(totalMonthlyAmount),
                icon: "dollarsign.circle.fill",
                color: .blue
            )

            SummaryCard(
                title: "Active Subscriptions",
                value: "\(subscriptions.count)",
                icon: "repeat.circle.fill",
                color: .green
            )

            SummaryCard(
                title: "Next Renewal",
                value: nextRenewalText,
                icon: "calendar.circle.fill",
                color: .orange
            )
        }
    }

    private var upcomingRenewalsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Renewals")
                .font(.subheadline)
                .fontWeight(.medium)

            if upcomingRenewals.isEmpty {
                Text("No renewals in the next 7 days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(upcomingRenewals) { subscription in
                    UpcomingRenewalRow(subscription: subscription)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var allSubscriptionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Subscriptions")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVStack(spacing: 8) {
                ForEach(subscriptions) { subscription in
                    SubscriptionRow(
                        subscription: subscription,
                        onCancel: { cancelSubscription(subscription) },
                        onEdit: { editSubscription(subscription) }
                    )
                }
            }
        }
    }

    private var nextRenewalText: String {
        guard let nextSubscription = subscriptions.min(by: { $0.nextRenewalDate < $1.nextRenewalDate }) else {
            return "None"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: nextSubscription.nextRenewalDate)
    }

    private var recentActivityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(spacing: 8) {
                ForEach(subscriptions.prefix(3)) { subscription in
                    HStack {
                        Image(systemName: subscription.icon)
                            .foregroundColor(subscription.color)
                            .frame(width: 20)

                        Text("Renewed \(subscription.name)")
                            .font(.body)

                        Spacer()

                        Text(subscription.formattedAmount)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func runAutoDetection() {
        // Simulate analyzing transactions for recurring patterns
        Task {
            let sampleTransactions = generateSampleTransactions()
            recurringPatterns = await detectionEngine.analyzeRecurringTransactions(sampleTransactions)
        }
    }

    private func generateOptimizations() {
        optimizationSuggestions = detectionEngine.optimizeSubscriptions(subscriptions)
    }

    private func generateSampleTransactions() -> [TransactionData] {
        // In a real app, this would fetch actual transaction data
        [
            TransactionData(description: "SPOTIFY PREMIUM", amount: 9.99, date: Date().addingTimeInterval(-86_400 * 30), merchant: "Spotify"),
            TransactionData(description: "SPOTIFY PREMIUM", amount: 9.99, date: Date().addingTimeInterval(-86_400 * 60), merchant: "Spotify"),
            TransactionData(description: "NETFLIX.COM", amount: 15.99, date: Date().addingTimeInterval(-86_400 * 28), merchant: "Netflix"),
            TransactionData(description: "NETFLIX.COM", amount: 15.99, date: Date().addingTimeInterval(-86_400 * 56), merchant: "Netflix"),
            TransactionData(description: "ADOBE CREATIVE", amount: 52.99, date: Date().addingTimeInterval(-86_400 * 31), merchant: "Adobe"),
            TransactionData(description: "AMAZON PRIME", amount: 12.99, date: Date().addingTimeInterval(-86_400 * 29), merchant: "Amazon")
        ]
    }

    private func convertPatternToSubscription(_ pattern: RecurringPattern) {
        let detection = detectionEngine.detectSubscription(
            from: pattern.merchant,
            amount: pattern.averageAmount,
            date: pattern.lastTransaction
        )

        let newSubscription = Subscription(
            name: detection?.serviceName ?? pattern.merchant,
            amount: pattern.averageAmount,
            billingCycle: determineBillingCycle(from: pattern.interval),
            nextRenewalDate: pattern.predictedNextDate,
            category: detection?.category ?? "Unknown",
            icon: detection?.icon ?? "app.fill",
            color: detection?.color ?? .blue
        )

        addSubscription(newSubscription)

        // Remove from patterns
        recurringPatterns.removeAll { $0.merchant == pattern.merchant }
    }

    private func determineBillingCycle(from interval: TimeInterval) -> BillingCycle {
        let days = interval / 86_400

        if days <= 10 {
            return .weekly
        } else if days <= 45 {
            return .monthly
        } else {
            return .yearly
        }
    }

    private func loadSubscriptions() {
        subscriptions = [
            Subscription(
                name: "Netflix",
                amount: 15.99,
                billingCycle: .monthly,
                nextRenewalDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                category: "Entertainment",
                icon: "tv.fill",
                color: .red
            ),
            Subscription(
                name: "Spotify Premium",
                amount: 9.99,
                billingCycle: .monthly,
                nextRenewalDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(),
                category: "Music",
                icon: "music.note",
                color: .green
            ),
            Subscription(
                name: "Adobe Creative Cloud",
                amount: 52.99,
                billingCycle: .monthly,
                nextRenewalDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date(),
                category: "Software",
                icon: "paintbrush.fill",
                color: .purple
            ),
            Subscription(
                name: "iCloud Storage",
                amount: 2.99,
                billingCycle: .monthly,
                nextRenewalDate: Calendar.current.date(byAdding: .day, value: 8, to: Date()) ?? Date(),
                category: "Storage",
                icon: "icloud.fill",
                color: .blue
            )
        ]

        calculateTotals()
        updateUpcomingRenewals()
    }

    private func calculateTotals() {
        totalMonthlyAmount = subscriptions.reduce(0) { total, subscription in
            total + subscription.monthlyAmount
        }
    }

    private func updateUpcomingRenewals() {
        let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        upcomingRenewals = subscriptions.filter { $0.nextRenewalDate <= sevenDaysFromNow }
            .sorted { $0.nextRenewalDate < $1.nextRenewalDate }
    }

    private func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        calculateTotals()
        updateUpcomingRenewals()
    }

    private func cancelSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
        calculateTotals()
        updateUpcomingRenewals()
    }

    private func editSubscription(_ subscription: Subscription) {
        // Implementation for editing subscription
        print("Edit subscription: \(subscription.name)")
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct SummaryCard: View {
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

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct UpcomingRenewalRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            Image(systemName: subscription.icon)
                .foregroundColor(subscription.color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("Renews \(subscription.nextRenewalDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(subscription.formattedAmount)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct SubscriptionRow: View {
    let subscription: Subscription
    let onCancel: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: subscription.icon)
                .foregroundColor(subscription.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack {
                    Text(subscription.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(subscription.billingCycle.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.formattedAmount)
                    .font(.body)
                    .fontWeight(.semibold)

                Text("Next: \(subscription.nextRenewalDate, formatter: shortDateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Menu {
                Button("Edit", action: onEdit)
                Button("Cancel Subscription", role: .destructive, action: onCancel)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct AddSubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var amount = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var nextRenewalDate = Date()
    @State private var category = "Entertainment"

    let onAdd: (Subscription) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Subscription Details") {
                    TextField("Service Name", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.displayName).tag(cycle)
                        }
                    }

                    DatePicker("Next Renewal", selection: $nextRenewalDate, displayedComponents: .date)

                    TextField("Category", text: $category)
                }
            }
            .navigationTitle("Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let amountValue = Double(amount), !name.isEmpty else { return }

                        let subscription = Subscription(
                            name: name,
                            amount: amountValue,
                            billingCycle: billingCycle,
                            nextRenewalDate: nextRenewalDate,
                            category: category,
                            icon: "app.fill",
                            color: .blue
                        )

                        onAdd(subscription)
                        dismiss()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

struct Subscription: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let billingCycle: BillingCycle
    let nextRenewalDate: Date
    let category: String
    let icon: String
    let color: Color

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    var monthlyAmount: Double {
        switch billingCycle {
        case .monthly: return amount
        case .yearly: return amount / 12
        case .weekly: return amount * 4.33
        }
    }
}

enum BillingCycle: CaseIterable {
    case weekly, monthly, yearly

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - New UI Components

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? Color.accentColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

struct OptimizationTabView: View {
    let suggestions: [OptimizationSuggestion]
    let totalMonthlySavings: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Summary card
            HStack {
                VStack(alignment: .leading) {
                    Text("Potential Monthly Savings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(formatCurrency(totalMonthlySavings))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }

                Spacer()

                Image(systemName: "lightbulb.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)

            // Suggestions list
            if suggestions.isEmpty {
                Text("No optimization suggestions available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                        OptimizationSuggestionRow(suggestion: suggestion)
                    }
                }
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct OptimizationSuggestionRow: View {
    let suggestion: OptimizationSuggestion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconForType(suggestion.type))
                .foregroundColor(colorForType(suggestion.type))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.body)
                    .fontWeight(.medium)

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)

                if !suggestion.affectedSubscriptions.isEmpty {
                    Text("Affects: \(suggestion.affectedSubscriptions.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(formatCurrency(suggestion.potentialSavings))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)

                Text("\(Int(suggestion.confidence * 100))% confidence")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func iconForType(_ type: OptimizationType) -> String {
        switch type {
        case .duplicateServices: return "doc.on.doc.fill"
        case .underutilized: return "chart.bar.xaxis"
        case .betterPricing: return "dollarsign.circle.fill"
        case .bundleOpportunity: return "gift.fill"
        }
    }

    private func colorForType(_ type: OptimizationType) -> Color {
        switch type {
        case .duplicateServices: return .orange
        case .underutilized: return .red
        case .betterPricing: return .green
        case .bundleOpportunity: return .purple
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct AutoDetectTabView: View {
    let patterns: [RecurringPattern]
    let onConvertPattern: (RecurringPattern) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detected Recurring Payments")
                .font(.headline)
                .fontWeight(.semibold)

            if patterns.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No recurring patterns detected")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Connect your bank account or import transactions to detect subscriptions automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(patterns.enumerated()), id: \.offset) { _, pattern in
                        RecurringPatternRow(pattern: pattern) {
                            onConvertPattern(pattern)
                        }
                    }
                }
            }
        }
    }
}

struct RecurringPatternRow: View {
    let pattern: RecurringPattern
    let onConvert: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "repeat.circle")
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.merchant)
                    .font(.body)
                    .fontWeight(.medium)

                HStack {
                    Text("\(pattern.transactionCount) transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(pattern.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(pattern.averageAmount))
                    .font(.body)
                    .fontWeight(.semibold)

                Text("Next: \(pattern.predictedNextDate, formatter: shortDateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("Add as Subscription") {
                onConvert()
            }
            .buttonStyle(.bordered)
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

struct OptimizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    let suggestions: [OptimizationSuggestion]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Optimization Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                            OptimizationSuggestionRow(suggestion: suggestion)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct DetectedSubscriptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let patterns: [RecurringPattern]
    let onConvertPattern: (RecurringPattern) -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Detected Subscriptions")
                    .font(.title2)
                    .fontWeight(.bold)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(patterns.enumerated()), id: \.offset) { _, pattern in
                            RecurringPatternRow(pattern: pattern) {
                                onConvertPattern(pattern)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

#Preview {
    SubscriptionTracker()
        .frame(width: 700, height: 600)
}
