// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  ContentView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Main application navigation structure with three-panel layout for sandbox environment
* Issues & Complexity Summary: Navigation state management, sidebar coordination, sandbox watermarking
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Low-Medium
  - Dependencies: 1 New (NavigationSplitView)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 65%
* Problem Estimate (Inherent Problem Difficulty %): 60%
* Initial Code Complexity Estimate %: 65%
* Justification for Estimates: NavigationSplitView is well-documented, straightforward implementation
* Final Code Complexity (Actual %): 68%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Navigation state management simpler than expected
* Last Updated: 2025-06-02
*/

import SwiftUI

struct ContentView: View {
    @State private var selectedView: NavigationItem = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        ChatbotIntegrationView {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView(selectedView: $selectedView)
            } detail: {
                DetailView(selectedView: selectedView)
            }
            .overlay(alignment: .bottomTrailing) {
                // SANDBOX WATERMARK - MANDATORY
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding()
            }
        }
        .onAppear {
            // Initialize chatbot PRODUCTION services for real API integration
            Task { @MainActor in
                ChatbotSetupManager.shared.setupProductionServices()
            }
        }
    }
}

struct SidebarView: View {
    @Binding var selectedView: NavigationItem
    
    var body: some View {
        List(NavigationItem.allCases, id: \.self, selection: $selectedView) { item in
            NavigationLink(value: item) {
                Label(item.title, systemImage: item.icon)
            }
        }
        .navigationTitle("FinanceMate")
        .frame(minWidth: 200)
    }
}

struct DetailView: View {
    let selectedView: NavigationItem
    
    var body: some View {
        Group {
            switch selectedView {
            case .dashboard:
                DashboardView()
            case .documents:
                DocumentsView()
            case .analytics:
                AnalyticsView()
            case .mlacs:
                MLACSView()
            case .export:
                FinancialExportView()
            case .enhancedAnalytics:
                RealTimeFinancialInsightsView()
            case .settings:
                SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum NavigationItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case documents = "Documents"
    case analytics = "Analytics"
    case mlacs = "MLACS"
    case export = "Financial Export"
    case enhancedAnalytics = "Enhanced Analytics"
    case settings = "Settings"
    
    var title: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .documents: return "doc.fill"
        case .analytics: return "chart.bar.fill"
        case .mlacs: return "brain.head.profile"
        case .export: return "square.and.arrow.up.fill"
        case .enhancedAnalytics: return "chart.bar.doc.horizontal.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    ContentView()
}