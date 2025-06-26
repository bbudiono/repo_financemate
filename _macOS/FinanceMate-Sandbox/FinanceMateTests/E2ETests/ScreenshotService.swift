import XCTest
import Foundation

struct ScreenshotService {
    @discardableResult
    static func capture(name: String, in testCase: XCTestCase) -> String? {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        testCase.add(attachment)

        // --- For CI/CD Artifacts ---
        // This part saves the screenshot to a file for external collection.
        let fileManager = FileManager.default
        // Assuming the derived data path for test artifacts. This might need adjustment.
        // A more robust solution involves passing an output directory via environment variables.
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            XCTFail("Failed to get documents directory")
            return nil
        }
        let artifactsDirectory = documentsDirectory.appendingPathComponent("test_artifacts")

        do {
            try fileManager.createDirectory(at: artifactsDirectory, withIntermediateDirectories: true, attributes: nil)
            let screenshotURL = artifactsDirectory.appendingPathComponent("\(name).png")
            try screenshot.pngRepresentation.write(to: screenshotURL)
            print("📸 Screenshot saved to: \(screenshotURL.path)")
            return screenshotURL.path
        } catch {
            XCTFail("Failed to save screenshot: \(error.localizedDescription)")
            return nil
        }
    }
}
