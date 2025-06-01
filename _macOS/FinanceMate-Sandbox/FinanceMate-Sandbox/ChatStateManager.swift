// SANDBOX FILE: For testing/development. See .cursorrules.
import Foundation
import SwiftUI
import Combine

/**
 * Minimal ChatStateManager for Sandbox environment
 * 
 * Purpose: Basic chat state management for sandbox testing
 */

class ChatStateManager: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing: Bool = false
    
    static let shared = ChatStateManager()
    
    private init() {}
    
    func sendMessage(text: String) {
        let message = ChatMessage(content: text, isUser: true)
        messages.append(message)
        
        // Simulate AI response for sandbox
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = ChatMessage(
                content: "Sandbox AI response to: \(text)",
                isUser: false
            )
            self.messages.append(response)
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}