//
// WealthDashboardView.swift
// FinanceMate
//
// P4-001 Wealth Dashboards Implementation - Interactive Portfolio Visualization
// Created: 2025-07-11
// Target: FinanceMate
//

/*
 * Purpose: Comprehensive wealth dashboard UI with interactive portfolio charts and glassmorphism styling
 * Issues & Complexity Summary: Complex Charts framework integration with portfolio analytics and responsive design
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~850
   - Core Algorithm Complexity: Medium (UI logic, chart interactions, responsive layout)
   - Dependencies: WealthDashboardViewModel, Charts framework, SwiftUI
   - State Management Complexity: High (chart interactions, time range selection, portfolio details)
   - Novelty/Uncertainty Factor: Medium (Charts framework patterns, glassmorphism integration)
 * AI Pre-Task Self-Assessment: 88%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: [TBD]
 * Overall Result Score: [TBD]
 * Key Variances/Learnings: [TBD]
 * Last Updated: 2025-07-11
 */

import SwiftUI
import Charts

struct WealthDashboardView: View {
    
    @StateObject private var viewModel: WealthDashboardViewModel
    @State private var selectedTimeRange: WealthDashboardViewModel.TimeRange = .sixMonths
    @State private var showingPortfolioDetail: Bool = false
    @State private var selectedAssetType: String?
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext, portfolioManager: PortfolioManager) {
        self._viewModel = StateObject(wrappedValue: WealthDashboardViewModel(
            context: context,
            portfolioManager: portfolioManager,
            analyticsEngine: AnalyticsEngine()
        ))
    }
    
    // MARK: - Main View
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Wealth Overview Header
                    wealthOverviewSection
                    
                    // Time Range Selector
                    timeRangeSelectorSection
                    
                    // Portfolio Performance Chart
                    portfolioPerformanceSection
                    
                    // Asset Allocation Charts
                    assetAllocationSection
                    
                    // Portfolio Summaries
                    portfolioSummariesSection
                    
                    // Top Performing Investments
                    topPerformersSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(dashboardBackground)
        .navigationTitle("Wealth Dashboard")
        .onAppear {
            Task {
                await viewModel.loadWealthData()
            }
        }
        .refreshable {
            await viewModel.refreshWealthData()
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Retry") {
                Task {
                    await viewModel.loadWealthData()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showingPortfolioDetail) {
            if let selectedPortfolio = viewModel.selectedPortfolio {
                PortfolioDetailView(portfolioId: selectedPortfolio)
            }
        }
    }
    
    // MARK: - Wealth Overview Section
    
    private var wealthOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Net Worth")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formattedCurrency(viewModel.totalNetWorth))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Portfolio Return")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.overallPortfolioReturn >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(viewModel.overallPortfolioReturn >= 0 ? .green : .red)
                            .font(.caption)
                        
                        Text(viewModel.formattedCurrency(viewModel.overallPortfolioReturn))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.overallPortfolioReturn >= 0 ? .green : .red)
                    }
                }
            }
            
            // Wealth Breakdown
            HStack(spacing: 20) {
                WealthMetricCard(
                    title: "Investments",
                    value: viewModel.formattedCurrency(viewModel.totalInvestments),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                WealthMetricCard(
                    title: "Liquid Assets",
                    value: viewModel.formattedCurrency(viewModel.totalLiquidAssets),
                    icon: "banknote",
                    color: .green
                )
                
                WealthMetricCard(
                    title: "Liabilities",
                    value: viewModel.formattedCurrency(viewModel.totalLiabilities),
                    icon: "minus.circle",
                    color: .red
                )
            }
        }
        .modifier(GlassmorphismModifier(.primary))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Net Worth: \(viewModel.formattedCurrency(viewModel.totalNetWorth))")
    }
    
    // MARK: - Time Range Selector
    
    private var timeRangeSelectorSection: some View {
        HStack {
            Text("Performance Period")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(WealthDashboardViewModel.TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue)
                        .tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 300)
        }
        .padding(.horizontal, 16)
        .onChange(of: selectedTimeRange) { newRange in
            Task {
                await viewModel.updateTimeRange(newRange)
            }
        }
    }
    
    // MARK: - Portfolio Performance Chart
    
    private var portfolioPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portfolio Performance")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !viewModel.portfolioPerformanceData.isEmpty {
                portfolioPerformanceChart
            } else {
                emptyChartState
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    private var portfolioPerformanceChart: some View {
        Chart(viewModel.portfolioPerformanceData) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Value", dataPoint.portfolioValue)
            )
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 3))
            
            AreaMark(
                x: .value("Date", dataPoint.date),
                y: .value("Value", dataPoint.portfolioValue)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 250)
        .chartBackground { chartProxy in
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.2)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatCurrencyCompact(doubleValue))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(0.3))
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel {
                    if let dateValue = value.as(Date.self) {
                        Text(dateValue, format: .dateTime.month(.abbreviated).day())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                AxisGridLine()
                    .foregroundStyle(.secondary.opacity(0.3))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Portfolio performance chart over \(selectedTimeRange.title)")
    }
    
    // MARK: - Asset Allocation Section
    
    private var assetAllocationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Asset Allocation")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                // Pie Chart
                if !viewModel.assetAllocationData.isEmpty {
                    assetAllocationChart
                        .frame(width: 200, height: 200)
                }
                
                Spacer()
                
                // Legend
                assetAllocationLegend
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    private var assetAllocationChart: some View {
        Chart(viewModel.assetAllocationData) { allocation in
            SectorMark(
                angle: .value("Value", allocation.value),
                innerRadius: .ratio(0.4),
                angularInset: 2
            )
            .foregroundStyle(allocation.color)
            .opacity(selectedAssetType == nil || selectedAssetType == allocation.assetType ? 1.0 : 0.5)
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotAreaFrame]
                VStack {
                    Text("Portfolio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Distribution")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
        .onTapGesture { location in
            // Handle tap to highlight asset type
            // This would require more complex chart interaction logic
        }
    }
    
    private var assetAllocationLegend: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.assetAllocationData) { allocation in
                HStack(spacing: 12) {
                    Circle()
                        .fill(allocation.color)
                        .frame(width: 12, height: 12)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(allocation.assetType)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(viewModel.formattedCurrency(allocation.value))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("(\(viewModel.formattedPercentage(allocation.percentage * 100)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .onTapGesture {
                    selectedAssetType = selectedAssetType == allocation.assetType ? nil : allocation.assetType
                }
            }
        }
    }
    
    // MARK: - Portfolio Summaries Section
    
    private var portfolioSummariesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portfolio Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.portfolioSummaries) { portfolio in
                    PortfolioSummaryCard(portfolio: portfolio) {
                        viewModel.selectPortfolio(portfolio.id)
                    }
                }
            }
        }
        .modifier(GlassmorphismModifier(.minimal))
    }
    
    // MARK: - Top Performers Section
    
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performing Investments")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(viewModel.topPerformingInvestments.prefix(5))) { investment in
                    InvestmentPerformanceRow(investment: investment)
                }
            }
        }
        .modifier(GlassmorphismModifier(.minimal))
    }
    
    // MARK: - Supporting Views
    
    private var dashboardBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading wealth data...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var emptyChartState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No performance data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start investing to see your portfolio performance")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        
        if amount >= 1_000_000 {
            formatter.positiveSuffix = "M"
            return formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "A$0M"
        } else if amount >= 1_000 {
            formatter.positiveSuffix = "K"
            return formatter.string(from: NSNumber(value: amount / 1_000)) ?? "A$0K"
        } else {
            return formatter.string(from: NSNumber(value: amount)) ?? "A$0"
        }
    }
}

// MARK: - Supporting Components

struct WealthMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PortfolioSummaryCard: View {
    let portfolio: WealthDashboardViewModel.PortfolioSummary
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(portfolio.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Value")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(NumberFormatter.currency.string(from: NSNumber(value: portfolio.totalValue)) ?? "A$0")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Return:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(portfolio.returnPercentage, specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(portfolio.returnPercentage >= 0 ? .green : .red)
                
                Spacer()
            }
        }
        .padding(16)
        .modifier(GlassmorphismModifier(.minimal))
        .onTapGesture(perform: onTap)
    }
}

struct InvestmentPerformanceRow: View {
    let investment: WealthDashboardViewModel.InvestmentPerformance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(investment.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(investment.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(NumberFormatter.currency.string(from: NSNumber(value: investment.currentValue)) ?? "A$0")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(investment.returnPercentage, specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(investment.returnPercentage >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}

struct PortfolioDetailView: View {
    let portfolioId: UUID
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Portfolio Detail View")
                    .font(.title)
                Text("Portfolio ID: \(portfolioId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Portfolio Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - NumberFormatter Extension

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_AU")
        formatter.currencyCode = "AUD"
        return formatter
    }()
}

// MARK: - Preview

struct WealthDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        WealthDashboardView(
            context: PersistenceController.preview.container.viewContext,
            portfolioManager: PortfolioManager(context: PersistenceController.preview.container.viewContext)
        )
        .previewDisplayName("Wealth Dashboard")
    }
}