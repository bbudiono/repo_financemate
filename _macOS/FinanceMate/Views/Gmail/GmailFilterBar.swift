import SwiftUI

/// Filter controls for Gmail receipts table
/// BLUEPRINT Line 67: Filterable requirement
struct GmailFilterBar: View {
    @ObservedObject var viewModel: GmailViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            // Search bar - real-time filtering
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search merchant, category, or amount...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(colorScheme == .dark ? Color(.windowBackgroundColor) : Color(.controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)

            // Filter controls row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Date range filter
                    Menu {
                        Button("All Time") {
                            viewModel.dateFilter = .allTime
                        }
                        Button("Today") {
                            viewModel.dateFilter = .today
                        }
                        Button("This Week") {
                            viewModel.dateFilter = .thisWeek
                        }
                        Button("This Month") {
                            viewModel.dateFilter = .thisMonth
                        }
                        Button("Last 3 Months") {
                            viewModel.dateFilter = .last3Months
                        }
                        Button("This Year") {
                            viewModel.dateFilter = .thisYear
                        }
                    } label: {
                        FilterPill(
                            icon: "calendar",
                            title: "Date",
                            value: viewModel.dateFilter.displayName,
                            isActive: viewModel.dateFilter != .allTime
                        )
                    }

                    // Merchant filter
                    if !availableMerchants.isEmpty {
                        Menu {
                            Button("All Merchants") {
                                viewModel.merchantFilter = nil
                            }
                            Divider()
                            ForEach(availableMerchants, id: \.self) { merchant in
                                Button(merchant) {
                                    viewModel.merchantFilter = merchant
                                }
                            }
                        } label: {
                            FilterPill(
                                icon: "building.2",
                                title: "Merchant",
                                value: viewModel.merchantFilter ?? "All",
                                isActive: viewModel.merchantFilter != nil
                            )
                        }
                    }

                    // Category filter
                    Menu {
                        Button("All Categories") {
                            viewModel.categoryFilter = nil
                        }
                        Divider()
                        ForEach(["Cashback", "Expense", "Income", "Refund"], id: \.self) { category in
                            Button(category) {
                                viewModel.categoryFilter = category
                            }
                        }
                    } label: {
                        FilterPill(
                            icon: "tag",
                            title: "Category",
                            value: viewModel.categoryFilter ?? "All",
                            isActive: viewModel.categoryFilter != nil
                        )
                    }

                    // Amount range filter
                    Menu {
                        Button("Any Amount") {
                            viewModel.amountFilter = .any
                        }
                        Divider()
                        Button("Under $50") {
                            viewModel.amountFilter = .under(50)
                        }
                        Button("$50 - $200") {
                            viewModel.amountFilter = .range(50, 200)
                        }
                        Button("$200 - $1,000") {
                            viewModel.amountFilter = .range(200, 1000)
                        }
                        Button("Over $1,000") {
                            viewModel.amountFilter = .over(1000)
                        }
                    } label: {
                        FilterPill(
                            icon: "dollarsign.circle",
                            title: "Amount",
                            value: viewModel.amountFilter.displayName,
                            isActive: viewModel.amountFilter != .any
                        )
                    }

                    // Confidence filter
                    Menu {
                        Button("Any Confidence") {
                            viewModel.confidenceFilter = .any
                        }
                        Divider()
                        Button("High (≥80%)") {
                            viewModel.confidenceFilter = .high
                        }
                        Button("Medium (≥60%)") {
                            viewModel.confidenceFilter = .medium
                        }
                        Button("Low (<60%)") {
                            viewModel.confidenceFilter = .low
                        }
                    } label: {
                        FilterPill(
                            icon: "checkmark.circle",
                            title: "Confidence",
                            value: viewModel.confidenceFilter.displayName,
                            isActive: viewModel.confidenceFilter != .any
                        )
                    }

                    // Clear all filters button
                    if hasActiveFilters {
                        Button(action: {
                            viewModel.clearAllFilters()
                        }) {
                            Text("Clear All")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 32)
        }
        .padding(.vertical, 8)
        .background(colorScheme == .dark ? Color(.windowBackgroundColor).opacity(0.3) : Color(.controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Computed Properties

    private var availableMerchants: [String] {
        Array(Set(viewModel.extractedTransactions.map(\.merchant))).sorted()
    }

    private var hasActiveFilters: Bool {
        viewModel.dateFilter != .allTime ||
        viewModel.merchantFilter != nil ||
        viewModel.categoryFilter != nil ||
        viewModel.amountFilter != .any ||
        viewModel.confidenceFilter != .any ||
        !viewModel.searchText.isEmpty
    }
}

// MARK: - Filter Pill Component

struct FilterPill: View {
    let icon: String
    let title: String
    let value: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            Text("·")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .foregroundColor(isActive ? .accentColor : .secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}
