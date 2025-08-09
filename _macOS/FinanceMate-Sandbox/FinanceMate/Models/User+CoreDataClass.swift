// SANDBOX FILE: For testing/development. See .cursorrules.

import CoreData
import Foundation

@objc(User)
public class User: NSManagedObject {

  /// Create a new user in the sandbox environment
  static func create(
    in context: NSManagedObjectContext,
    email: String,
    firstName: String? = nil,
    lastName: String? = nil,
    role: UserRole = .owner
  ) -> User {
    let user = User(context: context)
    user.id = UUID()
    user.email = email
    user.firstName = firstName
    user.lastName = lastName
    user.createdAt = Date()
    user.isActive = true

    return user
  }

  /// Fetch user by ID
  static func fetchUser(by id: UUID, in context: NSManagedObjectContext) -> User? {
    let request: NSFetchRequest<User> = User.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1

    return try? context.fetch(request).first
  }
}

/// User roles for sandbox environment
enum UserRole: String, CaseIterable {
  case owner = "owner"
  case contributor = "contributor"
  case viewer = "viewer"
}




