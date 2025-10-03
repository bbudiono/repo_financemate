import Foundation

/// Loads environment variables from .env file
/// CRITICAL: This is required for Gmail OAuth to work properly
struct DotEnvLoader {
    /// Load .env file from project root and set environment variables
    static func load() {
        // Try multiple possible locations for .env file
        let possiblePaths = [
            // Production path (app bundle)
            Bundle.main.bundlePath + "/../../../../.env",
            // Development path (relative to _macOS)
            FileManager.default.currentDirectoryPath + "/../../.env",
            // Absolute path to project root
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/.env"
        ]

        for path in possiblePaths {
            if loadFromPath(path) {
                print(" Loaded .env from: \(path)")
                return
            }
        }

        print("️ Warning: .env file not found. OAuth features will not work.")
        print("Searched paths: \(possiblePaths)")
    }

    /// Load environment variables from a specific path
    @discardableResult
    private static func loadFromPath(_ path: String) -> Bool {
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            return false
        }

        // Parse .env file line by line
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            // Skip comments and empty lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Parse KEY=VALUE pairs
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)

                // Set environment variable
                setenv(key, value, 1)
            }
        }

        // Verify critical OAuth variables were loaded
        if ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"] != nil &&
           ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"] != nil {
            return true
        }

        return false
    }

    /// Verify OAuth credentials are loaded
    static func verifyOAuthCredentials() -> Bool {
        let clientID = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_ID"]
        let clientSecret = ProcessInfo.processInfo.environment["GOOGLE_OAUTH_CLIENT_SECRET"]

        guard let id = clientID, !id.isEmpty,
              let secret = clientSecret, !secret.isEmpty else {
            print(" OAuth credentials not found in environment")
            print("  GOOGLE_OAUTH_CLIENT_ID: \(clientID ?? "NOT SET")")
            print("  GOOGLE_OAUTH_CLIENT_SECRET: \(clientSecret != nil ? "SET" : "NOT SET")")
            return false
        }

        print(" OAuth credentials loaded successfully")
        print("  Client ID: \(String(id.prefix(20)))...")
        return true
    }
}