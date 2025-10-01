import SwiftUI
import CoreData

struct ChatbotDrawer: View {
    @ObservedObject var viewModel: ChatbotViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    @State private var dragOffset: CGSize = .zero

    private let drawerWidth: CGFloat = 350
    private let collapsedWidth: CGFloat = 60
    private let cornerRadius: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                if viewModel.isDrawerVisible {
                    expandedContent
                } else {
                    collapsedContent
                }
            }
            .frame(width: viewModel.isDrawerVisible ? drawerWidth : collapsedWidth)
            .background(GlassmorphismBackground(cornerRadius: cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: 10, x: -2, y: 0)
            .offset(x: dragOffset.width)
            .gesture(dragGesture)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.isDrawerVisible)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
        }
        .accessibilityIdentifier("ChatbotDrawer")
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(spacing: 0) {
            drawerHeader
            Divider().opacity(0.3)
            messagesScrollView
            Divider().opacity(0.3)
            ChatInputField(
                messageText: $messageText,
                isInputFocused: $isInputFocused,
                isProcessing: viewModel.isProcessing,
                onSend: sendMessage
            )
        }
    }

    private var drawerHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Assistant")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(viewModel.isProcessing ? "Thinking..." : "Ready to help")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: { viewModel.clearConversation() }) {
                    Image(systemName: "trash.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Clear conversation")

                Button(action: { viewModel.toggleDrawer() }) {
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

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isProcessing {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isProcessing) { isProcessing in
                if isProcessing {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        VStack {
            Button(action: { viewModel.toggleDrawer() }) {
                Image(systemName: "message.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Open AI Assistant")

            Spacer()

            if viewModel.isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    dragOffset = .zero
                    if abs(value.translation.width) > 100 {
                        if value.translation.width > 0 && viewModel.isDrawerVisible {
                            viewModel.toggleDrawer()
                        } else if value.translation.width < 0 && !viewModel.isDrawerVisible {
                            viewModel.toggleDrawer()
                        }
                    }
                }
            }
    }

    // MARK: - Helper Methods

    private func sendMessage() {
        let content = messageText
        messageText = ""
        isInputFocused = false

        Task {
            await viewModel.sendMessage(content)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}
