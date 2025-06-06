// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  TaskMasterModals.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular TaskMaster modal components including task creation, analytics, and detail views
* Issues & Complexity Summary: Complex modal components with form validation, analytics display, and detailed task management
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~450
  - Core Algorithm Complexity: High (form management, analytics generation, detailed task views)
  - Dependencies: 6 New (SwiftUI, TaskMasterAIService, form validation, async operations, navigation, data formatting)
  - State Management Complexity: High (modal state, form state, analytics loading, task details)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 75%
* Problem Estimate (Inherent Problem Difficulty %): 70%
* Initial Code Complexity Estimate %): 73%
* Justification for Estimates: Complex modal components with comprehensive functionality
* Final Code Complexity (Actual %): 78%
* Overall Result Score (Success & Quality %): 90%
* Key Variances/Learnings: Modal separation maintains rich functionality while improving code organization
* Last Updated: 2025-06-06
*/

import SwiftUI

// MARK: - Task Creation Modal

struct TaskCreationModal: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var level: TaskLevel = .level5
    @State private var priority: TaskMasterPriority = .medium
    @State private var estimatedDuration: Double = 15
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Configuration") {
                    Picker("Level", selection: $level) {
                        ForEach(TaskLevel.allCases, id: \.self) { level in
                            Text("Level \(level.rawValue) - \(level.description)")
                                .tag(level)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskMasterPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized)
                                .tag(priority)
                        }
                    }
                    
                    HStack {
                        Text("Estimated Duration")
                        Spacer()
                        TextField("Minutes", value: $estimatedDuration, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("min")
                    }
                }
                
                Section("Tags") {
                    TextField("Comma-separated tags", text: $tags)
                }
            }
            .navigationTitle("Create Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func createTask() {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        Task {
            _ = await taskMaster.createTask(
                title: title,
                description: description,
                level: level,
                priority: priority,
                estimatedDuration: estimatedDuration,
                tags: tagArray
            )
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - Task Analytics Modal

struct TaskAnalyticsView: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    @Environment(\.dismiss) private var dismiss
    @State private var analytics: TaskAnalytics?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let analytics = analytics {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            AnalyticsCard(
                                title: "Active Tasks",
                                value: "\(analytics.totalActiveTasks)",
                                subtitle: "Currently in progress",
                                color: .blue
                            )
                            
                            AnalyticsCard(
                                title: "Completed Tasks",
                                value: "\(analytics.totalCompletedTasks)",
                                subtitle: "Successfully finished",
                                color: .green
                            )
                            
                            AnalyticsCard(
                                title: "Completion Rate",
                                value: "\(Int(analytics.completionRate * 100))%",
                                subtitle: "Tasks completed",
                                color: .orange
                            )
                            
                            AnalyticsCard(
                                title: "Efficiency Ratio",
                                value: String(format: "%.1f", analytics.taskEfficiencyRatio),
                                subtitle: "Estimated vs actual",
                                color: analytics.taskEfficiencyRatio >= 1.0 ? .green : .red
                            )
                            
                            AnalyticsCard(
                                title: "Avg Completion",
                                value: "\(Int(analytics.averageCompletionTime))m",
                                subtitle: "Average time per task",
                                color: .purple
                            )
                            
                            AnalyticsCard(
                                title: "Most Common",
                                value: "Level \(analytics.mostCommonLevel.rawValue)",
                                subtitle: analytics.mostCommonLevel.description,
                                color: .cyan
                            )
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Generating analytics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Task Analytics")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(width: 600, height: 500)
        .onAppear {
            Task {
                let generatedAnalytics = await taskMaster.generateTaskAnalytics()
                await MainActor.run {
                    analytics = generatedAnalytics
                }
            }
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 1)
    }
}

// MARK: - Task Detail Modal

struct TaskDetailView: View {
    let task: TaskItem
    @ObservedObject var taskMaster: TaskMasterAIService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(task.title)
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                            
                            PriorityBadge(priority: task.priority)
                        }
                        
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Task Details
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        DetailItem(title: "Level", value: "\(task.level.rawValue) - \(task.level.description)")
                        DetailItem(title: "Status", value: task.status.rawValue.capitalized)
                        DetailItem(title: "Estimated Duration", value: "\(Int(task.estimatedDuration)) minutes")
                        
                        if let actualDuration = task.actualDuration {
                            DetailItem(title: "Actual Duration", value: "\(Int(actualDuration)) minutes")
                        }
                        
                        DetailItem(title: "Created", value: task.createdAt.formatted(date: .abbreviated, time: .shortened))
                        
                        if let startedAt = task.startedAt {
                            DetailItem(title: "Started", value: startedAt.formatted(date: .abbreviated, time: .shortened))
                        }
                        
                        if let completedAt = task.completedAt {
                            DetailItem(title: "Completed", value: completedAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                    
                    if !task.tags.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(task.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    if !task.dependencies.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dependencies")
                                .font(.headline)
                            
                            ForEach(task.dependencies, id: \.self) { dependencyId in
                                if let dependency = taskMaster.getTask(by: dependencyId) {
                                    HStack {
                                        Circle()
                                            .fill(dependency.status == .completed ? .green : .orange)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(dependency.title)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Text(dependency.status.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    
                    // Subtasks
                    let subtasks = taskMaster.getSubtasks(for: task.id)
                    if !subtasks.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Subtasks (\(subtasks.count))")
                                .font(.headline)
                            
                            ForEach(subtasks) { subtask in
                                HStack {
                                    Image(systemName: subtask.status.icon)
                                        .foregroundColor(subtask.status == .completed ? .green : .blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subtask.title)
                                            .font(.subheadline)
                                        
                                        Text("\(Int(subtask.estimatedDuration))m • \(subtask.status.rawValue)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    TaskActionButton(task: subtask, taskMaster: taskMaster)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Task Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(width: 600, height: 700)
    }
}

struct DetailItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .bold()
            
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}