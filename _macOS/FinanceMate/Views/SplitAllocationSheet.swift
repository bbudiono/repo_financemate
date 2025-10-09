import CoreData
import Foundation
import SwiftUI

/*
 * Purpose: Bridge component to convert GmailLineItem to LineItem for tax splitting
 * Issues & Complexity Summary: Handles data conversion between Gmail models and Core Data
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~80
 *   - Core Algorithm Complexity: Medium (Data mapping and Core Data operations)
 *   - Dependencies: Core Data, Foundation, SwiftUI, Gmail models
 *   - State Management Complexity: Medium (Core Data context management)
 *   - Novelty/Uncertainty Factor: Low (Standard data conversion pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
 * Problem Estimate (Inherent Problem Difficulty %): 40%
 * Initial Code Complexity Estimate %: 35%
 * Justification for Estimates: Data conversion with Core Data persistence and state management
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Bridge component that converts GmailLineItem to LineItem for tax splitting
struct SplitAllocationSheet: View {
    let gmailLineItem: GmailLineItem
    let merchant: String
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel: SplitAllocationViewModel
    @State private var convertedLineItem: LineItem?
    @State private var isLoading = true
    @State private var errorMessage: String?

    init(gmailLineItem: GmailLineItem, merchant: String, isPresented: Binding<Bool>) {
        self.gmailLineItem = gmailLineItem
        self.merchant = merchant
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: SplitAllocationViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Converting line item...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let lineItem = convertedLineItem {
                SplitAllocationView(
                    viewModel: viewModel,
                    lineItem: lineItem,
                    isPresented: $isPresented
                )
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text("Conversion Error")
                        .font(.headline)

                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView("Initializing...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            Task {
                await convertGmailLineItemToLineItem()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                isPresented = false
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Private Methods

    /// Converts GmailLineItem to LineItem for tax splitting
    private func convertGmailLineItemToLineItem() async {
        isLoading = true
        errorMessage = nil

        do {
            // Create a new LineItem from the GmailLineItem data
            let lineItem = LineItem(context: viewContext)
            lineItem.id = UUID()
            lineItem.itemDescription = gmailLineItem.description
            lineItem.quantity = Int32(gmailLineItem.quantity)
            lineItem.price = gmailLineItem.price
            lineItem.taxCategory = "Personal" // Default category

            // Save to Core Data
            try viewContext.save()

            await MainActor.run {
                self.convertedLineItem = lineItem
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to convert line item: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplitAllocationSheet(
        gmailLineItem: GmailLineItem(
            description: "Test Item",
            quantity: 2,
            price: 50.0
        ),
        merchant: "Test Merchant",
        isPresented: .constant(true)
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}