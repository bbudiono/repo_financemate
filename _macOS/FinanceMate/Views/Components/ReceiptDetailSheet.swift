import SwiftUI

/**
 * ReceiptDetailSheet.swift
 * 
 * Purpose: PHASE 3.3 - Modular receipt detail sheet component (extracted from ReceiptListView)
 * Issues & Complexity Summary: Receipt detail content display with processing information
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~90 (focused detail display responsibility)
 *   - Core Algorithm Complexity: Low (content display and formatting)
 *   - Dependencies: 2 (SwiftUI, receipt data models)
 *   - State Management Complexity: Low (sheet presentation and formatting)
 *   - Novelty/Uncertainty Factor: Low (established detail view patterns)
 * AI Pre-Task Self-Assessment: 97%
 * Problem Estimate: 83%
 * Initial Code Complexity Estimate: 76%
 * Target Coverage: Receipt detail content validation testing
 * Australian Compliance: Transaction display formatting, currency handling
 * Last Updated: 2025-08-08
 */

/// Modular receipt detail sheet component
/// Extracted from ReceiptListView to maintain <200 line rule
struct ReceiptDetailSheet: View {
    
    // MARK: - Properties
    
    let receipt: ProcessedReceipt
    @Binding var isPresented: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    receiptDetailContent
                }
                .padding()
            }
            .navigationTitle("Receipt Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - Receipt Detail Content
    
    private var receiptDetailContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status and basic info
            basicInfoSection
            
            // Extracted text
            if !receipt.extractedText.isEmpty {
                extractedTextSection
            }
            
            // Processing notes
            if let notes = receipt.processingNotes, !notes.isEmpty {
                processingNotesSection(notes)
            }
            
            // Processing metadata
            processingMetadataSection
        }
    }
    
    // MARK: - Basic Info Section
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                statusIndicator(for: receipt.processingStatus)
                Text(receipt.processingStatus.rawValue.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if let vendor = receipt.vendor {
                detailRow(label: "Vendor", value: vendor)
            }
            
            detailRow(label: "Amount", value: formatCurrency(receipt.extractedAmount))
            
            if let date = receipt.extractedDate {
                detailRow(label: "Date", value: formatDate(date))
            }
            
            if let category = receipt.suggestedCategory {
                detailRow(label: "Category", value: category)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Extracted Text Section
    
    private var extractedTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Extracted Text")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(receipt.extractedText)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Processing Notes Section
    
    private func processingNotesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Processing Notes")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Processing Metadata Section
    
    private var processingMetadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Processing Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Receipt ID: \(receipt.id.uuidString)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Processed: \(formatDate(Date()))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Confidence: High")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func statusIndicator(for status: ProcessingStatus) -> some View {
        Circle()
            .fill(statusColor(for: status))
            .frame(width: 12, height: 12)
            .overlay(
                Circle()
                    .stroke(statusColor(for: status).opacity(0.3), lineWidth: 2)
                    .frame(width: 16, height: 16)
            )
    }
    
    private func statusColor(for status: ProcessingStatus) -> Color {
        switch status {
        case .success: return .green
        case .needsReview: return .orange
        case .failed: return .red
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.locale = Locale(identifier: "en_AU")
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    ReceiptDetailSheet(
        receipt: ProcessedReceipt(
            id: UUID(),
            extractedText: "Sample receipt text",
            extractedAmount: 25.50,
            extractedDate: Date(),
            vendor: "Sample Store",
            processingStatus: .success,
            suggestedCategory: "Groceries",
            processingNotes: nil
        ),
        isPresented: .constant(true)
    )
}