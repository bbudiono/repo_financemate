import SwiftUI

/// Archive status filter menu for Gmail receipts
/// BLUEPRINT Line 104: Archive filter functionality
struct ArchiveFilterMenu: View {
    @ObservedObject var viewModel: GmailViewModel
    @State private var isExpanded = false

    var body: some View {
        Menu {
            Button(action: {
                // Show only needsReview (default behavior)
                viewModel.showArchivedEmails = false
            }) {
                Label("Needs Review", systemImage: "envelope")
            }

            Button(action: {
                // Show only transactionCreated
                // This would require additional filtering logic in ViewModel
                viewModel.showArchivedEmails = true
            }) {
                Label("Transaction Created", systemImage: "checkmark.circle")
            }

            Button(action: {
                // Show only archived
                // This would require additional filtering logic in ViewModel
                viewModel.showArchivedEmails = true
            }) {
                Label("Archived", systemImage: "archivebox")
            }

            Button(action: {
                // Show all statuses
                viewModel.showArchivedEmails = true
            }) {
                Label("All Statuses", systemImage: "tray.full")
            }

        } label: {
            FilterPill(
                title: "Archive Status",
                icon: "archivebox",
                value: viewModel.showArchivedEmails ? "All" : "Active",
                isActive: viewModel.showArchivedEmails
            )
        }
        .accessibilityLabel("Archive status filter")
        .accessibilityHint("Filter emails by archive status")
    }
}

#Preview {
    @StateObject var viewModel = GmailViewModel(context: PersistenceController.preview.container.viewContext)

    return ArchiveFilterMenu(viewModel: viewModel)
        .padding()
}