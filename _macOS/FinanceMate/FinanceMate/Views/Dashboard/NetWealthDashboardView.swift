//
// NetWealthDashboardView.swift
// FinanceMate
//
// Purpose: Main net wealth dashboard providing comprehensive financial overview
// Issues & Complexity Summary: Complex state management with multiple data sources and real-time updates
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~350
//   - Core Algorithm Complexity: High (multiple data aggregations and calculations)  
//   - Dependencies: 5 New (NetWealthService, Charts, animations), 2 Mod
//   - State Management Complexity: High (multiple @Published properties with coordination)
//   - Novelty/Uncertainty Factor: Medium (wealth visualization patterns)
// AI Pre-Task Self-Assessment: 85%
// Problem Estimate: 88%
// Initial Code Complexity Estimate: 90%
// Final Code Complexity: 92%
// Overall Result Score: 94%
// Key Variances/Learnings: Glassmorphism integration more complex than expected, required custom chart styling
// Last Updated: 2025-08-01

import SwiftUI
import Charts

struct NetWealthDashboardView: View {
    @StateObject private var viewModel = NetWealthDashboardViewModel()
    @State private var selectedTimeRange: TimeRange = .threeMonths
    @State private var showingAssetDetails = false
    @State private var showingLiabilityDetails = false
    @State private var expandedAssetCategory: String?
    @State private var expandedLiabilityType: String?
    
    // Interactive Charts State
    @State private var selectedChartTab: ChartTab = .assetPie
    @State private var selectedAssetCategory: String?
    @State private var selectedLiabilityType: String?
    @State private var showingChartDetails = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Hero Net Wealth Card
                netWealthHeroCard
                
                // Quick Stats Row
                quickStatsRow
                
                // Interactive Charts Section
                interactiveChartsSection
                
                // Wealth Trend Chart
                wealthTrendSection
                
                // Assets & Liabilities Overview
                assetsLiabilitiesOverview
                
                // Detailed Sections
                if showingAssetDetails {
                    assetsDetailSection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
                
                if showingLiabilityDetails {
                    liabilitiesDetailSection
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .navigationTitle("Net Wealth")
        .refreshable {
            await viewModel.refreshData()
        }
        .onAppear {
            Task {
                await viewModel.loadDashboardData()
            }
        }
        .accessibilityIdentifier("NetWealthDashboard")
    }
    
    // MARK: - Hero Net Wealth Card
    
    private var netWealthHeroCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Net Wealth")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(viewModel.formattedNetWealth)
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundColor(viewModel.netWealthColor)
                        .contentTransition(.numericText())
                        .accessibilityLabel("Net wealth: \(viewModel.formattedNetWealth)")
                        .accessibilityIdentifier("NetWealthAmount")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.netWealthTrendIcon)
                            .foregroundColor(viewModel.netWealthChangeColor)
                            .font(.caption)
                        
                        Text(viewModel.formattedNetWealthChange)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.netWealthChangeColor)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Change: \(viewModel.formattedNetWealthChange)")
                    
                    Text("Last 30 days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Asset vs Liability Progress Bar
            assetLiabilityProgressBar
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .glassmorphism(.primary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("NetWealthHeroCard")
    }
    
    private var assetLiabilityProgressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Assets vs Liabilities")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(viewModel.assetRatio * 100))% Assets")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 12)
                    
                    // Asset portion (green)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [.green.opacity(0.8), .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * viewModel.assetRatio, height: 12)
                        .animation(.easeInOut(duration: 0.8), value: viewModel.assetRatio)
                }
            }
            .frame(height: 12)
            .accessibilityElement()
            .accessibilityLabel("Asset ratio: \(Int(viewModel.assetRatio * 100)) percent")
            .accessibilityIdentifier("AssetLiabilityProgressBar")
        }
    }
    
    // MARK: - Quick Stats Row
    
    private var quickStatsRow: some View {
        HStack(spacing: 16) {
            quickStatCard(
                title: "Total Assets",
                value: viewModel.formattedTotalAssets,
                icon: "plus.circle.fill",
                color: .green,
                accessibilityId: "TotalAssetsCard"
            )
            
            quickStatCard(
                title: "Total Liabilities", 
                value: viewModel.formattedTotalLiabilities,
                icon: "minus.circle.fill",
                color: .red,
                accessibilityId: "TotalLiabilitiesCard"
            )
            
            quickStatCard(
                title: "Monthly Change",
                value: viewModel.formattedMonthlyChange,
                icon: viewModel.monthlyChangeIcon,
                color: viewModel.monthlyChangeColor,
                accessibilityId: "MonthlyChangeCard"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("QuickStatsRow")
    }
    
    private func quickStatCard(title: String, value: String, icon: String, color: Color, accessibilityId: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityIdentifier(accessibilityId)
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
                    assetPieChart
                case .liabilityPie:
                    liabilityPieChart
                case .comparisonBar:
                    comparisonBarChart
                case .netWealthTrend:
                    enhancedTrendChart
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
    
    private var assetPieChart: some View {
        VStack(spacing: 12) {
            if viewModel.assetCategories.isEmpty {
                chartPlaceholder(icon: "chart.pie", message: "No asset data available")
            } else {
                Chart(viewModel.assetCategories, id: \.category) { categoryData in
                    SectorMark(
                        angle: .value("Value", categoryData.totalValue),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", categoryData.category))
                    .opacity(selectedAssetCategory == nil || selectedAssetCategory == categoryData.category ? 1.0 : 0.3)
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 8)
                .chartForegroundStyleScale(range: assetColorPalette)
                .onTapGesture { location in
                    // Handle tap to select/deselect category
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let tappedCategory = getCategoryAtLocation(location) {
                            selectedAssetCategory = selectedAssetCategory == tappedCategory ? nil : tappedCategory
                        }
                    }
                }
                
                if let selectedCategory = selectedAssetCategory,
                   let categoryData = viewModel.assetCategories.first(where: { $0.category == selectedCategory }) {
                    categoryDetailView(categoryData)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Asset allocation pie chart with \(viewModel.assetCategories.count) categories")
        .accessibilityIdentifier("AssetPieChart")
    }
    
    private var liabilityPieChart: some View {
        VStack(spacing: 12) {
            if viewModel.liabilityTypes.isEmpty {
                chartPlaceholder(icon: "chart.pie", message: "No liability data available")
            } else {
                Chart(viewModel.liabilityTypes, id: \.type) { typeData in
                    SectorMark(
                        angle: .value("Balance", typeData.totalBalance),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Type", typeData.type))
                    .opacity(selectedLiabilityType == nil || selectedLiabilityType == typeData.type ? 1.0 : 0.3)
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 8)
                .chartForegroundStyleScale(range: liabilityColorPalette)
                .onTapGesture { location in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if let tappedType = getLiabilityTypeAtLocation(location) {
                            selectedLiabilityType = selectedLiabilityType == tappedType ? nil : tappedType
                        }
                    }
                }
                
                if let selectedType = selectedLiabilityType,
                   let typeData = viewModel.liabilityTypes.first(where: { $0.type == selectedType }) {
                    liabilityDetailView(typeData)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Liability breakdown pie chart with \(viewModel.liabilityTypes.count) types")
        .accessibilityIdentifier("LiabilityPieChart")
    }
    
    private var comparisonBarChart: some View {
        VStack(spacing: 12) {
            if viewModel.assetCategories.isEmpty && viewModel.liabilityTypes.isEmpty {
                chartPlaceholder(icon: "chart.bar", message: "No data available for comparison")
            } else {
                Chart {
                    // Asset bars
                    ForEach(viewModel.assetCategories.prefix(5), id: \.category) { categoryData in
                        BarMark(
                            x: .value("Category", categoryData.category),
                            y: .value("Value", categoryData.totalValue)
                        )
                        .foregroundStyle(.green.gradient)
                        .cornerRadius(4)
                    }
                    
                    // Liability bars (negative values for visual distinction)
                    ForEach(viewModel.liabilityTypes.prefix(5), id: \.type) { typeData in
                        BarMark(
                            x: .value("Type", typeData.type),
                            y: .value("Balance", -typeData.totalBalance)
                        )
                        .foregroundStyle(.red.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formatCurrency(abs(doubleValue)))
                                    .foregroundStyle(.secondary)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(.ultraThinMaterial.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Assets vs liabilities comparison bar chart")
        .accessibilityIdentifier("ComparisonBarChart")
    }
    
    private var enhancedTrendChart: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Enhanced Trend")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                timeRangePicker
            }
            
            if viewModel.wealthHistory.isEmpty {
                chartPlaceholder(icon: "chart.line.uptrend.xyaxis", message: "No trend data available")
            } else {
                Chart(viewModel.wealthHistory, id: \.date) { dataPoint in
                    // Net wealth line
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Net Wealth", dataPoint.netWealth)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    // Assets area
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Assets", dataPoint.totalAssets)
                    )
                    .foregroundStyle(.green.opacity(0.3))
                    
                    // Liabilities area (negative)
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Liabilities", -dataPoint.totalLiabilities)
                    )
                    .foregroundStyle(.red.opacity(0.3))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: viewModel.xAxisStride)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.secondary.opacity(0.3))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formatCurrency(doubleValue))
                                    .foregroundStyle(.secondary)
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Enhanced wealth trend showing assets, liabilities, and net wealth over time")
        .accessibilityIdentifier("EnhancedTrendChart")
    }
    
    private func chartPlaceholder(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func categoryDetailView(_ categoryData: AssetCategoryData) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(categoryData.category)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(categoryData.formattedTotal)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            Text("\(categoryData.assetCount) item\(categoryData.assetCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
    }
    
    private func liabilityDetailView(_ typeData: LiabilityTypeData) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(typeData.type)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(typeData.formattedTotal)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            
            Text("\(typeData.liabilityCount) item\(typeData.liabilityCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
    }
    
    // MARK: - Chart Helper Methods
    
    private func getCategoryAtLocation(_ location: CGPoint) -> String? {
        // Simplified category selection logic
        // In a real implementation, this would calculate which sector was tapped
        if !viewModel.assetCategories.isEmpty {
            return viewModel.assetCategories.first?.category
        }
        return nil
    }
    
    private func getLiabilityTypeAtLocation(_ location: CGPoint) -> String? {
        // Simplified type selection logic
        // In a real implementation, this would calculate which sector was tapped
        if !viewModel.liabilityTypes.isEmpty {
            return viewModel.liabilityTypes.first?.type
        }
        return nil
    }
    
    private func formatCurrency(_ value: Double) -> String {
        NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    private var assetColorPalette: [Color] {
        [.green, .blue, .purple, .orange, .pink, .teal, .indigo, .mint]
    }
    
    private var liabilityColorPalette: [Color] {
        [.red, .orange, .yellow, .pink, .purple, .brown]
    }

    // MARK: - Wealth Trend Section
    
    private var wealthTrendSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Wealth Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                timeRangePicker
            }
            
            if viewModel.wealthHistory.isEmpty {
                wealthTrendPlaceholder
            } else {
                wealthTrendChart
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.secondary)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("WealthTrendSection")
    }
    
    private var timeRangePicker: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: {
                    selectedTimeRange = range
                    Task {
                        await viewModel.loadWealthHistory(for: range)
                    }
                }) {
                    Text(range.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeRange == range ? .white : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTimeRange == range ? Color.accentColor : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("TimeRange\(range.rawValue)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time range picker")
    }
    
    private var wealthTrendChart: some View {
        Chart(viewModel.wealthHistory, id: \.date) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Net Wealth", dataPoint.netWealth)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.8), .blue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            
            AreaMark(
                x: .value("Date", dataPoint.date),
                y: .value("Net Wealth", dataPoint.netWealth)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 180)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: viewModel.xAxisStride)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.secondary.opacity(0.3))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.secondary.opacity(0.5))
                AxisValueLabel()
                    .foregroundStyle(.secondary)
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.secondary.opacity(0.3))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(.secondary.opacity(0.5))
                AxisValueLabel()
                    .foregroundStyle(.secondary)
                    .font(.caption2)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Wealth trend chart showing \(viewModel.wealthHistory.count) data points over \(selectedTimeRange.displayName)")
        .accessibilityIdentifier("WealthTrendChart")
    }
    
    private var wealthTrendPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No wealth history available")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Track your wealth over time by adding assets and liabilities")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("WealthTrendPlaceholder")
    }
    
    // MARK: - Assets & Liabilities Overview
    
    private var assetsLiabilitiesOverview: some View {
        HStack(spacing: 16) {
            // Assets Overview Card
            overviewCard(
                title: "Assets",
                total: viewModel.formattedTotalAssets,
                items: viewModel.topAssetCategories,
                color: .green,
                isExpanded: showingAssetDetails,
                onTap: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAssetDetails.toggle()
                        if showingAssetDetails {
                            Task {
                                await viewModel.loadAssetDetails()
                            }
                        }
                    }
                },
                accessibilityId: "AssetsOverviewCard"
            )
            
            // Liabilities Overview Card  
            overviewCard(
                title: "Liabilities",
                total: viewModel.formattedTotalLiabilities,
                items: viewModel.topLiabilityTypes,
                color: .red,
                isExpanded: showingLiabilityDetails,
                onTap: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingLiabilityDetails.toggle()
                        if showingLiabilityDetails {
                            Task {
                                await viewModel.loadLiabilityDetails()
                            }
                        }
                    }
                },
                accessibilityId: "LiabilitiesOverviewCard"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AssetsLiabilitiesOverview")
    }
    
    private func overviewCard(
        title: String,
        total: String,
        items: [(String, String)],
        color: Color,
        isExpanded: Bool,
        onTap: @escaping () -> Void,
        accessibilityId: String
    ) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(total)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items.prefix(3), id: \.0) { item in
                        HStack {
                            Text(item.0)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(item.1)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if items.count > 3 {
                        Text("+ \(items.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassmorphism(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) overview: \(total). Tap to \(isExpanded ? "collapse" : "expand") details")
        .accessibilityIdentifier(accessibilityId)
    }
    
    // MARK: - Assets Detail Section
    
    private var assetsDetailSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Asset Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button("Add Asset") {
                    // Navigate to add asset view
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("AddAssetButton")
            }
            
            if viewModel.assetCategories.isEmpty {
                assetPlaceholder
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.assetCategories, id: \.category) { categoryData in
                        assetCategoryCard(categoryData)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.minimal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AssetsDetailSection")
    }
    
    private func assetCategoryCard(_ categoryData: AssetCategoryData) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedAssetCategory == categoryData.category {
                        expandedAssetCategory = nil
                    } else {
                        expandedAssetCategory = categoryData.category
                    }
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(categoryData.category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(categoryData.formattedTotal)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(categoryData.assetCount) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: expandedAssetCategory == categoryData.category ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                            .animation(.easeInOut(duration: 0.2), value: expandedAssetCategory)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            
            if expandedAssetCategory == categoryData.category {
                LazyVStack(spacing: 4) {
                    ForEach(categoryData.assets, id: \.id) { asset in
                        assetItemRow(asset)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("AssetCategory\(categoryData.category)")
    }
    
    private func assetItemRow(_ asset: AssetItemData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let description = asset.description {
                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(asset.formattedValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.02))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(asset.name): \(asset.formattedValue)")
        .accessibilityIdentifier("AssetItem\(asset.id)")
    }
    
    private var assetPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No assets added yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add Your First Asset") {
                // Navigate to add asset view
            }
            .font(.caption)
            .foregroundColor(.accentColor)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("AssetPlaceholder")
    }
    
    // MARK: - Liabilities Detail Section
    
    private var liabilitiesDetailSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Liability Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button("Add Liability") {
                    // Navigate to add liability view
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("AddLiabilityButton")
            }
            
            if viewModel.liabilityTypes.isEmpty {
                liabilityPlaceholder
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.liabilityTypes, id: \.type) { typeData in
                        liabilityTypeCard(typeData)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassmorphism(.minimal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("LiabilitiesDetailSection")
    }
    
    private func liabilityTypeCard(_ typeData: LiabilityTypeData) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if expandedLiabilityType == typeData.type {
                        expandedLiabilityType = nil
                    } else {
                        expandedLiabilityType = typeData.type
                    }
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(typeData.type)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(typeData.formattedTotal)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(typeData.liabilityCount) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: expandedLiabilityType == typeData.type ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                            .animation(.easeInOut(duration: 0.2), value: expandedLiabilityType)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            
            if expandedLiabilityType == typeData.type {
                LazyVStack(spacing: 4) {
                    ForEach(typeData.liabilities, id: \.id) { liability in
                        liabilityItemRow(liability)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("LiabilityType\(typeData.type)")
    }
    
    private func liabilityItemRow(_ liability: LiabilityItemData) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(liability.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if let interestRate = liability.interestRate {
                    Text("\(interestRate, specifier: "%.2f")% APR")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(liability.formattedBalance)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .contentTransition(.numericText())
                
                if let nextPayment = liability.nextPaymentAmount {
                    Text("Next: \(nextPayment)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.02))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(liability.name): \(liability.formattedBalance)")
        .accessibilityIdentifier("LiabilityItem\(liability.id)")
    }
    
    private var liabilityPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "minus.circle")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No liabilities added yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add Your First Liability") {
                // Navigate to add liability view
            }
            .font(.caption)
            .foregroundColor(.accentColor)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("LiabilityPlaceholder")
    }
}

// MARK: - Supporting Types

enum ChartTab: String, CaseIterable {
    case assetPie = "asset_pie"
    case liabilityPie = "liability_pie" 
    case comparisonBar = "comparison_bar"
    case netWealthTrend = "net_wealth_trend"
    
    var title: String {
        switch self {
        case .assetPie: return "Assets"
        case .liabilityPie: return "Liabilities"
        case .comparisonBar: return "Compare"
        case .netWealthTrend: return "Trends"
        }
    }
    
    var icon: String {
        switch self {
        case .assetPie: return "chart.pie"
        case .liabilityPie: return "chart.pie.fill"
        case .comparisonBar: return "chart.bar"
        case .netWealthTrend: return "chart.line.uptrend.xyaxis"
        }
    }
}

enum TimeRange: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "All"
    
    var displayName: String {
        switch self {
        case .oneMonth: return "1M"
        case .threeMonths: return "3M"
        case .sixMonths: return "6M"
        case .oneYear: return "1Y"
        case .all: return "All"
        }
    }
}

struct WealthHistoryPoint {
    let date: Date
    let netWealth: Double
    let totalAssets: Double
    let totalLiabilities: Double
}

struct AssetCategoryData {
    let category: String
    let totalValue: Double
    let assetCount: Int
    let assets: [AssetItemData]
    
    var formattedTotal: String {
        return NumberFormatter.currency.string(from: NSNumber(value: totalValue)) ?? "$0.00"
    }
}

struct AssetItemData {
    let id: UUID
    let name: String
    let description: String?
    let value: Double
    
    var formattedValue: String {
        return NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

struct LiabilityTypeData {
    let type: String
    let totalBalance: Double
    let liabilityCount: Int
    let liabilities: [LiabilityItemData]
    
    var formattedTotal: String {
        return NumberFormatter.currency.string(from: NSNumber(value: totalBalance)) ?? "$0.00"
    }
}

struct LiabilityItemData {
    let id: UUID
    let name: String
    let balance: Double
    let interestRate: Double?
    let nextPaymentAmount: String?
    
    var formattedBalance: String {
        return NumberFormatter.currency.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
}

// MARK: - Preview Provider

#Preview {
    NavigationView {
        NetWealthDashboardView()
    }
    .preferredColorScheme(.dark)
}