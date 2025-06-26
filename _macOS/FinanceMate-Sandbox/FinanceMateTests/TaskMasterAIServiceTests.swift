//
//  TaskMasterAIServiceTests.swift
//  FinanceMateTests
//
//  Created by Assistant on 6/8/25.
//

import XCTest
@testable import FinanceMate

@MainActor
final class TaskMasterAIServiceTests: XCTestCase {

    var taskMasterService: TaskMasterAIService!

    override func setUp() {
        super.setUp()
        taskMasterService = TaskMasterAIService()
    }

    override func tearDown() {
        taskMasterService = nil
        super.tearDown()
    }

    // MARK: - Task Creation Tests

    func testCreateLevel5Task() async {
        // Given
        let title = "Test Level 5 Task"
        let description = "Complex multi-step task for testing"
        let level = TaskLevel.level5
        let estimatedDuration: TimeInterval = 30

        // When
        let task = await taskMasterService.createTask(
            title: title,
            description: description,
            level: level,
            priority: .high,
            estimatedDuration: estimatedDuration,
            tags: ["test", "level5"]
        )

        // Then
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.description, description)
        XCTAssertEqual(task.level, level)
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.estimatedDuration, estimatedDuration)
        XCTAssertEqual(task.status, .pending)
        XCTAssertEqual(task.tags, ["test", "level5"])
        XCTAssertTrue(task.requiresDecomposition)
        XCTAssertFalse(task.isSubtask)
        XCTAssertTrue(taskMasterService.activeTasks.contains(where: { $0.id == task.id }))
    }

    func testCreateLevel6TaskWithAutomaticDecomposition() async {
        // Given
        let title = "Critical System Integration"
        let level = TaskLevel.level6

        // When
        let task = await taskMasterService.createTask(
            title: title,
            description: "Critical integration task",
            level: level,
            priority: .critical,
            estimatedDuration: 60
        )

        // Then
        XCTAssertEqual(task.level, level)
        XCTAssertTrue(task.requiresDecomposition)

        // Verify subtasks were automatically created
        let subtasks = taskMasterService.getSubtasks(for: task.id)
        XCTAssertGreaterThan(subtasks.count, 0, "Level 6 tasks should automatically generate subtasks")

        // Verify subtask structure
        for subtask in subtasks {
            XCTAssertEqual(subtask.parentTaskId, task.id)
            XCTAssertTrue(subtask.isSubtask)
            XCTAssertEqual(subtask.priority, task.priority)
        }
    }

    func testCreateChatbotAssistanceTask() async {
        // Given
        let userMessage = "Help me analyze financial data"
        let capabilities = ["analysis", "visualization", "reporting"]

        // When
        let task = await taskMasterService.createChatbotAssistanceTask(
            userMessage: userMessage,
            requiredCapabilities: capabilities
        )

        // Then
        XCTAssertTrue(task.title.contains("AI Assistant"))
        XCTAssertTrue(task.description.contains(userMessage))
        XCTAssertEqual(task.level, .level5)
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.tags, ["chatbot", "ai-assistance"] + capabilities)
        XCTAssertEqual(task.metadata, capabilities.joined(separator: ","))
    }

    // MARK: - Task Management Tests

    func testStartTask() async {
        // Given
        let task = await taskMasterService.createTask(
            title: "Test Task",
            description: "Test task for starting",
            level: .level3,
            estimatedDuration: 10
        )
        XCTAssertEqual(task.status, .pending)
        XCTAssertNil(task.startedAt)

        // When
        await taskMasterService.startTask(task.id)

        // Then
        let updatedTask = taskMasterService.getTask(by: task.id)
        XCTAssertNotNil(updatedTask)
        XCTAssertEqual(updatedTask?.status, .inProgress)
        XCTAssertNotNil(updatedTask?.startedAt)
    }

    func testCompleteTask() async {
        // Given
        let task = await taskMasterService.createTask(
            title: "Test Task",
            description: "Test task for completion",
            level: .level3,
            estimatedDuration: 10
        )
        await taskMasterService.startTask(task.id)

        // When
        await taskMasterService.completeTask(task.id)

        // Then
        let completedTask = taskMasterService.getTask(by: task.id)
        XCTAssertNotNil(completedTask)
        XCTAssertEqual(completedTask?.status, .completed)
        XCTAssertNotNil(completedTask?.completedAt)
        XCTAssertNotNil(completedTask?.actualDuration)

        // Verify task moved to completed list
        XCTAssertFalse(taskMasterService.activeTasks.contains(where: { $0.id == task.id }))
        XCTAssertTrue(taskMasterService.completedTasks.contains(where: { $0.id == task.id }))
    }

    func testUpdateTaskStatus() async {
        // Given
        let task = await taskMasterService.createTask(
            title: "Test Task",
            description: "Test task for status updates",
            level: .level3,
            estimatedDuration: 10
        )

        // When - Test blocked status
        await taskMasterService.updateTaskStatus(task.id, status: .blocked)

        // Then
        var updatedTask = taskMasterService.getTask(by: task.id)
        XCTAssertEqual(updatedTask?.status, .blocked)
        XCTAssertTrue(updatedTask?.isBlocked == true)

        // When - Test in progress status
        await taskMasterService.updateTaskStatus(task.id, status: .inProgress)

        // Then
        updatedTask = taskMasterService.getTask(by: task.id)
        XCTAssertEqual(updatedTask?.status, .inProgress)
        XCTAssertNotNil(updatedTask?.startedAt)
    }

    // MARK: - Task Decomposition Tests

    func testLevel5TaskDecomposition() async {
        // Given
        let parentTask = await taskMasterService.createTask(
            title: "Complex Feature Implementation",
            description: "Implement a complex feature with multiple steps",
            level: .level5,
            estimatedDuration: 45
        )

        // When
        let subtasks = await taskMasterService.decomposeTask(parentTask)

        // Then
        XCTAssertGreaterThan(subtasks.count, 0, "Level 5 tasks should generate subtasks")
        XCTAssertEqual(subtasks.count, 4, "Level 5 tasks should generate 4 standard subtasks")

        let expectedTitles = [
            "Planning & Analysis",
            "Core Implementation",
            "Testing & Validation",
            "Integration & Cleanup"
        ]

        for (index, subtask) in subtasks.enumerated() {
            XCTAssertTrue(subtask.title.contains(expectedTitles[index]))
            XCTAssertEqual(subtask.parentTaskId, parentTask.id)
            XCTAssertTrue(subtask.isSubtask)
            XCTAssertTrue(subtask.tags.contains("subtask"))
            XCTAssertTrue(subtask.tags.contains("level5-decomposed"))
        }
    }

    func testLevel6TaskDecomposition() async {
        // Given
        let parentTask = await taskMasterService.createTask(
            title: "Critical System Migration",
            description: "Migrate critical system components",
            level: .level6,
            estimatedDuration: 120
        )

        // When
        let subtasks = await taskMasterService.decomposeTask(parentTask)

        // Then
        XCTAssertEqual(subtasks.count, 6, "Level 6 tasks should generate 6 critical subtasks")

        let expectedTitles = [
            "System Analysis",
            "Architecture Design",
            "Core Development",
            "Security Validation",
            "Integration Testing",
            "Documentation & Deployment"
        ]

        for (index, subtask) in subtasks.enumerated() {
            XCTAssertTrue(subtask.title.contains(expectedTitles[index]))
            XCTAssertEqual(subtask.parentTaskId, parentTask.id)
            XCTAssertTrue(subtask.tags.contains("critical"))
            XCTAssertTrue(subtask.tags.contains("level6-decomposed"))
        }
    }

    // MARK: - Task Dependencies Tests

    func testAddTaskDependency() async {
        // Given
        let dependentTask = await taskMasterService.createTask(
            title: "Dependent Task",
            description: "Task that depends on another",
            level: .level3,
            estimatedDuration: 10
        )

        let prerequisiteTask = await taskMasterService.createTask(
            title: "Prerequisite Task",
            description: "Task that must complete first",
            level: .level3,
            estimatedDuration: 5
        )

        // When
        await taskMasterService.addTaskDependency(taskId: dependentTask.id, dependsOn: prerequisiteTask.id)

        // Then
        let updatedDependentTask = taskMasterService.getTask(by: dependentTask.id)
        XCTAssertNotNil(updatedDependentTask)
        XCTAssertEqual(updatedDependentTask?.status, .blocked)
        XCTAssertTrue(updatedDependentTask?.dependencies.contains(prerequisiteTask.id) == true)
    }

    func testUnblockTaskWhenDependencyCompletes() async {
        // Given
        let dependentTask = await taskMasterService.createTask(
            title: "Dependent Task",
            description: "Task that depends on another",
            level: .level3,
            estimatedDuration: 10
        )

        let prerequisiteTask = await taskMasterService.createTask(
            title: "Prerequisite Task",
            description: "Task that must complete first",
            level: .level3,
            estimatedDuration: 5
        )

        await taskMasterService.addTaskDependency(taskId: dependentTask.id, dependsOn: prerequisiteTask.id)

        // Verify task is blocked
        var updatedDependentTask = taskMasterService.getTask(by: dependentTask.id)
        XCTAssertEqual(updatedDependentTask?.status, .blocked)

        // When - Complete prerequisite task
        await taskMasterService.completeTask(prerequisiteTask.id)

        // Then - Dependent task should be unblocked
        updatedDependentTask = taskMasterService.getTask(by: dependentTask.id)
        XCTAssertEqual(updatedDependentTask?.status, .pending)
        XCTAssertFalse(updatedDependentTask?.isBlocked == true)
    }

    // MARK: - UI Integration Tests

    func testTrackButtonAction() async {
        // Given
        let buttonId = "export-button"
        let actionDescription = "Export financial data"
        let userContext = "DashboardView"

        // When
        let task = await taskMasterService.trackButtonAction(
            buttonId: buttonId,
            actionDescription: actionDescription,
            userContext: userContext
        )

        // Then
        XCTAssertTrue(task.title.contains("UI Action"))
        XCTAssertTrue(task.title.contains(actionDescription))
        XCTAssertTrue(task.description.contains(buttonId))
        XCTAssertTrue(task.description.contains(userContext))
        XCTAssertEqual(task.level, .level4)
        XCTAssertEqual(task.metadata, buttonId)
        XCTAssertTrue(task.tags.contains("ui-action"))
        XCTAssertTrue(task.tags.contains("button"))
        XCTAssertTrue(task.tags.contains(buttonId))
    }

    func testTrackModalWorkflow() async {
        // Given
        let modalId = "settings-modal"
        let workflowDescription = "Configure application settings"
        let expectedSteps = ["Open Settings", "Modify Preferences", "Save Changes"]

        // When
        let workflowTask = await taskMasterService.trackModalWorkflow(
            modalId: modalId,
            workflowDescription: workflowDescription,
            expectedSteps: expectedSteps
        )

        // Then
        XCTAssertTrue(workflowTask.title.contains("Modal Workflow"))
        XCTAssertTrue(workflowTask.title.contains(workflowDescription))
        XCTAssertEqual(workflowTask.level, .level5)
        XCTAssertEqual(workflowTask.status, .inProgress) // Should auto-start
        XCTAssertEqual(workflowTask.metadata, modalId)
        XCTAssertTrue(workflowTask.tags.contains("modal"))
        XCTAssertTrue(workflowTask.tags.contains("workflow"))

        // Verify subtasks were created for each step
        let subtasks = taskMasterService.getSubtasks(for: workflowTask.id)
        XCTAssertEqual(subtasks.count, expectedSteps.count)

        for (index, subtask) in subtasks.enumerated() {
            XCTAssertTrue(subtask.title.contains("Step \(index + 1)"))
            XCTAssertTrue(subtask.title.contains(expectedSteps[index]))
            XCTAssertEqual(subtask.level, .level3)
            XCTAssertTrue(subtask.tags.contains("workflow-step"))
        }
    }

    // MARK: - Analytics Tests

    func testGenerateTaskAnalytics() async {
        // Given - Create some tasks in different states
        let task1 = await taskMasterService.createTask(
            title: "Completed Task 1",
            description: "Test task",
            level: .level3,
            estimatedDuration: 10
        )

        let task2 = await taskMasterService.createTask(
            title: "Active Task 1",
            description: "Test task",
            level: .level4,
            priority: .high,
            estimatedDuration: 15
        )

        // Complete one task
        await taskMasterService.startTask(task1.id)
        await taskMasterService.completeTask(task1.id)

        // When
        let analytics = await taskMasterService.generateTaskAnalytics()

        // Then
        XCTAssertEqual(analytics.totalActiveTasks, 1)
        XCTAssertEqual(analytics.totalCompletedTasks, 1)
        XCTAssertGreaterThan(analytics.averageCompletionTime, 0)
        XCTAssertGreaterThan(analytics.completionRate, 0)
        XCTAssertLessThanOrEqual(analytics.completionRate, 1.0)

        // Verify priority distribution
        XCTAssertEqual(analytics.priorityDistribution[.medium], 1) // task2 has medium priority

        // Verify statistics are published
        XCTAssertNotNil(taskMasterService.statistics)
        XCTAssertEqual(taskMasterService.statistics?.totalActiveTasks, analytics.totalActiveTasks)
    }

    // MARK: - Utility Tests

    func testGetTasksByLevel() async {
        // Given
        let level3Task = await taskMasterService.createTask(
            title: "Level 3 Task",
            description: "Test",
            level: .level3,
            estimatedDuration: 5
        )

        let level5Task = await taskMasterService.createTask(
            title: "Level 5 Task",
            description: "Test",
            level: .level5,
            estimatedDuration: 30
        )

        // When
        let level3Tasks = taskMasterService.getTasksByLevel(.level3)
        let level5Tasks = taskMasterService.getTasksByLevel(.level5)

        // Then
        XCTAssertEqual(level3Tasks.count, 1)
        XCTAssertEqual(level5Tasks.count, 1)
        XCTAssertEqual(level3Tasks.first?.id, level3Task.id)
        XCTAssertEqual(level5Tasks.first?.id, level5Task.id)
    }

    func testGetTasksByPriority() async {
        // Given
        let highPriorityTask = await taskMasterService.createTask(
            title: "High Priority Task",
            description: "Test",
            level: .level3,
            priority: .high,
            estimatedDuration: 5
        )

        let criticalTask = await taskMasterService.createTask(
            title: "Critical Task",
            description: "Test",
            level: .level3,
            priority: .critical,
            estimatedDuration: 5
        )

        // When
        let highPriorityTasks = taskMasterService.getTasksByPriority(.high)
        let criticalTasks = taskMasterService.getTasksByPriority(.critical)

        // Then
        XCTAssertEqual(highPriorityTasks.count, 1)
        XCTAssertEqual(criticalTasks.count, 1)
        XCTAssertEqual(highPriorityTasks.first?.id, highPriorityTask.id)
        XCTAssertEqual(criticalTasks.first?.id, criticalTask.id)
    }

    func testUrgentTasksProperty() async {
        // Given
        let lowPriorityTask = await taskMasterService.createTask(
            title: "Low Priority Task",
            description: "Test",
            level: .level3,
            priority: .low,
            estimatedDuration: 5
        )

        let highPriorityTask = await taskMasterService.createTask(
            title: "High Priority Task",
            description: "Test",
            level: .level3,
            priority: .high,
            estimatedDuration: 5
        )

        let criticalTask = await taskMasterService.createTask(
            title: "Critical Task",
            description: "Test",
            level: .level3,
            priority: .critical,
            estimatedDuration: 5
        )

        // When
        let urgentTasks = taskMasterService.urgentTasks

        // Then
        XCTAssertEqual(urgentTasks.count, 2) // high and critical only
        XCTAssertTrue(urgentTasks.contains(where: { $0.id == highPriorityTask.id }))
        XCTAssertTrue(urgentTasks.contains(where: { $0.id == criticalTask.id }))
        XCTAssertFalse(urgentTasks.contains(where: { $0.id == lowPriorityTask.id }))

        // Verify sorting (critical should come first)
        XCTAssertEqual(urgentTasks.first?.priority, .critical)
    }

    // MARK: - Cleanup Tests

    func testCleanupOldTasks() async {
        // Given - Create a task and complete it
        let task = await taskMasterService.createTask(
            title: "Old Task",
            description: "Task to be cleaned up",
            level: .level3,
            estimatedDuration: 5
        )

        await taskMasterService.completeTask(task.id)

        // Verify task is completed
        XCTAssertTrue(taskMasterService.completedTasks.contains(where: { $0.id == task.id }))

        // When - Cleanup tasks older than yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        await taskMasterService.cleanupOldTasks(olderThan: yesterday)

        // Then - Task should still exist (it's newer than yesterday)
        XCTAssertTrue(taskMasterService.completedTasks.contains(where: { $0.id == task.id }))

        // When - Cleanup tasks older than tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        await taskMasterService.cleanupOldTasks(olderThan: tomorrow)

        // Then - Task should be removed
        XCTAssertFalse(taskMasterService.completedTasks.contains(where: { $0.id == task.id }))
        XCTAssertNil(taskMasterService.getTask(by: task.id))
    }
}

// MARK: - Task Model Tests

final class TaskItemTests: XCTestCase {

    func testTaskItemInitialization() {
        // Given
        let title = "Test Task"
        let description = "Test Description"
        let level = TaskLevel.level4
        let priority = TaskMasterPriority.high
        let estimatedDuration: TimeInterval = 25
        let tags = ["test", "unit"]

        // When
        let task = TaskItem(
            title: title,
            description: description,
            level: level,
            priority: priority,
            estimatedDuration: estimatedDuration,
            tags: tags
        )

        // Then
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.description, description)
        XCTAssertEqual(task.level, level)
        XCTAssertEqual(task.priority, priority)
        XCTAssertEqual(task.estimatedDuration, estimatedDuration)
        XCTAssertEqual(task.status, .pending)
        XCTAssertEqual(task.tags, tags)
        XCTAssertNotNil(task.id)
        XCTAssertNotNil(task.createdAt)
        XCTAssertNil(task.startedAt)
        XCTAssertNil(task.completedAt)
        XCTAssertNil(task.actualDuration)
        XCTAssertNil(task.parentTaskId)
        XCTAssertTrue(task.dependencies.isEmpty)
    }

    func testTaskLevelProperties() {
        // Test Level 5 task
        let level5Task = TaskItem(
            title: "Level 5 Task",
            description: "Test",
            level: .level5,
            estimatedDuration: 30
        )

        XCTAssertTrue(level5Task.requiresDecomposition)
        XCTAssertEqual(level5Task.level.description, "Complex Multi-Step Tasks")
        XCTAssertEqual(level5Task.level.estimatedBaseTime, 1800) // 30 minutes

        // Test Level 3 task
        let level3Task = TaskItem(
            title: "Level 3 Task",
            description: "Test",
            level: .level3,
            estimatedDuration: 5
        )

        XCTAssertFalse(level3Task.requiresDecomposition)
        XCTAssertEqual(level3Task.level.description, "Standard Operations")
        XCTAssertEqual(level3Task.level.estimatedBaseTime, 300) // 5 minutes
    }

    func testTaskPriorityProperties() {
        let criticalTask = TaskItem(
            title: "Critical Task",
            description: "Test",
            level: .level3,
            priority: .critical,
            estimatedDuration: 5
        )

        XCTAssertEqual(criticalTask.priority.weight, 4)
        XCTAssertEqual(criticalTask.priority.color, .red)

        let lowTask = TaskItem(
            title: "Low Task",
            description: "Test",
            level: .level3,
            priority: .low,
            estimatedDuration: 5
        )

        XCTAssertEqual(lowTask.priority.weight, 1)
        XCTAssertEqual(lowTask.priority.color, .green)
    }

    func testTaskStatusProperties() {
        let task = TaskItem(
            title: "Test Task",
            description: "Test",
            level: .level3,
            estimatedDuration: 5
        )

        XCTAssertTrue(task.canStart)
        XCTAssertFalse(task.isBlocked)
        XCTAssertTrue(task.status.isActive)
        XCTAssertEqual(task.status.icon, "clock")
    }

    func testSubtaskProperties() {
        let parentTask = TaskItem(
            title: "Parent Task",
            description: "Test",
            level: .level5,
            estimatedDuration: 30
        )

        let subtask = TaskItem(
            title: "Subtask",
            description: "Test",
            level: .level3,
            estimatedDuration: 5,
            parentTaskId: parentTask.id
        )

        XCTAssertFalse(parentTask.isSubtask)
        XCTAssertTrue(subtask.isSubtask)
        XCTAssertEqual(subtask.parentTaskId, parentTask.id)
    }
}

// MARK: - TaskLevel Tests

final class TaskLevelTests: XCTestCase {

    func testTaskLevelPriorities() {
        XCTAssertEqual(TaskLevel.level1.priority, 1)
        XCTAssertEqual(TaskLevel.level6.priority, 6)
    }

    func testTaskLevelDescriptions() {
        XCTAssertEqual(TaskLevel.level1.description, "Simple Actions")
        XCTAssertEqual(TaskLevel.level6.description, "Critical System Integration")
    }

    func testTaskLevelDecompositionRequirements() {
        XCTAssertFalse(TaskLevel.level1.requiresDecomposition)
        XCTAssertFalse(TaskLevel.level4.requiresDecomposition)
        XCTAssertTrue(TaskLevel.level5.requiresDecomposition)
        XCTAssertTrue(TaskLevel.level6.requiresDecomposition)
    }

    func testTaskLevelEstimatedTimes() {
        XCTAssertEqual(TaskLevel.level1.estimatedBaseTime, 30)    // 30 seconds
        XCTAssertEqual(TaskLevel.level2.estimatedBaseTime, 120)   // 2 minutes  
        XCTAssertEqual(TaskLevel.level3.estimatedBaseTime, 300)   // 5 minutes
        XCTAssertEqual(TaskLevel.level4.estimatedBaseTime, 900)   // 15 minutes
        XCTAssertEqual(TaskLevel.level5.estimatedBaseTime, 1800)  // 30 minutes
        XCTAssertEqual(TaskLevel.level6.estimatedBaseTime, 3600)  // 60 minutes
    }
}
