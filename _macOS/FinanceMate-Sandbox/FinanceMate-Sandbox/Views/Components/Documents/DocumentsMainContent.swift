// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DocumentsMainContent.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular documents main content area managing empty state, document list, and drag-drop functionality
* Issues & Complexity Summary: Main content orchestrator switching between empty state and document list with drag-drop overlay
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Medium (content state switching, drag-drop handling, document selection)
  - Dependencies: 5 New (SwiftUI, drag-drop support, content components, action callbacks, state bindings)
  - State Management Complexity: Medium (drag state, document selection, action coordination)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
* Problem Estimate (Inherent Problem Difficulty %): 30%
* Initial Code Complexity Estimate %): 33%
* Justification for Estimates: Straightforward content orchestration with well-defined state management
* Final Code Complexity (Actual %): 36%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Content separation improves maintainability while preserving drag-drop functionality
* Last Updated: 2025-06-06
*/

import SwiftUI

struct DocumentsMainContent: View {
    let documents: [DocumentItem]
    let filteredDocuments: [DocumentItem]
    @Binding var selectedDocument: DocumentItem?
    @Binding var isDragOver: Bool
    
    let onDocumentDrop: ([NSItemProvider]) -> Void
    let onDocumentDelete: (DocumentItem) -> Void
    let onDocumentSelect: (DocumentItem) -> Void
    
    var body: some View {
        Group {
            if documents.isEmpty {
                // Empty state with drag-drop zone
                VStack(spacing: 20) {
                    Spacer()
                    
                    DragDropZone(
                        isDragOver: $isDragOver,
                        onDrop: { providers in
                            onDocumentDrop(providers)
                            return true
                        }
                    )
                    
                    Spacer()
                }
            } else {
                // Document list with drag-drop overlay
                ZStack {
                    DocumentList(
                        documents: filteredDocuments,
                        selectedDocument: $selectedDocument,
                        onDelete: onDocumentDelete,
                        onSelect: onDocumentSelect
                    )
                    
                    if isDragOver {
                        DragOverlay()
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
                    onDocumentDrop(providers)
                    return true
                }
            }
        }
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
    let onSelect: (DocumentItem) -> Void
    
    var body: some View {
        List(documents) { document in
            HStack {
                Image(systemName: document.type.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.headline)
                    
                    Text(document.extractedText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: { onDelete(document) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            .background(selectedDocument?.id == document.id ? Color.blue.opacity(0.1) : Color.clear)
            .onTapGesture {
                onSelect(document)
            }
        }
        .listStyle(.inset)
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