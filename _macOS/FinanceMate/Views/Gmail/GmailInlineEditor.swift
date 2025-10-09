import SwiftUI

/// Gmail Inline Editor Component
/// Handles inline editing capabilities for Gmail receipt fields
struct GmailInlineEditor: View {
    @Binding var isEditing: Bool
    @Binding var editingMerchant: String
    @Binding var editingAmount: String
    @Binding var editingCategory: String

    let transaction: ExtractedTransaction
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack {
            Button("Cancel") {
                cancelEditing()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button("Save") {
                saveEditing()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }

    private func saveEditing() {
        // Validate inputs
        guard !editingMerchant.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        guard let amount = Double(editingAmount), amount > 0 else {
            return
        }

        guard !editingCategory.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        // Update transaction
        transaction.merchant = editingMerchant
        transaction.amount = amount
        transaction.category = editingCategory

        onSave()
        isEditing = false
    }

    private func cancelEditing() {
        // Reset editing values
        editingMerchant = transaction.merchant
        editingAmount = String(format: "%.2f", transaction.amount)
        editingCategory = transaction.category

        onCancel()
        isEditing = false
    }
}