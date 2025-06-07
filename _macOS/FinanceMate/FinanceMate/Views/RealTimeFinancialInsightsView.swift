//
//  RealTimeFinancialInsightsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/7/25.
//


/*
* Purpose: Real-Time Financial Insights View with AI-powered analysis and MLACS integration
* NO MOCK DATA - Displays genuine AI-powered financial insights for TestFlight users
* Features: Real-time updates, AI insights, MLACS coordination, interactive analytics, document integration
* Integration: Enhanced insights engine, AI analytics models, document processing, real-time streams
*/

import SwiftUI
import CoreData
import Combine

// MARK: - Real-Time Financial Insights View

public struct RealTimeFinancialInsightsView: View {
    
    // MARK: - Environment and State
    
    @Environment(\.managedObjectContext) private var context
    @StateObject private var integratedService = IntegratedFinancialDocumentInsightsService(
        context: CoreDataStack.shared.mainContext
    )
    @StateObject private var viewModel = RealTimeInsightsViewModel()
    
    // MARK: - State Variables
    
    @State private var selectedInsightType: FinancialInsightType? = nil
    @State private var showingInsightDetails = false
    @State private var selectedInsight: EnhancedFinancialInsight? = nil
    @State private var refreshingInsights = false
    @State private var showingSystemStatus = false
    @State private var showingAIAnalytics = false
    @State private var documentProcessingActive = false
    
    // MARK: - View Body
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with System Status
                headerView
                
                // Main Content
                if integratedService.isInitialized {
                    mainContentView
                } else {
                    initializationView
                }
            }
            .navigationTitle("AI Financial Insights")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    toolbarButtons
                }
            }
            .sheet(isPresented: $showingInsightDetails) {
                if let insight = selectedInsight {
                    RealTimeInsightDetailView(insight: insight)
                }
            }
            .sheet(isPresented: $showingSystemStatus) {
                SystemStatusView(
                    systemStatus: integratedService.systemStatus,
                    aiModels: integratedService.aiAnalyticsModels
                )
            }
            .sheet(isPresented: $showingAIAnalytics) {
                AIAnalyticsView(
                    integratedService: integratedService
                )
            }
        }
        .task {
            await initializeService()
        }
        .onReceive(integratedService.$realtimeInsights) { insights in
            viewModel.updateInsights(insights)
        }
        .onReceive(integratedService.$isProcessingActive) { isActive in
            documentProcessingActive = isActive
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                // System Health Indicator
                systemHealthIndicator
                
                Spacer()
                
                // Real-time Processing Status
                if documentProcessingActive {
                    processingStatusIndicator
                }
                
                // AI Models Status
                aiModelsStatusIndicator
            }
            .padding(.horizontal)
            
            // Quick Stats
            quickStatsView
        }
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var systemHealthIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(integratedService.systemStatus.isHealthy ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(integratedService.systemStatus.isHealthy ? "System Healthy" : "System Issues")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { showingSystemStatus = true }) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var processingStatusIndicator: some View {
        HStack(spacing: 4) {
            ProgressView()
                .scaleEffect(0.7)
            
            Text("Processing Documents...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var aiModelsStatusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(integratedService.systemStatus.aiModelsActive ? Color.blue : Color.orange)
                .frame(width: 8, height: 8)
            
            Text("AI Models")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: { showingAIAnalytics = true }) {
                Image(systemName: "brain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var quickStatsView: some View {
        HStack(spacing: 20) {
            statItem("Live Insights", value: "\(integratedService.realtimeInsights.count)")
            statItem("Documents Processed", value: "\(integratedService.processedDocumentCount)")
            statItem("Queue", value: "\(integratedService.documentProcessingQueue.count)")
            statItem("System Load", value: String(format: "%.1f%%", integratedService.systemStatus.systemLoad * 100))
        }
        .padding(.horizontal)
    }
    
    private func statItem(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Main Content View
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Insight Type Filter
            insightTypeFilter
            
            // Insights List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredInsights, id: \.id) { insight in
                        RealTimeInsightCardView(insight: insight) {
                            selectedInsight = insight
                            showingInsightDetails = true
                        }
                    }
                }
                .padding()
            }
            .refreshable {
                await refreshInsights()
            }
        }
    }
    
    private var insightTypeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedInsightType == nil,
                    action: { selectedInsightType = nil }
                )
                
                ForEach(FinancialInsightType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.displayName,
                        isSelected: selectedInsightType == type,
                        action: { selectedInsightType = type }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var filteredInsights: [EnhancedFinancialInsight] {
        let insights = integratedService.realtimeInsights
        
        if let selectedType = selectedInsightType {
            return insights.filter { $0.type == selectedType }
        }
        
        return insights
    }
    
    // MARK: - Initialization View
    
    private var initializationView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Initializing AI Financial Insights")
                .font(.headline)
            
            Text(integratedService.currentOperation)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: integratedService.processingProgress)
                .frame(width: 200)
        }
        .padding()
    }
    
    // MARK: - Toolbar Buttons
    
    private var toolbarButtons: some View {
        Group {
            Button(action: { showingAIAnalytics = true }) {
                Image(systemName: "brain")
            }
            
            Button(action: { showingSystemStatus = true }) {
                Image(systemName: "gauge")
            }
            
            Button(action: { Task { await refreshInsights() } }) {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(refreshingInsights)
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeService() async {
        do {
            try await integratedService.initializeIntegratedService()
            _ = try await integratedService.generateCurrentInsights()
        } catch {
            print("Failed to initialize integrated service: \(error)")
        }
    }
    
    private func refreshInsights() async {
        refreshingInsights = true
        defer { refreshingInsights = false }
        
        do {
            try await integratedService.refreshInsightsFromLatestData()
        } catch {
            print("Failed to refresh insights: \(error)")
        }
    }
}

// MARK: - Real-Time Insight Card View

struct RealTimeInsightCardView: View {
    let insight: EnhancedFinancialInsight
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    // Priority Indicator
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    
                    Text(insight.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // AI Indicator
                    if insight.processingMethod == .aiEnhanced || insight.processingMethod == .fullyAI {
                        Image(systemName: "brain")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    // Confidence Score
                    confidenceIndicator
                }
                
                // Description
                Text(insight.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                // AI Enhancements (if available)
                if !insight.aiEnhancements.contextualInformation.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Analysis")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(insight.aiEnhancements.contextualInformation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Footer
                HStack {
                    // Type Badge
                    Text(insight.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(typeColor.opacity(0.2))
                        .foregroundColor(typeColor)
                        .cornerRadius(12)
                    
                    Spacer()
                    
                    // Timestamp
                    Text(RelativeDateTimeFormatter().localizedString(for: insight.generatedAt, relativeTo: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
    
    private var typeColor: Color {
        switch insight.type {
        case .spendingPattern: return .blue
        case .incomeAnalysis: return .green
        case .budgetRecommendation: return .purple
        case .anomalyDetection: return .red
        case .goalProgress: return .orange
        case .categoryAnalysis: return .cyan
        }
    }
    
    private var confidenceIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < Int(insight.confidence * 5) ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Real-Time Insight Detail View

struct RealTimeInsightDetailView: View {
    let insight: EnhancedFinancialInsight
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(insight.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(insight.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Confidence and Priority
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Confidence")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(insight.confidence * 100))%")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Priority")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(insight.priority.rawValue.capitalized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("AI Confidence")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(insight.aiConfidence * 100))%")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Divider()
                    
                    // AI Enhancements
                    if !insight.aiEnhancements.contextualInformation.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Analysis")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text(insight.aiEnhancements.contextualInformation)
                                .font(.body)
                            
                            if !insight.aiEnhancements.predictionComponents.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Analysis Methods")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    ForEach(insight.aiEnhancements.predictionComponents, id: \.self) { component in
                                        Text("• \(component.replacingOccurrences(of: "_", with: " ").capitalized)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if !insight.aiEnhancements.riskFactors.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Risk Factors")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.orange)
                                    
                                    ForEach(insight.aiEnhancements.riskFactors, id: \.self) { factor in
                                        Text("• \(factor.replacingOccurrences(of: "_", with: " ").capitalized)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Divider()
                    
                    // Technical Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Technical Details")
                            .font(.headline)
                        
                        detailRow("Type", insight.type.displayName)
                        detailRow("Processing Method", insight.processingMethod.displayName)
                        detailRow("Generated", DateFormatter.detailed.string(from: insight.generatedAt))
                        
                        if let taskId = insight.agentTaskId {
                            detailRow("Agent Task ID", String(taskId.prefix(8)))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Insight Details")
            // .navigationBarTitleDisplayMode(.inline) // Not available on macOS
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - System Status View

struct SystemStatusView: View {
    let systemStatus: IntegratedSystemStatus
    let aiModels: AIPoweredFinancialAnalyticsModels
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // System Health
                    statusSection("System Health") {
                        statusRow("Overall Status", systemStatus.isHealthy ? "Healthy" : "Issues Detected", systemStatus.isHealthy ? .green : .red)
                        statusRow("Documents in Queue", "\(systemStatus.documentsInQueue)", .blue)
                        statusRow("Active Insights", "\(systemStatus.activeInsights)", .purple)
                        statusRow("System Load", String(format: "%.1f%%", systemStatus.systemLoad * 100), .orange)
                    }
                    
                    // AI Models Status
                    statusSection("AI Models") {
                        statusRow("Models Active", systemStatus.aiModelsActive ? "Active" : "Inactive", systemStatus.aiModelsActive ? .green : .red)
                        statusRow("MLACS Connected", systemStatus.mlacsConnected ? "Connected" : "Disconnected", systemStatus.mlacsConnected ? .green : .red)
                        statusRow("Model Accuracy", String(format: "%.1f%%", aiModels.modelAccuracy * 100), .blue)
                    }
                    
                    // Processing Models
                    statusSection("Processing Models") {
                        ForEach(aiModels.processingModels, id: \.self) { model in
                            statusRow(model, "Active", .green)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("System Status")
            // .navigationBarTitleDisplayMode(.inline) // Not available on macOS
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func statusSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                content()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func statusRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// MARK: - AI Analytics View

struct AIAnalyticsView: View {
    let integratedService: IntegratedFinancialDocumentInsightsService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Performance Metrics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Model Performance")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        let metrics = integratedService.aiAnalyticsModels.modelPerformanceMetrics
                        
                        performanceCard("Overall Accuracy", metrics.overallSystemAccuracy)
                        performanceCard("Spending Analysis", metrics.spendingModelAccuracy)
                        performanceCard("Anomaly Detection", metrics.anomalyModelAccuracy)
                        performanceCard("Predictive Analytics", metrics.predictiveModelAccuracy)
                    }
                    
                    // Real-time Analysis Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Real-time Analysis")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Circle()
                                .fill(integratedService.aiAnalyticsModels.realTimeAnalysisActive ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                            
                            Text(integratedService.aiAnalyticsModels.realTimeAnalysisActive ? "Active" : "Inactive")
                                .font(.body)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("AI Analytics")
            // .navigationBarTitleDisplayMode(.inline) // Not available on macOS
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performanceCard(_ title: String, _ value: Double) -> some View {
        HStack {
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(String(format: "%.1f%%", value * 100))
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - View Model

class RealTimeInsightsViewModel: ObservableObject {
    @Published var insights: [EnhancedFinancialInsight] = []
    
    func updateInsights(_ newInsights: [EnhancedFinancialInsight]) {
        DispatchQueue.main.async {
            self.insights = newInsights
        }
    }
}

// MARK: - Extensions

extension FinancialInsightType {
    var displayName: String {
        switch self {
        case .spendingPattern: return "Spending"
        case .incomeAnalysis: return "Income"
        case .budgetRecommendation: return "Budget"
        case .anomalyDetection: return "Anomalies"
        case .goalProgress: return "Goals"
        case .categoryAnalysis: return "Categories"
        }
    }
}

extension InsightProcessingMethod {
    var displayName: String {
        switch self {
        case .traditional: return "Traditional"
        case .aiEnhanced: return "AI Enhanced"
        case .fullyAI: return "Full AI"
        case .hybrid: return "Hybrid"
        }
    }
}

extension DateFormatter {
    static let detailed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}