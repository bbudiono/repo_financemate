import SwiftUI

// MARK: - Editable Field Components

/// Editable text field for inline table editing
struct EditableTextField: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: (String) -> Void

    @State private var isEditing = false
    @State private var tempText = ""

    var body: some View {
        if isEditing {
            TextField(placeholder, text: $tempText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    text = tempText
                    onCommit(tempText)
                    isEditing = false
                }
                .onAppear {
                    tempText = text
                }
        } else {
            Text(text.isEmpty ? placeholder : text)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .onTapGesture {
                    isEditing = true
                }
        }
    }
}

/// Editable amount field for currency values
struct EditableAmountField: View {
    @Binding var amount: Double
    let onCommit: (Double) -> Void

    @State private var isEditing = false
    @State private var tempText = ""

    var body: some View {
        if isEditing {
            TextField("0.00", text: $tempText)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onSubmit {
                    if let newAmount = Double(tempText) {
                        amount = newAmount
                        onCommit(newAmount)
                    }
                    isEditing = false
                }
                .onAppear {
                    tempText = String(format: "%.2f", amount)
                }
        } else {
            Text(amount, format: .currency(code: "AUD"))
                .foregroundColor(.red)
                .onTapGesture {
                    isEditing = true
                }
        }
    }
}

// MARK: - Field Update Enum

enum TransactionField {
    case merchant
    case category
    case amount
}