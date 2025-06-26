import SwiftUI

// MARK: - Budget Overview Cards

struct BudgetOverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Budget Progress Card

struct BudgetProgressCard: View {
    let budget: Budget
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.name ?? "Unnamed Budget")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(budget.budgetTypeEnum.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(budget.daysRemaining) days left")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Circle()
                            .fill(budget.isActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                }

                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        Text("\(Int(budget.spendingPercentage))%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(budget.progressColor)
                    }

                    ProgressView(value: budget.spendingPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: budget.progressColor))
                        .frame(height: 8)
                }

                // Financial Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(budget.totalSpent))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 4) {
                        Text("Budget")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(budget.totalBudgeted))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(budget.remainingAmount))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(budget.remainingAmount >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Empty Budget State

struct EmptyBudgetState: View {
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Active Budget")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Create your first budget to start tracking your spending")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Create Budget") {
                onCreate()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Budget Activity Row

struct BudgetActivityRow: View {
    let budget: Budget
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Budget Type Icon
                Image(systemName: budget.budgetTypeEnum.icon)
                    .font(.title2)
                    .foregroundColor(budget.progressColor)
                    .frame(width: 32, height: 32)

                // Budget Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name ?? "Unnamed Budget")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("Updated \(budget.dateUpdated ?? Date(), style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Quick Stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(budget.totalSpent))
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("of \(formatCurrency(budget.totalBudgeted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Budget List Card

struct BudgetListCard: View {
    let budget: Budget
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header Row
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: budget.budgetTypeEnum.icon)
                            .foregroundColor(budget.progressColor)

                        Text(budget.name ?? "Unnamed Budget")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Circle()
                            .fill(budget.isActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)

                        Text(budget.isActive ? "Active" : "Inactive")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Progress Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Spent: \(formatCurrency(budget.totalSpent))")
                            .font(.subheadline)

                        Spacer()

                        Text("Budget: \(formatCurrency(budget.totalBudgeted))")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)

                    ProgressView(value: budget.spendingPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: budget.progressColor))
                        .frame(height: 6)

                    HStack {
                        Text("\(Int(budget.spendingPercentage))% used")
                            .font(.caption)
                            .foregroundColor(budget.progressColor)

                        Spacer()

                        if budget.isActive {
                            Text("\(budget.daysRemaining) days remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Categories Preview
                if let categories = budget.categories?.allObjects as? [BudgetCategory], !categories.isEmpty {
                    HStack {
                        Text("Categories:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 4) {
                            ForEach(categories.prefix(3).sorted { $0.name ?? "" < $1.name ?? "" }, id: \.objectID) { category in
                                Text(category.name ?? "")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(category.statusColor.opacity(0.2))
                                    .foregroundColor(category.statusColor)
                                    .cornerRadius(4)
                            }

                            if categories.count > 3 {
                                Text("+\(categories.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(budget.isOverBudget ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: BudgetCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon ?? "circle.fill")
                    .foregroundColor(category.statusColor)
                    .font(.title3)

                Spacer()

                if category.isOverBudget {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Text(category.name ?? "Unnamed Category")
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Spent")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Budget")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text(formatCurrency(category.spentAmount?.doubleValue ?? 0))
                        .font(.caption)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(formatCurrency(category.budgetedAmount?.doubleValue ?? 0))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            ProgressView(value: category.spentPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: category.statusColor))
                .frame(height: 4)

            Text("\(Int(category.spentPercentage))% used")
                .font(.caption2)
                .foregroundColor(category.statusColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(category.isOverBudget ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Category Spending Chart

struct CategorySpendingChart: View {
    let categories: [BudgetCategory]

    private var chartData: [CategoryChartData] {
        categories.compactMap { category in
            guard let name = category.name,
                  let spent = category.spentAmount?.doubleValue,
                  spent > 0 else { return nil }

            return CategoryChartData(
                name: name,
                amount: spent,
                color: category.statusColor
            )
        }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if chartData.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No spending data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Simple bar chart representation
                VStack(spacing: 12) {
                    ForEach(chartData.prefix(5), id: \.name) { data in
                        let maxAmount = chartData.first?.amount ?? 1
                        let percentage = data.amount / maxAmount

                        VStack(spacing: 6) {
                            HStack {
                                Text(data.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Spacer()

                                Text(formatCurrency(data.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }

                            GeometryReader { geometry in
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(data.color)
                                        .frame(width: geometry.size.width * percentage)

                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: geometry.size.width * (1 - percentage))
                                }
                            }
                            .frame(height: 8)
                            .cornerRadius(4)
                        }
                    }
                }

                // Legend for remaining categories
                if chartData.count > 5 {
                    Text("+ \(chartData.count - 5) more categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct CategoryChartData {
    let name: String
    let amount: Double
    let color: Color
}

// MARK: - Pattern Card

struct PatternCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Performance Metric Row

struct PerformanceMetricRow: View {
    let title: String
    let value: String
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 6)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Core Data Stack Extension

extension CoreDataStack {
    static let shared = CoreDataStack()

    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

// MARK: - Placeholder Core Data Stack

class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FinanceMate")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()

    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func save() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
}
