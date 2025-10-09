import Foundation

/*
 * Purpose: Service for managing tax categories in split allocations
 * Issues & Complexity Summary: Handles predefined Australian tax categories, custom categories, and category management
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~40
 *   - Core Algorithm Complexity: Low (Category management and validation)
 *   - Dependencies: Foundation only
 *   - State Management Complexity: Low (Stateless service)
 *   - Novelty/Uncertainty Factor: Low (Standard category management patterns)
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 25%
 * Problem Estimate (Inherent Problem Difficulty %): 30%
 * Initial Code Complexity Estimate %: 25%
 * Justification for Estimates: Simple category management with predefined Australian tax categories
 * Final Code Complexity (Actual %): TBD
 * Overall Result Score (Success & Quality %): TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-10-04
 */

/// Service responsible for managing tax categories for split allocations
final class SplitAllocationTaxCategoryService {

    // MARK: - Predefined Categories

    /// Predefined Australian tax categories
    static let predefinedCategories: [String] = [
        "Business",
        "Personal",
        "Investment",
        "Charity",
        "Education",
        "Medical",
        "Travel",
        "Entertainment",
        "Depreciation",
        "Research & Development",
    ]

    // MARK: - Public Methods

    /// Returns the default Australian tax categories as required by BLUEPRINT
    /// - Returns: Array containing the three default tax categories
    func getDefaultTaxCategories() -> [String] {
        return ["Personal", "Business", "Investment"]
    }

    /// Returns all available tax categories (predefined + custom)
    /// - Parameter customCategories: Array of custom categories
    /// - Returns: Combined and sorted list of available categories
    func getAllAvailableCategories(customCategories: [String]) -> [String] {
        return Self.predefinedCategories + customCategories.sorted()
    }

    /// Returns a consistent color for a given tax category
    /// - Parameter category: The tax category name
    /// - Returns: Color string for the category
    func getColorForTaxCategory(_ category: String) -> String {
        // Use a hash-based approach to ensure consistent colors
        let colors = [
            "Business": "#007AFF",        // Blue
            "Personal": "#34C759",        // Green
            "Investment": "#FF9500",      // Orange
            "Charity": "#FF3B30",         // Red
            "Education": "#AF52DE",       // Purple
            "Medical": "#FF2D92",         // Pink
            "Travel": "#00C7BE",          // Teal
            "Entertainment": "#FFCC00",   // Yellow
            "Depreciation": "#8E8E93",    // Gray
            "Research & Development": "#5856D6" // Indigo
        ]

        // Return predefined color if available, otherwise generate based on hash
        if let predefinedColor = colors[category] {
            return predefinedColor
        }

        // Generate consistent color for custom categories
        let hash = category.hashValue
        let hue = abs(hash) % 360
        return String(format: "#%02X%02X%02X",
                      hueColorComponents(for: hue, saturation: 0.7, brightness: 0.8))
    }

    /// Creates a custom tax category with default color
    /// - Parameter categoryName: Name of the custom category
    /// - Returns: Color string for the new category
    func createCustomTaxCategory(_ categoryName: String) -> String {
        // Validate category name
        guard isValidCategoryName(categoryName) else {
            return ""
        }

        // Return color for the new category
        return getColorForTaxCategory(categoryName)
    }

    // MARK: - Private Helper Methods

    /// Validates if a tax category name is acceptable
    /// - Parameter categoryName: Name to validate
    /// - Returns: True if valid, false otherwise
    private func isValidCategoryName(_ categoryName: String) -> Bool {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 50
    }

    /// Converts HSB color values to RGB hex string
    /// - Parameters:
    ///   - hue: Hue value (0-360)
    ///   - saturation: Saturation value (0.0-1.0)
    ///   - brightness: Brightness value (0.0-1.0)
    /// - Returns: RGB hex string
    private func hueColorComponents(for hue: Int, saturation: Double, brightness: Double) -> (Int, Int, Int) {
        let c = brightness * saturation
        let x = c * (1 - abs(((Double(hue) / 60.0).truncatingRemainder(dividingBy: 2)) - 1))
        let m = brightness - c

        let (r, g, b): (Double, Double, Double)
        switch hue {
        case 0..<60:
            (r, g, b) = (c, x, 0)
        case 60..<120:
            (r, g, b) = (x, c, 0)
        case 120..<180:
            (r, g, b) = (0, c, x)
        case 180..<240:
            (r, g, b) = (0, x, c)
        case 240..<300:
            (r, g, b) = (x, 0, c)
        default:
            (r, g, b) = (c, 0, x)
        }

        let red = Int((r + m) * 255)
        let green = Int((g + m) * 255)
        let blue = Int((b + m) * 255)

        return (red, green, blue)
    }

    /// Validates if a tax category name is acceptable
    /// - Parameter categoryName: The category name to validate
    /// - Returns: True if valid, false otherwise
    func isValidCategoryName(_ categoryName: String) -> Bool {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 2 && trimmed.count <= 50
    }

    /// Validates if a category already exists
    /// - Parameters:
    ///   - categoryName: The category name to check
    ///   - customCategories: Existing custom categories
    /// - Returns: True if category exists, false otherwise
    func categoryExists(_ categoryName: String, in customCategories: [String]) -> Bool {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        return Self.predefinedCategories.contains(trimmed) || customCategories.contains(trimmed)
    }

    /// Prepares a new category name by trimming and validating
    /// - Parameter categoryName: Raw category name input
    /// - Returns: Clean category name or nil if invalid
    func prepareCategoryName(_ categoryName: String) -> String? {
        let trimmed = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        return isValidCategoryName(trimmed) ? trimmed : nil
    }

    /// Adds a custom category if valid and not duplicate
    /// - Parameters:
    ///   - categoryName: New category name to add
    ///   - customCategories: Existing custom categories array
    /// - Returns: Result with updated categories or error
    func addCustomCategory(_ categoryName: String, to customCategories: [String]) -> CategoryResult {
        guard let cleanName = prepareCategoryName(categoryName) else {
            return .error("Category name must be 2-50 characters and not be empty")
        }

        guard !categoryExists(cleanName, in: customCategories) else {
            return .error("Category '\(cleanName)' already exists")
        }

        var updatedCategories = customCategories
        updatedCategories.append(cleanName)
        return .success(updatedCategories)
    }

    /// Removes a custom category if it exists and is not a predefined category
    /// - Parameters:
    ///   - categoryName: Category name to remove
    ///   - customCategories: Existing custom categories array
    /// - Returns: Result with updated categories or error
    func removeCustomCategory(_ categoryName: String, from customCategories: [String]) -> CategoryResult {
        let cleanName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanName.isEmpty else {
            return .error("Category name cannot be empty")
        }

        guard !Self.predefinedCategories.contains(cleanName) else {
            return .error("Cannot remove predefined category '\(cleanName)'")
        }

        guard let index = customCategories.firstIndex(of: cleanName) else {
            return .error("Category '\(cleanName)' not found in custom categories")
        }

        var updatedCategories = customCategories
        updatedCategories.remove(at: index)
        return .success(updatedCategories)
    }
}

// MARK: - Supporting Types

extension SplitAllocationTaxCategoryService {

    /// Result type for category operations
    enum CategoryResult {
        case success([String])
        case error(String)

        var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .error:
                return false
            }
        }

        var categories: [String]? {
            switch self {
            case .success(let categories):
                return categories
            case .error:
                return nil
            }
        }

        var errorMessage: String? {
            switch self {
            case .success:
                return nil
            case .error(let message):
                return message
            }
        }
    }
}