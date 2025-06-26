import SwiftUI

struct CoPilotIntegrationView: View {
    @StateObject private var chatService = RealLLMAPIService()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isExpanded = true
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if isExpanded {
                contentView
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .alert("Co-Pilot Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title3)
                .foregroundColor(.blue)

            Text("🤖 Co-Pilot Assistant")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(chatService.isConnected ? .green : .red)
                    .frame(width: 8, height: 8)

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 12, height: 12)
                }
            }

            Button(action: {
                isExpanded.toggle()
            }) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Divider()

            messagesView
                .frame(maxHeight: 300)

            Divider()

            inputView
        }
    }

    private var messagesView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if messages.isEmpty {
                    emptyStateView
                } else {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "message")
                .font(.largeTitle)
                .foregroundColor(.secondary)

            Text("Welcome to Co-Pilot")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("I can help you with financial analysis, document processing, and application navigation.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var inputView: some View {
        HStack(spacing: 8) {
            TextField("Ask Co-Pilot anything...", text: $messageText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    sendMessage()
                }

            Button("Send") {
                sendMessage()
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding()
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isLoading else { return }

        let userMessage = ChatMessage(
            content: messageText,
            isUser: true,
            timestamp: Date()
        )

        messages.append(userMessage)
        let currentMessage = messageText
        messageText = ""
        isLoading = true

        Task {
            let response = await chatService.sendMessage(currentMessage)

            await MainActor.run {
                isLoading = false

                // Check for error responses
                if response.contains("❌") {
                    errorMessage = response
                    showingError = true
                }

                let assistantMessage = ChatMessage(
                    content: response,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(assistantMessage)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.blue : Color(NSColor.controlBackgroundColor))
                    )
                    .foregroundColor(message.isUser ? .white : .primary)

                Text(DateFormatter.shortTime.string(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser {
                Spacer()
            }
        }
    }
}

extension DateFormatter {
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    CoPilotIntegrationView()
        .frame(width: 400, height: 500)
}
