// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  AnalyticsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Analytics view wrapper that provides DocumentManager integration for TDD-driven analytics
* Issues & Complexity Summary: Integration wrapper for EnhancedAnalyticsView with Core Data access
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~50
  - Core Algorithm Complexity: Low (wrapper/integration)
  - Dependencies: 2 New (EnhancedAnalyticsView, DocumentManager)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
* Problem Estimate (Inherent Problem Difficulty %): 35%
* Initial Code Complexity Estimate %: 38%
* Justification for Estimates: Simple wrapper view with dependency injection
* Final Code Complexity (Actual %): 40%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Straightforward integration with TDD AnalyticsViewModel
* Last Updated: 2025-06-04
*/

import SwiftUI

struct AnalyticsView: View {
    @StateObject private var documentManager = DocumentManager()
    
    var body: some View {
        EnhancedAnalyticsView(documentManager: documentManager)
            .navigationTitle("Analytics")
    }
}

#Preview {
    AnalyticsView()
}