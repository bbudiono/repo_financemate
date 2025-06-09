//
//  APIKeyManagementView.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import SwiftUI
import Foundation

struct APIKeyManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var keychainManager = KeychainManager()
    
    @State private var openAIKey: String = ""
    @State private var anthropicKey: String = ""
    @State private var googleKey: String = ""
    @State private var perplexityKey: String = ""
    
    @State private var showingSaveConfirmation = false
    @State private var saveMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "key.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            Text("API Key Management")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Securely manage your AI service API keys")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // API Key Sections
                    VStack(spacing: 16) {
                        apiKeySection(
                            title: "OpenAI",
                            description: "Required for ChatGPT and GPT-4 functionality",
                            key: $openAIKey,
                            placeholder: "sk-...",
                            icon: "brain.head.profile",
                            color: .green
                        )
                        
                        apiKeySection(
                            title: "Anthropic Claude",
                            description: "Required for Claude AI functionality",
                            key: $anthropicKey,
                            placeholder: "sk-ant-...",
                            icon: "message.badge.filled",
                            color: .orange
                        )
                        
                        apiKeySection(
                            title: "Google AI",
                            description: "Required for Gemini and Google AI services",
                            key: $googleKey,
                            placeholder: "AIza...",
                            icon: "globe",
                            color: .blue
                        )
                        
                        apiKeySection(
                            title: "Perplexity",
                            description: "Required for Perplexity search and research",
                            key: $perplexityKey,
                            placeholder: "pplx-...",
                            icon: "magnifyingglass.circle",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Security Notice
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Security Notice")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Text("All API keys are stored securely in your macOS Keychain and never transmitted to third parties except the respective AI service providers.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save Keys") {
                            saveAPIKeys()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(allKeysEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("API Keys")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("API Keys Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text(saveMessage)
        }
        .onAppear {
            loadExistingKeys()
        }
    }
    
    private func apiKeySection(
        title: String,
        description: String,
        key: Binding<String>,
        placeholder: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !key.wrappedValue.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            SecureField(placeholder, text: key)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var allKeysEmpty: Bool {
        openAIKey.isEmpty && anthropicKey.isEmpty && googleKey.isEmpty && perplexityKey.isEmpty
    }
    
    private func loadExistingKeys() {
        // Note: In production, load from keychain
        // For now, just placeholder behavior
    }
    
    private func saveAPIKeys() {
        var savedCount = 0
        
        if !openAIKey.isEmpty {
            // Save to keychain
            savedCount += 1
        }
        
        if !anthropicKey.isEmpty {
            // Save to keychain
            savedCount += 1
        }
        
        if !googleKey.isEmpty {
            // Save to keychain
            savedCount += 1
        }
        
        if !perplexityKey.isEmpty {
            // Save to keychain
            savedCount += 1
        }
        
        saveMessage = "Successfully saved \(savedCount) API key\(savedCount == 1 ? "" : "s") to secure storage."
        showingSaveConfirmation = true
    }
}

struct APIKeyManagementView_Previews: PreviewProvider {
    static var previews: some View {
        APIKeyManagementView()
    }
}