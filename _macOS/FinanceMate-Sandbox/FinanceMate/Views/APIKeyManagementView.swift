//
//  APIKeyManagementView.swift
//  FinanceMate
//
//  Created by Assistant on 6/10/25.
//

import Foundation
import SwiftUI

struct APIKeyManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var keychainManager = KeychainManager()

    @State private var openAIKey: String = ""
    @State private var anthropicKey: String = ""
    @State private var googleKey: String = ""
    @State private var perplexityKey: String = ""

    @State private var showingSaveConfirmation = false
    @State private var saveMessage = ""
    @State private var validationErrors: [String: String] = [:]
    @State private var showingValidationAlert = false
    @State private var showingErrorAlert = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorGuidance = ""

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
                            color: .green,
                            keyIdentifier: "openai"
                        )

                        apiKeySection(
                            title: "Anthropic Claude",
                            description: "Required for Claude AI functionality",
                            key: $anthropicKey,
                            placeholder: "sk-ant-...",
                            icon: "message.badge.filled",
                            color: .orange,
                            keyIdentifier: "anthropic"
                        )

                        apiKeySection(
                            title: "Google AI",
                            description: "Required for Gemini and Google AI services",
                            key: $googleKey,
                            placeholder: "AIza...",
                            icon: "globe",
                            color: .blue,
                            keyIdentifier: "google"
                        )

                        apiKeySection(
                            title: "Perplexity",
                            description: "Required for Perplexity search and research",
                            key: $perplexityKey,
                            placeholder: "pplx-...",
                            icon: "magnifyingglass.circle",
                            color: .purple,
                            keyIdentifier: "perplexity"
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
                            if validateAllKeys() {
                                saveAPIKeys()
                            } else {
                                showingValidationAlert = true
                            }
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
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationErrorMessage)
        }
        .alert(errorTitle, isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            VStack(alignment: .leading, spacing: 8) {
                Text(errorMessage)
                Text("How to fix:")
                    .font(.headline)
                Text(errorGuidance)
                    .font(.caption)
            }
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
        color: Color,
        keyIdentifier: String
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

            VStack(alignment: .leading, spacing: 4) {
                SecureField(placeholder, text: key)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(validationErrors[keyIdentifier] != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
                    .onChange(of: key.wrappedValue) { newValue in
                        validateKey(keyIdentifier: keyIdentifier, value: newValue)
                    }

                if let errorMessage = validationErrors[keyIdentifier] {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
            }
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
        var errors: [String] = []

        func saveKey(_ key: String, identifier: String, serviceName: String) {
            guard !key.isEmpty else { return }

            do {
                let data = key.data(using: .utf8)!
                try keychainManager.save(data, for: "api_key_\(identifier)")
                savedCount += 1
            } catch let error as KeychainManager.KeychainError {
                errors.append("\(serviceName): \(error.localizedDescription)")
            } catch {
                errors.append("\(serviceName): Unknown error occurred")
            }
        }

        saveKey(openAIKey, identifier: "openai", serviceName: "OpenAI")
        saveKey(anthropicKey, identifier: "anthropic", serviceName: "Anthropic")
        saveKey(googleKey, identifier: "google", serviceName: "Google AI")
        saveKey(perplexityKey, identifier: "perplexity", serviceName: "Perplexity")

        if errors.isEmpty {
            saveMessage = "Successfully saved \(savedCount) API key\(savedCount == 1 ? "" : "s") to secure storage."
            showingSaveConfirmation = true
        } else if savedCount > 0 {
            let partialMessage = "Saved \(savedCount) key\(savedCount == 1 ? "" : "s"), but encountered errors:\n\(errors.joined(separator: "\n"))"
            showKeychainError(title: "Partial Save Complete", message: partialMessage, guidance: "Check the failed keys and try again.")
        } else {
            let allErrorsMessage = "Failed to save any keys:\n\(errors.joined(separator: "\n"))"
            showKeychainError(title: "Save Failed", message: allErrorsMessage, guidance: "Check your keychain permissions and try again.")
        }
    }

    private func showKeychainError(title: String, message: String, guidance: String) {
        errorTitle = title
        errorMessage = message
        errorGuidance = guidance
        showingErrorAlert = true
    }

    private func validateKey(keyIdentifier: String, value: String) {
        if value.isEmpty {
            validationErrors.removeValue(forKey: keyIdentifier)
            return
        }

        var errorMessage: String?

        switch keyIdentifier {
        case "openai":
            if !value.hasPrefix("sk-") {
                errorMessage = "OpenAI keys must start with 'sk-'"
            } else if value.count < 20 {
                errorMessage = "OpenAI key appears too short"
            }

        case "anthropic":
            if !value.hasPrefix("sk-ant-") {
                errorMessage = "Anthropic keys must start with 'sk-ant-'"
            } else if value.count < 25 {
                errorMessage = "Anthropic key appears too short"
            }

        case "google":
            if !value.hasPrefix("AIza") {
                errorMessage = "Google AI keys typically start with 'AIza'"
            } else if value.count < 25 {
                errorMessage = "Google AI key appears too short"
            }

        case "perplexity":
            if !value.hasPrefix("pplx-") {
                errorMessage = "Perplexity keys must start with 'pplx-'"
            } else if value.count < 20 {
                errorMessage = "Perplexity key appears too short"
            }

        default:
            break
        }

        if let error = errorMessage {
            validationErrors[keyIdentifier] = error
        } else {
            validationErrors.removeValue(forKey: keyIdentifier)
        }
    }

    private func validateAllKeys() -> Bool {
        // Clear existing errors
        validationErrors.removeAll()

        // Validate each non-empty key
        if !openAIKey.isEmpty {
            validateKey(keyIdentifier: "openai", value: openAIKey)
        }
        if !anthropicKey.isEmpty {
            validateKey(keyIdentifier: "anthropic", value: anthropicKey)
        }
        if !googleKey.isEmpty {
            validateKey(keyIdentifier: "google", value: googleKey)
        }
        if !perplexityKey.isEmpty {
            validateKey(keyIdentifier: "perplexity", value: perplexityKey)
        }

        return validationErrors.isEmpty
    }

    private var validationErrorMessage: String {
        let errors = validationErrors.values.joined(separator: "\n")
        return errors.isEmpty ? "Please fix the validation errors above." : errors
    }
}

struct APIKeyManagementView_Previews: PreviewProvider {
    static var previews: some View {
        APIKeyManagementView()
    }
}
