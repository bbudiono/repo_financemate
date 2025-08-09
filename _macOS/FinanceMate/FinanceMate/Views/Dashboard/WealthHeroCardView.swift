//
// WealthHeroCardView.swift
// FinanceMate
//
// Purpose: Hero card displaying total net wealth with progress bar and visual indicators
// Issues & Complexity Summary: Clean hero card with responsive layout and accessibility
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~180
//   - Core Algorithm Complexity: Medium (progress calculations and formatting)
//   - Dependencies: 2 (SwiftUI, NetWealthDashboardViewModel)
//   - State Management Complexity: Low (read-only display)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 90%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: 87%
// Overall Result Score: 94%
// Key Variances/Learnings: Progress bar calculations require careful real data validation
// Last Updated: 2025-08-04

import SwiftUI

struct WealthHeroCardView: View {
    @ObservedObject var viewModel: NetWealthDashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Net Wealth")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(viewModel.formattedNetWealth)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.netWealthColor)
                        .contentTransition(.numericText())
                        .accessibilityLabel("Net wealth: \(viewModel.formattedNetWealth)")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.netWealthTrendIcon)
                            .font(.caption)
                            .foregroundColor(viewModel.netWealthTrendColor)
                        
                        Text(viewModel.formattedNetWealthChange)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.netWealthTrendColor)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Net wealth change: \(viewModel.formattedNetWealthChange)")
                    
                    Text("vs last month")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            assetLiabilityProgressBar
        }
        .padding(20)
        .glassmorphism(.primary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("NetWealthHeroCard")
    }
    
    // MARK: - Asset Liability Progress Bar
    
    private var assetLiabilityProgressBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Assets vs Liabilities")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(viewModel.assetToLiabilityRatio * 100))% Assets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red.opacity(0.2))
                        .frame(height: 12)
                    
                    // Asset portion (left side)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(
                            width: geometry.size.width * viewModel.assetToLiabilityRatio,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.8), value: viewModel.assetToLiabilityRatio)
                }
            }
            .frame(height: 12)
            .accessibilityElement()
            .accessibilityLabel("Asset to liability ratio: \(Int(viewModel.assetToLiabilityRatio * 100)) percent assets")
            .accessibilityIdentifier("AssetLiabilityProgressBar")
            
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.formattedTotalAssets)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total assets: \(viewModel.formattedTotalAssets)")
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.formattedTotalLiabilities)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total liabilities: \(viewModel.formattedTotalLiabilities)")
            }
        }
    }
}

// MARK: - Preview Provider

#Preview {
    WealthHeroCardView(viewModel: NetWealthDashboardViewModel())
        .padding()
}