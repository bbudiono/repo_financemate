//
// AssetBreakdownView.swift
// FinanceMate
//
// Purpose: Simple asset breakdown UI with real data integration and glassmorphism styling
// Issues & Complexity Summary: SwiftUI view with real asset categorization, MVVM binding, responsive layout
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium (asset display, category breakdown)
//   - Dependencies: 3 (SwiftUI, AssetBreakdownViewModel, GlassmorphismModifier)
//   - State Management Complexity: Medium (real asset data, loading states)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 85%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: Simple, modular approach with real data integration
// Last Updated: 2025-08-02

import CoreData
import SwiftUI

/// Simple asset breakdown view displaying real asset categorization with glassmorphism styling
///
/// This view provides a clean, modular asset breakdown interface including:
/// - Real asset category totals from Core Data
/// - Asset type breakdown with AUD currency formatting
/// - Simple, responsive layout with glassmorphism design
/// - Loading states and error handling for real data
struct AssetBreakdownView: View {
    
    @EnvironmentObject private var viewModel: AssetBreakdownViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Simple Header
                    headerSection
                    
                    // Asset Categories (Real Data)
                    if viewModel.isLoading {
                        AssetBreakdownLoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        AssetBreakdownErrorView(message: errorMessage) {
                            viewModel.fetchAssetBreakdown()
                        }
                    } else {
                        assetCategoriesSection
                    }
                }
                .padding(20)
            }
        }
        .accessibilityIdentifier("AssetBreakdownView")
        .onAppear {
            viewModel.fetchAssetBreakdown()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Asset Breakdown")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Real asset categorization")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if viewModel.totalAssetValue > 0 {
                Text("Total: \(viewModel.formattedTotalValue)")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Asset Breakdown with total value \(viewModel.formattedTotalValue)")
    }
    
    // MARK: - Asset Categories Section (Real Data)
    private var assetCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Asset.AssetType.allCases, id: \.self) { assetType in
                if let assets = viewModel.assetsByCategory[assetType], !assets.isEmpty {
                    assetCategoryCard(for: assetType, assets: assets)
                }
            }
            if viewModel.assetsByCategory.isEmpty {
                AssetBreakdownEmptyStateView()
            }
        }
    }
    
    // MARK: - Asset Category Card (Real Data)
    private func assetCategoryCard(for assetType: Asset.AssetType, assets: [Asset]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(assetType.stringValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(viewModel.formattedCategoryTotal(for: assetType))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Simple asset list (real data)
            ForEach(assets.prefix(3), id: \.id) { asset in
                HStack {
                    Text(asset.name)
                        .font(.body)
                    Spacer()
                    Text(asset.formattedCurrentValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if assets.count > 3 {
                Text("+ \(assets.count - 3) more assets")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
        }
        .padding(16)
        .modifier(GlassmorphismModifier(style: .secondary, cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(assetType.stringValue) category with \(assets.count) assets totaling \(viewModel.formattedCategoryTotal(for: assetType))")
    }
    
}