import Foundation
import CoreData

/// Extraction Feedback entity definition for Core Data
extension PersistenceController {

    /// Create ExtractionFeedback entity description
    static func createExtractionFeedbackEntity() -> NSEntityDescription {
        let feedbackEntity = NSEntityDescription()
        feedbackEntity.name = "ExtractionFeedback"
        feedbackEntity.managedObjectClassName = "ExtractionFeedback"

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false

        let emailIdAttr = NSAttributeDescription()
        emailIdAttr.name = "emailID"
        emailIdAttr.attributeType = .stringAttributeType
        emailIdAttr.isOptional = false

        let feedbackTypeAttr = NSAttributeDescription()
        feedbackTypeAttr.name = "feedbackType"
        feedbackTypeAttr.attributeType = .stringAttributeType
        feedbackTypeAttr.isOptional = false

        let commentAttr = NSAttributeDescription()
        commentAttr.name = "comment"
        commentAttr.attributeType = .stringAttributeType
        commentAttr.isOptional = true

        let timestampAttr = NSAttributeDescription()
        timestampAttr.name = "timestamp"
        timestampAttr.attributeType = .dateAttributeType
        timestampAttr.isOptional = false
        timestampAttr.defaultValue = Date()

        feedbackEntity.properties = [idAttr, emailIdAttr, feedbackTypeAttr, commentAttr, timestampAttr]

        return feedbackEntity
    }
}