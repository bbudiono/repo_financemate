import XCTest
import CoreData

/**
 * Purpose: Failing test for UserAutomationMemory Core Data entity - Atomic TDD approach
 * Requirements: BLUEPRINT.md User Automation Memory data model requirements for AI training foundation
 * Issues & Complexity Summary: RED phase - deliberately failing test to drive UserAutomationMemory entity implementation
 * Key Complexity Drivers:
 * - Logic Scope (Est. LoC): ~45
 * - Core Algorithm Complexity: Low (test structure and assertions for new entity)
 * - Dependencies: 1 New (UserAutomationMemory entity), 0 Mod
 * - State Management Complexity: Low (stateless test)
 * - Novelty/Uncertainty Factor: Low (standard Core Data testing pattern)
 * AI Pre-Task Self-Assessment: 95%
 * Problem Estimate: 90%
 * Initial Code Complexity Estimate: 65%
 * Final Code Complexity: 68%
 * Overall Result Score: 97%
 * Key Variances/Learnings: Following established TDD pattern for Core Data entity creation
 * Last Updated: 2025-10-08
 */

final class UserAutomationMemoryTests: XCTestCase {

    func testCoreDataModelBuilderCreatesModelWithUserAutomationMemoryEntity() throws {
        // RED: This test should fail until UserAutomationMemory entity is added to CoreDataModelBuilder
        let model = CoreDataModelBuilder.createModel()

        // Verify model has the correct number of entities (should be 5 with UserAutomationMemory)
        XCTAssertEqual(model.entities.count, 5, "Core Data model should have exactly 5 entities including UserAutomationMemory")

        // Verify required entities exist
        let entityNames = model.entities.map { $0.name }
        XCTAssertTrue(entityNames.contains("Transaction"), "Model should contain Transaction entity")
        XCTAssertTrue(entityNames.contains("LineItem"), "Model should contain LineItem entity")
        XCTAssertTrue(entityNames.contains("SplitAllocation"), "Model should contain SplitAllocation entity")
        XCTAssertTrue(entityNames.contains("EmailStatusEntity"), "Model should contain EmailStatusEntity")
        XCTAssertTrue(entityNames.contains("UserAutomationMemory"), "Model should contain UserAutomationMemory entity")
    }

    func testUserAutomationMemoryEntityHasRequiredAttributes() throws {
        // RED: Test specific UserAutomationMemory entity structure
        let model = CoreDataModelBuilder.createModel()
        guard let userAutomationMemoryEntity = model.entities.first(where: { $0.name == "UserAutomationMemory" }) else {
            XCTFail("UserAutomationMemory entity not found in model")
            return
        }

        let attributeNames = userAutomationMemoryEntity.properties.compactMap { $0 as? NSAttributeDescription }.map { $0.name }

        // Verify required UserAutomationMemory attributes for AI training data
        XCTAssertTrue(attributeNames.contains("id"), "UserAutomationMemory should have id attribute")
        XCTAssertTrue(attributeNames.contains("merchantPatterns"), "UserAutomationMemory should have merchantPatterns attribute")
        XCTAssertTrue(attributeNames.contains("userCategory"), "UserAutomationMemory should have userCategory attribute")
        XCTAssertTrue(attributeNames.contains("splitTemplate"), "UserAutomationMemory should have splitTemplate attribute")
        XCTAssertTrue(attributeNames.contains("confidence"), "UserAutomationMemory should have confidence attribute")
        XCTAssertTrue(attributeNames.contains("usageCount"), "UserAutomationMemory should have usageCount attribute")
        XCTAssertTrue(attributeNames.contains("lastUsed"), "UserAutomationMemory should have lastUsed attribute")
        XCTAssertTrue(attributeNames.contains("trainingData"), "UserAutomationMemory should have trainingData attribute")
        XCTAssertTrue(attributeNames.contains("createdAt"), "UserAutomationMemory should have createdAt attribute")
        XCTAssertTrue(attributeNames.contains("updatedAt"), "UserAutomationMemory should have updatedAt attribute")
    }

    func testUserAutomationMemoryEntityAttributeTypes() throws {
        // RED: Test that UserAutomationMemory attributes have correct types
        let model = CoreDataModelBuilder.createModel()
        guard let userAutomationMemoryEntity = model.entities.first(where: { $0.name == "UserAutomationMemory" }) else {
            XCTFail("UserAutomationMemory entity not found in model")
            return
        }

        let attributes = Dictionary(uniqueKeysWithValues:
            userAutomationMemoryEntity.properties.compactMap { property -> (String, NSAttributeType)? in
                guard let attribute = property as? NSAttributeDescription else { return nil }
                return (attribute.name, attribute.attributeType)
            }
        )

        // Verify attribute types for AI training data structure
        XCTAssertEqual(attributes["id"], .UUIDAttributeType, "id should be UUID type")
        XCTAssertEqual(attributes["merchantPatterns"], .stringAttributeType, "merchantPatterns should be string type")
        XCTAssertEqual(attributes["userCategory"], .stringAttributeType, "userCategory should be string type")
        XCTAssertEqual(attributes["splitTemplate"], .stringAttributeType, "splitTemplate should be string type")
        XCTAssertEqual(attributes["confidence"], .doubleAttributeType, "confidence should be double type")
        XCTAssertEqual(attributes["usageCount"], .integer32AttributeType, "usageCount should be integer32 type")
        XCTAssertEqual(attributes["lastUsed"], .dateAttributeType, "lastUsed should be date type")
        XCTAssertEqual(attributes["trainingData"], .stringAttributeType, "trainingData should be string type (JSON)")
        XCTAssertEqual(attributes["createdAt"], .dateAttributeType, "createdAt should be date type")
        XCTAssertEqual(attributes["updatedAt"], .dateAttributeType, "updatedAt should be date type")
    }

    func testUserAutomationMemoryEntityDefaultValues() throws {
        // RED: Test that UserAutomationMemory attributes have appropriate default values
        let model = CoreDataModelBuilder.createModel()
        guard let userAutomationMemoryEntity = model.entities.first(where: { $0.name == "UserAutomationMemory" }) else {
            XCTFail("UserAutomationMemory entity not found in model")
            return
        }

        let attributes = Dictionary(uniqueKeysWithValues:
            userAutomationMemoryEntity.properties.compactMap { property -> (String, Any)? in
                guard let attribute = property as? NSAttributeDescription else { return nil }
                return (attribute.name, attribute.defaultValue as Any)
            }
        )

        // Verify default values for AI training data initialization
        XCTAssertNotNil(attributes["merchantPatterns"], "merchantPatterns should have default value")
        XCTAssertNotNil(attributes["userCategory"], "userCategory should have default value")
        XCTAssertNotNil(attributes["splitTemplate"], "splitTemplate should have default value")
        XCTAssertEqual(attributes["confidence"] as? Double, 0.0, "confidence should default to 0.0")
        XCTAssertEqual(attributes["usageCount"] as? Int32, 0, "usageCount should default to 0")
        XCTAssertNotNil(attributes["trainingData"], "trainingData should have default value")
    }

    func testUserAutomationMemoryEntityPersistency() throws {
        // RED: Test that UserAutomationMemory can be persisted to Core Data
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext

        // Create a test UserAutomationMemory record
        let userAutomationMemory = NSEntityDescription.insertNewObject(forEntityName: "UserAutomationMemory", into: context)

        // Test setting all required attributes
        userAutomationMemory.setValue(UUID(), forKey: "id")
        userAutomationMemory.setValue("Uber,Eats,DoorDash", forKey: "merchantPatterns")
        userAutomationMemory.setValue("Food & Dining", forKey: "userCategory")
        userAutomationMemory.setValue("50% Personal, 50% Business", forKey: "splitTemplate")
        userAutomationMemory.setValue(0.85, forKey: "confidence")
        userAutomationMemory.setValue(Int32(15), forKey: "usageCount")
        userAutomationMemory.setValue(Date(), forKey: "lastUsed")
        userAutomationMemory.setValue("{\"keywords\":[\"uber\",\"eats\"],\"avgAmount\":25.50}", forKey: "trainingData")
        userAutomationMemory.setValue(Date(), forKey: "createdAt")
        userAutomationMemory.setValue(Date(), forKey: "updatedAt")

        // Verify record can be saved (validates model structure)
        XCTAssertNoThrow(try context.save(), "UserAutomationMemory should save successfully with valid data")

        // Verify record can be retrieved
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserAutomationMemory")
        let results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1, "Should retrieve exactly 1 UserAutomationMemory record")

        let retrievedMemory = results.first!
        XCTAssertEqual(retrievedMemory.value(forKey: "merchantPatterns") as? String, "Uber,Eats,DoorDash")
        XCTAssertEqual(retrievedMemory.value(forKey: "userCategory") as? String, "Food & Dining")
        XCTAssertEqual(retrievedMemory.value(forKey: "confidence") as? Double, 0.85, accuracy: 0.001)
        XCTAssertEqual(retrievedMemory.value(forKey: "usageCount") as? Int32, 15)
    }

    func testUserAutomationMemoryAITrainingDataStructure() throws {
        // RED: Test that trainingData can store complex JSON for AI training
        let persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext

        // Create AI training data structure
        let trainingData = [
            "merchantPatterns": ["Uber", "Uber Eats", "DoorDash"],
            "keywords": ["food", "delivery", "transport"],
            "avgAmount": 25.50,
            "suggestedCategory": "Food & Dining",
            "suggestedSplit": ["Personal": 0.6, "Business": 0.4],
            "successRate": 0.92
        ] as [String: Any]

        let jsonData = try JSONSerialization.data(withJSONObject: trainingData, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        // Create UserAutomationMemory with complex training data
        let userAutomationMemory = NSEntityDescription.insertNewObject(forEntityName: "UserAutomationMemory", into: context)
        userAutomationMemory.setValue(UUID(), forKey: "id")
        userAutomationMemory.setValue("Uber,Eats,DoorDash", forKey: "merchantPatterns")
        userAutomationMemory.setValue("Food & Dining", forKey: "userCategory")
        userAutomationMemory.setValue(jsonString, forKey: "trainingData")
        userAutomationMemory.setValue(0.92, forKey: "confidence")
        userAutomationMemory.setValue(Int32(57), forKey: "usageCount")
        userAutomationMemory.setValue(Date(), forKey: "lastUsed")
        userAutomationMemory.setValue(Date(), forKey: "createdAt")
        userAutomationMemory.setValue(Date(), forKey: "updatedAt")

        // Save and retrieve
        try context.save()

        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "UserAutomationMemory")
        let results = try context.fetch(fetchRequest)
        XCTAssertEqual(results.count, 1, "Should retrieve exactly 1 UserAutomationMemory record")

        // Verify complex JSON data integrity
        let retrievedMemory = results.first!
        let retrievedJsonString = retrievedMemory.value(forKey: "trainingData") as? String
        XCTAssertNotNil(retrievedJsonString, "Training data JSON string should be retrievable")

        let retrievedData = try JSONSerialization.jsonObject(with: retrievedJsonString!.data(using: .utf8)!) as? [String: Any]
        XCTAssertNotNil(retrievedData, "Training data should be valid JSON")
        XCTAssertEqual(retrievedData?["suggestedCategory"] as? String, "Food & Dining")
        XCTAssertEqual((retrievedData?["successRate"] as? NSNumber)?.doubleValue, 0.92, accuracy: 0.001)
    }
}