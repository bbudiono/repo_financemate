// LiveMarkdownPreviewView.swift
// Advanced SwiftUI Example: Live Markdown Preview
// Demonstrates a modular, production-quality bi-directional markdown editor with live preview and simulated syntax highlighting.
// Author: AI Agent (2025)
//
// Use case: Bi-directional markdown editor with live preview and syntax highlighting.
// Most challenging aspect: Efficient parsing, diffing, and keeping editor and preview in sync (simulated here).

import SwiftUI
import Combine
import MarkdownUI // Assuming MarkdownUI or similar library is available/added as a dependency

/// ViewModel for managing markdown editor state and live preview.
class MarkdownEditorViewModel: ObservableObject {
    @Published var markdownText: String = "# Hello, Markdown!\n\nThis is a **live preview** of your markdown.\n\n- Item 1\n- Item 2\n\n```swift\nlet greeting = \"Hello, world!\"\nprint(greeting)\n```\n"
    
    // In a real app, you'd parse markdown here
    // For this example, we'll just use the MarkdownUI library directly in the view.
}

/// Main live markdown preview view.
struct LiveMarkdownPreviewView: View {
    @StateObject private var viewModel = MarkdownEditorViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Live Markdown Preview")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Editor and Preview Area
            HSplitView { // Use HSplitView for a resizable split view
                // Markdown Editor (Left Side)
                TextEditor(text: $viewModel.markdownText)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 1)
                    .padding(.horizontal)
                    .frame(minWidth: 200)
                
                // Live Preview (Right Side)
                ScrollView {
                    Markdown(viewModel.markdownText)
                        .markdownTextStyle(
                            // Example of simulated syntax highlighting via text style
                            MarkdownInlineStyle(), base: .markdownFromStandardColors()
                        )
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 1)
                .padding(.horizontal)
                .frame(minWidth: 200)
            }
            .padding(.bottom)
        }
        .cornerRadius(16)
        .shadow(radius: 4)
        .frame(minWidth: 600, minHeight: 400)
    }
}

// A basic example of applying standard colors via a custom style. In a real syntax highlighter, this would be more complex.
struct MarkdownFromStandardColors: MarkdownStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
    
    func inline(_ configuration: InlineConfiguration) -> some View {
           configuration.label
               .foregroundColor(
                   color(for: configuration.kind)
               )
       }
       
       private func color(for kind: MarkdownInlineKind) -> Color? {
           switch kind {
           case .code: return .purple
           case .emphasis: return .orange
           case .strong: return .red
           case .strikethrough: return .gray
           case .link: return .blue
           case .image: return .green // Or nil
           default: return nil
           }
       }
}

// MARK: - Preview
struct LiveMarkdownPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMarkdownPreviewView()
            .frame(width: 800, height: 600)
            .previewDisplayName("Live Markdown Preview")
    }
} 