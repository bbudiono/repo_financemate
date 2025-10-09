import SwiftUI

/// Gmail Inline Editable Row Component
/// Provides inline editing capabilities for Gmail receipt fields with validation
struct GmailEditableRow: View {
    @ObservedObject var transaction: ExtractedTransaction
    @State private var isEditing = false
    @State private var editingMerchant = ""
    @State private var editingAmount = ""
    @State private var editingCategory = ""
    @State private var showingError = false
    @State private var errorMessage = ""

    let onSave: () -> Void
    let onError: (String) -> Void = { _ in }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 4) {
            if isEditing {
                editingView
            } else {
                normalView
            }
        }
        .padding(.vertical, 8)
        .alert("Validation Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Editing View
    private var editingView: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Edit Receipt Details")
                    .font(.caption)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Merchant")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("Merchant name", text: $editingMerchant)
                            .font(.caption)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 140)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Amount")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $editingAmount)
                            .font(.caption)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Category")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        TextField("Category", text: $editingCategory)
                            .font(.caption)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }

                HStack(spacing: 8) {
                    Button("Save") {
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(!isValidInput())

                    Button("Cancel") {
                        cancelEditing()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Normal View
    private var normalView: some View {
        HStack(spacing: 8) {
            // Email sender info
            VStack(alignment: .leading, spacing: 2) {
                Text(extractDomain(from: transaction.emailSender))
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(transaction.emailSender)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 160, alignment: .leading)
            .onTapGesture {
                startEditing()
            }
            .accessibilityLabel("From: \(transaction.emailSender)")
            .accessibilityHint("Tap to edit receipt details")

            // Transaction details
            Text(transaction.merchant)
                .font(.caption)
                .frame(width: 120, alignment: .leading)

            Text(transaction.amount, format: .currency(code: "AUD"))
                .font(.caption.monospaced())
                .fontWeight(.bold)
                .frame(width: 90, alignment: .trailing)

            Text(transaction.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            Text("\(transaction.items.count)")
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .center)

            // Confidence indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(confidenceColor(transaction.confidence))
                    .frame(width: 6, height: 6)
                Text("\(Int(transaction.confidence * 100))%")
                    .font(.caption2)
            }
            .frame(width: 50, alignment: .center)

            // Actions
            HStack(spacing: 6) {
                Button("Edit") {
                    startEditing()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Import") {
                    // Import functionality to be implemented
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .frame(width: 120)
        }
    }

    // MARK: - Helper Methods
    private func startEditing() {
        isEditing = true
        editingMerchant = transaction.merchant
        editingAmount = String(format: "%.2f", transaction.amount)
        editingCategory = transaction.category
    }

    private func saveChanges() {
        guard validateInput() else { return }

        // Update transaction with validated values
        transaction.merchant = editingMerchant.trimmingCharacters(in: .whitespaces)
        transaction.amount = Double(editingAmount) ?? 0.0
        transaction.category = editingCategory.trimmingCharacters(in: .whitespaces)

        isEditing = false
        onSave()
    }

    private func cancelEditing() {
        isEditing = false
        editingMerchant = transaction.merchant
        editingAmount = String(format: "%.2f", transaction.amount)
        editingCategory = transaction.category
    }

    private func validateInput() -> Bool {
        // Validate merchant
        if editingMerchant.trimmingCharacters(in: .whitespaces).isEmpty {
            showError("Merchant name cannot be empty")
            return false
        }

        // Validate amount
        guard let amount = Double(editingAmount), amount > 0 else {
            showError("Please enter a valid amount greater than 0")
            return false
        }

        // Validate category
        if editingCategory.trimmingCharacters(in: .whitespaces).isEmpty {
            showError("Category cannot be empty")
            return false
        }

        return true
    }

    private func isValidInput() -> Bool {
        return !editingMerchant.trimmingCharacters(in: .whitespaces).isEmpty &&
               Double(editingAmount) != nil &&
               Double(editingAmount)! > 0 &&
               !editingCategory.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
        onError(message)
    }

    // MARK: - Utility Methods
    private func extractDomain(from email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : email
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.8 { return .green }
        if confidence >= 0.6 { return .orange }
        return .red
    }
}