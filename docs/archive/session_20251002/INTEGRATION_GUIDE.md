# Integration Guide: AnthropicAPIClient with LLMFinancialAdvisorService

## Overview
This guide shows how to integrate the production-ready `AnthropicAPIClient` with the existing `LLMFinancialAdvisorService` to enable real AI-powered financial advice in FinanceMate.

## Step 1: Update LLMFinancialAdvisorService

### Current Implementation (Mock)
The current service likely returns mock responses. We'll replace this with real Anthropic API calls.

### Updated Implementation

```swift
//
// LLMFinancialAdvisorService.swift
// FinanceMate
//
// AI-powered financial advisor using Anthropic Claude API
//

import Foundation
import OSLog

@MainActor
class LLMFinancialAdvisorService: ObservableObject {

    // MARK: - Properties

    private let apiClient: AnthropicAPIClient
    private let logger = Logger(subsystem: "com.financemate.service", category: "LLMAdvisor")

    @Published var conversationHistory: [AnthropicAPIClient.Message] = []
    @Published var isProcessing: Bool = false
    @Published var lastError: String?

    private let systemPrompt = """
    You are an expert financial advisor specializing in personal finance, budgeting,
    and investment strategies. Provide clear, actionable advice tailored to individual
    financial situations. Always consider risk tolerance, time horizons, and financial goals.

    When discussing financial products or investments, provide balanced perspectives and
    remind users to consult with licensed financial professionals for personalized advice.

    Keep responses concise and practical, focusing on actionable steps users can take
    to improve their financial health.
    """

    // MARK: - Initialization

    init() {
        // Get API key from environment
        guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"],
              !apiKey.isEmpty,
              apiKey != "sk-ant-your_anthropic_api_key_here" else {
            logger.error("ANTHROPIC_API_KEY not configured properly")
            fatalError("ANTHROPIC_API_KEY environment variable not set. Please configure .env file.")
        }

        self.apiClient = AnthropicAPIClient(apiKey: apiKey)
        logger.info("LLMFinancialAdvisorService initialized successfully")
    }

    // MARK: - Public API - Synchronous Response

    /// Ask a financial question and get a complete response
    /// - Parameter question: User's financial question
    /// - Returns: AI-generated financial advice
    func askQuestion(_ question: String) async throws -> String {
        logger.info("Processing question: \(question.prefix(50))...")
        isProcessing = true
        lastError = nil

        defer {
            isProcessing = false
        }

        // Add user message to history
        let userMessage = AnthropicAPIClient.Message(role: "user", content: question)
        conversationHistory.append(userMessage)

        do {
            // Get response from Anthropic API
            let response = try await apiClient.sendMessageSync(
                messages: conversationHistory,
                systemPrompt: systemPrompt
            )

            // Add assistant response to history
            let assistantMessage = AnthropicAPIClient.Message(role: "assistant", content: response)
            conversationHistory.append(assistantMessage)

            logger.info("Question processed successfully")
            return response

        } catch let error as AnthropicAPIClient.APIError {
            logger.error("API error: \(error.localizedDescription)")
            lastError = error.localizedDescription
            throw error

        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            lastError = "An unexpected error occurred. Please try again."
            throw error
        }
    }

    // MARK: - Public API - Streaming Response

    /// Ask a financial question with streaming response
    /// - Parameter question: User's financial question
    /// - Returns: AsyncThrowingStream of response chunks
    func askQuestionStreaming(_ question: String) async throws -> AsyncThrowingStream<String, Error> {
        logger.info("Processing streaming question: \(question.prefix(50))...")
        isProcessing = true
        lastError = nil

        // Add user message to history
        let userMessage = AnthropicAPIClient.Message(role: "user", content: question)
        conversationHistory.append(userMessage)

        do {
            let stream = try await apiClient.sendMessage(
                messages: conversationHistory,
                systemPrompt: systemPrompt
            )

            // Collect response for history
            var fullResponse = ""

            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await chunk in stream {
                            fullResponse.append(chunk)
                            continuation.yield(chunk)
                        }

                        // Add complete response to history
                        let assistantMessage = AnthropicAPIClient.Message(
                            role: "assistant",
                            content: fullResponse
                        )
                        await MainActor.run {
                            self.conversationHistory.append(assistantMessage)
                            self.isProcessing = false
                        }

                        continuation.finish()

                    } catch {
                        await MainActor.run {
                            self.lastError = error.localizedDescription
                            self.isProcessing = false
                        }
                        continuation.finish(throwing: error)
                    }
                }
            }

        } catch {
            isProcessing = false
            lastError = error.localizedDescription
            throw error
        }
    }

    // MARK: - Conversation Management

    /// Clear conversation history
    func clearConversation() {
        logger.info("Clearing conversation history")
        conversationHistory.removeAll()
        lastError = nil
    }

    /// Get conversation history count
    var messageCount: Int {
        conversationHistory.count
    }

    /// Check if service is ready
    var isReady: Bool {
        !isProcessing && lastError == nil
    }
}
```

## Step 2: Update ChatbotDrawer to Use Real API

### Key Changes

```swift
// In ChatbotDrawer.swift

@StateObject private var llmService = LLMFinancialAdvisorService()
@State private var streamingResponse = ""

// Replace mock sendMessage with:
private func sendMessage() {
    guard !currentMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }

    let userMessage = ChatMessage(text: currentMessage, isUser: true)
    messages.append(userMessage)
    currentMessage = ""
    isTyping = true
    streamingResponse = ""

    Task {
        do {
            // Use streaming for better UX
            let stream = try await llmService.askQuestionStreaming(userMessage.text)

            // Add empty assistant message that we'll update
            await MainActor.run {
                messages.append(ChatMessage(text: "", isUser: false))
            }

            // Stream response chunks
            for try await chunk in stream {
                await MainActor.run {
                    streamingResponse.append(chunk)
                    // Update last message with accumulated response
                    if let lastIndex = messages.indices.last {
                        messages[lastIndex].text = streamingResponse
                    }
                }
            }

            await MainActor.run {
                isTyping = false
                streamingResponse = ""
            }

        } catch {
            await MainActor.run {
                isTyping = false
                messages.append(ChatMessage(
                    text: "Sorry, I encountered an error: \(error.localizedDescription)",
                    isUser: false
                ))
            }
        }
    }
}
```

## Step 3: Environment Configuration

### Create .env File

```bash
cd /path/to/repo_financemate
cp .env.template .env
```

### Edit .env

```
ANTHROPIC_API_KEY=sk-ant-your_actual_api_key_from_anthropic_console
GOOGLE_OAUTH_CLIENT_ID=your_google_client_id
GOOGLE_OAUTH_CLIENT_SECRET=your_google_client_secret
```

### Load Environment in Xcode

Add to scheme environment variables:
1. Open scheme settings (Product → Scheme → Edit Scheme)
2. Select "Run" → "Arguments" → "Environment Variables"
3. Add from .env file

Or use a build phase script:

```bash
# Build Phase: Load Environment Variables
if [ -f "$SRCROOT/../.env" ]; then
    export $(cat "$SRCROOT/../.env" | grep -v '^#' | xargs)
fi
```

## Step 4: Error Handling UI

### Add Error Banner to ChatbotDrawer

```swift
// At top of ChatbotDrawer body
if let error = llmService.lastError {
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.orange)
        Text(error)
            .font(.caption)
            .foregroundColor(.secondary)
        Spacer()
        Button("Dismiss") {
            llmService.lastError = nil
        }
    }
    .padding()
    .background(Color.orange.opacity(0.1))
    .cornerRadius(8)
}
```

## Step 5: Testing the Integration

### Manual Test Script

```swift
import Foundation

@MainActor
func testLLMIntegration() async {
    print("Testing LLM Financial Advisor Service...")

    let service = LLMFinancialAdvisorService()

    // Test 1: Simple question
    do {
        let response = try await service.askQuestion("What is compound interest?")
        print("Response: \(response)")
    } catch {
        print("Error: \(error)")
    }

    // Test 2: Follow-up question
    do {
        let response = try await service.askQuestion("How can I apply it to my savings?")
        print("Follow-up: \(response)")
    } catch {
        print("Error: \(error)")
    }

    print("Message count: \(service.messageCount)")
}

await testLLMIntegration()
```

## Step 6: Performance Optimization

### Response Caching (Optional)

```swift
// Add to LLMFinancialAdvisorService

private var responseCache: [String: String] = [:]
private let maxCacheSize = 50

private func getCachedResponse(for question: String) -> String? {
    return responseCache[question]
}

private func cacheResponse(_ response: String, for question: String) {
    if responseCache.count >= maxCacheSize {
        // Remove oldest entry
        if let firstKey = responseCache.keys.first {
            responseCache.removeValue(forKey: firstKey)
        }
    }
    responseCache[question] = response
}
```

## Step 7: Monitoring and Analytics

### Add Usage Tracking

```swift
// Track API usage
private var apiCallCount = 0
private var totalTokensUsed = 0

func logAPIUsage() {
    logger.info("API Calls: \(apiCallCount), Estimated Tokens: \(totalTokensUsed)")
}
```

## Verification Checklist

- [ ] ANTHROPIC_API_KEY set in .env file
- [ ] LLMFinancialAdvisorService updated with real API client
- [ ] ChatbotDrawer using streaming responses
- [ ] Error handling UI implemented
- [ ] Build succeeds without errors
- [ ] Manual test confirms API connectivity
- [ ] Conversation history persists correctly
- [ ] Streaming UI updates smoothly
- [ ] Error messages display properly
- [ ] Rate limiting handled gracefully

## Troubleshooting

### Issue: "ANTHROPIC_API_KEY not set"
**Solution**: Verify .env file exists and contains valid API key

### Issue: "Invalid API key"
**Solution**: Check API key format (starts with "sk-ant-") and validity in Anthropic console

### Issue: Streaming not working
**Solution**: Verify AsyncThrowingStream properly handled in UI with @MainActor

### Issue: Rate limit exceeded
**Solution**: Implement exponential backoff or reduce request frequency

## Next Steps

1. Test integration with real Anthropic API key
2. Add conversation export/import
3. Implement response caching
4. Add conversation templates (budgeting, investing, etc.)
5. Performance monitoring and optimization

---

**Integration Status**: Ready for implementation
**Estimated Time**: 30-60 minutes
**Prerequisites**: Valid Anthropic API key
