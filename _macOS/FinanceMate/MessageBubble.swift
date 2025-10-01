import SwiftUI

struct MessageBubble: View {
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
