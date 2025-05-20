import SwiftUI

/// # Data Grid with Inline Editing and Drag Reordering (Conceptual)
/// Demonstrates a data grid with:
/// - Inline cell editing
/// - Sorting and filtering
/// - Drag-and-drop row reordering
struct DataGridWithInlineEditingAndDragReorder: View {
    @State private var rows: [GridRowData] = GridRowData.sampleRows
    @State private var sortAscending = true
    @State private var filterText = ""
    @State private var editingRow: UUID? = nil
    
    var filteredRows: [GridRowData] {
        let filtered = rows.filter { filterText.isEmpty || $0.name.localizedCaseInsensitiveContains(filterText) }
        return sortAscending ? filtered.sorted { $0.value < $1.value } : filtered.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter and Sort Controls
            HStack {
                TextField("Filter by name", text: $filterText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                Spacer()
                Button(action: { sortAscending.toggle() }) {
                    Label(sortAscending ? "Sort Asc" : "Sort Desc", systemImage: "arrow.up.arrow.down")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Data Grid
            List {
                ForEach(filteredRows) { row in
                    HStack {
                        if editingRow == row.id {
                            TextField("Name", text: Binding(
                                get: { row.name },
                                set: { newValue in
                                    if let idx = rows.firstIndex(where: { $0.id == row.id }) {
                                        rows[idx].name = newValue
                                    }
                                })
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        } else {
                            Text(row.name)
                                .frame(width: 120, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        if editingRow == row.id {
                            TextField("Value", value: Binding(
                                get: { row.value },
                                set: { newValue in
                                    if let idx = rows.firstIndex(where: { $0.id == row.id }) {
                                        rows[idx].value = newValue
                                    }
                                }),
                                formatter: NumberFormatter()
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        } else {
                            Text("\(row.value)")
                                .frame(width: 80, alignment: .trailing)
                        }
                        
                        Spacer()
                        
                        Button(editingRow == row.id ? "Done" : "Edit") {
                            editingRow = editingRow == row.id ? nil : row.id
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 4)
                }
                .onMove { indices, newOffset in
                    rows.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active)) // Always allow drag
        }
    }
}

// MARK: - Data Model
struct GridRowData: Identifiable {
    let id: UUID
    var name: String
    var value: Int
    
    static let sampleRows: [GridRowData] = [
        .init(id: UUID(), name: "Alpha", value: 10),
        .init(id: UUID(), name: "Beta", value: 20),
        .init(id: UUID(), name: "Gamma", value: 15),
        .init(id: UUID(), name: "Delta", value: 30),
        .init(id: UUID(), name: "Epsilon", value: 25)
    ]
}

// MARK: - Preview
#Preview {
    DataGridWithInlineEditingAndDragReorder()
        .frame(width: 600, height: 400)
} 