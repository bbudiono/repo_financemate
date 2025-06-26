import CoreData
import SwiftUI

struct CreateBudgetView: View {
    @ObservedObject var budgetManager: BudgetManager
    @Environment(\.dismiss) private var dismiss

    @State private var budgetName = ""
    @State private var totalAmount = ""
    @State private var selectedBudgetType: BudgetType = .monthly
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedTemplate: BudgetTemplate = .custom
    @State private var categories: [CategorySetup] = []
    @State private var selectedTab: CreateBudgetTab = .basic
    @State private var notes = ""

    private var isFormValid: Bool {
        !budgetName.isEmpty &&
        !totalAmount.isEmpty &&
        Double(totalAmount) != nil &&
        Double(totalAmount)! > 0 &&
        startDate < endDate &&
        !categories.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Navigation
                createBudgetTabNavigation

                Divider()

                // Tab Content
                ScrollView {
                    switch selectedTab {
                    case .basic:
                        basicInfoTab
                    case .categories:
                        categoriesTab
                    case .template:
                        templateTab
                    case .review:
                        reviewTab
                    }
                }
                .frame(maxHeight: .infinity)

                Divider()

                // Bottom Action Bar
                bottomActionBar
            }
        }
        .frame(width: 700, height: 600)
        .onAppear {
            setupDefaultCategories()
            updateEndDateForBudgetType()
        }
        .onChange(of: selectedBudgetType) { _ in
            updateEndDateForBudgetType()
        }
        .onChange(of: selectedTemplate) { _ in
            applyTemplate()
        }
    }

    // MARK: - Tab Navigation

    private var createBudgetTabNavigation: some View {
        HStack(spacing: 0) {
            ForEach(CreateBudgetTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Basic Info Tab

    private var basicInfoTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Basic Information")
                    .font(.title2)
                    .fontWeight(.bold)

                // Budget Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Name")
                        .font(.headline)
                        .fontWeight(.semibold)

                    TextField("Enter budget name (e.g., 'Monthly Budget', 'Vacation Fund')", text: $budgetName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }

                // Total Amount
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Budget Amount")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack {
                        Text("$")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        TextField("0.00", text: $totalAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .font(.title3)
                    }
                }

                // Budget Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Type")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Picker("Budget Type", selection: $selectedBudgetType) {
                        ForEach(BudgetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Date Range
                VStack(alignment: .leading, spacing: 8) {
                    Text("Budget Period")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("End Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                }

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.headline)
                        .fontWeight(.semibold)

                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Categories Tab

    private var categoriesTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Budget Categories")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Add Category") {
                        addCategory()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Text("Allocate your budget across different spending categories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Categories List
            if categories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No categories added yet")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Button("Add Your First Category") {
                        addCategory()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(categories.indices, id: \.self) { index in
                        CategorySetupCard(
                            category: $categories[index]
                        ) { deleteCategory(at: index) }
                    }
                }
            }

            // Budget Allocation Summary
            if !categories.isEmpty {
                budgetAllocationSummary
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Template Tab

    private var templateTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Budget Templates")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose a pre-configured template to get started quickly")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(BudgetTemplate.allCases, id: \.self) { template in
                    BudgetTemplateCard(
                        template: template,
                        isSelected: selectedTemplate == template
                    ) {
                        selectedTemplate = template
                    }
                }
            }

            if selectedTemplate != .custom {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Template Details")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(selectedTemplate.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Included Categories:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        let templateCategories = BudgetTemplate.categoriesForTemplate(selectedTemplate)
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(templateCategories, id: \.type) { category in
                                HStack(spacing: 6) {
                                    Image(systemName: category.type.icon)
                                        .foregroundColor(category.type.defaultColor)
                                        .font(.caption)

                                    Text(category.name)
                                        .font(.caption)

                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Review Tab

    private var reviewTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Review & Create")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 20) {
                // Budget Summary
                budgetSummarySection

                // Categories Summary
                categoriesSummarySection

                // Date Range Summary
                dateRangeSummarySection

                if !notes.isEmpty {
                    notesSection
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)

            Spacer()

            HStack(spacing: 12) {
                if selectedTab != .basic {
                    Button("Previous") {
                        navigateToPreviousTab()
                    }
                    .buttonStyle(.bordered)
                }

                if selectedTab != .review {
                    Button("Next") {
                        navigateToNextTab()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canNavigateToNextTab())
                } else {
                    Button("Create Budget") {
                        createBudget()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Supporting Views

    private var budgetAllocationSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allocation Summary")
                .font(.headline)
                .fontWeight(.semibold)

            let totalAllocated = categories.reduce(0) { $0 + ($1.amount ?? 0) }
            let budgetAmount = Double(totalAmount) ?? 0
            let remaining = budgetAmount - totalAllocated

            VStack(spacing: 8) {
                HStack {
                    Text("Total Budget:")
                        .font(.subheadline)
                    Spacer()
                    Text(formatCurrency(budgetAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Allocated:")
                        .font(.subheadline)
                    Spacer()
                    Text(formatCurrency(totalAllocated))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(totalAllocated > budgetAmount ? .red : .primary)
                }

                HStack {
                    Text("Remaining:")
                        .font(.subheadline)
                    Spacer()
                    Text(formatCurrency(remaining))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(remaining < 0 ? .red : .green)
                }

                if budgetAmount > 0 {
                    ProgressView(value: min(totalAllocated, budgetAmount), total: budgetAmount)
                        .progressViewStyle(LinearProgressViewStyle(tint: totalAllocated > budgetAmount ? .red : .blue))
                        .frame(height: 8)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
    }

    private var budgetSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Overview")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                SummaryRow(label: "Name", value: budgetName.isEmpty ? "Unnamed Budget" : budgetName)
                SummaryRow(label: "Amount", value: formatCurrency(Double(totalAmount) ?? 0))
                SummaryRow(label: "Type", value: selectedBudgetType.displayName)
                SummaryRow(label: "Duration", value: "\(daysBetween(startDate, endDate)) days")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var categoriesSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories (\(categories.count))")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(categories.indices, id: \.self) { index in
                let category = categories[index]
                HStack {
                    Image(systemName: category.type.icon)
                        .foregroundColor(category.type.defaultColor)

                    Text(category.name)
                        .font(.subheadline)

                    Spacer()

                    Text(formatCurrency(category.amount ?? 0))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var dateRangeSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Period")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                SummaryRow(label: "Start Date", value: formatDate(startDate))
                SummaryRow(label: "End Date", value: formatDate(endDate))
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
                .fontWeight(.semibold)

            Text(notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func setupDefaultCategories() {
        categories = BudgetCategoryData.defaultCategories.map { categoryData in
            CategorySetup(
                name: categoryData.name,
                type: categoryData.type,
                amount: categoryData.budgetedAmount,
                alertThreshold: categoryData.alertThreshold
            )
        }
    }

    private func updateEndDateForBudgetType() {
        let calendar = Calendar.current

        switch selectedBudgetType {
        case .weekly:
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .monthly:
            endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .yearly:
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        case .custom, .project:
            // Keep current end date for custom/project budgets
            break
        }
    }

    private func applyTemplate() {
        guard selectedTemplate != .custom else { return }

        categories = BudgetTemplate.categoriesForTemplate(selectedTemplate).map { categoryData in
            CategorySetup(
                name: categoryData.name,
                type: categoryData.type,
                amount: categoryData.budgetedAmount,
                alertThreshold: categoryData.alertThreshold
            )
        }

        // Set suggested budget amount based on template
        switch selectedTemplate {
        case .student:
            totalAmount = "1500"
        case .young_professional:
            totalAmount = "3500"
        case .family:
            totalAmount = "6000"
        case .retirement:
            totalAmount = "4000"
        case .custom:
            break
        }
    }

    private func addCategory() {
        categories.append(CategorySetup(
            name: "New Category",
            type: .miscellaneous,
            amount: 0,
            alertThreshold: 80
        ))
    }

    private func deleteCategory(at index: Int) {
        categories.remove(at: index)
    }

    private func navigateToNextTab() {
        guard let currentIndex = CreateBudgetTab.allCases.firstIndex(of: selectedTab),
              currentIndex < CreateBudgetTab.allCases.count - 1 else { return }

        selectedTab = CreateBudgetTab.allCases[currentIndex + 1]
    }

    private func navigateToPreviousTab() {
        guard let currentIndex = CreateBudgetTab.allCases.firstIndex(of: selectedTab),
              currentIndex > 0 else { return }

        selectedTab = CreateBudgetTab.allCases[currentIndex - 1]
    }

    private func canNavigateToNextTab() -> Bool {
        switch selectedTab {
        case .basic:
            return !budgetName.isEmpty && !totalAmount.isEmpty && Double(totalAmount) != nil
        case .categories:
            return !categories.isEmpty
        case .template:
            return true
        case .review:
            return false
        }
    }

    private func createBudget() {
        guard let amount = Double(totalAmount) else { return }

        let budgetCategories = categories.map { categorySetup in
            BudgetCategoryData(
                name: categorySetup.name,
                budgetedAmount: categorySetup.amount ?? 0,
                type: categorySetup.type,
                color: categorySetup.type.defaultColor,
                alertThreshold: categorySetup.alertThreshold
            )
        }

        let budget = budgetManager.createBudget(
            name: budgetName,
            amount: amount,
            type: selectedBudgetType,
            startDate: startDate,
            endDate: endDate,
            categories: budgetCategories
        )

        print("✅ Created budget: \(budget.name ?? "Unnamed") with \(budgetCategories.count) categories")
        dismiss()
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

// MARK: - Supporting Types and Views

enum CreateBudgetTab: CaseIterable {
    case basic, categories, template, review

    var title: String {
        switch self {
        case .basic: return "Basic Info"
        case .categories: return "Categories"
        case .template: return "Templates"
        case .review: return "Review"
        }
    }

    var icon: String {
        switch self {
        case .basic: return "info.circle"
        case .categories: return "list.clipboard"
        case .template: return "doc.text.image"
        case .review: return "checkmark.circle"
        }
    }
}

struct CategorySetup {
    var name: String
    var type: BudgetCategoryType
    var amount: Double?
    var alertThreshold: Double
}

struct CategorySetupCard: View {
    @Binding var category: CategorySetup
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Category Type Picker
            Picker("Category Type", selection: $category.type) {
                ForEach(BudgetCategoryType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.displayName)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 150)

            // Category Name
            TextField("Category Name", text: $category.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Amount
            HStack {
                Text("$")
                    .foregroundColor(.secondary)

                TextField("0.00", value: $category.amount, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Budget Templates

enum BudgetTemplate: CaseIterable {
    case student, young_professional, family, retirement, custom

    var title: String {
        switch self {
        case .student: return "Student Budget"
        case .young_professional: return "Young Professional"
        case .family: return "Family Budget"
        case .retirement: return "Retirement Budget"
        case .custom: return "Custom Budget"
        }
    }

    var description: String {
        switch self {
        case .student:
            return "Budget designed for students with focus on education, basic living expenses, and minimal entertainment."
        case .young_professional:
            return "Budget for young professionals starting their career with emphasis on career development and future savings."
        case .family:
            return "Comprehensive family budget including childcare, education, and family activities."
        case .retirement:
            return "Budget optimized for retirees focusing on healthcare, leisure, and conservative spending."
        case .custom:
            return "Start with a blank budget and customize all categories according to your specific needs."
        }
    }

    var icon: String {
        switch self {
        case .student: return "graduationcap.fill"
        case .young_professional: return "briefcase.fill"
        case .family: return "house.fill"
        case .retirement: return "leaf.fill"
        case .custom: return "slider.horizontal.3"
        }
    }

    static func categoriesForTemplate(_ template: BudgetTemplate) -> [BudgetCategoryData] {
        switch template {
        case .student:
            return [
                BudgetCategoryData(name: "Tuition & Books", budgetedAmount: 500.0, type: .education, color: .indigo, alertThreshold: 90.0),
                BudgetCategoryData(name: "Housing", budgetedAmount: 400.0, type: .housing, color: .blue, alertThreshold: 85.0),
                BudgetCategoryData(name: "Food", budgetedAmount: 200.0, type: .food, color: .orange, alertThreshold: 80.0),
                BudgetCategoryData(name: "Transportation", budgetedAmount: 100.0, type: .transportation, color: .green, alertThreshold: 90.0),
                BudgetCategoryData(name: "Entertainment", budgetedAmount: 150.0, type: .entertainment, color: .pink, alertThreshold: 100.0),
                BudgetCategoryData(name: "Emergency Fund", budgetedAmount: 150.0, type: .savings, color: .mint, alertThreshold: 50.0)
            ]

        case .young_professional:
            return [
                BudgetCategoryData(name: "Housing", budgetedAmount: 1200.0, type: .housing, color: .blue, alertThreshold: 80.0),
                BudgetCategoryData(name: "Food & Dining", budgetedAmount: 400.0, type: .food, color: .orange, alertThreshold: 85.0),
                BudgetCategoryData(name: "Transportation", budgetedAmount: 350.0, type: .transportation, color: .green, alertThreshold: 90.0),
                BudgetCategoryData(name: "Career Development", budgetedAmount: 200.0, type: .education, color: .indigo, alertThreshold: 100.0),
                BudgetCategoryData(name: "Entertainment", budgetedAmount: 300.0, type: .entertainment, color: .pink, alertThreshold: 100.0),
                BudgetCategoryData(name: "Savings & Investment", budgetedAmount: 700.0, type: .savings, color: .mint, alertThreshold: 50.0),
                BudgetCategoryData(name: "Healthcare", budgetedAmount: 150.0, type: .healthcare, color: .red, alertThreshold: 80.0),
                BudgetCategoryData(name: "Shopping", budgetedAmount: 200.0, type: .shopping, color: .brown, alertThreshold: 90.0)
            ]

        case .family:
            return [
                BudgetCategoryData(name: "Housing", budgetedAmount: 1800.0, type: .housing, color: .blue, alertThreshold: 80.0),
                BudgetCategoryData(name: "Groceries & Food", budgetedAmount: 600.0, type: .food, color: .orange, alertThreshold: 85.0),
                BudgetCategoryData(name: "Transportation", budgetedAmount: 500.0, type: .transportation, color: .green, alertThreshold: 90.0),
                BudgetCategoryData(name: "Childcare & Education", budgetedAmount: 800.0, type: .education, color: .indigo, alertThreshold: 90.0),
                BudgetCategoryData(name: "Healthcare", budgetedAmount: 300.0, type: .healthcare, color: .red, alertThreshold: 80.0),
                BudgetCategoryData(name: "Insurance", budgetedAmount: 400.0, type: .insurance, color: .purple, alertThreshold: 85.0),
                BudgetCategoryData(name: "Family Activities", budgetedAmount: 300.0, type: .entertainment, color: .pink, alertThreshold: 100.0),
                BudgetCategoryData(name: "Emergency & Savings", budgetedAmount: 800.0, type: .savings, color: .mint, alertThreshold: 50.0),
                BudgetCategoryData(name: "Utilities", budgetedAmount: 200.0, type: .utilities, color: .yellow, alertThreshold: 75.0),
                BudgetCategoryData(name: "Shopping & Supplies", budgetedAmount: 300.0, type: .shopping, color: .brown, alertThreshold: 90.0)
            ]

        case .retirement:
            return [
                BudgetCategoryData(name: "Housing", budgetedAmount: 1000.0, type: .housing, color: .blue, alertThreshold: 80.0),
                BudgetCategoryData(name: "Healthcare", budgetedAmount: 500.0, type: .healthcare, color: .red, alertThreshold: 75.0),
                BudgetCategoryData(name: "Food & Dining", budgetedAmount: 400.0, type: .food, color: .orange, alertThreshold: 85.0),
                BudgetCategoryData(name: "Transportation", budgetedAmount: 200.0, type: .transportation, color: .green, alertThreshold: 90.0),
                BudgetCategoryData(name: "Leisure & Travel", budgetedAmount: 600.0, type: .entertainment, color: .pink, alertThreshold: 100.0),
                BudgetCategoryData(name: "Insurance", budgetedAmount: 300.0, type: .insurance, color: .purple, alertThreshold: 80.0),
                BudgetCategoryData(name: "Utilities", budgetedAmount: 150.0, type: .utilities, color: .yellow, alertThreshold: 75.0),
                BudgetCategoryData(name: "Emergency Fund", budgetedAmount: 350.0, type: .savings, color: .mint, alertThreshold: 50.0),
                BudgetCategoryData(name: "Hobbies & Interests", budgetedAmount: 200.0, type: .miscellaneous, color: .gray, alertThreshold: 100.0),
                BudgetCategoryData(name: "Gifts & Donations", budgetedAmount: 300.0, type: .miscellaneous, color: .gray, alertThreshold: 100.0)
            ]

        case .custom:
            return []
        }
    }
}

struct BudgetTemplateCard: View {
    let template: BudgetTemplate
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .blue : .secondary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }

                Text(template.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CreateBudgetView(budgetManager: BudgetManager(context: CoreDataStack.shared.mainContext))
}
