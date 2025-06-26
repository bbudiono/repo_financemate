import SwiftUI

struct AddAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var accountName = ""
    @State private var institutionName = ""
    @State private var accountType = AccountType.checking
    @State private var balance = ""
    @State private var accountNumber = ""
    @State private var routingNumber = ""
    @State private var creditLimit = ""
    @State private var selectedConnectionMethod = ConnectionMethod.manual

    let onAdd: (FinancialAccount) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Connection method selector
                connectionMethodSelector

                Divider()

                // Form content
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedConnectionMethod == .manual {
                            manualEntryForm
                        } else {
                            institutionConnectionView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Account") {
                        addAccount()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .frame(width: 500, height: 600)
    }

    private var connectionMethodSelector: some View {
        HStack(spacing: 0) {
            ConnectionMethodButton(
                title: "Connect Bank",
                subtitle: "Secure & automatic",
                icon: "link",
                isSelected: selectedConnectionMethod == .bankConnection
            ) {
                selectedConnectionMethod = .bankConnection
            }

            ConnectionMethodButton(
                title: "Manual Entry",
                subtitle: "Enter details manually",
                icon: "keyboard",
                isSelected: selectedConnectionMethod == .manual
            ) {
                selectedConnectionMethod = .manual
            }
        }
        .padding()
    }

    private var manualEntryForm: some View {
        VStack(spacing: 16) {
            // Account Type Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Account Type")
                    .font(.headline)
                    .fontWeight(.medium)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(AccountType.allCases, id: \.self) { type in
                        AccountTypeCard(
                            accountType: type,
                            isSelected: accountType == type
                        ) {
                            accountType = type
                        }
                    }
                }
            }

            // Account Details
            VStack(alignment: .leading, spacing: 16) {
                Text("Account Details")
                    .font(.headline)
                    .fontWeight(.medium)

                VStack(spacing: 12) {
                    HStack {
                        TextField("Account Name", text: $accountName)
                        TextField("Institution Name", text: $institutionName)
                    }

                    HStack {
                        TextField("Current Balance", text: $balance)
                            .keyboardType(.decimalPad)

                        if accountType == .creditCard {
                            TextField("Credit Limit", text: $creditLimit)
                                .keyboardType(.decimalPad)
                        }
                    }

                    HStack {
                        TextField("Account Number", text: $accountNumber)

                        if accountType == .checking || accountType == .savings {
                            TextField("Routing Number", text: $routingNumber)
                        }
                    }
                }
            }
        }
    }

    private var institutionConnectionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Connect Your Bank")
                .font(.title2)
                .fontWeight(.bold)

            Text("Securely connect your bank account for automatic transaction syncing and real-time balance updates.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Popular institutions
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Institutions")
                    .font(.headline)
                    .fontWeight(.medium)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(popularInstitutions, id: \.name) { institution in
                        InstitutionCard(institution: institution) {
                            // Handle institution selection
                            institutionName = institution.name
                        }
                    }
                }
            }

            Button("Search All Institutions") {
                // Handle search all institutions
            }
            .buttonStyle(.borderedProminent)

            // Security notice
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)

                Text("Bank-level encryption keeps your data secure")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var isFormValid: Bool {
        if selectedConnectionMethod == .manual {
            return !accountName.isEmpty &&
                   !institutionName.isEmpty &&
                   !balance.isEmpty &&
                   Double(balance) != nil
        } else {
            return !institutionName.isEmpty
        }
    }

    private func addAccount() {
        guard let balanceValue = Double(balance) else { return }

        let account = FinancialAccount(
            name: accountName,
            institutionName: institutionName,
            type: accountType,
            balance: balanceValue,
            accountNumber: accountNumber.isEmpty ? "****0000" : "****\(String(accountNumber.suffix(4)))",
            routingNumber: routingNumber.isEmpty ? nil : routingNumber,
            creditLimit: accountType == .creditCard ? Double(creditLimit) : nil,
            isActive: true,
            lastUpdated: Date()
        )

        onAdd(account)
        dismiss()
    }

    private var popularInstitutions: [Institution] {
        [
            Institution(name: "Chase Bank", logo: "building.columns.fill"),
            Institution(name: "Bank of America", logo: "building.columns.fill"),
            Institution(name: "Wells Fargo", logo: "building.columns.fill"),
            Institution(name: "Citibank", logo: "building.columns.fill"),
            Institution(name: "Capital One", logo: "building.columns.fill"),
            Institution(name: "American Express", logo: "creditcard.fill")
        ]
    }
}

struct ConnectionMethodButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                VStack(spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct AccountTypeCard: View {
    let accountType: AccountType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: accountType.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : accountType.color)

                Text(accountType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? accountType.color : Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? accountType.color : Color.clear, lineWidth: 2)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct InstitutionCard: View {
    let institution: Institution
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: institution.logo)
                    .foregroundColor(.blue)
                    .frame(width: 24)

                Text(institution.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct Institution {
    let name: String
    let logo: String
}

enum ConnectionMethod {
    case bankConnection
    case manual
}

#Preview {
    AddAccountSheet { account in
        print("Added account: \(account.name)")
    }
}
