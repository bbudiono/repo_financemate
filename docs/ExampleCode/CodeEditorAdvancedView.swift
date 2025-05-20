// CodeEditorAdvancedView.swift
// Advanced SwiftUI Example: Code Editor with Syntax Highlighting and Autocompletion
// Demonstrates a modular, production-quality code editor with syntax highlighting, line numbers, and simulated autocompletion.
// Author: AI Agent (2025)
//
// Use case: In-app code editing with syntax highlighting, autocompletion, and error marking.
// Most challenging aspect: Efficient text rendering, syntax parsing, and responsive autocompletion (simulated here).

import SwiftUI

/// Simple syntax highlighter for Swift keywords (demo only).
struct SwiftSyntaxHighlighter {
    static let keywords: Set<String> = [
        "import", "struct", "class", "let", "var", "func", "return", "if", "else", "for", "in", "while", "switch", "case", "break", "continue", "true", "false", "nil", "enum", "extension", "protocol", "static", "public", "private", "internal", "fileprivate", "open", "init", "self", "super"
    ]
    static func highlight(_ line: String) -> AttributedString {
        var attributed = AttributedString(line)
        for keyword in keywords {
            if let range = attributed.range(of: keyword) {
                attributed[range].foregroundColor = .blue
                attributed[range].font = .system(size: 14, weight: .bold, design: .monospaced)
            }
        }
        return attributed
    }
}

/// ViewModel for managing code editor state and simulated autocompletion.
class CodeEditorViewModel: ObservableObject {
    @Published var code: String = "import SwiftUI\n\nstruct HelloWorldView: View {\n    var body: some View {\n        Text(\"Hello, world!\")\n    }\n}"
    @Published var suggestions: [String] = []
    @Published var showSuggestions: Bool = false
    @Published var cursorLine: Int = 0
    
    // Simulate autocompletion for Swift keywords
    func updateSuggestions(for line: String) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            suggestions = []
            showSuggestions = false
            return
        }
        suggestions = SwiftSyntaxHighlighter.keywords.filter { $0.hasPrefix(trimmed) }
        showSuggestions = !suggestions.isEmpty
    }
}

/// Main code editor view.
struct CodeEditorAdvancedView: View {
    @StateObject private var viewModel = CodeEditorViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Code Editor (Advanced)")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Code editor area
            ZStack(alignment: .topLeading) {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.code.split(separator: "\n").enumerated()), id: \.(0)) { idx, line in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(idx+1)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, design: .monospaced))
                                    .frame(width: 32, alignment: .trailing)
                                Text(SwiftSyntaxHighlighter.highlight(String(line)))
                                    .font(.system(size: 14, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(idx == viewModel.cursorLine ? Color.yellow.opacity(0.15) : Color.clear)
                            }
                            .padding(.vertical, 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                // Transparent TextEditor for input
                TextEditor(text: $viewModel.code)
                    .font(.system(size: 14, design: .monospaced))
                    .opacity(0.01)
                    .focused($isFocused)
                    .onChange(of: viewModel.code) { newValue in
                        // Update suggestions for the current line
                        let lines = newValue.split(separator: "\n", omittingEmptySubsequences: false)
                        let cursorLine = lines.count - 1
                        viewModel.cursorLine = cursorLine
                        if let currentLine = lines.last {
                            viewModel.updateSuggestions(for: String(currentLine))
                        } else {
                            viewModel.suggestions = []
                            viewModel.showSuggestions = false
                        }
                    }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
            .frame(minHeight: 250)
            
            // Autocompletion suggestions
            if viewModel.showSuggestions {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        Button(action: {
                            // Insert suggestion at cursor (demo: append to last line)
                            var lines = viewModel.code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
                            if !lines.isEmpty {
                                lines[lines.count-1] = suggestion
                                viewModel.code = lines.joined(separator: "\n")
                            }
                            viewModel.showSuggestions = false
                        }) {
                            Text(suggestion)
                                .font(.system(size: 14, design: .monospaced))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(.systemGray5))
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .shadow(radius: 2)
            }
        }
        .cornerRadius(16)
        .shadow(radius: 4)
        .frame(minWidth: 600, minHeight: 350)
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Preview
struct CodeEditorAdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        CodeEditorAdvancedView()
            .frame(width: 700, height: 400)
            .previewDisplayName("Code Editor (Advanced)")
    }
} 