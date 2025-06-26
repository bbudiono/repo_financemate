import Combine
import SwiftUI

struct EnhancedCoPilotView: View {
    @StateObject private var frontierService = FrontierModelsService()
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isExpanded = true
    @State private var showingModelSelector = false
    @State private var cancellables = Set<AnyCancellable>()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header with Model Selection
            headerView

            if isExpanded {
                Divider()

                // Model Selector (when shown)
                if showingModelSelector {
                    ModelSelectorView(frontierService: frontierService)
                        .frame(height: 300)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    Divider()
                }

                // Messages Area
                messagesView

                Divider()

                // Input Area
                inputView
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityEnhanced(
            label: "FinanceMate Co-Pilot Assistant",
            hint: "AI-powered financial assistant with frontier model selection",
            identifier: "copilot-main-panel"
        )
        .onAppear {
            setupMessageListener()
            addWelcomeMessage()
            announceInitialState()
        }
        .onChange(of: frontierService.selectedModel) { _ in
            announceModelChange()
        }
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 12) {
            // Co-Pilot Icon
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("🤖 Co-Pilot Assistant")
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    // Connection Status
                    Circle()
                        .fill(frontierService.isConnected ? .green : .red)
                        .frame(width: 6, height: 6)

                    Text(frontierService.isConnected ? "Connected" : "Disconnected")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    // Current Model
                    Text(frontierService.selectedModel.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            // Model Selector Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingModelSelector.toggle()
                }
                accessibilityManager.announceForAccessibility(
                    showingModelSelector ? "Model selector opened" : "Model selector closed"
                )
            }) {
                Image(systemName: showingModelSelector ? "brain.filled.head.profile" : "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(showingModelSelector ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityEnhanced(
                label: "Select AI Model",
                hint: "Opens model selection interface to choose between frontier AI models",
                traits: .isButton,
                identifier: "model-selector-button"
            )
            .accessibilityKeyboardShortcut("m", modifiers: .command)

            // Expand/Collapse Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
                accessibilityManager.announceForAccessibility(
                    isExpanded ? "Co-Pilot expanded" : "Co-Pilot collapsed"
                )
            }) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityEnhanced(
                label: isExpanded ? "Collapse Co-Pilot" : "Expand Co-Pilot",
                hint: "Toggles the Co-Pilot assistant interface visibility",
                traits: .isButton,
                identifier: "copilot-toggle-button"
            )
            .accessibilityKeyboardShortcut("e", modifiers: .command)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - Messages View
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if messages.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(messages, id: \.id) { message in
                            MessageBubbleView(message: message, selectedModel: frontierService.selectedModel)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .frame(minHeight: 200, maxHeight: 400)
    }

    // MARK: - Input View
    private var inputView: some View {
        VStack(spacing: 12) {
            // Quick Actions
            if messages.isEmpty || messages.count <= 2 {
                quickActionsView
            }

            // Text Input
            HStack(spacing: 12) {
                TextField("Ask your financial AI assistant...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .focused($isInputFocused)
                    .onSubmit {
                        Task {
                            await sendMessage()
                        }
                    }
                    .accessibilityEnhanced(
                        label: "Message input field",
                        hint: "Type your question or request for the AI assistant. Press Return to send.",
                        identifier: "copilot-message-input"
                    )
                    .accessibilityAction(named: "Send message") {
                        Task {
                            await sendMessage()
                        }
                    }

                Button(action: {
                    Task {
                        if frontierService.isLoading {
                            // Cancel operation
                            accessibilityManager.announceForAccessibility("Message cancelled")
                        } else {
                            await sendMessage()
                        }
                    }
                }) {
                    Image(systemName: frontierService.isLoading ? "stop.circle" : "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
                }
                .buttonStyle(.plain)
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !frontierService.isLoading)
                .accessibilityEnhanced(
                    label: frontierService.isLoading ? "Cancel message" : "Send message",
                    hint: frontierService.isLoading ? "Stops the current AI response" : "Sends your message to the AI assistant",
                    traits: .isButton,
                    identifier: "copilot-send-button"
                )
                .accessibilityKeyboardShortcut(.return, modifiers: .command)
            }

            // Loading indicator
            if frontierService.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)

                    Text("Thinking with \(frontierService.selectedModel.displayName)...")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Quick Actions
    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(getQuickActions(), id: \.title) { action in
                    QuickActionButton(action: action) {
                        messageText = action.prompt
                        Task {
                            await sendMessage()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: frontierService.selectedModel.icon)
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.6))

            VStack(spacing: 8) {
                Text("Welcome to FinanceMate Co-Pilot")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Powered by \(frontierService.selectedModel.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Ask me anything about your finances, documents, or subscriptions!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper Methods

    private func setupMessageListener() {
        frontierService.chatbotResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // The response is already handled in the sendMessage method
            }
            .store(in: &cancellables)
    }

    // MARK: - Accessibility Methods

    private func announceInitialState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            accessibilityManager.announceForAccessibility(
                "FinanceMate Co-Pilot ready. Current model: \(frontierService.selectedModel.displayName). Use Command+M to change models, Command+E to toggle panel."
            )
        }
    }

    private func announceModelChange() {
        accessibilityManager.announceForAccessibility(
            "AI model changed to \(frontierService.selectedModel.displayName)"
        )
    }

    private func announceNewMessage(isUser: Bool, content: String) {
        let prefix = isUser ? "You said" : "Assistant replied"
        let message = "\(prefix): \(content)"
        accessibilityManager.announceForAccessibility(message)
    }

    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            text: "Hello! I'm your FinanceMate Co-Pilot powered by \(frontierService.selectedModel.displayName). I'm here to help you with financial analysis, document processing, subscription management, and more. How can I assist you today?",
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(welcomeMessage)
    }

    private func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            text: text,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)

        // Clear input
        messageText = ""

        // Get AI response
        let response = await frontierService.sendMessage(text)

        // Add AI response
        let aiMessage = ChatMessage(
            text: response,
            isFromUser: false,
            timestamp: Date()
        )
        messages.append(aiMessage)
    }

    private func getQuickActions() -> [QuickAction] {
        [
            QuickAction(
                title: "💰 Analyze Expenses",
                icon: "chart.line.uptrend.xyaxis",
                prompt: "Help me analyze my current expenses and identify areas where I can save money."
            ),
            QuickAction(
                title: "📊 Subscription Review",
                icon: "repeat.circle",
                prompt: "Review my subscriptions and suggest optimizations to reduce costs."
            ),
            QuickAction(
                title: "📄 Process Document",
                icon: "doc.text.magnifyingglass",
                prompt: "I have a financial document I'd like you to analyze and extract key information from."
            ),
            QuickAction(
                title: "💡 Financial Tips",
                icon: "lightbulb",
                prompt: "Give me 3 actionable financial tips based on current market conditions."
            ),
            QuickAction(
                title: "🎯 Budget Planning",
                icon: "target",
                prompt: "Help me create a monthly budget plan based on my income and expenses."
            )
        ]
    }
}

// MARK: - Supporting Views

struct MessageBubbleView: View {
    let message: ChatMessage
    let selectedModel: FrontierModel
    @StateObject private var accessibilityManager = AccessibilityManager.shared

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if !message.isFromUser {
                        Image(systemName: selectedModel.icon)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)

                        Text(selectedModel.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                    }

                    Spacer()

                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }

                Text(message.text)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(message.isFromUser ? Color.blue : Color(NSColor.controlBackgroundColor))
                    )
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .accessibilityEnhanced(
                        label: accessibilityMessageLabel,
                        hint: accessibilityMessageHint,
                        value: message.text,
                        traits: [.isStaticText],
                        identifier: "message-\(message.id)"
                    )
                    .accessibilityAction(named: "Copy message") {
                        copyMessageToPasteboard()
                    }
            }
            .frame(maxWidth: 250, alignment: message.isFromUser ? .trailing : .leading)

            if !message.isFromUser {
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityEnhanced(
            label: fullAccessibilityLabel,
            value: message.text,
            traits: [.isStaticText],
            identifier: "message-bubble-\(message.id)"
        )
    }

    // MARK: - Accessibility Helpers

    private var accessibilityMessageLabel: String {
        let sender = message.isFromUser ? "You" : selectedModel.displayName
        let timeString = DateFormatter.timeFormatter.string(from: message.timestamp)
        return "\(sender) at \(timeString)"
    }

    private var accessibilityMessageHint: String {
        message.isFromUser ?
            "Your message sent to the AI assistant" :
            "Response from \(selectedModel.displayName) AI assistant"
    }

    private var fullAccessibilityLabel: String {
        let sender = message.isFromUser ? "You" : selectedModel.displayName
        let timeString = DateFormatter.timeFormatter.string(from: message.timestamp)
        return "\(sender) said at \(timeString): \(message.text)"
    }

    private func copyMessageToPasteboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.text, forType: .string)
        accessibilityManager.announceForAccessibility("Message copied to clipboard")
    }
}

struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    @StateObject private var accessibilityManager = AccessibilityManager.shared

    var body: some View {
        Button(action: {
            onTap()
            accessibilityManager.announceForAccessibility("Quick action: \(action.title) selected")
        }) {
            HStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.caption)
                    .accessibilityHidden(true)

                Text(action.title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.1))
            )
            .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
        .accessibilityEnhanced(
            label: action.title,
            hint: "Quick action button. Activates: \(action.prompt)",
            traits: .isButton,
            identifier: "quick-action-\(action.title.lowercased().replacingOccurrences(of: " ", with: "-"))"
        )
    }
}

// MARK: - Supporting Types

struct QuickAction {
    let title: String
    let icon: String
    let prompt: String
}

// MARK: - Extensions

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    EnhancedCoPilotView()
        .frame(width: 350, height: 600)
}
