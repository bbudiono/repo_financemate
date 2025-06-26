import SwiftUI

struct HealthRecommendationsView: View {
    let recommendations: [HealthRecommendation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personalized Recommendations")
                .font(.subheadline)
                .fontWeight(.medium)

            if recommendations.isEmpty {
                EmptyRecommendationsView()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(recommendations, id: \.title) { recommendation in
                        RecommendationCard(recommendation: recommendation)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct RecommendationCard: View {
    let recommendation: HealthRecommendation

    private var priorityColor: Color {
        switch recommendation.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    private var priorityIcon: String {
        switch recommendation.priority {
        case .high: return "exclamationmark.triangle.fill"
        case .medium: return "info.circle.fill"
        case .low: return "lightbulb.fill"
        }
    }

    private var categoryIcon: String {
        switch recommendation.category.lowercased() {
        case "savings": return "banknote.fill"
        case "debt": return "creditcard.fill"
        case "emergency fund": return "shield.fill"
        case "credit": return "percent"
        case "subscriptions": return "app.badge.fill"
        case "investment": return "chart.line.uptrend.xyaxis"
        case "budget": return "chart.pie.fill"
        default: return "questionmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            VStack {
                Image(systemName: priorityIcon)
                    .foregroundColor(priorityColor)
                    .font(.title3)

                Text(recommendation.priority.displayName)
                    .font(.caption2)
                    .foregroundColor(priorityColor)
                    .fontWeight(.medium)
            }
            .frame(width: 50)

            // Category icon
            Image(systemName: categoryIcon)
                .foregroundColor(.blue)
                .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recommendation.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(recommendation.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.2))
                        .foregroundColor(priorityColor)
                        .cornerRadius(4)
                }

                Text(recommendation.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Image(systemName: "target")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text("Impact: \(recommendation.impact)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(priorityColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)

            Text("Great Financial Health!")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("You're doing well across all financial health metrics. Keep up the good work!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

extension Priority {
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HealthRecommendationsView(
            recommendations: [
                HealthRecommendation(
                    priority: .high,
                    category: "Savings",
                    title: "Increase Savings Rate",
                    description: "Your current savings rate is 12%. Aim to save at least 15-20% of your income for better financial security.",
                    impact: "Improves financial security and future planning capabilities"
                ),
                HealthRecommendation(
                    priority: .medium,
                    category: "Emergency Fund",
                    title: "Build Emergency Fund",
                    description: "You have 2.1 months of expenses saved. Build this up to 3-6 months for better financial stability.",
                    impact: "Provides safety net for unexpected expenses"
                ),
                HealthRecommendation(
                    priority: .low,
                    category: "Credit",
                    title: "Monitor Credit Utilization",
                    description: "Your credit utilization is currently at 18%. Keep it below 30% and ideally under 10% for optimal credit health.",
                    impact: "Maintains and improves credit score"
                )
            ]
        )

        HealthRecommendationsView(recommendations: [])
    }
    .frame(width: 600)
    .padding()
}
