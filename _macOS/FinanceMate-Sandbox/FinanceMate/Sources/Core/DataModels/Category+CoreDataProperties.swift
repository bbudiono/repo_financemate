// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Category Core Data properties extension for attribute and relationship definitions
* Issues & Complexity Summary: Core Data managed object properties and relationships for Category entity
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~100
  - Core Algorithm Complexity: Low
  - Dependencies: 2 New (CoreData, Foundation)
  - State Management Complexity: Low
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Standard Core Data properties definition for category entity
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import CoreData
import Foundation

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        NSFetchRequest<Category>(entityName: "Category")
    }

    // MARK: - Attributes

    /// Unique identifier for the category
    @NSManaged public var id: UUID?

    /// Name of the category
    @NSManaged public var name: String?

    /// Hex color code for visual representation (e.g., "#FF6B6B")
    @NSManaged public var colorHex: String?

    /// Icon name for visual representation
    @NSManaged public var iconName: String?

    /// Whether the category is currently active
    @NSManaged public var isActive: Bool

    /// Whether this is a default category
    @NSManaged public var isDefault: Bool

    /// Sort order for display purposes
    @NSManaged public var sortOrder: Int32

    /// Date when the category was created
    @NSManaged public var dateCreated: Date?

    /// Date when the category was last modified
    @NSManaged public var dateModified: Date?

    /// Description of the category
    @NSManaged public var categoryDescription: String?

    /// Additional notes about the category
    @NSManaged public var notes: String?

    /// JSON string containing additional metadata
    @NSManaged public var metadata: String?

    // MARK: - Relationships

    /// Many-to-one relationship with parent category (for hierarchical structure)
    @NSManaged public var parentCategory: Category?

    /// One-to-many relationship with subcategories
    @NSManaged public var subcategories: NSSet?

    /// One-to-many relationship with documents assigned to this category
    @NSManaged public var documents: NSSet?
}

// MARK: - Generated accessors for to-many relationships

extension Category {
    @objc(addSubcategoriesObject:)
    @NSManaged public func addToSubcategories(_ value: Category)

    @objc(removeSubcategoriesObject:)
    @NSManaged public func removeFromSubcategories(_ value: Category)

    @objc(addSubcategories:)
    @NSManaged public func addToSubcategories(_ values: NSSet)

    @objc(removeSubcategories:)
    @NSManaged public func removeFromSubcategories(_ values: NSSet)

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: Document)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: Document)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)
}

extension Category: Identifiable {
    // Identifiable conformance using the id property
}

// MARK: - Fetch Request Helpers

extension Category {
    /// Fetch request for root categories (no parent)
    /// - Returns: Configured fetch request for root categories
    public static func fetchRootCategories() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "parentCategory == nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
                                 NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for active categories only
    /// - Returns: Configured fetch request for active categories
    public static func fetchActiveCategories() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
                                 NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for default categories
    /// - Returns: Configured fetch request for default categories
    public static func fetchDefaultCategories() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isDefault == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)]
        return request
    }

    /// Fetch request for subcategories of a specific parent
    /// - Parameter parent: Parent category
    /// - Returns: Configured fetch request for subcategories
    public static func fetchSubcategories(of parent: Category) -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "parentCategory == %@", parent)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
                                 NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for categories by color
    /// - Parameter colorHex: Hex color code to filter by
    /// - Returns: Configured fetch request
    public static func fetchRequest(with colorHex: String) -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "colorHex ==[cd] %@", colorHex)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for categories with documents
    /// - Returns: Configured fetch request for categories that have documents
    public static func fetchCategoriesWithDocuments() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "documents.@count > 0")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for empty categories (no documents)
    /// - Returns: Configured fetch request for categories without documents
    public static func fetchEmptyCategories() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "documents.@count == 0")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for categories by hierarchy depth
    /// - Parameter depth: Hierarchy depth (0 = root, 1 = first level, etc.)
    /// - Returns: Configured fetch request
    public static func fetchCategories(atDepth depth: Int) -> NSFetchRequest<Category> {
        let request = fetchRequest()

        if depth == 0 {
            request.predicate = NSPredicate(format: "parentCategory == nil")
        } else {
            // This would require a more complex predicate or post-fetch filtering
            // For now, we'll return all categories and filter in code
            request.predicate = nil
        }

        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch request for recently created categories
    /// - Parameter days: Number of days back to search (default 30)
    /// - Returns: Configured fetch request
    public static func fetchRecentCategories(within days: Int = 30) -> NSFetchRequest<Category> {
        let request = fetchRequest()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        request.predicate = NSPredicate(format: "dateCreated >= %@", cutoffDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.dateCreated, ascending: false)]
        return request
    }

    /// Search categories by name or description
    /// - Parameter searchText: Text to search for
    /// - Returns: Configured fetch request for search results
    public static func searchCategories(containing searchText: String) -> NSFetchRequest<Category> {
        let request = fetchRequest()
        let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@ OR categoryDescription CONTAINS[cd] %@ OR notes CONTAINS[cd] %@",
                                        searchText, searchText, searchText)
        request.predicate = searchPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }

    /// Fetch categories ordered by document count (most used first)
    /// - Returns: Configured fetch request ordered by usage
    public static func fetchCategoriesByUsage() -> NSFetchRequest<Category> {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "documents.@count", ascending: false),
                                 NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }
}
