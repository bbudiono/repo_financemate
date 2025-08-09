import SwiftUI
import Charts

/**
 * AssetAllocationChartView.swift
 * 
 * Purpose: PHASE 3.3 - Modular asset allocation chart component (extracted from EnhancedWealthDashboardView)
 * Issues & Complexity Summary: Specialized chart display with multiple visualization types
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~150 (focused chart responsibility)
 *   - Core Algorithm Complexity: Medium (chart data preparation, multi-type visualization)
 *   - Dependencies: 3 (SwiftUI, Charts, chart data models)
 *   - State Management Complexity: Low (chart type selection, data binding)
 *   - Novelty/Uncertainty Factor: Low (established SwiftUI Charts patterns)
 * AI Pre-Task Self-Assessment: 92%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 85%
 * Target Coverage: UI Testing with chart rendering validation
 * Australian Compliance: Asset classification standards
 * Last Updated: 2025-08-08
 */

/// Modular asset allocation chart view component
/// Extracted from EnhancedWealthDashboardView to maintain <200 line rule
struct AssetAllocationChartView: View {
    
    // MARK: - Properties
    
    let entityBreakdown: EntityWealthBreakdown?
    let multiEntityBreakdowns: [EntityWealthBreakdown]?
    @Binding var selectedChartType: ChartType
    @Binding var showingChart: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with controls
            HStack {
                Text("Asset Allocation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                chartTypeSelector
            }
            
            // Chart content
            chartContent
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    // MARK: - Chart Type Selector
    
    private var chartTypeSelector: some View {
        HStack {
            Button(action: {
                showingChart.toggle()
            }) {
                Image(systemName: showingChart ? "eye" : "eye.slash")
                    .foregroundColor(.secondary)
            }
            
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    // MARK: - Chart Content
    
    @ViewBuilder
    private var chartContent: some View {
        if showingChart {
            if let breakdown = entityBreakdown {
                assetAllocationChart(breakdown.assetAllocation)
            } else if let breakdowns = multiEntityBreakdowns {
                consolidatedAssetChart(breakdowns)
            } else {
                chartPlaceholder
            }
        } else {
            Text("Chart hidden")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(height: 300)
        }
    }
    
    // MARK: - Single Entity Chart
    
    private func assetAllocationChart(_ allocation: [AssetAllocationData]) -> some View {
        Chart(allocation, id: \.assetType) { data in
            switch selectedChartType {
            case .pie:
                SectorMark(
                    angle: .value("Amount", data.amount),
                    innerRadius: .ratio(0.4)
                )
                .foregroundStyle(colorForAssetType(data.assetType))
                .opacity(0.8)
                
            case .bar:
                BarMark(
                    x: .value("Asset Type", data.assetType),
                    y: .value("Amount", data.amount)
                )
                .foregroundStyle(colorForAssetType(data.assetType))
                
            case .line:
                // Line chart requires historical data - show placeholder
                EmptyView()
            }
        }
        .frame(height: 300)
        .chartAngleSelection(value: .constant(nil))
        .chartBackground { chartProxy in
            if selectedChartType == .pie {
                pieChartCenter(allocation)
            }
        }
        .chartYAxis {
            if selectedChartType == .bar {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyShort(amount))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Consolidated Chart
    
    private func consolidatedAssetChart(_ breakdowns: [EntityWealthBreakdown]) -> some View {
        let consolidatedAssets = consolidateAssetAllocations(breakdowns)
        
        return Chart(consolidatedAssets, id: \.assetType) { data in
            SectorMark(
                angle: .value("Amount", data.amount),
                innerRadius: .ratio(0.4)
            )
            .foregroundStyle(colorForAssetType(data.assetType))
            .opacity(0.8)
        }
        .frame(height: 300)
        .chartBackground { chartProxy in
            pieChartCenter(consolidatedAssets)
        }
    }
    
    // MARK: - Pie Chart Center
    
    private func pieChartCenter(_ allocation: [AssetAllocationData]) -> some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            VStack {
                Text("Total Assets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatCurrency(allocation.reduce(0) { $0 + $1.amount }))
                    .font(.title3.bold())
                    .foregroundColor(.primary)
            }
            .position(x: frame.midX, y: frame.midY)
        }
    }
    
    // MARK: - Chart Placeholder
    
    private var chartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No asset data available")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 300)
    }
    
    // MARK: - Utility Methods
    
    private func colorForAssetType(_ assetType: String) -> Color {
        switch assetType.lowercased() {
        case "real estate": return .green
        case "stocks", "equity": return .blue
        case "bonds": return .purple
        case "cash": return .orange
        case "cryptocurrency": return .yellow
        default: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatCurrencyShort(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        
        if amount >= 1000000 {
            formatter.multiplier = 0.000001
            return (formatter.string(from: NSNumber(value: amount)) ?? "$0") + "M"
        } else if amount >= 1000 {
            formatter.multiplier = 0.001
            return (formatter.string(from: NSNumber(value: amount)) ?? "$0") + "K"
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func consolidateAssetAllocations(_ breakdowns: [EntityWealthBreakdown]) -> [AssetAllocationData] {
        var consolidated: [String: Double] = [:]
        
        for breakdown in breakdowns {
            for allocation in breakdown.assetAllocation {
                consolidated[allocation.assetType, default: 0] += allocation.amount
            }
        }
        
        return consolidated.map { AssetAllocationData(assetType: $0.key, amount: $0.value) }
    }
}

// MARK: - Preview

#Preview {
    AssetAllocationChartView(
        entityBreakdown: nil,
        multiEntityBreakdowns: nil,
        selectedChartType: .constant(.pie),
        showingChart: .constant(true)
    )
}