import Foundation

// Simple test of merchant extraction logic
let testCases: [(sender: String, subject: String, expectedMerchant: String)] = [
    ("noreply@defence.gov.au", "Defence Invoice 2025", "Department of Defence"),
    ("support@bunnings.com", "Bunnings Receipt", "Bunnings"),
    ("no-reply@Amazon.com.au", "Your Order from Amazon", "Amazon"),
    ("support@anz.com.au", "ANZ Statement", "ANZ"),
    ("hello@woolworths.com.au", "Woolworths Receipt", "Woolworths"),
    ("orders@apple.com", "Apple Order Confirmation", "Apple"),
]

// Test normalizeDisplayName logic
func testNormalize(_ displayName: String) -> String {
    let name = displayName.trimmingCharacters(in: .whitespaces)
    
    // Remove common business suffixes
    var normalized = name
        .replacingOccurrences(of: " Pty Ltd", with: "", options: .caseInsensitive)
        .replacingOccurrences(of: " Limited", with: "", options: .caseInsensitive)
        .replacingOccurrences(of: " Ltd", with: "", options: .caseInsensitive)
        .trimmingCharacters(in: .whitespaces)
    
    // Check the Bunnings matching - THIS IS THE BUG
    if normalized.lowercased().contains("bunnings warehouse") || normalized.lowercased() == "bunnings warehouse" {
        print("[NORMALIZE] → Matched Bunnings Warehouse → Bunnings")
        return "Bunnings"
    }
    
    return normalized
}

// Test domain extraction
func testDomain(_ sender: String) -> String? {
    if let atIndex = sender.firstIndex(of: "@") {
        let domain = String(sender[sender.index(after: atIndex)...])
        
        if domain.contains(".gov.au") {
            let parts = domain.components(separatedBy: ".")
            if let dept = parts.first {
                switch dept.lowercased() {
                case "defence":
                    return "Department of Defence"
                default:
                    return dept.capitalized
                }
            }
        }
        
        if domain.contains("bunnings.com") { return "Bunnings" }
        if domain.contains("amazon.com") { return "Amazon" }
        if domain.contains("anz.com") { return "ANZ" }
        if domain.contains("woolworths.com") { return "Woolworths" }
        if domain.contains("apple.com") { return "Apple" }
        
        return nil
    }
    return nil
}

print("Testing merchant extraction:")
for testCase in testCases {
    print("\nTest: sender=\(testCase.sender), subject=\(testCase.subject)")
    if let merchant = testDomain(testCase.sender) {
        print("  Result: \(merchant) (expected: \(testCase.expectedMerchant))")
    } else {
        print("  Result: nil (expected: \(testCase.expectedMerchant))")
    }
}
