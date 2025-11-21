import SwiftUI

struct ChatInputField: View {
    @Binding var messageText: String
    @FocusState.Binding var isInputFocused: Bool
    let isProcessing: Bool
    // BLUEPRINT Line 135: Context-aware placeholder text
    var placeholder: String = "Ask about your finances..."
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField(placeholder, text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                    .focused($isInputFocused)
                    .lineLimit(1...4)
                    .onSubmit(sendMessage)
                    .disabled(isProcessing)

                Button(action: sendMessage) {
                    Image(systemName: messageText.isEmpty ? "mic.circle.fill" : "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .secondary : .blue)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isProcessing || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel(messageText.isEmpty ? "Voice input" : "Send message")
            }

            quickActionsView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Quick Actions

    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                QuickActionButton(title: "Expenses", icon: "chart.bar") {
                    messageText = "Show me my recent expenses"
                    sendMessage()
                }

                QuickActionButton(title: "Budget", icon: "dollarsign.circle") {
                    messageText = "How am I tracking against my budget?"
                    sendMessage()
                }

                QuickActionButton(title: "Goals", icon: "target") {
                    messageText = "Show me my financial goal progress"
                    sendMessage()
                }

                QuickActionButton(title: "Report", icon: "doc.text") {
                    messageText = "Generate a monthly expense report"
                    sendMessage()
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSend()
    }
}
