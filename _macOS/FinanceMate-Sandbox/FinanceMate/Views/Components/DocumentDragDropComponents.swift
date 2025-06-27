//
//  DocumentDragDropComponents.swift
//  FinanceMate
//
//  Extracted from DocumentsView.swift for SwiftLint compliance
//  Created by Assistant on 6/28/25.
//

/*
* Purpose: Drag and drop components for document upload functionality
* Issues & Complexity Summary: UI components for file drag-drop interaction
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~80
  - Core Algorithm Complexity: Low (UI presentation)
  - Dependencies: 1 (NSItemProvider)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment: 85%
* Problem Estimate: 70%
* Initial Code Complexity Estimate: 75%
* Final Code Complexity: 72%
* Overall Result Score: 88%
* Key Variances/Learnings: Drag-drop UI simpler than expected
* Last Updated: 2025-06-28
*/

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Drag Drop Zone Component

struct DragDropZone: View {
    @Binding var isDragOver: Bool
    let onDrop: ([NSItemProvider]) -> Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(isDragOver ? .blue : .secondary)
                .accessibilityIdentifier("drop_zone_icon")

            VStack(spacing: 8) {
                Text("Drop documents here")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("drop_zone_title")

                Text("Or click Import Files to browse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("drop_zone_browse_text")

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

// MARK: - Drag Overlay Component

struct DragOverlay: View {
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .overlay(
                VStack {
                    Image(systemName: "doc.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .accessibilityIdentifier("drop_overlay_icon")
                    Text("Drop to upload")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .accessibilityIdentifier("drop_overlay_text")
                }
            )
            .cornerRadius(12)
            .padding()
    }
}

#Preview {
    VStack(spacing: 20) {
        DragDropZone(isDragOver: .constant(false)) { _ in true }
            .frame(height: 200)
        
        DragOverlay()
            .frame(height: 100)
    }
    .padding()
}