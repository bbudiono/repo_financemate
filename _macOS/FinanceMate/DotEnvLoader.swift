import Foundation

/// Loads environment variables from .env file
/// CRITICAL: This is required for Gmail OAuth to work properly
struct DotEnvLoader {
    // Store credentials in memory (sandboxing prevents setenv from working reliably)
    private static var credentials: [String: String] = [:]

    /// Get a credential value
    static func get(_ key: String) -> String? {
        return credentials[key]
    }

    /// Set credentials programmatically (for testing/fallback)
    static func setCredentials(_ creds: [String: String]) {
        credentials = creds
    }

    /// Load .env file from project root and set environment variables
    static func load() {
        // Use desktop for debug log (accessible even with sandboxing)
        let debugLog = NSHomeDirectory() + "/Desktop/financemate_debug.log"
        var log = "=== DotEnvLoader.load() START [\(Date())] ===\n"
        log += "Bundle path: \(Bundle.main.bundlePath)\n"
        log += "Current directory: \(FileManager.default.currentDirectoryPath)\n"

        NSLog("=== DotEnvLoader.load() START [\(Date())] ===")
        NSLog("Bundle path: \(Bundle.main.bundlePath)")
        NSLog("Current directory: \(FileManager.default.currentDirectoryPath)")

        // Try multiple possible locations for .env file
        let possiblePaths = [
            // Absolute path to _macOS directory (WHERE .ENV ACTUALLY IS)
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/.env",
            // Fallback: project root (if .env moved there)
            "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/.env",
            // Production path (app bundle)
            Bundle.main.bundlePath + "/../../../../.env"
        ]

        log += "Trying \(possiblePaths.count) possible paths:\n"
        NSLog("Trying \(possiblePaths.count) possible paths:")
        for (index, path) in possiblePaths.enumerated() {
            log += "  [\(index + 1)] \(path)\n"
            NSLog("  [\(index + 1)] \(path)")
            let exists = FileManager.default.fileExists(atPath: path)
            log += "      Exists: \(exists)\n"
            NSLog("      Exists: \(exists)")

            if loadFromPath(path, log: &log) {
                log += "=== SUCCESS: Loaded .env from path [\(index + 1)] ===\n"
                log += "Credentials in memory: \(credentials.keys.sorted())\n"
                log += "Client ID: \(credentials["GOOGLE_OAUTH_CLIENT_ID"]?.prefix(20) ?? "NOT FOUND")\n"
                log += "Client Secret: \(credentials["GOOGLE_OAUTH_CLIENT_SECRET"] != nil ? "LOADED" : "MISSING")\n"

                NSLog(" SUCCESS: Loaded .env from path [\(index + 1)]")
                NSLog(" Credentials in memory: \(credentials.keys.sorted())")
                NSLog(" Client ID: \(credentials["GOOGLE_OAUTH_CLIENT_ID"]?.prefix(20) ?? "NOT FOUND")")
                NSLog(" Client Secret: \(credentials["GOOGLE_OAUTH_CLIENT_SECRET"] != nil ? "LOADED" : "MISSING")")

                try? log.write(toFile: debugLog, atomically: true, encoding: .utf8)
                return
            }
        }

        log += "️ WARNING: .env file not found in any location - using embedded fallback\n"
        log += "Credentials dict is empty: \(credentials.isEmpty)\n"
        NSLog("️ WARNING: .env file not found in any location")
        NSLog("️ Credentials dict is empty: \(credentials.isEmpty)")

        try? log.write(toFile: debugLog, atomically: true, encoding: .utf8)
    }

    /// Load environment variables from a specific path
    @discardableResult
    private static func loadFromPath(_ path: String, log: inout String) -> Bool {
        log += "    Attempting to load from: \(path)\n"
        NSLog("    Attempting to load from: \(path)")

        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            log += "    FAILED: Could not read file\n"
            NSLog("    FAILED: Could not read file")
            return false
        }

        log += "    File read successfully, size: \(contents.count) bytes\n"
        NSLog("    File read successfully, size: \(contents.count) bytes")

        // Parse .env file line by line
        let lines = contents.components(separatedBy: .newlines)
        log += "    Parsing \(lines.count) lines...\n"
        NSLog("    Parsing \(lines.count) lines...")

        var keysFound = 0
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

                // Store in memory dictionary
                credentials[key] = value
                keysFound += 1

                if key.contains("OAUTH") {
                    log += "    Found OAuth key: \(key) = \(value.prefix(20))...\n"
                    NSLog("    Found OAuth key: \(key) = \(value.prefix(20))...")
                }

                // Also try to set environment variable (may not work in sandbox)
                setenv(key, value, 1)
            }
        }

        log += "    Stored \(keysFound) credentials in memory\n"
        NSLog("    Stored \(keysFound) credentials in memory")

        // Verify critical OAuth variables were loaded
        let hasClientID = credentials["GOOGLE_OAUTH_CLIENT_ID"] != nil
        let hasClientSecret = credentials["GOOGLE_OAUTH_CLIENT_SECRET"] != nil

        log += "    Has Client ID: \(hasClientID)\n"
        log += "    Has Client Secret: \(hasClientSecret)\n"
        NSLog("    Has Client ID: \(hasClientID)")
        NSLog("    Has Client Secret: \(hasClientSecret)")

        return hasClientID && hasClientSecret
    }

    /// Verify OAuth credentials are loaded
    static func verifyOAuthCredentials() -> Bool {
        let clientID = credentials["GOOGLE_OAUTH_CLIENT_ID"]
        let clientSecret = credentials["GOOGLE_OAUTH_CLIENT_SECRET"]

        guard let id = clientID, !id.isEmpty,
              let secret = clientSecret, !secret.isEmpty else {
            NSLog(" OAuth credentials not found")
            NSLog("  GOOGLE_OAUTH_CLIENT_ID: \(clientID ?? "NOT SET")")
            NSLog("  GOOGLE_OAUTH_CLIENT_SECRET: \(clientSecret != nil ? "SET" : "NOT SET")")
            NSLog("  Available keys: \(credentials.keys.sorted())")
            return false
        }

        NSLog(" OAuth credentials loaded successfully")
        NSLog("  Client ID: \(String(id.prefix(20)))...")
        return true
    }
}