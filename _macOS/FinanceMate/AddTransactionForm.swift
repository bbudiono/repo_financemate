import SwiftUI

/// Modal form for adding new transactions
struct AddTransactionForm: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Transaction")
                .font(.title2)
                .fontWeight(.bold)

            Text("Transaction form coming soon")
                .foregroundColor(.secondary)

            Button("Cancel") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}