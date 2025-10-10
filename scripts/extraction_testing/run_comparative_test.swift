#!/usr/bin/env swift

import Foundation
import FoundationModels

struct EmailSample: Codable {
    let id: String
    let subject: String
    let sender: String
    let snippet: String
}

struct ComparisonResult {
    let emailSubject: String
    let foundationModelsTime: Double
    let foundationModelsJSON: String
    let foundationModelsSuccess: Bool
}

class ComparativeTest {
    func runTest() async {
        print("=== FOUNDATION MODELS COMPARATIVE TEST ===")
        print("Hardware: M4 Max / 128GB RAM")
        print("Framework: Foundation Models (~3B params)")
        print("---\n")

        // Load test samples
        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: "gmail_test_samples.json")),
              let samples = try? JSONDecoder().decode([EmailSample].self, from: jsonData) else {
            print("[ERROR] Failed to load test samples")
            return
        }

        print("Loaded \(samples.count) test samples\n")

        // Check availability
        switch SystemLanguageModel.default.availability {
        case .available:
            print("[OK] Foundation Models ready\n")
        case .unavailable(let reason):
            print("[ERROR] Foundation Models unavailable: \(reason)")
            return
        }

        var results: [ComparisonResult] = []

        // Test each sample
        for (index, sample) in samples.enumerated() {
            print("[\(index+1)/\(samples.count)] Testing: \(sample.subject)")

            let prompt = """
            Extract transaction from this Australian email. Return ONLY JSON (no markdown):

            {"merchant":"Name","amount":123.45,"category":"Category","gstAmount":12.34,"abn":"XX XXX XXX XXX","invoiceNumber":"INV123","paymentMethod":"Visa","confidence":0.9}

            Rules:
            - If BNPL (Afterpay/Zip), extract REAL merchant not payment provider
            - GST is 10% in Australia
            - Confidence 0.9+ if certain, 0.5-0.9 if unsure, <0.5 if guessing

            Subject: \(sample.subject)
            From: \(sample.sender)
            Content: \(sample.snippet)
            """

            do {
                let start = Date()
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                let duration = Date().timeIntervalSince(start)

                // Strip markdown if present
                var json = response.content
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let success = json.contains("{") && json.contains("}")

                results.append(ComparisonResult(
                    emailSubject: sample.subject,
                    foundationModelsTime: duration,
                    foundationModelsJSON: json,
                    foundationModelsSuccess: success
                ))

                print("  Time: \(String(format: "%.2f", duration))s")
                print("  Result: \(success ? "" : "")")
                if success {
                    print("  \(json)")
                }
                print()

            } catch {
                print("   Error: \(error.localizedDescription)\n")
            }
        }

        // Summary
        let successCount = results.filter { $0.foundationModelsSuccess }.count
        let avgTime = results.map { $0.foundationModelsTime }.reduce(0, +) / Double(results.count)

        print("\n=== SUMMARY ===")
        print("Success Rate: \(successCount)/\(samples.count) (\(successCount * 100 / samples.count)%)")
        print("Avg Time: \(String(format: "%.2f", avgTime))s")
        print("Hardware: M4 Max with Metal GPU acceleration")
    }
}

let test = ComparativeTest()

Task {
    await test.runTest()
    print("\n[COMPLETE] Comparative test finished")
    exit(0)
}

RunLoop.main.run()
