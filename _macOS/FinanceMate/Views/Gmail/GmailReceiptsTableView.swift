import SwiftUI

/// BLUEPRINT Lines 67-69: Gmail Receipts Review Table with Expandable Details
/// Master-detail pattern: Main table wrapper delegating to row components
struct GmailReceiptsTableView: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var expandedID: String?

    var body: some View {
        VStack(spacing: 12) {
            // Header with batch actions
            HStack {
                Text("\(viewModel.extractedTransactions.count) emails to review")
                    .font(.headline)
                Spacer()
                if !viewModel.selectedIDs.isEmpty {
                    Text("\(viewModel.selectedIDs.count) selected")
                        .foregroundColor(.secondary)
                    Button("Import Selected") {
                        importSelected()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal)

            // Spreadsheet-like list with expandable rows
            List {
                ForEach(viewModel.extractedTransactions) { transaction in
                    GmailTableRow(
                        transaction: transaction,
                        viewModel: viewModel,
                        expandedID: $expandedID
                    )
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Helper Methods

    private func importSelected() {
        for id in viewModel.selectedIDs {
            if let transaction = viewModel.extractedTransactions.first(where: { $0.id == id }) {
                viewModel.createTransaction(from: transaction)
            }
        }
        viewModel.selectedIDs.removeAll()
    }
}
