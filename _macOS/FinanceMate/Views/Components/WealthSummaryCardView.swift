import SwiftUI

/**
 * WealthSummaryCardView.swift
 * 
 * Purpose: PHASE 3.3 - Modular wealth summary card component (extracted from EnhancedWealthDashboardView)
 * Issues & Complexity Summary: Focused wealth metrics display with interactive capabilities
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120 (focused wealth summary responsibility)
 *   - Core Algorithm Complexity: Low (display logic, formatting, user interaction)
 *   - Dependencies: 2 (SwiftUI, glassmorphism design system)
 *   - State Management Complexity: Low (simple display state, tap interactions)
 *   - Novelty/Uncertainty Factor: Low (established UI patterns)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Target Coverage: UI Testing with accessibility compliance
 * Australian Compliance: Currency formatting (AUD)
 * Last Updated: 2025-08-08
 */

/// Modular wealth summary card view component
/// Extracted from EnhancedWealthDashboardView to maintain <200 line rule
struct WealthSummaryCardView: View {
    
    // MARK: - Properties
    
    let selectedEntityBreakdown: EntityWealthBreakdown?
    let consolidatedWealth: NetWealthResult?
    let onMetricTap: (WealthMetric) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Wealth Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Content based on data availability
            if let breakdown = selectedEntityBreakdown {
                entityWealthSummary(breakdown)
            } else if let consolidated = consolidatedWealth {
                consolidatedWealthSummary(consolidated)
            } else {
                wealthSummaryPlaceholder
            }
        }
        .modifier(GlassmorphismModifier(.accent))
    }
    
    // MARK: - Entity Wealth Summary
    
    private func entityWealthSummary(_ breakdown: EntityWealthBreakdown) -> some View {
        VStack(spacing: 12) {
            // Net wealth display
            HStack {
                Text("Net Wealth")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(formatCurrency(breakdown.netWealthResult.netWealth))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(breakdown.netWealthResult.netWealth >= 0 ? .green : .red)
            }
            
            // Metrics grid
            HStack(spacing: 20) {
                wealthMetricCard(
                    title: "Assets",
                    value: breakdown.netWealthResult.totalAssets,
                    color: .blue,
                    metric: .totalAssets
                )
                
                wealthMetricCard(
                    title: "Liabilities", 
                    value: breakdown.netWealthResult.totalLiabilities,
                    color: .orange,
                    metric: .totalLiabilities
                )
                
                wealthMetricCard(
                    title: "Performance",
                    value: breakdown.performanceScore,
                    color: .purple,
                    metric: .performanceScore,
                    isPercentage: true
                )
            }
        }
    }
    
    // MARK: - Consolidated Wealth Summary
    
    private func consolidatedWealthSummary(_ consolidated: NetWealthResult) -> some View {
        VStack(spacing: 12) {
            // Total net wealth
            HStack {
                Text("Total Net Wealth")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(formatCurrency(consolidated.netWealth))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(consolidated.netWealth >= 0 ? .green : .red)
            }
            
            // Asset/Liability totals
            HStack(spacing: 20) {
                wealthMetricCard(
                    title: "Total Assets",
                    value: consolidated.totalAssets,
                    color: .blue,
                    metric: .totalAssets
                )
                
                wealthMetricCard(
                    title: "Total Liabilities",
                    value: consolidated.totalLiabilities, 
                    color: .orange,
                    metric: .totalLiabilities
                )
            }
        }
    }
    
    // MARK: - Placeholder View
    
    private var wealthSummaryPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No wealth data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }
    
    // MARK: - Wealth Metric Card
    
    private func wealthMetricCard(
        title: String, 
        value: Double, 
        color: Color, 
        metric: WealthMetric, 
        isPercentage: Bool = false
    ) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(isPercentage ? "\(value * 100, specifier: "%.1f")%" : formatCurrency(value))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            onMetricTap(metric)
        }
    }
    
    // MARK: - Utility Methods
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview {
    WealthSummaryCardView(
        selectedEntityBreakdown: nil,
        consolidatedWealth: nil
    ) { metric in
        print("Tapped metric: \(metric)")
    }
}