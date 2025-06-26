// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  TaskMasterRows.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular task row components for displaying active and completed tasks with interactive elements
* Issues & Complexity Summary: Complex row components with status indicators, action buttons, and context menus
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~220
  - Core Algorithm Complexity: Medium (status display, action handling, priority management)
  - Dependencies: 4 New (SwiftUI, TaskMasterAIService, task model types, action handlers)
  - State Management Complexity: Medium (task status, action button states, context menu logic)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 50%
* Problem Estimate (Inherent Problem Difficulty %): 45%
* Initial Code Complexity Estimate %): 48%
* Justification for Estimates: Complex UI component with multiple interactive elements and state management
* Final Code Complexity (Actual %): 52%
* Overall Result Score (Success & Quality %): 92%
* Key Variances/Learnings: Row components maintain rich functionality while improving reusability
* Last Updated: 2025-06-06
*/

import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    @ObservedObject var taskMaster: TaskMasterAIService
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    // Title and priority
                    HStack {
                        Text(task.title)
                            .font(.headline)
                            .lineLimit(1)

                        Spacer()

                        PriorityBadge(priority: task.priority)
                    }

                    // Description
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    // Tags and metadata
                    HStack {
                        if !task.tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(task.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(Capsule())
                                }

                                if task.tags.count > 3 {
                                    Text("+\(task.tags.count - 3)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        // Duration estimate
                        Text("\(Int(task.estimatedDuration))m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Action buttons
                VStack(spacing: 8) {
                    TaskActionButton(task: task, taskMaster: taskMaster)

                    if task.requiresDecomposition {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var statusColor: Color {
        switch task.status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .blocked: return .orange
        case .completed: return .green
        case .cancelled: return .red
        case .failed: return .red
        }
    }
}

struct CompletedTaskRow: View {
    let task: TaskItem

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough()

                if let completedAt = task.completedAt {
                    Text("Completed: \(completedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let actualDuration = task.actualDuration {
                    Text("Duration: \(Int(actualDuration))m (est. \(Int(task.estimatedDuration))m)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            PriorityBadge(priority: task.priority)
        }
        .padding(.vertical, 4)
        .opacity(0.7)
    }
}

struct PriorityBadge: View {
    let priority: TaskMasterPriority

    var body: some View {
        Text(priority.rawValue.uppercased())
            .font(.caption2)
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color)
            .clipShape(Capsule())
    }
}

struct TaskActionButton: View {
    let task: TaskItem
    @ObservedObject var taskMaster: TaskMasterAIService

    var body: some View {
        Button(action: performAction) {
            Image(systemName: actionIcon)
                .foregroundColor(actionColor)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(PlainButtonStyle())
        .help(actionHelpText)
    }

    private var actionIcon: String {
        switch task.status {
        case .pending: return "play.circle"
        case .inProgress: return "checkmark.circle"
        case .blocked: return "exclamationmark.triangle"
        case .completed: return "checkmark.circle.fill"
        case .cancelled, .failed: return "xmark.circle"
        }
    }

    private var actionColor: Color {
        switch task.status {
        case .pending: return .blue
        case .inProgress: return .green
        case .blocked: return .orange
        case .completed: return .green
        case .cancelled, .failed: return .red
        }
    }

    private var actionHelpText: String {
        switch task.status {
        case .pending: return "Start task"
        case .inProgress: return "Complete task"
        case .blocked: return "Task is blocked"
        case .completed: return "Task completed"
        case .cancelled, .failed: return "Task failed"
        }
    }

    private func performAction() {
        Task {
            switch task.status {
            case .pending:
                await taskMaster.startTask(task.id)
            case .inProgress:
                await taskMaster.completeTask(task.id)
            default:
                break
            }
        }
    }
}

struct TaskContextMenu: View {
    let task: TaskItem
    @ObservedObject var taskMaster: TaskMasterAIService

    var body: some View {
        Group {
            if task.status == .pending {
                Button("Start Task") {
                    Task { await taskMaster.startTask(task.id) }
                }
            }

            if task.status == .inProgress {
                Button("Complete Task") {
                    Task { await taskMaster.completeTask(task.id) }
                }
            }

            if task.requiresDecomposition {
                Button("Decompose Task") {
                    Task { _ = await taskMaster.decomposeTask(task) }
                }
            }

            Divider()

            Button("View Details") {
                // Implementation would show detailed task view
                print("📱 View details for task: \(task.title)")
            }

            Button("Duplicate Task") {
                Task {
                    _ = await taskMaster.createTask(
                        title: "Copy of \(task.title)",
                        description: task.description,
                        level: task.level,
                        priority: task.priority,
                        estimatedDuration: task.estimatedDuration,
                        tags: task.tags
                    )
                }
            }
        }
    }
}
