// SANDBOX FILE: For testing/development. See .cursorrules.
/*
* Purpose: Category Core Data model class for expense and document classification
* Issues & Complexity Summary: Category entity with hierarchical structure, validation, and visual customization
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~180
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (CoreData, Foundation, UI color handling)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 70%
* Problem Estimate (Inherent Problem Difficulty %): 65%
* Initial Code Complexity Estimate %: 68%
* Justification for Estimates: Standard categorization with hierarchical relationships
* Final Code Complexity (Actual %): TBD
* Overall Result Score (Success & Quality %): TBD
* Key Variances/Learnings: TBD
* Last Updated: 2025-06-03
*/

import CoreData
import Foundation

/// Category entity representing classification system for documents and expenses
/// Manages hierarchical structure, visual customization, and business logic
@objc(Category)
public class Category: NSManagedObject {
    // MARK: - Convenience Initializer

    /// Creates a new Category with required properties
    /// - Parameters:
    ///   - context: The managed object context
    ///   - name: Name of the category
    ///   - colorHex: Hex color code for visual representation
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        colorHex: String = "#007AFF"
    ) {
        self.init(context: context)

        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.dateCreated = Date()
        self.dateModified = Date()
        self.isActive = true
        self.isDefault = false
        self.sortOrder = 0
    }

    // MARK: - Computed Properties

    /// Computed property for display name
    public var displayName: String {
        name ?? "Unknown Category"
    }

    /// Computed property for full category path (includes parent categories)
    public var fullCategoryPath: String {
        var pathComponents: [String] = []
        var currentCategory: Category? = self

        while let category = currentCategory {
            if let name = category.name {
                pathComponents.insert(name, at: 0)
            }
            currentCategory = category.parentCategory
        }

        return pathComponents.joined(separator: " > ")
    }

    /// Computed property for category depth in hierarchy
    public var hierarchyDepth: Int {
        var depth = 0
        var currentCategory = parentCategory

        while currentCategory != nil {
            depth += 1
            currentCategory = currentCategory?.parentCategory
        }

        return depth
    }

    /// Computed property for document count in this category
    public var documentCount: Int {
        documents?.count ?? 0
    }

    /// Computed property for total document count including subcategories
    public var totalDocumentCount: Int {
        var count = documentCount

        if let subcategories = subcategories?.allObjects as? [Category] {
            for subcategory in subcategories {
                count += subcategory.totalDocumentCount
            }
        }

        return count
    }

    /// Computed property to check if category has subcategories
    public var hasSubcategories: Bool {
        (subcategories?.count ?? 0) > 0
    }

    /// Computed property to check if this is a root category
    public var isRootCategory: Bool {
        parentCategory == nil
    }

    /// Computed property for color validation
    public var hasValidColor: Bool {
        guard let colorHex = colorHex else { return false }
        return Category.isValidHexColor(colorHex)
    }

    // MARK: - Business Logic Methods

    /// Updates the category's active status
    /// - Parameter active: New active status
    public func updateActiveStatus(_ active: Bool) {
        isActive = active
        dateModified = Date()

        // If deactivating, also deactivate all subcategories
        if !active, let subcategories = subcategories?.allObjects as? [Category] {
            for subcategory in subcategories {
                subcategory.updateActiveStatus(false)
            }
        }
    }

    /// Updates the category's sort order
    /// - Parameter order: New sort order
    public func updateSortOrder(_ order: Int32) {
        sortOrder = order
        dateModified = Date()
    }

    /// Sets this category as default (and removes default status from others)
    public func setAsDefault() {
        isDefault = true
        dateModified = Date()

        // Remove default status from sibling categories
        if let parent = parentCategory {
            if let siblings = parent.subcategories?.allObjects as? [Category] {
                for sibling in siblings {
                    if sibling != self && sibling.isDefault {
                        sibling.isDefault = false
                        sibling.dateModified = Date()
                    }
                }
            }
        } else {
            // Remove default status from other root categories
            // This would need to be handled at the context level
        }
    }

    /// Adds a subcategory to this category
    /// - Parameter subcategory: The subcategory to add
    public func addSubcategory(_ subcategory: Category) {
        subcategory.parentCategory = self
        addToSubcategories(subcategory)
        dateModified = Date()
    }

    /// Removes a subcategory from this category
    /// - Parameter subcategory: The subcategory to remove
    public func removeSubcategory(_ subcategory: Category) {
        subcategory.parentCategory = nil
        removeFromSubcategories(subcategory)
        dateModified = Date()
    }

    /// Gets all ancestor categories (parent, grandparent, etc.)
    /// - Returns: Array of ancestor categories from immediate parent to root
    public func getAncestors() -> [Category] {
        var ancestors: [Category] = []
        var currentCategory = parentCategory

        while let category = currentCategory {
            ancestors.append(category)
            currentCategory = category.parentCategory
        }

        return ancestors
    }

    /// Gets all descendant categories (children, grandchildren, etc.)
    /// - Returns: Array of all descendant categories
    public func getDescendants() -> [Category] {
        var descendants: [Category] = []

        if let subcategories = subcategories?.allObjects as? [Category] {
            for subcategory in subcategories {
                descendants.append(subcategory)
                descendants.append(contentsOf: subcategory.getDescendants())
            }
        }

        return descendants
    }

    /// Validates hex color format
    /// - Parameter hexColor: Hex color string to validate
    /// - Returns: True if valid hex color format
    public static func isValidHexColor(_ hexColor: String) -> Bool {
        let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let hexPredicate = NSPredicate(format: "SELF MATCHES %@", hexPattern)
        return hexPredicate.evaluate(with: hexColor)
    }

    /// Creates a summary dictionary of the category information
    /// - Returns: Dictionary containing key category information
    public func createSummary() -> [String: Any] {
        var summary: [String: Any] = [:]

        summary["id"] = id?.uuidString
        summary["name"] = name
        summary["fullPath"] = fullCategoryPath
        summary["colorHex"] = colorHex
        summary["iconName"] = iconName
        summary["isActive"] = isActive
        summary["isDefault"] = isDefault
        summary["isRootCategory"] = isRootCategory
        summary["hierarchyDepth"] = hierarchyDepth
        summary["documentCount"] = documentCount
        summary["totalDocumentCount"] = totalDocumentCount
        summary["hasSubcategories"] = hasSubcategories
        summary["dateCreated"] = dateCreated
        summary["sortOrder"] = sortOrder

        if let parentCategory = parentCategory {
            summary["parentCategoryName"] = parentCategory.name
        }

        return summary
    }

    /// Validates category properties before saving
    /// - Throws: ValidationError if validation fails
    public func validateForSave() throws {
        // Validate required fields
        guard let name = name, !name.isEmpty else {
            throw ValidationError.missingRequiredField("name")
        }

        // Validate name length
        guard name.count <= 50 else {
            throw ValidationError.invalidValue("name", "Name must be 50 characters or less")
        }

        // Validate color format if provided
        if let colorHex = colorHex, !colorHex.isEmpty {
            guard Category.isValidHexColor(colorHex) else {
                throw ValidationError.invalidValue("colorHex", colorHex)
            }
        }

        // Validate that category doesn't create circular reference
        if let parentCategory = parentCategory {
            var currentParent: Category? = parentCategory
            while currentParent != nil {
                if currentParent == self {
                    throw ValidationError.invalidValue("parentCategory", "Circular reference detected")
                }
                currentParent = currentParent?.parentCategory
            }
        }

        // Validate sort order is reasonable
        guard sortOrder >= 0 && sortOrder <= 9999 else {
            throw ValidationError.invalidValue("sortOrder", "Sort order must be between 0 and 9999")
        }
    }
}

// MARK: - Core Data Validation

extension Category {
    override public func validateForInsert() throws {
        try super.validateForInsert()
        try validateForSave()
    }

    override public func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateForSave()
    }

    override public func willSave() {
        super.willSave()

        // Automatically update dateModified when any property changes
        if isUpdated && !isDeleted {
            dateModified = Date()
        }

        // Ensure color hex starts with # if provided
        if let colorHex = colorHex, !colorHex.isEmpty && !colorHex.hasPrefix("#") {
            self.colorHex = "#" + colorHex
        }
    }
}
