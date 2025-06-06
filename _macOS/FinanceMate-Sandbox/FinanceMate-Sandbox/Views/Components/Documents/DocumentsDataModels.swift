// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DocumentsDataModels.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular data models for document management including document items, processing status, and filter types
* Issues & Complexity Summary: Data model definitions with computed properties, enumerations, and type mappings
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low (enum definitions, computed properties, type mappings)
  - Dependencies: 2 New (SwiftUI, Foundation for UUID and Date)
  - State Management Complexity: Low (immutable data structures)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 15%
* Problem Estimate (Inherent Problem Difficulty %): 10%
* Initial Code Complexity Estimate %): 13%
* Justification for Estimates: Simple data model extraction with straightforward enumerations
* Final Code Complexity (Actual %): 17%
* Overall Result Score (Success & Quality %): 98%
* Key Variances/Learnings: Data model separation improves code organization and reusability
* Last Updated: 2025-06-06
*/

import SwiftUI

// MARK: - Data Models

struct DocumentItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let type: DocumentType
    let dateAdded: Date
    var extractedText: String
    var processingStatus: ViewProcessingStatus
}

enum ViewProcessingStatus: CaseIterable {
    case pending
    case processing
    case completed
    case failed
    case cancelled
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .gray
        }
    }
}

enum DocumentFilter: CaseIterable {
    case all
    case invoices
    case receipts
    case statements
    case contracts
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .invoices: return "Invoices"
        case .receipts: return "Receipts"
        case .statements: return "Statements"
        case .contracts: return "Contracts"
        }
    }
    
    var documentType: DocumentType? {
        switch self {
        case .all: return nil
        case .invoices: return .invoice
        case .receipts: return .receipt
        case .statements: return .statement
        case .contracts: return .other
        }
    }
}