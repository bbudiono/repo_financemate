// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  DocumentsView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Clean document management view using real services without TaskMaster UI components
* Real Functionality: Document processing using FinancialDocumentProcessor with Core Data storage
* MCP Integration: Uses TaskMaster-AI MCP server behind the scenes, not as UI feature
*/

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct DocumentsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var themeManager = ThemeManager.shared
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)],
        animation: .default)
    private var documents: FetchedResults<Document>

    @StateObject private var documentProcessor = FinancialDocumentProcessor()

    @State private var isDropTargeted = false
    @State private var processingStatus = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedDocument: Document?
    @State private var showingDocumentDetail = false
    @State private var showingFileImporter = false
    @State private var searchText = ""
    @State private var isProcessing = false

    private let acceptedTypes = [UTType.pdf, UTType.image, UTType.text]

    var filteredDocuments: [Document] {
        let filtered = documents.filter { document in
            if !searchText.isEmpty {
                return document.fileName?.localizedCaseInsensitiveContains(searchText) == true ||
                       document.rawOCRText?.localizedCaseInsensitiveContains(searchText) == true
            }
            return true
        }
        return Array(filtered)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with glassmorphism
            HStack {
                TextField("Search documents...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("documents_search_field")

                Button("Import Files") {
                    showingFileImporter = true
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("import_files_button")
            }
            .padding()
            .lightGlass()

            Divider()
                .background(FinanceMateTheme.textSecondary(for: colorScheme).opacity(0.3))

            // Main Content with glassmorphism
            if documents.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 64))
                        .foregroundColor(FinanceMateTheme.textSecondary(for: colorScheme))
                        .accessibilityIdentifier("documents_empty_icon")

                    Text("No Documents")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(FinanceMateTheme.textPrimary(for: colorScheme))
                        .accessibilityIdentifier("documents_empty_title")

                    Text("Drop files here or use Import Files to add documents")
                        .foregroundColor(FinanceMateTheme.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("documents_empty_description")

                    Button("Import Files") {
                        showingFileImporter = true
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("documents_empty_import_button")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isDropTargeted ? FinanceMateTheme.infoColor : FinanceMateTheme.textSecondary(for: colorScheme).opacity(0.5),
                            style: StrokeStyle(lineWidth: 2, dash: [10])
                        )
                )
                .padding()
                .mediumGlass()
            } else {
                List(filteredDocuments, id: \.self, selection: $selectedDocument) { document in
                    DocumentRowView(document: document) {
                        deleteDocument(document)
                    }
                }
                .lightGlass()
            }

            // Processing Indicator with glassmorphism
            if isProcessing {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)

                    Text("Processing documents...")
                        .font(.caption)
                        .foregroundColor(FinanceMateTheme.textSecondary(for: colorScheme))
                }
                .padding()
                .lightGlass()
            }

            // Status message with theme
            if !processingStatus.isEmpty {
                Text(processingStatus)
                    .font(.caption)
                    .foregroundColor(FinanceMateTheme.textSecondary(for: colorScheme))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .background(
            // Documents background with subtle gradient
            LinearGradient(
                colors: [
                    FinanceMateTheme.surfaceColor(for: colorScheme).opacity(0.1),
                    FinanceMateTheme.surfaceColor(for: colorScheme).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Documents")
        .onDrop(of: acceptedTypes, isTargeted: $isDropTargeted) { providers in
            handleDocumentDrop(providers)
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: acceptedTypes,
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    processDocument(url: url)
                }
            case .failure(let error):
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Document Operations

    private func deleteDocument(_ document: Document) {
        viewContext.delete(document)

        do {
            try viewContext.save()
        } catch {
            print("Error deleting document: \(error)")
        }
    }

    @discardableResult
    private func handleDocumentDrop(_ providers: [NSItemProvider]) -> Bool {
        isProcessing = true
        processingStatus = "Processing \(providers.count) document(s)..."

        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                DispatchQueue.main.async {
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        processDocument(url: url)
                    }

                    if provider == providers.last {
                        isProcessing = false
                        processingStatus = ""
                    }
                }
            }
        }

        return true
    }

    private func processDocument(url: URL) {
        // Create new Core Data document
        let document = Document(context: viewContext)
        document.id = UUID()
        document.fileName = url.lastPathComponent
        document.filePath = url.path
        document.dateCreated = Date()
        document.rawOCRText = "🔄 Processing document..."

        // Save to Core Data
        do {
            try viewContext.save()
        } catch {
            print("Error saving document: \(error)")
            return
        }

        // Process document using real FinancialDocumentProcessor
        Task {
            do {
                let result = await documentProcessor.processFinancialDocument(url: url)

                await MainActor.run {
                    switch result {
                    case .success(let processedDoc):
                        // Update with processed financial data
                        let financialSummary = createFinancialSummary(from: processedDoc.financialData)
                        document.rawOCRText = "✅ \(financialSummary)"

                    case .failure(let error):
                        document.rawOCRText = "❌ Processing failed: \(error.localizedDescription)"
                    }

                    // Save updated document
                    do {
                        try viewContext.save()
                    } catch {
                        print("Error updating document: \(error)")
                    }
                }
            } catch {
                await MainActor.run {
                    document.rawOCRText = "❌ Error: \(error.localizedDescription)"
                    try? viewContext.save()
                }
            }
        }
    }

    private func createFinancialSummary(from financialData: ProcessedFinancialData) -> String {
        var summary = "Financial Document Processed:\n"

        if let amount = financialData.totalAmount {
            summary += "Amount: \(amount.value) \(financialData.currencyCode)\n"
        }

        if let vendor = financialData.vendor {
            summary += "Vendor: \(vendor.name)\n"
        }

        if !financialData.dates.isEmpty {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            summary += "Date: \(formatter.string(from: financialData.dates.first?.date ?? Date()))\n"
        }

        if !financialData.lineItems.isEmpty {
            summary += "Items: \(financialData.lineItems.count)"
        }

        return summary
    }
}

// MARK: - Document Row View

struct DocumentRowView: View {
    let document: Document
    let onDelete: () -> Void

    var body: some View {
        HStack {
            // Document icon
            Image(systemName: documentIcon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.fileName ?? "Unknown Document")
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityIdentifier("document_row_filename_\(document.id?.uuidString ?? "unknown")")

                Text(document.rawOCRText ?? "No content")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .accessibilityIdentifier("document_row_content_\(document.id?.uuidString ?? "unknown")")

                HStack {
                    Text(documentType)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)

                    Spacer()

                    if let date = document.dateCreated {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("document_row_delete_\(document.id?.uuidString ?? "unknown")")
            .accessibilityLabel("Delete document")
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("document_row_\(document.id?.uuidString ?? "unknown")")
        .accessibilityLabel("Document: \(document.fileName ?? "Unknown Document")")
    }

    private var documentIcon: String {
        guard let name = document.fileName else { return "doc" }

        if name.hasSuffix(".pdf") {
            return "doc.text.fill"
        } else if name.hasSuffix(".jpg") || name.hasSuffix(".png") || name.hasSuffix(".jpeg") {
            return "photo"
        } else {
            return "doc"
        }
    }

    private var documentType: String {
        guard let name = document.fileName else { return "Document" }

        if name.hasSuffix(".pdf") {
            return "PDF"
        } else if name.hasSuffix(".jpg") || name.hasSuffix(".png") || name.hasSuffix(".jpeg") {
            return "Image"
        } else {
            return "Document"
        }
    }
}

#Preview {
    DocumentsView()
        .environment(\.managedObjectContext, CoreDataStack.shared.mainContext)
}
