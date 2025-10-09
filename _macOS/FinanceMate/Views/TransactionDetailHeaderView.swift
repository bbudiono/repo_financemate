import SwiftUI

/// Header section for transaction detail view
/// Displays merchant, amount, date, category, and confidence information
struct TransactionDetailHeaderView: View {
    let transaction: ExtractedTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(transaction.merchant)
                .font(.title)
                .fontWeight(.bold)

            Text(transaction.amount, format: .currency(code: "AUD"))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.accentColor)

            HStack(spacing: 12) {
                Label(transaction.date.formatted(date: .long, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                Circle().fill(Color.secondary).frame(width: 4, height: 4)
                Label(transaction.category, systemImage: "tag").font(.caption)
                Circle().fill(Color.secondary).frame(width: 4, height: 4)

                HStack(spacing: 4) {
                    Circle()
                        .fill(confidenceColor)
                        .frame(width: 8, height: 8)
                    Text("\(Int(transaction.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundColor(confidenceColor)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    private var confidenceColor: Color {
        if transaction.confidence >= 0.8 { return .green }
        if transaction.confidence >= 0.6 { return .orange }
        return .red
    }
}