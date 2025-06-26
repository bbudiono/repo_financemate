import Foundation
import SwiftUI

struct SubscriptionManagementView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showingAddSubscription = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Stats Cards
                headerSection

                // Subscription List
                if viewModel.subscriptions.isEmpty {
                    emptyStateView
                } else {
                    subscriptionListView
                }

                Spacer()
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSubscription = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Monthly Stats Cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Monthly Total",
                    value: viewModel.monthlyTotal,
                    color: .blue,
                    icon: "creditcard.fill"
                )

                StatCard(
                    title: "Annual Total",
                    value: viewModel.annualTotal,
                    color: .green,
                    icon: "chart.line.uptrend.xyaxis"
                )

                StatCard(
                    title: "Active Subs",
                    value: "\(viewModel.activeSubscriptions)",
                    color: .orange,
                    icon: "repeat.circle.fill"
                )
            }
            .padding(.horizontal)

            // Quick Filter Buttons
            HStack(spacing: 12) {
                FilterButton(
                    title: "All",
                    isSelected: viewModel.selectedFilter == .all
                ) { viewModel.selectedFilter = .all }

                FilterButton(
                    title: "Active",
                    isSelected: viewModel.selectedFilter == .active
                ) { viewModel.selectedFilter = .active }

                FilterButton(
                    title: "Paused",
                    isSelected: viewModel.selectedFilter == .paused
                ) { viewModel.selectedFilter = .paused }

                FilterButton(
                    title: "Cancelled",
                    isSelected: viewModel.selectedFilter == .cancelled
                ) { viewModel.selectedFilter = .cancelled }

                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Subscription List
    private var subscriptionListView: some View {
        List {
            ForEach(viewModel.filteredSubscriptions) { subscription in
                SubscriptionRowView(subscription: subscription, viewModel: viewModel)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "repeat.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Subscriptions Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Track your recurring payments and never miss a billing cycle")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { showingAddSubscription = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First Subscription")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        .opacity(isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Subscription Row View
struct SubscriptionRowView: View {
    let subscription: Subscription
    let viewModel: SubscriptionViewModel
    @State private var showingDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                // Service Icon/Logo
                serviceIcon

                // Subscription Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(subscription.serviceName ?? "Unknown Service")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(subscription.plan ?? "Unknown Plan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Cost and Status
                VStack(alignment: .trailing, spacing: 4) {
                    Text(subscription.formattedCost)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(subscription.status == "active" ? .primary : .secondary)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor(for: subscription.status))
                            .frame(width: 8, height: 8)

                        Text(statusDisplayName(for: subscription.status))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)

            // Next Billing Info (for active subscriptions)
            if subscription.status == "active", let nextBillingDate = subscription.nextBillingDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Text("Next billing: \(nextBillingDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(subscription.daysUntilNextBilling) days")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(subscription.daysUntilNextBilling <= 3 ? .orange : .secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            SubscriptionDetailView(subscription: subscription, viewModel: viewModel)
        }
    }

    private var serviceIcon: some View {
        ZStack {
            Circle()
                .fill(brandColor(from: subscription.brandColorHex).opacity(0.1))
                .frame(width: 40, height: 40)

            let iconName = subscription.systemIcon
            if !iconName.isEmpty && iconName != "circle.fill" {
                Image(systemName: iconName)
                    .foregroundColor(brandColor(from: subscription.brandColorHex))
                    .font(.system(size: 20))
            } else {
                Text(String((subscription.serviceName ?? "?").prefix(1).uppercased()))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(brandColor(from: subscription.brandColorHex))
            }
        }
    }

    private func statusColor(for status: String?) -> Color {
        switch status {
        case "active":
            return .green
        case "paused":
            return .orange
        case "cancelled":
            return .red
        default:
            return .secondary
        }
    }

    private func statusDisplayName(for status: String?) -> String {
        switch status {
        case "active":
            return "Active"
        case "paused":
            return "Paused"
        case "cancelled":
            return "Cancelled"
        default:
            return "Unknown"
        }
    }

    private func brandColor(from hex: String?) -> Color {
        guard let hex = hex, !hex.isEmpty else {
            return Color.blue
        }

        // Convert hex string to Color
        var hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexValue.hasPrefix("#") {
            hexValue.removeFirst()
        }

        guard let intValue = UInt(hexValue, radix: 16) else {
            return Color.blue
        }

        let red = Double((intValue >> 16) & 0xFF) / 255.0
        let green = Double((intValue >> 8) & 0xFF) / 255.0
        let blue = Double(intValue & 0xFF) / 255.0

        return Color(.sRGB, red: red, green: green, blue: blue)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

#Preview {
    SubscriptionManagementView()
}
