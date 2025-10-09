import Foundation

/// Extension for GmailViewModel filter persistence
/// BLUEPRINT REQUIREMENT: Gmail filtering system with filter persistence
extension GmailViewModel {

    /// Save current filter state to UserDefaults
    func saveFilterState() {
        UserDefaults.standard.set(searchText, forKey: "GmailFilter_searchText")
        UserDefaults.standard.set(merchantFilter, forKey: "GmailFilter_merchantFilter")
        UserDefaults.standard.set(categoryFilter, forKey: "GmailFilter_categoryFilter")
    }

    /// Load filter state from UserDefaults
    func loadFilterState() {
        searchText = UserDefaults.standard.string(forKey: "GmailFilter_searchText") ?? ""
        merchantFilter = UserDefaults.standard.string(forKey: "GmailFilter_merchantFilter")
        categoryFilter = UserDefaults.standard.string(forKey: "GmailFilter_categoryFilter")
    }
}