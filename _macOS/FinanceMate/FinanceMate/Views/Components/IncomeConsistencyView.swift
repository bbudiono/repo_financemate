import Charts
import SwiftUI

struct IncomeConsistencyView: View {
    let analysis: IncomeAnalysis

    private var consistencyGrade: String {
        let score = analysis.consistencyScore
        if score >= 0.9 { return "A+" } else if score >= 0.8 { return "A" } else if score >= 0.7 { return "B+" } else if score >= 0.6 { return "B" } else if score >= 0.5 { return "C+" } else if score >= 0.4 { return "C" } else { return "D" }
    }

    private var consistencyDescription: String {
        let score = analysis.consistencyScore
        if score >= 0.9 { return "Excellent - Very stable income" } else if score >= 0.8 { return "Great - Stable income with minor fluctuations" } else if score >= 0.7 { return "Good - Generally stable with some variation" } else if score >= 0.6 { return "Fair - Moderate income fluctuations" } else if score >= 0.5 { return "Below Average - Noticeable income variations" } else { return "Poor - Highly irregular income" }
    }

    private var consistencyColor: Color {
        let score = analysis.consistencyScore
        if score >= 0.8 { return .green } else if score >= 0.6 { return .orange } else { return .red }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income Consistency")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 20) {
                // Consistency score gauge
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: analysis.consistencyScore)
                            .stroke(
                                consistencyColor,
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text(consistencyGrade)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(consistencyColor)

                            Text("\(Int(analysis.consistencyScore * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Consistency details
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Consistency Rating")
                            .font(.headline)
                            .fontWeight(.medium)

                        Text(consistencyDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ConsistencyMetricRow(
                            title: "Score",
                            value: "\(Int(analysis.consistencyScore * 100))%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: consistencyColor
                        )

                        ConsistencyMetricRow(
                            title: "Grade",
                            value: consistencyGrade,
                            icon: "graduationcap.fill",
                            color: consistencyColor
                        )

                        ConsistencyMetricRow(
                            title: "Growth Rate",
                            value: "\(String(format: "%.1f", analysis.growthRate))%",
                            icon: analysis.growthRate >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                            color: analysis.growthRate >= 0 ? .green : .red
                        )

                        ConsistencyMetricRow(
                            title: "Income Streams",
                            value: "\(analysis.incomeStreams.count)",
                            icon: "arrow.branch",
                            color: .blue
                        )
                    }
                }

                Spacer()
            }

            // Improvement suggestions
            if analysis.consistencyScore < 0.8 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestions to Improve Consistency")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(consistencyColor)

                    VStack(alignment: .leading, spacing: 6) {
                        if analysis.incomeStreams.count < 2 {
                            SuggestionRow(
                                icon: "arrow.branch",
                                text: "Consider developing additional income streams",
                                color: .blue
                            )
                        }

                        if analysis.consistencyScore < 0.6 {
                            SuggestionRow(
                                icon: "calendar",
                                text: "Explore opportunities for regular, recurring income",
                                color: .green
                            )
                        }

                        SuggestionRow(
                            icon: "dollarsign.circle",
                            text: "Build an emergency fund to handle income fluctuations",
                            color: .orange
                        )
                    }
                }
                .padding()
                .background(consistencyColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ConsistencyMetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)

            Text(title)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct SuggestionRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)

            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        IncomeConsistencyView(
            analysis: IncomeAnalysis(
                period: .month,
                totalIncome: 8450.00,
                averageMonthlyIncome: 8450.00,
                incomeStreams: [
                    IncomeStream(source: "Primary Job", amount: 7500.00, frequency: 2, category: "Salary"),
                    IncomeStream(source: "Freelance", amount: 650.00, frequency: 3, category: "Contract"),
                    IncomeStream(source: "Investment", amount: 300.00, frequency: 1, category: "Investment")
                ],
                growthRate: 5.2,
                consistencyScore: 0.92,
                insights: []
            )
        )

        IncomeConsistencyView(
            analysis: IncomeAnalysis(
                period: .month,
                totalIncome: 3200.00,
                averageMonthlyIncome: 3200.00,
                incomeStreams: [
                    IncomeStream(source: "Freelance", amount: 3200.00, frequency: 5, category: "Contract")
                ],
                growthRate: -2.1,
                consistencyScore: 0.45,
                insights: []
            )
        )
    }
    .frame(width: 600)
    .padding()
}
