//
// LiabilityBreakdownView.swift
// FinanceMate
//
// Purpose: Detailed liability breakdown with type cards and individual liability items
// Issues & Complexity Summary: Complex liability display with hierarchical data and interactions
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~150
//   - Core Algorithm Complexity: Medium (hierarchical data display)
//   - Dependencies: 2 (SwiftUI, NetWealthDashboardViewModel)
//   - State Management Complexity: Low (read-only display)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 90%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 87%
// Final Code Complexity: 88%
// Overall Result Score: 94%
// Key Variances/Learnings: Extracted from NetWealthDashboardView for modular architecture
// Last Updated: 2025-08-04

import SwiftUI

// MARK: - Temporary Type Definitions (until WealthDashboardModels.swift is added to build)

struct LiabilityTypeData {
    let type: String
    let totalBalance: Double
    let liabilityCount: Int
    let liabilities: [LiabilityItemData]
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: totalBalance)) ?? "A$0.00"
    }
}

struct LiabilityItemData {
    let id: UUID
    let name: String
    let balance: Double
    let interestRate: Double?
    let nextPaymentAmount: String?
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: balance)) ?? "A$0.00"
    }
}

struct LiabilityBreakdownView: View {
    @ObservedObject var viewModel: NetWealthDashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Liability Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                liabilityPlaceholder
            } else if viewModel.liabilityTypes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "minus.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No liabilities recorded")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.liabilityTypes, id: \.type) { typeData in
                        liabilityTypeCard(typeData)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("LiabilitiesDetailSection")
    }
    
    private func liabilityTypeCard(_ typeData: LiabilityTypeData) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(typeData.type)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(typeData.liabilityCount) \(typeData.liabilityCount == 1 ? "item" : "items")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(typeData.formattedTotal)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Individual liability items
            if !typeData.liabilities.isEmpty {
                VStack(spacing: 8) {
                    ForEach(typeData.liabilities, id: \.id) { liability in
                        liabilityItemRow(liability)
                    }
                }
            }
        }
        .padding(16)
        .glassmorphism(.minimal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(typeData.type): \(typeData.formattedTotal)")
        .accessibilityIdentifier("LiabilityTypeCard_\(typeData.type)")
    }
    
    private func liabilityItemRow(_ liability: LiabilityItemData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(liability.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let interestRate = liability.interestRate {
                    Text("\(String(format: "%.2f", interestRate))% APR")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(liability.formattedBalance)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                
                if let nextPayment = liability.nextPaymentAmount {
                    Text("Next: \(nextPayment)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(liability.name): \(liability.formattedBalance)")
    }
    
    private var liabilityPlaceholder: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .frame(width: 80, height: 12)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Rectangle()
                            .frame(width: 50, height: 8)
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    
                    Spacer()
                    
                    Rectangle()
                        .frame(width: 60, height: 14)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(16)
                .glassmorphism(.minimal)
            }
        }
        .redacted(reason: .placeholder)
    }
}