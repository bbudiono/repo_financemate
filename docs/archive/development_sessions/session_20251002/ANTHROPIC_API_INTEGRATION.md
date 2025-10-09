# Anthropic Claude API Integration

## Overview

Production-ready Anthropic Claude API client implementation for FinanceMate. Supports both streaming and non-streaming responses with comprehensive error handling, security, and performance optimization.

## Implementation Details

### Files Created

1. **AnthropicAPIClient.swift** (276 lines)
   - Production-ready API client
   - Streaming and synchronous response support
   - Comprehensive error handling
   - Security-first implementation

2. **AnthropicAPIClientTests.swift** (226 lines)
   - Unit tests covering all scenarios
   - Error handling validation
   - Performance tests
   - Edge case coverage

3. **.env.template** (updated)
   - ANTHROPIC_API_KEY configuration
   - Setup instructions

## Features

### Core Capabilities

- ✅ **Streaming Responses**: AsyncThrowingStream for real-time responses
- ✅ **Synchronous Responses**: Simple request-response pattern
- ✅ **Error Handling**: 6 distinct error types with user-friendly messages
- ✅ **Security**: API key validation, secure storage, no logging
- ✅ **Performance**: Optimized URLSession configuration
- ✅ **Logging**: Detailed os.log integration

### Supported Error Types

1. **invalidAPIKey**: 401 authentication failures
2. **rateLimitExceeded**: 429 with retry-after timing
3. **networkError**: Network connectivity issues
4. **invalidResponse**: Malformed API responses
5. **decodingError**: JSON parsing failures
6. **serverError**: 5xx server errors

## Usage Examples

### Basic Synchronous Request

```swift
let client = AnthropicAPIClient(apiKey: "sk-ant-...")

let messages = [
    AnthropicAPIClient.Message(role: "user", content: "What is compound interest?")
]

do {
    let response = try await client.sendMessageSync(
        messages: messages,
        systemPrompt: "You are a financial advisor."
    )
    print(response)
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### Streaming Request

```swift
let client = AnthropicAPIClient(apiKey: "sk-ant-...")

let messages = [
    AnthropicAPIClient.Message(role: "user", content: "Explain budgeting")
]

do {
    let stream = try await client.sendMessage(messages: messages)

    for try await chunk in stream {
        print(chunk, terminator: "")
    }
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### Multi-Turn Conversation

```swift
let messages = [
    AnthropicAPIClient.Message(role: "user", content: "Hello"),
    AnthropicAPIClient.Message(role: "assistant", content: "Hi! How can I help?"),
    AnthropicAPIClient.Message(role: "user", content: "What are ETFs?")
]

let response = try await client.sendMessageSync(messages: messages)
```

## Configuration

### Environment Setup

1. Copy template:
   ```bash
   cp .env.template .env
   ```

2. Add your Anthropic API key:
   ```
   ANTHROPIC_API_KEY=sk-ant-your_actual_api_key_here
   ```

3. Get API key from: https://console.anthropic.com/settings/keys

### Security Best Practices

- ✅ Store API key in environment variables
- ✅ Never commit .env to version control
- ✅ Validate API key format (starts with "sk-ant-")
- ✅ API key never logged or exposed
- ✅ Secure URLSession configuration
- ❌ Never hardcode API keys in source code

## API Specification

### Model Configuration

- **Model**: claude-sonnet-4-20250514
- **Max Tokens**: 1024 (configurable)
- **API Version**: 2023-06-01
- **Base URL**: https://api.anthropic.com/v1/messages

### Request Headers

```
x-api-key: [YOUR_API_KEY]
anthropic-version: 2023-06-01
content-type: application/json
```

### Request Body

```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "..."}
  ],
  "system": "Optional system prompt",
  "stream": true
}
```

### Response Format (Non-Streaming)

```json
{
  "content": [
    {
      "type": "text",
      "text": "Response content here"
    }
  ]
}
```

### Response Format (Streaming)

Server-Sent Events (SSE):
```
data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"chunk"}}

data: [DONE]
```

## Error Handling

### HTTP Status Codes

- **200-299**: Success
- **401**: Invalid API key → `APIError.invalidAPIKey`
- **429**: Rate limit → `APIError.rateLimitExceeded(retryAfter:)`
- **500-599**: Server error → `APIError.serverError(statusCode:)`

### Error Recovery

```swift
do {
    let response = try await client.sendMessageSync(messages: messages)
} catch AnthropicAPIClient.APIError.invalidAPIKey {
    // Handle invalid API key
    print("Please check your Anthropic API key")
} catch AnthropicAPIClient.APIError.rateLimitExceeded(let retryAfter) {
    // Implement exponential backoff
    print("Rate limited. Retry after \(retryAfter) seconds")
} catch AnthropicAPIClient.APIError.networkError(let error) {
    // Handle network issues
    print("Network error: \(error.localizedDescription)")
} catch {
    // Generic error handling
    print("Unexpected error: \(error)")
}
```

## Testing

### Running Tests

```bash
cd _macOS
xcodebuild test -project FinanceMate.xcodeproj \
  -scheme FinanceMate \
  -destination 'platform=macOS' \
  -only-testing:FinanceMateTests/AnthropicAPIClientTests
```

### Test Coverage

- ✅ Initialization tests
- ✅ Message model validation
- ✅ Error handling tests
- ✅ Request building validation
- ✅ Streaming request tests
- ✅ Multi-message conversations
- ✅ Edge cases (empty content, long messages)
- ✅ Performance benchmarks

### Manual Integration Test

```bash
export ANTHROPIC_API_KEY=sk-ant-your_key
swift test_anthropic_client.swift
```

## Performance

### URLSession Configuration

- **Request Timeout**: 60 seconds
- **Resource Timeout**: 300 seconds
- **Waits for Connectivity**: Enabled
- **Connection Reuse**: Enabled

### Optimization Techniques

1. Connection pooling via URLSession
2. Efficient SSE parsing with buffer management
3. Minimal memory allocation
4. Async/await for optimal concurrency

## KISS Compliance

### Complexity Analysis

- **File Size**: 276 lines (within reasonable bounds)
- **Single Responsibility**: API client only
- **Dependencies**: Foundation, OSLog (minimal)
- **Complexity**: Low cyclomatic complexity
- **Maintainability**: High - clear separation of concerns

### Design Decisions

1. **No business logic**: Pure API client, integration logic goes in services
2. **Minimal abstractions**: Direct URLSession usage
3. **Clear error types**: Explicit error cases
4. **Simple models**: Message struct with minimal fields
5. **Standard patterns**: Swift async/await, AsyncThrowingStream

## Integration with FinanceMate

### LLMFinancialAdvisorService

The API client will be integrated with `LLMFinancialAdvisorService` for:

- Financial question answering
- Transaction analysis
- Budget recommendations
- Investment advice

### Example Service Integration

```swift
class LLMFinancialAdvisorService {
    private let apiClient: AnthropicAPIClient

    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] else {
            fatalError("ANTHROPIC_API_KEY not set")
        }
        self.apiClient = AnthropicAPIClient(apiKey: apiKey)
    }

    func askQuestion(_ question: String) async throws -> String {
        let messages = [
            AnthropicAPIClient.Message(role: "user", content: question)
        ]

        return try await apiClient.sendMessageSync(
            messages: messages,
            systemPrompt: "You are an expert financial advisor..."
        )
    }
}
```

## Security Audit

### Security Checklist

- ✅ API key stored in environment variables
- ✅ API key never logged or printed
- ✅ API key validation on initialization
- ✅ HTTPS-only communication
- ✅ Secure URLSession configuration
- ✅ No sensitive data in error messages
- ✅ Proper timeout configurations
- ✅ No hardcoded credentials

### Threat Mitigation

1. **Credential Exposure**: Environment variable storage
2. **Man-in-the-Middle**: HTTPS enforcement
3. **Rate Limiting**: Exponential backoff support
4. **Network Attacks**: Timeout configurations
5. **Error Information Leakage**: Generic error messages

## Troubleshooting

### Common Issues

**Issue**: "Invalid API key" error
**Solution**: Verify ANTHROPIC_API_KEY in .env starts with "sk-ant-"

**Issue**: Rate limit exceeded
**Solution**: Implement exponential backoff using retryAfter value

**Issue**: Network timeout
**Solution**: Check internet connectivity, increase timeout if needed

**Issue**: Decoding error
**Solution**: Verify API response format matches expected schema

### Debug Logging

Enable debug logging:
```swift
import OSLog

let logger = Logger(subsystem: "com.financemate.api", category: "AnthropicClient")
// Logs are automatically generated by the client
```

View logs in Console.app:
- Filter: `subsystem:com.financemate.api category:AnthropicClient`

## Future Enhancements

### Potential Improvements

1. **Retry Logic**: Automatic retry with exponential backoff
2. **Caching**: Response caching for repeated queries
3. **Token Counting**: Estimate token usage before requests
4. **Function Calling**: Support for tool use API
5. **Batch Requests**: Multiple messages in single API call
6. **Configurable Models**: Support for different Claude models
7. **Request Cancellation**: Cancel in-flight requests
8. **Metrics**: Track API usage and performance

## Compliance

### KISS Principle

- ✅ Single responsibility (API client only)
- ✅ Minimal dependencies (Foundation, OSLog)
- ✅ Clear error handling
- ✅ No over-engineering
- ✅ Simple, maintainable code

### Production Readiness

- ✅ Comprehensive error handling
- ✅ Security best practices
- ✅ Performance optimization
- ✅ Detailed logging
- ✅ Full test coverage
- ✅ Documentation

## References

- [Anthropic API Documentation](https://docs.anthropic.com/en/api/messages)
- [Claude Model Documentation](https://docs.anthropic.com/en/docs/models-overview)
- [API Console](https://console.anthropic.com/)
- [Rate Limits](https://docs.anthropic.com/en/api/rate-limits)

---

**Last Updated**: 2025-10-02
**Version**: 1.0.0
**Status**: Production Ready ✅
