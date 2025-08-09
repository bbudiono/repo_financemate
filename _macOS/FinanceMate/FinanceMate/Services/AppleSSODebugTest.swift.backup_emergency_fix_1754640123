//
// AppleSSODebugTest.swift
// FinanceMate
//
// Purpose: Debug test for Apple SSO user creation functionality
// Issues & Complexity Summary: Core Data User entity creation and validation
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~100
//   - Core Algorithm Complexity: Medium (Core Data operations)
//   - Dependencies: 3 (CoreData, Foundation, UserRole)
//   - State Management Complexity: Low (test-only)
//   - Novelty/Uncertainty Factor: Low
// AI Pre-Task Self-Assessment: 95%
// Problem Estimate: 95%
// Initial Code Complexity Estimate: 75%
// Final Code Complexity: 75%
// Overall Result Score: 95%
// Key Variances/Learnings: Isolated debug test for Apple SSO Core Data issue
// Last Updated: 2025-08-08

import Foundation
import CoreData

/// Isolated debug test class for Apple SSO user creation functionality
/// This helps verify that User entity creation works correctly in Core Data
public class AppleSSODebugTest {
    
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Test User entity creation with debug logging
    /// Returns detailed results about the Core Data operation
    public func testUserCreation() -> (success: Bool, details: [String]) {
        var details: [String] = []
        
        do {
            details.append("🔍 DEBUG: Starting User entity creation test")
            
            // Check if User entity exists in model
            let entities = context.persistentStoreCoordinator?.managedObjectModel.entities ?? []
            let userEntityExists = entities.contains { $0.name == "User" }
            details.append("📊 DEBUG: User entity exists in model: \(userEntityExists)")
            details.append("📊 DEBUG: Available entities: \(entities.compactMap(\.name))")
            
            if !userEntityExists {
                details.append("❌ CRITICAL: User entity not found in Core Data model")
                return (false, details)
            }
            
            // Test basic User creation
            details.append("🏗️ DEBUG: Creating User entity")
            let testEmail = "debug-test@example.com"
            let testName = "Debug Test User"
            
            let user = User.create(in: context, name: testName, email: testEmail, role: .owner)
            details.append("✅ DEBUG: User entity created with ID: \(user.id)")
            
            // Validate user properties
            details.append("📝 DEBUG: Validating user properties")
            details.append("  - Name: \(user.name)")
            details.append("  - Email: \(user.email)")
            details.append("  - Role: \(user.role)")
            details.append("  - IsActive: \(user.isActive)")
            details.append("  - CreatedAt: \(user.createdAt)")
            
            // Validate user
            let validation = user.validate()
            if validation.isValid {
                details.append("✅ DEBUG: User validation passed")
            } else {
                details.append("❌ DEBUG: User validation failed: \(validation.errors)")
                return (false, details)
            }
            
            // Test Core Data save
            details.append("💾 DEBUG: Attempting to save Core Data context")
            try context.save()
            details.append("✅ DEBUG: Core Data context saved successfully")
            
            // Test user fetch
            details.append("🔍 DEBUG: Testing user fetch by email")
            let fetchedUser = User.fetchUser(by: testEmail, in: context)
            if let fetchedUser = fetchedUser {
                details.append("✅ DEBUG: User fetched successfully: \(fetchedUser.id)")
            } else {
                details.append("❌ DEBUG: Failed to fetch user by email")
                return (false, details)
            }
            
            details.append("🎉 DEBUG: Apple SSO User creation test PASSED")
            return (true, details)
            
        } catch {
            details.append("❌ CRITICAL ERROR in testUserCreation: \(error)")
            details.append("❌ ERROR TYPE: \(type(of: error))")
            details.append("❌ ERROR LOCALIZED: \(error.localizedDescription)")
            
            if let nsError = error as NSError? {
                details.append("❌ NSError Code: \(nsError.code)")
                details.append("❌ NSError Domain: \(nsError.domain)")
                details.append("❌ NSError UserInfo: \(nsError.userInfo)")
            }
            
            return (false, details)
        }
    }
    
    /// Quick test method that can be called from ViewModels
    public static func quickTest(in context: NSManagedObjectContext) -> (success: Bool, message: String) {
        let debugTest = AppleSSODebugTest(context: context)
        let result = debugTest.testUserCreation()
        
        let summary = result.success ? 
            "✅ Apple SSO User creation test PASSED" :
            "❌ Apple SSO User creation test FAILED"
            
        let details = result.details.joined(separator: "\n")
        print("🍎 APPLE SSO DEBUG TEST RESULTS:")
        print(details)
        
        return (result.success, summary)
    }
}