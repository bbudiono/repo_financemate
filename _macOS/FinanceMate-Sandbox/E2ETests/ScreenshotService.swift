import Foundation
import XCTest

@MainActor
class ScreenshotService {
    static let shared = ScreenshotService()
    
    private init() {}
    
    func takeScreenshot(name: String) {
        // Placeholder implementation
    }
}