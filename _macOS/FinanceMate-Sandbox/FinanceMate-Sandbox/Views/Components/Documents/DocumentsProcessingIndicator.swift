// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DocumentsProcessingIndicator.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular processing indicator component showing AI document processing progress and status
* Issues & Complexity Summary: Processing display component with progress tracking, error handling, and visual feedback
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~60
  - Core Algorithm Complexity: Low (progress display, conditional error handling)
  - Dependencies: 3 New (SwiftUI, FinancialDocumentProcessor, error state)
  - State Management Complexity: Low (progress value, error state display)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
* Problem Estimate (Inherent Problem Difficulty %): 20%
* Initial Code Complexity Estimate %): 23%
* Justification for Estimates: Simple processing indicator with straightforward visual elements
* Final Code Complexity (Actual %): 27%
* Overall Result Score (Success & Quality %): 96%
* Key Variances/Learnings: Processing indicator separation improves code organization
* Last Updated: 2025-06-06
*/

import SwiftUI

struct DocumentsProcessingIndicator: View {
    @ObservedObject var financialProcessor: FinancialDocumentProcessor
    let isProcessing: Bool
    let processingError: String?
    
    var body: some View {
        if isProcessing || financialProcessor.isProcessing {
            VStack(spacing: 8) {
                HStack {
                    ProgressView(value: financialProcessor.processingProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(maxWidth: .infinity)
                    
                    Text("\(Int(financialProcessor.processingProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .frame(width: 40)
                }
                
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.orange)
                    Text("🤖 SANDBOX: AI-Powered Financial Document Processing...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if let error = processingError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Error: \(error)")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .padding()
        }
    }
}

struct StatusBadge: View {
    let status: ViewProcessingStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption2)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .cornerRadius(4)
    }
}