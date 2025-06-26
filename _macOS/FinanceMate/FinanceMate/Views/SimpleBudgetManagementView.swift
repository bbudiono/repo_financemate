import CoreData
import SwiftUI

struct SimpleBudgetManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var showingCreateBudget = false

    private let tabs = ["Overview", "Categories", "Reports", "Settings"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Budget Tabs", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    BudgetOverviewView()
                case 1:
                    BudgetCategoriesView()
                case 2:
                    BudgetReportsView()
                case 3:
                    BudgetSettingsView()
                default:
                    BudgetOverviewView()
                }
            }
        }
        .navigationTitle("Budget Management")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Budget") {
                    showingCreateBudget = true
                }
            }
        }
        .sheet(isPresented: $showingCreateBudget) {
            CreateBudgetSheet()
        }
    }
}

// MARK: - Tab Views

struct BudgetOverviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Monthly Budget Overview")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        BudgetSummaryCard(title: "Total Budget", amount: "$5,000", color: .blue)
                        BudgetSummaryCard(title: "Spent", amount: "$3,250", color: .orange)
                        BudgetSummaryCard(title: "Remaining", amount: "$1,750", color: .green)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Categories")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        BudgetCategoryRow(name: "Housing", budgeted: 2000, spent: 1800, color: .blue)
                        BudgetCategoryRow(name: "Food", budgeted: 800, spent: 650, color: .green)
                        BudgetCategoryRow(name: "Transportation", budgeted: 500, spent: 400, color: .orange)
                        BudgetCategoryRow(name: "Entertainment", budgeted: 300, spent: 400, color: .red)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

struct BudgetCategoriesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Budget Categories")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                LazyVStack(spacing: 1) {
                    ForEach(sampleCategories, id: \.name) { category in
                        BudgetCategoryDetailRow(category: category)
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private var sampleCategories: [BudgetCategoryData] {
        [
            BudgetCategoryData(name: "Housing", budgeted: 2000, spent: 1800, color: .blue),
            BudgetCategoryData(name: "Food", budgeted: 800, spent: 650, color: .green),
            BudgetCategoryData(name: "Transportation", budgeted: 500, spent: 400, color: .orange),
            BudgetCategoryData(name: "Entertainment", budgeted: 300, spent: 400, color: .red),
            BudgetCategoryData(name: "Utilities", budgeted: 200, spent: 180, color: .purple),
            BudgetCategoryData(name: "Healthcare", budgeted: 150, spent: 125, color: .pink)
        ]
    }
}

struct BudgetReportsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Budget Reports")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    ReportCard(
                        title: "Monthly Variance Report",
                        description: "Track spending variance by category",
                        icon: "chart.bar.fill"
                    )

                    ReportCard(
                        title: "Spending Trends",
                        description: "Analyze spending patterns over time",
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    ReportCard(
                        title: "Budget Performance",
                        description: "Overall budget performance metrics",
                        icon: "target"
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct BudgetSettingsView: View {
    @State private var monthlyIncome: String = "5000"
    @State private var savingsGoal: String = "1000"
    @State private var currencyCode: String = "USD"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Budget Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monthly Income")
                            .font(.headline)
                        TextField("Enter monthly income", text: $monthlyIncome)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Savings Goal")
                            .font(.headline)
                        TextField("Enter savings goal", text: $savingsGoal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.headline)
                        TextField("Currency code", text: $currencyCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views

struct BudgetSummaryCard: View {
    let title: String
    let amount: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(amount)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct BudgetCategoryRow: View {
    let name: String
    let budgeted: Double
    let spent: Double
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Int(spent)) / $\(Int(budgeted))")
                    .font(.caption)
                    .foregroundColor(.primary)

                ProgressView(value: spent, total: budgeted)
                    .frame(width: 60)
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}

struct BudgetCategoryDetailRow: View {
    let category: BudgetCategoryData

    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                Text("Budgeted: $\(Int(category.budgeted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(Int(category.spent))")
                    .font(.headline)
                    .foregroundColor(category.spent > category.budgeted ? .red : .primary)

                Text(category.spent > category.budgeted ? "Over budget" : "Under budget")
                    .font(.caption)
                    .foregroundColor(category.spent > category.budgeted ? .red : .green)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct ReportCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CreateBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var budgetName: String = ""
    @State private var budgetAmount: String = ""
    @State private var budgetType: String = "monthly"
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Budget")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Budget Name")
                    .font(.headline)
                TextField("Enter budget name", text: $budgetName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Budget Amount")
                    .font(.headline)
                TextField("Enter budget amount", text: $budgetAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("Create Budget") {
                    createBudget()
                }
                .buttonStyle(.borderedProminent)
                .disabled(budgetName.isEmpty || budgetAmount.isEmpty)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 300)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Budget '\(budgetName)' created successfully with amount $\(budgetAmount)")
        }
    }

    private func createBudget() {
        guard let amount = Double(budgetAmount) else {
            errorMessage = "Please enter a valid budget amount"
            showingError = true
            return
        }

        guard amount > 0 else {
            errorMessage = "Budget amount must be greater than zero"
            showingError = true
            return
        }

        // Create budget using UserDefaults for now (until Budget Core Data entity is added to production target)
        let budgetData: [String: Any] = [
            "id": UUID().uuidString,
            "name": budgetName,
            "totalAmount": amount,
            "budgetType": budgetType,
            "startDate": Date(),
            "endDate": Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            "isActive": true,
            "dateCreated": Date(),
            "currency": "USD"
        ]

        saveBudgetToUserDefaults(budgetData)
        showingSuccess = true
    }

    private func saveBudgetToUserDefaults(_ budgetData: [String: Any]) {
        var existingBudgets = UserDefaults.standard.array(forKey: "SavedBudgets") as? [[String: Any]] ?? []
        existingBudgets.append(budgetData)
        UserDefaults.standard.set(existingBudgets, forKey: "SavedBudgets")
    }
}

// MARK: - Data Models

struct BudgetCategoryData {
    let name: String
    let budgeted: Double
    let spent: Double
    let color: Color
}

#Preview {
    SimpleBudgetManagementView()
        .frame(width: 800, height: 600)
}
