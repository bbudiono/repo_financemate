import XCTest
import SwiftUI
import AppKit
@testable import FinanceMate

/// Headless visual verification via SwiftUI snapshot (no XCUITest)
/// - Captures a PNG of `NetWealthDashboardView` and attaches to test results
/// - Also writes a copy under `artifacts/visual_snapshots/` at repo root
@MainActor
final class VisualSnapshotTests: XCTestCase {

    func testNetWealthDashboardVisualSnapshot() throws {
        // Arrange: Compose the SwiftUI view and host it offscreen
        let view = NetWealthDashboardView()
        let hosting = NSHostingView(rootView: view)
        let size = NSSize(width: 1200, height: 800)
        hosting.frame = NSRect(origin: .zero, size: size)

        // Ensure the view has a backing layer for bitmap capture
        hosting.wantsLayer = true
        hosting.layoutSubtreeIfNeeded()

        // Act: Render to bitmap
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            XCTFail("Failed to create bitmap rep for snapshot")
            return
        }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)

        guard let data = rep.representation(using: .png, properties: [:]) else {
            XCTFail("Failed to generate PNG representation for snapshot")
            return
        }

        // Attach to test results (kept in .xcresult bundle)
        let attachment = XCTAttachment(data: data)
        attachment.name = "NetWealthDashboardView_snapshot.png"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also persist a copy to repo artifacts for quick review
        do {
            // Compute repo root using source file path hierarchy: .../_macOS/FinanceMateTests/E2E/this_file
            let sourceURL = URL(fileURLWithPath: #file)
            let repoRoot = sourceURL
                .deletingLastPathComponent() // E2E
                .deletingLastPathComponent() // FinanceMateTests
                .deletingLastPathComponent() // _macOS
                .deletingLastPathComponent() // repo root

            let snapshotsDir = repoRoot.appendingPathComponent("artifacts/visual_snapshots", isDirectory: true)
            try FileManager.default.createDirectory(at: snapshotsDir, withIntermediateDirectories: true)

            let filename = "NetWealthDashboard_" + ISO8601DateFormatter().string(from: Date()) + ".png"
            let fileURL = snapshotsDir.appendingPathComponent(filename)
            try data.write(to: fileURL)

            // Provide a filesystem path hint in logs
            print("📸 Saved visual snapshot to: \(fileURL.path)")
        } catch {
            // Non-fatal if filesystem path cannot be written; attachment still exists
            print("⚠️ Unable to persist snapshot to artifacts directory: \(error.localizedDescription)")
        }

        // Assert: Basic sanity on pixel content size
        XCTAssertGreaterThan(rep.pixelsWide, 0)
        XCTAssertGreaterThan(rep.pixelsHigh, 0)
    }
}
