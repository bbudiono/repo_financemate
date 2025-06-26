import CoreData
import Foundation
import SwiftUI

struct SubscriptionDetailView: View {
    let subscription: Subscription
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditView = false
    @State private var showingCancelAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    headerSection

                    // Details Section
                    detailsSection

                    // Billing Section
                    billingSection

                    // Actions Section
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Subscription Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        showingEditView = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditSubscriptionView(subscription: subscription, viewModel: viewModel)
        }
        .alert("Cancel Subscription", isPresented: $showingCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                viewModel.cancelSubscription(subscription)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to cancel this subscription? This action cannot be undone.")
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Service Icon
            ZStack {
                Circle()
                    .fill(brandColor.opacity(0.1))
                    .frame(width: 60, height: 60)

                let iconName = subscription.systemIcon
                if !iconName.isEmpty && iconName != "circle.fill" {
                    Image(systemName: iconName)
                        .foregroundColor(brandColor)
                        .font(.system(size: 30))
                } else {
                    Text(String((subscription.serviceName ?? "?").prefix(1).uppercased()))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(brandColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.serviceName ?? "Unknown Service")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(subscription.plan ?? "Unknown Plan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    Text(statusDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                DetailRow(title: "Cost", value: subscription.formattedCost)
                DetailRow(title: "Monthly Cost", value: formatCurrency(subscription.monthlyCost))
                DetailRow(title: "Annual Cost", value: formatCurrency(subscription.annualCost))
                DetailRow(title: "Category", value: subscription.category?.capitalized ?? "Other")

                if let startDate = subscription.startDate {
                    DetailRow(title: "Start Date", value: DateFormatter.medium.string(from: startDate))
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Billing Section
    private var billingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Billing Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                if let nextBilling = subscription.nextBillingDate {
                    DetailRow(title: "Next Billing", value: DateFormatter.medium.string(from: nextBilling))
                    DetailRow(title: "Days Until Billing", value: "\\(subscription.daysUntilNextBilling) days")
                }

                DetailRow(title: "Billing Cycle", value: subscription.billingCycle?.capitalized ?? "Monthly")

                if let notes = subscription.notes, !notes.isEmpty {
                    DetailRow(title: "Notes", value: notes)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if subscription.status == "active" {
                Button(action: {
                    viewModel.pauseSubscription(subscription)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "pause.fill")
                        Text("Pause Subscription")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else if subscription.status == "paused" {
                Button(action: {
                    viewModel.resumeSubscription(subscription)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Resume Subscription")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            if subscription.status != "cancelled" {
                Button(action: {
                    showingCancelAlert = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Cancel Subscription")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var brandColor: Color {
        guard let hex = subscription.brandColorHex, !hex.isEmpty else {
            return Color.blue
        }

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

    private var statusColor: Color {
        switch subscription.status {
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

    private var statusDisplayName: String {
        switch subscription.status {
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

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Views
struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct EditSubscriptionView: View {
    let subscription: Subscription
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var serviceName: String
    @State private var plan: String
    @State private var cost: String
    @State private var billingCycle: String
    @State private var category: String
    @State private var notes: String

    init(subscription: Subscription, viewModel: SubscriptionViewModel) {
        self.subscription = subscription
        self.viewModel = viewModel
        self._serviceName = State(initialValue: subscription.serviceName ?? "")
        self._plan = State(initialValue: subscription.plan ?? "")
        self._cost = State(initialValue: String(subscription.cost))
        self._billingCycle = State(initialValue: subscription.billingCycle ?? "monthly")
        self._category = State(initialValue: subscription.category ?? "other")
        self._notes = State(initialValue: subscription.notes ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Service Details")) {
                    TextField("Service Name", text: $serviceName)
                    TextField("Plan", text: $plan)
                    TextField("Cost", text: $cost)
                }

                Section(header: Text("Settings")) {
                    Picker("Billing Cycle", selection: $billingCycle) {
                        Text("Monthly").tag("monthly")
                        Text("Yearly").tag("yearly")
                        Text("Weekly").tag("weekly")
                    }

                    Picker("Category", selection: $category) {
                        Text("Entertainment").tag("entertainment")
                        Text("Productivity").tag("productivity")
                        Text("Health").tag("health")
                        Text("Education").tag("education")
                        Text("Finance").tag("finance")
                        Text("Shopping").tag("shopping")
                        Text("Other").tag("other")
                    }
                }

                Section(header: Text("Notes")) {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(serviceName.isEmpty || cost.isEmpty || Double(cost) == nil)
                }
            }
        }
    }

    private func saveChanges() {
        guard let costValue = Double(cost) else { return }

        subscription.serviceName = serviceName
        subscription.plan = plan
        subscription.cost = costValue
        subscription.billingCycle = billingCycle
        subscription.category = category
        subscription.notes = notes

        viewModel.updateSubscription(subscription)
    }
}

extension DateFormatter {
    static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
