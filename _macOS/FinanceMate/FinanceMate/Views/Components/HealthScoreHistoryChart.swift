import Charts
import SwiftUI

struct HealthScoreHistoryChart: View {
    let scoreHistory: [ScoreHistoryPoint]

    private var averageScore: Double {
        guard !scoreHistory.isEmpty else { return 0 }
        return scoreHistory.reduce(0) { $0 + $1.score } / Double(scoreHistory.count)
    }

    private var scoreImprovement: Double {
        guard scoreHistory.count >= 2 else { return 0 }
        let firstScore = scoreHistory.first?.score ?? 0
        let lastScore = scoreHistory.last?.score ?? 0
        return lastScore - firstScore
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Score History")
                .font(.subheadline)
                .fontWeight(.medium)

            if scoreHistory.isEmpty {
                EmptyScoreHistoryView()
            } else {
                VStack(spacing: 16) {
                    // Score history chart
                    Chart {
                        ForEach(scoreHistory, id: \.date) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3))

                            AreaMark(
                                x: .value("Date", point.date),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(30)
                        }

                        // Average line
                        RuleMark(y: .value("Average", averageScore))
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Avg: \(Int(averageScore))")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(4)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(4)
                            }
                    }
                    .frame(height: 150)
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.month(.abbreviated))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let score = value.as(Double.self) {
                                    Text("\(Int(score))")
                                }
                            }
                        }
                    }

                    // Score insights
                    HStack(spacing: 16) {
                        ScoreInsightCard(
                            title: "Current Score",
                            value: "\(Int(scoreHistory.last?.score ?? 0))",
                            icon: "chart.bar.fill",
                            color: scoreColor(scoreHistory.last?.score ?? 0)
                        )

                        ScoreInsightCard(
                            title: "Average Score",
                            value: "\(Int(averageScore))",
                            icon: "minus.circle.fill",
                            color: scoreColor(averageScore)
                        )

                        ScoreInsightCard(
                            title: "Total Change",
                            value: "\(scoreImprovement > 0 ? "+" : "")\(Int(scoreImprovement))",
                            icon: scoreImprovement >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                            color: scoreImprovement >= 0 ? .green : .red
                        )

                        ScoreInsightCard(
                            title: "Trend",
                            value: scoreImprovement > 5 ? "Improving" : (scoreImprovement < -5 ? "Declining" : "Stable"),
                            icon: scoreImprovement > 5 ? "chart.line.uptrend.xyaxis" : (scoreImprovement < -5 ? "chart.line.downtrend.xyaxis" : "chart.line.flattrend.xyaxis"),
                            color: scoreImprovement > 5 ? .green : (scoreImprovement < -5 ? .red : .blue)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green } else if score >= 60 { return .orange } else { return .red }
    }
}

struct ScoreInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct EmptyScoreHistoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("Building Score History")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Your financial health score history will appear here as we collect more data over time.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

#Preview {
    let calendar = Calendar.current
    let sampleHistory = (0...11).map { i in
        let date = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
        let baseScore = 75.0
        let variation = Double.random(in: -10...15)
        return ScoreHistoryPoint(date: date, score: max(0, min(100, baseScore + variation)))
    }.reversed()

    VStack(spacing: 20) {
        HealthScoreHistoryChart(scoreHistory: Array(sampleHistory))

        HealthScoreHistoryChart(scoreHistory: [])
    }
    .frame(width: 600)
    .padding()
}
