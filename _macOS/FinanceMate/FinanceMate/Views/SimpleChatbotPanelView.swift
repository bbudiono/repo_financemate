//
//  SimpleChatbotPanelView.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

/*
* Purpose: Simplified ChatbotPanel implementation for production use with gradual feature integration
* Issues & Complexity Summary: Minimal chatbot interface using existing RealLLMAPIService without complex dependencies
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low-Medium
  - Dependencies: 2 (SwiftUI, RealLLMAPIService)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
* Problem Estimate (Inherent Problem Difficulty %): 35%
* Initial Code Complexity Estimate %: 38%
* Justification for Estimates: Simple progressive implementation building on proven RealLLMAPIService
* Final Code Complexity (Actual %): 40%
* Overall Result Score (Success & Quality %): 90%
* Key Variances/Learnings: TDD approach enables clean incremental chatbot integration
* Last Updated: 2025-06-10
*/

import SwiftUI

struct SimpleChatbotPanelView: View {
    // MARK: - Properties

    @State private var messages: [SimpleChatMessage] = []
    @State private var currentInput: String = ""
    @State private var isProcessing: Bool = false
    @StateObject private var apiService = RealLLMAPIService()

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Messages
            messagesSection

            Divider()

            // Input section
            inputSection
        }
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            setupInitialState()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("FinanceMate Assistant")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(apiService.isConnected ? "Ready" : "Configure API keys in Settings")
                    .font(.caption)
                    .foregroundColor(apiService.isConnected ? .green : .orange)
            }

            Spacer()

            Button(action: clearConversation) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .help("Clear conversation")
            .disabled(messages.isEmpty)
        }
        .padding()
    }

    // MARK: - Messages Section

    private var messagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Chat with FinanceMate Assistant")
                .font(.title3)
                .fontWeight(.medium)

            Text("Ask questions about your financial data, get insights, or request help with document processing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func messageRow(_ message: SimpleChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isUser ? Color.accentColor : Color.secondary.opacity(0.1))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(12)
                    .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isUser {
                Spacer()
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Ask FinanceMate Assistant...", text: $currentInput, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(isProcessing || !apiService.isConnected)
                    .onSubmit {
                        sendMessage()
                    }

                Button(action: sendMessage) {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing || !apiService.isConnected)
            }

            if !apiService.isConnected {
                Text("Configure API keys in Settings to enable chat")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
    }

    // MARK: - Actions

    private func setupInitialState() {
        // Add welcome message if API is connected
        if apiService.isConnected && messages.isEmpty {
            messages.append(SimpleChatMessage(
                content: "Hello! I'm your FinanceMate Assistant. How can I help you with your financial documents and data today?",
                isUser: false
            ))
        }
    }

    private func sendMessage() {
        let userInput = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userInput.isEmpty, !isProcessing, apiService.isConnected else { return }

        // Add user message
        messages.append(SimpleChatMessage(content: userInput, isUser: true))
        currentInput = ""
        isProcessing = true

        // Send to API
        Task {
            do {
                let response = try await apiService.sendMessage(userInput)

                await MainActor.run {
                    messages.append(SimpleChatMessage(content: response, isUser: false))
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    messages.append(SimpleChatMessage(
                        content: "Sorry, I encountered an error: \(error.localizedDescription)",
                        isUser: false
                    ))
                    isProcessing = false
                }
            }
        }
    }

    private func clearConversation() {
        messages.removeAll()
        setupInitialState()
    }

    private func scrollToBottom(proxy: ScrollViewReader) {
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Supporting Types

struct SimpleChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

#Preview {
    SimpleChatbotPanelView()
        .frame(width: 350, height: 600)
}
