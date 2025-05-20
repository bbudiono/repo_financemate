import SwiftUI

/// # Block Configuration Menu View (Conceptual)
/// A conceptual view demonstrating a Notion-style block configuration menu:
/// - Appears contextually on block interaction
/// - Displays a list of actions relevant to the block
/// - Can be presented as a popover or context menu
struct BlockConfigurationMenuView: View {
    // MARK: - Properties
    let blockType: String
    
    // Sample actions based on block type (conceptual)
    private var availableActions: [BlockAction] {
        switch blockType {
        case "Text Block":
            return [
                BlockAction(name: "Delete", icon: "trash", role: .destructive),
                BlockAction(name: "Duplicate", icon: "square.on.square"),
                BlockAction(name: "Turn into", icon: "text.append", children: [
                    BlockAction(name: "Heading 1", icon: "text.append"),
                    BlockAction(name: "Bulleted List", icon: "list.bullet")
                ]),
                BlockAction(name: "Copy link", icon: "link"),
                BlockAction(name: "Move to", icon: "arrow.right.square")
            ]
        case "Image Block":
            return [
                BlockAction(name: "Delete", icon: "trash", role: .destructive),
                BlockAction(name: "Duplicate", icon: "square.on.square"),
                BlockAction(name: "Replace image", icon: "photo.on.rectangle"),
                BlockAction(name: "Add caption", icon: "text.bubble"),
                BlockAction(name: "View original", icon: "magnifyingglass"),
            ]
        default:
            return [
                BlockAction(name: "Delete", icon: "trash", role: .destructive),
                BlockAction(name: "Duplicate", icon: "square.on.square"),
                BlockAction(name: "Copy link", icon: "link"),
            ]
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(availableActions) {
                action in
                if let children = action.children {
                    Menu {
                        ForEach(children) {
                            child in
                            Button(action: { print("Selected action: \(child.name)") }) {
                                Label(child.name, systemImage: child.icon)
                            }
                        }
                    } label: {
                        Label(action.name, systemImage: action.icon)
                    }
                } else {
                    Button(action: { print("Selected action: \(action.name)") }) {
                        Label(action.name, systemImage: action.icon)
                    }
                    .keyboardShortcut(action.shortcut)
                    .tint(action.role == .destructive ? .red : .accentColor)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(minWidth: 200)
    }
}

// MARK: - Data Models

struct BlockAction: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbols name
    var role: ButtonRole? = nil
    var shortcut: KeyboardShortcut? = nil
    var children: [BlockAction]? = nil
}

// MARK: - Preview
struct BlockConfigurationMenuView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Simulated Text Block")
                .padding()
                .contextMenu {
                    BlockConfigurationMenuView(blockType: "Text Block")
                }
            
            Text("Simulated Image Block")
                .padding()
                .contextMenu {
                     BlockConfigurationMenuView(blockType: "Image Block")
                }
            
            Text("Simulated Generic Block")
                .padding()
                .contextMenu {
                     BlockConfigurationMenuView(blockType: "Unknown Block")
                }
        }
    }
} 