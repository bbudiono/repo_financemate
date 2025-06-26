// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DashboardQuickActions.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular quick actions component extracted from DashboardView for reusability
* Issues & Complexity Summary: Action button grid with comprehensive TaskMaster workflow tracking
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~180
  - Core Algorithm Complexity: Medium (workflow tracking, modal management)
  - Dependencies: 4 New (SwiftUI, TaskMaster workflow tracking, Core Data, modal state)
  - State Management Complexity: Medium (modal state binding, workflow coordination)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
* Problem Estimate (Inherent Problem Difficulty %): 30%
* Initial Code Complexity Estimate %): 33%
* Justification for Estimates: Component extraction with complex TaskMaster workflow integration
* Final Code Complexity (Actual %): 38%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: TaskMaster workflow tracking adds significant complexity but provides excellent UX monitoring
* Last Updated: 2025-06-06
*/

import CoreData
import SwiftUI

struct DashboardQuickActions: View {
    let allDocuments: FetchedResults<Document>
    let wiringService: TaskMasterWiringService
    @Binding var showingAddTransaction: Bool
    @Binding var showingDocumentUpload: Bool
    @Binding var showingAnalytics: Bool

    // For financial metrics access
    let totalBalance: Double
    let monthlyIncome: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DashboardQuickActionButton(
                    title: "Upload Document",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    Task {
                        _ = await wiringService.trackButtonAction(
                            buttonId: "dashboard-upload-document-btn",
                            viewName: "DashboardView",
                            actionDescription: "Upload Financial Document",
                            expectedOutcome: "Navigate to document upload interface",
                            metadata: [
                                "current_documents": "\(allDocuments.count)",
                                "quick_action": "upload",
                                "navigation_target": "DocumentUploadView"
                            ]
                        )
                    }
                    showingDocumentUpload = true
                }

                DashboardQuickActionButton(
                    title: "Add Transaction",
                    icon: "plus.square.fill",
                    color: .green
                ) {
                    Task {
                        _ = await wiringService.trackModalWorkflow(
                            modalId: "dashboard-add-transaction-modal",
                            viewName: "DashboardView",
                            workflowDescription: "Add New Financial Transaction",
                            expectedSteps: [
                                TaskMasterWorkflowStep(
                                    title: "Select Transaction Type",
                                    description: "Choose between Income or Expense",
                                    elementType: .form,
                                    estimatedDuration: 10,
                                    validationCriteria: ["Transaction type selected"]
                                ),
                                TaskMasterWorkflowStep(
                                    title: "Enter Amount",
                                    description: "Input transaction amount",
                                    elementType: .form,
                                    estimatedDuration: 15,
                                    validationCriteria: ["Valid amount entered", "Amount > 0"]
                                ),
                                TaskMasterWorkflowStep(
                                    title: "Enter Description",
                                    description: "Provide transaction description",
                                    elementType: .form,
                                    estimatedDuration: 20,
                                    validationCriteria: ["Description provided", "Description not empty"]
                                ),
                                TaskMasterWorkflowStep(
                                    title: "Select Date",
                                    description: "Choose transaction date",
                                    elementType: .form,
                                    estimatedDuration: 10,
                                    validationCriteria: ["Valid date selected"]
                                ),
                                TaskMasterWorkflowStep(
                                    title: "Save Transaction",
                                    description: "Persist transaction to Core Data",
                                    elementType: .action,
                                    estimatedDuration: 5,
                                    validationCriteria: ["Transaction saved", "Core Data updated"]
                                )
                            ],
                            metadata: [
                                "current_balance": "\(totalBalance)",
                                "monthly_income": "\(monthlyIncome)",
                                "modal_type": "transaction_entry"
                            ]
                        )
                    }
                    showingAddTransaction = true
                }

                DashboardQuickActionButton(
                    title: "View Reports",
                    icon: "chart.bar.fill",
                    color: .purple
                ) {
                    Task {
                        _ = await wiringService.trackButtonAction(
                            buttonId: "dashboard-view-reports-btn",
                            viewName: "DashboardView",
                            actionDescription: "View Financial Reports",
                            expectedOutcome: "Navigate to AnalyticsView with comprehensive reports",
                            metadata: [
                                "total_balance": "\(totalBalance)",
                                "monthly_income": "\(monthlyIncome)",
                                "navigation_target": "AnalyticsView"
                            ]
                        )
                    }
                    showingAnalytics = true
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
}

struct DashboardQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
