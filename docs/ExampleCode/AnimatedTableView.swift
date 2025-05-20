//
//  AnimatedTableView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// # Animated Table View
/// This example demonstrates advanced table/list interactions in SwiftUI:
/// - Custom item appearance animations with staggered timing
/// - Swipe actions with animated transitions
/// - Context menu with preview animations
/// - Item reordering with custom drag preview
/// - Search functionality with animated filtering
/// - Scroll position tracking and automatic scrolling
/// - Accessibility enhancements
struct AnimatedTableView: View {
    // MARK: - State
    
    /// List of tasks
    @State private var tasks: [TaskItem] = sampleTasks
    
    /// Tracks which tasks are expanded
    @State private var expandedTasks: Set<UUID> = []
    
    /// Search text for filtering
    @State private var searchText = ""
    
    /// Tracks if items are currently being animated in
    @State private var isAppearing = true
    
    /// Tracks if search field is focused
    @State private var isSearchFocused = false
    
    /// Currently selected task ID
    @State private var selectedTaskId: UUID? = nil
    
    /// Tasks being dragged
    @State private var draggingTask: TaskItem? = nil
    
    // MARK: - Computed Properties
    
    /// Filtered tasks based on search text
    private var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    .background(Color(UIColor.systemBackground))
                    // Add shadow when scrolling
                    .shadow(color: Color.black.opacity(0.1), radius: 6, y: 2)
                
                // Main table/list view
                ScrollViewReader { scrollProxy in
                    List {
                        // Header section
                        Section {
                            headerContent
                        }
                        
                        // Tasks section
                        Section {
                            ForEach(filteredTasks) { task in
                                taskRow(for: task)
                                    // Attach ID for scroll position tracking
                                    .id(task.id)
                                    // Add appearance animation with staggered timing
                                    .opacity(isAppearing ? 0 : 1)
                                    .offset(x: isAppearing ? -20 : 0)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.8)
                                        .delay(getAppearDelay(for: task)),
                                        value: isAppearing
                                    )
                                    // Configure swipe actions
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                deleteTask(task)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)
                                        
                                        Button {
                                            toggleTaskCompletion(task)
                                        } label: {
                                            Label(
                                                task.isCompleted ? "Incomplete" : "Complete",
                                                systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle"
                                            )
                                        }
                                        .tint(task.isCompleted ? .orange : .green)
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            withAnimation {
                                                togglePinned(task)
                                            }
                                        } label: {
                                            Label(
                                                task.isPinned ? "Unpin" : "Pin",
                                                systemImage: task.isPinned ? "pin.slash" : "pin"
                                            )
                                        }
                                        .tint(.blue)
                                    }
                                    // Enable dragging for reordering
                                    .onDrag {
                                        self.draggingTask = task
                                        return NSItemProvider(object: task.id.uuidString as NSString)
                                    }
                                    // Enable dropping for reordering
                                    .onDrop(of: [UTType.plainText.identifier], delegate: TaskDropDelegate(
                                        item: task,
                                        items: $tasks,
                                        current: $draggingTask
                                    ))
                            }
                            .onDelete { indexSet in
                                // Handle swipe-to-delete
                                withAnimation {
                                    let tasksToDelete = indexSet.map { filteredTasks[$0] }
                                    tasksToDelete.forEach { deleteTask($0) }
                                }
                            }
                        } header: {
                            Text("Tasks (\(filteredTasks.count))")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onChange(of: selectedTaskId) { newValue in
                        // Scroll to selected task when it changes
                        if let id = newValue {
                            withAnimation {
                                scrollProxy.scrollTo(id, anchor: .center)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Task List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            addNewTask()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            sortTasks()
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                // Start appearance animations with slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isAppearing = false
                    }
                }
            }
        }
        // Make entire navigation view accessible
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Animated task list with \(tasks.count) tasks")
    }
    
    // MARK: - UI Components
    
    /// Search bar component
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .animation(.easeInOut, value: isSearchFocused)
            
            TextField("Search tasks", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSearchFocused ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                )
                .animation(.easeInOut, value: isSearchFocused)
                .onTapGesture {
                    isSearchFocused = true
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(4)
                .contentShape(Circle())
                .transition(.scale.combined(with: .opacity))
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
        )
        // Make search bar accessible
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Search tasks")
        .accessibilityHint("Enter text to filter the task list")
    }
    
    /// Header content at the top of the list
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task summary statistics
            HStack {
                // Completed tasks
                TaskStatView(
                    title: "Completed",
                    count: tasks.filter(\.isCompleted).count,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Spacer()
                
                // Pending tasks
                TaskStatView(
                    title: "Pending",
                    count: tasks.filter { !$0.isCompleted }.count,
                    icon: "clock.fill",
                    color: .orange
                )
                
                Spacer()
                
                // Pinned tasks
                TaskStatView(
                    title: "Pinned",
                    count: tasks.filter(\.isPinned).count,
                    icon: "pin.fill",
                    color: .blue
                )
            }
            .padding(.vertical, 10)
            // Animated reveal from bottom
            .opacity(isAppearing ? 0 : 1)
            .offset(y: isAppearing ? 20 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: isAppearing)
        }
    }
    
    /// Creates a row view for a single task
    private func taskRow(for task: TaskItem) -> some View {
        let isExpanded = expandedTasks.contains(task.id)
        
        return VStack(alignment: .leading, spacing: 6) {
            // Task header with title and actions
            HStack {
                // Completion status indicator
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: task.isCompleted)
                    .onTapGesture {
                        withAnimation {
                            toggleTaskCompletion(task)
                        }
                    }
                    // Make completion toggle accessible
                    .accessibilityLabel(task.isCompleted ? "Completed" : "Not completed")
                    .accessibilityHint("Tap to mark as \(task.isCompleted ? "incomplete" : "complete")")
                
                VStack(alignment: .leading, spacing: 4) {
                    // Task title
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .animation(.easeInOut, value: task.isCompleted)
                    
                    // Priority and date
                    HStack(spacing: 6) {
                        // Priority indicator
                        PriorityBadge(priority: task.priority)
                        
                        // Due date
                        Text(task.dueDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Pinned indicator
                if task.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Expand/collapse button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        toggleExpanded(task)
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Expanded details section
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Description
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, 4)
                    }
                    
                    // Tags
                    if !task.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(task.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        // Edit button
                        ActionButton(
                            title: "Edit",
                            icon: "pencil",
                            color: .blue
                        ) {
                            // Edit action would go here
                            print("Edit task: \(task.id)")
                        }
                        
                        // Complete/Incomplete toggle
                        ActionButton(
                            title: task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                            icon: task.isCompleted ? "xmark.circle" : "checkmark.circle",
                            color: task.isCompleted ? .orange : .green
                        ) {
                            withAnimation {
                                toggleTaskCompletion(task)
                            }
                        }
                        
                        // Delete button
                        ActionButton(
                            title: "Delete",
                            icon: "trash",
                            color: .red
                        ) {
                            withAnimation {
                                deleteTask(task)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.leading, 28)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
        .contentShape(Rectangle()) // Make entire row tappable
        .onTapGesture {
            // Select and highlight this task
            withAnimation {
                if selectedTaskId == task.id {
                    selectedTaskId = nil
                } else {
                    selectedTaskId = task.id
                }
            }
        }
        .padding(.vertical, 6)
        .background(
            // Highlight selected task
            RoundedRectangle(cornerRadius: 8)
                .fill(task.id == selectedTaskId ? Color.blue.opacity(0.1) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: selectedTaskId)
        )
        // Context menu for additional actions
        .contextMenu {
            // Context menu options
            Button {
                // Edit action
                print("Edit task: \(task.id)")
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                withAnimation {
                    toggleTaskCompletion(task)
                }
            } label: {
                Label(
                    task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle"
                )
            }
            
            Button {
                withAnimation {
                    togglePinned(task)
                }
            } label: {
                Label(
                    task.isPinned ? "Unpin" : "Pin Task",
                    systemImage: task.isPinned ? "pin.slash" : "pin"
                )
            }
            
            Divider()
            
            Button(role: .destructive) {
                withAnimation {
                    deleteTask(task)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        // Full accessibility for the task row
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), Priority: \(task.priority.rawValue), \(task.isCompleted ? "Completed" : "Not completed"), \(task.isPinned ? "Pinned" : "")")
        .accessibilityHint("Double tap to select. Swipe right for delete and complete actions. Swipe left to pin.")
        .accessibilityAction(.magicTap) {
            withAnimation {
                toggleTaskCompletion(task)
            }
        }
    }
    
    // MARK: - Action Methods
    
    /// Returns staggered animation delay for a task during initial appearance
    private func getAppearDelay(for task: TaskItem) -> Double {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            // Staggered delay based on index - earlier items appear first
            return Double(index) * 0.05
        }
        return 0
    }
    
    /// Toggles the expanded state of a task
    private func toggleExpanded(_ task: TaskItem) {
        if expandedTasks.contains(task.id) {
            expandedTasks.remove(task.id)
        } else {
            expandedTasks.insert(task.id)
        }
    }
    
    /// Toggles the completion status of a task
    private func toggleTaskCompletion(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index].isCompleted.toggle()
            }
        }
    }
    
    /// Toggles the pinned status of a task
    private func togglePinned(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isPinned.toggle()
            
            if tasks[index].isPinned {
                // Move pinned task to the top
                let pinnedTask = tasks.remove(at: index)
                tasks.insert(pinnedTask, at: 0)
            }
        }
    }
    
    /// Deletes a task
    private func deleteTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            // Clear selected task if it's being deleted
            if selectedTaskId == task.id {
                selectedTaskId = nil
            }
            
            // Remove task from expanded set if it's expanded
            expandedTasks.remove(task.id)
            
            // Remove the task
            tasks.remove(at: index)
        }
    }
    
    /// Adds a new task
    private func addNewTask() {
        let newTask = TaskItem(
            title: "New Task",
            description: "Add task description here",
            dueDate: Date().addingTimeInterval(86400), // Tomorrow
            priority: .medium,
            isCompleted: false,
            isPinned: false,
            tags: ["new"]
        )
        
        // Add task at the beginning
        tasks.insert(newTask, at: 0)
        
        // Auto-expand the new task
        expandedTasks.insert(newTask.id)
        
        // Select the new task
        selectedTaskId = newTask.id
    }
    
    /// Sort tasks by various criteria
    private func sortTasks() {
        withAnimation {
            // Sort by completion status, then priority, then due date
            tasks.sort { a, b in
                if a.isPinned && !b.isPinned {
                    return true
                } else if !a.isPinned && b.isPinned {
                    return false
                } else if a.isCompleted != b.isCompleted {
                    return !a.isCompleted
                } else if a.priority != b.priority {
                    return a.priority.rawValue < b.priority.rawValue
                } else {
                    return a.dueDate < b.dueDate
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// Task statistic view for header
struct TaskStatView: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.system(size: 18, weight: .semibold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Priority badge indicator
struct PriorityBadge: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(priorityColor.opacity(0.2))
            )
            .foregroundColor(priorityColor)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}

/// Action button for expanded task view
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .foregroundColor(color)
            .background(
                Capsule()
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.1))
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Custom button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Drop delegate for handling task reordering
struct TaskDropDelegate: DropDelegate {
    let item: TaskItem
    @Binding var items: [TaskItem]
    @Binding var current: TaskItem?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // Reset current after drop completed
        current = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Only reorder if we have a valid current item
        guard let current = current else { return }
        
        // Don't reorder if dropping onto self
        if current.id == item.id { return }
        
        // Find indices
        guard let fromIndex = items.firstIndex(where: { $0.id == current.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Don't reorder pinned items
        if items[fromIndex].isPinned != items[toIndex].isPinned {
            return
        }
        
        // Perform the reordering
        if fromIndex != toIndex {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                let fromItem = items[fromIndex]
                items.remove(at: fromIndex)
                items.insert(fromItem, at: toIndex)
            }
        }
    }
}

// MARK: - Models

/// Task priority enum
enum TaskPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var id: String { self.rawValue }
}

/// Task item model
struct TaskItem: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date
    var priority: TaskPriority
    var isCompleted: Bool
    var isPinned: Bool
    var tags: [String]
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// UTType extension for drag and drop support
extension UTType {
    static let taskItem = UTType(exportedAs: "com.picketmate.taskitem")
}

// MARK: - Sample Data

let sampleTasks = [
    TaskItem(
        title: "Design new dashboard layout",
        description: "Create wireframes for the new analytics dashboard. Include charts, user metrics, and activity feed.",
        dueDate: Date().addingTimeInterval(86400*2),
        priority: .high,
        isCompleted: false,
        isPinned: true,
        tags: ["design", "UI/UX", "analytics"]
    ),
    TaskItem(
        title: "Review pull requests",
        description: "Review and approve pending pull requests for the frontend team.",
        dueDate: Date().addingTimeInterval(86400),
        priority: .medium,
        isCompleted: false,
        isPinned: false,
        tags: ["code", "review", "frontend"]
    ),
    TaskItem(
        title: "Fix authentication bug",
        description: "Users report occasional logout issues after the latest update. Investigate and fix the authentication service.",
        dueDate: Date().addingTimeInterval(86400*3),
        priority: .high,
        isCompleted: false,
        isPinned: false,
        tags: ["bug", "authentication", "critical"]
    ),
    TaskItem(
        title: "Write documentation",
        description: "Update API documentation for new endpoints. Include example requests and responses.",
        dueDate: Date().addingTimeInterval(86400*5),
        priority: .low,
        isCompleted: true,
        isPinned: false,
        tags: ["documentation", "API"]
    ),
    TaskItem(
        title: "Weekly team meeting",
        description: "Prepare agenda and lead discussion on current sprint progress and blockers.",
        dueDate: Date().addingTimeInterval(86400*1),
        priority: .medium,
        isCompleted: false,
        isPinned: false,
        tags: ["meeting", "team"]
    ),
    TaskItem(
        title: "Optimize database queries",
        description: "Identify and optimize slow running queries in the analytics service.",
        dueDate: Date().addingTimeInterval(86400*4),
        priority: .medium,
        isCompleted: false,
        isPinned: false,
        tags: ["performance", "database"]
    ),
    TaskItem(
        title: "Update dependencies",
        description: "Update all npm packages to latest versions and test for compatibility issues.",
        dueDate: Date().addingTimeInterval(86400*7),
        priority: .low,
        isCompleted: true,
        isPinned: false,
        tags: ["maintenance", "dependencies"]
    ),
    TaskItem(
        title: "Prepare project presentation",
        description: "Create slides and demo for the quarterly review meeting with stakeholders.",
        dueDate: Date().addingTimeInterval(86400*10),
        priority: .high,
        isCompleted: false,
        isPinned: true,
        tags: ["presentation", "stakeholders"]
    )
]

// MARK: - Preview

struct AnimatedTableView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedTableView()
    }
} 