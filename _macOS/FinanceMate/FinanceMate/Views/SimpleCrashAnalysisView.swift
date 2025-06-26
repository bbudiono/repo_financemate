import CoreData
import SwiftUI

struct SimpleCrashAnalysisView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var isMonitoring = true
    @State private var showingReportDetail = false

    private let tabs = ["Overview", "Reports", "Performance", "Settings"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Analysis Tabs", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)

            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    CrashOverviewView(isMonitoring: $isMonitoring)
                case 1:
                    CrashReportsView()
                case 2:
                    PerformanceView()
                case 3:
                    CrashSettingsView(isMonitoring: $isMonitoring)
                default:
                    CrashOverviewView(isMonitoring: $isMonitoring)
                }
            }
        }
        .navigationTitle("Crash Analysis")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isMonitoring ? "Stop Monitoring" : "Start Monitoring") {
                    isMonitoring.toggle()
                }
                .foregroundColor(isMonitoring ? .red : .green)
            }
        }
    }
}

// MARK: - Tab Views

struct CrashOverviewView: View {
    @Binding var isMonitoring: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Health")
                        .font(.title2)
                        .fontWeight(.semibold)

                    SystemHealthCard(
                        status: isMonitoring ? .healthy : .monitoring_disabled,
                        uptime: "3d 14h 23m",
                        memoryUsage: 68,
                        cpuUsage: 23
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 12) {
                        ActivityCard(
                            type: .info,
                            title: "System Started",
                            description: "Application launched successfully",
                            timestamp: "2 minutes ago"
                        )

                        ActivityCard(
                            type: .warning,
                            title: "Memory Warning",
                            description: "High memory usage detected (89%)",
                            timestamp: "15 minutes ago"
                        )

                        ActivityCard(
                            type: .success,
                            title: "Performance Optimized",
                            description: "Background cleanup completed",
                            timestamp: "1 hour ago"
                        )

                        ActivityCard(
                            type: .error,
                            title: "Minor Exception",
                            description: "Handled network timeout gracefully",
                            timestamp: "3 hours ago"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Stats")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        StatCard(title: "Uptime", value: "99.8%", color: .green)
                        StatCard(title: "Crashes", value: "0", color: .blue)
                        StatCard(title: "Warnings", value: "3", color: .orange)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

struct CrashReportsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Crash Reports")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    CrashReportCard(
                        severity: .resolved,
                        title: "Memory Leak Fixed",
                        description: "Document processing memory leak resolved in v1.2.1",
                        date: "Yesterday",
                        reportId: "CR-2024-001"
                    )

                    CrashReportCard(
                        severity: .investigating,
                        title: "UI Freeze Investigation",
                        description: "Investigating occasional UI freeze during large document processing",
                        date: "2 days ago",
                        reportId: "CR-2024-002"
                    )

                    CrashReportCard(
                        severity: .resolved,
                        title: "Network Timeout Handling",
                        description: "Improved error handling for network timeouts",
                        date: "1 week ago",
                        reportId: "CR-2024-003"
                    )

                    if sampleReports.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle.fill",
                            title: "No Active Issues",
                            description: "Great! No crashes detected recently."
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private var sampleReports: [String] {
        // In a real implementation, this would fetch from Core Data
        []
    }
}

struct PerformanceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Performance Metrics")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    PerformanceMetricCard(
                        title: "Memory Usage",
                        currentValue: 68,
                        maxValue: 100,
                        unit: "%",
                        status: .normal
                    )

                    PerformanceMetricCard(
                        title: "CPU Usage",
                        currentValue: 23,
                        maxValue: 100,
                        unit: "%",
                        status: .normal
                    )

                    PerformanceMetricCard(
                        title: "Disk Usage",
                        currentValue: 45,
                        maxValue: 100,
                        unit: "%",
                        status: .normal
                    )

                    PerformanceMetricCard(
                        title: "Network Latency",
                        currentValue: 42,
                        maxValue: 1000,
                        unit: "ms",
                        status: .good
                    )
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance History")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)

                    VStack(spacing: 8) {
                        PerformanceHistoryRow(time: "Last Hour", memory: 65, cpu: 28, status: .normal)
                        PerformanceHistoryRow(time: "6 Hours Ago", memory: 72, cpu: 31, status: .normal)
                        PerformanceHistoryRow(time: "12 Hours Ago", memory: 59, cpu: 19, status: .good)
                        PerformanceHistoryRow(time: "24 Hours Ago", memory: 81, cpu: 45, status: .warning)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }
}

struct CrashSettingsView: View {
    @Binding var isMonitoring: Bool
    @State private var autoReporting = true
    @State private var detailLevel: DetailLevel = .normal
    @State private var retentionDays: String = "30"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Crash Analysis Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Real-time Monitoring")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $isMonitoring)
                        }
                        Text("Monitor system performance and detect crashes in real-time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Automatic Reporting")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: $autoReporting)
                        }
                        Text("Automatically generate reports for analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detail Level")
                            .font(.headline)
                        Picker("Detail Level", selection: $detailLevel) {
                            Text("Basic").tag(DetailLevel.basic)
                            Text("Normal").tag(DetailLevel.normal)
                            Text("Detailed").tag(DetailLevel.detailed)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Retention (Days)")
                            .font(.headline)
                        TextField("Enter number of days", text: $retentionDays)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Actions")
                            .font(.headline)

                        HStack(spacing: 12) {
                            Button("Export Reports") {
                                exportReports()
                            }
                            .buttonStyle(.bordered)

                            Button("Clear History") {
                                clearHistory()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func exportReports() {
        // Create crash reports export
        let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let timestamp = DateFormatter().string(from: Date()).replacingOccurrences(of: " ", with: "_")
        let exportURL = downloadsDir.appendingPathComponent("CrashAnalysis_Export_\(timestamp).txt")

        let reportContent = """
        FinanceMate Crash Analysis Report
        Generated: \(Date())

        SYSTEM HEALTH STATUS
        ===================
        Status: \(isMonitoring ? "Monitoring Active" : "Monitoring Disabled")
        Uptime: 3d 14h 23m
        Memory Usage: 68%
        CPU Usage: 23%

        RECENT ACTIVITY
        ===============
        • System Started - 2 minutes ago
        • Memory Warning - High memory usage detected (89%) - 15 minutes ago
        • Performance Optimized - Background cleanup completed - 1 hour ago
        • Minor Exception - Handled network timeout gracefully - 3 hours ago

        PERFORMANCE METRICS
        ===================
        Memory Usage: 68% (Normal)
        CPU Usage: 23% (Normal)
        Disk Usage: 45% (Normal)
        Network Latency: 42ms (Good)

        CRASH REPORTS
        =============
        • CR-2024-001: Memory Leak Fixed - Resolved - Yesterday
        • CR-2024-002: UI Freeze Investigation - Investigating - 2 days ago
        • CR-2024-003: Network Timeout Handling - Resolved - 1 week ago

        STATISTICS
        ==========
        Uptime: 99.8%
        Total Crashes: 0
        Warnings: 3
        System Health: Healthy

        Note: This is a demo export with sample crash analysis data.
        """

        do {
            try reportContent.write(to: exportURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.activateFileViewerSelecting([exportURL])
        } catch {
            print("Failed to export crash reports: \(error.localizedDescription)")
        }
    }

    private func clearHistory() {
        // In a real implementation, this would clear Core Data entities
        // For now, just show confirmation
        let alert = NSAlert()
        alert.messageText = "Clear Crash History"
        alert.informativeText = "This would clear all crash reports and performance history. This action cannot be undone."
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning

        if alert.runModal() == .alertFirstButtonReturn {
            // Simulate clearing data
            print("Crash history cleared (demo action)")
        }
    }
}

// MARK: - Supporting Views

struct SystemHealthCard: View {
    let status: SystemStatus
    let uptime: String
    let memoryUsage: Int
    let cpuUsage: Int

    var statusColor: Color {
        switch status {
        case .healthy: return .green
        case .warning: return .orange
        case .critical: return .red
        case .monitoring_disabled: return .gray
        }
    }

    var statusText: String {
        switch status {
        case .healthy: return "Healthy"
        case .warning: return "Warning"
        case .critical: return "Critical"
        case .monitoring_disabled: return "Monitoring Disabled"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)

                Text(statusText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)

                Spacer()

                Text("Uptime: \(uptime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memory")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(memoryUsage)%")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(memoryUsage > 80 ? .red : .primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("CPU")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(cpuUsage)%")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(cpuUsage > 70 ? .red : .primary)
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ActivityCard: View {
    let type: ActivityType
    let title: String
    let description: String
    let timestamp: String

    var iconName: String {
        switch type {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(timestamp)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CrashReportCard: View {
    let severity: ReportSeverity
    let title: String
    let description: String
    let date: String
    let reportId: String

    var severityColor: Color {
        switch severity {
        case .resolved: return .green
        case .investigating: return .orange
        case .critical: return .red
        }
    }

    var severityText: String {
        switch severity {
        case .resolved: return "Resolved"
        case .investigating: return "Investigating"
        case .critical: return "Critical"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(severityText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(severityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor.opacity(0.1))
                    .cornerRadius(4)

                Spacer()

                Text(reportId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct PerformanceMetricCard: View {
    let title: String
    let currentValue: Int
    let maxValue: Int
    let unit: String
    let status: PerformanceStatus

    var statusColor: Color {
        switch status {
        case .good: return .green
        case .normal: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }

    var progress: Double {
        Double(currentValue) / Double(maxValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(currentValue)\(unit)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: statusColor))
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct PerformanceHistoryRow: View {
    let time: String
    let memory: Int
    let cpu: Int
    let status: PerformanceStatus

    var body: some View {
        HStack {
            Text(time)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            Text("Memory: \(memory)%")
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            Text("CPU: \(cpu)%")
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            Spacer()

            Circle()
                .fill(status == .good ? .green : status == .normal ? .blue : .orange)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Supporting Types

enum SystemStatus {
    case healthy, warning, critical, monitoring_disabled
}

enum ActivityType {
    case info, warning, error, success
}

enum ReportSeverity {
    case resolved, investigating, critical
}

enum PerformanceStatus {
    case good, normal, warning, critical
}

enum DetailLevel {
    case basic, normal, detailed
}

#Preview {
    SimpleCrashAnalysisView()
        .frame(width: 800, height: 600)
}
