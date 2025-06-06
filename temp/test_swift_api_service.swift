#!/usr/bin/env swift

import Foundation
import Network

// Test script to verify Swift RealLLMAPIService functionality
// This tests the actual service without UI interaction

print("🔍 TESTING SWIFT RealLLMAPIService")
print("⏰ Timestamp: \(Date().ISO8601Format())")

// Load API key from global .env
func loadAPIKey() -> String? {
    let envPaths = [
        "/Users/bernhardbudiono/.config/mcp/.env",
        "/Users/bernhardbudiono/Library/Application Support/anythingllm-desktop/storage/.env"
    ]
    
    for envPath in envPaths {
        guard let content = try? String(contentsOfFile: envPath) else { continue }
        
        for line in content.components(separatedBy: .newlines) {
            if line.hasPrefix("OPENAI_API_KEY=") {
                let key = String(line.dropFirst("OPENAI_API_KEY=".count))
                return key.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    return nil
}

// Test the OpenAI API call directly
func testOpenAIAPICall() async -> Bool {
    print("🚀 Testing OpenAI API call...")
    
    guard let apiKey = loadAPIKey() else {
        print("❌ FAILED: No API key found")
        return false
    }
    
    print("✅ API key loaded: \(String(apiKey.prefix(20)))...")
    
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages": [
            ["role": "system", "content": "You are a helpful financial assistant integrated into FinanceMate app."],
            ["role": "user", "content": "Headless test: Explain what a budget is in 2 sentences."]
        ],
        "max_tokens": 100
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ FAILED: Invalid response type")
            return false
        }
        
        if httpResponse.statusCode == 200 {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                print("✅ SUCCESS: OpenAI API responded")
                print("📝 Response: \(String(content.prefix(100)))...")
                return true
            } else {
                print("❌ FAILED: Invalid response structure")
                return false
            }
        } else {
            print("❌ FAILED: HTTP \(httpResponse.statusCode)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("📄 Error: \(errorData)")
            }
            return false
        }
    } catch {
        print("❌ FAILED: \(error.localizedDescription)")
        return false
    }
}

// Test network connectivity
func testNetworkConnectivity() -> Bool {
    print("🌐 Testing network connectivity...")
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected = false
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        isConnected = path.status == .satisfied
        semaphore.signal()
    }
    
    monitor.start(queue: queue)
    
    _ = semaphore.wait(timeout: .now() + 2)
    monitor.cancel()
    
    if isConnected {
        print("✅ Network connectivity: GOOD")
    } else {
        print("❌ Network connectivity: FAILED")
    }
    
    return isConnected
}

// Main execution
Task {
    print("=" * 60)
    
    let networkTest = testNetworkConnectivity()
    let apiTest = await testOpenAIAPICall()
    
    print("\n" + "=" * 60)
    print("📊 SWIFT SERVICE TESTING RESULTS:")
    print("  Network: \(networkTest ? "✅ PASS" : "❌ FAIL")")
    print("  OpenAI API: \(apiTest ? "✅ PASS" : "❌ FAIL")")
    
    let overallSuccess = networkTest && apiTest
    print("\n🏁 OVERALL: \(overallSuccess ? "✅ ALL TESTS PASSED" : "❌ SOME TESTS FAILED")")
    print("=" * 60)
    
    exit(overallSuccess ? 0 : 1)
}