import Foundation
import SwiftUI

struct AddSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var serviceName = ""
    @State private var plan = ""
    @State private var cost = ""
    @State private var selectedBillingCycle = "monthly"
    @State private var selectedCategory = "other"
    @State private var notes = ""

    private let billingCycles = [
        ("monthly", "Monthly"),
        ("yearly", "Yearly"),
        ("weekly", "Weekly")
    ]

    private let categories = [
        ("entertainment", "Entertainment"),
        ("productivity", "Productivity"),
        ("health", "Health & Fitness"),
        ("education", "Education"),
        ("finance", "Finance"),
        ("shopping", "Shopping"),
        ("other", "Other")
    ]

    private var isFormValid: Bool {
        !serviceName.isEmpty && !cost.isEmpty && Double(cost) != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Service Details") {
                    TextField("Service Name", text: $serviceName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Plan Type", text: $plan)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.0) { category in
                            HStack {
                                Image(systemName: categoryIcon(for: category.0))
                                Text(category.1)
                            }
                            .tag(category.0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section("Billing Information") {
                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("0.00", text: $cost)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }

                    Picker("Billing Cycle", selection: $selectedBillingCycle) {
                        ForEach(billingCycles, id: \.0) { cycle in
                            Text(cycle.1).tag(cycle.0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section("Notes") {
                    TextField("Notes (optional)", text: $notes)
                        .lineLimit(3...6)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if !serviceName.isEmpty && !cost.isEmpty, let costValue = Double(cost) {
                    Section("Preview") {
                        SubscriptionPreviewCard(
                            serviceName: serviceName,
                            plan: plan.isEmpty ? "Standard" : plan,
                            cost: costValue,
                            billingCycle: selectedBillingCycle,
                            category: selectedCategory
                        )
                    }
                }
            }
            .formStyle(GroupedFormStyle())
            .navigationTitle("Add Subscription")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 500, height: 600)
    }

    private func saveSubscription() {
        guard let costValue = Double(cost) else { return }

        viewModel.addSubscription(
            serviceName: serviceName,
            plan: plan.isEmpty ? "Standard" : plan,
            cost: costValue,
            billingCycle: selectedBillingCycle,
            category: selectedCategory,
            notes: notes
        )

        dismiss()
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "entertainment": return "tv.fill"
        case "productivity": return "laptopcomputer"
        case "health": return "heart.fill"
        case "education": return "graduationcap.fill"
        case "finance": return "dollarsign.circle.fill"
        case "shopping": return "bag.fill"
        case "other": return "circle.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Preview Card Component
struct SubscriptionPreviewCard: View {
    let serviceName: String
    let plan: String
    let cost: Double
    let billingCycle: String
    let category: String

    private var formattedCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let costString = formatter.string(from: NSNumber(value: cost)) ?? "$0.00"
        let cycleShortName = billingCycle == "yearly" ? "yr" : (billingCycle == "weekly" ? "wk" : "mo")
        return "\(costString)/\(cycleShortName)"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Service Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 32, height: 32)

                Image(systemName: categoryIcon(for: category))
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
            }

            // Service Details
            VStack(alignment: .leading, spacing: 2) {
                Text(serviceName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(plan)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Cost
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedCost)
                    .font(.subheadline)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)

                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "entertainment": return "tv.fill"
        case "productivity": return "laptopcomputer"
        case "health": return "heart.fill"
        case "education": return "graduationcap.fill"
        case "finance": return "dollarsign.circle.fill"
        case "shopping": return "bag.fill"
        case "other": return "circle.fill"
        default: return "circle.fill"
        }
    }
}

#Preview {
    AddSubscriptionView(viewModel: SubscriptionViewModel())
}
