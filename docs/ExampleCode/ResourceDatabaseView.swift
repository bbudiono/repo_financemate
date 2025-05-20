import SwiftUI

/// # Resource Database Browser View
/// Professional view for browsing and managing local resources:
/// - Hierarchical file and folder display
/// - Search and filtering
/// - Resource metadata display
/// - Integration with local data (simulated)
struct ResourceDatabaseView: View {
    // MARK: - State
    @State private var resources: [FileSystemItem] = sampleFileSystem
    @State private var searchText = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search resources", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Resource List (Simulated File System)
            List(filteredResources, children: \.children) {
                item in
                HStack {
                    Image(systemName: item.isFolder ? "folder.fill" : "doc.fill")
                        .foregroundColor(item.isFolder ? .blue : .secondary)
                    Text(item.name)
                    
                    if !item.isFolder {
                        Text("(\(formatBytes(item.size ?? 0))")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let date = item.modificationDate {
                         Text("\(date, format: .dateTime.date())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var filteredResources: [FileSystemItem] {
        if searchText.isEmpty {
            return resources
        } else {
            return resources.filter { $0.name.localizedCaseInsensitiveContains(searchText) || ($0.children?.filter { $0.name.localizedCaseInsensitiveContains(searchText) }.isEmpty == false) }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Data Models

struct FileSystemItem: Identifiable {
    let id = UUID()
    let name: String
    let isFolder: Bool
    var size: Int? // in bytes
    var modificationDate: Date? = Date()
    var children: [FileSystemItem]?
}

// Sample Data (Simulated File System)
let sampleFileSystem: [FileSystemItem] = [
    FileSystemItem(name: "Documents", isFolder: true, children: [
        FileSystemItem(name: "Report.docx", isFolder: false, size: 15000, modificationDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())),
        FileSystemItem(name: "Presentation.pptx", isFolder: false, size: 85000, modificationDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())),
        FileSystemItem(name: "Archive", isFolder: true, children: [
            FileSystemItem(name: "OldNotes.txt", isFolder: false, size: 2000, modificationDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()))
        ])
    ]),
    FileSystemItem(name: "Downloads", isFolder: true, children: [
        FileSystemItem(name: "Setup.dmg", isFolder: false, size: 500000, modificationDate: Date())
    ]),
    FileSystemItem(name: "Pictures", isFolder: true, children: [
        FileSystemItem(name: "Vacation", isFolder: true, children: [
            FileSystemItem(name: "photo1.jpg", isFolder: false, size: 3000000, modificationDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())),
            FileSystemItem(name: "photo2.jpg", isFolder: false, size: 2500000, modificationDate: Calendar.current.date(byAdding: .day, value: -9, to: Date()))
        ]),
        FileSystemItem(name: "Screenshots", isFolder: true, children: [])
    ]),
    FileSystemItem(name: "README.md", isFolder: false, size: 5000, modificationDate: Date())
]

// MARK: - Previews
struct ResourceDatabaseView_Previews: PreviewProvider {
    static var previews: some View {
        ResourceDatabaseView()
            .frame(width: 500, height: 700)
    }
} 