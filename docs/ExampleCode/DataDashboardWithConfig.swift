import SwiftUI
import Charts

/// # Data Dashboard with Interactive Charts and Configuration Modals (Conceptual)
/// Demonstrates a data dashboard with conceptual interactive charts and a modal for configuration.
/// Combines:
/// - Conceptual Charts (using SwiftUI Charts framework)
/// - Buttons to trigger configuration modal
/// - Modal view for configuration options (inspired by DatabaseConfigView)
/// - Inspired by DataAnalyticsDashboardView and InteractiveDashboardView.
struct DataDashboardWithConfig: View {
    // MARK: - State
    @State private var showConfigModal = false
    @State private var chartType: ChartType = .bar
    @State private var timeRange: TimeRange = .month
    
    // Sample data (conceptual)
    let sampleData: [SalesData] = [
        .init(month: "Jan", amount: 1500),
        .init(month: "Feb", amount: 2300),
        .init(month: "Mar", amount: 1800),
        .init(month: "Apr", amount: 3100),
        .init(month: "May", amount: 2800)
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            // MARK: - Header and Config Button
            HStack {
                Text("Sales Dashboard")
                    .font(.title)
                Spacer()
                Button("Configure") {
                    showConfigModal = true
                }
            }
            .padding(.horizontal)
            
            // MARK: - Conceptual Chart Area
            if chartType == .bar {
                Chart(sampleData) {
                    BarMark(
                        x: .value("Month", $0.month),
                        y: .value("Sales", $0.amount)
                    )
                }
                .padding()
            } else if chartType == .line {
                Chart(sampleData) {
                    LineMark(
                        x: .value("Month", $0.month),
                        y: .value("Sales", $0.amount)
                    )
                    PointMark(
                        x: .value("Month", $0.month),
                        y: .value("Sales", $0.amount)
                    )
                }
                .padding()
            }
            
            Spacer() // Push content to top
        }
        .sheet(isPresented: $showConfigModal) {
            // MARK: - Configuration Modal
            DashboardConfigurationModal(chartType: $chartType, timeRange: $timeRange)
        }
        .navigationTitle("Dashboard")
    }
}

// MARK: - Configuration Modal View (Conceptual)
struct DashboardConfigurationModal: View {
    @Environment(\.dismiss) var dismiss
    @Binding var chartType: ChartType
    @Binding var timeRange: TimeRange
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chart Settings")) {
                    Picker("Chart Type", selection: $chartType) {
                        Text("Bar Chart").tag(ChartType.bar)
                        Text("Line Chart").tag(ChartType.line)
                        // Add more chart types conceptually
                    }
                    Picker("Time Range", selection: $timeRange) {
                        Text("Month").tag(TimeRange.month)
                        Text("Quarter").tag(TimeRange.quarter)
                        Text("Year").tag(TimeRange.year)
                        // Add more time ranges conceptually
                    }
                }
                
                Section(header: Text("Data Filters (Conceptual)")) {
                    Text("Add data filtering options here...")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Configure Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 400, minHeight: 300, idealHeight: 400)
    }
}

// MARK: - Data Models and Enums

// Reusing SalesData from the initial example if available, or define simple struct
struct SalesData: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

enum ChartType {
    case bar, line // Add more as needed conceptually
}

enum TimeRange {
    case month, quarter, year // Add more as needed conceptually
}

// Sample Data - If not reusing from other files
// let sampleData: [SalesData] = [ ... ]

// MARK: - Preview
struct DataDashboardWithConfig_Previews: PreviewProvider {
    static var previews: some View {
        DataDashboardWithConfig()
    }
} 