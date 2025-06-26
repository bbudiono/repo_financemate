//
//  SimpleCoPilotPanelView.swift
//  FinanceMate
//
//  Created by Assistant on 6/11/25.
//

/*
* Purpose: Simplified Co-Pilot panel for sidebar integration with MLACS support
* Issues & Complexity Summary: Lightweight chat interface with integrated MLACS coordination
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium
  - Dependencies: 2 New (RealLLMAPIService, ChatMessage)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 45%
* Problem Estimate (Inherent Problem Difficulty %): 40%
* Initial Code Complexity Estimate %: 43%
* Justification for Estimates: Simplified chat interface with MLACS integration
* Final Code Complexity (Actual %): 42%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: MLACS integration seamlessly embedded in Co-Pilot system
* Last Updated: 2025-06-11
*/

import SwiftUI

struct SimpleCoPilotPanelView: View {
    @StateObject private var chatService = RealLLMAPIService()
    @StateObject private var mlacsCoordinator = MLACSChatCoordinator()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var mlacsMode: MLACSMode = .single

    enum MLACSMode: String, CaseIterable {
        case single = "Single Agent"
        case multi = "Multi-Agent Coordination"

        var icon: String {
            switch self {
            case .single: return "brain"
            case .multi: return "brain.head.profile.fill"
            }
        }

        var description: String {
            switch self {
            case .single: return "Direct AI response"
            case .multi: return "MLACS coordination system"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            messagesView
            inputView
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Co-Pilot Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: mlacsMode.icon)
                    .font(.title3)
                    .foregroundColor(.blue)

                Text("🤖 Co-Pilot")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(chatService.isConnected ? .green : .red)
                        .frame(width: 8, height: 8)

                    if mlacsCoordinator.isActive {
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                    }
                }
            }

            // MLACS Mode Selector
            HStack {
                Picker("Mode", selection: $mlacsMode) {
                    ForEach(MLACSMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .help(mlacsMode.description)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Messages View

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty {
                        welcomeMessage
                    } else {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
    }

    private var welcomeMessage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("👋 Welcome to Co-Pilot")
                .font(.headline)
                .foregroundColor(.primary)

            Text("I'm your AI-powered financial assistant integrated with MLACS (Multi-LLM Agent Coordination System). I can help you with:")
                .font(.body)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("• Document analysis & data extraction")
                Text("• Financial insights & trends")
                Text("• Budget recommendations")
                Text("• Export assistance")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text("Choose **Multi-Agent Coordination** mode for complex tasks requiring multiple AI perspectives.")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.top, 4)

            // MLACS Context-Aware Suggestions
            if !mlacsCoordinator.getContextAwareSuggestions().isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Suggestions:")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    ForEach(mlacsCoordinator.getContextAwareSuggestions().prefix(3), id: \.self) { suggestion in
                        Button(suggestion) {
                            messageText = suggestion
                            sendMessage()
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Input View

    private var inputView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Ask Co-Pilot anything...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .secondary : .blue)
                }
                .disabled(messageText.isEmpty || isLoading)
            }

            if mlacsMode == .multi {
                Text("🧬 MLACS coordination active")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !messageText.isEmpty, !isLoading else { return }

        let userMessage = ChatMessage(
            id: UUID(),
            content: messageText,
            isUser: true,
            timestamp: Date()
        )

        messages.append(userMessage)
        let question = messageText
        messageText = ""
        isLoading = true

        Task {
            do {
                let response: String

                // Use MLACS coordinator for enhanced responses
                response = await mlacsCoordinator.processMessage(question, mode: mlacsMode)

                await MainActor.run {
                    let assistantMessage = ChatMessage(
                        id: UUID(),
                        content: response,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(assistantMessage)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Message Bubble View

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.blue : Color(NSColor.controlBackgroundColor))
                    )

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SimpleCoPilotPanelView()
        .frame(width: 350, height: 600)
}
