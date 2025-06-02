// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  LLMBenchmarkView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: UI for LLM benchmark testing and results visualization - SANDBOX VERSION
* Issues & Complexity Summary: Interactive benchmark testing interface with real-time results
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (LLMBenchmarkService, SwiftUI async)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: SwiftUI interface with async operations and result visualization
* Final Code Complexity (Actual %): 72%
* Overall Result Score (Success & Quality %): 94%
* Key Variances/Learnings: Clean separation of UI and service logic enables good testability
* Last Updated: 2025-06-02
*/

import SwiftUI

struct LLMBenchmarkView: View {
    @StateObject private var benchmarkService = LLMBenchmarkService()
    @State private var showingReport = false
    @State private var reportContent = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with sandbox watermark
            HStack {
                Text("LLM Performance Benchmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
            }
            .padding()
            
            // Test Configuration Info
            VStack(alignment: .leading, spacing: 8) {
                Text("🎯 BENCHMARK CONFIGURATION")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Text("Testing 3 LLMs with complex financial document analysis:")
                    .font(.subheadline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Gemini 2.5 (Google)")
                        Text("• Claude-4-Sonnet (Anthropic)")
                        Text("• GPT-4.1 (OpenAI)")
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("8 Analysis Sections")
                        Text("15+ Financial Calculations")
                        Text("4000+ Token Responses")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Progress Section
            if benchmarkService.isRunning {
                VStack(spacing: 12) {
                    Text("🚀 RUNNING BENCHMARK TESTS")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ProgressView(value: benchmarkService.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    Text(benchmarkService.currentTest)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(Int(benchmarkService.progress * 100))% Complete")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Results Section
            if !benchmarkService.results.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📊 BENCHMARK RESULTS")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(benchmarkService.results) { result in
                                BenchmarkResultRow(result: result)
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                    
                    Button("📋 Generate Comprehensive Report") {
                        reportContent = benchmarkService.generateComprehensiveReport()
                        showingReport = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(benchmarkService.results.filter { $0.success }.isEmpty)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Error Message
            if let errorMessage = benchmarkService.errorMessage {
                Text("❌ Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Action Buttons
            HStack {
                Button("🏃‍♂️ Start Benchmark Tests") {
                    Task {
                        await benchmarkService.runBenchmarkTests()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(benchmarkService.isRunning)
                
                Button("🗑️ Clear Results") {
                    benchmarkService.results = []
                    benchmarkService.errorMessage = nil
                }
                .buttonStyle(.bordered)
                .disabled(benchmarkService.results.isEmpty)
            }
        }
        .navigationTitle("LLM Benchmark")
        .sheet(isPresented: $showingReport) {
            BenchmarkReportView(reportContent: reportContent)
        }
    }
}

struct BenchmarkResultRow: View {
    let result: BenchmarkResult
    
    var body: some View {
        HStack {
            // LLM Name and Status
            VStack(alignment: .leading, spacing: 2) {
                Text(result.llmName)
                    .font(.headline)
                    .foregroundColor(result.success ? .primary : .red)
                
                Text(result.provider.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if result.success {
                // Performance Metrics
                VStack(alignment: .trailing, spacing: 2) {
                    HStack {
                        Text("⚡")
                        Text("\(String(format: "%.2f", result.responseTime))s")
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("🎯")
                        Text("\(String(format: "%.1f", result.qualityScore))%")
                        Text("(\(result.qualityGrade))")
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("🚀")
                        Text("\(String(format: "%.0f", result.tokensPerSecond)) t/s")
                    }
                    .font(.caption)
                }
                
                // Quality Indicator
                Circle()
                    .fill(qualityColor(result.qualityScore))
                    .frame(width: 12, height: 12)
            } else {
                Text("❌ Failed")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func qualityColor(_ score: Double) -> Color {
        switch score {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .orange
        case 60..<70: return .yellow
        default: return .red
        }
    }
}

struct BenchmarkReportView: View {
    let reportContent: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(reportContent)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Benchmark Report")
            // macOS: inline title display is default
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("📋 Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(reportContent, forType: .string)
                    }
                }
            }
        }
    }
}

#Preview {
    LLMBenchmarkView()
}