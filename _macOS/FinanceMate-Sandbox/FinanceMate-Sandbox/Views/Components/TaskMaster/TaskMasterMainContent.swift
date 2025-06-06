// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  TaskMasterMainContent.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular TaskMaster main content area with header, task lists, and dynamic content switching
* Issues & Complexity Summary: Complex main content orchestrator managing multiple task list states and header statistics
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~180
  - Core Algorithm Complexity: Medium (content switching, state management, task filtering)
  - Dependencies: 4 New (SwiftUI, TaskMasterAIService, Combine, child components)
  - State Management Complexity: Medium (task selection, content state management)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 45%
* Problem Estimate (Inherent Problem Difficulty %): 40%
* Initial Code Complexity Estimate %): 43%
* Justification for Estimates: Main content orchestration with multiple child components
* Final Code Complexity (Actual %): 47%
* Overall Result Score (Success & Quality %): 93%
* Key Variances/Learnings: Clean separation of main content logic from parent view
* Last Updated: 2025-06-06
*/

import SwiftUI
import Combine

struct TaskMasterMainContent: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    let selectedTaskLevel: TaskLevel
    let searchText: String
    let showCompletedTasks: Bool
    @Binding var selectedTask: TaskItem?
    @Binding var showTaskDetails: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with statistics
            TaskMasterHeader(taskMaster: taskMaster, selectedLevel: selectedTaskLevel)
            
            Divider()
            
            // Task list content
            if showCompletedTasks {
                CompletedTasksList(taskMaster: taskMaster, searchText: searchText)
            } else {
                ActiveTasksList(
                    taskMaster: taskMaster,
                    selectedLevel: selectedTaskLevel,
                    searchText: searchText,
                    onTaskSelected: { task in
                        selectedTask = task
                        showTaskDetails = true
                    }
                )
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct TaskMasterHeader: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    let selectedLevel: TaskLevel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TaskMaster-AI Dashboard")
                    .font(.title2)
                    .bold()
                
                Text("Level \(selectedLevel.rawValue) • \(selectedLevel.description)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                StatisticView(
                    title: "Active",
                    value: "\(taskMaster.activeTasks.count)",
                    color: .blue
                )
                
                StatisticView(
                    title: "Completed",
                    value: "\(taskMaster.completedTasks.count)",
                    color: .green
                )
                
                StatisticView(
                    title: "In Progress",
                    value: "\(taskMaster.inProgressTasks.count)",
                    color: .orange
                )
                
                if !taskMaster.urgentTasks.isEmpty {
                    StatisticView(
                        title: "Urgent",
                        value: "\(taskMaster.urgentTasks.count)",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct StatisticView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ActiveTasksList: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    let selectedLevel: TaskLevel
    let searchText: String
    let onTaskSelected: (TaskItem) -> Void
    
    private var filteredTasks: [TaskItem] {
        let levelTasks = taskMaster.getTasksByLevel(selectedLevel)
        
        if searchText.isEmpty {
            return levelTasks
        } else {
            return levelTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        List(filteredTasks) { task in
            TaskRow(task: task, taskMaster: taskMaster) {
                onTaskSelected(task)
            }
            .contextMenu {
                TaskContextMenu(task: task, taskMaster: taskMaster)
            }
        }
        .listStyle(PlainListStyle())
        .overlay {
            if filteredTasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "No Tasks",
                    subtitle: searchText.isEmpty
                        ? "No \(selectedLevel.description.lowercased()) tasks"
                        : "No tasks match '\(searchText)'"
                )
            }
        }
    }
}

struct CompletedTasksList: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    let searchText: String
    
    private var filteredCompletedTasks: [TaskItem] {
        let completed = taskMaster.completedTasks
        
        if searchText.isEmpty {
            return completed.sorted { $0.completedAt ?? Date() > $1.completedAt ?? Date() }
        } else {
            return completed.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.completedAt ?? Date() > $1.completedAt ?? Date() }
        }
    }
    
    var body: some View {
        List(filteredCompletedTasks) { task in
            CompletedTaskRow(task: task)
        }
        .listStyle(PlainListStyle())
        .overlay {
            if filteredCompletedTasks.isEmpty {
                EmptyStateView(
                    icon: "archivebox",
                    title: "No Completed Tasks",
                    subtitle: searchText.isEmpty
                        ? "Complete some tasks to see them here"
                        : "No completed tasks match '\(searchText)'"
                )
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}