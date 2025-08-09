//
// WealthQuickStatsView.swift
// FinanceMate
//
// Purpose: Quick stats row displaying key wealth metrics with glassmorphism cards
// Issues & Complexity Summary: Responsive layout with adaptive cards and accessibility
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Low (simple display and formatting)
//   - Dependencies: 2 (SwiftUI, NetWealthDashboardViewModel)
//   - State Management Complexity: Low (read-only display)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 80%
// Final Code Complexity: 82%
// Overall Result Score: 95%
// Key Variances/Learnings: Clean modular card design with consistent accessibility
// Last Updated: 2025-08-04

import SwiftUI

struct WealthQuickStatsView: View {
    @ObservedObject var viewModel: NetWealthDashboardViewModel
    
    var body: some View {
        quickStatsRow
    }
    
    // MARK: - Quick Stats Row
    
    private var quickStatsRow: some View {
        HStack(spacing: 16) {
            quickStatCard(
                title: "Total Assets",
                value: viewModel.formattedTotalAssets,
                icon: "arrow.up.circle.fill",
                color: .green,
                accessibilityId: "TotalAssetsCard"
            )
            
            quickStatCard(
                title: "Total Liabilities", 
                value: viewModel.formattedTotalLiabilities,
                icon: "arrow.down.circle.fill",
                color: .red,
                accessibilityId: "TotalLiabilitiesCard"
            )
            
            quickStatCard(
                title: "Monthly Change",
                value: viewModel.formattedMonthlyChange,
                icon: viewModel.monthlyChangeIcon,
                color: viewModel.monthlyChangeColor,
                accessibilityId: "MonthlyChangeCard"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("QuickStatsRow")
    }
    
    private func quickStatCard(title: String, value: String, icon: String, color: Color, accessibilityId: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityIdentifier(accessibilityId)
    }
}

// MARK: - Preview Provider

#Preview {
    WealthQuickStatsView(viewModel: NetWealthDashboardViewModel())
        .padding()
}