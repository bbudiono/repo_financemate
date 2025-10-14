import Foundation

/// Service for Gmail attachment operations
/// Handles downloading and processing email attachments
class GmailAttachmentService {

    /// Download attachment from Gmail message
    /// - Parameters:
    ///   - messageId: Gmail message ID
    ///   - attachmentId: Attachment ID from message
    ///   - accessToken: Valid OAuth access token
    /// - Returns: Raw attachment data
    /// - Throws: GmailAPIError if download fails
    static func downloadAttachment(
        messageId: String,
        attachmentId: String,
        accessToken: String
    ) async throws -> Data {
        let endpoint = "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(messageId)/attachments/\(attachmentId)"

        guard let url = URL(string: endpoint) else {
            throw GmailAPIError.invalidURL(endpoint)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GmailAPIError.networkError("Invalid response type")
        }

        guard httpResponse.statusCode == 200 else {
            throw GmailAPIError.apiError(httpResponse.statusCode, "Failed to download attachment")
        }

        // Gmail returns base64url-encoded data in JSON format
        struct AttachmentResponse: Codable {
            let data: String  // base64url-encoded
            let size: Int?
        }

        let attachmentResponse = try JSONDecoder().decode(AttachmentResponse.self, from: data)

        // Decode base64url (Gmail uses base64url, not standard base64)
        guard let decodedData = Data(base64urlEncoded: attachmentResponse.data) else {
            throw GmailAPIError.invalidData("Failed to decode attachment data")
        }

        return decodedData
    }

    /// Extract attachments metadata from Gmail message
    /// - Parameter message: GmailEmail message with raw API response
    /// - Returns: Array of attachment metadata (id, filename, mimeType, size)
    static func extractAttachments(from message: GmailEmail) -> [GmailAttachment] {
        // Parse attachments from message payload
        // Gmail API structure: message.payload.parts[].filename, mimeType, body.attachmentId, body.size

        var attachments: [GmailAttachment] = []

        // TODO: Parse from message.rawAPIResponse if available
        // This is a placeholder - real implementation would parse JSON structure

        return attachments
    }
}
