//
//  DocumentListPerformanceView.swift
//  FinanceMate
//
//  Extracted from DocumentsView.swift for SwiftLint compliance
//  Created by Assistant on 6/28/25.
//

/*
* Purpose: Performance monitoring and optimization dashboard for document list
* Issues & Complexity Summary: Performance metrics visualization with recommendations
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Low-Medium (metrics calculation)
  - Dependencies: 1 (DocumentViewPerformanceMetrics)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment: 80%
* Problem Estimate: 75%
* Initial Code Complexity Estimate: 78%
* Final Code Complexity: 80%
* Overall Result Score: 90%
* Key Variances/Learnings: Metrics visualization straightforward
* Last Updated: 2025-06-28
*/

import SwiftUI

// MARK: - Document List Performance View

struct DocumentListPerformanceView: View {
    let metrics: DocumentViewPerformanceMetrics
    let isVirtualizationEnabled: Bool
    let totalCount: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Overall Performance Grade
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Performance Grade")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(metrics.performanceGrade.description)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(metrics.performanceGrade.color)
                    }

                    Spacer()

                    Image(systemName: "speedometer")
                        .font(.largeTitle)
                        .foregroundColor(metrics.performanceGrade.color)
                }
                .padding()
                .background(metrics.performanceGrade.color.opacity(0.1))
                .cornerRadius(12)

                // Performance Metrics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Performance Metrics")
                        .font(.headline)
                        .fontWeight(.semibold)

                    VStack(spacing: 12) {
                        PerformanceMetricRow(
                            title: "Filter Time",
                            value: String(format: "%.3f sec", metrics.lastFilterTime),
                            optimal: metrics.lastFilterTime < 0.1
                        )

                        PerformanceMetricRow(
                            title: "Total Filters",
                            value: String(metrics.totalFilters),
                            optimal: metrics.totalFilters > 0
                        )

                        PerformanceMetricRow(
                            title: "Virtualization",
                            value: isVirtualizationEnabled ? "Enabled" : "Disabled",
                            optimal: isVirtualizationEnabled || totalCount < 100
                        )

                        PerformanceMetricRow(
                            title: "Total Documents",
                            value: String(totalCount),
                            optimal: true
                        )
                    }
                }

                // Recommendations
                let recommendations = getPerformanceRecommendations()
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(recommendations, id: \.self) { recommendation in
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("List Performance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func getPerformanceRecommendations() -> [String] {
        var recommendations: [String] = []

        if metrics.lastFilterTime > 0.2 {
            recommendations.append("Consider reducing document count or optimizing search")
        }

        if totalCount > 1000 && !isVirtualizationEnabled {
            recommendations.append("Enable list virtualization for large datasets")
        }

        if metrics.totalFilters == 0 {
            recommendations.append("Performance metrics will appear after using search/filters")
        }

        return recommendations
    }
}

// MARK: - Performance Metric Row Component

struct PerformanceMetricRow: View {
    let title: String
    let value: String
    let optimal: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .frame(width: 120, alignment: .leading)

            Spacer()

            HStack(spacing: 4) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Image(systemName: optimal ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(optimal ? .green : .orange)
                    .font(.caption)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    DocumentListPerformanceView(
        metrics: DocumentViewPerformanceMetrics(),
        isVirtualizationEnabled: true,
        totalCount: 150
    )
}