//
// NetWealthDashboardView_TestingVersion.swift
// FinanceMate
//
// Purpose: Temporary testing version for Phase 3 Functional Integration Testing
// Issues & Complexity Summary: Simplified version for testing core modular functionality
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~60
//   - Core Algorithm Complexity: Low (basic composition for testing)
//   - Dependencies: 1 New (SwiftUI), 0 Mod
//   - State Management Complexity: Low (minimal state for testing)
//   - Novelty/Uncertainty Factor: Low (temporary testing implementation)
// AI Pre-Task Self-Assessment: 98%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 70%
// Final Code Complexity: 72%
// Overall Result Score: 97%
// Key Variances/Learnings: Temporary version enables core functionality testing
// Last Updated: 2025-08-04

import SwiftUI

struct NetWealthDashboardView: View {
    @StateObject private var viewModel = NetWealthDashboardViewModel()
    @State private var showingAssetDetails = false
    @State private var showingLiabilityDetails = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Temporary Hero Section for Testing
                VStack(spacing: 16) {
                    Text("Net Wealth Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Total Net Wealth: $\(viewModel.netWealth, specifier: "%.2f")")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Testing: Asset Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Assets")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Total Assets: $\(viewModel.totalAssets, specifier: "%.2f")")
                        .font(.subheadline)
                    
                    Button("Toggle Asset Details") {
                        withAnimation {
                            showingAssetDetails.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if showingAssetDetails {
                        Text("Asset breakdown details would appear here")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Testing: Liability Information  
                VStack(alignment: .leading, spacing: 12) {
                    Text("Liabilities")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Total Liabilities: $\(viewModel.totalLiabilities, specifier: "%.2f")")
                        .font(.subheadline)
                    
                    Button("Toggle Liability Details") {
                        withAnimation {
                            showingLiabilityDetails.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if showingLiabilityDetails {
                        Text("Liability breakdown details would appear here")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                // Testing: Core Data Integration Status
                VStack(alignment: .leading, spacing: 8) {
                    Text("Integration Status")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Circle()
                            .fill(viewModel.isLoading ? Color.orange : Color.green)
                            .frame(width: 12, height: 12)
                        
                        Text(viewModel.isLoading ? "Loading..." : "Data Loaded")
                            .font(.caption)
                    }
                    
                    Text("Asset Categories: \(viewModel.assetCategories.count) items")
                        .font(.caption)
                    
                    Text("Liability Types: \(viewModel.liabilityTypes.count) items")
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationTitle("Net Wealth (Testing)")
        .refreshable {
            viewModel.refreshData()
        }
        .onAppear {
            // EMERGENCY FIX: Removed Task block - immediate execution
        viewModel.loadDashboardData()
        }
        .accessibilityIdentifier("NetWealthDashboardTesting")
    }
}

// MARK: - Preview Provider

#Preview {
    NavigationView {
        NetWealthDashboardView()
    }
    .preferredColorScheme(.dark)
}