import SwiftUI

/// Empty state display when no transactions match filters or search
struct TransactionEmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(searchText.isEmpty ? "No transactions yet" : "No matching transactions")
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: .infinity)
    }
}