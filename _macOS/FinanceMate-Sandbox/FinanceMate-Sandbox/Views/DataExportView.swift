//
//  DataExportView.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFormat: ExportFormat = .csv
    @State private var includeDocuments = true
    @State private var includeFinancialData = true
    @State private var includeAnalytics = false
    @State private var dateRange: DateRange = .allTime
    @State private var isExporting = false
    @State private var exportComplete = false
    @State private var exportedFilePath: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("Export Data")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Export your financial data and documents")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Export Format Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Format")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                exportFormatRow(format)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Data Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Include Data")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            dataSelectionRow(
                                title: "Financial Documents",
                                description: "Original uploaded PDFs and images",
                                isSelected: $includeDocuments,
                                icon: "doc.fill"
                            )
                            
                            dataSelectionRow(
                                title: "Financial Data",
                                description: "Extracted transaction data and line items",
                                isSelected: $includeFinancialData,
                                icon: "dollarsign.circle.fill"
                            )
                            
                            dataSelectionRow(
                                title: "Analytics Reports",
                                description: "Generated charts and analysis",
                                isSelected: $includeAnalytics,
                                icon: "chart.bar.fill"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Date Range Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date Range")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Date Range", selection: $dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.displayName).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Export Summary
                    if !isExporting {
                        VStack(spacing: 8) {
                            Text("Export Summary")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Format: \(selectedFormat.displayName)")
                                .font(.body)
                            
                            Text("Data: \(selectedDataTypes)")
                                .font(.body)
                            
                            Text("Period: \(dateRange.displayName)")
                                .font(.body)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Export Progress
                    if isExporting {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            
                            Text("Exporting data...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Export Complete
                    if exportComplete {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                            
                            Text("Export Complete!")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Data exported successfully")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button("Show in Finder") {
                                showInFinder()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    if !exportComplete {
                        HStack(spacing: 16) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            .disabled(isExporting)
                            
                            Button("Export") {
                                startExport()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isExporting || !hasDataSelected)
                        }
                        .padding()
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func exportFormatRow(_ format: ExportFormat) -> some View {
        HStack {
            Button(action: {
                selectedFormat = format
            }) {
                HStack {
                    Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedFormat == format ? .blue : .secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(format.displayName)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text(format.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func dataSelectionRow(
        title: String,
        description: String,
        isSelected: Binding<Bool>,
        icon: String
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isSelected)
                .toggleStyle(SwitchToggleStyle())
        }
    }
    
    private var selectedDataTypes: String {
        var types: [String] = []
        if includeDocuments { types.append("Documents") }
        if includeFinancialData { types.append("Financial Data") }
        if includeAnalytics { types.append("Analytics") }
        return types.joined(separator: ", ")
    }
    
    private var hasDataSelected: Bool {
        includeDocuments || includeFinancialData || includeAnalytics
    }
    
    private func startExport() {
        isExporting = true
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isExporting = false
            exportComplete = true
            exportedFilePath = "~/Downloads/FinanceMate_Export_\(Date().timeIntervalSince1970).zip"
        }
    }
    
    private func showInFinder() {
        // In production, show actual file in Finder
        print("Would show file at: \(exportedFilePath)")
    }
}

// MARK: - Supporting Types

enum ExportFormat: CaseIterable {
    case csv
    case excel
    case pdf
    case json
    
    var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .excel: return "Excel"
        case .pdf: return "PDF Report"
        case .json: return "JSON"
        }
    }
    
    var description: String {
        switch self {
        case .csv: return "Comma-separated values, compatible with spreadsheets"
        case .excel: return "Microsoft Excel format with multiple sheets"
        case .pdf: return "Formatted PDF report with charts and summaries"
        case .json: return "Raw JSON data for developers and integrations"
        }
    }
}

enum DateRange: CaseIterable {
    case lastMonth
    case lastThreeMonths
    case lastYear
    case allTime
    
    var displayName: String {
        switch self {
        case .lastMonth: return "Last Month"
        case .lastThreeMonths: return "3 Months"
        case .lastYear: return "Last Year"
        case .allTime: return "All Time"
        }
    }
}

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        DataExportView()
    }
}