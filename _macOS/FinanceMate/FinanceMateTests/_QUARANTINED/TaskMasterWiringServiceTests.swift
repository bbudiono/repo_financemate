//
//  TaskMasterWiringServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/8/25.
//

import XCTest
@testable import FinanceMate

@MainActor
final class TaskMasterWiringServiceTests: XCTestCase {

    var taskMasterService: TaskMasterAIService!
    var wiringService: TaskMasterWiringService!

    override func setUp() {
        super.setUp()
        taskMasterService = TaskMasterAIService()
        wiringService = TaskMasterWiringService(taskMaster: taskMasterService)
    }

    override func tearDown() {
        wiringService = nil
        taskMasterService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testWiringServiceInitialization() {
        XCTAssertTrue(wiringService.isTrackingEnabled)
        XCTAssertTrue(wiringService.activeWorkflows.isEmpty)
        XCTAssertTrue(wiringService.completedWorkflows.isEmpty)
        XCTAssertNil(wiringService.interactionAnalytics)
        XCTAssertNil(wiringService.lastInteraction)
    }

    // MARK: - Button Action Tracking Tests

    func testTrackButtonAction() async {
        // Given
        let buttonId = "export-button"
        let viewName = "DashboardView"
        let actionDescription = "Export financial data to PDF"
        let expectedOutcome = "PDF file generated successfully"
        let metadata = ["format": "PDF", "scope": "current-month"]

        // When
        let task = await wiringService.trackButtonAction(
            buttonId: buttonId,
            viewName: viewName,
            actionDescription: actionDescription,
            expectedOutcome: expectedOutcome,
            metadata: metadata
        )

        // Then
        XCTAssertEqual(task.level, .level4) // Default for buttons
        XCTAssertTrue(task.title.contains("UI Action"))
        XCTAssertTrue(task.title.contains(actionDescription))
        XCTAssertTrue(task.description.contains(buttonId))
        XCTAssertTrue(task.description.contains(viewName))
        XCTAssertEqual(task.metadata, buttonId)
        XCTAssertTrue(task.tags.contains("ui-action"))
        XCTAssertTrue(task.tags.contains("button"))
        XCTAssertTrue(task.tags.contains(buttonId))

        // Verify task is tracked in wiring service
        let trackedTask = wiringService.getTaskForElement(buttonId)
        XCTAssertNotNil(trackedTask)
        XCTAssertEqual(trackedTask?.id, task.id)

        // Verify interaction was recorded
        XCTAssertNotNil(wiringService.lastInteraction)
        XCTAssertEqual(wiringService.lastInteraction?.elementId, buttonId)
        XCTAssertEqual(wiringService.lastInteraction?.viewName, viewName)
        XCTAssertEqual(wiringService.lastInteraction?.elementType, .button)
        XCTAssertEqual(wiringService.lastInteraction?.userAction, actionDescription)
        XCTAssertEqual(wiringService.lastInteraction?.expectedOutcome, expectedOutcome)
    }

    func testTrackMultipleButtonActions() async {
        // Given
        let button1 = ("save-button", "SettingsView", "Save user preferences")
        let button2 = ("refresh-button", "DashboardView", "Refresh dashboard data")

        // When
        let task1 = await wiringService.trackButtonAction(
            buttonId: button1.0,
            viewName: button1.1,
            actionDescription: button1.2
        )

        let task2 = await wiringService.trackButtonAction(
            buttonId: button2.0,
            viewName: button2.1,
            actionDescription: button2.2
        )

        // Then
        XCTAssertNotEqual(task1.id, task2.id)
        XCTAssertNotNil(wiringService.getTaskForElement(button1.0))
        XCTAssertNotNil(wiringService.getTaskForElement(button2.0))

        let trackingStatus = wiringService.getTrackingStatus()
        XCTAssertEqual(trackingStatus.activeTasks, 2)
        XCTAssertEqual(trackingStatus.totalInteractions, 2)
    }

    // MARK: - Modal Workflow Tracking Tests

    func testTrackModalWorkflow() async {
        // Given
        let modalId = "settings-modal"
        let viewName = "SettingsView"
        let workflowDescription = "Configure application settings"
        let expectedSteps = [
            TaskMasterWorkflowStep(
                title: "Open Settings Panel",
                description: "Display settings interface",
                elementType: .panel,
                estimatedDuration: 2
            ),
            TaskMasterWorkflowStep(
                title: "Modify Preferences",
                description: "Update user preferences",
                elementType: .form,
                estimatedDuration: 10
            ),
            TaskMasterWorkflowStep(
                title: "Save Changes",
                description: "Persist settings to storage",
                elementType: .action,
                estimatedDuration: 3
            )
        ]
        let metadata = ["category": "user-settings", "priority": "medium"]

        // When
        let workflowTask = await wiringService.trackModalWorkflow(
            modalId: modalId,
            viewName: viewName,
            workflowDescription: workflowDescription,
            expectedSteps: expectedSteps,
            metadata: metadata
        )

        // Then
        XCTAssertEqual(workflowTask.level, .level5) // Default for modals
        XCTAssertTrue(workflowTask.title.contains("Modal Workflow"))
        XCTAssertTrue(workflowTask.title.contains(workflowDescription))
        XCTAssertEqual(workflowTask.metadata, modalId)
        XCTAssertTrue(workflowTask.tags.contains("modal"))
        XCTAssertTrue(workflowTask.tags.contains("workflow"))

        // Verify workflow is tracked as active
        XCTAssertTrue(wiringService.activeWorkflows.keys.contains(modalId))
        XCTAssertEqual(wiringService.activeWorkflows[modalId]?.id, workflowTask.id)

        // Verify interaction was recorded
        XCTAssertNotNil(wiringService.lastInteraction)
        XCTAssertEqual(wiringService.lastInteraction?.elementType, .modal)
        XCTAssertEqual(wiringService.lastInteraction?.userAction, "Open Modal")

        // Verify subtasks were created
        let subtasks = taskMasterService.getSubtasks(for: workflowTask.id)
        XCTAssertEqual(subtasks.count, expectedSteps.count)

        for (index, subtask) in subtasks.enumerated() {
            XCTAssertTrue(subtask.title.contains("Step \(index + 1)"))
            XCTAssertTrue(subtask.title.contains(expectedSteps[index].title))
            XCTAssertEqual(subtask.parentTaskId, workflowTask.id)
            XCTAssertTrue(subtask.tags.contains("workflow-step"))
        }
    }

    // MARK: - Form Interaction Tracking Tests

    func testTrackFormInteraction() async {
        // Given
        let formId = "user-profile-form"
        let viewName = "ProfileView"
        let formAction = "Update user profile information"
        let validationSteps = [
            "Validate email format",
            "Check password strength",
            "Verify required fields",
            "Confirm data consistency"
        ]
        let metadata = ["section": "profile", "complexity": "medium"]

        // When
        let formTask = await wiringService.trackFormInteraction(
            formId: formId,
            viewName: viewName,
            formAction: formAction,
            validationSteps: validationSteps,
            metadata: metadata
        )

        // Then
        XCTAssertEqual(formTask.level, .level5) // Forms are complex
        XCTAssertTrue(formTask.title.contains("Form Workflow"))
        XCTAssertTrue(formTask.title.contains(formAction))
        XCTAssertTrue(formTask.description.contains(viewName))
        XCTAssertEqual(formTask.metadata, formId)
        XCTAssertTrue(formTask.tags.contains("form"))
        XCTAssertTrue(formTask.tags.contains("workflow"))
        XCTAssertTrue(formTask.tags.contains(formId))
        XCTAssertTrue(formTask.tags.contains(viewName.lowercased()))

        // Verify interaction was recorded
        XCTAssertNotNil(wiringService.lastInteraction)
        XCTAssertEqual(wiringService.lastInteraction?.elementType, .form)
        XCTAssertEqual(wiringService.lastInteraction?.expectedOutcome, "Complete form validation and submission")

        // Verify validation subtasks were created
        let subtasks = taskMasterService.getSubtasks(for: formTask.id)
        XCTAssertEqual(subtasks.count, validationSteps.count)

        for (index, subtask) in subtasks.enumerated() {
            XCTAssertTrue(subtask.title.contains("Validation \(index + 1)"))
            XCTAssertTrue(subtask.title.contains(validationSteps[index]))
            XCTAssertEqual(subtask.level, .level3)
            XCTAssertEqual(subtask.parentTaskId, formTask.id)
            XCTAssertTrue(subtask.tags.contains("form-validation"))
            XCTAssertTrue(subtask.tags.contains(formId))
        }
    }

    // MARK: - Navigation Tracking Tests

    func testTrackNavigationAction() async {
        // Given
        let navigationId = "dashboard-to-analytics"
        let fromView = "DashboardView"
        let toView = "AnalyticsView"
        let navigationAction = "Navigate to analytics screen"
        let metadata = ["transition": "slide", "direction": "forward"]

        // When
        let navigationTask = await wiringService.trackNavigationAction(
            navigationId: navigationId,
            fromView: fromView,
            toView: toView,
            navigationAction: navigationAction,
            metadata: metadata
        )

        // Then
        XCTAssertEqual(navigationTask.level, .level4) // Standard for navigation
        XCTAssertTrue(navigationTask.title.contains("Navigation"))
        XCTAssertTrue(navigationTask.title.contains(fromView))
        XCTAssertTrue(navigationTask.title.contains(toView))
        XCTAssertTrue(navigationTask.description.contains(navigationAction))
        XCTAssertEqual(navigationTask.metadata, navigationId)
        XCTAssertTrue(navigationTask.tags.contains("navigation"))
        XCTAssertTrue(navigationTask.tags.contains("view-transition"))
        XCTAssertTrue(navigationTask.tags.contains(fromView.lowercased()))
        XCTAssertTrue(navigationTask.tags.contains(toView.lowercased()))

        // Verify interaction was recorded with destination metadata
        XCTAssertNotNil(wiringService.lastInteraction)
        XCTAssertEqual(wiringService.lastInteraction?.elementType, .navigation)
        XCTAssertEqual(wiringService.lastInteraction?.viewName, fromView)
        XCTAssertEqual(wiringService.lastInteraction?.metadata["destination"], toView)
    }

    // MARK: - Workflow Management Tests

    func testCompleteWorkflowStep() async {
        // Given
        let modalId = "export-modal"
        let workflowSteps = [
            TaskMasterWorkflowStep(
                title: "Select Format",
                description: "Choose export format",
                elementType: .form,
                estimatedDuration: 5
            ),
            TaskMasterWorkflowStep(
                title: "Configure Options",
                description: "Set export parameters",
                elementType: .form,
                estimatedDuration: 10
            )
        ]

        let workflowTask = await wiringService.trackModalWorkflow(
            modalId: modalId,
            viewName: "ExportView",
            workflowDescription: "Export financial data",
            expectedSteps: workflowSteps
        )

        let firstStep = workflowSteps[0]

        // When
        await wiringService.completeWorkflowStep(
            workflowId: modalId,
            stepId: firstStep.id,
            outcome: "PDF format selected"
        )

        // Then
        // Verify the corresponding subtask was completed
        let subtasks = taskMasterService.getSubtasks(for: workflowTask.id)
        let completedSubtask = subtasks.first { $0.title.contains(firstStep.title) }
        XCTAssertNotNil(completedSubtask)

        // Workflow should still be active (not all steps complete)
        XCTAssertTrue(wiringService.activeWorkflows.keys.contains(modalId))
    }

    func testCompleteEntireWorkflow() async {
        // Given
        let modalId = "simple-modal"
        let workflowSteps = [
            TaskMasterWorkflowStep(
                title: "Single Step",
                description: "Only one step",
                elementType: .action,
                estimatedDuration: 2
            )
        ]

        let workflowTask = await wiringService.trackModalWorkflow(
            modalId: modalId,
            viewName: "TestView",
            workflowDescription: "Simple workflow",
            expectedSteps: workflowSteps
        )

        // When
        await wiringService.completeWorkflow(
            workflowId: modalId,
            outcome: "Workflow completed successfully"
        )

        // Then
        // Verify workflow was moved from active to completed
        XCTAssertFalse(wiringService.activeWorkflows.keys.contains(modalId))
        XCTAssertTrue(wiringService.completedWorkflows.contains { $0.id == workflowTask.id })

        // Verify completion interaction was recorded
        XCTAssertNotNil(wiringService.lastInteraction)
        XCTAssertEqual(wiringService.lastInteraction?.elementType, .workflow)
        XCTAssertEqual(wiringService.lastInteraction?.userAction, "Complete Workflow")
        XCTAssertEqual(wiringService.lastInteraction?.expectedOutcome, "Workflow completed successfully")
    }

    // MARK: - Analytics Tests

    func testGenerateInteractionAnalytics() async {
        // Given - Create various interactions
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "DashboardView",
            actionDescription: "Action 1"
        )

        _ = await wiringService.trackButtonAction(
            buttonId: "button2",
            viewName: "DashboardView",
            actionDescription: "Action 2"
        )

        _ = await wiringService.trackFormInteraction(
            formId: "form1",
            viewName: "SettingsView",
            formAction: "Form action",
            validationSteps: ["Step 1"]
        )

        _ = await wiringService.trackNavigationAction(
            navigationId: "nav1",
            fromView: "DashboardView",
            toView: "AnalyticsView",
            navigationAction: "Navigate"
        )

        // When
        let analytics = await wiringService.generateInteractionAnalytics()

        // Then
        XCTAssertEqual(analytics.totalInteractions, 4)
        XCTAssertGreaterThan(analytics.uniqueElementsTracked, 0)
        XCTAssertEqual(analytics.mostActiveView, "DashboardView") // 3 interactions
        XCTAssertEqual(analytics.mostUsedElementType, .button) // 2 button interactions

        // Verify view distribution
        XCTAssertEqual(analytics.interactionsByView["DashboardView"], 3)
        XCTAssertEqual(analytics.interactionsByView["SettingsView"], 1)

        // Verify element type distribution
        XCTAssertEqual(analytics.elementTypeDistribution[.button], 2)
        XCTAssertEqual(analytics.elementTypeDistribution[.form], 1)
        XCTAssertEqual(analytics.elementTypeDistribution[.navigation], 1)

        // Verify analytics are published
        XCTAssertNotNil(wiringService.interactionAnalytics)
        XCTAssertEqual(wiringService.interactionAnalytics?.totalInteractions, analytics.totalInteractions)
    }

    func testGetTrackingStatus() async {
        // Given
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "TestView",
            actionDescription: "Test action"
        )

        _ = await wiringService.trackModalWorkflow(
            modalId: "modal1",
            viewName: "TestView",
            workflowDescription: "Test workflow",
            expectedSteps: [
                TaskMasterWorkflowStep(
                    title: "Step 1",
                    description: "Test step",
                    elementType: .action,
                    estimatedDuration: 1
                )
            ]
        )

        // When
        let status = wiringService.getTrackingStatus()

        // Then
        XCTAssertEqual(status.activeTasks, 2) // button + workflow tasks
        XCTAssertEqual(status.activeWorkflows, 1) // one modal workflow
        XCTAssertEqual(status.totalInteractions, 2) // two interactions recorded
    }

    // MARK: - Utility Tests

    func testGetActiveWorkflows() async {
        // Given
        let workflow1 = await wiringService.trackModalWorkflow(
            modalId: "modal1",
            viewName: "TestView",
            workflowDescription: "Workflow 1",
            expectedSteps: []
        )

        let workflow2 = await wiringService.trackModalWorkflow(
            modalId: "modal2",
            viewName: "TestView",
            workflowDescription: "Workflow 2",
            expectedSteps: []
        )

        // When
        let activeWorkflows = wiringService.getActiveWorkflows()

        // Then
        XCTAssertEqual(activeWorkflows.count, 2)
        XCTAssertTrue(activeWorkflows.contains { $0.id == workflow1.id })
        XCTAssertTrue(activeWorkflows.contains { $0.id == workflow2.id })
    }

    func testGetInteractionHistoryForView() async {
        // Given
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "DashboardView",
            actionDescription: "Action 1"
        )

        _ = await wiringService.trackButtonAction(
            buttonId: "button2",
            viewName: "SettingsView",
            actionDescription: "Action 2"
        )

        _ = await wiringService.trackButtonAction(
            buttonId: "button3",
            viewName: "DashboardView",
            actionDescription: "Action 3"
        )

        // When
        let dashboardHistory = wiringService.getInteractionHistory(for: "DashboardView")
        let settingsHistory = wiringService.getInteractionHistory(for: "SettingsView")

        // Then
        XCTAssertEqual(dashboardHistory.count, 2)
        XCTAssertEqual(settingsHistory.count, 1)

        XCTAssertTrue(dashboardHistory.allSatisfy { $0.viewName == "DashboardView" })
        XCTAssertTrue(settingsHistory.allSatisfy { $0.viewName == "SettingsView" })
    }

    func testSetTrackingEnabled() {
        // Given
        XCTAssertTrue(wiringService.isTrackingEnabled)

        // When
        wiringService.setTrackingEnabled(false)

        // Then
        XCTAssertFalse(wiringService.isTrackingEnabled)

        // When
        wiringService.setTrackingEnabled(true)

        // Then
        XCTAssertTrue(wiringService.isTrackingEnabled)
    }

    func testPerformanceMetrics() async {
        // Given
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "TestView",
            actionDescription: "Test action"
        )

        _ = await wiringService.trackModalWorkflow(
            modalId: "modal1",
            viewName: "TestView",
            workflowDescription: "Test workflow",
            expectedSteps: []
        )

        // When
        let metrics = wiringService.performanceMetrics

        // Then
        XCTAssertGreaterThan(metrics.memoryUsage, 0)
        XCTAssertGreaterThanOrEqual(metrics.processingSpeed, 0)
    }

    func testExportInteractionData() async {
        // Given
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "TestView",
            actionDescription: "Test action"
        )

        _ = await wiringService.generateInteractionAnalytics()

        // When
        let exportData = await wiringService.exportInteractionData()

        // Then
        XCTAssertNotNil(exportData)
        XCTAssertGreaterThan(exportData?.count ?? 0, 0)

        // Verify data can be parsed as JSON
        if let data = exportData {
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertNotNil(jsonObject)

            if let json = jsonObject as? [String: Any] {
                XCTAssertNotNil(json["interactions"])
                XCTAssertNotNil(json["workflows"])
                XCTAssertNotNil(json["analytics"])
                XCTAssertNotNil(json["exported_at"])
            }
        }
    }

    // MARK: - Cleanup Tests

    func testCleanupOldInteractions() async {
        // Given
        _ = await wiringService.trackButtonAction(
            buttonId: "button1",
            viewName: "TestView",
            actionDescription: "Test action"
        )

        let initialCount = wiringService.getTrackingStatus().totalInteractions
        XCTAssertGreaterThan(initialCount, 0)

        // When - Cleanup interactions older than tomorrow (should keep all recent ones)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        await wiringService.cleanupOldInteractions(olderThan: tomorrow)

        // Then - Interactions should still exist (they're newer than 24 hours)
        let afterCleanupCount = wiringService.getTrackingStatus().totalInteractions
        XCTAssertGreaterThan(afterCleanupCount, 0)
    }
}

// MARK: - UI Element Types Tests

final class UIElementTypeTests: XCTestCase {

    func testUIElementTypeDefaultTaskLevels() {
        XCTAssertEqual(UIElementType.button.defaultTaskLevel, .level4)
        XCTAssertEqual(UIElementType.menu.defaultTaskLevel, .level4)
        XCTAssertEqual(UIElementType.navigation.defaultTaskLevel, .level4)
        XCTAssertEqual(UIElementType.action.defaultTaskLevel, .level4)

        XCTAssertEqual(UIElementType.form.defaultTaskLevel, .level5)
        XCTAssertEqual(UIElementType.panel.defaultTaskLevel, .level5)
        XCTAssertEqual(UIElementType.modal.defaultTaskLevel, .level5)
        XCTAssertEqual(UIElementType.workflow.defaultTaskLevel, .level5)
    }

    func testUIElementTypeIcons() {
        XCTAssertEqual(UIElementType.button.icon, "button.horizontal")
        XCTAssertEqual(UIElementType.modal.icon, "square.stack")
        XCTAssertEqual(UIElementType.menu.icon, "list.bullet")
        XCTAssertEqual(UIElementType.form.icon, "doc.text")
        XCTAssertEqual(UIElementType.panel.icon, "sidebar.left")
        XCTAssertEqual(UIElementType.navigation.icon, "arrow.right.circle")
        XCTAssertEqual(UIElementType.action.icon, "play.circle")
        XCTAssertEqual(UIElementType.workflow.icon, "arrow.triangle.branch")
    }
}

// MARK: - UI Context Tests

final class UIContextTests: XCTestCase {

    func testUIContextInitialization() {
        // Given
        let viewName = "TestView"
        let elementType = UIElementType.button
        let elementId = "test-button"
        let parentContext = "parent-context"
        let userAction = "Click button"
        let expectedOutcome = "Action performed"
        let metadata = ["key": "value"]

        // When
        let context = UIContext(
            viewName: viewName,
            elementType: elementType,
            elementId: elementId,
            parentContext: parentContext,
            userAction: userAction,
            expectedOutcome: expectedOutcome,
            metadata: metadata
        )

        // Then
        XCTAssertEqual(context.viewName, viewName)
        XCTAssertEqual(context.elementType, elementType)
        XCTAssertEqual(context.elementId, elementId)
        XCTAssertEqual(context.parentContext, parentContext)
        XCTAssertEqual(context.userAction, userAction)
        XCTAssertEqual(context.expectedOutcome, expectedOutcome)
        XCTAssertEqual(context.metadata, metadata)
    }

    func testUIContextWithDefaults() {
        // Given
        let viewName = "TestView"
        let elementType = UIElementType.form
        let elementId = "test-form"
        let userAction = "Submit form"

        // When
        let context = UIContext(
            viewName: viewName,
            elementType: elementType,
            elementId: elementId,
            userAction: userAction
        )

        // Then
        XCTAssertEqual(context.viewName, viewName)
        XCTAssertEqual(context.elementType, elementType)
        XCTAssertEqual(context.elementId, elementId)
        XCTAssertNil(context.parentContext)
        XCTAssertEqual(context.userAction, userAction)
        XCTAssertNil(context.expectedOutcome)
        XCTAssertTrue(context.metadata.isEmpty)
    }
}

// MARK: - Workflow Step Tests

final class TaskMasterWorkflowStepTests: XCTestCase {

    func testWorkflowStepInitialization() {
        // Given
        let title = "Test Step"
        let description = "Test step description"
        let elementType = UIElementType.form
        let estimatedDuration: TimeInterval = 10
        let dependencies = ["step1", "step2"]
        let validationCriteria = ["criteria1", "criteria2"]

        // When
        let step = TaskMasterWorkflowStep(
            title: title,
            description: description,
            elementType: elementType,
            estimatedDuration: estimatedDuration,
            dependencies: dependencies,
            validationCriteria: validationCriteria
        )

        // Then
        XCTAssertEqual(step.title, title)
        XCTAssertEqual(step.description, description)
        XCTAssertEqual(step.elementType, elementType)
        XCTAssertEqual(step.estimatedDuration, estimatedDuration)
        XCTAssertEqual(step.dependencies, dependencies)
        XCTAssertEqual(step.validationCriteria, validationCriteria)
        XCTAssertNotNil(step.id)
    }

    func testWorkflowStepWithDefaults() {
        // Given
        let title = "Simple Step"
        let description = "Simple step description"
        let elementType = UIElementType.action
        let estimatedDuration: TimeInterval = 5

        // When
        let step = TaskMasterWorkflowStep(
            title: title,
            description: description,
            elementType: elementType,
            estimatedDuration: estimatedDuration
        )

        // Then
        XCTAssertEqual(step.title, title)
        XCTAssertEqual(step.description, description)
        XCTAssertEqual(step.elementType, elementType)
        XCTAssertEqual(step.estimatedDuration, estimatedDuration)
        XCTAssertTrue(step.dependencies.isEmpty)
        XCTAssertTrue(step.validationCriteria.isEmpty)
    }
}
