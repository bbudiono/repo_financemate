import Foundation

/// Handles decoding of Gmail email bodies from base64url format
struct GmailEmailBodyDecoder {

    /// Extract full email body from Gmail API payload
    static func extractBody(from payload: Payload) -> String {
        // Try direct body first
        if let bodyData = payload.body?.data, !bodyData.isEmpty {
            if let decoded = decodeBase64Url(bodyData) {
                return decoded
            }
        }

        // Try parts for multipart emails
        if let parts = payload.parts {
            return extractFromParts(parts)
        }

        return ""
    }

    /// Recursively extract text from email parts
    private static func extractFromParts(_ parts: [EmailPart]) -> String {
        var allText = ""

        for part in parts {
            // Extract from current part
            if part.mimeType == "text/plain" || part.mimeType == "text/html" {
                if let bodyData = part.body?.data, !bodyData.isEmpty {
                    if let decoded = decodeBase64Url(bodyData) {
                        allText += decoded + "\n"
                    }
                }
            }

            // Recursively handle nested parts
            if let subparts = part.parts {
                allText += extractFromParts(subparts)
            }
        }

        return allText
    }

    /// Decode base64url-encoded string to plain text
    private static func decodeBase64Url(_ base64UrlString: String) -> String? {
        // Gmail uses base64url encoding (RFC 4648)
        var base64 = base64UrlString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }

        return text
    }
}
