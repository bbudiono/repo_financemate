import SwiftUI

struct FinancialHealthScoreView: View {
    let healthScore: FinancialHealthScore

    private var scoreGrade: String {
        let score = healthScore.overallScore
        if score >= 90 { return "A+" } else if score >= 80 { return "A" } else if score >= 70 { return "B+" } else if score >= 60 { return "B" } else if score >= 50 { return "C+" } else if score >= 40 { return "C" } else { return "D" }
    }

    private var scoreDescription: String {
        let score = healthScore.overallScore
        if score >= 90 { return "Excellent Financial Health" } else if score >= 80 { return "Very Good Financial Health" } else if score >= 70 { return "Good Financial Health" } else if score >= 60 { return "Fair Financial Health" } else if score >= 50 { return "Below Average Financial Health" } else { return "Poor Financial Health" }
    }

    private var scoreColor: Color {
        let score = healthScore.overallScore
        if score >= 80 { return .green } else if score >= 60 { return .orange } else { return .red }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main score display
            HStack(spacing: 20) {
                // Score gauge
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 16)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: healthScore.overallScore / 100)
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Text("\(Int(healthScore.overallScore))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(scoreColor)

                        Text(scoreGrade)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(scoreColor)
                    }
                }

                // Score details
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Financial Health Score")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(scoreDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        ScoreComponentRow(
                            title: "Savings Rate",
                            percentage: healthScore.savingsRate * 100,
                            target: 20,
                            color: healthScore.savingsRate >= 0.2 ? .green : .orange
                        )

                        ScoreComponentRow(
                            title: "Debt to Income",
                            percentage: healthScore.debtToIncomeRatio * 100,
                            target: 36,
                            isLowerBetter: true,
                            color: healthScore.debtToIncomeRatio <= 0.36 ? .green : .red
                        )

                        ScoreComponentRow(
                            title: "Emergency Fund",
                            percentage: min(healthScore.emergencyFundRatio, 6) / 6 * 100,
                            target: 100,
                            color: healthScore.emergencyFundRatio >= 3 ? .green : .orange
                        )

                        ScoreComponentRow(
                            title: "Credit Utilization",
                            percentage: healthScore.creditUtilization * 100,
                            target: 30,
                            isLowerBetter: true,
                            color: healthScore.creditUtilization <= 0.3 ? .green : .red
                        )
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ScoreComponentRow: View {
    let title: String
    let percentage: Double
    let target: Double
    var isLowerBetter: Bool = false
    let color: Color

    private var isOnTarget: Bool {
        if isLowerBetter {
            return percentage <= target
        } else {
            return percentage >= target
        }
    }

    private var displayValue: String {
        if title == "Emergency Fund" {
            let months = percentage / 100 * 6
            return String(format: "%.1f months", months)
        } else {
            return String(format: "%.1f%%", percentage)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(displayValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }

            Spacer()

            Image(systemName: isOnTarget ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(color)
                .font(.body)
        }
    }
}

#Preview {
    FinancialHealthScoreView(
        healthScore: FinancialHealthScore(
            overallScore: 78.5,
            savingsRate: 0.18,
            debtToIncomeRatio: 0.25,
            emergencyFundRatio: 4.2,
            creditUtilization: 0.15,
            subscriptionBurden: 0.08,
            recommendations: [],
            scoreHistory: []
        )
    )
    .frame(width: 600)
    .padding()
}
