import SwiftUI

// MARK: - Supporting Components

/// Simple row component for displaying label-value pairs
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

/// Basic line item row without tax split functionality
struct LineItemRow: View {
    let item: GmailLineItem

    var body: some View {
        HStack(alignment: .top) {
            Text("\(item.quantity)×")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(item.price, format: .currency(code: "AUD"))
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

/// Line item row with tax split button functionality
struct LineItemRowWithSplit: View {
    let item: GmailLineItem
    let onTaxSplit: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Text("\(item.quantity)×")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.price, format: .currency(code: "AUD"))
                    .font(.body)
                    .fontWeight(.semibold)

                Button("Tax Split") {
                    onTaxSplit()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
    }
}

// MARK: - Split Allocation Sheet Wrapper

/// Sheet wrapper for tax split functionality
/// Converts GmailLineItem to LineItem for SplitAllocationView
struct SplitAllocationSheet: View {
    let lineItem: GmailLineItem
    let merchant: String
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext

    // Convert GmailLineItem to LineItem for the SplitAllocationView
    private var convertedLineItem: LineItem {
        let convertedItem = LineItem(context: viewContext)
        convertedItem.itemDescription = lineItem.description
        convertedItem.amount = lineItem.price
        convertedItem.quantity = Int16(lineItem.quantity)
        return convertedItem
    }

    var body: some View {
        let viewModel = SplitAllocationViewModel(context: viewContext)

        SplitAllocationView(
            viewModel: viewModel,
            lineItem: convertedLineItem,
            isPresented: $isPresented
        )
    }
}