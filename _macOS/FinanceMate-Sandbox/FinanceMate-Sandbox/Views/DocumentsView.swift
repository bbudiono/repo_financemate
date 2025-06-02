// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DocumentsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Comprehensive document management with drag-drop upload, filtering, and document processing - SANDBOX VERSION
* Issues & Complexity Summary: Complex file handling, drag-drop integration, document processing workflow
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~220
  - Core Algorithm Complexity: High
  - Dependencies: 3 New (File handling, NSOpenPanel, drag-drop)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 80%
* Problem Estimate (Inherent Problem Difficulty %): 85%
* Initial Code Complexity Estimate %: 82%
* Justification for Estimates: File operations, drag-drop UI, document state management, filtering logic
* Final Code Complexity (Actual %): 85%
* Overall Result Score (Success & Quality %): 90%
* Key Variances/Learnings: Drag-drop implementation more complex than expected, good file handling patterns
* Last Updated: 2025-06-02
*/

import SwiftUI
import UniformTypeIdentifiers

struct DocumentsView: View {
    @State private var documents: [DocumentItem] = []
    @State private var searchText = ""
    @State private var selectedFilter: DocumentFilter = .all
    @State private var isDragOver = false
    @State private var showingFileImporter = false
    @State private var selectedDocument: DocumentItem?
    @State private var isProcessing = false
    
    var filteredDocuments: [DocumentItem] {
        let filtered = documents.filter { document in
            if selectedFilter != .all && document.type != selectedFilter.documentType {
                return false
            }
            if !searchText.isEmpty {
                return document.name.localizedCaseInsensitiveContains(searchText) ||
                       document.extractedText.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
        return filtered.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filters - SANDBOX VERSION
            VStack(spacing: 16) {
                HStack {
                    Text("Document Management")
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
                    
                    Button("Import Files") {
                        showingFileImporter = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                HStack {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search documents...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Filter picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(DocumentFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                }
            }
            .padding()
            
            Divider()
            
            // Main content area
            if documents.isEmpty {
                // Empty state with drag-drop zone
                VStack(spacing: 20) {
                    Spacer()
                    
                    DragDropZone(
                        isDragOver: $isDragOver,
                        onDrop: handleDocumentDrop
                    )
                    
                    Spacer()
                }
            } else {
                // Document list with drag-drop overlay
                ZStack {
                    DocumentList(
                        documents: filteredDocuments,
                        selectedDocument: $selectedDocument,
                        onDelete: deleteDocument
                    )
                    
                    if isDragOver {
                        DragOverlay()
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
                    handleDocumentDrop(providers)
                }
            }
            
            // Processing indicator
            if isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing documents... (SANDBOX)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }
        }
        .navigationTitle("Documents")
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .image, .text],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .onAppear {
            loadSampleDocuments()
        }
    }
    
    private func handleDocumentDrop(_ providers: [NSItemProvider]) -> Bool {
        isProcessing = true
        
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        processDocument(url: url)
                    }
                    
                    if provider == providers.last {
                        isProcessing = false
                    }
                }
            }
        }
        
        return true
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        isProcessing = true
        
        switch result {
        case .success(let urls):
            for url in urls {
                processDocument(url: url)
            }
        case .failure(let error):
            print("SANDBOX - File import error: \(error)")
        }
        
        isProcessing = false
    }
    
    private func processDocument(url: URL) {
        // Create document item
        let document = DocumentItem(
            name: url.lastPathComponent,
            url: url,
            type: DocumentType.from(url: url),
            dateAdded: Date(),
            extractedText: "Processing... (SANDBOX MODE)", // Would be processed by AI service
            processingStatus: .pending
        )
        
        documents.append(document)
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let index = documents.firstIndex(where: { $0.id == document.id }) {
                documents[index].extractedText = "SANDBOX: Sample extracted text for \(document.name)"
                documents[index].processingStatus = .completed
            }
        }
    }
    
    private func deleteDocument(_ document: DocumentItem) {
        documents.removeAll { $0.id == document.id }
    }
    
    private func loadSampleDocuments() {
        // Load sample documents for demo
        documents = [
            DocumentItem(
                name: "SANDBOX_Invoice_2025_001.pdf",
                url: URL(string: "file://sample1.pdf")!,
                type: .invoice,
                dateAdded: Date().addingTimeInterval(-86400),
                extractedText: "SANDBOX: Invoice from ABC Company for $1,250.00",
                processingStatus: .completed
            ),
            DocumentItem(
                name: "SANDBOX_Receipt_Grocery.jpg",
                url: URL(string: "file://sample2.jpg")!,
                type: .receipt,
                dateAdded: Date().addingTimeInterval(-172800),
                extractedText: "SANDBOX: Grocery receipt for $87.45",
                processingStatus: .completed
            )
        ]
    }
}

struct DragDropZone: View {
    @Binding var isDragOver: Bool
    let onDrop: ([NSItemProvider]) -> Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(isDragOver ? .blue : .secondary)
            
            VStack(spacing: 8) {
                Text("Drop documents here")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Or click Import Files to browse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("🧪 SANDBOX: Supports PDF, images, and text files")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDragOver ? Color.blue : Color.gray.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
        )
        .padding()
        .onDrop(of: [.fileURL], isTargeted: $isDragOver, perform: onDrop)
    }
}

struct DocumentList: View {
    let documents: [DocumentItem]
    @Binding var selectedDocument: DocumentItem?
    let onDelete: (DocumentItem) -> Void
    
    var body: some View {
        List(documents) { document in
            DocumentRow(
                document: document,
                isSelected: selectedDocument?.id == document.id,
                onSelect: { selectedDocument = document },
                onDelete: { onDelete(document) }
            )
        }
        .listStyle(.inset)
    }
}

struct DocumentRow: View {
    let document: DocumentItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Document type icon
            Image(systemName: document.type.icon)
                .font(.title2)
                .foregroundColor(document.type.color)
                .frame(width: 32, height: 32)
            
            // Document info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(document.extractedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(document.dateAdded, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    StatusBadge(status: document.processingStatus)
                }
            }
            
            Spacer()
            
            // Actions
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture {
            onSelect()
        }
    }
}

struct StatusBadge: View {
    let status: ProcessingStatus
    
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

struct DragOverlay: View {
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .overlay(
                VStack {
                    Image(systemName: "doc.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("Drop to upload (SANDBOX)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            )
            .cornerRadius(12)
            .padding()
    }
}

// MARK: - Data Models

struct DocumentItem: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let type: DocumentType
    let dateAdded: Date
    var extractedText: String
    var processingStatus: ProcessingStatus
}

enum ProcessingStatus: CaseIterable {
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
        case .contracts: return .contract
        }
    }
}

#Preview {
    NavigationView {
        DocumentsView()
    }
}