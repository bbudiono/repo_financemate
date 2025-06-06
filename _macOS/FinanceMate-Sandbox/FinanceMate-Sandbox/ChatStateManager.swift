// SANDBOX FILE: For testing/development. See .cursorrules.
import Foundation
import SwiftUI
import Combine

/**
 * Legacy ChatStateManager for backward compatibility
 * Now uses the comprehensive chatbot system from ChatbotPanel
 * 
 * Purpose: Provides backward compatibility while using new chatbot infrastructure
 */

class ChatStateManager: ObservableObject {
    @Published var messages: [LegacyChatMessage] = []
    @Published var isProcessing: Bool = false
    
    static let shared = ChatStateManager()
    
    private init() {}
    
    func sendMessage(text: String) {
        let message = LegacyChatMessage(content: text, isUser: true)
        messages.append(message)
        
        // Simulate AI response for sandbox
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = LegacyChatMessage(
                content: "Sandbox AI response to: \(text)",
                isUser: false
            )
            self.messages.append(response)
        }
    }
}

struct LegacyChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}