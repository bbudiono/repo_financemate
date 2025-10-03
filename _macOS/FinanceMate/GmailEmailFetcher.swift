import Foundation

/// Simple email body fetcher - KISS principle
struct GmailEmailFetcher {

    /// Extract readable text from Gmail email payload
    static func getEmailText(from payload: Payload) -> String {
        // Try direct body
        if let bodyText = getTextFromBody(payload.body) {
            return bodyText
        }

        // Try parts
        if let parts = payload.parts {
            return getTextFromParts(parts)
        }

        return ""
    }

    private static func getTextFromBody(_ body: EmailBody?) -> String? {
        guard let data = body?.data, !data.isEmpty else { return nil }
        return decodeBase64Url(data)
    }

    private static func getTextFromParts(_ parts: [EmailPart]) -> String {
        for part in parts {
            // Prefer text/plain
            if part.mimeType == "text/plain" {
                if let text = getTextFromBody(part.body) {
                    return text
                }
            }
        }

        // Fallback to any text
        for part in parts {
            if let text = getTextFromBody(part.body), !text.isEmpty {
                return text
            }
            // Check nested parts
            if let subparts = part.parts {
                let text = getTextFromParts(subparts)
                if !text.isEmpty { return text }
            }
        }

        return ""
    }

    private static func decodeBase64Url(_ base64Url: String) -> String? {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }

        return text
    }
}
