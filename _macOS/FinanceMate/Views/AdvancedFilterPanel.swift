import SwiftUI

// MARK: - Advanced Filter Panel
// BLUEPRINT Line 136: Advanced filtering with multi-select, date range, and rules

struct AdvancedFilterPanel: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @State private var newRuleField: FilterRule.FilterField = .merchant
    @State private var newRuleOperation: FilterRule.FilterOperation = .contains
    @State private var newRuleValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            Divider()
            categorySection
            Divider()
            dateRangeSection
            Divider()
            amountRangeSection
            Divider()
            quickFiltersSection
            Divider()
            rulesSection
            Spacer()
            footerSection
        }
        .padding()
        .frame(width: 320)
        .background(.ultraThinMaterial)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Advanced Filters")
                .font(.headline)
            Spacer()
            if viewModel.advancedFilter.hasActiveFilters {
                Button("Clear All") {
                    viewModel.clearAdvancedFilters()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
            }
        }
    }

    // MARK: - Category Multi-Select

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.subheadline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(TransactionCategory.allCases, id: \.self) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: viewModel.advancedFilter.selectedCategories.contains(category.rawValue),
                        action: { viewModel.toggleCategory(category.rawValue) }
                    )
                }
            }
        }
    }

    // MARK: - Date Range

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date Range")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                DatePicker("From",
                           selection: Binding(
                               get: { viewModel.advancedFilter.startDate ?? Date().addingTimeInterval(-365*24*60*60) },
                               set: { viewModel.advancedFilter.startDate = $0 }
                           ),
                           displayedComponents: .date)
                .labelsHidden()
                .frame(maxWidth: .infinity)

                Text("to")
                    .foregroundColor(.secondary)

                DatePicker("To",
                           selection: Binding(
                               get: { viewModel.advancedFilter.endDate ?? Date() },
                               set: { viewModel.advancedFilter.endDate = $0 }
                           ),
                           displayedComponents: .date)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 8) {
                QuickDateButton(title: "7D") { setDateRange(days: 7) }
                QuickDateButton(title: "30D") { setDateRange(days: 30) }
                QuickDateButton(title: "90D") { setDateRange(days: 90) }
                QuickDateButton(title: "1Y") { setDateRange(days: 365) }
                QuickDateButton(title: "All") { clearDateRange() }
            }
        }
    }

    // MARK: - Amount Range

    private var amountRangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount Range")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                TextField("Min $", value: $viewModel.advancedFilter.minAmount, format: .currency(code: "AUD"))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)

                Text("to")
                    .foregroundColor(.secondary)

                TextField("Max $", value: $viewModel.advancedFilter.maxAmount, format: .currency(code: "AUD"))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Quick Filters

    private var quickFiltersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Filters")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Toggle("Expenses Only", isOn: $viewModel.advancedFilter.showOnlyExpenses)
                    .toggleStyle(.checkbox)
                Toggle("Income Only", isOn: $viewModel.advancedFilter.showOnlyIncome)
                    .toggleStyle(.checkbox)
            }
        }
    }

    // MARK: - Rules Section

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Rules")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Existing rules
            ForEach(viewModel.advancedFilter.rules) { rule in
                HStack {
                    Text("\(rule.field.rawValue) \(rule.operation.displayName) '\(rule.value)'")
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Button(action: { viewModel.removeFilterRule(rule) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(6)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            }

            // Add new rule
            HStack(spacing: 4) {
                Picker("Field", selection: $newRuleField) {
                    ForEach(FilterRule.FilterField.allCases, id: \.self) { field in
                        Text(field.rawValue).tag(field)
                    }
                }
                .labelsHidden()
                .frame(width: 80)

                Picker("Op", selection: $newRuleOperation) {
                    ForEach(FilterRule.FilterOperation.operations(for: newRuleField), id: \.self) { op in
                        Text(op.displayName).tag(op)
                    }
                }
                .labelsHidden()
                .frame(width: 80)

                TextField("Value", text: $newRuleValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)

                Button(action: addRule) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                .disabled(newRuleValue.isEmpty)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            let count = viewModel.filteredTransactions.count
            Text("\(count) transaction\(count == 1 ? "" : "s") matching")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Helper Methods

    private func setDateRange(days: Int) {
        viewModel.advancedFilter.endDate = Date()
        viewModel.advancedFilter.startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())
    }

    private func clearDateRange() {
        viewModel.advancedFilter.startDate = nil
        viewModel.advancedFilter.endDate = nil
    }

    private func addRule() {
        let rule = FilterRule(field: newRuleField, operation: newRuleOperation, value: newRuleValue)
        viewModel.addFilterRule(rule)
        newRuleValue = ""
    }
}

// MARK: - Supporting Components

struct CategoryFilterChip: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption2)
                Text(category.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(isSelected ? .accentColor : .primary)
    }
}

struct QuickDateButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}
