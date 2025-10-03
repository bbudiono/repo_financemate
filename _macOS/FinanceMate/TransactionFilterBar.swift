import SwiftUI

/// Filter bar component for transaction filtering
struct TransactionFilterBar: View {
    @Binding var selectedSource: String?
    @Binding var selectedCategory: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(title: "All", isSelected: selectedSource == nil && selectedCategory == nil) {
                    selectedSource = nil
                    selectedCategory = nil
                }
                FilterButton(title: "Gmail", isSelected: selectedSource == "gmail") {
                    selectedSource = selectedSource == "gmail" ? nil : "gmail"
                }
                FilterButton(title: "Manual", isSelected: selectedSource == "manual") {
                    selectedSource = selectedSource == "manual" ? nil : "manual"
                }
                ForEach(["Groceries", "Dining", "Transport", "Utilities"], id: \.self) { cat in
                    FilterButton(title: cat, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

/// Individual filter button component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}