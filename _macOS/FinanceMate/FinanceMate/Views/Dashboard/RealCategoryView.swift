//
//  RealCategoryView.swift
//  FinanceMate
//
//  Purpose: Real category view using Core Data - NO MOCK DATA
//

import CoreData
import SwiftUI

struct RealCategoryView: View {
    @StateObject private var dataService = DashboardDataService()
    @State private var categories: [CategoryExpense] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Smart Expense Categorizer")
                .font(.title2)
                .fontWeight(.semibold)

            if isLoading {
                ProgressView("Analyzing your expenses...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error loading categories")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadCategories()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if categories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No expense data found")
                        .font(.headline)
                    Text("Upload financial documents to see expense categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(categories.prefix(8), id: \.name) { category in
                        RealCategoryCard(category: category)
                    }
                }

                if categories.count > 8 {
                    Text("\(categories.count - 8) more categories...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .onAppear {
            loadCategories()
        }
    }

    private func loadCategories() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedCategories = try await dataService.getCategorizedExpenses()
                await MainActor.run {
                    self.categories = fetchedCategories
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct RealCategoryCard: View {
    let category: CategoryExpense

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Spacer()
                Image(systemName: category.trend.icon)
                    .foregroundColor(category.trend.color)
            }

            Text("$\(category.totalAmount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Text("\(category.transactionCount) transactions")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if abs(category.trendPercentage) > 0.1 {
                    Spacer()
                    Text("\(category.trendPercentage > 0 ? "+" : "")\(category.trendPercentage, specifier: "%.1f")%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(category.trend.color)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

extension CategoryTrend {
    var color: Color {
        switch self {
        case .up: return .red
        case .down: return .green
        case .stable: return .blue
        }
    }

    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
}
