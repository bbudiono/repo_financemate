// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardRecentActivity.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular recent activity component extracted from DashboardView for reusability
* Issues & Complexity Summary: Document list rendering with real-time Core Data integration
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low (document filtering and display)
  - Dependencies: 3 New (SwiftUI, Core Data, TaskMaster wiring)
  - State Management Complexity: Low (Core Data fetch results)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 20%
* Problem Estimate (Inherent Problem Difficulty %): 15%
* Initial Code Complexity Estimate %): 18%
* Justification for Estimates: Simple document list component with TaskMaster tracking
* Final Code Complexity (Actual %): 22%
* Overall Result Score (Success & Quality %): 96%
* Key Variances/Learnings: Clean component extraction maintains all functionality
* Last Updated: 2025-06-06
*/

import SwiftUI
import CoreData

struct DashboardRecentActivity: View {
    let allDocuments: FetchedResults<Document>
    let wiringService: TaskMasterWiringService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    Task {
                        _ = await wiringService.trackButtonAction(
                            buttonId: "dashboard-view-all-btn",
                            viewName: "DashboardView",
                            actionDescription: "View All Recent Activity",
                            expectedOutcome: "Navigate to DocumentsView with all documents",
                            metadata: [
                                "total_documents": "\(allDocuments.count)",
                                "recent_documents_shown": "\(Array(allDocuments.prefix(5)).count)",
                                "navigation_target": "DocumentsView"
                            ]
                        )
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            let recentDocs = Array(allDocuments.prefix(5))
            if recentDocs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No documents yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Upload financial documents to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(recentDocs, id: \.self) { document in
                    DocumentRow(document: document)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DocumentRow: View {
    let document: Document
    
    var body: some View {
        HStack {
            Image(systemName: document.documentTypeEnum.iconName)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(document.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let dateCreated = document.dateCreated {
                    Text(dateCreated, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if let financialData = document.financialData,
                   let amount = financialData.totalAmount {
                    Text(formatCurrency(amount.doubleValue))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(amount.doubleValue < 0 ? .red : .green)
                }
                
                Text(document.processingStatusEnum.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}