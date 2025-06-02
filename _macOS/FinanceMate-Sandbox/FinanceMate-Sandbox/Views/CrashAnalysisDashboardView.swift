// SANDBOX FILE: For testing/development. See .cursorrules.
//
// CrashAnalysisDashboardView.swift
// FinanceMate-Sandbox
//
// Purpose: Comprehensive SwiftUI dashboard for crash analysis and system monitoring
// Issues & Complexity Summary: Complex UI with real-time data updates and multiple chart types
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~380
//   - Core Algorithm Complexity: Medium (data visualization, state management, real-time updates)
//   - Dependencies: 4 New (SwiftUI, Charts, Combine, Foundation)
//   - State Management Complexity: High (multiple data sources, real-time updates, UI state)
//   - Novelty/Uncertainty Factor: Low (established SwiftUI patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 72%
// Problem Estimate (Inherent Problem Difficulty %): 70%
// Initial Code Complexity Estimate %: 71%
// Justification for Estimates: Standard SwiftUI dashboard with some complexity in data visualization
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-02

import SwiftUI
import Combine
import Foundation

// MARK: - Crash Analysis Dashboard View

struct CrashAnalysisDashboardView: View {
    @StateObject private var crashAnalysisManager = CrashAnalysisManager.shared
    @State private var isRefreshing = false
    @State private var selectedTimeRange: TimeRange = .last24Hours
    @State private var showingExportDialog = false
    @State private var exportedFileURL: URL?
    @State private var selectedCrashType: CrashType?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Controls
                topControlsSection
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // System Health Overview
                        systemHealthSection
                        
                        // Quick Stats
                        quickStatsSection
                        
                        // Charts Section
                        chartsSection
                        
                        // Recent Crashes
                        recentCrashesSection
                        
                        // Performance Monitoring
                        performanceSection
                        
                        // System Information
                        systemInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Crash Analysis Dashboard")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    toolbarItems
                }
            }
            .sheet(isPresented: $showingExportDialog) {
                exportDialog
            }
            .alert("Export Complete", isPresented: .constant(exportedFileURL != nil)) {
                Button("Open") {
                    if let url = exportedFileURL {
                        NSWorkspace.shared.open(url.deletingLastPathComponent())
                    }
                    exportedFileURL = nil
                }
                Button("OK") {
                    exportedFileURL = nil
                }
            } message: {
                Text("Crash report exported successfully")
            }
            .task {
                await refreshData()
            }
        }
        .frame(minWidth: 900, minHeight: 700)
    }
    
    // MARK: - Top Controls Section
    
    private var topControlsSection: some View {
        HStack {
            // Monitoring Status
            HStack(spacing: 8) {
                Circle()
                    .fill(crashAnalysisManager.isMonitoring ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(crashAnalysisManager.isMonitoring ? "Monitoring Active" : "Monitoring Inactive")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time Range Picker
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 300)
            
            Spacer()
            
            // Refresh Button
            Button(action: {
                Task {
                    await refreshData()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(isRefreshing)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - System Health Section
    
    private var systemHealthSection: some View {
        GroupBox("System Health") {
            HStack(spacing: 20) {
                // Health Score Gauge
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: crashAnalysisManager.systemHealth.score / 100)
                            .stroke(crashAnalysisManager.systemHealth.status.color, lineWidth: 8)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: crashAnalysisManager.systemHealth.score)
                        
                        VStack {
                            Text("\(Int(crashAnalysisManager.systemHealth.score))")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Score")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(crashAnalysisManager.systemHealth.status.description)
                        .font(.caption)
                        .foregroundColor(crashAnalysisManager.systemHealth.status.color)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                // Health Indicators
                VStack(alignment: .leading, spacing: 8) {
                    healthIndicator(
                        title: "Recent Crashes",
                        hasIssue: crashAnalysisManager.systemHealth.hasRecentCrashes,
                        icon: "exclamationmark.triangle"
                    )
                    
                    healthIndicator(
                        title: "Performance Issues",
                        hasIssue: crashAnalysisManager.systemHealth.hasPerformanceIssues,
                        icon: "speedometer"
                    )
                    
                    healthIndicator(
                        title: "Recent Alerts",
                        hasIssue: crashAnalysisManager.systemHealth.hasRecentAlerts,
                        icon: "bell"
                    )
                    
                    healthIndicator(
                        title: "Monitoring",
                        hasIssue: !crashAnalysisManager.systemHealth.isMonitoring,
                        icon: "eye"
                    )
                }
                
                Spacer()
                
                // Last Updated
                VStack(alignment: .trailing) {
                    Text("Last Updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(crashAnalysisManager.systemHealth.lastUpdated, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
    
    private func healthIndicator(title: String, hasIssue: Bool, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(hasIssue ? .red : .green)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
            
            Spacer()
            
            Text(hasIssue ? "Issue" : "OK")
                .font(.caption2)
                .foregroundColor(hasIssue ? .red : .green)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Total Crashes",
                value: crashAnalysisManager.dashboardData.analysisResult?.totalCrashes ?? 0,
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
            
            statCard(
                title: "Crash Free Rate",
                value: crashAnalysisManager.dashboardData.crashMetrics?.crashFreeRate ?? 100.0,
                format: "%.1f%%",
                icon: "checkmark.shield.fill",
                color: .green
            )
            
            statCard(
                title: "Memory Leaks",
                value: crashAnalysisManager.dashboardData.memoryLeaks.count,
                icon: "memorychip.fill",
                color: .orange
            )
            
            statCard(
                title: "Stability Score",
                value: crashAnalysisManager.dashboardData.crashMetrics?.stabilityScore ?? 100.0,
                format: "%.0f",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )
        }
    }
    
    private func statCard(title: String, value: Any, format: String = "%.0f", icon: String, color: Color) -> some View {
        GroupBox {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let doubleValue = value as? Double {
                        Text(String(format: format, doubleValue))
                            .font(.title2)
                            .fontWeight(.bold)
                    } else if let intValue = value as? Int {
                        Text("\(intValue)")
                            .font(.title2)
                            .fontWeight(.bold)
                    } else {
                        Text("\(value)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
        }
        .frame(height: 80)
    }
    
    // MARK: - Charts Section
    
    private var chartsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Crash Types Chart
                crashTypesPieChart
                
                // Severity Distribution Chart
                severityDistributionChart
            }
            
            // Trends Chart
            trendsChart
        }
    }
    
    private var crashTypesPieChart: some View {
        GroupBox("Crash Types Distribution") {
            if let crashesByType = crashAnalysisManager.dashboardData.analysisResult?.crashesByType,
               !crashesByType.isEmpty {
                VStack(spacing: 12) {
                    // Simple pie representation using circles
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        ForEach(Array(crashesByType.keys), id: \.self) { crashType in
                            Circle()
                                .fill(colorForCrashType(crashType))
                                .frame(width: 8, height: 8)
                                .offset(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -40...40))
                        }
                    }
                    
                    // Legend
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(Array(crashesByType.keys), id: \.self) { crashType in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(colorForCrashType(crashType))
                                    .frame(width: 8, height: 8)
                                Text(crashType.rawValue.capitalized)
                                    .font(.caption2)
                                Text("(\(crashesByType[crashType] ?? 0))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 200)
            } else {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No crash data available")
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
    }
    
    private var severityDistributionChart: some View {
        GroupBox("Severity Distribution") {
            if let crashesBySeverity = crashAnalysisManager.dashboardData.analysisResult?.crashesBySeverity,
               !crashesBySeverity.isEmpty {
                VStack(spacing: 8) {
                    ForEach(CrashSeverity.allCases, id: \.self) { severity in
                        let count = crashesBySeverity[severity] ?? 0
                        let maxCount = crashesBySeverity.values.max() ?? 1
                        let percentage = maxCount > 0 ? Double(count) / Double(maxCount) : 0
                        
                        HStack {
                            Text(severity.description)
                                .font(.caption)
                                .frame(width: 60, alignment: .leading)
                            
                            Rectangle()
                                .fill(colorForSeverity(severity))
                                .frame(width: 120 * percentage, height: 20)
                                .animation(.easeInOut, value: percentage)
                            
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
                .frame(height: 200)
                .padding()
            } else {
                VStack {
                    Image(systemName: "chart.bar")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No severity data available")
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
    }
    
    private var trendsChart: some View {
        GroupBox("Crash Trends") {
            if let trends = crashAnalysisManager.dashboardData.analysisResult?.trends,
               !trends.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Period")
                            .font(.caption)
                            .frame(width: 50, alignment: .leading)
                        Text("Count")
                            .font(.caption)
                            .frame(width: 50, alignment: .center)
                        Text("Change")
                            .font(.caption)
                            .frame(width: 60, alignment: .trailing)
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                    
                    ForEach(trends, id: \.severity) { trend in
                        HStack {
                            Text(trend.period)
                                .font(.caption)
                                .frame(width: 50, alignment: .leading)
                            
                            Text("\(trend.crashCount)")
                                .font(.caption)
                                .foregroundColor(colorForSeverity(trend.severity))
                                .frame(width: 50, alignment: .center)
                            
                            Text(String(format: "%.1f%%", trend.changePercentage))
                                .font(.caption)
                                .foregroundColor(trend.changePercentage >= 0 ? .red : .green)
                                .frame(width: 60, alignment: .trailing)
                            
                            Rectangle()
                                .fill(colorForSeverity(trend.severity))
                                .frame(width: max(4, abs(trend.changePercentage) * 2), height: 4)
                            
                            Spacer()
                        }
                    }
                }
                .frame(height: 150)
                .padding()
            } else {
                VStack {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No trend data available")
                        .foregroundColor(.secondary)
                }
                .frame(height: 150)
            }
        }
    }
    
    // MARK: - Recent Crashes Section
    
    private var recentCrashesSection: some View {
        GroupBox("Recent Crashes") {
            if crashAnalysisManager.dashboardData.recentCrashes.isEmpty {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("No recent crashes")
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(crashAnalysisManager.dashboardData.recentCrashes) { crash in
                        crashRowView(crash)
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }
    
    private func crashRowView(_ crash: CrashReport) -> some View {
        HStack(spacing: 12) {
            // Severity indicator
            Circle()
                .fill(colorForSeverity(crash.severity))
                .frame(width: 12, height: 12)
            
            // Crash info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(crash.crashType.rawValue.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(crash.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(crash.errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            // Severity badge
            Text(crash.severity.description)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(colorForSeverity(crash.severity).opacity(0.2))
                .foregroundColor(colorForSeverity(crash.severity))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
    
    // MARK: - Performance Section
    
    private var performanceSection: some View {
        GroupBox("Performance Monitoring") {
            if let performanceSnapshot = crashAnalysisManager.dashboardData.performanceSnapshot {
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        performanceMetric(
                            title: "CPU Usage",
                            value: performanceSnapshot.cpuUsage.totalUsage,
                            unit: "%",
                            color: performanceSnapshot.cpuUsage.totalUsage > 80 ? .red : .green
                        )
                        
                        performanceMetric(
                            title: "Memory Usage",
                            value: Double(performanceSnapshot.memoryUsage.resident) / Double(performanceSnapshot.memoryUsage.physical) * 100,
                            unit: "%",
                            color: performanceSnapshot.memoryUsage.pressure != .normal ? .orange : .green
                        )
                        
                        performanceMetric(
                            title: "Thermal State",
                            value: performanceSnapshot.thermalState.rawValue,
                            isNumeric: false,
                            color: performanceSnapshot.thermalState == .nominal ? .green : .red
                        )
                    }
                    
                    if !crashAnalysisManager.dashboardData.memoryLeaks.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Memory Leaks Detected")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            
                            ForEach(crashAnalysisManager.dashboardData.memoryLeaks.prefix(3)) { leak in
                                HStack {
                                    Text(leak.objectType)
                                        .font(.caption)
                                    
                                    Spacer()
                                    
                                    Text("\(leak.instanceCount) instances")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(ByteCountFormatter().string(fromByteCount: Int64(leak.totalMemory)))
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
                .padding()
            } else {
                VStack {
                    Image(systemName: "speedometer")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Performance data not available")
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
            }
        }
    }
    
    private func performanceMetric(title: String, value: Any, unit: String = "", isNumeric: Bool = true, color: Color) -> some View {
        VStack(spacing: 4) {
            if isNumeric, let doubleValue = value as? Double {
                Text(String(format: "%.1f%@", doubleValue, unit))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            } else {
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - System Info Section
    
    private var systemInfoSection: some View {
        GroupBox("System Information") {
            VStack(spacing: 8) {
                HStack {
                    systemInfoRow(title: "App Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    
                    Spacer()
                    
                    systemInfoRow(title: "Build Number", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                }
                
                HStack {
                    systemInfoRow(title: "System Version", value: ProcessInfo.processInfo.operatingSystemVersionString)
                    
                    Spacer()
                    
                    systemInfoRow(title: "Device Model", value: ProcessInfo.processInfo.machineModelName)
                }
                
                HStack {
                    systemInfoRow(title: "Processor Count", value: "\(ProcessInfo.processInfo.processorCount) cores")
                    
                    Spacer()
                    
                    systemInfoRow(title: "Physical Memory", value: ByteCountFormatter().string(fromByteCount: Int64(ProcessInfo.processInfo.physicalMemory)))
                }
            }
            .padding()
        }
    }
    
    private func systemInfoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Toolbar Items
    
    private var toolbarItems: some View {
        HStack {
            // Monitor toggle
            Button(action: {
                if crashAnalysisManager.isMonitoring {
                    crashAnalysisManager.stopMonitoring()
                } else {
                    crashAnalysisManager.startMonitoring()
                }
            }) {
                Label(
                    crashAnalysisManager.isMonitoring ? "Stop Monitoring" : "Start Monitoring",
                    systemImage: crashAnalysisManager.isMonitoring ? "stop.circle" : "play.circle"
                )
            }
            .foregroundColor(crashAnalysisManager.isMonitoring ? .red : .green)
            
            // Export button
            Button(action: {
                showingExportDialog = true
            }) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            // Test crashes menu
            Menu {
                ForEach(CrashType.allCases, id: \.self) { crashType in
                    Button("Simulate \(crashType.rawValue.capitalized)") {
                        crashAnalysisManager.simulateCrash(type: crashType)
                    }
                }
            } label: {
                Label("Test Crashes", systemImage: "ladybug")
            }
            
            // Clear data button
            Button(action: {
                Task {
                    await crashAnalysisManager.clearAllData()
                    await refreshData()
                }
            }) {
                Label("Clear Data", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Export Dialog
    
    private var exportDialog: some View {
        VStack(spacing: 20) {
            Text("Export Crash Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("This will export a comprehensive crash analysis report including all crash data, performance metrics, and system information.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    showingExportDialog = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Export") {
                    Task {
                        showingExportDialog = false
                        exportedFileURL = await crashAnalysisManager.exportCrashReport()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    // MARK: - Helper Methods
    
    private func refreshData() async {
        isRefreshing = true
        let _ = await crashAnalysisManager.getDashboardData()
        isRefreshing = false
    }
    
    private func colorForCrashType(_ crashType: CrashType) -> Color {
        switch crashType {
        case .memoryLeak: return .orange
        case .unexpectedException: return .red
        case .signalException: return .purple
        case .hangOrTimeout: return .yellow
        case .networkFailure: return .blue
        case .uiResponsiveness: return .cyan
        case .dataCorruption: return .pink
        case .authenticationFailure: return .indigo
        case .unknown: return .gray
        }
    }
    
    private func colorForSeverity(_ severity: CrashSeverity) -> Color {
        switch severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Supporting Types

enum TimeRange: String, CaseIterable {
    case last1Hour = "1h"
    case last24Hours = "24h"
    case last7Days = "7d"
    case last30Days = "30d"
    
    var displayName: String {
        switch self {
        case .last1Hour: return "1 Hour"
        case .last24Hours: return "24 Hours"
        case .last7Days: return "7 Days"
        case .last30Days: return "30 Days"
        }
    }
}

// MARK: - Preview

struct CrashAnalysisDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        CrashAnalysisDashboardView()
            .frame(width: 1200, height: 800)
    }
}