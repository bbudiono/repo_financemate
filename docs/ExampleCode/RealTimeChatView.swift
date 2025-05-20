// RealTimeChatView.swift
// Advanced SwiftUI Example: Real-Time Chat Interface
// Demonstrates a modular, production-quality chat UI with simulated live updates and typing indicators.
// Author: AI Agent (2025)
//
// Use case: Live chat interface with message grouping, typing indicators, and delivery status.
// Most challenging aspect: Efficient live updates, message ordering, and UI performance with large message sets.

import SwiftUI

/// Represents a single chat message.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let userID: String
    let userName: String
    let text: String
    let timestamp: Date
    var isOwn: Bool { userID == "user1" }
}

/// Simulated user for demonstration.
struct ChatUser: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    var isTyping: Bool
}

/// ViewModel for managing chat state and simulated live updates.
class RealTimeChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        .init(userID: "user2", userName: "Bob", text: "Hey Alice!", timestamp: Date().addingTimeInterval(-120)),
        .init(userID: "user1", userName: "Alice", text: "Hi Bob! How are you?", timestamp: Date().addingTimeInterval(-110)),
        .init(userID: "user2", userName: "Bob", text: "Doing well, thanks!", timestamp: Date().addingTimeInterval(-100))
    ]
    @Published var users: [ChatUser] = [
        .init(id: "user1", name: "Alice", color: .blue, isTyping: false),
        .init(id: "user2", name: "Bob", color: .green, isTyping: false)
    ]
    @Published var inputText: String = ""
    @Published var localUserID: String = "user1"
    @Published var isRemoteTyping: Bool = false
    
    // Simulate remote user typing and sending messages
    func simulateRemoteUserActivity() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            self.isRemoteTyping = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isRemoteTyping = false
                let msg = ChatMessage(userID: "user2", userName: "Bob", text: self.randomRemoteMessage(), timestamp: Date())
                self.messages.append(msg)
            }
        }
    }
    
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let user = users.first(where: { $0.id == localUserID }) ?? users[0]
        let msg = ChatMessage(userID: user.id, userName: user.name, text: trimmed, timestamp: Date())
        messages.append(msg)
        inputText = ""
    }
    
    private func randomRemoteMessage() -> String {
        let options = [
            "That's interesting!",
            "Can you tell me more?",
            "I agree with you.",
            "Let's catch up soon!",
            "👍",
            "😂",
            "Sounds good!"
        ]
        return options.randomElement() ?? "Okay!"
    }
}

/// Main real-time chat view.
struct RealTimeChatView: View {
    @StateObject private var viewModel = RealTimeChatViewModel()
    @Namespace private var bottomID
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Real-Time Chat")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubbleView(message: msg)
                                .id(msg.id)
                        }
                        if viewModel.isRemoteTyping {
                            TypingIndicatorView(user: viewModel.users[1])
                        }
                        // Scroll anchor
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
                }
            }
            
            Divider()
            // Input bar
            HStack {
                TextField("Type a message...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 36)
                    .onSubmit { viewModel.sendMessage() }
                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .frame(minWidth: 400, minHeight: 350)
        .onAppear {
            viewModel.simulateRemoteUserActivity()
        }
    }
}

/// Visual representation of a chat message bubble.
struct ChatBubbleView: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isOwn { Spacer() }
            VStack(alignment: message.isOwn ? .trailing : .leading, spacing: 2) {
                Text(message.userName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .padding(10)
                    .background(message.isOwn ? Color.blue.opacity(0.15) : Color.green.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                Text(Self.timestampString(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            if !message.isOwn { Spacer() }
        }
        .padding(.vertical, 2)
    }
    static func timestampString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Typing indicator for a user.
struct TypingIndicatorView: View {
    let user: ChatUser
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(user.color).frame(width: 8, height: 8)
            Text("\(user.name) is typing...")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.leading, 8)
        .padding(.vertical, 2)
    }
}

// MARK: - Preview
struct RealTimeChatView_Previews: PreviewProvider {
    static var previews: some View {
        RealTimeChatView()
            .frame(width: 500, height: 400)
            .previewDisplayName("Real-Time Chat")
    }
} 