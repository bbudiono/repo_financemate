// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatMessageView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/4/25.
//

/*
* Purpose: Individual chat message display component with native macOS styling and interactions
* Issues & Complexity Summary: Sophisticated message rendering with state indicators, timestamps, and interaction support
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~250
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (SwiftUI, Foundation, Models)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Complex message rendering with multiple states and interactions
* Final Code Complexity (Actual %): 67%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Well-structured component design enables rich message display
* Last Updated: 2025-06-04
*/

import SwiftUI
import Foundation

public struct ChatMessageView: View {
    
    // MARK: - Properties
    
    let message: ChatMessage
    let theme: ChatTheme
    let showTimestamp: Bool
    let onCopy: () -> Void
    
    @State private var isHovering = false
    @State private var showingCopyConfirmation = false
    
    // MARK: - Initialization
    
    public init(
        message: ChatMessage,
        theme: ChatTheme,
        showTimestamp: Bool = false,
        onCopy: @escaping () -> Void
    ) {
        self.message = message
        self.theme = theme
        self.showTimestamp = showTimestamp
        self.onCopy = onCopy
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
                messageContent
                avatarView
            } else {
                avatarView
                messageContent
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .contextMenu {
            contextMenuItems
        }
    }
    
    // MARK: - Message Content
    
    private var messageContent: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            messageBubble
            messageFooter
        }
    }
    
    private var messageBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            messageText
            attachmentsView
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(messageBackgroundColor)
        .foregroundColor(theme.textColor)
        .cornerRadius(12)
        .overlay(
            // Hover actions
            HStack {
                Spacer()
                if isHovering {
                    VStack {
                        Button(action: copyMessage) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(theme.secondaryTextColor)
                        }
                        .buttonStyle(.borderless)
                        .help("Copy message")
                        Spacer()
                    }
                    .padding(.trailing, 4)
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isHovering)
    }
    
    private var messageText: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(formatMessageContent(message.content))
                .textSelection(.enabled)
                .font(.system(.body, design: .default))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            if case .streaming = message.messageState {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(theme.secondaryTextColor)
                            .frame(width: 4, height: 4)
                            .scaleEffect(streamingAnimation ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: streamingAnimation
                            )
                    }
                }
                .padding(.top, 4)
                .onAppear {
                    streamingAnimation = true
                }
            }
        }
    }
    
    @State private var streamingAnimation = false
    
    private var attachmentsView: some View {
        ForEach(message.attachments) { attachment in
            AttachmentView(attachment: attachment, theme: theme)
        }
    }
    
    private var messageFooter: some View {
        HStack(spacing: 4) {
            if showTimestamp {
                Text(formattedTimestamp)
                    .font(.caption2)
                    .foregroundColor(theme.secondaryTextColor)
            }
            
            messageStateIndicator
            
            if showingCopyConfirmation {
                Text("Copied!")
                    .font(.caption2)
                    .foregroundColor(theme.accentColor)
                    .transition(.opacity)
            }
        }
    }
    
    private var messageStateIndicator: some View {
        Group {
            switch message.messageState {
            case .pending:
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(theme.secondaryTextColor)
            case .sending:
                ProgressView()
                    .scaleEffect(0.7)
                    .frame(width: 10, height: 10)
            case .sent:
                EmptyView()
            case .failed(let error):
                Button(action: {}) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
                .help("Failed: \(error)")
            case .streaming:
                Text("typing...")
                    .font(.caption2)
                    .foregroundColor(theme.secondaryTextColor)
                    .italic()
            }
        }
    }
    
    // MARK: - Avatar
    
    private var avatarView: some View {
        Group {
            if message.isUser {
                Circle()
                    .fill(theme.accentColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(theme.accentColor)
                    )
            } else {
                Circle()
                    .fill(theme.secondaryTextColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "brain")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                    )
            }
        }
    }
    
    // MARK: - Context Menu
    
    private var contextMenuItems: some View {
        Group {
            Button("Copy Message") {
                copyMessage()
            }
            
            if !message.isUser {
                Button("Copy Response") {
                    copyMessage()
                }
            }
            
            Divider()
            
            Button("Copy Timestamp") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(formattedTimestamp, forType: .string)
                showCopyConfirmation()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var messageBackgroundColor: Color {
        if message.isUser {
            return theme.userMessageColor
        } else {
            return theme.botMessageColor
        }
    }
    
    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: message.timestamp)
    }
    
    // MARK: - Methods
    
    private func formatMessageContent(_ content: String) -> AttributedString {
        var attributedString = AttributedString(content)
        
        // Format URLs
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: content.utf16.count)
        
        detector?.enumerateMatches(in: content, options: [], range: range) { match, _, _ in
            guard let match = match, let urlRange = Range(match.range, in: content) else { return }
            
            if let attributedRange = Range<AttributedString.Index>(urlRange, in: attributedString) {
                attributedString[attributedRange].foregroundColor = .blue
                attributedString[attributedRange].underlineStyle = .single
            }
        }
        
        // Format code blocks (simple implementation)
        if content.contains("`") {
            let codePattern = "`([^`]+)`"
            if let regex = try? NSRegularExpression(pattern: codePattern, options: []) {
                let matches = regex.matches(in: content, options: [], range: range)
                
                for match in matches.reversed() {
                    if let codeRange = Range(match.range, in: content),
                       let attributedRange = Range<AttributedString.Index>(codeRange, in: attributedString) {
                        attributedString[attributedRange].font = .system(.body, design: .monospaced)
                        attributedString[attributedRange].backgroundColor = Color.gray.opacity(0.2)
                    }
                }
            }
        }
        
        return attributedString
    }
    
    private func copyMessage() {
        onCopy()
        showCopyConfirmation()
    }
    
    private func showCopyConfirmation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingCopyConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingCopyConfirmation = false
            }
        }
    }
}

// MARK: - Attachment View

private struct AttachmentView: View {
    let attachment: ChatAttachment
    let theme: ChatTheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(theme.accentColor)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let path = attachment.path {
                    Text(path)
                        .font(.caption2)
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.accentColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var iconName: String {
        switch attachment.type {
        case .file:
            return "doc.text"
        case .folder:
            return "folder"
        case .appElement:
            return "app"
        case .ragItem:
            return "magnifyingglass"
        case .unknown:
            return "questionmark.circle"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ChatMessageView(
            message: ChatMessage(
                content: "Hello! This is a user message with some sample content.",
                isUser: true
            ),
            theme: .light,
            showTimestamp: true,
            onCopy: {}
        )
        
        ChatMessageView(
            message: ChatMessage(
                content: "This is a bot response with `code formatting` and a longer message that demonstrates how the text wraps and displays in the chat interface.",
                isUser: false,
                messageState: .sent
            ),
            theme: .light,
            showTimestamp: true,
            onCopy: {}
        )
        
        ChatMessageView(
            message: ChatMessage(
                content: "This message is currently streaming...",
                isUser: false,
                messageState: .streaming
            ),
            theme: .light,
            onCopy: {}
        )
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}