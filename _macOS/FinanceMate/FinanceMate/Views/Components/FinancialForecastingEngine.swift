import Charts
import SwiftUI

struct FinancialForecastingEngine: View {
    @State private var forecastData: [ForecastDataPoint] = []
    @State private var selectedTimeframe: ForecastTimeframe = .threeMonths
    @State private var cashFlowProjections: [CashFlowProjection] = []
    @State private var upcomingTransactions: [UpcomingTransaction] = []
    @State private var isGeneratingForecast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView

            if isGeneratingForecast {
                loadingView
            } else {
                forecastChartsView
                cashFlowSummaryView
                upcomingTransactionsView
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            generateForecast()
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text("Financial Forecasting")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("AI-powered cash flow predictions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(ForecastTimeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.displayName).tag(timeframe)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 250)
            .onChange(of: selectedTimeframe) { _, _ in
                generateForecast()
            }

            Button(action: generateForecast) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            .buttonStyle(.bordered)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Generating financial forecast...")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Analyzing historical patterns and upcoming transactions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var forecastChartsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cash Flow Forecast")
                .font(.headline)
                .fontWeight(.medium)

            HStack(spacing: 20) {
                // Balance forecast chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Balance Projection")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Chart(forecastData) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)

                        if dataPoint.isActual {
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Balance", dataPoint.balance)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(30)
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(formatCurrency(doubleValue))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let dateValue = value.as(Date.self) {
                                    Text(dateValue, format: .dateTime.month(.abbreviated).day())
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }

                // Income vs Expenses
                VStack(alignment: .leading, spacing: 8) {
                    Text("Income vs Expenses")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Chart(cashFlowProjections) { projection in
                        BarMark(
                            x: .value("Date", projection.date),
                            y: .value("Income", projection.income)
                        )
                        .foregroundStyle(.green)

                        BarMark(
                            x: .value("Date", projection.date),
                            y: .value("Expenses", -projection.expenses)
                        )
                        .foregroundStyle(.red)
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(formatCurrency(abs(doubleValue)))
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var cashFlowSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Flow Summary")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                CashFlowCard(
                    title: "Projected Income",
                    amount: cashFlowProjections.reduce(0) { $0 + $1.income },
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )

                CashFlowCard(
                    title: "Projected Expenses",
                    amount: cashFlowProjections.reduce(0) { $0 + $1.expenses },
                    color: .red,
                    icon: "arrow.down.circle.fill"
                )

                CashFlowCard(
                    title: "Net Cash Flow",
                    amount: cashFlowProjections.reduce(0) { $0 + $1.income - $1.expenses },
                    color: .blue,
                    icon: "equal.circle.fill"
                )

                CashFlowCard(
                    title: "Lowest Balance",
                    amount: forecastData.min { $0.balance < $1.balance }?.balance ?? 0,
                    color: .orange,
                    icon: "exclamationmark.triangle.fill"
                )
            }
        }
    }

    private var upcomingTransactionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Transactions")
                .font(.subheadline)
                .fontWeight(.medium)

            LazyVStack(spacing: 8) {
                ForEach(upcomingTransactions.prefix(5)) { transaction in
                    UpcomingTransactionRow(transaction: transaction)
                }
            }

            if upcomingTransactions.count > 5 {
                Button("View All (\(upcomingTransactions.count - 5) more)") {
                    // Show all upcoming transactions
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func generateForecast() {
        isGeneratingForecast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generateForecastData()
            generateCashFlowProjections()
            generateUpcomingTransactions()
            isGeneratingForecast = false
        }
    }

    private func generateForecastData() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: selectedTimeframe.dateComponent, value: selectedTimeframe.value, to: startDate) ?? startDate

        var currentBalance = 5420.50 // Starting balance
        forecastData = []

        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        for day in 0...days {
            guard let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) else { continue }

            // Simulate daily balance changes
            let dailyChange = Double.random(in: -100...150)
            currentBalance += dailyChange

            forecastData.append(ForecastDataPoint(
                date: date,
                balance: currentBalance,
                isActual: day <= 7 // Mark first week as actual data
            ))
        }
    }

    private func generateCashFlowProjections() {
        let startDate = Date()
        cashFlowProjections = []

        for month in 0..<selectedTimeframe.monthCount {
            guard let date = Calendar.current.date(byAdding: .month, value: month, to: startDate) else { continue }

            let income = Double.random(in: 4000...6000)
            let expenses = Double.random(in: 2500...4500)

            cashFlowProjections.append(CashFlowProjection(
                date: date,
                income: income,
                expenses: expenses
            ))
        }
    }

    private func generateUpcomingTransactions() {
        upcomingTransactions = [
            UpcomingTransaction(
                description: "Salary Deposit",
                amount: 4200.00,
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                type: .income,
                confidence: .high
            ),
            UpcomingTransaction(
                description: "Rent Payment",
                amount: -1200.00,
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                type: .expense,
                confidence: .high
            ),
            UpcomingTransaction(
                description: "Netflix Subscription",
                amount: -15.99,
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                type: .expense,
                confidence: .high
            ),
            UpcomingTransaction(
                description: "Grocery Shopping",
                amount: -150.00,
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                type: .expense,
                confidence: .medium
            )
        ]
        .sorted { $0.date < $1.date }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct CashFlowCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            Text(formatCurrency(amount))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(amount < 0 ? .red : .primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct UpcomingTransactionRow: View {
    let transaction: UpcomingTransaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.body)
                    .fontWeight(.medium)

                HStack {
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(transaction.confidence.displayName)
                        .font(.caption)
                        .foregroundColor(transaction.confidence.color)
                }
            }

            Spacer()

            Text(transaction.formattedAmount)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

struct ForecastDataPoint {
    let date: Date
    let balance: Double
    let isActual: Bool
}

struct CashFlowProjection {
    let date: Date
    let income: Double
    let expenses: Double
}

struct UpcomingTransaction: Identifiable {
    let id = UUID()
    let description: String
    let amount: Double
    let date: Date
    let type: TransactionType
    let confidence: ConfidenceLevel

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

enum TransactionType {
    case income, expense
}

enum ConfidenceLevel {
    case low, medium, high

    var displayName: String {
        switch self {
        case .low: return "Low confidence"
        case .medium: return "Medium confidence"
        case .high: return "High confidence"
        }
    }

    var color: Color {
        switch self {
        case .low: return .orange
        case .medium: return .yellow
        case .high: return .green
        }
    }
}

enum ForecastTimeframe: CaseIterable {
    case oneMonth, threeMonths, sixMonths, oneYear

    var displayName: String {
        switch self {
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .oneYear: return "1 Year"
        }
    }

    var dateComponent: Calendar.Component {
        switch self {
        case .oneMonth: return .month
        case .threeMonths: return .month
        case .sixMonths: return .month
        case .oneYear: return .year
        }
    }

    var value: Int {
        switch self {
        case .oneMonth: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .oneYear: return 1
        }
    }

    var monthCount: Int {
        switch self {
        case .oneMonth: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .oneYear: return 12
        }
    }
}

#Preview {
    FinancialForecastingEngine()
        .frame(width: 900, height: 700)
}
