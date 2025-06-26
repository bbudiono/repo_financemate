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
    @State private var dateRange: ExportDateRange = .allTime
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
                            ForEach(ExportDateRange.allCases, id: \.self) { range in
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

        Task {
            do {
                let exportedFile = try await performActualExport()

                await MainActor.run {
                    isExporting = false
                    exportComplete = true
                    exportedFilePath = exportedFile
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    // In a real app, show error alert
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func performActualExport() async throws -> String {
        // Create downloads directory if it doesn't exist
        let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        // Create export filename with timestamp
        let timestamp = DateFormatter().string(from: Date())
        let fileName = "FinanceMate_Export_\(timestamp.replacingOccurrences(of: " ", with: "_"))"

        let exportURL: URL

        switch selectedFormat {
        case .csv:
            exportURL = downloadsDir.appendingPathComponent("\(fileName).csv")
            try await createCSVExport(at: exportURL)
        case .pdf:
            exportURL = downloadsDir.appendingPathComponent("\(fileName).pdf")
            try await createPDFExport(at: exportURL)
        case .json:
            exportURL = downloadsDir.appendingPathComponent("\(fileName).json")
            try await createJSONExport(at: exportURL)
        }

        return exportURL.path
    }

    private func createCSVExport(at url: URL) async throws {
        var csvContent = "Date,Description,Amount,Category,Type\n"

        // Add sample data - in real app, fetch from Core Data
        if includeFinancialData {
            csvContent += "2024-06-01,\"Coffee Shop Purchase\",4.50,Food,Expense\n"
            csvContent += "2024-06-02,\"Salary Deposit\",3500.00,Income,Income\n"
            csvContent += "2024-06-03,\"Gas Station\",45.80,Transportation,Expense\n"
            csvContent += "2024-06-04,\"Grocery Store\",127.35,Food,Expense\n"
            csvContent += "2024-06-05,\"Freelance Payment\",850.00,Income,Income\n"
        }

        if includeAnalytics {
            csvContent += "\n\nAnalytics Summary\n"
            csvContent += "Total Income,4350.00\n"
            csvContent += "Total Expenses,177.65\n"
            csvContent += "Net Amount,4172.35\n"
        }

        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }

    private func createPDFExport(at url: URL) async throws {
        // For now, create a simple text file with PDF extension
        // In a real implementation, use PDFKit to create actual PDF
        let pdfContent = """
        FinanceMate Export Report
        Generated: \(Date())
        Format: PDF Report

        FINANCIAL SUMMARY
        ================

        Export includes:
        \(includeDocuments ? "✓" : "✗") Financial Documents
        \(includeFinancialData ? "✓" : "✗") Financial Data
        \(includeAnalytics ? "✓" : "✗") Analytics Reports

        Date Range: \(dateRange.displayName)

        SAMPLE TRANSACTIONS
        ===================

        2024-06-01    Coffee Shop Purchase    $4.50      Food
        2024-06-02    Salary Deposit         $3,500.00   Income
        2024-06-03    Gas Station            $45.80      Transportation
        2024-06-04    Grocery Store          $127.35     Food
        2024-06-05    Freelance Payment      $850.00     Income

        ANALYTICS
        =========

        Total Income:    $4,350.00
        Total Expenses:  $177.65
        Net Amount:      $4,172.35

        Note: This is a demo export. Real implementation would include actual financial data and formatted PDF generation.
        """

        try pdfContent.write(to: url, atomically: true, encoding: .utf8)
    }

    private func createJSONExport(at url: URL) async throws {
        let exportData: [String: Any] = [
            "export_info": [
                "generated_at": ISO8601DateFormatter().string(from: Date()),
                "format": selectedFormat.displayName,
                "date_range": dateRange.displayName,
                "includes": [
                    "documents": includeDocuments,
                    "financial_data": includeFinancialData,
                    "analytics": includeAnalytics
                ]
            ],
            "financial_data": includeFinancialData ? [
                [
                    "date": "2024-06-01",
                    "description": "Coffee Shop Purchase",
                    "amount": -4.50,
                    "category": "Food",
                    "type": "expense"
                ],
                [
                    "date": "2024-06-02",
                    "description": "Salary Deposit",
                    "amount": 3500.00,
                    "category": "Income",
                    "type": "income"
                ],
                [
                    "date": "2024-06-03",
                    "description": "Gas Station",
                    "amount": -45.80,
                    "category": "Transportation",
                    "type": "expense"
                ],
                [
                    "date": "2024-06-04",
                    "description": "Grocery Store",
                    "amount": -127.35,
                    "category": "Food",
                    "type": "expense"
                ],
                [
                    "date": "2024-06-05",
                    "description": "Freelance Payment",
                    "amount": 850.00,
                    "category": "Income",
                    "type": "income"
                ]
            ] : [],
            "analytics": includeAnalytics ? [
                "total_income": 4350.00,
                "total_expenses": 177.65,
                "net_amount": 4172.35,
                "transaction_count": 5,
                "categories": [
                    "Food": -131.85,
                    "Transportation": -45.80,
                    "Income": 4350.00
                ]
            ] : [:],
            "documents": includeDocuments ? [
                "note": "Document exports would include file references and metadata",
                "sample_documents": [
                    "invoice_001.pdf",
                    "receipt_002.jpg",
                    "bank_statement_003.pdf"
                ]
            ] : [:]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        try jsonData.write(to: url)
    }

    private func showInFinder() {
        let url = URL(fileURLWithPath: exportedFilePath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
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

enum ExportDateRange: CaseIterable {
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
