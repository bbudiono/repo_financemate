import Foundation

class TestExecutorService {

    enum TestExecutorError: Error {
        case executionFailed(output: String)
    }

    static func runXCUITests(scheme: String, project: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild")

        // Note: The path to the .xcodeproj may need to be adjusted for your environment
        process.arguments = [
            "test",
            "-project", project,
            "-scheme", scheme,
            // Run on a simulator to ensure headless execution
            "-destination", "platform=macOS",
            "-only-testing:FinanceMateTests/AuthenticationE2ETests",
            "-resultBundlePath", "test_results.xcresult"
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            throw TestExecutorError.executionFailed(output: output)
        }

        // A real implementation would parse the output for test results.
        // For now, returning the raw log is sufficient proof of execution.
        return output
    }

    static func parseTestResults(from output: String) -> (passed: Int, failed: Int, details: [String]) {
        var passed = 0
        var failed = 0
        var details: [String] = []

        let lines = output.components(separatedBy: .newlines)

        for line in lines {
            if line.contains("Test Case '-[") && line.contains("passed") {
                passed += 1
                details.append("✅ \(extractTestName(from: line))")
            } else if line.contains("Test Case '-[") && line.contains("failed") {
                failed += 1
                details.append("❌ \(extractTestName(from: line))")
            }
        }

        return (passed, failed, details)
    }

    private static func extractTestName(from line: String) -> String {
        // Extract test name from xcodebuild output format
        if let start = line.range(of: "-[")?.upperBound,
           let end = line.range(of: "]")?.lowerBound {
            return String(line[start..<end])
        }
        return line
    }

    static func checkForScreenshots() -> [String] {
        let artifactsPath = FileManager.default.currentDirectoryPath + "/test_artifacts"
        var screenshots: [String] = []

        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: artifactsPath)
            screenshots = files.filter { $0.hasSuffix(".png") }
        } catch {
            // Directory doesn't exist or can't be read
        }

        return screenshots
    }
}
