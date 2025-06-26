import Charts
import SwiftUI

struct ForecastingView: View {
    let analyticsEngine: AdvancedAnalyticsEngine
    let spendingAnalysis: SpendingAnalysis?
    let selectedPeriod: AnalyticsPeriod

    @State private var forecastPeriods = 6
    @State private var selectedForecastType = ForecastType.spending
    @State private var trendForecast: TrendForecast?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Forecast controls
            HStack {
                Text("Financial Forecasting")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Picker("Forecast Type", selection: $selectedForecastType) {
                    ForEach(ForecastType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)

                Stepper("Periods: \(forecastPeriods)", value: $forecastPeriods, in: 3...12)
                    .frame(width: 150)
            }

            if let forecast = trendForecast {
                VStack(spacing: 16) {
                    // Forecast chart
                    forecastChartView(forecast: forecast)

                    // Forecast insights
                    forecastInsightsView(forecast: forecast)
                }
            } else {
                ProgressView("Generating forecast...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onAppear {
            generateForecast()
        }
        .onChange(of: forecastPeriods) { _, _ in
            generateForecast()
        }
        .onChange(of: selectedForecastType) { _, _ in
            generateForecast()
        }
    }

    private func forecastChartView(forecast: TrendForecast) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(selectedForecastType.displayName) Forecast")
                .font(.subheadline)
                .fontWeight(.medium)

            Chart {
                // Historical data (simplified for demo)
                ForEach(generateHistoricalData(), id: \.period) { dataPoint in
                    LineMark(
                        x: .value("Period", dataPoint.period),
                        y: .value("Amount", dataPoint.value)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // Forecast data
                ForEach(forecast.forecastPoints, id: \.period) { point in
                    LineMark(
                        x: .value("Period", point.period + 12), // Offset for future periods
                        y: .value("Amount", point.value)
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

                    // Confidence interval
                    AreaMark(
                        x: .value("Period", point.period + 12),
                        yStart: .value("Lower", point.lowerBound),
                        yEnd: .value("Upper", point.upperBound)
                    )
                    .foregroundStyle(.orange.opacity(0.2))
                }

                // Divider line between historical and forecast
                RuleMark(x: .value("Now", 12))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .annotation(position: .top) {
                        Text("Today")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let period = value.as(Int.self) {
                            if period <= 12 {
                                Text("M\(period)")
                            } else {
                                Text("F\(period - 12)")
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(formatCurrencyCompact(amount))
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .blue, label: "Historical", style: .solid)
                LegendItem(color: .orange, label: "Forecast", style: .dashed)
                LegendItem(color: .orange.opacity(0.3), label: "Confidence Range", style: .fill)
            }
            .font(.caption)
        }
    }

    private func forecastInsightsView(forecast: TrendForecast) -> some View {
        HStack(spacing: 16) {
            ForecastInsightCard(
                title: "Trend Direction",
                value: forecast.trendDirection.displayName,
                icon: forecast.trendDirection.iconName,
                color: forecast.trendDirection.color
            )

            ForecastInsightCard(
                title: "Confidence",
                value: "\(Int(forecast.confidence * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: forecast.confidence >= 0.8 ? .green : (forecast.confidence >= 0.6 ? .orange : .red)
            )

            ForecastInsightCard(
                title: "Volatility",
                value: volatilityDescription(forecast.volatility),
                icon: "waveform.path.ecg",
                color: forecast.volatility < 100 ? .green : (forecast.volatility < 300 ? .orange : .red)
            )

            ForecastInsightCard(
                title: "Seasonality",
                value: forecast.seasonalityDetected ? "Detected" : "None",
                icon: "calendar.circle",
                color: forecast.seasonalityDetected ? .blue : .gray
            )
        }
    }

    private func generateForecast() {
        guard let analysis = spendingAnalysis else { return }

        // Generate historical data points for forecasting
        let historicalData = analysis.spendingByDay.map { daySpending in
            DataPoint(date: daySpending.date, value: daySpending.amount)
        }

        trendForecast = analyticsEngine.generateTrendForecast(
            historicalData: historicalData,
            forecastPeriods: forecastPeriods
        )
    }

    private func generateHistoricalData() -> [HistoricalDataPoint] {
        // Generate sample historical data for chart
        var data: [HistoricalDataPoint] = []
        let baseValue = selectedForecastType == .spending ? 2500.0 : 7500.0

        for i in 1...12 {
            let variation = Double.random(in: -500...500)
            let value = baseValue + variation
            data.append(HistoricalDataPoint(period: i, value: value))
        }

        return data
    }

    private func volatilityDescription(_ volatility: Double) -> String {
        if volatility < 100 { return "Low" } else if volatility < 300 { return "Medium" } else { return "High" }
    }

    private func formatCurrencyCompact(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        if abs(amount) >= 1000 {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount / 1000)) ?? "$0" + "K"
        } else {
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

struct ForecastInsightCard: View {
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

struct LegendItem: View {
    let color: Color
    let label: String
    let style: LegendStyle

    var body: some View {
        HStack(spacing: 4) {
            switch style {
            case .solid:
                Rectangle()
                    .fill(color)
                    .frame(width: 12, height: 2)
            case .dashed:
                Rectangle()
                    .fill(color)
                    .frame(width: 12, height: 2)
                    .overlay(
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [2, 2]))
                    )
            case .fill:
                Rectangle()
                    .fill(color)
                    .frame(width: 12, height: 8)
                    .cornerRadius(2)
            }

            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

enum ForecastType: String, CaseIterable {
    case spending = "spending"
    case income = "income"
    case netWorth = "netWorth"

    var displayName: String {
        switch self {
        case .spending: return "Spending"
        case .income: return "Income"
        case .netWorth: return "Net Worth"
        }
    }
}

enum LegendStyle {
    case solid
    case dashed
    case fill
}

struct HistoricalDataPoint {
    let period: Int
    let value: Double
}

#Preview {
    ForecastingView(
        analyticsEngine: AdvancedAnalyticsEngine(),
        spendingAnalysis: SpendingAnalysis(
            period: .month,
            totalSpent: 2847.50,
            averageDailySpending: 94.92,
            categoryBreakdown: [],
            trendAnalysis: .increasing,
            topMerchants: [],
            spendingByDay: [
                DailySpending(date: Date(), amount: 120.50, transactionCount: 3)
            ],
            spendingByMonth: [],
            insights: []
        ),
        selectedPeriod: .month
    )
    .frame(width: 700, height: 500)
    .padding()
}
