import SwiftUI

/// # Hierarchical Data Browser with Search and Context Menus (Conceptual)
/// Demonstrates browsing hierarchical data with search filtering and contextual menus on items.
/// Combines:
/// - OutlineGroup/List for hierarchical display
/// - TextField for search
/// - .contextMenu for item actions
/// - Inspired by Symbol Gallery and ResourceDatabaseView.
struct HierarchicalDataBrowserView: View {
    // MARK: - State
    @State private var searchText = ""
    
    // Sample hierarchical data (conceptual)
    private let data: [DataItem] = [
        DataItem(name: "Category 1", children: [
            DataItem(name: "Item 1.1"),
            DataItem(name: "Item 1.2", children: [
                DataItem(name: "Item 1.2.1"),
                DataItem(name: "Item 1.2.2")
            ]),
            DataItem(name: "Item 1.3")
        ]),
        DataItem(name: "Category 2", children: [
            DataItem(name: "Item 2.1"),
            DataItem(name: "Item 2.2"),
        ]),
        DataItem(name: "Standalone Item 3")
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search data", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Hierarchical List
            List {
                ForEach(filteredData) {
                    item in
                    OutlineGroup(item, children: \.children) {
                        childItem in
                        HStack {
                            Image(systemName: childItem.icon)
                            Text(childItem.name)
                        }
                        .contextMenu {
                            // MARK: - Context Menu Actions
                            Button(action: { print("Action A on \(childItem.name)") }) {
                                Label("Action A", systemImage: "play.circle")
                            }
                            Button(action: { print("Action B on \(childItem.name)") }) {
                                Label("Action B", systemImage: "info.circle")
                            }
                            Divider()
                            Button(action: { print("Delete \(childItem.name)") }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 300, idealWidth: 400, minHeight: 400, idealHeight: 600)
        .navigationTitle("Data Browser")
    }
    
    // MARK: - Helper Properties
    
    private var filteredData: [DataItem] {
        if searchText.isEmpty {
            return data
        } else {
            // Simple recursive search filter
            return data.compactMap { $0.filter(searchText) }
        }
    }
}

// MARK: - Data Models

struct DataItem: Identifiable {
    let id = UUID()
    let name: String
    var icon: String = "folder"
    var children: [DataItem]?
    
    func filter(_ text: String) -> DataItem? {
        let lowercasedText = text.lowercased()
        // Check if the item name matches
        if name.lowercased().contains(lowercasedText) {
            return self
        }
        // Check if any children match (and filter them)
        if let children = children {
            let filteredChildren = children.compactMap { $0.filter(text) }
            if !filteredChildren.isEmpty {
                // Return a new DataItem with filtered children
                return DataItem(name: name, icon: icon, children: filteredChildren)
            }
        }
        // No match
        return nil
    }
}

// MARK: - Preview
struct HierarchicalDataBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        HierarchicalDataBrowserView()
    }
} 