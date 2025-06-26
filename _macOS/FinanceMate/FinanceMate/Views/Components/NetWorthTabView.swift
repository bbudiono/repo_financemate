import Charts
import SwiftUI

struct NetWorthTabView: View {
    let aggregationService: AccountAggregationService
    @Binding var selectedPeriod: TimePeriod
    @State private var netWorthHistory: [NetWorthDataPoint] = []

    var body: some View {
        VStack(spacing: 20) {
            periodSelectorView
            netWorthChartView
            assetLiabilityBreakdownView
        }
        .onAppear {
            loadNetWorthHistory()
        }
        .onChange(of: selectedPeriod) { _, _ in
            loadNetWorthHistory()
        }
    }

    private var periodSelectorView: some View {
        HStack {
            Text("Net Worth Tracking")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Picker("Time Period", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.displayName).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
    }

    private var netWorthChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Net Worth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(formatCurrency(aggregationService.totalNetWorth))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(aggregationService.totalNetWorth >= 0 ? .green : .red)
                }

                Spacer()

                if let change = calculateNetWorthChange() {
                    VStack(alignment: .trailing) {
                        Text("Change (\(selectedPeriod.displayName))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption)
                                .foregroundColor(change >= 0 ? .green : .red)

                            Text(formatCurrency(abs(change)))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                }
            }

            Chart(netWorthHistory, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Net Worth", dataPoint.netWorth)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Net Worth", dataPoint.netWorth)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyCompact(amount))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private var assetLiabilityBreakdownView: some View {
        HStack(spacing: 16) {
            // Assets breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Assets")
                    .font(.headline)
                    .fontWeight(.semibold)

                Chart(assetData, id: \.type) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(data.color)
                }
                .frame(height: 120)

                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(assetData, id: \.type) { data in
                        HStack {
                            Circle()
                                .fill(data.color)
                                .frame(width: 8, height: 8)

                            Text(data.type)
                                .font(.caption)

                            Spacer()

                            Text(formatCurrency(data.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)

            // Liabilities breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Liabilities")
                    .font(.headline)
                    .fontWeight(.semibold)

                Chart(liabilityData, id: \.type) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(data.color)
                }
                .frame(height: 120)

                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(liabilityData, id: \.type) { data in
                        HStack {
                            Circle()
                                .fill(data.color)
                                .frame(width: 8, height: 8)

                            Text(data.type)
                                .font(.caption)

                            Spacer()

                            Text(formatCurrency(data.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
        }
    }

    private var assetData: [ChartData] {
        let accountsByType = Dictionary(grouping: aggregationService.accounts.filter { $0.type.isAsset }) { $0.type }

        return accountsByType.map { type, accounts in
            ChartData(
                type: type.displayName,
                amount: accounts.reduce(0) { $0 + $1.balance },
                color: type.color
            )
        }.filter { $0.amount > 0 }
    }

    private var liabilityData: [ChartData] {
        let accountsByType = Dictionary(grouping: aggregationService.accounts.filter { $0.type.isLiability }) { $0.type }

        return accountsByType.map { type, accounts in
            ChartData(
                type: type.displayName,
                amount: abs(accounts.reduce(0) { $0 + $1.balance }),
                color: type.color
            )
        }.filter { $0.amount > 0 }
    }

    private func loadNetWorthHistory() {
        netWorthHistory = aggregationService.getNetWorthHistory(period: selectedPeriod)
    }

    private func calculateNetWorthChange() -> Double? {
        guard netWorthHistory.count >= 2 else { return nil }
        let oldest = netWorthHistory.first!.netWorth
        let newest = netWorthHistory.last!.netWorth
        return newest - oldest
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(amount) >= 1_000_000 {
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "$0" + "M"
        } else if abs(amount) >= 1000 {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount / 1000)) ?? "$0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

struct ChartData {
    let type: String
    let amount: Double
    let color: Color
}

#Preview {
    NetWorthTabView(
        aggregationService: AccountAggregationService(),
        selectedPeriod: .constant(.month)
    )
    .frame(width: 700, height: 600)
}
