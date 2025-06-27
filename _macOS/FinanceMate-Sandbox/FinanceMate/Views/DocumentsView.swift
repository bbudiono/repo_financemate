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

import CoreData
import PDFKit
import Quartz
import SwiftUI

// MARK: - Import Centralized Theme
// CentralizedTheme.swift provides glassmorphism effects and theme management
import UniformTypeIdentifiers
import Vision
import VisionKit

// MARK: - Extracted Models
// DocumentFilter, UIDocumentType, and related enums moved to DocumentModels.swift
// NOTE: DocumentModels.swift and DocumentDetailView.swift need to be added to Xcode project

struct DocumentsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // PERFORMANCE OPTIMIZATION: Core Data fetch request with improved configuration
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)],
        animation: .easeInOut(duration: 0.2))
    private var documents: FetchedResults<Document>
    
    // Performance monitoring for documents view
    @EnvironmentObject private var performanceMonitor: AppPerformanceMonitor
    
    // Document file handling service
    @StateObject private var fileHandler: DocumentFileHandlingService

    @State private var searchText = ""
    @State private var selectedFilter: DocumentFilter = .all
    @State private var isDragOver = false
    @State private var showingFileImporter = false
    @State private var selectedDocument: Document?
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSuccess = false
    @State private var successMessage = ""
    @State private var showingPerformanceInfo = false

    // Performance tracking variables
    @State private var isVirtualizationEnabled = false
    @State private var visibleRange: Range<Int> = 0..<50
    @State private var totalDocumentCount = 0
    @State private var filterPerformanceMetrics = DocumentViewPerformanceMetrics()
    
    // MARK: - Initializer
    init() {
        self._fileHandler = StateObject(wrappedValue: DocumentFileHandlingService(context: CoreDataStack.shared.mainContext))
    }

    // PERFORMANCE OPTIMIZATION: Enhanced filtered documents with better algorithms
    var filteredDocuments: [Document] {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Early return for better performance
        if documents.isEmpty {
            return []
        }

        // PERFORMANCE OPTIMIZATION: Use lazy evaluation for large datasets
        let filtered = documents.lazy.filter { document in
            // Apply document type filter first (most selective)
            if selectedFilter != .all && getDocumentType(document) != selectedFilter.uiDocumentType {
                return false
            }

            // Apply search text filter with optimized search
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let fileName = (document.fileName ?? "").lowercased()
                let extractedText = (document.rawOCRText ?? "").lowercased()
                
                // PERFORMANCE OPTIMIZATION: Short-circuit evaluation
                return fileName.contains(searchLower) || extractedText.contains(searchLower)
            }

            return true
        }

        // PERFORMANCE OPTIMIZATION: Limit sorting for large datasets
        let result: [Document]
        if performanceMonitor.isLowMemoryMode && filtered.count > 100 {
            // In low memory mode, limit results
            result = Array(filtered.prefix(100))
        } else {
            result = filtered.sorted {
                ($0.dateCreated ?? Date.distantPast) > ($1.dateCreated ?? Date.distantPast)
            }
        }

        // Update performance metrics
        let endTime = CFAbsoluteTimeGetCurrent()
        DispatchQueue.main.async {
            self.filterPerformanceMetrics.lastFilterTime = endTime - startTime
            self.filterPerformanceMetrics.totalFilters += 1
        }

        return result
    }

    private func getDocumentType(_ document: Document) -> UIDocumentType {
        guard let fileName = document.fileName else { return .other }
        let filename = fileName.lowercased()
        if filename.contains("invoice") { return .invoice }
        if filename.contains("receipt") { return .receipt }
        if filename.contains("statement") { return .statement }
        if filename.contains("contract") { return .contract }
        return .other
    }

    private func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "pdf": return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "txt": return "text/plain"
        case "tiff": return "image/tiff"
        case "heic": return "image/heic"
        default: return "application/octet-stream"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filters
            VStack(spacing: 16) {
                HStack {
                    Text("Document Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("documents_header_title")

                    // Performance indicator
                    if isVirtualizationEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .foregroundColor(filterPerformanceMetrics.performanceGrade.color)
                            Text("Optimized")
                                .font(.caption)
                                .foregroundColor(filterPerformanceMetrics.performanceGrade.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(filterPerformanceMetrics.performanceGrade.color.opacity(0.1))
                        .cornerRadius(6)
                        .onTapGesture {
                            showingPerformanceInfo.toggle()
                        }
                    }

                    Spacer()

                    Button("Import Files") {
                        showingFileImporter = true
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("import_files_button")
                }

                HStack {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search documents...", text: $searchText)
                            .textFieldStyle(.plain)
                            .accessibilityIdentifier("documents_search_field")
                    }
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.1), lineWidth: 0.5))

                    // Filter picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(DocumentFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    .accessibilityIdentifier("documents_filter_picker")
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
                // Document list with drag-drop overlay and virtualization
                ZStack {
                    OptimizedDocumentList(
                        documents: filteredDocuments,
                        selectedDocument: $selectedDocument,
                        onDelete: deleteDocument,
                        isVirtualizationEnabled: isVirtualizationEnabled,
                        visibleRange: $visibleRange
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
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding()
            }
        }
        .navigationTitle("Documents")
        .sheet(item: $selectedDocument) { document in
            DocumentDetailView(document: document) {
                selectedDocument = nil
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.pdf, .image, .text],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .onAppear {
            // Core Data automatically loads documents via @FetchRequest
            // Update total count for virtualization decisions
            updateTotalCount()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showingSuccess) {
            Button("OK") { }
        } message: {
            Text(successMessage)
        }
        .sheet(isPresented: $showingPerformanceInfo) {
            DocumentListPerformanceView(metrics: filterPerformanceMetrics, isVirtualizationEnabled: isVirtualizationEnabled, totalCount: totalDocumentCount)
        }
    }

    private func handleDocumentDrop(_ providers: [NSItemProvider]) -> Bool {
        isProcessing = true

        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
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
            Task {
                var successCount = 0
                var errorCount = 0

                for url in urls {
                    do {
                        try await processDocumentWithErrorHandling(url: url)
                        successCount += 1
                    } catch {
                        errorCount += 1
                    }
                }

                await MainActor.run {
                    isProcessing = false

                    if errorCount == 0 {
                        successMessage = "Successfully imported \(successCount) document\(successCount == 1 ? "" : "s")"
                        showingSuccess = true
                    } else if successCount == 0 {
                        errorMessage = "Failed to import \(errorCount) document\(errorCount == 1 ? "" : "s")"
                        showingError = true
                    } else {
                        successMessage = "Imported \(successCount) documents successfully, \(errorCount) failed"
                        showingSuccess = true
                    }
                }
            }
        case .failure(let error):
            errorMessage = "File selection failed: \(error.localizedDescription)"
            showingError = true
            isProcessing = false
        }
    }

    private func processDocumentWithErrorHandling(url: URL) async throws {
        // Create Core Data Document entity
        let document = Document(context: viewContext)
        document.id = UUID()
        document.fileName = url.lastPathComponent
        document.filePath = url.path
        document.dateCreated = Date()
        document.rawOCRText = "Processing..."
        document.processingStatus = "processing"
        document.mimeType = getMimeType(for: url)

        // Get file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            document.fileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            document.fileSize = 0
        }

        // Save to Core Data immediately with processing status
        do {
            try viewContext.save()
        } catch {
            throw DocumentError.saveError(error.localizedDescription)
        }

        // Real OCR processing using Apple Vision framework
        do {
            let extractedText = try await performBackgroundOCR(on: url)

            await MainActor.run {
                document.rawOCRText = extractedText.isEmpty ? "No text detected" : extractedText
                document.processingStatus = "completed"

                do {
                    try viewContext.save()
                } catch {
                    document.rawOCRText = "Save failed: \(error.localizedDescription)"
                    document.processingStatus = "error"
                }
            }
        } catch {
            await MainActor.run {
                document.rawOCRText = "OCR failed: \(error.localizedDescription)"
                document.processingStatus = "error"

                do {
                    try viewContext.save()
                } catch {
                    // Document will remain in error state
                }
            }
            throw DocumentError.ocrError(error.localizedDescription)
        }
    }

    private func processDocument(url: URL) {
        Task {
            do {
                try await processDocumentWithErrorHandling(url: url)
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to process \(url.lastPathComponent): \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }

    private func performBackgroundOCR(on url: URL) async throws -> String {
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
        try await withCheckedThrowingContinuation { continuation in
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

    private func deleteDocument(_ document: Document) {
        viewContext.delete(document)

        do {
            try viewContext.save()
            print("✅ Document deleted from Core Data: \(document.fileName ?? "Unknown")")
            // Update total count after deletion
            updateTotalCount()
        } catch {
            print("❌ Failed to delete document: \(error)")
        }
    }

    private func updateTotalCount() {
        totalDocumentCount = documents.count
        // Enable virtualization for large datasets
        isVirtualizationEnabled = totalDocumentCount > 100
    }
}

// DragDropZone moved to Components/DocumentDragDropComponents.swift

// OptimizedDocumentList moved to Components/OptimizedDocumentList.swift

// DocumentRow moved to Components/OptimizedDocumentList.swift

// StatusBadge moved to Components/OptimizedDocumentList.swift

// DragOverlay moved to Components/DocumentDragDropComponents.swift

// MARK: - Data Models
// UIProcessingStatus moved to DocumentModels.swift

// MARK: - DocumentDetailView extracted to separate file
// DocumentDetailView is now in DocumentDetailView.swift for SwiftLint compliance

// MARK: - Document List Performance View

// DocumentListPerformanceView moved to Components/DocumentListPerformanceView.swift

// PerformanceMetricRow moved to Components/DocumentListPerformanceView.swift

#Preview {
    NavigationView {
        DocumentsView()
    }
}