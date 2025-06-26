import SwiftUI

struct InsightsView: View {
    let insights: [AnalyticsInsight]
    let onInsightTap: (AnalyticsInsight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Insights")
                .font(.subheadline)
                .fontWeight(.medium)

            if insights.isEmpty {
                EmptyInsightsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(insights, id: \.title) { insight in
                        InsightCard(insight: insight) {
                            onInsightTap(insight)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct InsightCard: View {
    let insight: AnalyticsInsight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: iconForInsightType(insight.type))
                    .foregroundColor(colorForInsightType(insight.type))
                    .font(.title3)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(insight.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Spacer()

                        if insight.actionable {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Text(insight.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colorForInsightType(insight.type).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForInsightType(_ type: InsightType) -> String {
        switch type {
        case .positive: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private func colorForInsightType(_ type: InsightType) -> Color {
        switch type {
        case .positive: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }
}

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No insights available")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Insights will appear as you add more transactions and spending data.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        InsightsView(
            insights: [
                AnalyticsInsight(
                    type: .warning,
                    title: "High Spending Day",
                    description: "You spent $245.80 on March 15th, which is 3x your daily average.",
                    actionable: true
                ),
                AnalyticsInsight(
                    type: .info,
                    title: "Category Dominance",
                    description: "Food represents 35% of your total spending this month.",
                    actionable: true
                ),
                AnalyticsInsight(
                    type: .positive,
                    title: "Spending Decrease",
                    description: "Your weekly spending has decreased by 12% compared to last week.",
                    actionable: false
                )
            ]
        ) { insight in
            print("Tapped insight: \(insight.title)")
        }

        InsightsView(insights: []) { _ in }
    }
    .frame(width: 500)
    .padding()
}
