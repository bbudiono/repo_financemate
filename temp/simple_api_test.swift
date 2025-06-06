import Foundation

// Simple headless test for OpenAI API
print("🔍 HEADLESS SWIFT API TEST")
print("⏰ Time: \(Date())")

let apiKey = "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"

func testAPI() async {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = """
    {
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "system", "content": "You are FinanceMate assistant."},
            {"role": "user", "content": "HEADLESS TEST: Say 'API Works!' in 3 words"}
        ],
        "max_tokens": 20
    }
    """
    request.httpBody = body.data(using: .utf8)
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        
        if httpResponse.statusCode == 200 {
            let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            let choices = json["choices"] as! [[String: Any]]
            let message = choices[0]["message"] as! [String: Any]
            let content = message["content"] as! String
            
            print("✅ SUCCESS: \(content.trimmingCharacters(in: .whitespacesAndNewlines))")
        } else {
            print("❌ FAILED: HTTP \(httpResponse.statusCode)")
        }
    } catch {
        print("❌ ERROR: \(error)")
    }
}

Task {
    await testAPI()
    print("🏁 Test completed")
}