// SANDBOX FILE: For testing/development. See .cursorrules.
//
// BasicExportService.swift
// FinanceMate-Sandbox
//
// Purpose: Simple TDD-driven export service for financial data with basic CSV functionality
// Issues & Complexity Summary: Test-driven implementation starting with minimal CSV export functionality
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Low-Medium (CSV generation, data validation)
//   - Dependencies: 3 New (Foundation, Core Data, File System)
//   - State Management Complexity: Low (stateless service)
//   - Novelty/Uncertainty Factor: Low (standard CSV export patterns)
// AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 45%
// Problem Estimate (Inherent Problem Difficulty %): 40%
// Initial Code Complexity Estimate %: 43%
// Justification for Estimates: Simple CSV export service with clear input/output requirements, TDD-driven approach
// Final Code Complexity (Actual %): TBD
// Overall Result Score (Success & Quality %): TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-06-04

import Foundation
import CoreData

// MARK: - Export Format Enum

public enum ExportFormat: String, CaseIterable, Identifiable {
    case csv = "CSV"
    
    public var id: String { rawValue }
    
    public var fileExtension: String {
        switch self {
        case .csv: return "csv"
        }
    }
}

// MARK: - Export Error Types

public enum ExportError: Error, Equatable {
    case invalidData
    case fileWriteError
    case noDataFound
    
    public var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Invalid or corrupted financial data"
        case .fileWriteError:
            return "Failed to write export file"
        case .noDataFound:
            return "No financial data found to export"
        }
    }
}

// MARK: - Export Result

public struct ExportResult {
    public let success: Bool
    public let recordCount: Int
    public let fileURL: URL?
    public let errorMessage: String?
    
    public init(success: Bool, recordCount: Int, fileURL: URL? = nil, errorMessage: String? = nil) {
        self.success = success
        self.recordCount = recordCount
        self.fileURL = fileURL
        self.errorMessage = errorMessage
    }
}

// MARK: - Basic Export Service

public class BasicExportService: ObservableObject {
    
    @Published public var isExporting: Bool = false
    
    public init() {}
    
    // MARK: - Public Export Methods
    
    public func exportFinancialData(_ data: [FinancialData], format: ExportFormat) throws -> String {
        switch format {
        case .csv:
            return try generateCSVContent(from: data)
        }
    }
    
    public func exportToFile(_ data: [FinancialData], format: ExportFormat) throws -> ExportResult {
        Task { @MainActor in
            isExporting = true
        }
        defer { 
            Task { @MainActor in
                isExporting = false
            }
        }
        
        guard !data.isEmpty else {
            return ExportResult(
                success: false,
                recordCount: 0,
                errorMessage: ExportError.noDataFound.localizedDescription
            )
        }
        
        do {
            let content = try exportFinancialData(data, format: format)
            let fileURL = try writeToFile(content: content, format: format)
            
            return ExportResult(
                success: true,
                recordCount: data.count,
                fileURL: fileURL
            )
        } catch {
            return ExportResult(
                success: false,
                recordCount: 0,
                errorMessage: error.localizedDescription
            )
        }
    }
    
    // MARK: - Private Implementation
    
    private func generateCSVContent(from data: [FinancialData]) throws -> String {
        var csvContent = generateCSVHeader()
        
        for financialRecord in data {
            let csvRow = try generateCSVRow(from: financialRecord)
            csvContent += csvRow + "\n"
        }
        
        return csvContent
    }
    
    private func generateCSVHeader() -> String {
        return "Date,InvoiceNumber,VendorName,Amount,Currency\n"
    }
    
    private func generateCSVRow(from data: FinancialData) throws -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = data.invoiceDate.map { dateFormatter.string(from: $0) } ?? ""
        let invoiceNumber = escapeCSVField(data.invoiceNumber ?? "")
        let vendorName = escapeCSVField(data.vendorName ?? "")
        let amount = data.totalAmount?.doubleValue ?? 0.0
        let currency = escapeCSVField(data.currency ?? "USD")
        
        return "\(date),\(invoiceNumber),\(vendorName),\(amount),\(currency)"
    }
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return field
    }
    
    private func writeToFile(content: String, format: ExportFormat) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "financial_export_\(Int(Date().timeIntervalSince1970)).\(format.fileExtension)"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            throw ExportError.fileWriteError
        }
    }
}