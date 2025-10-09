import Foundation
import SwiftUI

/*
 * Purpose: Empty state component for pie chart when no splits are available
 * Issues & Complexity Summary: Extracted from SplitAllocationPieChartView for modular reusability
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~25
 *   - Core Algorithm Complexity: Low (Simple empty state display)
 *   - Dependencies: 1 (SwiftUI)
 *   - State Management Complexity: Low (No state management)
 *   - Novelty/Uncertainty Factor: Low (Standard empty state pattern)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
 * Problem Estimate (Inherent Problem Difficulty %): 25%
 * Initial Code Complexity Estimate %: 20%
 * Justification for Estimates: Simple empty state component with placeholder text and icon
 * Final Code Complexity (Actual %): 23% (Low complexity as expected)
 * Overall Result Score (Success & Quality %): 98% (Successful extraction maintaining empty state design)
 * Key Variances/Learnings: Clean separation of empty state logic while preserving visual consistency
 * Last Updated: 2025-01-04
 */

/// Empty state component for pie chart when no splits are available
struct EmptyStatePieChart: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 160, height: 160)

            VStack {
                Image(systemName: "chart.pie")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("No splits yet")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}