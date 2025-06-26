import CoreData
import Foundation

@objc(BudgetAllocation)
public class BudgetAllocation: NSManagedObject {
    // MARK: - Computed Properties

    public var allocationAmount: Double {
        amount?.doubleValue ?? 0.0
    }

    public var isCurrentAllocation: Bool {
        guard let allocationDate = allocationDate else { return false }
        let calendar = Calendar.current
        return calendar.isDate(allocationDate, inSameDayAs: Date())
    }
}
