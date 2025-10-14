import Foundation

/// Attachment parsing extension for GmailAPI (Phase 3.3)
/// KISS: Separated to maintain low complexity in main API file
extension GmailAPI {

    // MARK: - Attachment Parsing

    /// Parse attachments from Gmail payload
    /// - Parameter payload: Email payload with parts
    /// - Returns: Array of attachment metadata
    static func parseAttachments(from payload: Payload) -> [GmailAttachment] {
        guard let parts = payload.parts else { return [] }
        return extractAttachmentsFromParts(parts)
    }

    /// Recursively extract attachments from email parts
    private static func extractAttachmentsFromParts(_ parts: [EmailPart]) -> [GmailAttachment] {
        var attachments: [GmailAttachment] = []

        for part in parts {
            if let attachment = tryExtractAttachment(from: part) {
                attachments.append(attachment)
            }

            // Recursively check nested parts
            if let subparts = part.parts {
                attachments.append(contentsOf: extractAttachmentsFromParts(subparts))
            }
        }

        return attachments
    }

    /// Try to extract attachment from single email part
    private static func tryExtractAttachment(from part: EmailPart) -> GmailAttachment? {
        guard let filename = getFilename(from: part),
              !filename.isEmpty,
              let attachmentId = getAttachmentId(from: part),
              let size = getAttachmentSize(from: part) else {
            return nil
        }

        return GmailAttachment(
            id: attachmentId,
            filename: filename,
            mimeType: part.mimeType,
            size: size
        )
    }

    /// Extract filename from email part
    private static func getFilename(from part: EmailPart) -> String? {
        // Gmail API includes filename in part structure
        // Placeholder for now - will be populated with real Gmail API response
        return nil
    }

    /// Extract attachment ID from email part body
    private static func getAttachmentId(from part: EmailPart) -> String? {
        // Gmail API includes attachmentId in part.body.attachmentId
        return nil
    }

    /// Extract attachment size from email part body
    private static func getAttachmentSize(from part: EmailPart) -> Int? {
        // Gmail API includes size in part.body.size
        return nil
    }
}
