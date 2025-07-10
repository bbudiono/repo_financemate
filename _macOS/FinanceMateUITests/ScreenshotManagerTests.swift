import XCTest
@testable import FinanceMate

/**
 * ScreenshotManagerTests.swift
 * 
 * Purpose: TDD tests for enhanced screenshot automation with visual regression detection
 * Issues & Complexity Summary: Tests screenshot capture, baseline management, pixel comparison, and diff reporting
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~400
 *   - Core Algorithm Complexity: High (Image processing, pixel-by-pixel comparison)
 *   - Dependencies: 4 (XCTest, XCUITest, CoreGraphics, Foundation)
 *   - State Management Complexity: Medium (Baseline storage, comparison state)
 *   - Novelty/Uncertainty Factor: Medium (New visual regression framework)
 * AI Pre-Task Self-Assessment: 85%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 85%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TDD for visual regression testing with automated diff detection
 * Last Updated: 2025-07-09
 */

class ScreenshotManagerTests: XCTestCase {
    
    var screenshotManager: ScreenshotManager!
    var mockApp: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        screenshotManager = ScreenshotManager.shared
        mockApp = XCUIApplication()
    }
    
    override func tearDown() {
        screenshotManager = nil
        mockApp = nil
        super.tearDown()
    }
    
    // MARK: - Baseline Screenshot Tests
    
    func testCaptureBaselineScreenshot() {
        // Given: A screenshot manager and mock app
        let screenshotName = "test-baseline-screenshot"
        
        // When: Capturing a baseline screenshot
        // This should fail initially as ScreenshotManager doesn't exist yet
        let baselineScreenshot = screenshotManager.captureBaselineScreenshot(name: screenshotName, app: mockApp)
        
        // Then: Should create a baseline screenshot with proper naming
        XCTAssertNotNil(baselineScreenshot, "Baseline screenshot should be created")
        XCTAssertEqual(baselineScreenshot.name, "baseline-\(screenshotName)", "Screenshot should have correct baseline naming")
        XCTAssertEqual(baselineScreenshot.lifetime, .keepAlways, "Baseline screenshots should be kept permanently")
    }
    
    func testCaptureBaselineScreenshotWithInvalidApp() {
        // Given: An invalid app instance
        let screenshotName = "test-invalid-app"
        
        // When: Attempting to capture screenshot with invalid app
        // Then: Should handle error gracefully
        XCTAssertThrowsError(try screenshotManager.captureBaselineScreenshot(name: screenshotName, app: nil)) { error in
            XCTAssertTrue(error is ScreenshotManager.ScreenshotError, "Should throw ScreenshotError for invalid app")
        }
    }
    
    // MARK: - Screenshot Comparison Tests
    
    func testCompareIdenticalScreenshots() {
        // Given: Two identical screenshots
        let baselineScreenshot = createMockScreenshot(name: "baseline-test")
        let currentScreenshot = createMockScreenshot(name: "current-test")
        
        // When: Comparing identical screenshots
        let comparison = screenshotManager.compareScreenshots(baseline: baselineScreenshot, current: currentScreenshot)
        
        // Then: Should indicate no differences
        XCTAssertEqual(comparison.similarityPercentage, 100.0, accuracy: 0.01, "Identical screenshots should have 100% similarity")
        XCTAssertTrue(comparison.passesThreshold, "Identical screenshots should pass threshold")
        XCTAssertTrue(comparison.differences.isEmpty, "Identical screenshots should have no differences")
    }
    
    func testCompareScreenshotsWithDifferences() {
        // Given: Two different screenshots
        let baselineScreenshot = createMockScreenshot(name: "baseline-different")
        let currentScreenshot = createMockScreenshot(name: "current-different")
        
        // When: Comparing different screenshots
        let comparison = screenshotManager.compareScreenshots(baseline: baselineScreenshot, current: currentScreenshot)
        
        // Then: Should detect differences
        XCTAssertLessThan(comparison.similarityPercentage, 100.0, "Different screenshots should have < 100% similarity")
        XCTAssertFalse(comparison.differences.isEmpty, "Different screenshots should have detected differences")
    }
    
    func testCompareScreenshotsWithThreshold() {
        // Given: Screenshots with minor differences and a threshold
        let baselineScreenshot = createMockScreenshot(name: "baseline-threshold")
        let currentScreenshot = createMockScreenshot(name: "current-threshold")
        
        // When: Comparing with a specific threshold
        let comparison = screenshotManager.compareScreenshots(
            baseline: baselineScreenshot, 
            current: currentScreenshot,
            threshold: 0.95
        )
        
        // Then: Should respect threshold setting
        if comparison.similarityPercentage >= 95.0 {
            XCTAssertTrue(comparison.passesThreshold, "Screenshots above threshold should pass")
        } else {
            XCTAssertFalse(comparison.passesThreshold, "Screenshots below threshold should fail")
        }
    }
    
    // MARK: - Diff Report Generation Tests
    
    func testGenerateDiffReport() {
        // Given: A screenshot comparison with differences
        let baselineScreenshot = createMockScreenshot(name: "baseline-diff")
        let currentScreenshot = createMockScreenshot(name: "current-diff")
        let comparison = ScreenshotComparison(
            baseline: baselineScreenshot,
            current: currentScreenshot,
            differences: [
                PixelDifference(x: 10, y: 20, expectedColor: .red, actualColor: .blue),
                PixelDifference(x: 50, y: 80, expectedColor: .green, actualColor: .yellow)
            ],
            similarityPercentage: 95.5,
            passesThreshold: true
        )
        
        // When: Generating diff report
        let diffReport = screenshotManager.generateDiffReport(comparison: comparison)
        
        // Then: Should create comprehensive diff report
        XCTAssertNotNil(diffReport, "Diff report should be generated")
        XCTAssertEqual(diffReport.comparisonResult, comparison, "Report should contain comparison data")
        XCTAssertEqual(diffReport.differenceCount, 2, "Report should count detected differences")
        XCTAssertNotNil(diffReport.highlightedDiffImage, "Report should include highlighted diff image")
        XCTAssertTrue(diffReport.summary.contains("95.5%"), "Report summary should include similarity percentage")
    }
    
    func testGenerateDiffReportWithNoDifferences() {
        // Given: A screenshot comparison with no differences
        let baselineScreenshot = createMockScreenshot(name: "baseline-no-diff")
        let currentScreenshot = createMockScreenshot(name: "current-no-diff")
        let comparison = ScreenshotComparison(
            baseline: baselineScreenshot,
            current: currentScreenshot,
            differences: [],
            similarityPercentage: 100.0,
            passesThreshold: true
        )
        
        // When: Generating diff report
        let diffReport = screenshotManager.generateDiffReport(comparison: comparison)
        
        // Then: Should create report indicating no differences
        XCTAssertNotNil(diffReport, "Diff report should be generated even with no differences")
        XCTAssertEqual(diffReport.differenceCount, 0, "Report should show zero differences")
        XCTAssertTrue(diffReport.summary.contains("100%"), "Report should indicate perfect match")
        XCTAssertTrue(diffReport.summary.contains("identical"), "Report should indicate screenshots are identical")
    }
    
    // MARK: - Visual Regression Test Protocol Tests
    
    func testVisualRegressionTestProtocol() {
        // Given: A visual regression test implementation
        let regressionTest = MockVisualRegressionTest()
        
        // When: Running visual regression test
        let result = regressionTest.captureAndCompareScreenshot(name: "test-regression", threshold: 0.98)
        
        // Then: Should execute complete visual regression workflow
        XCTAssertTrue(result, "Visual regression test should complete successfully")
        XCTAssertTrue(regressionTest.didCaptureScreenshot, "Test should capture screenshot")
        XCTAssertTrue(regressionTest.didCompareWithBaseline, "Test should compare with baseline")
        XCTAssertTrue(regressionTest.didGenerateReport, "Test should generate comparison report")
    }
    
    func testUpdateBaseline() {
        // Given: A visual regression test with existing baseline
        let regressionTest = MockVisualRegressionTest()
        let screenshotName = "test-update-baseline"
        
        // When: Updating baseline screenshot
        regressionTest.updateBaseline(name: screenshotName)
        
        // Then: Should update baseline with current screenshot
        XCTAssertTrue(regressionTest.didUpdateBaseline, "Should update baseline screenshot")
        XCTAssertEqual(regressionTest.lastUpdatedBaseline, screenshotName, "Should update correct baseline")
    }
    
    func testGenerateRegressionReport() {
        // Given: A visual regression test with comparison results
        let regressionTest = MockVisualRegressionTest()
        regressionTest.addComparisonResult(name: "test-1", similarity: 100.0, passed: true)
        regressionTest.addComparisonResult(name: "test-2", similarity: 94.5, passed: false)
        
        // When: Generating regression report
        let report = regressionTest.generateRegressionReport()
        
        // Then: Should create comprehensive regression report
        XCTAssertFalse(report.isEmpty, "Report should not be empty")
        XCTAssertTrue(report.contains("test-1"), "Report should include all test results")
        XCTAssertTrue(report.contains("test-2"), "Report should include all test results")
        XCTAssertTrue(report.contains("100.0%"), "Report should include similarity percentages")
        XCTAssertTrue(report.contains("94.5%"), "Report should include similarity percentages")
    }
    
    // MARK: - Error Handling Tests
    
    func testScreenshotManagerErrorHandling() {
        // Given: Invalid screenshot data
        let invalidScreenshot = createInvalidScreenshot()
        
        // When: Attempting to process invalid screenshot
        // Then: Should handle errors gracefully
        XCTAssertThrowsError(try screenshotManager.processScreenshot(invalidScreenshot)) { error in
            XCTAssertTrue(error is ScreenshotManager.ScreenshotError, "Should throw appropriate error type")
        }
    }
    
    func testScreenshotComparisonWithCorruptedData() {
        // Given: Corrupted screenshot data
        let corruptedScreenshot = createCorruptedScreenshot()
        let validScreenshot = createMockScreenshot(name: "valid")
        
        // When: Comparing with corrupted data
        // Then: Should handle corruption gracefully
        XCTAssertThrowsError(try screenshotManager.compareScreenshots(baseline: corruptedScreenshot, current: validScreenshot)) { error in
            XCTAssertTrue(error is ScreenshotManager.ScreenshotError, "Should handle corrupted data with proper error")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockScreenshot(name: String) -> XCTAttachment {
        let screenshot = XCTAttachment(data: Data(), uniformTypeIdentifier: "public.png")
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        return screenshot
    }
    
    private func createInvalidScreenshot() -> XCTAttachment {
        let screenshot = XCTAttachment(data: Data(), uniformTypeIdentifier: "invalid.type")
        screenshot.name = "invalid-screenshot"
        return screenshot
    }
    
    private func createCorruptedScreenshot() -> XCTAttachment {
        let corruptedData = Data([0x00, 0x01, 0x02, 0x03]) // Invalid image data
        let screenshot = XCTAttachment(data: corruptedData, uniformTypeIdentifier: "public.png")
        screenshot.name = "corrupted-screenshot"
        return screenshot
    }
}

// MARK: - Mock Classes for Testing

class MockVisualRegressionTest: VisualRegressionTest {
    var didCaptureScreenshot = false
    var didCompareWithBaseline = false
    var didGenerateReport = false
    var didUpdateBaseline = false
    var lastUpdatedBaseline: String?
    var comparisonResults: [(name: String, similarity: Double, passed: Bool)] = []
    
    func captureAndCompareScreenshot(name: String, threshold: Double) -> Bool {
        didCaptureScreenshot = true
        didCompareWithBaseline = true
        didGenerateReport = true
        return true
    }
    
    func updateBaseline(name: String) {
        didUpdateBaseline = true
        lastUpdatedBaseline = name
    }
    
    func generateRegressionReport() -> String {
        var report = "Visual Regression Test Report\n"
        report += "=" * 40 + "\n\n"
        
        for result in comparisonResults {
            report += "Test: \(result.name)\n"
            report += "Similarity: \(result.similarity)%\n"
            report += "Status: \(result.passed ? "PASSED" : "FAILED")\n\n"
        }
        
        return report
    }
    
    func addComparisonResult(name: String, similarity: Double, passed: Bool) {
        comparisonResults.append((name: name, similarity: similarity, passed: passed))
    }
}