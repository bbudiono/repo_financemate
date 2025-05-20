// CollaborativeTextEditorView.swift
// Advanced SwiftUI Example: Collaborative Text Editor with Simulated Conflict Resolution
// Demonstrates a modular, production-quality real-time collaborative text editor with simulated concurrent edits and conflict resolution.
// Author: AI Agent (2025)
//
// Use case: Real-time collaborative text editing with multiple users making changes simultaneously.
// Most challenging aspect: Implementing efficient text synchronization, handling concurrent edits, and resolving conflicts (simulated here).

import SwiftUI
import Combine

/// Represents a text edit operation.
struct TextEdit: Identifiable, Equatable {
    let id = UUID()
    let userID: String
    let timestamp: Date
    let range: NSRange // Range in the text where the edit occurred
    let text: String? // New text inserted (nil for deletion)
    var isDeletion: Bool { text == nil }
}

/// ViewModel for managing collaborative text editor state and simulated synchronization/conflict resolution.
class CollaborativeTextEditorViewModel: ObservableObject {
    @Published var text: String = "Start typing here...\n"
    @Published var users: [String: Color] = ["user1": .blue, "user2": .green]
    @Published var localUserID: String = "user1"
    @Published var remoteEdits: [TextEdit] = [] // Simulate incoming edits
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Simulate incoming remote edits
        Timer.publish(every: 5.0, on: .main, in: .common).sink { [weak self] _ in
            self?.simulateRemoteEdit()
        }
        .store(in: &cancellables)
    }
    
    // Simulate a remote user making an edit
    func simulateRemoteEdit() {
        guard let remoteUser = users.first(where: { $0.key != localUserID })?.key else { return }
        
        let currentText = text as NSString
        let randomLocation = Int.random(in: 0...currentText.length)
        let randomLength = Int.random(in: 0...min(5, currentText.length - randomLocation))
        let rangeToEdit = NSRange(location: randomLocation, length: randomLength)
        
        let newTextOptions = [" (remote edit) ", " inserted ", nil] // nil represents deletion
        let simulatedNewText = newTextOptions.randomElement() ?? ""
        
        let edit = TextEdit(
            userID: remoteUser,
            timestamp: Date(),
            range: rangeToEdit,
            text: simulatedNewText
        )
        
        // Apply the simulated edit and simulate conflict resolution
        applyRemoteEdit(edit)
    }
    
    // Apply a remote edit and simulate conflict resolution (simplistic)
    func applyRemoteEdit(_ edit: TextEdit) {
        let nsText = text as NSString
        var updatedText = nsText.mutableCopy() as! NSMutableString
        
        // Simulate a potential conflict: local changes might have shifted ranges
        // In a real system, you'd use operational transformation (OT) or CRDTs
        let safeRange = NSRange(location: max(0, min(nsText.length, edit.range.location)),
                                length: min(edit.range.length, nsText.length - max(0, edit.range.location)))
        
        if edit.isDeletion {
            updatedText.deleteCharacters(in: safeRange)
        } else if let newText = edit.text {
            updatedText.replaceCharacters(in: safeRange, with: newText)
        }
        
        // Simulate basic conflict resolution: latest edit wins
        DispatchQueue.main.async {
            self.text = updatedText as String
            // In a real system, you'd signal UI updates or apply OT algorithms
            print("Applied remote edit from \(edit.userID) at \(edit.timestamp): range=\(edit.range), text=\(edit.text ?? "[deletion]"). Current text length: \(self.text.count)")
        }
    }
    
    // Handle local text changes
    func localTextDidChange(_ newText: String) {
        // In a real system, you'd generate TextEdit operations based on diffing newText and oldText
        // and send them to the server.
        print("Local text changed. New length: \(newText.count)")
    }
}

/// Main collaborative text editor view.
struct CollaborativeTextEditorView: View {
    @StateObject private var viewModel = CollaborativeTextEditorViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Collaborative Text Editor")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Text("User: \(viewModel.localUserID)")
                    .font(.caption)
                    .foregroundColor(viewModel.users[viewModel.localUserID] ?? .gray)
                    .padding(.trailing)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Text Editor Area
            TextEditor(text: $viewModel.text)
                .font(.system(.body, design: .monospaced))
                .lineSpacing(4)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(radius: 1)
                .padding()
                .onChange(of: viewModel.text) { newValue in
                    viewModel.localTextDidChange(newValue)
                }
        }
        .cornerRadius(16)
        .shadow(radius: 4)
        .frame(minWidth: 500, minHeight: 300)
    }
}

// MARK: - Preview
struct CollaborativeTextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CollaborativeTextEditorView()
            .frame(width: 600, height: 400)
            .previewDisplayName("Collaborative Text Editor")
    }
} 