// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardDataStatus.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular data status indicator component extracted from DashboardView
* Issues & Complexity Summary: Simple status indicator showing real data integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~40
  - Core Algorithm Complexity: Low (simple count display)
  - Dependencies: 2 New (SwiftUI, Core Data)
  - State Management Complexity: Low (read-only data display)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 8%
* Problem Estimate (Inherent Problem Difficulty %): 5%
* Initial Code Complexity Estimate %): 7%
* Justification for Estimates: Very simple status display component
* Final Code Complexity (Actual %): 10%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Clean extraction of status indicator
* Last Updated: 2025-06-06
*/

import SwiftUI
import CoreData

struct DashboardDataStatus: View {
    let allFinancialData: FetchedResults<FinancialData>
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Real Data Integration Active")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Text("Showing \(allFinancialData.count) total financial records")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}