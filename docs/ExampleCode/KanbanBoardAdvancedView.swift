// KanbanBoardAdvancedView.swift
// Advanced SwiftUI Example: Kanban Board with Drag-and-Drop
// Demonstrates a modular, production-quality Kanban board with drag-and-drop columns and cards.
// Author: AI Agent (2025)
//
// Use case: Task management board with drag-and-drop columns and cards, supporting persistence and multi-user updates.
// Most challenging aspect: Smooth drag-and-drop, state management, and real-time sync (simulated here).

import SwiftUI

/// Represents a single Kanban card (task).
struct KanbanCard: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var description: String
}

/// Represents a Kanban column (e.g., To Do, In Progress, Done).
struct KanbanColumn: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var cards: [KanbanCard]
}

/// ViewModel for managing Kanban board state and drag-and-drop logic.
class KanbanBoardViewModel: ObservableObject {
    @Published var columns: [KanbanColumn] = [
        KanbanColumn(title: "To Do", cards: [
            KanbanCard(title: "Design UI", description: "Create wireframes for new feature."),
            KanbanCard(title: "Write Specs", description: "Document requirements.")
        ]),
        KanbanColumn(title: "In Progress", cards: [
            KanbanCard(title: "Implement ViewModel", description: "Develop data logic."),
        ]),
        KanbanColumn(title: "Done", cards: [
            KanbanCard(title: "Setup Project", description: "Initial Xcode project setup.")
        ])
    ]
    @Published var draggingCard: KanbanCard? = nil
    @Published var dragSourceColumnID: UUID? = nil
    
    // Move card from one column to another
    func moveCard(_ card: KanbanCard, from sourceColumnID: UUID, to destColumnID: UUID, at destIndex: Int?) {
        guard let sourceIdx = columns.firstIndex(where: { $0.id == sourceColumnID }),
              let cardIdx = columns[sourceIdx].cards.firstIndex(of: card),
              let destIdx = columns.firstIndex(where: { $0.id == destColumnID }) else { return }
        // Remove from source
        let removed = columns[sourceIdx].cards.remove(at: cardIdx)
        // Insert into destination
        if let destIndex = destIndex, destIndex <= columns[destIdx].cards.count {
            columns[destIdx].cards.insert(removed, at: destIndex)
        } else {
            columns[destIdx].cards.append(removed)
        }
    }
    
    // Add a new card to a column
    func addCard(to columnID: UUID) {
        guard let idx = columns.firstIndex(where: { $0.id == columnID }) else { return }
        let newCard = KanbanCard(title: "New Task", description: "Description...")
        columns[idx].cards.insert(newCard, at: 0)
    }
}

/// Main Kanban board view.
struct KanbanBoardAdvancedView: View {
    @StateObject private var viewModel = KanbanBoardViewModel()
    @Namespace private var cardNamespace
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Kanban Board (Advanced)")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Kanban columns
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 24) {
                    ForEach(viewModel.columns) { column in
                        KanbanColumnView(
                            column: column,
                            draggingCard: $viewModel.draggingCard,
                            dragSourceColumnID: $viewModel.dragSourceColumnID,
                            onMoveCard: { card, sourceID, destID, destIndex in
                                viewModel.moveCard(card, from: sourceID, to: destID, at: destIndex)
                            },
                            onAddCard: {
                                viewModel.addCard(to: column.id)
                            }
                        )
                        .frame(width: 280)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
        }
        .cornerRadius(16)
        .shadow(radius: 4)
        .frame(minWidth: 900, minHeight: 400)
    }
}

/// Visual representation of a Kanban column.
struct KanbanColumnView: View {
    let column: KanbanColumn
    @Binding var draggingCard: KanbanCard?
    @Binding var dragSourceColumnID: UUID?
    let onMoveCard: (KanbanCard, UUID, UUID, Int?) -> Void
    let onAddCard: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(column.title)
                    .font(.headline)
                Spacer()
                Button(action: onAddCard) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 4)
            
            ForEach(Array(column.cards.enumerated()), id: \.(1)) { idx, card in
                KanbanCardView(card: card)
                    .opacity(draggingCard == card ? 0.3 : 1.0)
                    .onDrag {
                        self.draggingCard = card
                        self.dragSourceColumnID = column.id
                        return NSItemProvider(object: card.title as NSString)
                    }
                    .onDrop(of: [UTType.text], delegate: KanbanDropDelegate(
                        card: card,
                        column: column,
                        draggingCard: $draggingCard,
                        dragSourceColumnID: $dragSourceColumnID,
                        onMoveCard: onMoveCard,
                        destIndex: idx
                    ))
            }
            // Drop at end of column
            Rectangle()
                .fill(Color.clear)
                .frame(height: 24)
                .onDrop(of: [UTType.text], delegate: KanbanDropDelegate(
                    card: nil,
                    column: column,
                    draggingCard: $draggingCard,
                    dragSourceColumnID: $dragSourceColumnID,
                    onMoveCard: onMoveCard,
                    destIndex: column.cards.count
                ))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Visual representation of a Kanban card.
struct KanbanCardView: View {
    let card: KanbanCard
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.title)
                .font(.headline)
            Text(card.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

/// Drop delegate for handling drag-and-drop of Kanban cards.
import UniformTypeIdentifiers
struct KanbanDropDelegate: DropDelegate {
    let card: KanbanCard?
    let column: KanbanColumn
    @Binding var draggingCard: KanbanCard?
    @Binding var dragSourceColumnID: UUID?
    let onMoveCard: (KanbanCard, UUID, UUID, Int?) -> Void
    let destIndex: Int?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggingCard = draggingCard, let sourceID = dragSourceColumnID else { return false }
        onMoveCard(draggingCard, sourceID, column.id, destIndex)
        self.draggingCard = nil
        self.dragSourceColumnID = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Optional: highlight drop target
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        // Optional: remove highlight
    }
}

// MARK: - Preview
struct KanbanBoardAdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        KanbanBoardAdvancedView()
            .frame(width: 1000, height: 500)
            .previewDisplayName("Kanban Board (Advanced)")
    }
} 