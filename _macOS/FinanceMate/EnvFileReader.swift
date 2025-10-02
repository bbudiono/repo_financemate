import Foundation

/// Simple .env file reader for OAuth credentials
/// Fallback when environment variables not available
struct EnvFileReader {

    static func getGoogleClientID() -> String? {
        return readEnvVar("GOOGLE_OAUTH_CLIENT_ID")
    }

    static func getGoogleClientSecret() -> String? {
        return readEnvVar("GOOGLE_OAUTH_CLIENT_SECRET")
    }

    static func getAnthropicAPIKey() -> String? {
        return readEnvVar("ANTHROPIC_API_KEY")
    }

    private static func readEnvVar(_ key: String) -> String? {
        // First try process environment
        if let value = ProcessInfo.processInfo.environment[key] {
            return value
        }

        // Fallback: Read from .env file in bundle Resources
        guard let resourcePath = Bundle.main.resourcePath else {
            return nil
        }

        let envPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(".env")

        guard FileManager.default.fileExists(atPath: envPath.path),
              let content = try? String(contentsOf: envPath) else {
            return nil
        }

        // Parse .env file for key
        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#"), trimmed.contains("=") else {
                continue
            }

            let parts = trimmed.components(separatedBy: "=")
            guard parts.count >= 2, parts[0].trimmingCharacters(in: .whitespaces) == key else {
                continue
            }

            let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
            return value
        }

        return nil
    }
}
