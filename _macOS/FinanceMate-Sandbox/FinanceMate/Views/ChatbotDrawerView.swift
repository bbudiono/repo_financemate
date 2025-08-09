// SANDBOX FILE: For testing/development. See .cursorrules.

import CoreData
import SwiftUI

/*
 * Purpose: AI-powered chatbot drawer UI - Right-hand side persistent interface as per BLUEPRINT
 * Issues & Complexity Summary: Complex SwiftUI layout, glassmorphism design, real-time chat interface
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400
   - Core Algorithm Complexity: Medium-High (UI animations, state management)
   - Dependencies: SwiftUI, ChatbotViewModel, glassmorphism components
   - State Management Complexity: High (drawer state, chat state, animations)
   - Novelty/Uncertainty Factor: Medium (drawer UI patterns, chat interface)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 88%
 * Initial Code Complexity Estimate: 87%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-08-08
 */

struct ChatbotDrawerView: View {
  @StateObject private var chatbotViewModel: ChatbotViewModel
  @Environment(\.managedObjectContext) private var viewContext
  @State private var messageText = ""
  @State private var isExpanded = false
  @FocusState private var isInputFocused: Bool

  // Animation properties
  @State private var dragOffset: CGSize = .zero
  @State private var isDragging = false

  // Constants
  private let drawerWidth: CGFloat = 350
  private let collapsedWidth: CGFloat = 60
  private let cornerRadius: CGFloat = 20

  init(context: NSManagedObjectContext) {
    self._chatbotViewModel = StateObject(wrappedValue: ChatbotViewModel(context: context))
  }

  var body: some View {
    HStack(spacing: 0) {
      Spacer()

      // Chatbot Drawer
      VStack(spacing: 0) {
        drawerContent
      }
      .frame(width: chatbotViewModel.isDrawerVisible ? drawerWidth : collapsedWidth)
      .background(glassmorphismBackground)
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .shadow(color: .black.opacity(0.1), radius: 10, x: -2, y: 0)
      .offset(x: dragOffset.width)
      .gesture(dragGesture)
      .animation(
        .spring(response: 0.6, dampingFraction: 0.8), value: chatbotViewModel.isDrawerVisible
      )
      .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
    .accessibilityIdentifier("ChatbotDrawer")
  }

  // MARK: - Drawer Content

  @ViewBuilder
  private var drawerContent: some View {
    if chatbotViewModel.isDrawerVisible {
      expandedDrawerContent
    } else {
      collapsedDrawerContent
    }
  }

  private var expandedDrawerContent: some View {
    VStack(spacing: 0) {
      // Header
      drawerHeader

      Divider()
        .opacity(0.3)

      // Messages
      messagesScrollView

      Divider()
        .opacity(0.3)

      // Input Area
      messageInputArea
    }
  }

  private var collapsedDrawerContent: some View {
    VStack {
      Button(action: {
        withAnimation(.spring()) {
          chatbotViewModel.toggleDrawer()
        }
      }) {
        Image(systemName: "message.circle.fill")
          .font(.title2)
          .foregroundColor(.blue)
          .frame(width: 40, height: 40)
          .background(Circle().fill(.ultraThinMaterial))
      }
      .buttonStyle(PlainButtonStyle())
      .accessibilityLabel("Open AI Assistant")

      Spacer()

      // Processing indicator when collapsed
      if chatbotViewModel.isProcessing {
        ProgressView()
          .scaleEffect(0.8)
          .progressViewStyle(CircularProgressViewStyle(tint: .blue))
      }
    }
    .padding(.vertical, 20)
  }

  // MARK: - Header

  private var drawerHeader: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("AI Assistant")
          .font(.headline)
          .fontWeight(.semibold)

        Text(chatbotViewModel.isProcessing ? "Thinking..." : "Ready to help")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      HStack(spacing: 12) {
        // Clear conversation
        Button(action: {
          withAnimation {
            chatbotViewModel.clearConversation()
          }
        }) {
          Image(systemName: "trash.circle")
            .font(.title3)
            .foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Clear conversation")

        // Minimize button
        Button(action: {
          withAnimation(.spring()) {
            chatbotViewModel.toggleDrawer()
          }
        }) {
          Image(systemName: "chevron.right.circle")
            .font(.title3)
            .foregroundColor(.secondary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Minimize assistant")
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

  // MARK: - Messages

  private var messagesScrollView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(chatbotViewModel.messages) { message in
            MessageBubbleView(message: message)
              .id(message.id)
          }

          // Typing indicator
          if chatbotViewModel.isProcessing {
            TypingIndicatorView()
              .id("typing")
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
      }
      .onChange(of: chatbotViewModel.messages.count) { _ in
        withAnimation(.easeOut(duration: 0.3)) {
          if let lastMessage = chatbotViewModel.messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
          }
        }
      }
      .onChange(of: chatbotViewModel.isProcessing) { isProcessing in
        if isProcessing {
          withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo("typing", anchor: .bottom)
          }
        }
      }
    }
    .frame(maxHeight: .infinity)
  }

  // MARK: - Input Area

  private var messageInputArea: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        TextField("Ask about your finances...", text: $messageText, axis: .vertical)
          .textFieldStyle(.plain)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
          .focused($isInputFocused)
          .lineLimit(1...4)
          .onSubmit {
            sendMessage()
          }
          .disabled(chatbotViewModel.isProcessing)

        Button(action: sendMessage) {
          Image(systemName: messageText.isEmpty ? "mic.circle.fill" : "arrow.up.circle.fill")
            .font(.title2)
            .foregroundColor(messageText.isEmpty ? .secondary : .blue)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(chatbotViewModel.isProcessing || (messageText.isEmpty && true))  // Voice input placeholder
        .accessibilityLabel(messageText.isEmpty ? "Voice input" : "Send message")
      }

      // Quick actions
      quickActionsView
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }

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

  // MARK: - Background

  private var glassmorphismBackground: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(.ultraThinMaterial)
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(
            LinearGradient(
              colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(.white.opacity(0.2), lineWidth: 1)
      )
  }

  // MARK: - Drag Gesture

  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        isDragging = true
        dragOffset = value.translation
      }
      .onEnded { value in
        isDragging = false

        withAnimation(.spring()) {
          // Snap back to position
          dragOffset = .zero

          // Toggle drawer if dragged far enough
          if abs(value.translation.x) > 100 {
            if value.translation.x > 0 && chatbotViewModel.isDrawerVisible {
              chatbotViewModel.toggleDrawer()
            } else if value.translation.x < 0 && !chatbotViewModel.isDrawerVisible {
              chatbotViewModel.toggleDrawer()
            }
          }
        }
      }
  }

  // MARK: - Actions

  private func sendMessage() {
    guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

    Task {
      await chatbotViewModel.sendMessage(messageText)
      await MainActor.run {
        messageText = ""
        isInputFocused = false
      }
    }
  }
}

// MARK: - Supporting Views

struct MessageBubbleView: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer()
      }

      VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
        Text(message.content)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(message.role == .user ? .blue : .gray.opacity(0.1))
          )
          .foregroundColor(message.role == .user ? .white : .primary)

        Text(message.timestamp, style: .time)
          .font(.caption2)
          .foregroundColor(.secondary)
      }

      if message.role == .assistant {
        Spacer()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(message.role == .user ? "You" : "Assistant") said: \(message.content)")
  }
}

struct TypingIndicatorView: View {
  @State private var animationPhase = 0

  var body: some View {
    HStack {
      HStack(spacing: 4) {
        ForEach(0..<3) { index in
          Circle()
            .fill(.secondary)
            .frame(width: 6, height: 6)
            .scaleEffect(animationPhase == index ? 1.2 : 0.8)
            .animation(
              .easeInOut(duration: 0.6).repeatForever().delay(Double(index) * 0.2),
              value: animationPhase
            )
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(RoundedRectangle(cornerRadius: 16).fill(.gray.opacity(0.1)))

      Spacer()
    }
    .onAppear {
      animationPhase = 0
    }
    .accessibilityLabel("Assistant is typing")
  }
}

struct QuickActionButton: View {
  let title: String
  let icon: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        Image(systemName: icon)
          .font(.caption)
        Text(title)
          .font(.caption)
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel(title)
  }
}

// MARK: - Preview

struct ChatbotDrawerView_Previews: PreviewProvider {
  static var previews: some View {
    ChatbotDrawerView(context: PersistenceController.preview.container.viewContext)
      .frame(width: 800, height: 600)
  }
}




