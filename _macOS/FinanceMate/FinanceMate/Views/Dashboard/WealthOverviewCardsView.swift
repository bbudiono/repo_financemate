//
// WealthOverviewCardsView.swift
// FinanceMate
//
// Purpose: Assets and liabilities overview cards with detail toggle functionality
// Issues & Complexity Summary: Clean overview cards with interactive expand/collapse
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~90
//   - Core Algorithm Complexity: Low (card display and interactions)
//   - Dependencies: 2 (SwiftUI, NetWealthDashboardViewModel)
//   - State Management Complexity: Medium (binding coordination)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 92%
// Problem Estimate: 90%
// Initial Code Complexity Estimate: 88%
// Final Code Complexity: 89%
// Overall Result Score: 95%
// Key Variances/Learnings: Extracted from NetWealthDashboardView for modular architecture
// Last Updated: 2025-08-04

import SwiftUI

struct WealthOverviewCardsView: View {
    @ObservedObject var viewModel: NetWealthDashboardViewModel
    @Binding var showingAssetDetails: Bool
    @Binding var showingLiabilityDetails: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            overviewCard(
                title: "Total Assets",
                value: viewModel.formattedTotalAssets,
                icon: "chart.pie.fill",
                color: .green,
                isLoading: viewModel.isLoading,
                showDetailAction: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAssetDetails.toggle()
                    }
                },
                isShowingDetail: showingAssetDetails,
                accessibilityId: "TotalAssetsCard"
            )
            
            overviewCard(
                title: "Total Liabilities",
                value: viewModel.formattedTotalLiabilities,
                icon: "minus.circle.fill",
                color: .red,
                isLoading: viewModel.isLoading,
                showDetailAction: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLiabilityDetails.toggle()
                    }
                },
                isShowingDetail: showingLiabilityDetails,
                accessibilityId: "TotalLiabilitiesCard"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AssetsLiabilitiesOverview")
    }
    
    private func overviewCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        isLoading: Bool,
        showDetailAction: @escaping () -> Void,
        isShowingDetail: Bool,
        accessibilityId: String
    ) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Button(action: showDetailAction) {
                    Image(systemName: isShowingDetail ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(isShowingDetail ? "Hide details" : "Show details")
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .opacity(isLoading ? 0.5 : 1.0)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityIdentifier(accessibilityId)
    }
}