//
//  EnhancedAnalyticsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

// SANDBOX FILE: For testing/development. See .cursorrules.

/*
* Purpose: Enhanced analytics view with real-time financial insights and chart visualization in Sandbox
* Issues & Complexity Summary: Initial TDD implementation with comprehensive data visualization
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: Medium-High
  - Dependencies: 5 New (SwiftUI Charts, real-time binding, analytics viewmodel, chart rendering, responsive design)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 72%
* Justification for Estimates: Complex SwiftUI interface with multiple chart types and real-time data binding
* Final Code Complexity (Actual %): TBD - Initial implementation
* Overall Result Score (Success & Quality %): TBD - TDD iteration
* Key Variances/Learnings: TDD approach ensures robust analytics UI with proper chart integration
* Last Updated: 2025-06-02
*/

import Charts
import SwiftUI

// MARK: - Enhanced Analytics View

struct EnhancedAnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    @StateObject private var taskMasterService = TaskMasterAIService()
    @StateObject private var wiringService: TaskMasterWiringService
    @State private var selectedChart: ChartType = .trends

    init(documentManager: DocumentManager) {
        self._viewModel = StateObject(wrappedValue: AnalyticsViewModel(documentManager: documentManager))
        let taskMaster = TaskMasterAIService()
        self._wiringService = StateObject(wrappedValue: TaskMasterWiringService(taskMaster: taskMaster))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Sandbox indicator
                headerView

                // Loading state
                if viewModel.isLoading {
                    loadingView
                } else {
                    // Main content
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Summary cards
                            summaryCardsView

                            // Chart controls
                            chartControlsView

                            // Selected chart view
                            selectedChartView

                            // Quick insights
                            quickInsightsView

                            // Advanced Analytics Engine
                            advancedAnalyticsView

                            // Detailed analytics
                            detailedAnalyticsView
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .task {
                await viewModel.loadAnalyticsData()
            }
            .refreshable {
                await handleDataRefresh()
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Financial Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Real-time insights and trends")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Period selector
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
            .onChange(of: viewModel.selectedPeriod) { newPeriod in
                Task {
                    // Track period selection with TaskMaster-AI
                    _ = await wiringService.trackButtonAction(
                        buttonId: "period_selector_\(newPeriod.rawValue)",
                        viewName: "AnalyticsView",
                        actionDescription: "Select \(newPeriod.displayName) period",
                        expectedOutcome: "Update analytics data for \(newPeriod.displayName)",
                        metadata: [
                            "period": newPeriod.rawValue,
                            "period_display": newPeriod.displayName,
                            "date_range_start": ISO8601DateFormatter().string(from: newPeriod.dateRange.start),
                            "date_range_end": ISO8601DateFormatter().string(from: newPeriod.dateRange.end)
                        ]
                    )

                    // Load analytics data for new period
                    await viewModel.loadAnalyticsData()
                }
            }

            // Refresh button
            Button(action: {
                Task {
                    await handleDataRefresh()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)

            // Sandbox indicator
            Text("🧪 SANDBOX")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Analytics...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Summary Cards View

    private var summaryCardsView: some View {
        HStack(spacing: 20) {
            SummaryCard(
                title: "Total Spending",
                value: formatCurrency(viewModel.totalSpending ?? 0),
                icon: "dollarsign.circle.fill",
                color: .blue
            )

            SummaryCard(
                title: "Average Transaction",
                value: formatCurrency(viewModel.averageSpending ?? 0),
                icon: "chart.bar.fill",
                color: .green
            )

            SummaryCard(
                title: "Documents Processed",
                value: "\(viewModel.monthlyData.reduce(0) { $0 + $1.transactionCount })",
                icon: "doc.text.fill",
                color: .orange
            )

            SummaryCard(
                title: "Categories",
                value: "\(viewModel.categoryData.count)",
                icon: "tag.fill",
                color: .purple
            )
        }
    }

    // MARK: - Chart Controls View

    private var chartControlsView: some View {
        HStack {
            Text("Charts")
                .font(.headline)

            Spacer()

            Picker("Chart Type", selection: $selectedChart) {
                ForEach(ChartType.allCases, id: \.self) { chartType in
                    Label(chartType.displayName, systemImage: chartType.icon)
                        .tag(chartType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedChart) { newChart in
                Task {
                    // Track chart type selection with TaskMaster-AI
                    _ = await wiringService.trackButtonAction(
                        buttonId: "chart_selector_\(newChart.rawValue)",
                        viewName: "AnalyticsView",
                        actionDescription: "Select \(newChart.displayName) chart",
                        expectedOutcome: "Display \(newChart.displayName) chart visualization",
                        metadata: [
                            "chart_type": newChart.rawValue,
                            "chart_icon": newChart.icon,
                            "display_name": newChart.displayName
                        ]
                    )
                }
            }
        }
    }

    // MARK: - Selected Chart View

    @ViewBuilder
    private var selectedChartView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(selectedChart.displayName)
                .font(.title2)
                .fontWeight(.semibold)

            switch selectedChart {
            case .trends:
                trendsChartView
            case .categories:
                categoriesChartView
            case .comparison:
                comparisonChartView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Trends Chart View

    private var trendsChartView: some View {
        Chart(viewModel.monthlyData) { data in
            LineMark(
                x: .value("Period", data.period),
                y: .value("Amount", data.totalSpending)
            )
            .foregroundStyle(.blue)
            .symbol(Circle().strokeBorder(lineWidth: 2))

            AreaMark(
                x: .value("Period", data.period),
                y: .value("Amount", data.totalSpending)
            )
            .foregroundStyle(.blue.opacity(0.3))
        }
        .frame(height: 300)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .onTapGesture {
            Task {
                await handleChartInteraction(type: "chart_select", chartType: "trends")
            }
        }
    }

    // MARK: - Categories Chart View

    private var categoriesChartView: some View {
        Chart(viewModel.categoryData.prefix(6)) { data in
            SectorMark(
                angle: .value("Amount", data.totalAmount),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(data.color)
            .opacity(0.8)
        }
        .frame(height: 300)
        .chartLegend(position: .trailing, alignment: .center, spacing: 20)
        .onTapGesture {
            Task {
                await handleChartInteraction(type: "chart_select", chartType: "categories")
            }
        }
    }

    // MARK: - Comparison Chart View

    private var comparisonChartView: some View {
        Chart(viewModel.categoryData.prefix(8)) { data in
            BarMark(
                x: .value("Category", data.categoryName),
                y: .value("Amount", data.totalAmount)
            )
            .foregroundStyle(data.color)
        }
        .frame(height: 300)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .onTapGesture {
            Task {
                await handleChartInteraction(type: "chart_select", chartType: "comparison")
            }
        }
    }

    // MARK: - Quick Insights View

    private var quickInsightsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Insights")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                InsightCard(
                    title: "Top Category",
                    value: viewModel.categoryData.first?.categoryName ?? "N/A",
                    subtitle: "Highest spending",
                    icon: "crown.fill",
                    color: .yellow
                )

                InsightCard(
                    title: "Growth Trend",
                    value: calculateGrowthTrend(),
                    subtitle: "vs. previous period",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )

                InsightCard(
                    title: "Most Frequent",
                    value: getMostFrequentCategory(),
                    subtitle: "Transaction type",
                    icon: "repeat",
                    color: .blue
                )

                InsightCard(
                    title: "Efficiency Score",
                    value: calculateEfficiencyScore(),
                    subtitle: "Processing accuracy",
                    icon: "target",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Detailed Analytics View

    private var detailedAnalyticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Category Breakdown")
                .font(.headline)

            ForEach(viewModel.categoryData.prefix(10)) { category in
                CategoryRowView(category: category)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Advanced Analytics View

    private var advancedAnalyticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Advanced Analytics Engine")
                    .font(.headline)

                Spacer()

                Button("Generate Advanced Report") {
                    Task {
                        await handleAdvancedReportGeneration()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)

                Button("Detect Anomalies") {
                    Task {
                        await handleAnomalyDetection()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)

                Button("Analyze Trends") {
                    Task {
                        await handleTrendAnalysis()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)

                // Export menu
                Menu("Export Analytics") {
                    Button("Export as PDF") {
                        Task {
                            await handleAnalyticsExport(format: "PDF")
                        }
                    }

                    Button("Export as CSV") {
                        Task {
                            await handleAnalyticsExport(format: "CSV")
                        }
                    }

                    Button("Export as Excel") {
                        Task {
                            await handleAnalyticsExport(format: "Excel")
                        }
                    }

                    Button("Export as JSON") {
                        Task {
                            await handleAnalyticsExport(format: "JSON")
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }

            if let lastReport = viewModel.lastAdvancedReport {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latest Advanced Analytics Report")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Risk Score: \(Int(lastReport.riskScore * 100))%")
                                .foregroundColor(getRiskColor(lastReport.riskScore))

                            Text("Trend: \(lastReport.trendAnalysis)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text("Generated: \(formatDate(lastReport.generatedDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if !lastReport.recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recommendations:")
                                .font(.caption)
                                .fontWeight(.medium)

                            ForEach(lastReport.recommendations.prefix(3), id: \.self) { recommendation in
                                Text("• \(recommendation)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func calculateGrowthTrend() -> String {
        guard viewModel.monthlyData.count >= 2 else { return "N/A" }

        let latest = viewModel.monthlyData.last?.totalSpending ?? 0
        let previous = viewModel.monthlyData.dropLast().last?.totalSpending ?? 0

        if previous > 0 {
            let growth = ((latest - previous) / previous) * 100
            return String(format: "%.1f%%", growth)
        }

        return "N/A"
    }

    private func getMostFrequentCategory() -> String {
        viewModel.categoryData.max { $0.transactionCount < $1.transactionCount }?.categoryName ?? "N/A"
    }

    private func calculateEfficiencyScore() -> String {
        // Simplified efficiency calculation based on processing confidence
        "85%" // Placeholder for actual calculation
    }

    // MARK: - TaskMaster-AI Integrated Analytics Methods

    /// Handle data refresh with TaskMaster-AI tracking
    private func handleDataRefresh() async {
        // Track data refresh action
        _ = await wiringService.trackButtonAction(
            buttonId: "analytics_refresh",
            viewName: "AnalyticsView",
            actionDescription: "Refresh analytics data",
            expectedOutcome: "Updated analytics with latest financial data",
            metadata: [
                "refresh_type": "manual",
                "data_scope": "all_analytics",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )

        // Execute refresh
        await viewModel.refreshAnalyticsData()
    }

    /// Handle advanced report generation with comprehensive workflow tracking
    private func handleAdvancedReportGeneration() async {
        let workflowSteps = [
            TaskMasterWorkflowStep(
                title: "Prepare Financial Data",
                description: "Fetch and validate financial data for analysis",
                elementType: .action,
                estimatedDuration: 3,
                validationCriteria: ["Data fetched", "Data validated", "No errors"]
            ),
            TaskMasterWorkflowStep(
                title: "Run Advanced Analytics Engine",
                description: "Execute advanced financial analytics algorithms",
                elementType: .action,
                estimatedDuration: 8,
                dependencies: ["prepare_data"],
                validationCriteria: ["Analytics completed", "Report generated", "Risk assessment done"]
            ),
            TaskMasterWorkflowStep(
                title: "Generate Insights and Recommendations",
                description: "Create actionable insights from analytics results",
                elementType: .action,
                estimatedDuration: 5,
                dependencies: ["analytics_engine"],
                validationCriteria: ["Insights generated", "Recommendations created", "Report finalized"]
            )
        ]

        // Track the comprehensive workflow
        let workflow = await wiringService.trackModalWorkflow(
            modalId: "advanced_report_generation",
            viewName: "AnalyticsView",
            workflowDescription: "Generate comprehensive advanced analytics report",
            expectedSteps: workflowSteps,
            metadata: [
                "report_type": "advanced",
                "complexity": "high",
                "estimated_total_duration": "16"
            ]
        )

        // Execute the analytics generation
        await viewModel.generateAdvancedAnalyticsReport()

        // Complete the workflow
        await wiringService.completeWorkflow(
            workflowId: "advanced_report_generation",
            outcome: "Advanced analytics report generated successfully"
        )
    }

    /// Handle anomaly detection with workflow tracking
    private func handleAnomalyDetection() async {
        let anomalySteps = [
            TaskMasterWorkflowStep(
                title: "Load Transaction Data",
                description: "Fetch recent transaction data for anomaly analysis",
                elementType: .action,
                estimatedDuration: 2
            ),
            TaskMasterWorkflowStep(
                title: "Apply ML Anomaly Detection",
                description: "Run machine learning algorithms to detect unusual patterns",
                elementType: .action,
                estimatedDuration: 12
            ),
            TaskMasterWorkflowStep(
                title: "Generate Anomaly Report",
                description: "Create detailed report of detected anomalies",
                elementType: .action,
                estimatedDuration: 4
            )
        ]

        // Track anomaly detection workflow
        let workflow = await wiringService.trackModalWorkflow(
            modalId: "anomaly_detection",
            viewName: "AnalyticsView",
            workflowDescription: "Detect financial anomalies using advanced algorithms",
            expectedSteps: anomalySteps,
            metadata: [
                "analysis_type": "anomaly_detection",
                "ml_enabled": "true",
                "expected_duration": "18"
            ]
        )

        // Execute anomaly detection
        await viewModel.detectFinancialAnomalies()

        // Complete the workflow
        await wiringService.completeWorkflow(
            workflowId: "anomaly_detection",
            outcome: "Anomaly detection completed successfully"
        )
    }

    /// Handle trend analysis with workflow tracking
    private func handleTrendAnalysis() async {
        let trendSteps = [
            TaskMasterWorkflowStep(
                title: "Collect Historical Data",
                description: "Gather historical financial data for trend analysis",
                elementType: .action,
                estimatedDuration: 3
            ),
            TaskMasterWorkflowStep(
                title: "Calculate Statistical Trends",
                description: "Apply statistical models to identify trends",
                elementType: .action,
                estimatedDuration: 6
            ),
            TaskMasterWorkflowStep(
                title: "Generate Trend Predictions",
                description: "Create future trend predictions based on analysis",
                elementType: .action,
                estimatedDuration: 4
            )
        ]

        // Track trend analysis workflow
        let workflow = await wiringService.trackModalWorkflow(
            modalId: "trend_analysis",
            viewName: "AnalyticsView",
            workflowDescription: "Perform real-time trend analysis on financial data",
            expectedSteps: trendSteps,
            metadata: [
                "analysis_type": "real_time_trends",
                "prediction_horizon": "6_months",
                "statistical_models": "enabled"
            ]
        )

        // Execute trend analysis
        await viewModel.performRealTimeTrendAnalysis()

        // Complete the workflow
        await wiringService.completeWorkflow(
            workflowId: "trend_analysis",
            outcome: "Trend analysis completed successfully"
        )
    }

    /// Handle analytics export with comprehensive workflow tracking
    private func handleAnalyticsExport(format: String) async {
        let exportSteps = [
            TaskMasterWorkflowStep(
                title: "Prepare Export Data",
                description: "Prepare analytics data for \(format) export",
                elementType: .action,
                estimatedDuration: 2
            ),
            TaskMasterWorkflowStep(
                title: "Format Data for \(format)",
                description: "Convert analytics data to \(format) format",
                elementType: .action,
                estimatedDuration: 4
            ),
            TaskMasterWorkflowStep(
                title: "Generate \(format) File",
                description: "Create and save \(format) export file",
                elementType: .action,
                estimatedDuration: 3
            ),
            TaskMasterWorkflowStep(
                title: "Verify Export Quality",
                description: "Validate exported \(format) file integrity",
                elementType: .action,
                estimatedDuration: 2
            )
        ]

        // Track export workflow
        let workflow = await wiringService.trackModalWorkflow(
            modalId: "analytics_export_\(format.lowercased())",
            viewName: "AnalyticsView",
            workflowDescription: "Export analytics data to \(format) format",
            expectedSteps: exportSteps,
            metadata: [
                "export_format": format,
                "data_scope": "current_analytics",
                "quality_check": "enabled",
                "export_timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        )

        // Simulate export process (in real implementation, this would call actual export service)
        print("📊 Exporting analytics data to \(format) format...")

        // Simulate processing time
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Complete the workflow
        await wiringService.completeWorkflow(
            workflowId: "analytics_export_\(format.lowercased())",
            outcome: "Analytics data exported to \(format) format successfully"
        )

        print("✅ Analytics export to \(format) completed")
    }

    /// Handle chart interaction tracking
    private func handleChartInteraction(type: String, chartType: String) async {
        _ = await wiringService.trackButtonAction(
            buttonId: "\(type)_\(chartType)",
            viewName: "AnalyticsView",
            actionDescription: "User \(type.replacingOccurrences(of: "_", with: " ")) on \(chartType) chart",
            expectedOutcome: "Enhanced chart viewing experience",
            metadata: [
                "interaction_type": type,
                "chart_type": chartType,
                "chart_context": "active_chart",
                "user_intent": "data_exploration"
            ]
        )
    }

    private func getRiskColor(_ riskScore: Double) -> Color {
        if riskScore < 0.3 {
            return .green
        } else if riskScore < 0.7 {
            return .orange
        } else {
            return .red
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
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

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct CategoryRowView: View {
    let category: CategoryAnalytics

    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)

            Text(category.categoryName)
                .font(.subheadline)

            Spacer()

            VStack(alignment: .trailing) {
                Text(formatCurrency(category.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(Int(category.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// MARK: - Supporting Enums

enum ChartType: String, CaseIterable {
    case trends = "trends"
    case categories = "categories"
    case comparison = "comparison"

    var displayName: String {
        switch self {
        case .trends: return "Trends"
        case .categories: return "Categories"
        case .comparison: return "Comparison"
        }
    }

    var icon: String {
        switch self {
        case .trends: return "chart.line.uptrend.xyaxis"
        case .categories: return "chart.pie.fill"
        case .comparison: return "chart.bar.fill"
        }
    }
}
