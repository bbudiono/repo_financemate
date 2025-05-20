import SwiftUI

/// # Slash Command Menu View (Conceptual)
/// A conceptual view demonstrating a Notion-style slash command menu:
/// - Appears contextually when '/' is typed
/// - Displays a searchable list of commands/block types
/// - Filters results dynamically based on input
struct SlashCommandMenuView: View {
    // MARK: - State
    @Binding var isPresented: Bool
    @State private var searchText = ""
    
    // Sample command data (conceptual)
    private let allCommands = [
        CommandItem(name: "Text", icon: "text.alignleft"),
        CommandItem(name: "Heading 1", icon: "text.append"),
        CommandItem(name: "Heading 2", icon: "text.append"),
        CommandItem(name: "Heading 3", icon: "text.append"),
        CommandItem(name: "Bulleted list", icon: "list.bullet"),
        CommandItem(name: "Numbered list", icon: "list.number"),
        CommandItem(name: "Toggle list", icon: "chevron.right"),
        CommandItem(name: "Quote", icon: "quote.opening"),
        CommandItem(name: "Divider", icon: "line.horizontal.3"),
        CommandItem(name: "Link to page", icon: "link"),
        CommandItem(name: "Image", icon: "photo"),
        CommandItem(name: "Video", icon: "video"),
        CommandItem(name: "Audio", icon: "waveform"),
        CommandItem(name: "Code", icon: "code.slash"),
        CommandItem(name: "File", icon: "doc"),
        CommandItem(name: "Table", icon: "tablecells"),
        CommandItem(name: "Mention a person", icon: "person"),
        CommandItem(name: "Mention a page", icon: "doc.text.magnifyingglass"),
        CommandItem(name: "Date or reminder", icon: "calendar"),
        CommandItem(name: "Comment", icon: "text.bubble"),
        CommandItem(name: "Formula", icon: "function"),
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Search input
            TextField("Filter commands", text: $searchText)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Command list
            List(filteredCommands) {
                command in
                Button(action: { 
                    // Conceptual: Insert block/execute command
                    print("Selected command: \(command.name)")
                    isPresented = false // Dismiss modal after selection
                }) {
                    HStack {
                        Image(systemName: command.icon)
                        Text(command.name)
                        Spacer()
                    }
                }
                .buttonStyle(.plain) // Make the whole row tappable
            }
            .listStyle(.sidebar)
        }
        .frame(minWidth: 250, idealWidth: 300, maxWidth: 400, minHeight: 300, idealHeight: 400, maxHeight: 500)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
    // MARK: - Helper Properties
    
    private var filteredCommands: [CommandItem] {
        if searchText.isEmpty {
            return allCommands
        } else {
            return allCommands.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Data Models

struct CommandItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbols name
}

// MARK: - Preview Wrapper
// A helper struct to preview the modal
struct SlashCommandMenu_Preview_Wrapper: View {
    @State private var showMenu = true
    
    var body: some View {
        Button("Show Command Menu") { showMenu = true }
        .sheet(isPresented: $showMenu) {
            SlashCommandMenuView(isPresented: $showMenu)
        }
    }
}

// MARK: - Previews
struct SlashCommandMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlashCommandMenu_Preview_Wrapper()
    }
} 