import SwiftUI

struct SmartExpenseCategorizer: View {
    @StateObject private var aiEngine = AICategorizationEngine()
    @State private var selectedTransaction: Transaction?
    @State private var suggestedCategories: [CategoryPrediction] = []
    @State private var isProcessing = false
    @State private var recentTransactions: [Transaction] = []
    @State private var processingProgress: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView

            if isProcessing {
                processingView
            } else {
                aiStatusView
                categoriesGridView
                recentTransactionsView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            loadRecentTransactions()

            // Initialize AI model training if needed
            Task {
                await aiEngine.trainInitialModel()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text("Smart Categorization")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("AI-powered expense classification")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: processAllTransactions) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Auto-Categorize")
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var processingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Analyzing transactions...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var aiStatusView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("AI Engine Status")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                HStack(spacing: 8) {
                    Circle()
                        .fill(aiEngine.isTraining ? .orange : .green)
                        .frame(width: 8, height: 8)

                    Text(aiEngine.isTraining ? "Training" : "Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if aiEngine.confidence > 0 {
                HStack {
                    Text("Model Confidence:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(aiEngine.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(aiEngine.confidence > 0.7 ? .green : .orange)

                    Spacer()
                }
            }
        }
    }

    private var categoriesGridView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Categories")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(suggestedCategories.enumerated()), id: \.offset) { _, prediction in
                    CategoryPredictionCard(
                        prediction: prediction,
                        isSelected: false // Will implement proper selection logic
                    ) {
                        applyCategory(prediction)
                    }
                }
            }
        }
    }

    private var recentTransactionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Uncategorized")
                .font(.subheadline)
                .fontWeight(.medium)

            if recentTransactions.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "All Caught Up!",
                    subtitle: "No transactions need categorization"
                )
            } else {
                ForEach(recentTransactions.prefix(5)) { transaction in
                    TransactionRow(
                        transaction: transaction
                    ) { selectTransaction(transaction) }
                }
            }
        }
    }

    private func loadRecentTransactions() {
        recentTransactions = [
            Transaction(
                id: UUID(),
                amount: -45.67,
                description: "STARBUCKS COFFEE #1234",
                date: Date(),
                categoryId: nil
            ),
            Transaction(
                id: UUID(),
                amount: -12.99,
                description: "NETFLIX.COM MONTHLY",
                date: Date().addingTimeInterval(-86_400),
                categoryId: nil
            ),
            Transaction(
                id: UUID(),
                amount: -89.32,
                description: "SHELL GAS STATION",
                date: Date().addingTimeInterval(-172_800),
                categoryId: nil
            )
        ]

        // Initialize with default categorization suggestions
        suggestedCategories = BudgetCategoryType.allCases.prefix(6).map { categoryType in
            CategoryPrediction(
                category: categoryType,
                confidence: 0.5,
                reasoning: "Default suggestion",
                alternativeCategories: []
            )
        }
    }

    private func selectTransaction(_ transaction: Transaction) {
        selectedTransaction = transaction
        generateCategorySuggestions(for: transaction)
    }

    private func generateCategorySuggestions(for transaction: Transaction) {
        let prediction = aiEngine.categorizeTransaction(
            transaction.description,
            amount: transaction.amount
        )

        // Convert AI predictions to CategoryPrediction format
        var predictions: [CategoryPrediction] = [prediction]

        // Add alternative suggestions
        for altCategory in prediction.alternativeCategories {
            let altPrediction = CategoryPrediction(
                category: altCategory,
                confidence: prediction.confidence * 0.7, // Lower confidence for alternatives
                reasoning: "Alternative suggestion",
                alternativeCategories: []
            )
            predictions.append(altPrediction)
        }

        suggestedCategories = predictions
    }

    private func applyCategory(_ categoryPrediction: CategoryPrediction) {
        guard let transaction = selectedTransaction else { return }

        // Store the category prediction for learning
        let budgetCategory = categoryPrediction.category
        transaction.categoryId = UUID() // Temporary - in real app would map to actual category

        // Provide feedback to AI engine for learning
        aiEngine.learnFromUserFeedback(
            description: transaction.description,
            amount: transaction.amount,
            userSelectedCategory: budgetCategory
        )

        if let index = recentTransactions.firstIndex(where: { $0.id == transaction.id }) {
            recentTransactions.remove(at: index)
        }

        selectedTransaction = nil

        if !recentTransactions.isEmpty {
            selectTransaction(recentTransactions.first!)
        }
    }

    private func processAllTransactions() {
        isProcessing = true

        Task {
            let transactionData = recentTransactions.map { transaction in
                TransactionData(
                    description: transaction.description,
                    amount: transaction.amount,
                    merchant: nil
                )
            }

            let predictions = await aiEngine.bulkCategorize(transactionData)

            await MainActor.run {
                // Apply predictions to transactions
                for (index, prediction) in predictions.enumerated() {
                    if index < recentTransactions.count {
                        recentTransactions[index].categoryId = UUID() // Temporary mapping
                    }
                }

                recentTransactions.removeAll()
                isProcessing = false
            }
        }
    }
}

struct CategoryPredictionCard: View {
    let prediction: CategoryPrediction
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: prediction.category.icon)
                    .font(.title2)
                    .foregroundColor(prediction.category.defaultColor)

                Text(prediction.category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                // Confidence indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(confidenceColor)
                        .frame(width: 6, height: 6)

                    Text("\(Int(prediction.confidence * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? prediction.category.defaultColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? prediction.category.defaultColor : Color.clear, lineWidth: 2)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .help(prediction.reasoning)
    }

    private var confidenceColor: Color {
        if prediction.confidence > 0.8 {
            return .green
        } else if prediction.confidence > 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.description)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(transaction.formattedAmount)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.amount < 0 ? .red : .green)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

class Transaction: ObservableObject, Identifiable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    @Published var categoryId: UUID?

    init(id: UUID, amount: Double, description: String, date: Date, categoryId: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.categoryId = categoryId
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// Legacy Category struct - kept for compatibility
struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color

    static let food = Category(name: "Food & Dining", icon: "fork.knife", color: .orange)
    static let transportation = Category(name: "Transportation", icon: "car.fill", color: .blue)
    static let entertainment = Category(name: "Entertainment", icon: "tv.fill", color: .purple)
    static let subscriptions = Category(name: "Subscriptions", icon: "repeat.circle.fill", color: .red)
    static let utilities = Category(name: "Utilities", icon: "bolt.fill", color: .yellow)
    static let business = Category(name: "Business", icon: "briefcase.fill", color: .green)
    static let travel = Category(name: "Travel", icon: "airplane", color: .cyan)
    static let shopping = Category(name: "Shopping", icon: "bag.fill", color: .pink)
    static let healthcare = Category(name: "Healthcare", icon: "cross.fill", color: .red)

    static let defaultCategories = [
        food, transportation, entertainment, subscriptions,
        utilities, business, travel, shopping, healthcare
    ]
}

#Preview {
    SmartExpenseCategorizer()
        .frame(width: 600, height: 500)
}
