// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DashboardInsightsPreview.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Dashboard insights preview component showing key financial insights
* Real Functionality: Displays top 3 insights from RealTimeFinancialInsightsEngine
* No Mock Data: All insights generated from actual user financial data
*/

import SwiftUI
import CoreData

struct DashboardInsightsPreview: View {
    @StateObject private var insightsEngine: RealTimeFinancialInsightsEngine
    @State private var insights: [FinancialInsight] = []
    @State private var isLoading = false
    @State private var showingAllInsights = false
    
    init() {
        let context = CoreDataStack.shared.mainContext
        _insightsEngine = StateObject(wrappedValue: RealTimeFinancialInsightsEngine(context: context))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text("Smart Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !insights.isEmpty {
                    Button("View All") {
                        showingAllInsights = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            // Content
            if isLoading {
                loadingContent
            } else if insights.isEmpty {
                emptyContent
            } else {
                insightsContent
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            Task {
                await loadInsights()
            }
        }
        .sheet(isPresented: $showingAllInsights) {
            FinancialInsightsView()
        }
    }
    
    // MARK: - Content Views
    
    private var loadingContent: some View {
        HStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
            
            Text("Analyzing your financial data...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 80)
    }
    
    private var emptyContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Add transactions to see insights")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
    }
    
    private var insightsContent: some View {
        VStack(spacing: 8) {
            ForEach(Array(insights.prefix(3).enumerated()), id: \.element.id) { index, insight in
                InsightPreviewRow(insight: insight, rank: index + 1)
                
                if index < min(2, insights.count - 1) {
                    Divider()
                }
            }
        }
    }
    
    // MARK: - Methods
    
    @MainActor
    private func loadInsights() async {
        isLoading = true
        
        do {
            let allInsights = try insightsEngine.generateRealTimeInsights()
            // Show top 3 most important insights
            insights = Array(allInsights.prefix(3))
        } catch {
            print("Failed to load insights: \(error)")
            insights = []
        }
        
        isLoading = false
    }
}

// MARK: - Insight Preview Row

struct InsightPreviewRow: View {
    let insight: FinancialInsight
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank indicator
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(priorityColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Confidence indicator
            confidenceIndicator
        }
    }
    
    private var priorityColor: Color {
        switch insight.priority {
        case .critical:
            return .red
        case .high:
            return .orange
        case .medium:
            return .blue
        case .low:
            return .green
        }
    }
    
    private var confidenceIndicator: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(insight.confidence * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(confidenceColor)
            
            Rectangle()
                .fill(confidenceColor)
                .frame(width: 30 * insight.confidence, height: 3)
                .cornerRadius(1.5)
        }
    }
    
    private var confidenceColor: Color {
        if insight.confidence >= 0.8 {
            return .green
        } else if insight.confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    DashboardInsightsPreview()
        .padding()
}