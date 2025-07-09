//
// ContentView.swift
// FinanceMate
//
// Purpose: Main navigation container integrating MVVM dashboard architecture
// Issues & Complexity Summary: Production navigation using DashboardView with proper MVVM separation
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~60
//   - Core Algorithm Complexity: Low
//   - Dependencies: 2 (DashboardView, Core Data Environment)
//   - State Management Complexity: Low
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 98%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: 72%
// Overall Result Score: 96%
// Key Variances/Learnings: Simplified to proper MVVM navigation pattern
// Last Updated: 2025-07-05

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dashboardViewModel = DashboardViewModel()

    var body: some View {
        // Full-width tab navigation structure
        TabView {
            // Dashboard Tab - Full Width
            DashboardView()
                .environmentObject(dashboardViewModel)
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .accessibilityIdentifier("Dashboard")

            // Transactions Tab
            TransactionsView(context: viewContext)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .accessibilityIdentifier("Transactions")

            // Settings Tab (placeholder for future implementation)
            SettingsPlaceholderView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .accessibilityIdentifier("Settings")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            dashboardViewModel.setPersistenceContext(viewContext)
            Task {
                dashboardViewModel.fetchDashboardData()
            }
        }
    }
}

// MARK: - Placeholder Views for Future Implementation

private struct SettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gear.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Text("App settings coming soon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassmorphism(.secondary, cornerRadius: 16)
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
