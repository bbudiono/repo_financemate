import Foundation

/// Simple persistence for Gmail filter state
/// BLUEPRINT REQUIREMENT: Gmail filtering system with filter persistence
class GmailFilterPersistenceService {

    private let filterStateKey = "GmailFilterState"

    /// Save filter state to UserDefaults
    func saveFilterState(state: FilterState) {
        let data: [String: Any] = [
            "searchText": state.searchText,
            "dateFilter": state.dateFilter.rawValue,
            "merchantFilter": state.merchantFilter as Any,
            "categoryFilter": state.categoryFilter as Any,
            "confidenceFilter": state.confidenceFilter.rawValue
        ]
        UserDefaults.standard.set(data, forKey: filterStateKey)
    }

    /// Load filter state from UserDefaults
    func loadFilterState() -> FilterState? {
        guard let data = UserDefaults.standard.dictionary(forKey: filterStateKey) else {
            return nil
        }
        return FilterState(
            searchText: data["searchText"] as? String ?? "",
            dateFilter: DateFilter(rawValue: data["dateFilter"] as? String ?? "allTime") ?? .allTime,
            merchantFilter: data["merchantFilter"] as? String,
            categoryFilter: data["categoryFilter"] as? String,
            amountFilter: .any,
            confidenceFilter: ConfidenceFilter(rawValue: data["confidenceFilter"] as? String ?? "any") ?? .any
        )
    }
}

/// Filter state model
struct FilterState {
    let searchText: String
    let dateFilter: DateFilter
    let merchantFilter: String?
    let categoryFilter: String?
    let amountFilter: AmountFilter
    let confidenceFilter: ConfidenceFilter
}