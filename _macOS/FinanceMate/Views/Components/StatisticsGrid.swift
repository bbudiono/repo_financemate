import SwiftUI

/**
 * StatisticsGrid.swift
 * 
 * Purpose: PHASE 3.3 - Modular statistics grid component (extracted from ProcessingStatisticsView)
 * Issues & Complexity Summary: Statistics display grid with metric cards and visual indicators
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~50 (focused grid display responsibility)
 *   - Core Algorithm Complexity: Low (data display and card layout)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: None (display-only component)
 *   - Novelty/Uncertainty Factor: Low (established grid display patterns)
 * AI Pre-Task Self-Assessment: 99%
 * Problem Estimate: 75%
 * Initial Code Complexity Estimate: 68%
 * Target Coverage: Statistics grid display testing
 * Australian Compliance: Processing metrics display standards
 * Last Updated: 2025-08-08
 */

/// Modular statistics grid component
/// Extracted from ProcessingStatisticsView to maintain <200 line rule
struct StatisticsGrid: View {
    
    // MARK: - Properties
    
    let result: EmailReceiptResult
    
    // MARK: - Body
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            statisticCard(
                title: "Total Processed",
                value: "\(result.processedReceipts.count)",
                color: .blue,
                icon: "doc.text"
            )
            
            statisticCard(
                title: "Successful",
                value: "\(successfulCount)",
                color: .green,
                icon: "checkmark.circle"
            )
            
            statisticCard(
                title: "Needs Review",
                value: "\(needsReviewCount)",
                color: .orange,
                icon: "exclamationmark.circle"
            )
            
            statisticCard(
                title: "Errors",
                value: "\(errorsCount)",
                color: .red,
                icon: "xmark.circle"
            )
        }
    }
    
    // MARK: - Statistic Card
    
    private func statisticCard(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var successfulCount: Int {
        result.processedReceipts.filter { $0.processingStatus == .success }.count
    }
    
    private var needsReviewCount: Int {
        result.processedReceipts.filter { $0.processingStatus == .needsReview }.count
    }
    
    private var errorsCount: Int {
        result.processedReceipts.filter { $0.processingStatus == .failed }.count
    }
}

// MARK: - Preview

#Preview {
    StatisticsGrid(
        result: EmailReceiptResult(
            processedReceipts: [],
            processingErrors: [],
            processingDuration: 0,
            emailsProcessed: 0,
            auditTrail: []
        )
    )
}