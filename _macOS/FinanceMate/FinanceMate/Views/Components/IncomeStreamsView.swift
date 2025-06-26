import Charts
import SwiftUI

struct IncomeStreamsView: View {
    let analysis: IncomeAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income Sources")
                .font(.subheadline)
                .fontWeight(.medium)

            if analysis.incomeStreams.isEmpty {
                EmptyIncomeStreamsView()
            } else {
                HStack(spacing: 16) {
                    // Income streams chart
                    Chart(analysis.incomeStreams, id: \.source) { stream in
                        SectorMark(
                            angle: .value("Amount", stream.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1
                        )
                        .foregroundStyle(colorForIncomeSource(stream.source))
                        .opacity(0.8)
                    }
                    .frame(width: 150, height: 150)

                    // Income streams list
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(analysis.incomeStreams, id: \.source) { stream in
                            IncomeStreamRowView(
                                stream: stream,
                                totalIncome: analysis.totalIncome,
                                color: colorForIncomeSource(stream.source)
                            )
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func colorForIncomeSource(_ source: String) -> Color {
        switch source.lowercased() {
        case let name where name.contains("salary") || name.contains("job") || name.contains("employment"): return .blue
        case let name where name.contains("freelance") || name.contains("contract") || name.contains("consulting"): return .green
        case let name where name.contains("investment") || name.contains("dividend") || name.contains("interest"): return .purple
        case let name where name.contains("rental") || name.contains("property"): return .orange
        case let name where name.contains("business") || name.contains("profit"): return .red
        case let name where name.contains("bonus") || name.contains("commission"): return .mint
        default: return .gray
        }
    }
}

struct IncomeStreamRowView: View {
    let stream: IncomeStream
    let totalIncome: Double
    let color: Color

    private var percentage: Double {
        totalIncome > 0 ? (stream.amount / totalIncome) * 100 : 0
    }

    private var frequencyText: String {
        switch stream.frequency {
        case 1: return "1 payment"
        case 2: return "2 payments"
        default: return "\(stream.frequency) payments"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(stream.source)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Spacer()

                    Text(formatCurrency(stream.amount))
                        .font(.body)
                        .fontWeight(.semibold)
                }

                HStack {
                    Text(stream.category)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(frequencyText) • \(String(format: "%.1f", percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct EmptyIncomeStreamsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.branch")
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text("No income streams found")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Income sources will appear as you add income transactions.")
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
        IncomeStreamsView(
            analysis: IncomeAnalysis(
                period: .month,
                totalIncome: 8450.00,
                averageMonthlyIncome: 8450.00,
                incomeStreams: [
                    IncomeStream(source: "Primary Job Salary", amount: 7500.00, frequency: 2, category: "Salary"),
                    IncomeStream(source: "Freelance Consulting", amount: 650.00, frequency: 3, category: "Contract"),
                    IncomeStream(source: "Investment Returns", amount: 300.00, frequency: 1, category: "Investment")
                ],
                growthRate: 5.2,
                consistencyScore: 0.92,
                insights: []
            )
        )

        IncomeStreamsView(
            analysis: IncomeAnalysis(
                period: .month,
                totalIncome: 0,
                averageMonthlyIncome: 0,
                incomeStreams: [],
                growthRate: 0,
                consistencyScore: 0,
                insights: []
            )
        )
    }
    .frame(width: 500)
    .padding()
}
