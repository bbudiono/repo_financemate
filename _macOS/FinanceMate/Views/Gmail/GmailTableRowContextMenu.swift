import SwiftUI

/// GmailTableRow Context Menu Component - Enhanced Right-Click Functionality
/// Extracted from GmailTableRow for KISS compliance (<200 lines per file)
/// Provides contextual menu items based on transaction status and selection
struct GmailTableRowContextMenu: View {
    let transaction: ExtractedTransaction
    @ObservedObject var viewModel: GmailViewModel
    let onDelete: () -> Void
    let onImport: () -> Void
    let onImportSelected: () -> Void
    let onDeleteSelected: () -> Void

    var body: some View {
        Group {
            individualTransactionMenuItems
            deleteMenuItem

            if !viewModel.selectedIDs.isEmpty {
                Divider()
                batchOperationMenuItems
            }
        }
    }

    // MARK: - Context Menu Components

    private var individualTransactionMenuItems: some View {
        Group {
            if transaction.status == .needsReview {
                importTransactionMenuItem
                markAsReviewedMenuItem
                archiveMenuItem
            }

            if transaction.status == .transactionCreated {
                archiveMenuItem
            }

            if transaction.status == .archived {
                unarchiveMenuItem
            }
        }
    }

    private var importTransactionMenuItem: some View {
        Button("Import Transaction") {
            onImport()
        }
        .accessibilityLabel("Import transaction from \(transaction.merchant) for \(transaction.amount, format: .currency(code: "AUD"))")
    }

    private var markAsReviewedMenuItem: some View {
        Button("Mark as Reviewed") {
            markAsReviewed()
        }
        .accessibilityLabel("Mark transaction from \(transaction.merchant) as reviewed")
    }

    private var archiveMenuItem: some View {
        Button("Archive") {
            archiveTransaction()
        }
        .accessibilityLabel("Archive transaction from \(transaction.merchant)")
    }

    private var unarchiveMenuItem: some View {
        Button("Unarchive") {
            unarchiveTransaction()
        }
        .accessibilityLabel("Unarchive transaction from \(transaction.merchant)")
    }

    private var deleteMenuItem: some View {
        Button("Delete") {
            onDelete()
        }
        .accessibilityLabel("Delete transaction from \(transaction.merchant) for \(transaction.amount, format: .currency(code: "AUD"))")
    }

    private var batchOperationMenuItems: some View {
        Group {
            Button("Import Selected (\(viewModel.selectedIDs.count))") {
                onImportSelected()
            }
            .accessibilityLabel("Import \(viewModel.selectedIDs.count) selected transactions")

            if hasArchivableSelected() {
                Button("Archive Selected (\(viewModel.selectedIDs.count))") {
                    archiveSelected()
                }
                .accessibilityLabel("Archive \(viewModel.selectedIDs.count) selected transactions")
            }

            Button("Delete Selected (\(viewModel.selectedIDs.count))") {
                onDeleteSelected()
            }
            .accessibilityLabel("Delete \(viewModel.selectedIDs.count) selected transactions")
        }
    }

    // MARK: - Helper Methods

    private func markAsReviewed() {
        transaction.status = .transactionCreated
    }

    private func archiveTransaction() {
        transaction.status = .archived
    }

    private func unarchiveTransaction() {
        transaction.status = .needsReview
    }

    private func archiveSelected() {
        viewModel.extractedTransactions.forEach { transaction in
            if viewModel.selectedIDs.contains(transaction.id) {
                transaction.status = .archived
            }
        }
        viewModel.selectedIDs.removeAll()
    }

    private func hasArchivableSelected() -> Bool {
        return viewModel.extractedTransactions.contains { transaction in
            viewModel.selectedIDs.contains(transaction.id) &&
            (transaction.status == .needsReview || transaction.status == .transactionCreated)
        }
    }
}