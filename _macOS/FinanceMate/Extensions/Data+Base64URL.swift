import Foundation

// MARK: - Base64URL Decoding Extension

extension Data {
    /// Decode base64url-encoded string (Gmail's format)
    /// Base64url replaces + with - and / with _
    init?(base64urlEncoded string: String) {
        // Convert base64url to standard base64
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let paddingLength = (4 - base64.count % 4) % 4
        base64 += String(repeating: "=", count: paddingLength)

        // Decode standard base64
        self.init(base64Encoded: base64)
    }
}
