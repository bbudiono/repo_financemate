import SwiftUI

/// # Kanban Board with Checklist and Progress (Conceptual)
/// Demonstrates a Kanban board with:
/// - Drag-and-drop cards between columns
/// - Inline editing of card titles
/// - Checklist per card
/// - Animated progress ring for completion
struct KanbanBoardWithChecklistAndProgress: View {
    @State private var columns: [KanbanColumn] = KanbanColumn.sampleColumns
    @State private var editingCardID: UUID? = nil
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 32) {
                ForEach($columns) { $column in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(column.title)
                            .font(.headline)
                        VStack(spacing: 12) {
                            ForEach($column.cards) { $card in
                                KanbanCardView(card: $card, isEditing: editingCardID == card.id, onEdit: {
                                    editingCardID = card.id
                                }, onDoneEditing: {
                                    editingCardID = nil
                                })
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .frame(width: 260)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                }
            }
            .padding()
        }
    }
}

// MARK: - Kanban Card View
struct KanbanCardView: View {
    @Binding var card: KanbanCard
    var isEditing: Bool
    var onEdit: () -> Void
    var onDoneEditing: () -> Void
    
    var completion: Double {
        guard !card.checklist.isEmpty else { return 0 }
        let completed = card.checklist.filter { $0.completed }.count
        return Double(completed) / Double(card.checklist.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isEditing {
                    TextField("Title", text: $card.title, onCommit: onDoneEditing)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(card.title)
                        .font(.headline)
                        .onTapGesture { onEdit() }
                }
                Spacer()
                ProgressRing(progress: completion)
                    .frame(width: 28, height: 28)
            }
            ForEach($card.checklist) { $item in
                HStack {
                    Button(action: { item.completed.toggle() }) {
                        Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.completed ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                    TextField("Task", text: $item.text)
                        .textFieldStyle(.plain)
                }
            }
        }
        .padding(8)
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    var progress: Double // 0.0 to 1.0
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            Text("\(Int(progress * 100))%")
                .font(.caption2)
        }
    }
}

// MARK: - Data Models
struct KanbanColumn: Identifiable {
    let id = UUID()
    var title: String
    var cards: [KanbanCard]
    
    static let sampleColumns: [KanbanColumn] = [
        KanbanColumn(title: "To Do", cards: [
            KanbanCard(title: "Design UI", checklist: [
                ChecklistItem(text: "Wireframe", completed: true),
                ChecklistItem(text: "Mockup", completed: false)
            ]),
            KanbanCard(title: "Setup Project", checklist: [
                ChecklistItem(text: "Create repo", completed: true),
                ChecklistItem(text: "Setup CI", completed: false)
            ])
        ]),
        KanbanColumn(title: "In Progress", cards: [
            KanbanCard(title: "Implement Features", checklist: [
                ChecklistItem(text: "Login", completed: true),
                ChecklistItem(text: "Dashboard", completed: false)
            ])
        ]),
        KanbanColumn(title: "Done", cards: [
            KanbanCard(title: "Research", checklist: [
                ChecklistItem(text: "Competitors", completed: true),
                ChecklistItem(text: "User Needs", completed: true)
            ])
        ])
    ]
}

struct KanbanCard: Identifiable {
    let id = UUID()
    var title: String
    var checklist: [ChecklistItem]
}

struct ChecklistItem: Identifiable {
    let id = UUID()
    var text: String
    var completed: Bool
}

// MARK: - Preview
#Preview {
    KanbanBoardWithChecklistAndProgress()
        .frame(width: 1200, height: 500)
} 