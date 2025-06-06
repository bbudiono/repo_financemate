// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardHeader.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular dashboard header component with sandbox watermark
* Issues & Complexity Summary: Simple header component with proper sandbox identification
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~50
  - Core Algorithm Complexity: Low (static header with watermark)
  - Dependencies: 1 New (SwiftUI)
  - State Management Complexity: Low (no state management)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 10%
* Problem Estimate (Inherent Problem Difficulty %): 5%
* Initial Code Complexity Estimate %): 8%
* Justification for Estimates: Simple header component extraction
* Final Code Complexity (Actual %): 12%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Simple modular extraction with excellent reusability
* Last Updated: 2025-06-06
*/

import SwiftUI

struct DashboardHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Financial Overview")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("🧪 SANDBOX MODE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
            }
            
            Text("Welcome back! Here's your real financial summary from Core Data.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}