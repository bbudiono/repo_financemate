import Foundation

/// Loads environment variables from .env file for standalone app launches
/// When app is launched outside Xcode, manually load .env file into process environment
struct EnvironmentLoader {

    /// Load .env file from project root into process environment
    static func loadEnvironmentFile() {
        // Find .env file (search parent directories from app bundle)
        guard let bundlePath = Bundle.main.resourcePath else {
            print("️  Could not find bundle resource path")
            return
        }

        // Check multiple possible .env locations
        let possiblePaths = [
            // When running from Xcode DerivedData
            URL(fileURLWithPath: bundlePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent(".env"),

            // When running as installed app (future)
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".config")
                .appendingPathComponent("financemate")
                .appendingPathComponent(".env")
        ]

        var envFileURL: URL?
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path.path) {
                envFileURL = path
                print(" Found .env file: \(path.path)")
                break
            }
        }

        guard let envFile = envFileURL else {
            print("️  No .env file found. OAuth/API features will not work.")
            print("   Expected locations:")
            for path in possiblePaths {
                print("   - \(path.path)")
            }
            return
        }

        // Read and parse .env file
        do {
            let content = try String(contentsOf: envFile, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)

            var loadedCount = 0
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                // Skip comments and empty lines
                guard !trimmed.isEmpty, !trimmed.hasPrefix("#"), trimmed.contains("=") else {
                    continue
                }

                // Parse KEY=VALUE
                let parts = trimmed.components(separatedBy: "=")
                guard parts.count >= 2 else { continue }

                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)

                // Set environment variable
                setenv(key, value, 1)
                loadedCount += 1

                // Debug log critical vars (redacted)
                if key.contains("CLIENT_ID") {
                    print("  Loaded: \(key)=\(value.prefix(20))...")
                } else if key.contains("ANTHROPIC") {
                    print("  Loaded: \(key)=\(value.prefix(10))...")
                }
            }

            print(" Loaded \(loadedCount) environment variables from .env")

        } catch {
            print("️  Failed to load .env file: \(error.localizedDescription)")
        }
    }
}
