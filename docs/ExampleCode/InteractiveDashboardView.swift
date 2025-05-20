//
//  InteractiveDashboardView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// An interactive dashboard view demonstrating advanced SwiftUI techniques
/// including animated charts, custom controls, and depth effects.
struct InteractiveDashboardView: View {
    // MARK: - Properties
    
    /// Tracks the selected time period for data visualization
    @State private var selectedPeriod: TimePeriod = .week
    
    /// Sample activity data for visualization
    @State private var activityData: [ActivityData] = ActivityData.sampleData
    
    /// Controls whether detailed view is showing
    @State private var showingDetail = false
    
    /// Animation phase for fluid background effects
    @State private var animationPhase: Double = 0
    
    /// Currently selected data point
    @State private var selectedDataPoint: ActivityData?
    
    // MARK: - Animation Properties
    private let backgroundAnimation = Animation.linear(duration: 20).repeatForever(autoreverses: false)
    private let chartAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    
    // MARK: - Constants
    private let cornerRadius: CGFloat = 24
    private let cardPadding: CGFloat = 20
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackgroundView(phase: animationPhase)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Dashboard header
                    headerView
                    
                    // Activity chart card
                    activityChartCard
                    
                    // Stats summary cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        StatCard(
                            title: "Productivity",
                            value: "78%",
                            icon: "chart.bar.fill",
                            color: .blue,
                            trend: .up,
                            trendValue: "+12%"
                        )
                        
                        StatCard(
                            title: "Focus Time",
                            value: "4.5 hrs",
                            icon: "timer",
                            color: .purple,
                            trend: .up,
                            trendValue: "+0.8 hrs"
                        )
                        
                        StatCard(
                            title: "Tasks Completed",
                            value: "24",
                            icon: "checkmark.circle.fill",
                            color: .green,
                            trend: .down,
                            trendValue: "-3"
                        )
                        
                        StatCard(
                            title: "Streak",
                            value: "7 days",
                            icon: "flame.fill",
                            color: .orange,
                            trend: .up,
                            trendValue: "+2 days"
                        )
                    }
                    
                    // Custom progress gauge
                    progressGaugeView
                }
                .padding()
            }
        }
        .onAppear {
            // Start background animation
            withAnimation(backgroundAnimation) {
                animationPhase = 360
            }
            
            // Animate in the chart data
            animateChartData()
        }
        // Setup sheet for detail view
        .sheet(item: $selectedDataPoint) { dataPoint in
            DetailView(data: dataPoint, dismiss: {
                selectedDataPoint = nil
            })
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Daily overview & stats")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // User avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Text("JS")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 6)
    }
    
    // MARK: - Activity Chart Card
    private var activityChartCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Card header
            HStack {
                Text("Activity Trends")
                    .font(.headline)
                
                Spacer()
                
                // Time period segmented control
                periodSelector
            }
            
            // Chart visualization
            VStack(spacing: 15) {
                // Activity bars
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(activityData) { data in
                        ActivityBar(
                            data: data,
                            maxValue: activityData.map(\.value).max() ?? 100,
                            isSelected: selectedDataPoint?.id == data.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDataPoint = data
                            }
                        }
                    }
                }
                .frame(height: 220)
                .padding(.top, 10)
                
                // Chart labels
                HStack(spacing: 8) {
                    ForEach(activityData) { data in
                        Text(data.label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                LegendItem(color: .blue, label: "Productivity")
                LegendItem(color: .purple, label: "Focus Time")
                LegendItem(color: .green, label: "Tasks")
            }
            .padding(.top, 5)
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
    
    // MARK: - Progress Gauge View
    private var progressGaugeView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Goal Progress")
                .font(.headline)
            
            HStack {
                // Circular progress gauge
                ZStack {
                    // Background track
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 18)
                        .frame(width: 120, height: 120)
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: 0.65) // 65% complete
                        .stroke(
                            AngularGradient(
                                colors: [.blue, .purple, .pink],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    // Center value
                    VStack(spacing: 2) {
                        Text("65%")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.trailing, 10)
                
                VStack(alignment: .leading, spacing: 15) {
                    // Progress stats
                    ProgressStat(label: "Tasks Completed", value: "18/25", color: .blue)
                    ProgressStat(label: "Hours Focused", value: "24/40", color: .purple)
                    ProgressStat(label: "Productivity Score", value: "78/100", color: .pink)
                }
            }
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
            )
        }
    }
    
    // MARK: - Period Selector Control
    private var periodSelector: some View {
        HStack {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(chartAnimation) {
                        selectedPeriod = period
                        // Simulate data change
                        generateNewData(for: period)
                    }
                }) {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundColor(selectedPeriod == period ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedPeriod == period ? 
                                      LinearGradient(colors: [.blue, .purple], 
                                                    startPoint: .leading, 
                                                    endPoint: .trailing) : 
                                        Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Helper Methods
    
    /// Generates new data based on selected time period
    private func generateNewData(for period: TimePeriod) {
        let dataPoints = period == .day ? 24 : (period == .week ? 7 : 30)
        
        // Create sample data with randomized values
        activityData = []
        
        for i in 0..<dataPoints {
            let value = Double.random(in: 20...100)
            let label: String
            
            switch period {
            case .day:
                label = "\(i)h"
            case .week:
                let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                label = days[i % 7]
            case .month:
                label = "\(i+1)"
            }
            
            activityData.append(ActivityData(id: UUID(), label: label, value: value))
        }
        
        // Keep reasonable number for display
        if period == .month {
            activityData = Array(activityData.prefix(10))
        }
        
        // Animate the appearance
        animateChartData()
    }
    
    /// Animates the chart data appearing
    private func animateChartData() {
        // Store original values
        let originalData = activityData
        
        // Reset the values to zero
        for i in 0..<activityData.count {
            activityData[i].value = 0
        }
        
        // Animate to the actual values with a sequence for each bar
        for i in 0..<activityData.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    activityData[i].value = originalData[i].value
                }
            }
        }
    }
}

// MARK: - Supporting Models and Enums

/// Represents different time periods for data visualization
enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
}

/// Represents trend direction for statistics
enum TrendDirection {
    case up, down, neutral
}

/// Model for activity data points
struct ActivityData: Identifiable {
    var id: UUID
    var label: String
    var value: Double
    
    static var sampleData: [ActivityData] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days.map { day in
            ActivityData(id: UUID(), label: day, value: Double.random(in: 30...100))
        }
    }
}

// MARK: - Supporting Views

/// Beautiful animated background with floating particles
struct AnimatedBackgroundView: View {
    let phase: Double
    
    var body: some View {
        ZStack {
            // Base color
            Color(UIColor.systemBackground)
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    .blue.opacity(0.1),
                    .purple.opacity(0.05),
                    .blue.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Particle effects
            ForEach(0..<20) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                i % 2 == 0 ? .blue.opacity(0.2) : .purple.opacity(0.2),
                                i % 3 == 0 ? .pink.opacity(0.1) : .blue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 40...100), 
                           height: CGFloat.random(in: 40...100))
                    .position(
                        x: CGFloat.random(in: -50...500),
                        y: CGFloat.random(in: -50...1000)
                    )
                    .blur(radius: 15)
                    .rotationEffect(.degrees(phase) * (i % 2 == 0 ? 1 : -1) * 0.05)
                    .offset(x: sin(Double(i) + phase * .pi / 180) * 20,
                            y: cos(Double(i) + phase * .pi / 180) * 20)
            }
        }
    }
}

/// Interactive bar for activity chart
struct ActivityBar: View {
    let data: ActivityData
    let maxValue: Double
    let isSelected: Bool
    
    @State private var animatedHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            // Value bubble - only shows when selected
            if isSelected {
                Text("\(Int(data.value))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .offset(y: -5)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // The bar itself
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            .blue,
                            .purple
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(
                    height: animatedHeight
                )
                .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, 
                        radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(isSelected ? 0.6 : 0), lineWidth: 2)
                )
                .scaleEffect(x: isSelected ? 1.1 : 1, y: 1, anchor: .bottom)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // Animate the bar growing from zero to full height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                    animatedHeight = calculateHeight()
                }
            }
        }
        // Update height when data changes
        .onChange(of: data.value) { _ in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                animatedHeight = calculateHeight()
            }
        }
    }
    
    /// Calculate the height of the bar based on value and max value
    private func calculateHeight() -> CGFloat {
        let height = CGFloat(data.value / maxValue) * 200
        return max(height, 5) // Ensure a minimum height
    }
}

/// Legend item for chart
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Stats card view
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    let trendValue: String
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .rotationEffect(.degrees(isAnimating ? 10 : 0))
                
                Spacer()
                
                // Trend indicator
                HStack(spacing: 2) {
                    Image(systemName: trendIcon)
                        .font(.caption2)
                        .foregroundColor(trendColor)
                    
                    Text(trendValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(trendColor.opacity(0.1))
                )
            }
            
            // Value and title
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            // Subtle animation for the icon
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
                .delay(Double.random(in: 0...1))
            ) {
                isAnimating = true
            }
        }
    }
    
    /// Returns the appropriate icon for the trend direction
    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "arrow.right"
        }
    }
    
    /// Returns the appropriate color for the trend direction
    private var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
}

/// Progress statistic item
struct ProgressStat: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

/// Detail view shown when a chart item is selected
struct DetailView: View {
    let data: ActivityData
    let dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // Header with close button
            HStack {
                Text("Activity Details")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Detail card
            VStack(spacing: 30) {
                // Date/time info
                Text(data.label)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                // Value circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("\(Int(data.value))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Additional metrics
                VStack(spacing: 16) {
                    DetailMetricRow(label: "Activity Score", value: "\(Int(data.value))/100")
                    DetailMetricRow(label: "Tasks Completed", value: "\(Int(data.value / 10))")
                    DetailMetricRow(label: "Focus Minutes", value: "\(Int(data.value * 0.6))")
                }
                .padding(.top, 10)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 30)
    }
}

/// Detail metric row for the detail view
struct DetailMetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
struct InteractiveDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveDashboardView()
            .preferredColorScheme(.light)
        
        InteractiveDashboardView()
            .preferredColorScheme(.dark)
    }
} 