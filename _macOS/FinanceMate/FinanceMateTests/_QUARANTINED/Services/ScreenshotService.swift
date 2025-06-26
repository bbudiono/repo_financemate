import XCTest

class ScreenshotService {
    static func capture(name: String, in testCase: XCTestCase) -> XCTAttachment? {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(name).png"
        attachment.lifetime = .keepAlways
        testCase.add(attachment)

        // Also save to artifacts directory for CI access
        let artifactsPath = FileManager.default.currentDirectoryPath + "/test_artifacts"
        try? FileManager.default.createDirectory(atPath: artifactsPath, withIntermediateDirectories: true)

        let screenshotPath = "\(artifactsPath)/\(name).png"
        let imageData = screenshot.pngRepresentation
        try? imageData.write(to: URL(fileURLWithPath: screenshotPath))

        print("Screenshot saved to: \(screenshotPath)")
        return attachment
    }
}
