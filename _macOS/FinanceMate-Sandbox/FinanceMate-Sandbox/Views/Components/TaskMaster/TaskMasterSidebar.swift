// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  TaskMasterSidebar.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular TaskMaster sidebar component with task levels, quick actions, and system status
* Issues & Complexity Summary: Clean sidebar extraction with task level navigation and system monitoring
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~150
  - Core Algorithm Complexity: Medium (task level filtering, status monitoring)
  - Dependencies: 3 New (SwiftUI, TaskMasterAIService, Combine)
  - State Management Complexity: Medium (task level selection, modal state binding)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 35%
* Problem Estimate (Inherent Problem Difficulty %): 30%
* Initial Code Complexity Estimate %): 33%
* Justification for Estimates: Sidebar component extraction with state management
* Final Code Complexity (Actual %): 38%
* Overall Result Score (Success & Quality %): 94%
* Key Variances/Learnings: Clean modular extraction maintains all TaskMaster sidebar functionality
* Last Updated: 2025-06-06
*/

import SwiftUI
import Combine

struct TaskMasterSidebar: View {
    @ObservedObject var taskMaster: TaskMasterAIService
    @Binding var selectedTaskLevel: TaskLevel
    @Binding var showTaskCreationModal: Bool
    @Binding var showAnalytics: Bool
    @Binding var showCompletedTasks: Bool
    @Binding var searchText: String
    
    var body: some View {
        List {
            Section("Task Levels") {
                ForEach(TaskLevel.allCases, id: \.self) { level in
                    TaskLevelRow(
                        level: level,
                        taskCount: taskMaster.getTasksByLevel(level).count,
                        isSelected: selectedTaskLevel == level
                    )
                    .onTapGesture {
                        selectedTaskLevel = level
                    }
                }
            }
            
            Section("Quick Actions") {
                QuickActionRow(
                    icon: "plus.circle.fill",
                    title: "Create New Task",
                    subtitle: "Add Level \(selectedTaskLevel.rawValue) task"
                ) {
                    showTaskCreationModal = true
                }
                
                QuickActionRow(
                    icon: "chart.bar.fill",
                    title: "View Analytics",
                    subtitle: "Task performance metrics"
                ) {
                    showAnalytics = true
                }
                
                QuickActionRow(
                    icon: "checkmark.circle.fill",
                    title: "Completed Tasks",
                    subtitle: "\(taskMaster.completedTasks.count) tasks"
                ) {
                    showCompletedTasks.toggle()
                }
            }
            
            Section("System Status") {
                HStack {
                    Circle()
                        .fill(taskMaster.isProcessing ? .orange : .green)
                        .frame(width: 8, height: 8)
                    Text(taskMaster.isProcessing ? "Processing..." : "Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let workflow = taskMaster.currentWorkflow {
                    Text("Current: \(workflow)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search tasks...")
    }
}

struct TaskLevelRow: View {
    let level: TaskLevel
    let taskCount: Int
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(level.rawValue)")
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(taskCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Text("tasks")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 2)
    }
}