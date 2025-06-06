// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  SettingsTestUtilities.swift
//  FinanceMate-SandboxTests
//
//  Created by Assistant on 6/7/25.
//

/*
* Purpose: Shared test utilities and helpers for Settings workflow TDD tests
* Issues & Complexity Summary: Common utilities to support modular settings test components
* Key Complexity Drivers:
  - Shared test setup and teardown logic
  - Common workflow simulation methods
  - Validation helper methods
  - Test data factories and builders
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %: 75%
* Final Code Complexity (Actual %): 72%
* Overall Result Score (Success & Quality %): 95%
* Last Updated: 2025-06-07
*/

import XCTest
import SwiftUI
import Combine
@testable import FinanceMate_Sandbox

/// Base class for all Settings workflow tests providing common setup and utilities
@MainActor
class SettingsTestBase: XCTestCase {
    
    // MARK: - Shared Test Properties
    
    var taskMaster: TaskMasterAIService!
    var wiringService: TaskMasterWiringService!
    var cancellables: Set<AnyCancellable> = []
    let testTimeout: TimeInterval = 20.0
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        taskMaster = TaskMasterAIService()
        wiringService = TaskMasterWiringService(taskMaster: taskMaster)
        cancellables = []
    }
    
    override func tearDown() async throws {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        wiringService = nil
        taskMaster = nil
        try await super.tearDown()
    }
}

/// Factory for creating common workflow steps used across settings tests
struct SettingsWorkflowStepFactory {
    
    static func createAccountSetupSteps() -> [TaskMasterWorkflowStep] {
        return [
            TaskMasterWorkflowStep(
                title: "Open Account Configuration Modal",
                description: "Display account setup interface with current settings",
                elementType: .modal,
                estimatedDuration: 2,
                validationCriteria: ["Modal displayed", "Current settings loaded"]
            ),
            TaskMasterWorkflowStep(
                title: "Profile Information Section",
                description: "Update user profile information with validation",
                elementType: .form,
                estimatedDuration: 5,
                dependencies: ["Open Account Configuration Modal"],
                validationCriteria: ["Name validated", "Email format checked", "Profile picture updated"]
            ),
            TaskMasterWorkflowStep(
                title: "Security Preferences Section",
                description: "Configure security settings and authentication methods",
                elementType: .form,
                estimatedDuration: 4,
                dependencies: ["Profile Information Section"],
                validationCriteria: ["Password strength verified", "Two-factor enabled", "Security questions set"]
            ),
            TaskMasterWorkflowStep(
                title: "Data Privacy Settings",
                description: "Configure data handling and privacy preferences",
                elementType: .form,
                estimatedDuration: 3,
                dependencies: ["Security Preferences Section"],
                validationCriteria: ["Privacy level selected", "Data sharing configured", "Retention policy set"]
            ),
            TaskMasterWorkflowStep(
                title: "Verification Process",
                description: "Execute account verification workflow",
                elementType: .workflow,
                estimatedDuration: 6,
                dependencies: ["Data Privacy Settings"],
                validationCriteria: ["Email verified", "Security check passed", "Account validated"]
            ),
            TaskMasterWorkflowStep(
                title: "Apply Configuration",
                description: "Save and apply all account configuration changes",
                elementType: .action,
                estimatedDuration: 2,
                dependencies: ["Verification Process"],
                validationCriteria: ["Settings saved", "Confirmation displayed", "Account updated"]
            )
        ]
    }
    
    static func createSecurityConfigurationSteps() -> [TaskMasterWorkflowStep] {
        return [
            TaskMasterWorkflowStep(
                title: "Security Assessment Modal",
                description: "Evaluate current security status and identify improvements",
                elementType: .modal,
                estimatedDuration: 4,
                validationCriteria: ["Security scan completed", "Vulnerabilities identified", "Recommendations generated"]
            ),
            TaskMasterWorkflowStep(
                title: "Authentication Method Configuration",
                description: "Configure multi-factor authentication and biometric settings",
                elementType: .modal,
                estimatedDuration: 6,
                dependencies: ["Security Assessment Modal"],
                validationCriteria: ["MFA enabled", "Biometric configured", "Backup methods set"]
            ),
            TaskMasterWorkflowStep(
                title: "Encryption Settings Modal",
                description: "Configure data encryption preferences and key management",
                elementType: .modal,
                estimatedDuration: 5,
                dependencies: ["Authentication Method Configuration"],
                validationCriteria: ["Encryption level selected", "Key rotation configured", "Backup encryption verified"]
            ),
            TaskMasterWorkflowStep(
                title: "Permission and Access Control",
                description: "Configure app permissions and access control settings",
                elementType: .modal,
                estimatedDuration: 4,
                dependencies: ["Encryption Settings Modal"],
                validationCriteria: ["Permissions reviewed", "Access levels set", "Restrictions configured"]
            ),
            TaskMasterWorkflowStep(
                title: "Security Verification Workflow",
                description: "Complete comprehensive security verification process",
                elementType: .workflow,
                estimatedDuration: 8,
                dependencies: ["Permission and Access Control"],
                validationCriteria: ["Identity verified", "Security tests passed", "Configuration validated"]
            ),
            TaskMasterWorkflowStep(
                title: "Security Policy Confirmation",
                description: "Review and confirm security policy changes",
                elementType: .modal,
                estimatedDuration: 3,
                dependencies: ["Security Verification Workflow"],
                validationCriteria: ["Policy reviewed", "Changes approved", "Security profile updated"]
            )
        ]
    }
    
    static func createDataExportSteps() -> [TaskMasterWorkflowStep] {
        return [
            TaskMasterWorkflowStep(
                title: "Export Configuration Modal",
                description: "Configure data export parameters and format selection",
                elementType: .modal,
                estimatedDuration: 3,
                validationCriteria: ["Format selected", "Date range configured", "Data scope defined"]
            ),
            TaskMasterWorkflowStep(
                title: "Data Validation Process",
                description: "Validate data integrity and completeness before export",
                elementType: .workflow,
                estimatedDuration: 5,
                dependencies: ["Export Configuration Modal"],
                validationCriteria: ["Data integrity verified", "Completeness checked", "Format compatibility validated"]
            ),
            TaskMasterWorkflowStep(
                title: "Export Processing Modal",
                description: "Execute data export with progress tracking and validation",
                elementType: .modal,
                estimatedDuration: 8,
                dependencies: ["Data Validation Process"],
                validationCriteria: ["Export initiated", "Progress tracked", "Quality checks passed"]
            ),
            TaskMasterWorkflowStep(
                title: "File Generation and Optimization",
                description: "Generate export file with optimization and compression",
                elementType: .workflow,
                estimatedDuration: 6,
                dependencies: ["Export Processing Modal"],
                validationCriteria: ["File generated", "Optimization applied", "Compression completed"]
            ),
            TaskMasterWorkflowStep(
                title: "Export Verification Modal",
                description: "Verify export quality and completeness",
                elementType: .modal,
                estimatedDuration: 4,
                dependencies: ["File Generation and Optimization"],
                validationCriteria: ["File verified", "Content validated", "Quality approved"]
            ),
            TaskMasterWorkflowStep(
                title: "Download and Completion",
                description: "Facilitate file download and workflow completion",
                elementType: .action,
                estimatedDuration: 2,
                dependencies: ["Export Verification Modal"],
                validationCriteria: ["File downloaded", "Completion confirmed", "Export logged"]
            )
        ]
    }
    
    static func createSSOAuthenticationSteps() -> [TaskMasterWorkflowStep] {
        return [
            TaskMasterWorkflowStep(
                title: "SSO Provider Selection Modal",
                description: "Select and configure SSO identity provider",
                elementType: .modal,
                estimatedDuration: 4,
                validationCriteria: ["Provider selected", "Configuration loaded", "Compatibility verified"]
            ),
            TaskMasterWorkflowStep(
                title: "SSO Configuration Workflow",
                description: "Configure SSO parameters and integration settings",
                elementType: .workflow,
                estimatedDuration: 8,
                dependencies: ["SSO Provider Selection Modal"],
                validationCriteria: ["Client ID configured", "Redirect URLs set", "Scopes defined"]
            ),
            TaskMasterWorkflowStep(
                title: "Authentication Testing Modal",
                description: "Test SSO authentication flow and validation",
                elementType: .modal,
                estimatedDuration: 6,
                dependencies: ["SSO Configuration Workflow"],
                validationCriteria: ["Authentication tested", "Token validation verified", "User mapping confirmed"]
            ),
            TaskMasterWorkflowStep(
                title: "Security Policy Integration",
                description: "Integrate SSO with existing security policies",
                elementType: .workflow,
                estimatedDuration: 5,
                dependencies: ["Authentication Testing Modal"],
                validationCriteria: ["Policy compatibility verified", "Security rules applied", "Access controls updated"]
            ),
            TaskMasterWorkflowStep(
                title: "User Provisioning Configuration",
                description: "Configure automatic user provisioning and deprovisioning",
                elementType: .modal,
                estimatedDuration: 7,
                dependencies: ["Security Policy Integration"],
                validationCriteria: ["Provisioning rules set", "Deprovisioning configured", "Role mapping defined"]
            ),
            TaskMasterWorkflowStep(
                title: "SSO Verification and Activation",
                description: "Complete SSO verification and activate integration",
                elementType: .workflow,
                estimatedDuration: 4,
                dependencies: ["User Provisioning Configuration"],
                validationCriteria: ["SSO verified", "Integration activated", "Documentation updated"]
            )
        ]
    }
}

/// Validation steps factory for common form interactions
struct SettingsValidationStepsFactory {
    
    static func createAccountModificationSteps() -> [String] {
        return [
            "Authenticate Current User",
            "Load Existing Account Data",
            "Validate Modification Permissions",
            "Apply Account Changes",
            "Verify Data Integrity",
            "Update Security Context",
            "Confirm Modification Success"
        ]
    }
    
    static func createSecurityAuditSteps() -> [String] {
        return [
            "Scan Current Security Configuration",
            "Validate Authentication Methods",
            "Check Encryption Implementation",
            "Verify Access Control Policies",
            "Test Security Boundaries",
            "Evaluate Compliance Status",
            "Generate Security Report",
            "Recommend Security Improvements",
            "Schedule Security Review",
            "Update Security Documentation"
        ]
    }
    
    static func createDataImportValidationSteps() -> [String] {
        return [
            "File Format Validation",
            "Data Structure Analysis",
            "Content Integrity Check",
            "Compatibility Verification",
            "Conflict Detection",
            "Import Strategy Selection",
            "Backup Creation",
            "Import Execution",
            "Data Verification",
            "Import Confirmation"
        ]
    }
}

/// Common test data and interaction patterns
struct SettingsTestDataFactory {
    
    static func createSettingsInteractions() -> [(String, String, String)] {
        return [
            ("general-settings-toggle", "Toggle General Setting", "General Settings"),
            ("security-settings-button", "Open Security Settings", "Security Section"),
            ("export-settings-modal", "Configure Export Settings", "Data Management"),
            ("import-preferences-form", "Set Import Preferences", "Data Management"),
            ("appearance-customization", "Customize Appearance", "Appearance Section"),
            ("notification-config", "Configure Notifications", "Notification Section")
        ]
    }
    
    static func createPreferencesSteps() -> [TaskMasterWorkflowStep] {
        return [
            TaskMasterWorkflowStep(
                title: "Appearance Customization",
                description: "Configure app appearance and theme settings",
                elementType: .form,
                estimatedDuration: 3,
                validationCriteria: ["Theme selected", "Color scheme applied", "Font preferences set"]
            ),
            TaskMasterWorkflowStep(
                title: "Notification Configuration",
                description: "Configure notification preferences and schedules",
                elementType: .form,
                estimatedDuration: 4,
                dependencies: ["Appearance Customization"],
                validationCriteria: ["Notification types selected", "Schedules configured", "Delivery methods set"]
            ),
            TaskMasterWorkflowStep(
                title: "Advanced Preferences",
                description: "Configure advanced app preferences and behaviors",
                elementType: .modal,
                estimatedDuration: 5,
                dependencies: ["Notification Configuration"],
                validationCriteria: ["Advanced settings configured", "Behaviors customized", "Performance optimized"]
            ),
            TaskMasterWorkflowStep(
                title: "Preference Validation",
                description: "Validate preference configurations and compatibility",
                elementType: .workflow,
                estimatedDuration: 3,
                dependencies: ["Advanced Preferences"],
                validationCriteria: ["Preferences validated", "Compatibility checked", "Performance impact assessed"]
            )
        ]
    }
}

/// Common test utility methods
extension SettingsTestBase {
    
    /// Helper method to simulate complex modal workflow
    func simulateComplexModalWorkflow(
        modalId: String,
        workflowDescription: String,
        steps: [TaskMasterWorkflowStep]
    ) async -> TaskItem {
        return await wiringService.trackModalWorkflow(
            modalId: modalId,
            viewName: "SettingsView",
            workflowDescription: workflowDescription,
            expectedSteps: steps
        )
    }
    
    /// Helper method to verify workflow step completion
    func verifyWorkflowStepCompletion(
        workflowId: String,
        expectedSteps: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let workflow = wiringService.activeWorkflows[workflowId] ??
                           wiringService.completedWorkflows.first(where: { $0.id == workflowId }) else {
            XCTFail("Workflow not found: \(workflowId)", file: file, line: line)
            return
        }
        
        let subtasks = taskMaster.getSubtasks(for: workflow.id)
        XCTAssertEqual(subtasks.count, expectedSteps, file: file, line: line)
    }
    
    /// Helper method to validate task level and properties
    func validateTaskProperties(
        task: TaskItem,
        expectedLevel: TaskLevel,
        expectedTags: [String],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(task.level, expectedLevel, file: file, line: line)
        for tag in expectedTags {
            XCTAssertTrue(task.tags.contains(tag), "Task missing tag: \(tag)", file: file, line: line)
        }
    }
    
    /// Helper method to complete workflow steps progressively
    func completeWorkflowStepsProgressively(
        workflowId: String,
        steps: [TaskMasterWorkflowStep],
        subtasks: [TaskItem]
    ) async {
        for (index, step) in steps.enumerated() {
            await wiringService.completeWorkflowStep(
                workflowId: workflowId,
                stepId: step.id,
                outcome: "Step \(index + 1) completed successfully"
            )
            
            // Verify step completion
            let completedSubtasks = subtasks.prefix(index + 1).filter {
                taskMaster.getTask(by: $0.id)?.status == .completed
            }
            XCTAssertEqual(completedSubtasks.count, index + 1)
        }
    }
    
    /// Helper method to verify workflow completion
    func verifyWorkflowCompletion(
        workflowId: String,
        expectedTaskId: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(wiringService.completedWorkflows.contains { $0.id == expectedTaskId }, file: file, line: line)
        XCTAssertFalse(wiringService.activeWorkflows.keys.contains(workflowId), file: file, line: line)
    }
    
    /// Helper method to create and track multiple setting interactions
    func trackMultipleSettingsInteractions(
        interactions: [(String, String, String)]
    ) async -> [TaskItem] {
        var tasks: [TaskItem] = []
        for (elementId, action, context) in interactions {
            let task = await wiringService.trackButtonAction(
                buttonId: elementId,
                viewName: "SettingsView",
                actionDescription: action,
                expectedOutcome: "\(action) completed",
                metadata: ["settings_section": context]
            )
            tasks.append(task)
        }
        return tasks
    }
}