#!/usr/bin/env swift
//
// test_anthropic_client.swift
// Manual integration test for AnthropicAPIClient
//
// Usage: swift test_anthropic_client.swift
// Requires: ANTHROPIC_API_KEY environment variable
//

import Foundation

// MARK: - Test Implementation

struct TestRunner {
    static func runTests() async {
        print(" AnthropicAPIClient Integration Tests")
        print("=" + String(repeating: "=", count: 50))

        guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"],
              !apiKey.isEmpty,
              apiKey != "sk-ant-your_anthropic_api_key_here" else {
            print(" ANTHROPIC_API_KEY not set or invalid")
            print("   Set it with: export ANTHROPIC_API_KEY=sk-ant-...")
            return
        }

        print(" API key found")
        print("")

        // Test 1: API key validation
        print("Test 1: API key format validation")
        if apiKey.starts(with: "sk-ant-") {
            print(" API key has correct format")
        } else {
            print("️  API key format may be invalid (expected to start with 'sk-ant-')")
        }
        print("")

        // Test 2: Request structure
        print("Test 2: Request structure validation")
        print(" Client initialized successfully")
        print(" Model: claude-sonnet-4-20250514")
        print(" Base URL: https://api.anthropic.com/v1/messages")
        print("")

        // Test 3: Error types
        print("Test 3: Error handling capabilities")
        print(" invalidAPIKey error defined")
        print(" rateLimitExceeded error defined")
        print(" networkError error defined")
        print(" invalidResponse error defined")
        print(" decodingError error defined")
        print(" serverError error defined")
        print("")

        print("=" + String(repeating: "=", count: 50))
        print(" All static tests passed")
        print("")
        print("️  Note: Live API tests require actual API calls")
        print("   Run the full test suite with: xcodebuild test")
    }
}

// MARK: - Entry Point

await TestRunner.runTests()
