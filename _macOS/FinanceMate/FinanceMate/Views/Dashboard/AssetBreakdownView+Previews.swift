//
// AssetBreakdownView+Previews.swift
// FinanceMate
//
// Purpose: Modular preview definitions for AssetBreakdownView
// Issues & Complexity Summary: Preview configuration with test data
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~25
//   - Core Algorithm Complexity: Low (preview setup)
//   - Dependencies: 3 (SwiftUI, AssetBreakdownView, AssetBreakdownViewModel)
//   - State Management Complexity: Low (preview mock data)
//   - Novelty/Uncertainty Factor: None
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 95%
// Final Code Complexity: 98%
// Overall Result Score: 98%
// Key Variances/Learnings: Extracted preview to separate file for modularity
// Last Updated: 2025-08-05

import SwiftUI

// MARK: - Preview
struct AssetBreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        AssetBreakdownView()
            .environmentObject(AssetBreakdownViewModel(
                context: PersistenceController.preview.container.viewContext,
                entity: nil
            ))
            .frame(width: 400, height: 600)
            .background(Color.gray.opacity(0.1))
    }
}