// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Document Core Data model class for financial document management
* Issues & Complexity Summary: Document entity with file metadata, processing status, and relationships
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (CoreData, Foundation, UniformTypeIdentifiers)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 73%
* Justification for Estimates: Standard Core Data entity with business logic validation
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData
import UniformTypeIdentifiers

/// Document entity representing financial documents in the system
/// Manages file metadata, processing status, and relationships to financial data
@objc(Document)
public class Document: NSManagedObject {
    
    // MARK: - Convenience Initializer
    
    /// Creates a new Document with required properties
    /// - Parameters:
    ///   - context: The managed object context
    ///   - fileName: Name of the file
    ///   - filePath: Full path to the file
    ///   - documentType: Type of document (invoice, receipt, etc.)
    convenience init(
        context: NSManagedObjectContext,
        fileName: String,
        filePath: String,
        documentType: DocumentType
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.fileName = fileName
        self.filePath = filePath
        self.documentType = documentType.rawValue
        self.dateCreated = Date()
        self.dateModified = Date()
        self.processingStatus = ProcessingStatus.pending.rawValue
        
        // Set MIME type based on file extension
        self.mimeType = self.determineMimeType(for: fileName)
    }
    
    // MARK: - Computed Properties
    
    /// Computed property for document type enum
    public var documentTypeEnum: DocumentType {
        get {
            return DocumentType(rawValue: documentType ?? "") ?? .other
        }
        set {
            documentType = newValue.rawValue
        }
    }
    
    /// Computed property for processing status enum
    public var processingStatusEnum: ProcessingStatus {
        get {
            return ProcessingStatus(rawValue: processingStatus ?? "") ?? .pending
        }
        set {
            processingStatus = newValue.rawValue
        }
    }
    
    /// Computed property for file extension
    public var fileExtension: String {
        return URL(fileURLWithPath: fileName ?? "").pathExtension.lowercased()
    }
    
    /// Computed property to check if document is an image
    public var isImageDocument: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic"]
        return imageExtensions.contains(fileExtension)
    }
    
    /// Computed property to check if document is a PDF
    public var isPDFDocument: Bool {
        return fileExtension == "pdf"
    }
    
    /// Computed property for display name
    public var displayName: String {
        return fileName ?? "Unknown Document"
    }
    
    /// Computed property for file size in human-readable format
    public var fileSizeFormatted: String {
        let fileSize = self.fileSize
        
        if fileSize < 1024 {
            return "\(fileSize) B"
        } else if fileSize < 1024 * 1024 {
            return String(format: "%.1f KB", Double(fileSize) / 1024.0)
        } else if fileSize < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(fileSize) / (1024.0 * 1024.0))
        } else {
            return String(format: "%.1f GB", Double(fileSize) / (1024.0 * 1024.0 * 1024.0))
        }
    }
    
    // MARK: - Business Logic Methods
    
    /// Updates the document's processing status
    /// - Parameter status: New processing status
    public func updateProcessingStatus(_ status: ProcessingStatus) {
        processingStatusEnum = status
        dateModified = Date()
    }
    
    /// Marks the document as processed with financial data
    /// - Parameter data: Associated financial data
    public func markAsProcessed(with data: FinancialData) {
        financialData = data
        data.document = self
        updateProcessingStatus(.completed)
    }
    
    /// Marks the document as requiring manual review
    /// - Parameter reason: Reason for manual review
    public func markForReview(reason: String? = nil) {
        updateProcessingStatus(.requiresReview)
        if let reason = reason {
            notes = (notes ?? "") + "\nRequires review: \(reason)"
        }
    }
    
    /// Determines MIME type based on file extension
    /// - Parameter fileName: Name of the file
    /// - Returns: MIME type string
    private func determineMimeType(for fileName: String) -> String {
        let pathExtension = URL(fileURLWithPath: fileName).pathExtension
        
        if let utType = UTType(filenameExtension: pathExtension) {
            return utType.preferredMIMEType ?? "application/octet-stream"
        }
        
        // Fallback for common types
        switch pathExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        default:
            return "application/octet-stream"
        }
    }
    
    /// Validates document properties before saving
    /// - Throws: ValidationError if validation fails
    public func validateForSave() throws {
        // Validate required fields
        guard let fileName = fileName, !fileName.isEmpty else {
            throw ValidationError.missingRequiredField("fileName")
        }
        
        guard let filePath = filePath, !filePath.isEmpty else {
            throw ValidationError.missingRequiredField("filePath")
        }
        
        guard let documentType = documentType, !documentType.isEmpty else {
            throw ValidationError.missingRequiredField("documentType")
        }
        
        guard let processingStatus = processingStatus, !processingStatus.isEmpty else {
            throw ValidationError.missingRequiredField("processingStatus")
        }
        
        // Validate document type is valid
        guard DocumentType(rawValue: documentType) != nil else {
            throw ValidationError.invalidValue("documentType", documentType)
        }
        
        // Validate processing status is valid
        guard ProcessingStatus(rawValue: processingStatus) != nil else {
            throw ValidationError.invalidValue("processingStatus", processingStatus)
        }
        
        // Validate file size is reasonable (max 100MB)
        guard fileSize <= 100 * 1024 * 1024 else {
            throw ValidationError.invalidValue("fileSize", "File size exceeds 100MB limit")
        }
    }
}

// MARK: - Core Data Validation

extension Document {
    
    public override func validateForInsert() throws {
        try super.validateForInsert()
        try validateForSave()
    }
    
    public override func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateForSave()
    }
    
    public override func willSave() {
        super.willSave()
        
        // Automatically update dateModified when any property changes
        if isUpdated && !isDeleted {
            dateModified = Date()
        }
    }
}

// MARK: - Supporting Types

/// Document type enumeration
public enum DocumentType: String, CaseIterable {
    case invoice = "invoice"
    case receipt = "receipt"
    case bill = "bill"
    case statement = "statement"
    case other = "other"
    
    /// Display name for the document type
    public var displayName: String {
        switch self {
        case .invoice: return "Invoice"
        case .receipt: return "Receipt"
        case .bill: return "Bill"
        case .statement: return "Statement"
        case .other: return "Other"
        }
    }
    
    /// Icon name for the document type
    public var iconName: String {
        switch self {
        case .invoice: return "doc.text"
        case .receipt: return "receipt"
        case .bill: return "doc.circle"
        case .statement: return "doc.plaintext"
        case .other: return "doc"
        }
    }
    
    /// Determine document type from URL file extension
    public static func from(url: URL) -> DocumentType {
        let pathExtension = url.pathExtension.lowercased()
        let fileName = url.lastPathComponent.lowercased()
        
        if fileName.contains("invoice") {
            return .invoice
        } else if fileName.contains("receipt") {
            return .receipt
        } else if fileName.contains("bill") {
            return .bill
        } else if fileName.contains("statement") {
            return .statement
        } else if pathExtension == "pdf" || pathExtension == "jpg" || pathExtension == "jpeg" || pathExtension == "png" {
            return .other
        } else {
            return .other
        }
    }
}

/// Processing status enumeration
public enum ProcessingStatus: String, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case requiresReview = "requires_review"
    
    /// Display name for the processing status
    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .requiresReview: return "Requires Review"
        }
    }
    
    /// Color for status indicator
    public var statusColor: String {
        switch self {
        case .pending: return "#FFA500"      // Orange
        case .processing: return "#007AFF"   // Blue
        case .completed: return "#34C759"    // Green
        case .failed: return "#FF3B30"       // Red
        case .requiresReview: return "#FF9500" // Yellow
        }
    }
}

/// Validation error types
public enum ValidationError: LocalizedError {
    case missingRequiredField(String)
    case invalidValue(String, String)
    
    public var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidValue(let field, let value):
            return "Invalid value for \(field): \(value)"
        }
    }
}