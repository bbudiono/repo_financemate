// DocumentMetadataManager.swift
// Purpose: Document metadata extraction and management
// Part of unified Manager architecture for FinanceMate

import CoreGraphics
import Foundation
import ImageIO
import PDFKit

@MainActor
class DocumentMetadataManager: ObservableObject {
    @Published var extractedMetadata: [URL: DocumentMetadata] = [:]
    @Published var isExtracting = false

    // MARK: - Metadata Extraction

    func extractMetadata(from url: URL) async throws -> DocumentMetadata {
        isExtracting = true
        defer { isExtracting = false }

        let fileManager = FileManager.default
        let fileName = url.lastPathComponent
        let fileExtension = url.pathExtension.lowercased()

        // Get basic file attributes
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        let creationDate = attributes[.creationDate] as? Date
        let modificationDate = attributes[.modificationDate] as? Date

        // Extract type-specific metadata
        var pageCount: Int?
        var imageMetadata: ImageMetadata?
        var documentProperties: [String: Any] = [:]

        switch fileExtension {
        case "pdf":
            (pageCount, documentProperties) = try await extractPDFMetadata(from: url)
        case "jpg", "jpeg", "png", "tiff", "heic":
            imageMetadata = try await extractImageMetadata(from: url)
        default:
            break
        }

        let metadata = DocumentMetadata(
            fileName: fileName,
            fileSize: fileSize,
            fileType: fileExtension,
            creationDate: creationDate,
            modificationDate: modificationDate,
            pageCount: pageCount,
            imageMetadata: imageMetadata,
            documentProperties: documentProperties
        )

        extractedMetadata[url] = metadata
        return metadata
    }

    func getMetadata(for url: URL) -> DocumentMetadata? {
        extractedMetadata[url]
    }

    func clearMetadataCache() {
        extractedMetadata.removeAll()
    }

    // MARK: - Private Extraction Methods

    private func extractPDFMetadata(from url: URL) async throws -> (pageCount: Int?, properties: [String: Any]) {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw MetadataExtractionError.cannotOpenPDF
        }

        let pageCount = pdfDocument.pageCount

        // Extract document properties
        var properties: [String: Any] = [:]

        if let title = pdfDocument.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
            properties["title"] = title
        }

        if let author = pdfDocument.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String {
            properties["author"] = author
        }

        if let creator = pdfDocument.documentAttributes?[PDFDocumentAttribute.creatorAttribute] as? String {
            properties["creator"] = creator
        }

        if let producer = pdfDocument.documentAttributes?[PDFDocumentAttribute.producerAttribute] as? String {
            properties["producer"] = producer
        }

        if let creationDate = pdfDocument.documentAttributes?[PDFDocumentAttribute.creationDateAttribute] as? Date {
            properties["creationDate"] = creationDate
        }

        if let modificationDate = pdfDocument.documentAttributes?[PDFDocumentAttribute.modificationDateAttribute] as? Date {
            properties["modificationDate"] = modificationDate
        }

        if let subject = pdfDocument.documentAttributes?[PDFDocumentAttribute.subjectAttribute] as? String {
            properties["subject"] = subject
        }

        if let keywords = pdfDocument.documentAttributes?[PDFDocumentAttribute.keywordsAttribute] as? [String] {
            properties["keywords"] = keywords
        }

        // Extract security information
        properties["isEncrypted"] = pdfDocument.isEncrypted
        properties["isLocked"] = pdfDocument.isLocked
        properties["allowsPrinting"] = pdfDocument.allowsPrinting
        properties["allowsCopying"] = pdfDocument.allowsCopying

        return (pageCount, properties)
    }

    private func extractImageMetadata(from url: URL) async throws -> ImageMetadata {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw MetadataExtractionError.cannotOpenImage
        }

        let count = CGImageSourceGetCount(imageSource)
        guard !isEmpty else {
            throw MetadataExtractionError.emptyImage
        }

        // Get image properties
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            throw MetadataExtractionError.cannotReadImageProperties
        }

        // Extract basic image information
        let pixelWidth = imageProperties[kCGImagePropertyPixelWidth as String] as? Int
        let pixelHeight = imageProperties[kCGImagePropertyPixelHeight as String] as? Int
        let colorModel = imageProperties[kCGImagePropertyColorModel as String] as? String
        let depth = imageProperties[kCGImagePropertyDepth as String] as? Int
        let dpiWidth = imageProperties[kCGImagePropertyDPIWidth as String] as? Double
        let dpiHeight = imageProperties[kCGImagePropertyDPIHeight as String] as? Double
        let hasAlpha = imageProperties[kCGImagePropertyHasAlpha as String] as? Bool

        // Extract EXIF data
        var exifData: [String: Any]?
        if let exif = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            exifData = exif
        }

        // Extract TIFF data
        var tiffData: [String: Any]?
        if let tiff = imageProperties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            tiffData = tiff
        }

        // Extract GPS data
        var gpsData: [String: Any]?
        if let gps = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            gpsData = gps
        }

        return ImageMetadata(
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            colorModel: colorModel,
            depth: depth,
            dpiWidth: dpiWidth,
            dpiHeight: dpiHeight,
            hasAlpha: hasAlpha,
            exifData: exifData,
            tiffData: tiffData,
            gpsData: gpsData
        )
    }
}

// MARK: - Enhanced Data Models

struct DocumentMetadata: Codable {
    let fileName: String
    let fileSize: Int64
    let fileType: String
    let creationDate: Date?
    let modificationDate: Date?
    let pageCount: Int?
    let imageMetadata: ImageMetadata?
    let documentProperties: [String: AnyCodable]

    init(fileName: String, fileSize: Int64, fileType: String, creationDate: Date?, modificationDate: Date?, pageCount: Int?, imageMetadata: ImageMetadata? = nil, documentProperties: [String: Any] = [:]) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileType = fileType
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.pageCount = pageCount
        self.imageMetadata = imageMetadata
        self.documentProperties = documentProperties.mapValues { AnyCodable($0) }
    }

    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var isImage: Bool {
        ["jpg", "jpeg", "png", "tiff", "heic"].contains(fileType.lowercased())
    }

    var isPDF: Bool {
        fileType.lowercased() == "pdf"
    }
}

struct ImageMetadata: Codable {
    let pixelWidth: Int?
    let pixelHeight: Int?
    let colorModel: String?
    let depth: Int?
    let dpiWidth: Double?
    let dpiHeight: Double?
    let hasAlpha: Bool?
    let exifData: [String: AnyCodable]?
    let tiffData: [String: AnyCodable]?
    let gpsData: [String: AnyCodable]?

    init(pixelWidth: Int?, pixelHeight: Int?, colorModel: String?, depth: Int?, dpiWidth: Double?, dpiHeight: Double?, hasAlpha: Bool?, exifData: [String: Any]?, tiffData: [String: Any]?, gpsData: [String: Any]?) {
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.colorModel = colorModel
        self.depth = depth
        self.dpiWidth = dpiWidth
        self.dpiHeight = dpiHeight
        self.hasAlpha = hasAlpha
        self.exifData = exifData?.mapValues { AnyCodable($0) }
        self.tiffData = tiffData?.mapValues { AnyCodable($0) }
        self.gpsData = gpsData?.mapValues { AnyCodable($0) }
    }

    var resolutionDescription: String {
        guard let width = pixelWidth, let height = pixelHeight else {
            return "Unknown resolution"
        }
        return "\(width) × \(height) pixels"
    }

    var dpiDescription: String {
        guard let dpiWidth = dpiWidth, let dpiHeight = dpiHeight else {
            return "Unknown DPI"
        }
        if dpiWidth == dpiHeight {
            return "\(Int(dpiWidth)) DPI"
        } else {
            return "\(Int(dpiWidth)) × \(Int(dpiHeight)) DPI"
        }
    }
}

// Helper for encoding/decoding Any values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Cannot encode AnyCodable"))
        }
    }
}

enum MetadataExtractionError: LocalizedError {
    case cannotOpenPDF
    case cannotOpenImage
    case emptyImage
    case cannotReadImageProperties

    var errorDescription: String? {
        switch self {
        case .cannotOpenPDF:
            return "Cannot open PDF document"
        case .cannotOpenImage:
            return "Cannot open image file"
        case .emptyImage:
            return "Image file contains no data"
        case .cannotReadImageProperties:
            return "Cannot read image properties"
        }
    }
}
