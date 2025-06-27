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
    
    // Document processing service
    @StateObject private var processingService: DocumentProcessingService

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

    // Performance management
    @StateObject private var performanceManager: DocumentViewPerformanceManager
    
    // MARK: - Initializer
    init() {
        let context = CoreDataStack.shared.mainContext
        self._fileHandler = StateObject(wrappedValue: DocumentFileHandlingService(context: context))
        self._processingService = StateObject(wrappedValue: DocumentProcessingService())
        self._performanceManager = StateObject(wrappedValue: DocumentViewPerformanceManager())
    }

    // PERFORMANCE OPTIMIZATION: Enhanced filtered documents with better algorithms
    var filteredDocuments: [Document] {
        return performanceManager.optimizeDocumentFiltering(
            documents: documents,
            searchText: searchText,
            selectedFilter: selectedFilter,
            performanceMonitor: performanceMonitor
        )
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
                    if performanceManager.isVirtualizationEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .foregroundColor(performanceManager.filterPerformanceMetrics.performanceGrade.color)
                            Text("Optimized")
                                .font(.caption)
                                .foregroundColor(performanceManager.filterPerformanceMetrics.performanceGrade.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(performanceManager.filterPerformanceMetrics.performanceGrade.color.opacity(0.1))
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
                        isVirtualizationEnabled: performanceManager.isVirtualizationEnabled,
                        visibleRange: $performanceManager.visibleRange
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
            DocumentListPerformanceView(metrics: performanceManager.filterPerformanceMetrics, isVirtualizationEnabled: performanceManager.isVirtualizationEnabled, totalCount: performanceManager.totalDocumentCount)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDocumentType(_ document: Document) -> UIDocumentType {
        guard let fileName = document.fileName else {
            return .other
        }
        
        let lowercasedFileName = fileName.lowercased()
        
        // Simple classification based on file name keywords
        if lowercasedFileName.contains("invoice") {
            return .invoice
        } else if lowercasedFileName.contains("receipt") {
            return .receipt
        } else if lowercasedFileName.contains("statement") {
            return .statement
        } else if lowercasedFileName.contains("bill") {
            return .bill
        } else {
            return .other
        }
    }

    private func handleDocumentDrop(_ providers: [NSItemProvider]) -> Bool {
        isProcessing = true
        
        Task {
            // Extract URLs from providers
            var urls: [URL] = []
            for provider in providers {
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    do {
                        let item = try await provider.loadItem(forTypeIdentifier: "public.file-url", options: nil)
                        if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                            urls.append(url)
                        }
                    } catch {
                        print("Failed to load dropped item: \(error)")
                    }
                }
            }
            
            // Process the URLs
            let results = await processingService.processDocuments(urls: urls)
            let successCount = results.filter { if case .success = $0 { return true }; return false }.count
            let errorCount = results.count - successCount
            
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
        
        return true
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        isProcessing = true

        switch result {
        case .success(let urls):
            Task {
                let results = await processingService.processDocuments(urls: urls)
                let successCount = results.filter { if case .success = $0 { return true }; return false }.count
                let errorCount = results.count - successCount

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
        performanceManager.updateDocumentCount(documents.count)
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