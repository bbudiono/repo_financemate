import SwiftUI

struct MLACSEvolutionaryView: View {
    @StateObject private var eosSystem = MLACSEvolutionaryOptimizationSystem()
    @State private var selectedTab: MLACSTab = .overview
    @State private var userQuery: String = ""
    @State private var isProcessing: Bool = false
    @State private var currentSolution: OptimizedSolution?
    @State private var showingQueryInterface: Bool = false

    var body: some View {
        NavigationView {
            // Sidebar Navigation
            VStack(spacing: 0) {
                headerView
                Divider()
                sidebarNavigation
                Divider()
                systemStatusCard
            }
            .frame(minWidth: 300)
            .background(Color(NSColor.controlBackgroundColor))

            // Main Content Area
            Group {
                switch selectedTab {
                case .overview:
                    overviewDashboard
                case .evolutionaryEngine:
                    evolutionaryEngineView
                case .agentPools:
                    agentPoolsView
                case .researchDiscovery:
                    researchDiscoveryView
                case .solutionDatabase:
                    solutionDatabaseView
                case .performanceAnalytics:
                    performanceAnalyticsView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("MLACS-EOS")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingQueryInterface = true }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Query MLACS-EOS")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showingQueryInterface) {
            MLACSQueryInterface(
                eosSystem: eosSystem,
                isProcessing: $isProcessing,
                currentSolution: $currentSolution
            )
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text("MLACS-EOS")
                .font(.title2)
                .fontWeight(.bold)

            Text("Multi-LLM Agent Coordination System")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Evolutionary Optimization")
                .font(.caption2)
                .foregroundColor(.blue)
                .fontWeight(.medium)
        }
        .padding()
    }

    // MARK: - Sidebar Navigation

    private var sidebarNavigation: some View {
        List(MLACSTab.allCases, id: \.self, selection: $selectedTab) { tab in
            Label(tab.title, systemImage: tab.icon)
                .foregroundColor(selectedTab == tab ? .blue : .primary)
        }
        .listStyle(.sidebar)
    }

    // MARK: - System Status Card

    private var systemStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("System Status")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                StatusIndicator(status: eosSystem.systemStatus)
            }

            VStack(alignment: .leading, spacing: 4) {
                StatusRow(
                    title: "Active Operations",
                    value: "\(eosSystem.currentOperations.filter { $0.status != .completed }.count)"
                )

                StatusRow(
                    title: "Avg Response Time",
                    value: String(format: "%.2fs", eosSystem.performanceMetrics.averageResponseTime)
                )

                StatusRow(
                    title: "Quality Score",
                    value: String(format: "%.1f%%", eosSystem.qualityMetrics.averageQualityScore * 100)
                )
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .padding()
    }

    // MARK: - Overview Dashboard

    private var overviewDashboard: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                systemOverviewCards
                activeOperationsView
                recentSolutionsView
            }
            .padding()
        }
    }

    private var systemOverviewCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            SystemOverviewCard(
                title: "Total Queries Processed",
                value: "\(eosSystem.performanceMetrics.totalQueries)",
                icon: "brain.head.profile",
                color: .blue
            )

            SystemOverviewCard(
                title: "Novel Solutions Discovered",
                value: "\(eosSystem.qualityMetrics.novelSolutionsDiscovered)",
                icon: "lightbulb.fill",
                color: .yellow
            )

            SystemOverviewCard(
                title: "High Quality Solutions",
                value: "\(eosSystem.qualityMetrics.highQualitySolutions)",
                icon: "star.fill",
                color: .green
            )
        }
    }

    private var activeOperationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Operations")
                .font(.headline)
                .fontWeight(.semibold)

            if eosSystem.currentOperations.isEmpty {
                EmptyOperationsView()
            } else {
                ForEach(eosSystem.currentOperations.filter { $0.status != .completed }, id: \.id) { operation in
                    OperationCard(operation: operation)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var recentSolutionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Solutions")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(eosSystem.solutionDatabase.storedSolutions.suffix(5), id: \.id) { solution in
                SolutionCard(solution: solution)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Evolutionary Engine View

    private var evolutionaryEngineView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                evolutionaryProcessFlow
                generationAnalysis
                optimizationMetrics
            }
            .padding()
        }
    }

    private var evolutionaryProcessFlow: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evolutionary Process Flow")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                ProcessStage(
                    title: "Generate",
                    description: "3-10 diverse solutions",
                    icon: "plus.circle.fill",
                    color: .green
                )

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                ProcessStage(
                    title: "Evaluate",
                    description: "Multi-agent scoring",
                    icon: "checkmark.circle.fill",
                    color: .blue
                )

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                ProcessStage(
                    title: "Optimize",
                    description: "Iterative refinement",
                    icon: "arrow.up.circle.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var generationAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generation Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder for generation tracking charts
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Evolution Progress Tracking")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var optimizationMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optimization Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(
                    title: "Convergence Rate",
                    value: "92.3%",
                    subtitle: "Solutions reaching quality threshold"
                )

                MetricCard(
                    title: "Improvement Factor",
                    value: "1.34x",
                    subtitle: "Average quality enhancement"
                )

                MetricCard(
                    title: "Generation Efficiency",
                    value: "4.2 gens",
                    subtitle: "Average generations to convergence"
                )

                MetricCard(
                    title: "Pattern Recognition",
                    value: "87.1%",
                    subtitle: "Successful pattern application"
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Agent Pools View

    private var agentPoolsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                agentPoolOverview
                generatorPoolDetails
                evaluatorPoolDetails
                optimizerPoolDetails
            }
            .padding()
        }
    }

    private var agentPoolOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Agent Pool Architecture")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                AgentPoolCard(
                    title: "Generator Pool",
                    count: 10,
                    types: ["Ideation", "Code", "Research", "Creative", "Expert"],
                    color: .green
                )

                AgentPoolCard(
                    title: "Evaluator Pool",
                    count: 5,
                    types: ["Quality", "Logic", "Requirements", "Peer Review", "Performance"],
                    color: .blue
                )

                AgentPoolCard(
                    title: "Optimizer Pool",
                    count: 3,
                    types: ["Algorithm", "Integration", "Adaptation"],
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var generatorPoolDetails: some View {
        AgentPoolDetailView(
            title: "Generator Agents",
            agents: [
                AgentInfo(name: "Ideation Agent", type: "Innovation", status: .active, performance: 0.89),
                AgentInfo(name: "Code Generation Agent", type: "Implementation", status: .active, performance: 0.92),
                AgentInfo(name: "Research Agent", type: "Knowledge Discovery", status: .active, performance: 0.85),
                AgentInfo(name: "Creative Agent", type: "Unconventional Solutions", status: .active, performance: 0.78),
                AgentInfo(name: "Domain Expert Agent", type: "Specialized Knowledge", status: .active, performance: 0.94)
            ]
        )
    }

    private var evaluatorPoolDetails: some View {
        AgentPoolDetailView(
            title: "Evaluator Agents",
            agents: [
                AgentInfo(name: "Quality Evaluator", type: "Solution Quality", status: .active, performance: 0.96),
                AgentInfo(name: "Logic Validator", type: "Logical Consistency", status: .active, performance: 0.98),
                AgentInfo(name: "Requirements Checker", type: "Requirement Compliance", status: .active, performance: 0.91),
                AgentInfo(name: "Peer Reviewer", type: "Cross-Validation", status: .active, performance: 0.87),
                AgentInfo(name: "Performance Benchmarker", type: "Quantitative Analysis", status: .active, performance: 0.93)
            ]
        )
    }

    private var optimizerPoolDetails: some View {
        AgentPoolDetailView(
            title: "Optimizer Agents",
            agents: [
                AgentInfo(name: "Algorithm Optimizer", type: "Performance Enhancement", status: .active, performance: 0.91),
                AgentInfo(name: "Integration Specialist", type: "System Integration", status: .active, performance: 0.88),
                AgentInfo(name: "Adaptation Engineer", type: "Context Adaptation", status: .active, performance: 0.86)
            ]
        )
    }

    // MARK: - Research Discovery View

    private var researchDiscoveryView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                autonomousResearchEngine
                knowledgeMiningResults
                discoveryPatterns
            }
            .padding()
        }
    }

    private var autonomousResearchEngine: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Autonomous Research Engine")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                ResearchSourceCard(
                    name: "Perplexity-Ask",
                    status: .connected,
                    queriesProcessed: 1247,
                    successRate: 0.96
                )

                ResearchSourceCard(
                    name: "Brave Search",
                    status: .connected,
                    queriesProcessed: 892,
                    successRate: 0.94
                )

                ResearchSourceCard(
                    name: "Tavily Search",
                    status: .connected,
                    queriesProcessed: 654,
                    successRate: 0.91
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var knowledgeMiningResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Knowledge Mining Results")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder for knowledge mining visualization
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 180)
                .overlay(
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Knowledge Discovery Patterns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var discoveryPatterns: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discovery Patterns")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DiscoveryPatternCard(
                    title: "Novel Approaches",
                    count: 23,
                    percentage: 15.7,
                    trend: .up
                )

                DiscoveryPatternCard(
                    title: "Cross-Domain Patterns",
                    count: 41,
                    percentage: 28.3,
                    trend: .up
                )

                DiscoveryPatternCard(
                    title: "Optimization Opportunities",
                    count: 67,
                    percentage: 45.2,
                    trend: .stable
                )

                DiscoveryPatternCard(
                    title: "Integration Insights",
                    count: 34,
                    percentage: 22.1,
                    trend: .up
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Solution Database View

    private var solutionDatabaseView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                solutionDatabaseOverview
                patternLibraryView
                performanceHistoryView
            }
            .padding()
        }
    }

    private var solutionDatabaseOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Solution Database")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DatabaseMetricCard(
                    title: "Total Solutions",
                    value: "\(eosSystem.solutionDatabase.storedSolutions.count)",
                    icon: "brain.head.profile",
                    color: .blue
                )

                DatabaseMetricCard(
                    title: "Pattern Library",
                    value: "\(eosSystem.solutionDatabase.patternLibrary.count)",
                    icon: "pattern",
                    color: .green
                )

                DatabaseMetricCard(
                    title: "Performance Points",
                    value: "\(eosSystem.solutionDatabase.performanceHistory.count)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var patternLibraryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pattern Library")
                .font(.headline)
                .fontWeight(.semibold)

            ForEach(eosSystem.solutionDatabase.patternLibrary.prefix(5), id: \.id) { pattern in
                PatternCard(pattern: pattern)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var performanceHistoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance History")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder for performance history chart
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Performance Trends Over Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    // MARK: - Performance Analytics View

    private var performanceAnalyticsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                performanceOverview
                qualityAnalytics
                efficiencyMetrics
            }
            .padding()
        }
    }

    private var performanceOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Overview")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                PerformanceMetricCard(
                    title: "Response Time",
                    value: String(format: "%.2fs", eosSystem.performanceMetrics.averageResponseTime),
                    target: "<2.0s",
                    status: eosSystem.performanceMetrics.averageResponseTime < 2.0 ? .good : .needs_improvement
                )

                PerformanceMetricCard(
                    title: "Quality Score",
                    value: String(format: "%.1f%%", eosSystem.qualityMetrics.averageQualityScore * 100),
                    target: ">95%",
                    status: eosSystem.qualityMetrics.averageQualityScore > 0.95 ? .good : .needs_improvement
                )

                PerformanceMetricCard(
                    title: "Success Rate",
                    value: String(format: "%.1f%%", eosSystem.performanceMetrics.successRate * 100),
                    target: ">90%",
                    status: eosSystem.performanceMetrics.successRate > 0.90 ? .good : .needs_improvement
                )

                PerformanceMetricCard(
                    title: "Uptime",
                    value: String(format: "%.1fh", eosSystem.performanceMetrics.systemUptime / 3600),
                    target: "24/7",
                    status: .good
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var qualityAnalytics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quality Analytics")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder for quality analytics charts
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("Quality Distribution Analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var efficiencyMetrics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Efficiency Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            // Placeholder for efficiency metrics
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .frame(height: 180)
                .overlay(
                    VStack {
                        Image(systemName: "speedometer")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("System Efficiency Tracking")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views and Components

enum MLACSTab: String, CaseIterable {
    case overview = "Overview"
    case evolutionaryEngine = "Evolutionary Engine"
    case agentPools = "Agent Pools"
    case researchDiscovery = "Research & Discovery"
    case solutionDatabase = "Solution Database"
    case performanceAnalytics = "Performance Analytics"

    var title: String {
        switch self {
        case .overview: return "📋 Overview"
        case .evolutionaryEngine: return "🧬 Evolutionary Engine"
        case .agentPools: return "👥 Agent Pools"
        case .researchDiscovery: return "🔍 Research & Discovery"
        case .solutionDatabase: return "🗄️ Solution Database"
        case .performanceAnalytics: return "📊 Performance Analytics"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "chart.line.uptrend.xyaxis"
        case .evolutionaryEngine: return "brain.head.profile"
        case .agentPools: return "person.3.fill"
        case .researchDiscovery: return "magnifyingglass.circle"
        case .solutionDatabase: return "externaldrive.fill"
        case .performanceAnalytics: return "chart.bar.xaxis"
        }
    }
}

struct StatusIndicator: View {
    let status: SystemStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
    }

    private var statusColor: Color {
        switch status {
        case .ready: return .green
        case .processing: return .blue
        case .initializing: return .orange
        case .configurationError: return .red
        case .maintenance: return .yellow
        }
    }

    private var statusText: String {
        switch status {
        case .ready: return "Ready"
        case .processing: return "Processing"
        case .initializing: return "Initializing"
        case .configurationError: return "Error"
        case .maintenance: return "Maintenance"
        }
    }
}

struct StatusRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct SystemOverviewCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

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
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct EmptyOperationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("No Active Operations")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Use 'Query MLACS-EOS' to start evolutionary optimization")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct OperationCard: View {
    let operation: EvolutionaryOperation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(operation.query)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("Started: \(operation.startTime, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(operation.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(operation.status.color)

                if let duration = operation.duration {
                    Text(String(format: "%.2fs", duration))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct SolutionCard: View {
    let solution: OptimizedSolution

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(solution.originalQuery)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(solution.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text(String(format: "%.1f%%", solution.qualityScore * 100))
                        .font(.caption)
                        .fontWeight(.medium)

                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }

                if solution.isNovelSolution {
                    Text("Novel")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

// Additional supporting views would continue here...
// Due to length constraints, I'm providing the core structure

extension OperationStatus {
    var displayName: String {
        switch self {
        case .analyzing: return "Analyzing"
        case .generating: return "Generating"
        case .evaluating: return "Evaluating"
        case .optimizing: return "Optimizing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }

    var color: Color {
        switch self {
        case .analyzing: return .blue
        case .generating: return .green
        case .evaluating: return .orange
        case .optimizing: return .purple
        case .completed: return .green
        case .failed: return .red
        }
    }
}

// MARK: - Query Interface

struct MLACSQueryInterface: View {
    let eosSystem: MLACSEvolutionaryOptimizationSystem
    @Binding var isProcessing: Bool
    @Binding var currentSolution: OptimizedSolution?

    @State private var query: String = ""
    @State private var selectedContext: QueryContext = .general
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                queryInputSection

                if isProcessing {
                    processingView
                } else if let solution = currentSolution {
                    solutionView(solution)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Query MLACS-EOS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitQuery()
                    }
                    .disabled(query.isEmpty || isProcessing)
                }
            }
        }
        .frame(width: 600, height: 500)
    }

    private var queryInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Query")
                .font(.headline)

            TextEditor(text: $query)
                .font(.body)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            Picker("Context", selection: $selectedContext) {
                ForEach(QueryContext.allCases, id: \.self) { context in
                    Text(context.rawValue.capitalized).tag(context)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("MLACS-EOS is processing your query...")
                .font(.headline)

            Text("Generating and evaluating multiple solutions")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func solutionView(_ solution: OptimizedSolution) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Optimized Solution")
                .font(.headline)

            Text(solution.selectedSolution)
                .font(.body)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)

            HStack {
                Text("Quality Score: \(String(format: "%.1f%%", solution.qualityScore * 100))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Processing Time: \(String(format: "%.2fs", solution.processingTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func submitQuery() {
        isProcessing = true
        currentSolution = nil

        Task {
            let solution = await eosSystem.processUserQuery(query, context: selectedContext)

            await MainActor.run {
                currentSolution = solution
                isProcessing = false
            }
        }
    }
}

#Preview {
    MLACSEvolutionaryView()
}
