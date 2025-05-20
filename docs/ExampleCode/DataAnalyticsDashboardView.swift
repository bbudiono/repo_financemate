import SwiftUI
import Charts

/// # Data Analytics Dashboard View
/// Professional dashboard with:
/// - Multiple interactive charts
/// - Customizable time ranges
/// - Data filtering capabilities
/// - Key performance metrics
/// - Export functionality
struct DataAnalyticsDashboardView: View {
    // MARK: - State
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedCategory: DataCategory = .all
    @State private var showDataTable = false
    @State private var isRefreshing = false
    @State private var selectedDataPoint: DataPoint?
    @State private var showExportOptions = false
    @State private var dateRange = DateRange(
        start: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
        end: Date()
    )
    
    // Sample data
    private let salesData = SalesDataProvider.monthlySalesData
    private let visitData = SalesDataProvider.websiteVisitsData
    private let conversionData = SalesDataProvider.conversionRateData
    private let productData = SalesDataProvider.productPerformanceData
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Dashboard header
            dashboardHeader
                .padding()
                .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Main dashboard content
            ScrollView {
                VStack(spacing: 16) {
                    // KPI metrics row
                    metricsRow
                        .padding()
                    
                    // Main charts section
                    HStack(alignment: .top, spacing: 16) {
                        // Sales trend chart
                        salesTrendChart
                            .frame(height: 300)
                        
                        // Traffic sources chart
                        trafficSourcesChart
                            .frame(height: 300)
                    }
                    .padding()
                    
                    // Secondary charts row
                    HStack(alignment: .top, spacing: 16) {
                        // Conversion rates chart
                        conversionRatesChart
                            .frame(height: 250)
                        
                        // Top products chart
                        topProductsChart
                            .frame(height: 250)
                    }
                    .padding()
                    
                    // Conditional data table
                    if showDataTable {
                        dataTable
                            .padding()
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showExportOptions) {
            exportOptionsView
        }
    }
    
    // MARK: - UI Components
    
    // Dashboard header with controls
    private var dashboardHeader: some View {
        HStack {
            // Dashboard title
            VStack(alignment: .leading, spacing: 4) {
                Text("Analytics Dashboard")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Last updated: \(formatDate(Date()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Control panel
            HStack(spacing: 16) {
                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                // Category filter
                Picker("Category", selection: $selectedCategory) {
                    ForEach(DataCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .frame(width: 150)
                
                // Action buttons
                Button(action: refreshData) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
                .disabled(isRefreshing)
                
                Button(action: toggleDataTable) {
                    Label("Data Table", systemImage: showDataTable ? "table.fill" : "table")
                }
                
                Button(action: { showExportOptions = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
    // KPI metrics cards row
    private var metricsRow: some View {
        HStack(spacing: 16) {
            // Total Revenue
            MetricCard(
                title: "Total Revenue",
                value: "$128,459",
                trend: "+12.5%",
                trendDirection: .up,
                icon: "dollarsign.circle.fill",
                color: .blue
            )
            
            // Total Orders
            MetricCard(
                title: "Total Orders",
                value: "1,482",
                trend: "+8.3%",
                trendDirection: .up,
                icon: "cart.fill",
                color: .green
            )
            
            // Conversion Rate
            MetricCard(
                title: "Conversion Rate",
                value: "3.2%",
                trend: "-0.4%",
                trendDirection: .down,
                icon: "arrow.triangle.swap",
                color: .red
            )
            
            // Average Order Value
            MetricCard(
                title: "Avg. Order Value",
                value: "$86.68",
                trend: "+5.7%",
                trendDirection: .up,
                icon: "creditcard.fill",
                color: .purple
            )
        }
        .frame(height: 120)
    }
    
    // Sales trend chart
    private var salesTrendChart: some View {
        ChartCard(title: "Sales Trend", subtitle: "Revenue over time") {
            Chart {
                ForEach(salesData) { item in
                    LineMark(
                        x: .value("Month", item.date, unit: .month),
                        y: .value("Revenue", item.value)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Month", item.date, unit: .month),
                        y: .value("Revenue", item.value)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                    
                    if let selectedPoint = selectedDataPoint,
                       selectedPoint.id == item.id {
                        PointMark(
                            x: .value("Month", item.date, unit: .month),
                            y: .value("Revenue", item.value)
                        )
                        .foregroundStyle(Color.blue)
                        .symbolSize(100)
                    }
                }
                
                RuleMark(y: .value("Target", 85000))
                    .foregroundStyle(Color.red.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .trailing) {
                        Text("Target")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .chartYScale(domain: 0...100000)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard x >= 0, x <= geometry[proxy.plotAreaFrame].width else {
                                        selectedDataPoint = nil
                                        return
                                    }
                                    
                                    let xPosition = proxy.position(forX: x)
                                    let closestPoint = salesData.min(by: {
                                        abs(proxy.position(forX: Calendar.current.startOfDay(for: $0.date)).x - xPosition.x) <
                                        abs(proxy.position(forX: Calendar.current.startOfDay(for: $1.date)).x - xPosition.x)
                                    })
                                    selectedDataPoint = closestPoint
                                }
                                .onEnded { _ in
                                    // Keep the selection visible
                                }
                        )
                }
            }
        }
    }
    
    // Traffic sources donut chart
    private var trafficSourcesChart: some View {
        ChartCard(title: "Traffic Sources", subtitle: "Visitors by channel") {
            Chart {
                ForEach(Array(trafficSources.enumerated()), id: \.offset) { index, source in
                    SectorMark(
                        angle: .value("Value", source.value),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Source", source.name))
                    .annotation(position: .overlay) {
                        Text("\(source.value)%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .chartForegroundStyleScale([
                "Direct": Color.blue,
                "Organic Search": Color.green,
                "Social Media": Color.purple,
                "Email": Color.orange,
                "Referral": Color.pink
            ])
            .frame(height: 240)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(trafficSources) { source in
                    HStack {
                        Circle()
                            .fill(sourceColor(for: source.name))
                            .frame(width: 12, height: 12)
                        
                        Text(source.name)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(source.value)%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.top)
        }
    }
    
    // Conversion rates chart
    private var conversionRatesChart: some View {
        ChartCard(title: "Conversion Funnel", subtitle: "View-to-purchase steps") {
            Chart {
                ForEach(conversionSteps) { step in
                    BarMark(
                        x: .value("Step", step.name),
                        y: .value("Count", step.value)
                    )
                    .foregroundStyle(
                        Gradient(colors: [.purple.opacity(0.7), .purple])
                    )
                    .annotation(position: .top) {
                        VStack {
                            Text("\(step.value)")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            if let percentage = step.percentage {
                                Text("(\(percentage)%)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                RuleMark(
                    y: .value("Previous Month", 32000)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(.gray)
                .annotation(position: .trailing) {
                    Text("Last Month")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .chartYScale(domain: 0...40000)
        }
    }
    
    // Top products chart
    private var topProductsChart: some View {
        ChartCard(title: "Top Products", subtitle: "By revenue") {
            Chart {
                ForEach(productData) { product in
                    BarMark(
                        x: .value("Revenue", product.revenue),
                        y: .value("Product", product.name)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .annotation(position: .trailing) {
                        Text("$\(Int(product.revenue))")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .chartXScale(domain: 0...20000)
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) { value in
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
        }
    }
    
    // Data table view
    private var dataTable: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sales Data Table")
                    .font(.headline)
                
                Spacer()
                
                Text("\(salesData.count) records")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Table header
            HStack {
                Text("Date")
                    .fontWeight(.medium)
                    .frame(width: 150, alignment: .leading)
                
                Text("Revenue")
                    .fontWeight(.medium)
                    .frame(width: 120, alignment: .trailing)
                
                Text("Orders")
                    .fontWeight(.medium)
                    .frame(width: 120, alignment: .trailing)
                
                Text("Avg. Order Value")
                    .fontWeight(.medium)
                    .frame(width: 150, alignment: .trailing)
                
                Text("YoY Change")
                    .fontWeight(.medium)
                    .frame(width: 120, alignment: .trailing)
            }
            .font(.caption)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
            
            // Table rows
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    ForEach(salesData) { item in
                        HStack {
                            Text(formatDate(item.date))
                                .frame(width: 150, alignment: .leading)
                            
                            Text("$\(Int(item.value))")
                                .frame(width: 120, alignment: .trailing)
                            
                            Text("\(Int(item.value / 80))")
                                .frame(width: 120, alignment: .trailing)
                            
                            Text("$\(Int(item.value / (item.value / 80)))")
                                .frame(width: 150, alignment: .trailing)
                            
                            HStack(spacing: 2) {
                                Image(systemName: item.yoy > 0 ? "arrow.up" : "arrow.down")
                                    .foregroundColor(item.yoy > 0 ? .green : .red)
                                    .font(.caption2)
                                
                                Text("\(abs(item.yoy), specifier: "%.1f")%")
                                    .foregroundColor(item.yoy > 0 ? .green : .red)
                            }
                            .frame(width: 120, alignment: .trailing)
                        }
                        .font(.caption)
                        .padding(.vertical, 8)
                        .background(
                            Rectangle()
                                .fill(Color.white.opacity(0.001)) // Nearly transparent for hit testing
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.1)),
                            alignment: .bottom
                        )
                    }
                }
            }
            .frame(height: 300)
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
    
    // Export options view
    private var exportOptionsView: some View {
        VStack(spacing: 20) {
            Text("Export Dashboard Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Select date range:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    DatePicker("Start date", selection: $dateRange.start, displayedComponents: [.date])
                    
                    DatePicker("End date", selection: $dateRange.end, displayedComponents: [.date])
                }
                
                Divider()
                
                Text("Export format:")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    FormatButton(title: "Excel (.xlsx)", icon: "tablecells", isSelected: true)
                    FormatButton(title: "CSV (.csv)", icon: "list.bullet", isSelected: false)
                    FormatButton(title: "PDF Report", icon: "doc.text", isSelected: false)
                }
                
                Divider()
                
                Text("Data to include:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(["Sales data", "Traffic data", "Conversion metrics", "Product performance"], id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundColor(.blue)
                            
                            Text(item)
                                .font(.body)
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    showExportOptions = false
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Export") {
                    exportData()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 450)
        .background(Color(.windowBackgroundColor))
    }
    
    // MARK: - Helper Methods
    
    private func refreshData() {
        isRefreshing = true
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRefreshing = false
        }
    }
    
    private func toggleDataTable() {
        showDataTable.toggle()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func sourceColor(for name: String) -> Color {
        switch name {
        case "Direct": return .blue
        case "Organic Search": return .green
        case "Social Media": return .purple
        case "Email": return .orange
        case "Referral": return .pink
        default: return .gray
        }
    }
    
    private func exportData() {
        // Implement export functionality (would create a file in real app)
        showExportOptions = false
    }
    
    // MARK: - Sample Data
    
    private var trafficSources: [DataItem] {
        [
            DataItem(id: 1, name: "Direct", value: 35),
            DataItem(id: 2, name: "Organic Search", value: 25),
            DataItem(id: 3, name: "Social Media", value: 18),
            DataItem(id: 4, name: "Email", value: 15),
            DataItem(id: 5, name: "Referral", value: 7)
        ]
    }
    
    private var conversionSteps: [ConversionStep] {
        [
            ConversionStep(id: 1, name: "Visitors", value: 35428, percentage: 100),
            ConversionStep(id: 2, name: "Product Views", value: 21257, percentage: 60),
            ConversionStep(id: 3, name: "Add to Cart", value: 8857, percentage: 25),
            ConversionStep(id: 4, name: "Checkout", value: 4251, percentage: 12),
            ConversionStep(id: 5, name: "Purchases", value: 1482, percentage: 4)
        ]
    }
}

// MARK: - Supporting Views

// Metric card component
struct MetricCard: View {
    let title: String
    let value: String
    let trend: String
    let trendDirection: TrendDirection
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and icon
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .default))
            
            // Trend
            HStack(spacing: 4) {
                Image(systemName: trendDirection == .up ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundColor(trendDirection == .up ? .green : .red)
                
                Text(trend)
                    .font(.caption)
                    .foregroundColor(trendDirection == .up ? .green : .red)
                
                Text("vs. previous period")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
}

// Chart card component
struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    
    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Chart content
            content
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.07), radius: 5, x: 0, y: 2)
    }
}

// Format button for export options
struct FormatButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(isSelected ? .white : .blue)
                .frame(width: 60, height: 60)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

// Data point for charts
struct DataPoint: Identifiable {
    let id: Int
    let date: Date
    let value: Double
    let yoy: Double // Year-over-year change percentage
    
    init(id: Int, date: Date, value: Double, yoy: Double = 0.0) {
        self.id = id
        self.date = date
        self.value = value
        self.yoy = yoy
    }
}

// Simple data item
struct DataItem: Identifiable {
    let id: Int
    let name: String
    let value: Int
}

// Product performance data
struct ProductData: Identifiable {
    let id: Int
    let name: String
    let revenue: Double
    let units: Int
}

// Conversion funnel step
struct ConversionStep: Identifiable {
    let id: Int
    let name: String
    let value: Int
    let percentage: Int?
}

// Date range for export
struct DateRange {
    var start: Date
    var end: Date
}

// Trend direction
enum TrendDirection {
    case up, down
}

// Time range options
enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case custom = "Custom"
}

// Data category filter options
enum DataCategory: String, CaseIterable {
    case all = "All Categories"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case home = "Home Goods"
    case health = "Health & Beauty"
}

// MARK: - Mock Data Provider

struct SalesDataProvider {
    // Generate monthly sales data
    static var monthlySalesData: [DataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<12).map { i in
            let month = calendar.date(byAdding: .month, value: -i, to: today)!
            // Create realistic patterns with some seasonality and trends
            let baseValue = Double.random(in: 60000...70000)
            let seasonality = sin(Double(i) / 2) * 15000
            let randomVariation = Double.random(in: -5000...5000)
            let trendFactor = Double(i) * 1000 // Slight growth over time
            
            // Calculate final value with constraints
            let finalValue = max(40000, min(100000, baseValue + seasonality + randomVariation - trendFactor))
            
            return DataPoint(
                id: i,
                date: month,
                value: finalValue,
                yoy: Double.random(in: -10...15)
            )
        }
    }
    
    // Website visits data - closely related to sales data but with higher numbers
    static var websiteVisitsData: [DataPoint] {
        return monthlySalesData.enumerated().map { index, salesPoint in
            let multiplier = Double.random(in: 2.8...3.5)
            return DataPoint(
                id: index,
                date: salesPoint.date,
                value: salesPoint.value * multiplier
            )
        }
    }
    
    // Conversion rate data - represents percentage of visitors making purchase
    static var conversionRateData: [DataPoint] {
        return monthlySalesData.enumerated().map { index, salesPoint in
            let conversionRate = (salesPoint.value / (salesPoint.value * Double.random(in: 2.8...3.5))) * 100
            return DataPoint(
                id: index,
                date: salesPoint.date,
                value: conversionRate
            )
        }
    }
    
    // Top-selling products by revenue
    static var productPerformanceData: [ProductData] {
        return [
            ProductData(id: 1, name: "Premium Headphones", revenue: 18250, units: 365),
            ProductData(id: 2, name: "Ultra HD Smart TV", revenue: 15780, units: 42),
            ProductData(id: 3, name: "Professional Camera", revenue: 12340, units: 76),
            ProductData(id: 4, name: "Wireless Earbuds", revenue: 9870, units: 548),
            ProductData(id: 5, name: "Designer Watch", revenue: 7650, units: 85)
        ]
    }
}

// MARK: - Previews

struct DataAnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DataAnalyticsDashboardView()
            .frame(width: 1200, height: 900)
    }
} 