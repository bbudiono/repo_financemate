//
// AnthropicStreamHandler.swift
// FinanceMate
//
// Server-Sent Events (SSE) stream processor for Anthropic Claude API
// Handles streaming response parsing with buffer management
//

import Foundation
import OSLog

/// Processes Server-Sent Events (SSE) from Anthropic streaming API
struct AnthropicStreamHandler {

    private let logger = Logger(subsystem: "com.financemate.api", category: "StreamHandler")

    // MARK: - Stream Processing

    /// Process byte stream into text chunks
    /// - Parameter bytes: URLSession.AsyncBytes stream
    /// - Returns: AsyncThrowingStream of text chunks
    func processStream(
        _ bytes: URLSession.AsyncBytes
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    var buffer = ""

                    for try await byte in bytes {
                        buffer.append(Character(UnicodeScalar(byte)))

                        // Process complete SSE events (delimited by double newline)
                        while let newlineRange = buffer.range(of: "\n\n") {
                            let event = String(buffer[..<newlineRange.lowerBound])
                            buffer.removeSubrange(..<newlineRange.upperBound)

                            if let content = parseSSEEvent(event) {
                                continuation.yield(content)
                            }
                        }
                    }

                    continuation.finish()
                    logger.info("Stream processing completed successfully")

                } catch {
                    logger.error("Stream processing failed: \(error.localizedDescription)")
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Event Parsing

    /// Parse Server-Sent Event into text content
    /// - Parameter event: Raw SSE event string
    /// - Returns: Extracted text or nil
    private func parseSSEEvent(_ event: String) -> String? {
        let lines = event.split(separator: "\n")

        for line in lines {
            // SSE format: "data: {JSON}"
            if line.starts(with: "data: ") {
                let jsonString = String(line.dropFirst(6))

                // Check for stream end marker
                if jsonString == "[DONE]" {
                    return nil
                }

                // Decode streaming event
                guard let data = jsonString.data(using: .utf8),
                      let json = try? JSONDecoder().decode(AnthropicStreamEvent.self, from: data),
                      json.type == "content_block_delta",
                      let delta = json.delta,
                      delta.type == "text_delta" else {
                    continue
                }

                return delta.text
            }
        }

        return nil
    }
}
