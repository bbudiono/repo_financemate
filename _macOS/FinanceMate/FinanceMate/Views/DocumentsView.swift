//
//  DocumentsView.swift
//  FinanceMate
//
//  Created by Assistant on 6/2/25.
//

/*
* Purpose: Comprehensive document management with drag-drop upload, filtering, and document processing
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
import Vision
import VisionKit
import PDFKit
import Quartz

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
            // Header with search and filters
            VStack(spacing: 16) {
                HStack {
                    Text("Document Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
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
                    Text("Processing documents...")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            print("File import error: \(error)")
        }
        
        isProcessing = false
    }
    
    private func processDocument(url: URL) {
        // Create document item
        let document = DocumentItem(
            name: url.lastPathComponent,
            url: url,
            type: UIDocumentType.from(url: url),
            dateAdded: Date(),
            extractedText: "Processing...",
            processingStatus: .processing
        )
        
        documents.append(document)
        
        // Real OCR processing using Apple Vision framework
        Task {
            do {
                let extractedText = try await performRealOCR(on: url)
                
                await MainActor.run {
                    if let index = documents.firstIndex(where: { $0.id == document.id }) {
                        documents[index].extractedText = extractedText.isEmpty ? "No text detected" : extractedText
                        documents[index].processingStatus = .completed
                    }
                }
            } catch {
                await MainActor.run {
                    if let index = documents.firstIndex(where: { $0.id == document.id }) {
                        documents[index].extractedText = "OCR failed: \(error.localizedDescription)"
                        documents[index].processingStatus = .error
                    }
                }
            }
        }
    }
    
    private func performRealOCR(on url: URL) async throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try await extractTextFromPDF(url: url)
        case "jpg", "jpeg", "png", "tiff", "heic":
            return try await extractTextFromImage(url: url)
        case "txt":
            return try String(contentsOf: url, encoding: .utf8)
        default:
            throw OCRError.unsupportedFileType
        }
    }
    
    private func extractTextFromPDF(url: URL) async throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw OCRError.pdfLoadFailed
        }
        
        var fullText = ""
        
        // First try to extract native text
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }
        
        // If no native text found, use OCR on PDF pages
        if fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            for pageIndex in 0..<min(pdfDocument.pageCount, 10) { // Limit to first 10 pages
                guard let page = pdfDocument.page(at: pageIndex) else { continue }
                
                let pageRect = page.bounds(for: .mediaBox)
                
                // Create image from PDF page using macOS APIs
                let nsImage = NSImage(size: pageRect.size)
                nsImage.lockFocus()
                
                let context = NSGraphicsContext.current!.cgContext
                context.translateBy(x: 0, y: pageRect.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                page.draw(with: .mediaBox, to: context)
                
                nsImage.unlockFocus()
                
                guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    continue
                }
                let pageImage = NSImage(cgImage: cgImage, size: pageRect.size)
                
                let ocrText = try await performVisionOCR(on: cgImage)
                fullText += ocrText + "\n"
            }
        }
        
        return fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractTextFromImage(url: URL) async throws -> String {
        guard let nsImage = NSImage(contentsOf: url) else {
            throw OCRError.imageLoadFailed
        }
        
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageProcessingFailed
        }
        
        return try await performVisionOCR(on: cgImage)
    }
    
    private func performVisionOCR(on cgImage: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: recognizedText)
            }
            
            // Configure for maximum accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func deleteDocument(_ document: DocumentItem) {
        documents.removeAll { $0.id == document.id }
    }
    
    private func loadSampleDocuments() {
        // REMOVED: No more fake data for TestFlight readiness
        // Starting with empty state to show real document upload functionality
        documents = []
        
        // Log for production tracking
        print("📱 PRODUCTION: DocumentsView initialized with empty state - ready for real document uploads")
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
                
                Text("Supports PDF, images, and text files")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    let status: UIProcessingStatus
    
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
                    Text("Drop to upload")
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
    let type: UIDocumentType
    let dateAdded: Date
    var extractedText: String
    var processingStatus: UIProcessingStatus
}

enum UIDocumentType: CaseIterable {
    case invoice
    case receipt
    case statement
    case contract
    case other
    
    var icon: String {
        switch self {
        case .invoice: return "doc.text"
        case .receipt: return "receipt"
        case .statement: return "doc.plaintext"
        case .contract: return "doc.badge.ellipsis"
        case .other: return "doc"
        }
    }
    
    var color: Color {
        switch self {
        case .invoice: return .blue
        case .receipt: return .green
        case .statement: return .orange
        case .contract: return .purple
        case .other: return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .statement: return "Statement"
        case .contract: return "Contract"
        case .other: return "Other"
        }
    }
    
    static func from(url: URL) -> UIDocumentType {
        let filename = url.lastPathComponent.lowercased()
        if filename.contains("invoice") { return .invoice }
        if filename.contains("receipt") { return .receipt }
        if filename.contains("statement") { return .statement }
        if filename.contains("contract") { return .contract }
        return .other
    }
}

enum UIProcessingStatus {
    case pending
    case processing
    case completed
    case error
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle"
        case .error: return "exclamationmark.triangle"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .error: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Ready"
        case .error: return "Error"
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
    
    var documentType: UIDocumentType? {
        switch self {
        case .all: return nil
        case .invoices: return .invoice
        case .receipts: return .receipt
        case .statements: return .statement
        case .contracts: return .contract
        }
    }
}

// MARK: - OCR Error Types

enum OCRError: Error, LocalizedError {
    case unsupportedFileType
    case pdfLoadFailed
    case imageLoadFailed
    case imageProcessingFailed
    case visionFrameworkError(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFileType:
            return "Unsupported file type for OCR processing"
        case .pdfLoadFailed:
            return "Failed to load PDF document"
        case .imageLoadFailed:
            return "Failed to load image file"
        case .imageProcessingFailed:
            return "Failed to process image for OCR"
        case .visionFrameworkError(let message):
            return "Vision framework error: \(message)"
        }
    }
}

#Preview {
    NavigationView {
        DocumentsView()
    }
}