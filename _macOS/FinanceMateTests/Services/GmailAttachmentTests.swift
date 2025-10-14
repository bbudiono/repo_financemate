import XCTest
@testable import FinanceMate

/// Tests for Gmail attachment download and caching
class GmailAttachmentTests: XCTestCase {

    var gmailService: GmailAPIService!
    var cacheService: EmailCacheService!

    override func setUp() {
        super.setUp()
        gmailService = GmailAPIService()
        cacheService = EmailCacheService()
    }

    override func tearDown() {
        // Clear cache after each test
        cacheService.clearOldAttachments(maxAge: 0)
        super.tearDown()
    }

    // MARK: - Attachment Detection Tests

    func testGmailAttachmentIsPDF() {
        // Arrange
        let pdfAttachment = GmailAttachment(
            id: "test123",
            filename: "invoice.pdf",
            mimeType: "application/pdf",
            size: 50000
        )

        // Assert
        XCTAssertTrue(pdfAttachment.isPDF)
        XCTAssertFalse(pdfAttachment.isImage)
        XCTAssertTrue(pdfAttachment.shouldProcess)
    }

    func testGmailAttachmentIsImage() {
        // Arrange
        let imageAttachment = GmailAttachment(
            id: "test456",
            filename: "receipt.jpg",
            mimeType: "image/jpeg",
            size: 100000
        )

        // Assert
        XCTAssertFalse(imageAttachment.isPDF)
        XCTAssertTrue(imageAttachment.isImage)
        XCTAssertTrue(imageAttachment.shouldProcess)
    }

    // MARK: - Attachment Caching Tests

    func testCacheSmallAttachment() {
        // Arrange
        let testData = Data("Test PDF content".utf8)
        let messageId = "msg123"
        let filename = "test.pdf"

        // Act
        cacheService.cacheAttachment(testData, for: messageId, filename: filename)
        let cachedData = cacheService.getCachedAttachment(for: messageId, filename: filename)

        // Assert
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, testData)
    }

    func testCacheLargeAttachment() {
        // Arrange: Create data larger than 1MB
        let largeData = Data(repeating: 0xFF, count: 2_000_000)  // 2MB
        let messageId = "msg456"
        let filename = "large.pdf"

        // Act
        cacheService.cacheAttachment(largeData, for: messageId, filename: filename)
        let cachedData = cacheService.getCachedAttachment(for: messageId, filename: filename)

        // Assert
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData?.count, largeData.count)
    }

    func testGetCachedAttachmentReturnsNilIfNotCached() {
        // Act
        let cachedData = cacheService.getCachedAttachment(for: "nonexistent", filename: "none.pdf")

        // Assert
        XCTAssertNil(cachedData)
    }

    func testClearOldAttachments() {
        // Arrange
        let testData = Data("Test".utf8)
        cacheService.cacheAttachment(testData, for: "msg1", filename: "file1.pdf")
        cacheService.cacheAttachment(testData, for: "msg2", filename: "file2.pdf")

        // Act
        cacheService.clearOldAttachments(maxAge: 0)  // Clear all

        // Assert
        XCTAssertNil(cacheService.getCachedAttachment(for: "msg1", filename: "file1.pdf"))
        XCTAssertNil(cacheService.getCachedAttachment(for: "msg2", filename: "file2.pdf"))
    }

    // MARK: - Base64URL Decoding Tests

    func testBase64URLDecoding() {
        // Arrange: Gmail uses base64url encoding (- instead of +, _ instead of /)
        let base64urlString = "SGVsbG8gV29ybGQh"  // "Hello World!" in base64url

        // Act
        let decodedData = Data(base64urlEncoded: base64urlString)
        let decodedString = decodedData.flatMap { String(data: $0, encoding: .utf8) }

        // Assert
        XCTAssertNotNil(decodedData)
        XCTAssertEqual(decodedString, "Hello World!")
    }

    func testBase64URLDecodingWithSpecialChars() {
        // Arrange: Test with characters that differ between base64 and base64url
        let testString = "Test with special chars: +/="
        let standardBase64 = testString.data(using: .utf8)!.base64EncodedString()

        // Convert to base64url format
        let base64url = standardBase64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        // Act
        let decodedData = Data(base64urlEncoded: base64url)
        let decodedString = decodedData.flatMap { String(data: $0, encoding: .utf8) }

        // Assert
        XCTAssertEqual(decodedString, testString)
    }
}
