import SwiftUI

/**
 * ProcessingStatisticsView.swift
 * 
 * Purpose: PHASE 3.3 - Modular processing statistics component (extracted from EmailProcessingResultsView)
 * Issues & Complexity Summary: Statistics display and filtering controls for email processing results
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~120 (focused statistics responsibility)
 *   - Core Algorithm Complexity: Low (statistics calculation and display formatting)
 *   - Dependencies: 2 (SwiftUI, statistics data structures)
 *   - State Management Complexity: Low (filter state, statistics display)
 *   - Novelty/Uncertainty Factor: Low (established statistics display patterns)
 * AI Pre-Task Self-Assessment: 96%
 * Problem Estimate: 85%
 * Initial Code Complexity Estimate: 80%
 * Target Coverage: Statistics accuracy testing with filter validation
 * Australian Compliance: Processing metrics display standards
 * Last Updated: 2025-08-08
 */

/// Modular processing statistics view component
/// Extracted from EmailProcessingResultsView to maintain <200 line rule
struct ProcessingStatisticsView: View {
    
    // MARK: - Properties
    
    let result: EmailReceiptResult
    @Binding var filterOption: FilterOption
    @Binding var sortOption: SortOption
    let onExport: () -> Void
    
    // MARK: - Supporting Types
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case successful = "Successful"
        case needsReview = "Needs Review"
        case errors = "Errors"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .successful: return "checkmark.circle"
            case .needsReview: return "exclamationmark.circle"
            case .errors: return "xmark.circle"
            }
        }
    }
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case amountDescending = "Amount (Highest)"
        case amountAscending = "Amount (Lowest)"
        case vendor = "Vendor (A-Z)"
        
        var icon: String {
            switch self {
            case .dateDescending: return "calendar.badge.minus"
            case .dateAscending: return "calendar.badge.plus"
            case .amountDescending: return "dollarsign.circle"
            case .amountAscending: return "dollarsign.circle.fill"
            case .vendor: return "building.2"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Results header with export
            headerSection
            
            // Statistics grid
            StatisticsGrid(result: result)
            
            // Filter and sort controls
            filterAndSortSection
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "list.clipboard")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("Processing Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Export") {
                onExport()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .disabled(result.processedReceipts.isEmpty)
        }
    }
    
    
    // MARK: - Filter and Sort Section
    
    private var filterAndSortSection: some View {
        HStack(spacing: 16) {
            // Filter picker
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Filter", selection: $filterOption) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        HStack {
                            Image(systemName: option.icon)
                            Text(option.rawValue)
                        }.tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
            }
            
            Spacer()
            
            // Sort picker
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        HStack {
                            Image(systemName: option.icon)
                            Text(option.rawValue)
                        }.tag(option)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
            }
        }
        .padding(.horizontal)
    }
    
}

// MARK: - Preview

#Preview {
    ProcessingStatisticsView(
        result: EmailReceiptResult(
            processedReceipts: [],
            processingErrors: [],
            processingDuration: 0,
            emailsProcessed: 0,
            auditTrail: []
        ),
        filterOption: .constant(.all),
        sortOption: .constant(.dateDescending)
    ) {
        print("Export tapped")
    }
}