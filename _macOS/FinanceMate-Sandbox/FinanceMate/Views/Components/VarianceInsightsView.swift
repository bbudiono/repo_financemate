import SwiftUI

struct VarianceInsightsView: View {
    let insights: [AnalyticsInsight]
    let onInsightTap: (AnalyticsInsight) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget Variance Insights")
                .font(.subheadline)
                .fontWeight(.medium)

            if insights.isEmpty {
                EmptyVarianceInsightsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(insights, id: \.title) { insight in
                        VarianceInsightCard(insight: insight) {
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

struct VarianceInsightCard: View {
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
                        .lineLimit(3)
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

struct EmptyVarianceInsightsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No budget variance insights")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Insights will appear when you set up budgets and track spending against them.")
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
        VarianceInsightsView(
            insights: [
                AnalyticsInsight(
                    type: .warning,
                    title: "Entertainment Over Budget",
                    description: "You've spent 60% more than budgeted on entertainment this month. Consider reviewing your entertainment expenses.",
                    actionable: true
                ),
                AnalyticsInsight(
                    type: .positive,
                    title: "Transportation Savings",
                    description: "Great job! You're 8% under budget for transportation costs this month.",
                    actionable: false
                ),
                AnalyticsInsight(
                    type: .info,
                    title: "Food Budget Near Limit",
                    description: "You've used 88% of your food budget with 8 days remaining in the month.",
                    actionable: true
                )
            ]
        ) { insight in
            print("Tapped insight: \(insight.title)")
        }

        VarianceInsightsView(insights: []) { _ in }
    }
    .frame(width: 500)
    .padding()
}
