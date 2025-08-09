//
// InteractiveChartsView.swift
// FinanceMate
//
// Purpose: Interactive charts container with tab picker and chart switching logic
// Issues & Complexity Summary: Complex chart coordination with smooth animations and real data
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~200
//   - Core Algorithm Complexity: Medium (chart switching and animation coordination)
//   - Dependencies: 3 (SwiftUI, Charts, WealthDashboardModels)
//   - State Management Complexity: Medium (chart tab selection and interactive state)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 88%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 88%
// Final Code Complexity: 90%
// Overall Result Score: 93%
// Key Variances/Learnings: Chart animation coordination requires careful state management
// Last Updated: 2025-08-04

import SwiftUI

struct InteractiveChartsView: View {
    @ObservedObject var viewModel: NetWealthDashboardViewModel
    @Binding var selectedChartTab: ChartTab
    @Binding var selectedAssetCategory: String?
    @Binding var selectedLiabilityType: String?
    @Binding var showingChartDetails: Bool
    
    var body: some View {
        interactiveChartsSection
    }
    
    // MARK: - Interactive Charts Section
    
    private var interactiveChartsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Wealth Visualization")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                chartTabPicker
            }
            
            Group {
                switch selectedChartTab {
                case .assetPie:
                    AssetPieChartView(
                        viewModel: viewModel,
                        selectedAssetCategory: $selectedAssetCategory
                    )
                case .liabilityPie:
                    LiabilityPieChartView(
                        viewModel: viewModel,
                        selectedLiabilityType: $selectedLiabilityType
                    )
                case .comparisonBar:
                    ComparisonBarChartView(viewModel: viewModel)
                case .netWealthTrend:
                    WealthTrendChartView(viewModel: viewModel)
                }
            }
            .frame(height: 280)
            .animation(.easeInOut(duration: 0.3), value: selectedChartTab)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("InteractiveChartsSection")
    }
    
    private var chartTabPicker: some View {
        HStack(spacing: 4) {
            ForEach(ChartTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedChartTab = tab
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: tab.icon)
                            .font(.caption)
                            .foregroundColor(selectedChartTab == tab ? .white : .secondary)
                        
                        Text(tab.title)
                            .font(.caption2)
                            .foregroundColor(selectedChartTab == tab ? .white : .secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedChartTab == tab ? Color.accentColor : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("ChartTab\(tab.rawValue)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Chart type picker")
    }
}

// MARK: - Preview Provider

#Preview {
    InteractiveChartsView(
        viewModel: NetWealthDashboardViewModel(),
        selectedChartTab: .constant(.assetPie),
        selectedAssetCategory: .constant(nil),
        selectedLiabilityType: .constant(nil),
        showingChartDetails: .constant(false)
    )
    .padding()
}