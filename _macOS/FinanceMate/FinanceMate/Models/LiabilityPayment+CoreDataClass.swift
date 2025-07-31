import Foundation
import CoreData

@objc(LiabilityPayment)
public class LiabilityPayment: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// Amount formatted as currency
    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Date formatted as string
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Factory Methods
    
    /// Create a new LiabilityPayment
    @discardableResult
    public static func create(
        in context: NSManagedObjectContext,
        amount: Double,
        date: Date,
        liability: Liability
    ) -> LiabilityPayment {
        let payment = LiabilityPayment(context: context)
        payment.id = UUID()
        payment.amount = amount
        payment.date = date
        payment.liability = liability
        return payment
    }
    
    // MARK: - Fetch Requests
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LiabilityPayment> {
        return NSFetchRequest<LiabilityPayment>(entityName: "LiabilityPayment")
    }
}

extension LiabilityPayment {
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var date: Date
    @NSManaged public var liability: Liability
}