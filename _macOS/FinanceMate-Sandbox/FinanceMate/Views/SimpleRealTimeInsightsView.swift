import CoreData
import SwiftUI

struct SimpleRealTimeInsightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    @State private var showingInsightDetail = false
    @State private var isRefreshing = false

    private let tabs = ["Overview", "Trends", "Alerts", "AI Analysis"]

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("Insights Tabs", selection: $selectedTab) {
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
                    InsightsOverviewView()
                case 1:
                    InsightsTrendsView()
                case 2:
                    InsightsAlertsView()
                case 3:
                    InsightsAIAnalysisView()
                default:
                    InsightsOverviewView()
                }
            }
        }
        .navigationTitle("Real-Time Financial Insights")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    refreshInsights()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isRefreshing)
            }
        }
    }

    private func refreshInsights() {
        isRefreshing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isRefreshing = false
        }
    }
}

// MARK: - Tab Views

struct InsightsOverviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Health Score")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HealthScoreCard(score: 85, trend: .improving)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Insights")
                        .font(.title2)
                        .fontWeight(.semibold)

                    VStack(spacing: 12) {
                        InsightCard(
                            title: "Spending Pattern Alert",
                            description: "Your dining expenses increased 23% this month",
                            type: .warning,
                            recommendation: "Consider setting a dining budget limit"
                        )

                        InsightCard(
                            title: "Savings Opportunity",
                            description: "You could save $127/month by optimizing subscriptions",
                            type: .opportunity,
                            recommendation: "Review unused streaming services"
                        )

                        InsightCard(
                            title: "Budget Progress",
                            description: "You're 15% under budget this month",
                            type: .positive,
                            recommendation: "Great job staying within limits!"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Metrics")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        MetricCard(title: "Cash Flow", value: "+$1,234", trend: .up, color: .green)
                        MetricCard(title: "Expenses", value: "$3,456", trend: .down, color: .blue)
                        MetricCard(title: "Savings Rate", value: "23%", trend: .up, color: .purple)
                    }
                }

                Spacer()
            }
            .padding(20)
        }
    }
}

struct InsightsTrendsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Spending Trends")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    TrendCard(
                        category: "Food & Dining",
                        currentMonth: 856,
                        previousMonth: 723,
                        trend: .up,
                        percentage: 18.4
                    )

                    TrendCard(
                        category: "Transportation",
                        currentMonth: 234,
                        previousMonth: 267,
                        trend: .down,
                        percentage: 12.4
                    )

                    TrendCard(
                        category: "Entertainment",
                        currentMonth: 145,
                        previousMonth: 189,
                        trend: .down,
                        percentage: 23.3
                    )

                    TrendCard(
                        category: "Shopping",
                        currentMonth: 567,
                        previousMonth: 445,
                        trend: .up,
                        percentage: 27.4
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct InsightsAlertsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Financial Alerts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 12) {
                    AlertCard(
                        title: "Budget Exceeded",
                        message: "Dining category is 15% over budget",
                        severity: .high,
                        actionRequired: true
                    )

                    AlertCard(
                        title: "Unusual Transaction",
                        message: "Large expense detected: $1,200 at TechStore",
                        severity: .medium,
                        actionRequired: false
                    )

                    AlertCard(
                        title: "Bill Due Soon",
                        message: "Credit card payment due in 3 days",
                        severity: .low,
                        actionRequired: true
                    )

                    AlertCard(
                        title: "Subscription Renewal",
                        message: "Premium subscription renewing tomorrow",
                        severity: .low,
                        actionRequired: false
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

struct InsightsAIAnalysisView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("AI-Powered Analysis")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 16) {
                    AIAnalysisCard(
                        title: "Spending Behavior Analysis",
                        insight: "Your spending patterns suggest you're more likely to overspend on weekends. Consider setting weekend spending alerts.",
                        confidence: 92,
                        category: "Behavioral"
                    )

                    AIAnalysisCard(
                        title: "Savings Optimization",
                        insight: "Based on your income and expenses, you could increase savings by 8% by adjusting recurring subscriptions.",
                        confidence: 87,
                        category: "Optimization"
                    )

                    AIAnalysisCard(
                        title: "Financial Goal Prediction",
                        insight: "At your current savings rate, you'll reach your emergency fund goal 2 months ahead of schedule.",
                        confidence: 94,
                        category: "Forecasting"
                    )

                    AIAnalysisCard(
                        title: "Risk Assessment",
                        insight: "Your financial stability score is strong. Consider investing surplus funds for better returns.",
                        confidence: 78,
                        category: "Risk Management"
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views

struct HealthScoreCard: View {
    let score: Int
    let trend: TrendDirection

    var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(scoreColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("/ 100")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        HStack(spacing: 4) {
                            Image(systemName: trend == .improving ? "arrow.up" : "arrow.down")
                                .font(.caption)
                                .foregroundColor(trend == .improving ? .green : .red)
                            Text(trend == .improving ? "Improving" : "Declining")
                                .font(.caption)
                                .foregroundColor(trend == .improving ? .green : .red)
                        }
                    }
                }

                Text("Financial Health Score")
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Spacer()

            CircularProgressView(progress: Double(score) / 100, color: scoreColor)
                .frame(width: 80, height: 80)
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let type: InsightType
    let recommendation: String

    var iconName: String {
        switch type {
        case .warning: return "exclamationmark.triangle.fill"
        case .opportunity: return "lightbulb.fill"
        case .positive: return "checkmark.circle.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .warning: return .orange
        case .opportunity: return .blue
        case .positive: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            if !recommendation.isEmpty {
                Text("💡 \(recommendation)")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(iconColor.opacity(0.1))
                    .foregroundColor(iconColor)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundColor(trend == .up ? .green : .red)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TrendCard: View {
    let category: String
    let currentMonth: Double
    let previousMonth: Double
    let trend: TrendDirection
    let percentage: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("This month: $\(Int(currentMonth))")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text("Last month: $\(Int(previousMonth))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                        .font(.caption)
                        .foregroundColor(trend == .up ? .red : .green)
                    Text("\(String(format: "%.1f", percentage))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(trend == .up ? .red : .green)
                }

                Text(trend == .up ? "Increase" : "Decrease")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct AlertCard: View {
    let title: String
    let message: String
    let severity: AlertSeverity
    let actionRequired: Bool

    var severityColor: Color {
        switch severity {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(severityColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if actionRequired {
                Button("View Details") {
                    // Open alert details or navigate to relevant view
                    if let url = URL(string: "financemate://alerts/\(alert.id)") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct AIAnalysisCard: View {
    let title: String
    let insight: String
    let confidence: Int
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.fill")
                    .font(.title2)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(confidence)%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)

                    Text("Confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(insight)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

// MARK: - Supporting Types

enum TrendDirection {
    case up, down, improving, declining
}

enum InsightType {
    case warning, opportunity, positive
}

enum AlertSeverity {
    case high, medium, low
}

#Preview {
    SimpleRealTimeInsightsView()
        .frame(width: 800, height: 600)
}
