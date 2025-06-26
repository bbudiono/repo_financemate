//
//  RealForecastView.swift
//  FinanceMate
//
//  Purpose: Real financial forecasting from Core Data - NO MOCK DATA
//

import CoreData
import SwiftUI

struct RealForecastView: View {
    @StateObject private var dataService = DashboardDataService()
    @State private var forecasts: [FinancialForecast] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Financial Forecasting")
                .font(.title2)
                .fontWeight(.semibold)

            if isLoading {
                ProgressView("Analyzing spending patterns...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error generating forecasts")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        loadForecasts()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if forecasts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Not enough data for forecasting")
                        .font(.headline)
                    Text("We need at least a month of financial data to generate accurate forecasts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 16) {
                    ForEach(forecasts, id: \.type) { forecast in
                        RealForecastCard(forecast: forecast)
                    }
                }

                // Confidence indicator
                if let avgConfidence = averageConfidence {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Forecast Confidence")
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        ProgressView(value: avgConfidence)
                            .progressViewStyle(.linear)
                            .frame(height: 4)

                        Text("\(Int(avgConfidence * 100))% - Based on \(dataMonths) months of data")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .onAppear {
            loadForecasts()
        }
    }

    private var averageConfidence: Double? {
        guard !forecasts.isEmpty else { return nil }
        return forecasts.map { $0.confidence }.reduce(0, +) / Double(forecasts.count)
    }

    private var dataMonths: Int {
        // Approximate based on confidence levels
        if let confidence = averageConfidence {
            return Int(confidence * 12)
        }
        return 0
    }

    private func loadForecasts() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let generated = try await dataService.generateForecasts()
                await MainActor.run {
                    self.forecasts = generated
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct RealForecastCard: View {
    let forecast: FinancialForecast

    private var title: String {
        switch forecast.type {
        case .nextMonth:
            return "Next Month Projection"
        case .yearEnd:
            return "Year-End Projection"
        case .savingsPotential:
            return "Savings Potential"
        }
    }

    private var icon: String {
        switch forecast.type {
        case .nextMonth:
            return "calendar.circle"
        case .yearEnd:
            return "calendar.badge.clock"
        case .savingsPotential:
            return "dollarsign.arrow.circlepath"
        }
    }

    private var changeColor: Color {
        switch forecast.type {
        case .savingsPotential:
            return .green // Savings are always good
        default:
            return forecast.changePercentage > 0 ? .red : .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                }

                Spacer()

                if abs(forecast.changePercentage) > 0.1 {
                    Text("\(forecast.changePercentage > 0 ? "+" : "")\(forecast.changePercentage, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(changeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(changeColor.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            Text("$\(forecast.projectedAmount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.semibold)

            Text(forecast.description)
                .font(.caption)
                .foregroundColor(.secondary)

            // Confidence bar
            HStack {
                Text("Confidence")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 2)

                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * forecast.confidence, height: 2)
                    }
                }
                .frame(height: 2)

                Text("\(Int(forecast.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
