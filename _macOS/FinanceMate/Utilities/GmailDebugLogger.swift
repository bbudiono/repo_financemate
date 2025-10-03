import Foundation

/// Debug utility for saving Gmail email content for analysis
struct GmailDebugLogger {

    /// Saves email content to debug directory for analysis
    static func saveEmailsForDebug(_ emails: [GmailEmail]) {
        guard let debugDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("gmail_debug") else { return }

        try? FileManager.default.createDirectory(at: debugDir, withIntermediateDirectories: true)

        for (index, email) in emails.enumerated() {
            let debugFile = debugDir.appendingPathComponent("email_\(index)_\(email.id).txt")
            let content = """
            EMAIL \(index + 1)
            ==========
            Subject: \(email.subject)
            From: \(email.sender)
            Date: \(email.date)

            BODY:
            \(email.snippet)
            """
            try? content.write(to: debugFile, atomically: true, encoding: .utf8)
            NSLog("Email \(index) saved: \(debugFile.path)")
        }
    }
}
