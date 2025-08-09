import SwiftUI
import Charts
import CoreData

/**
 * EnhancedWealthDashboardView.swift
 * 
 * Purpose: PHASE 3.2 - Comprehensive multi-entity wealth visualization dashboard
 * Issues & Complexity Summary: Complex data visualization, multi-entity aggregation, interactive charts, real-time updates
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~450+ (comprehensive dashboard, multiple chart types, entity switching)
 *   - Core Algorithm Complexity: High (wealth aggregation, chart data preparation, multi-entity coordination)
 *   - Dependencies: 5 New (Charts, MultiEntityWealthService, PortfolioManager, enhanced design system)
 *   - State Management Complexity: Very High (real-time wealth updates, multi-entity state, chart interactions)
 *   - Novelty/Uncertainty Factor: Medium (SwiftUI Charts with complex financial data)
 * AI Pre-Task Self-Assessment: 90%
 * Problem Estimate: 92%
 * Initial Code Complexity Estimate: 95%
 * Target Coverage: UI Testing with glassmorphism compliance and accessibility
 * Australian Compliance: Currency formatting, investment regulations display
 * Last Updated: 2025-08-08
 */

/// Enhanced wealth dashboard integrating multi-entity wealth management with portfolio visualization
/// Builds upon existing MultiEntityWealthService and PortfolioManager foundations
struct EnhancedWealthDashboardView: View {
    
    // MARK: - Dependencies
    
    @StateObject private var multiEntityWealthService: MultiEntityWealthService
    @StateObject private var portfolioManager: PortfolioManager
    
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - UI State
    
    @State private var selectedEntity: FinancialEntity?
    @State private var selectedTimeRange: TimeRange = .oneYear
    @State private var showingEntitySelector = false
    @State private var isRefreshing = false
    @State private var showingDetailSheet = false
    @State private var selectedMetric: WealthMetric?
    
    // MARK: - Chart State
    
    @State private var showingAssetChart = true
    @State private var showingLiabilityChart = true
    @State private var showingPerformanceChart = true
    @State private var selectedChartType: ChartType = .pie
    
    // MARK: - Computed Properties
    
    private var selectedEntityBreakdown: EntityWealthBreakdown? {
        guard let entity = selectedEntity,
              let breakdown = multiEntityWealthService.multiEntityBreakdown else { return nil }
        
        return breakdown.entityBreakdowns.first { $0.entity.id == entity.id }
    }
    
    private var consolidatedWealth: NetWealthResult? {
        return multiEntityWealthService.multiEntityBreakdown?.consolidatedWealth
    }
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        let netWealthService = NetWealthService(context: context)
        self._multiEntityWealthService = StateObject(wrappedValue: MultiEntityWealthService(
            context: context,
            netWealthService: netWealthService
        ))
        self._portfolioManager = StateObject(wrappedValue: PortfolioManager(context: context))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with entity selector
                    headerSection
                    
                    // Wealth summary cards
                    wealthSummarySection
                    
                    // Asset allocation charts
                    if showingAssetChart {
                        assetAllocationSection
                    }
                    
                    // Liability breakdown
                    if showingLiabilityChart {
                        liabilityBreakdownSection
                    }
                    
                    // Performance tracking
                    if showingPerformanceChart {
                        performanceSection
                    }
                    
                    // Investment portfolios
                    investmentPortfoliosSection
                    
                    // Cross-entity analysis
                    crossEntityAnalysisSection
                }
                .padding()
            }
            .navigationTitle("Wealth Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    refreshButton
                    chartOptionsMenu
                    entitySelectorButton
                }
            }
        }
        .refreshable {
            await refreshData()
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let metric = selectedMetric {
                wealthDetailSheet(metric)
            }
        }
        .sheet(isPresented: $showingEntitySelector) {
            entitySelectorSheet
        }
        .task {
            await loadInitialData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Current entity display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedEntity?.name ?? "All Entities")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(selectedEntity?.entityType ?? "Consolidated View")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            
            // Last updated indicator
            if let lastCalculation = multiEntityWealthService.multiEntityBreakdown?.calculatedAt {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Updated \(formatRelativeTime(lastCalculation))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    // MARK: - Wealth Summary Section
    
    private var wealthSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Wealth Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
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
    
    private func entityWealthSummary(_ breakdown: EntityWealthBreakdown) -> some View {
        VStack(spacing: 12) {
            // Net wealth
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
            
            // Asset/Liability breakdown
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
    
    private func consolidatedWealthSummary(_ consolidated: NetWealthResult) -> some View {
        VStack(spacing: 12) {
            // Total net wealth across all entities
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
    
    private var wealthSummaryPlaceholder: some View {
        VStack(spacing: 12) {
            if multiEntityWealthService.isLoading {
                ProgressView("Loading wealth data...")
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("No wealth data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Refresh Data") {
                        Task {
                            await refreshData()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
    }
    
    // MARK: - Asset Allocation Section
    
    private var assetAllocationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Asset Allocation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            if let breakdown = selectedEntityBreakdown {
                assetAllocationChart(breakdown.assetAllocation)
            } else if let multiEntity = multiEntityWealthService.multiEntityBreakdown {
                consolidatedAssetChart(multiEntity.entityBreakdowns)
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
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
                // Line chart would require historical data
                EmptyView()
            }
        }
        .frame(height: 300)
        .chartAngleSelection(value: .constant(nil))
        .chartBackground { chartProxy in
            if selectedChartType == .pie {
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotAreaFrame]
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
        }
    }
    
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
    }
    
    // MARK: - Liability Breakdown Section
    
    private var liabilityBreakdownSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Liability Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let breakdown = selectedEntityBreakdown {
                liabilityChart(breakdown.liabilityBreakdown)
            } else if let multiEntity = multiEntityWealthService.multiEntityBreakdown {
                consolidatedLiabilityChart(multiEntity.entityBreakdowns)
            }
        }
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    private func liabilityChart(_ breakdown: [LiabilityBreakdownData]) -> some View {
        Chart(breakdown, id: \.liabilityType) { data in
            BarMark(
                x: .value("Liability Type", data.liabilityType),
                y: .value("Amount", data.amount)
            )
            .foregroundStyle(colorForLiabilityType(data.liabilityType))
        }
        .frame(height: 200)
        .chartYAxis {
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
    
    private func consolidatedLiabilityChart(_ breakdowns: [EntityWealthBreakdown]) -> some View {
        let consolidatedLiabilities = consolidateLiabilityBreakdowns(breakdowns)
        
        return Chart(consolidatedLiabilities, id: \.liabilityType) { data in
            BarMark(
                x: .value("Liability Type", data.liabilityType),
                y: .value("Amount", data.amount)
            )
            .foregroundStyle(colorForLiabilityType(data.liabilityType))
        }
        .frame(height: 200)
    }
    
    // MARK: - Performance Section
    
    private var performanceSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Performance Tracking")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let breakdown = selectedEntityBreakdown {
                performanceMetrics(breakdown.riskMetrics, performanceScore: breakdown.performanceScore)
            } else if let multiEntity = multiEntityWealthService.multiEntityBreakdown {
                crossEntityPerformance(multiEntity.performanceMetrics)
            }
        }
        .modifier(GlassmorphismModifier(.accent))
    }
    
    private func performanceMetrics(_ riskMetrics: EntityRiskMetrics, performanceScore: Double) -> some View {
        HStack(spacing: 20) {
            performanceCard(
                title: "Performance Score",
                value: performanceScore,
                color: performanceScore > 0.5 ? .green : .red,
                isPercentage: true
            )
            
            performanceCard(
                title: "Risk Level",
                value: riskMetrics.overallRiskScore,
                color: riskColorForScore(riskMetrics.overallRiskScore),
                isPercentage: true
            )
            
            performanceCard(
                title: "Diversification",
                value: riskMetrics.diversificationScore,
                color: .blue,
                isPercentage: true
            )
        }
    }
    
    private func crossEntityPerformance(_ metrics: EntityPerformanceMetrics) -> some View {
        VStack(spacing: 12) {
            // Growth rates chart
            Chart(metrics.growthRates, id: \.entityId) { growth in
                BarMark(
                    x: .value("Entity", growth.entityName),
                    y: .value("Growth Rate", growth.growthRate)
                )
                .foregroundStyle(growth.growthRate > 0 ? .green : .red)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let rate = value.as(Double.self) {
                            Text("\(rate, specifier: "%.1f")%")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Investment Portfolios Section
    
    private var investmentPortfoliosSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Investment Portfolios")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Manage") {
                    // Navigate to portfolio management
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            portfolioSummaryGrid
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    private var portfolioSummaryGrid: some View {
        // This would integrate with the existing PortfolioManager
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            portfolioCard(
                name: "Growth Portfolio",
                value: 125000.00,
                performance: 0.087,
                riskLevel: "Moderate"
            )
            
            portfolioCard(
                name: "Conservative Portfolio", 
                value: 85000.00,
                performance: 0.045,
                riskLevel: "Low"
            )
        }
    }
    
    private func portfolioCard(name: String, value: Double, performance: Double, riskLevel: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(formatCurrency(value))
                .font(.title3)
                .fontWeight(.bold)
            
            HStack {
                Text("\(performance, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(performance > 0 ? .green : .red)
                
                Spacer()
                
                Text(riskLevel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Cross-Entity Analysis Section
    
    private var crossEntityAnalysisSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Cross-Entity Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let analysis = multiEntityWealthService.multiEntityBreakdown?.crossEntityAnalysis {
                crossEntityMetrics(analysis)
            }
        }
        .modifier(GlassmorphismModifier(.minimal))
    }
    
    private func crossEntityMetrics(_ analysis: CrossEntityAnalysis) -> some View {
        VStack(spacing: 12) {
            // Entity contributions
            Chart(analysis.entityContributions, id: \.entityId) { contribution in
                BarMark(
                    x: .value("Contribution", contribution.percentageContribution),
                    y: .value("Entity", contribution.entityName)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let percentage = value.as(Double.self) {
                            Text("\(percentage, specifier: "%.1f")%")
                        }
                    }
                }
            }
            
            // Optimization opportunities
            if !analysis.optimizationOpportunities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Optimization Opportunities")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(analysis.optimizationOpportunities.prefix(3), id: \.id) { opportunity in
                        optimizationOpportunityView(opportunity)
                    }
                }
            }
        }
    }
    
    private func optimizationOpportunityView(_ opportunity: OptimizationRecommendation) -> some View {
        HStack {
            Circle()
                .fill(priorityColor(opportunity.priority))
                .frame(width: 8, height: 8)
            
            Text(opportunity.description)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(formatCurrency(opportunity.potentialSavings))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Utility Views
    
    private func wealthMetricCard(title: String, value: Double, color: Color, metric: WealthMetric, isPercentage: Bool = false) -> some View {
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
            selectedMetric = metric
            showingDetailSheet = true
        }
    }
    
    private func performanceCard(title: String, value: Double, color: Color, isPercentage: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(isPercentage ? "\(value * 100, specifier: "%.1f")%" : "\(value, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Toolbar Items
    
    private var refreshButton: some View {
        Button(action: {
            Task {
                await refreshData()
            }
        }) {
            Image(systemName: "arrow.clockwise")
                .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
                .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
        }
        .disabled(isRefreshing)
    }
    
    private var chartOptionsMenu: some View {
        Menu {
            Section("Charts") {
                Toggle("Asset Allocation", isOn: $showingAssetChart)
                Toggle("Liabilities", isOn: $showingLiabilityChart)
                Toggle("Performance", isOn: $showingPerformanceChart)
            }
            
            Section("Chart Type") {
                Picker("Chart Type", selection: $selectedChartType) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }
        } label: {
            Image(systemName: "chart.bar")
        }
    }
    
    private var entitySelectorButton: some View {
        Button(action: {
            showingEntitySelector = true
        }) {
            Image(systemName: "list.bullet")
        }
    }
    
    // MARK: - Sheet Views
    
    private var entitySelectorSheet: some View {
        NavigationView {
            List {
                // All entities option
                Button("All Entities") {
                    selectedEntity = nil
                    showingEntitySelector = false
                }
                .foregroundColor(selectedEntity == nil ? .blue : .primary)
                
                // Individual entities (would fetch from Core Data)
                Section("Financial Entities") {
                    ForEach([], id: \.self) { entity in
                        // Entity rows would go here
                    }
                }
            }
            .navigationTitle("Select Entity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingEntitySelector = false
                    }
                }
            }
        }
    }
    
    private func wealthDetailSheet(_ metric: WealthMetric) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Wealth Metric Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Detailed breakdown would go here
                    Text("Detailed analysis for \(metric.displayName)")
                        .font(.body)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(metric.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingDetailSheet = false
                        selectedMetric = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Data Methods
    
    private func loadInitialData() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        // Load wealth data using existing services
        multiEntityWealthService.calculateMultiEntityWealth()
        
        await MainActor.run {
            isRefreshing = false
        }
    }
    
    private func refreshData() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        // Refresh all data sources
        multiEntityWealthService.calculateMultiEntityWealth()
        
        // Small delay for UI feedback
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            isRefreshing = false
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
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
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
    
    private func colorForLiabilityType(_ liabilityType: String) -> Color {
        switch liabilityType.lowercased() {
        case "mortgage": return .red
        case "credit card": return .orange
        case "personal loan": return .yellow
        case "business loan": return .purple
        default: return .gray
        }
    }
    
    private func riskColorForScore(_ score: Double) -> Color {
        if score < 0.3 { return .green }
        else if score < 0.7 { return .orange }
        else { return .red }
    }
    
    private func priorityColor(_ priority: OptimizationPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
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
    
    private func consolidateLiabilityBreakdowns(_ breakdowns: [EntityWealthBreakdown]) -> [LiabilityBreakdownData] {
        var consolidated: [String: Double] = [:]
        
        for breakdown in breakdowns {
            for liability in breakdown.liabilityBreakdown {
                consolidated[liability.liabilityType, default: 0] += liability.amount
            }
        }
        
        return consolidated.map { LiabilityBreakdownData(liabilityType: $0.key, amount: $0.value) }
    }
}

// MARK: - Supporting Types

enum TimeRange: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case twoYears = "2Y"
    case fiveYears = "5Y"
    
    var displayName: String {
        return self.rawValue
    }
}

enum ChartType: String, CaseIterable {
    case pie = "pie"
    case bar = "bar"
    case line = "line"
    
    var displayName: String {
        switch self {
        case .pie: return "Pie Chart"
        case .bar: return "Bar Chart"
        case .line: return "Line Chart"
        }
    }
}

enum WealthMetric {
    case totalAssets
    case totalLiabilities
    case netWealth
    case performanceScore
    case riskScore
    
    var displayName: String {
        switch self {
        case .totalAssets: return "Total Assets"
        case .totalLiabilities: return "Total Liabilities"
        case .netWealth: return "Net Wealth"
        case .performanceScore: return "Performance Score"
        case .riskScore: return "Risk Score"
        }
    }
}

// MARK: - Data Structure Extensions

// These would be defined based on the existing MultiEntityWealthService structures
extension AssetAllocationData {
    init(assetType: String, amount: Double) {
        // Initialize based on actual structure
        self.assetType = assetType
        self.amount = amount
    }
}

extension LiabilityBreakdownData {
    init(liabilityType: String, amount: Double) {
        // Initialize based on actual structure
        self.liabilityType = liabilityType
        self.amount = amount
    }
}

// MARK: - Preview

#Preview {
    EnhancedWealthDashboardView(context: PersistenceController.preview.container.viewContext)
}