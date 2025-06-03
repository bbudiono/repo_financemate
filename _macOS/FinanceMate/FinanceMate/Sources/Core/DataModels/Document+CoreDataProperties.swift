// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Document Core Data properties extension for attribute and relationship definitions
* Issues & Complexity Summary: Core Data managed object properties and relationships for Document entity
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Standard Core Data properties definition
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import Foundation
import CoreData

extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    // MARK: - Attributes
    
    /// Unique identifier for the document
    @NSManaged public var id: UUID?
    
    /// Name of the file
    @NSManaged public var fileName: String?
    
    /// Full path to the file in the filesystem
    @NSManaged public var filePath: String?
    
    /// Size of the file in bytes
    @NSManaged public var fileSize: Int64
    
    /// MIME type of the file
    @NSManaged public var mimeType: String?
    
    /// Date when the document was created
    @NSManaged public var dateCreated: Date?
    
    /// Date when the document was last modified
    @NSManaged public var dateModified: Date?
    
    /// Type of document (invoice, receipt, bill, statement, other)
    @NSManaged public var documentType: String?
    
    /// Current processing status (pending, processing, completed, failed, requires_review)
    @NSManaged public var processingStatus: String?
    
    /// Additional notes or comments about the document
    @NSManaged public var notes: String?
    
    /// Checksum or hash of the file for integrity verification
    @NSManaged public var fileHash: String?
    
    /// Confidence score from OCR processing (0.0 to 1.0)
    @NSManaged public var ocrConfidence: Double
    
    /// Raw OCR text extracted from the document
    @NSManaged public var rawOCRText: String?
    
    /// JSON string containing additional metadata
    @NSManaged public var metadata: String?
    
    /// Flag indicating if the document has been archived
    @NSManaged public var isArchived: Bool
    
    /// Flag indicating if the document is marked as favorite
    @NSManaged public var isFavorite: Bool
    
    // MARK: - Relationships
    
    /// One-to-one relationship with financial data extracted from this document
    @NSManaged public var financialData: FinancialData?
    
    /// Many-to-one relationship with the client associated with this document
    @NSManaged public var client: Client?
    
    /// Many-to-one relationship with the category for classification
    @NSManaged public var category: Category?
    
    /// Many-to-one relationship with the project this document belongs to
    @NSManaged public var project: Project?
}

// MARK: - Generated accessors for to-many relationships

extension Document : Identifiable {
    // Identifiable conformance using the id property
}

// MARK: - Fetch Request Helpers

extension Document {
    
    /// Fetch request for documents of a specific type
    /// - Parameter documentType: The type of documents to fetch
    /// - Returns: Configured fetch request
    public static func fetchRequest(for documentType: DocumentType) -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "documentType == %@", documentType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for documents with a specific processing status
    /// - Parameter status: The processing status to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(with status: ProcessingStatus) -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "processingStatus == %@", status.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for documents associated with a specific client
    /// - Parameter client: The client to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(for client: Client) -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "client == %@", client)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for documents within a date range
    /// - Parameters:
    ///   - startDate: Start date of the range
    ///   - endDate: End date of the range
    /// - Returns: Configured fetch request
    public static func fetchRequest(from startDate: Date, to endDate: Date) -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "dateCreated >= %@ AND dateCreated <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for archived documents
    /// - Returns: Configured fetch request for archived documents
    public static func fetchArchivedDocuments() -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateModified, ascending: false)]
        return request
    }
    
    /// Fetch request for favorite documents
    /// - Returns: Configured fetch request for favorite documents
    public static func fetchFavoriteDocuments() -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
    
    /// Fetch request for documents that need processing
    /// - Returns: Configured fetch request for documents pending processing
    public static func fetchDocumentsNeedingProcessing() -> NSFetchRequest<Document> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "processingStatus IN %@", [ProcessingStatus.pending.rawValue, ProcessingStatus.requiresReview.rawValue])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: true)]
        return request
    }
    
    /// Search documents by filename or OCR text
    /// - Parameter searchText: Text to search for
    /// - Returns: Configured fetch request for search results
    public static func searchDocuments(containing searchText: String) -> NSFetchRequest<Document> {
        let request = fetchRequest()
        let searchPredicate = NSPredicate(format: "fileName CONTAINS[cd] %@ OR rawOCRText CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", 
                                        searchText, searchText, searchText)
        request.predicate = searchPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateCreated, ascending: false)]
        return request
    }
}