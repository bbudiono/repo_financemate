//
//  AnimatedDataDashboard.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// # Animated Data Dashboard
/// This example demonstrates advanced data visualization techniques in SwiftUI:
/// - Custom animated charts with fluid transitions
/// - Interactive elements with haptic feedback
/// - Animated data value transitions
/// - Custom drawing with paths and shapes
/// - Real-time data updates with smooth animations
/// - Accessibility enhancements for data visualization
struct AnimatedDataDashboard: View {
    // MARK: - State
    
    /// Selected time range for data display
    @State private var selectedTimeRange: TimeRange = .week
    
    /// Selected data category to highlight
    @State private var selectedCategory: DataCategory = .all
    
    /// Whether to show detailed information view
    @State private var showingDetail = false
    
    /// Demo data for the visualization
    @State private var salesData = SalesData.sampleData
    
    /// Tracks when the view has appeared for entrance animations
    @State private var hasAppeared = false
    
    // MARK: - Animation Properties
    
    /// Animation for chart value transitions
    private let chartAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    
    /// Animation for UI element transitions
    private let uiAnimation = Animation.easeInOut(duration: 0.3)
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    dashboardHeader
                    
                    // Time range selector
                    timeRangeSelector
                        .padding(.horizontal)
                    
                    // Main chart card
                    mainChartCard(width: geometry.size.width)
                    
                    // Category selector
                    categorySelector
                        .padding(.horizontal)
                    
                    // Statistics grid
                    statsGrid
                    
                    // Detail card
                    if showingDetail {
                        detailCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding()
                .onAppear {
                    // Trigger entrance animations
                    animateEntrance()
                    
                    // Start simulated real-time updates
                    startDataUpdates()
                }
            }
        }
        .navigationTitle("Analytics Dashboard")
        .preferredColorScheme(.light) // Works with both light and dark
    }
    
    // MARK: - Dashboard Components
    
    /// Header section with title and refresh button
    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sales Performance")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Updated just now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: refreshData) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(8)
                    .background(Circle().fill(Color.accentColor.opacity(0.1)))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .opacity(hasAppeared ? 1 : 0)
        .animation(uiAnimation.delay(0.1), value: hasAppeared)
    }
    
    /// Time range selection control
    private var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button(action: { selectTimeRange(range) }) {
                    Text(range.rawValue)
                        .font(.callout)
                        .fontWeight(selectedTimeRange == range ? .semibold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTimeRange == range ? 
                                      Color.accentColor : Color.clear)
                        )
                        .foregroundColor(selectedTimeRange == range ? 
                                         .white : .primary)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .opacity(hasAppeared ? 1 : 0)
        .animation(uiAnimation.delay(0.2), value: hasAppeared)
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time range selector")
        .accessibilityHint("Select a time range to view data for")
    }
    
    /// Main animated chart component
    private func mainChartCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            // Chart title
            Text("Revenue Trends")
                .font(.headline)
                .foregroundColor(.primary)
            
            // The chart itself
            AnimatedBarChart(
                data: filteredData,
                selectedCategory: selectedCategory,
                maxValue: maxValue
            )
            .frame(height: 220)
            .animation(chartAnimation, value: filteredData)
            .animation(chartAnimation, value: selectedCategory)
            
            // Legend
            HStack(spacing: 16) {
                ForEach(DataCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                    legendItem(for: category)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 50)
        .animation(uiAnimation.delay(0.3), value: hasAppeared)
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Revenue trends chart")
        .accessibilityHint("Shows sales data over time with category breakdowns")
    }
    
    /// Category selection buttons
    private var categorySelector: some View {
        HStack(spacing: 10) {
            ForEach(DataCategory.allCases, id: \.self) { category in
                Button(action: { selectCategory(category) }) {
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(selectedCategory == category ? .semibold : .regular)
                        .foregroundColor(selectedCategory == category ? 
                                        category.color : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategory == category ? 
                                       category.color : Color.gray.opacity(0.3), 
                                       lineWidth: 1.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
        }
        .opacity(hasAppeared ? 1 : 0)
        .animation(uiAnimation.delay(0.4), value: hasAppeared)
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Category filter")
        .accessibilityHint("Filter chart data by product category")
    }
    
    /// Statistics summary grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            statCard(
                title: "Total Revenue",
                value: "$\(totalRevenue)",
                icon: "dollarsign.circle.fill",
                color: .green,
                trend: "+12%"
            )
            
            statCard(
                title: "Avg Order Value",
                value: "$\(averageOrderValue)",
                icon: "cart.fill",
                color: .blue,
                trend: "+5%"
            )
            
            statCard(
                title: "Conversion Rate",
                value: "\(conversionRate)%",
                icon: "arrow.triangle.2.circlepath",
                color: .purple,
                trend: "+2%"
            )
            
            statCard(
                title: "Active Users",
                value: "\(activeUsers)",
                icon: "person.2.fill",
                color: .orange,
                trend: "+18%"
            )
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 30)
        .animation(uiAnimation.delay(0.5), value: hasAppeared)
    }
    
    /// Detail information card
    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header with close button
            HStack {
                Text("Detailed Analysis")
                    .font(.headline)
                
                Spacer()
                
                Button(action: toggleDetail) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Detail metrics
            VStack(spacing: 12) {
                metricRow(label: "Revenue Growth", value: "+15.2%", color: .green)
                metricRow(label: "New Customers", value: "342", color: .blue)
                metricRow(label: "Repeat Purchase Rate", value: "68%", color: .purple)
                metricRow(label: "Avg Time on Site", value: "4:35", color: .orange)
            }
            .padding(.top, 5)
            
            // Recommendation
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommendation")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Focus on mobile optimization to improve conversion rates, as 73% of your traffic comes from mobile devices.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 5)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        )
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Detailed analysis")
        .accessibilityAddTraits(.isModal)
    }
    
    // MARK: - Support Views
    
    /// Creates a legend item for a data category
    private func legendItem(for category: DataCategory) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(category.color)
                .frame(width: 10, height: 10)
            
            Text(category.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    /// Creates a statistic card
    private func statCard(title: String, value: String, icon: String, color: Color, trend: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                    )
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.1))
                    )
                    .foregroundColor(.green)
            }
            
            // Value and label
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        )
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(trend)")
    }
    
    /// Creates a metric row for the detail card
    private func metricRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Filters data based on selected time range and category
    private var filteredData: [DataPoint] {
        var filtered = salesData.filter { $0.timeRange == selectedTimeRange }
        
        // If a specific category is selected, highlight it
        if selectedCategory != .all {
            // Keep all data points but mark only the selected category as highlighted
            filtered = filtered.map { point in
                var newPoint = point
                newPoint.highlighted = (point.category == selectedCategory)
                return newPoint
            }
        } else {
            // When "All" is selected, nothing is specifically highlighted
            filtered = filtered.map { point in
                var newPoint = point
                newPoint.highlighted = false
                return newPoint
            }
        }
        
        return filtered
    }
    
    /// Calculate the maximum value for chart scaling
    private var maxValue: Double {
        let maximum = salesData
            .filter { $0.timeRange == selectedTimeRange }
            .map(\.value)
            .max() ?? 100
        
        // Add 10% padding to the maximum for better visualization
        return maximum * 1.1
    }
    
    /// Calculate total revenue for stats
    private var totalRevenue: String {
        let total = filteredData
            .map(\.value)
            .reduce(0, +)
        
        return String(format: "%.1fK", total / 1000)
    }
    
    /// Simulate average order value
    private var averageOrderValue: String {
        return "78.5"
    }
    
    /// Simulate conversion rate
    private var conversionRate: String {
        return "4.7"
    }
    
    /// Simulate active users
    private var activeUsers: String {
        return "12.4K"
    }
    
    // MARK: - Actions
    
    /// Select a time range for data display
    private func selectTimeRange(_ range: TimeRange) {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(chartAnimation) {
            selectedTimeRange = range
        }
    }
    
    /// Select a data category to highlight
    private func selectCategory(_ category: DataCategory) {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(chartAnimation) {
            selectedCategory = category
        }
    }
    
    /// Toggle detail information view
    private func toggleDetail() {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingDetail.toggle()
        }
    }
    
    /// Refresh data with animation
    private func refreshData() {
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Simulate data refresh
        withAnimation(chartAnimation) {
            salesData = SalesData.generateRandomData()
        }
    }
    
    /// Animate entrance of UI elements
    private func animateEntrance() {
        // Delay to allow view layout to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(uiAnimation) {
                hasAppeared = true
            }
        }
    }
    
    /// Start simulated real-time data updates
    private func startDataUpdates() {
        // Simulates real-time data updates every 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Simulate small data changes
            withAnimation(chartAnimation) {
                // Update a random data point
                let randomIndex = Int.random(in: 0..<salesData.count)
                if randomIndex < salesData.count {
                    salesData[randomIndex].value += Double.random(in: -10...20)
                    if salesData[randomIndex].value < 10 {
                        salesData[randomIndex].value = 10
                    }
                }
            }
            
            // Continue updates if the view is still active
            startDataUpdates()
        }
    }
}

// MARK: - Animated Bar Chart View

/// Custom bar chart with fluid animations between data states
struct AnimatedBarChart: View {
    let data: [DataPoint]
    let selectedCategory: DataCategory
    let maxValue: Double
    
    /// Bar width based on data count
    private var barWidth: CGFloat {
        let count = CGFloat(data.count)
        // Calculate dynamically, but with a minimum width
        return max(10, min(30, 300 / count - 8))
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    // Bar group for each data point
                    VStack(spacing: 0) {
                        // The actual bar
                        barRect(for: point, in: geometry)
                        
                        // X-axis label
                        Text(point.label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 20) // Space for labels
            .padding(.top, 20)    // Space for value labels
            .overlay(alignment: .topLeading) {
                // Y-axis labels
                yAxisLabels(in: geometry)
            }
        }
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Bar chart showing \(data.count) data points")
        .accessibilityValue("Maximum value: \(Int(maxValue))")
    }
    
    /// Create a bar rectangle with animations
    private func barRect(for point: DataPoint, in geometry: GeometryProxy) -> some View {
        let height = geometry.size.height - 40 // Subtract space for labels
        let barHeight = height * point.value / maxValue
        
        return Rectangle()
            .fill(barColor(for: point))
            .frame(width: barWidth, height: barHeight)
            // Custom rounded corners just at the top
            .mask(
                RoundedCorner(radius: 4, corners: [.topLeft, .topRight])
            )
            // Apply effects based on highlight state
            .scaleEffect(
                point.highlighted ? 1.05 : 1.0,
                anchor: .bottom
            )
            .brightness(point.highlighted ? 0.1 : 0)
            .shadow(
                color: point.highlighted ? point.category.color.opacity(0.4) : .clear,
                radius: 4, y: 2
            )
            // Overlay value on top of bar
            .overlay(alignment: .top) {
                if point.highlighted || selectedCategory == .all {
                    Text("\(Int(point.value))")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(
                            Capsule()
                                .fill(point.category.color)
                        )
                        .offset(y: -15)
                        .opacity(barHeight > 30 ? 1 : 0) // Only show for taller bars
                }
            }
            // Accessibility
            .accessibilityLabel("\(point.label): \(Int(point.value))")
            .accessibilityValue(point.category.name)
    }
    
    /// Create Y-axis labels
    private func yAxisLabels(in geometry: GeometryProxy) -> some View {
        let height = geometry.size.height - 40
        
        return VStack(alignment: .leading) {
            ForEach(0..<4) { i in
                Text("\(Int(maxValue * Double(3 - i) / 3))")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .frame(height: 20)
            }
            Spacer()
        }
        .frame(height: height)
        .padding(.trailing, 5)
        .opacity(0.7) // Subtle appearance
    }
    
    /// Determine bar color based on data point
    private func barColor(for point: DataPoint) -> Color {
        if selectedCategory == .all {
            return point.category.color
        } else if point.highlighted {
            return point.category.color
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Custom Shapes

/// Custom shape for rounded corners only on specified edges
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Models and Data

/// Time range options
enum TimeRange: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

/// Data categories with colors
enum DataCategory: CaseIterable {
    case all
    case electronics
    case clothing
    case home
    case accessories
    
    var name: String {
        switch self {
        case .all: return "All"
        case .electronics: return "Electronics"
        case .clothing: return "Clothing"
        case .home: return "Home"
        case .accessories: return "Accessories"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .electronics: return .blue
        case .clothing: return .purple
        case .home: return .orange
        case .accessories: return .green
        }
    }
}

/// Single data point for visualization
struct DataPoint: Identifiable {
    let id = UUID()
    let label: String
    var value: Double
    let category: DataCategory
    let timeRange: TimeRange
    var highlighted: Bool = false
}

/// Sample data generator
struct SalesData {
    /// Generate sample data for demonstration
    static var sampleData: [DataPoint] {
        var data: [DataPoint] = []
        
        // Day data
        for hour in 0..<24 where hour % 3 == 0 {
            let hourLabel = "\(hour):00"
            data.append(DataPoint(label: hourLabel, value: Double.random(in: 50...200), category: .electronics, timeRange: .day))
            data.append(DataPoint(label: hourLabel, value: Double.random(in: 30...150), category: .clothing, timeRange: .day))
            data.append(DataPoint(label: hourLabel, value: Double.random(in: 20...100), category: .home, timeRange: .day))
            data.append(DataPoint(label: hourLabel, value: Double.random(in: 10...80), category: .accessories, timeRange: .day))
        }
        
        // Week data
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for day in weekdays {
            data.append(DataPoint(label: day, value: Double.random(in: 100...300), category: .electronics, timeRange: .week))
            data.append(DataPoint(label: day, value: Double.random(in: 80...250), category: .clothing, timeRange: .week))
            data.append(DataPoint(label: day, value: Double.random(in: 50...200), category: .home, timeRange: .week))
            data.append(DataPoint(label: day, value: Double.random(in: 30...150), category: .accessories, timeRange: .week))
        }
        
        // Month data
        for week in 1...4 {
            let weekLabel = "W\(week)"
            data.append(DataPoint(label: weekLabel, value: Double.random(in: 300...600), category: .electronics, timeRange: .month))
            data.append(DataPoint(label: weekLabel, value: Double.random(in: 200...500), category: .clothing, timeRange: .month))
            data.append(DataPoint(label: weekLabel, value: Double.random(in: 150...400), category: .home, timeRange: .month))
            data.append(DataPoint(label: weekLabel, value: Double.random(in: 100...300), category: .accessories, timeRange: .month))
        }
        
        // Year data
        let months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
        for month in months {
            data.append(DataPoint(label: month, value: Double.random(in: 1000...2000), category: .electronics, timeRange: .year))
            data.append(DataPoint(label: month, value: Double.random(in: 800...1800), category: .clothing, timeRange: .year))
            data.append(DataPoint(label: month, value: Double.random(in: 600...1600), category: .home, timeRange: .year))
            data.append(DataPoint(label: month, value: Double.random(in: 400...1400), category: .accessories, timeRange: .year))
        }
        
        return data
    }
    
    /// Generate new random data (maintains structure but changes values)
    static func generateRandomData() -> [DataPoint] {
        // Start with a structure copy of the sample data
        let structure = sampleData
        
        // Generate new values while keeping the same structure
        return structure.map { point in
            var newPoint = point
            
            // Randomize values but keep reasonable for each time range
            switch point.timeRange {
            case .day:
                newPoint.value = Double.random(in: 10...250)
            case .week:
                newPoint.value = Double.random(in: 30...350)
            case .month:
                newPoint.value = Double.random(in: 100...650)
            case .year:
                newPoint.value = Double.random(in: 400...2200)
            }
            
            return newPoint
        }
    }
}

// MARK: - Preview

struct AnimatedDataDashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnimatedDataDashboard()
        }
    }
} 