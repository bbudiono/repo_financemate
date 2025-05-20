import SwiftUI

/// # Complex Gantt Chart View
/// Professional Gantt chart component with:
/// - Scrollable time timeline
/// - Task and Milestone representation with start/end dates or just dates
/// - Interactive task bars (conceptual drag/resize)
/// - Task dependencies visualization (conceptual)
/// - Resource allocation visualization (conceptual)
/// - Progress tracking visualization (conceptual)
/// - Zooming capabilities (conceptual)
struct ComplexGanttChartView: View {
    // MARK: - State
    // Use GanttItem to support both tasks and milestones
    @State private var ganttItems: [GanttItem] = sampleGanttItems
    @State private var timelineScrollOffset: CGFloat = 0
    @State private var timelineScale: CGFloat = 1.0 // 1.0 represents default scale (e.g., 1 day = X points)
    
    // Dimensions
    private let headerHeight: CGFloat = 50
    private let taskRowHeight: CGFloat = 40
    private let taskBarHeight: CGFloat = 30
    private let minimumDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())! // Start date for the timeline
    private let maximumDate = Calendar.current.date(byAdding: .day, value: 180, to: Date())! // End date for the timeline
    private let pointsPerDay: CGFloat = 20.0 // How many points represent one day at scale 1.0
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Timeline Header (Dates)
            TimelineHeaderView(minimumDate: minimumDate, maximumDate: maximumDate, scale: timelineScale, pointsPerDay: pointsPerDay, scrollOffset: timelineScrollOffset)
                .frame(height: headerHeight)
                .background(Color.gray.opacity(0.1))
            
            Divider()
            
            // Task Area (Rows and Bars/Milestones)
            ScrollView(.horizontal) {
                ScrollViewReader { proxy in
                    ZStack(alignment: .topLeading) {
                        // Task/Milestone Rows Background (conceptual: alternating colors or lines)
                        VStack(spacing: 0) {
                            ForEach(ganttItems.indices, id: \.self) { index in
                                Rectangle()
                                    .fill(index % 2 == 0 ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                    .frame(height: taskRowHeight)
                            }
                        }
                        
                        // Gantt Task Bars and Milestones
                        ForEach(ganttItems.indices, id: \.self) { index in
                            let item = ganttItems[index]
                            switch item {
                            case .task(let task):
                                GanttTaskView(
                                    task: task,
                                    minimumDate: minimumDate,
                                    scale: timelineScale,
                                    pointsPerDay: pointsPerDay,
                                    rowHeight: taskRowHeight,
                                    taskBarHeight: taskBarHeight
                                )
                                .offset(y: CGFloat(index) * taskRowHeight)
                            case .milestone(let milestone):
                                GanttMilestoneView(
                                    milestone: milestone,
                                    minimumDate: minimumDate,
                                    scale: timelineScale,
                                    pointsPerDay: pointsPerDay,
                                    rowHeight: taskRowHeight
                                )
                                .offset(y: CGFloat(index) * taskRowHeight)
                            }
                        }

                        // Conceptual Dependency Lines - This would require more complex drawing
                        // based on task positions.
                        // Example: Draw a line from end of Task 1 to start of Task 3 if Task 3 depends on Task 1
                        // For now, this is just a comment indicating where dependency drawing would go.
                        // You would iterate through ganttItems, find tasks with dependencies,
                        // and draw lines between the relevant task/milestone positions.
                    }
                    .frame(minWidth: timelineWidth)
                    .onChange(of: timelineScrollOffset) { newOffset in
                        proxy.scrollTo(newOffset, anchor: .leading)
                    }
                }
            }
            .coordinateSpace(name: "timelineScroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                timelineScrollOffset = value
            }
            .background(Color(.windowBackgroundColor))
            
            // Timeline Controls (Conceptual: Zoom, Filters etc.)
            HStack {
                Text("Timeline Controls (Zoom, Filters etc.)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 30)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    // MARK: - Helper Properties
    
    private var timelineWidth: CGFloat {
        let duration = Calendar.current.dateComponents([.day], from: minimumDate, to: maximumDate).day ?? 0
        return CGFloat(duration) * pointsPerDay * timelineScale
    }
}

// MARK: - Supporting Views

/// View for the horizontal timeline header (dates)
struct TimelineHeaderView: View {
    let minimumDate: Date
    let maximumDate: Date
    let scale: CGFloat
    let pointsPerDay: CGFloat
    let scrollOffset: CGFloat
    
    private var days: [Date] {
        var dates: [Date] = []
        var currentDate = minimumDate
        let calendar = Calendar.current
        while currentDate <= maximumDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                ZStack(alignment: .leading) {
                    // Conceptual background for alignment
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: timelineWidth, height: 1)
                    
                    // Date markers and labels
                    ForEach(days, id: \.self) { day in
                        let dayOffset = CGFloat(Calendar.current.dateComponents([.day], from: minimumDate, to: day).day ?? 0)
                        let xPosition = dayOffset * pointsPerDay * scale
                        
                        VStack(alignment: .leading) {
                            // Tick mark
                            Rectangle()
                                .fill(Color.primary.opacity(0.5))
                                .frame(width: 1, height: 10)
                            
                            // Date label (show every few days based on scale)
                            if dayOffset.truncatingRemainder(dividingBy: 7) == 0 || scale > 1.5 {
                                Text("\(day, format: .dateTime.month(.abbreviated).day())")
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                                    .offset(x: 5)
                            }
                        }
                        .offset(x: xPosition)
                    }
                }
                .frame(minWidth: timelineWidth) // Ensure ZStack takes required width
                .onChange(of: scrollOffset) { newOffset in
                     proxy.scrollTo(newOffset, anchor: .leading)
                 }
            }
        }
         .disabled(true) // Disable user scrolling, sync with main ScrollView
         .coordinateSpace(name: "timelineHeaderScroll")
         .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
             // This won't be triggered due to disabled, but shows intent
         }
    }
    
    private var timelineWidth: CGFloat {
        let duration = Calendar.current.dateComponents([.day], from: minimumDate, to: maximumDate).day ?? 0
        return CGFloat(duration) * pointsPerDay * scale
    }
}

/// View for an individual task bar in the Gantt chart
struct GanttTaskView: View {
    let task: GanttTask
    let minimumDate: Date
    let scale: CGFloat
    let pointsPerDay: CGFloat
    let rowHeight: CGFloat
    let taskBarHeight: CGFloat
    
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var initialStartTime: Date = Date()
    
    private var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: task.startTime, to: task.endTime).day ?? 0
    }
    
    private var startOffsetInDays: Int {
        Calendar.current.dateComponents([.day], from: minimumDate, to: task.startTime).day ?? 0
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Task Bar
            Rectangle()
                .fill(task.color.opacity(0.8))
                .frame(width: CGFloat(durationInDays) * pointsPerDay * scale, height: taskBarHeight)
                .cornerRadius(5)
                // Progress Overlay
                .overlay(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(task.color.opacity(1.0))
                            .frame(width: geometry.size.width * CGFloat(task.completionPercentage), height: geometry.size.height)
                            .cornerRadius(5)
                    }
                )
                .overlay(
                    VStack(alignment: .leading) {
                        // Task Name
                        Text(task.name)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        // Assigned Resources (Conceptual - might need a dedicated view)
                        if !task.assignedResources.isEmpty {
                            Text("Res: \(task.assignedResources.map { $0.name }.joined(separator: ", "))")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 4)
                                .lineLimit(1)
                        }

                        // Completion Percentage
                        Text("\(Int(task.completionPercentage * 100))%")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                )
                .offset(x: CGFloat(startOffsetInDays) * pointsPerDay * scale + dragOffset.width)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if !isDragging {
                                initialStartTime = task.startTime
                            }
                            isDragging = true
                            dragOffset = value.translation
                            // Conceptual: update task start/end time based on drag
                        }
                        .onEnded { value in
                            isDragging = false
                            dragOffset = .zero // Reset offset after conceptual update
                        }
                )
                .zIndex(isDragging ? 1 : 0) // Bring dragged item to front
        }
    }
}

/// View for an individual milestone in the Gantt chart
struct GanttMilestoneView: View {
    let milestone: GanttMilestone
    let minimumDate: Date
    let scale: CGFloat
    let pointsPerDay: CGFloat
    let rowHeight: CGFloat

    private var dateOffsetInDays: Int {
        Calendar.current.dateComponents([.day], from: minimumDate, to: milestone.date).day ?? 0
    }

    var body: some View {
        ZStack {
            // Milestone Marker (e.g., Diamond)
            Circle()
                .fill(milestone.color)
                .frame(width: rowHeight * 0.6, height: rowHeight * 0.6)
                .rotationEffect(.degrees(45))
                .overlay(
                    Text(milestone.name)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-45)) // Rotate text back
                )
                .offset(x: CGFloat(dateOffsetInDays) * pointsPerDay * scale)

            // Conceptual: Display assigned resources near milestone
             if !milestone.assignedResources.isEmpty {
                 Text("Res: \(milestone.assignedResources.map { $0.name }.joined(separator: ", "))")
                     .font(.system(size: 8))
                     .foregroundColor(.primary.opacity(0.8))
                     .offset(x: CGFloat(dateOffsetInDays) * pointsPerDay * scale, y: rowHeight * 0.4)
             }
        }
    }
}

// MARK: - Data Models

// Represents a resource assigned to a task, e.g., personnel, equipment
struct Resource: Identifiable {
    let id = UUID()
    let name: String
    let type: String // e.g., "Personnel", "Equipment"
}

// Represents a task in the Gantt chart
struct GanttTask: Identifiable {
    let id = UUID()
    let name: String
    let startTime: Date
    let endTime: Date // Should be >= startTime
    let color: Color
    var completionPercentage: Double // 0.0 to 1.0
    var dependencies: [UUID] // IDs of tasks that must be completed before this task starts
    var assignedResources: [Resource] = [] // Resources assigned to this task
}

// Represents a key milestone in the project timeline
struct GanttMilestone: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let color: Color // Color of the milestone marker
    var assignedResources: [Resource] = [] // Resources associated with the milestone (e.g., attendees)
}

// Enum to hold either a Task or a Milestone
enum GanttItem: Identifiable {
    case task(GanttTask)
    case milestone(GanttMilestone)

    var id: UUID {
        switch self {
        case .task(let task): return task.id
        case .milestone(let milestone): return milestone.id
        }
    }
}

// Sample Data - Updated to include milestones, dependencies, resources, and progress
let sampleResources: [Resource] = [
    Resource(name: "John Doe", type: "Personnel"),
    Resource(name: "Excavator 1", type: "Equipment"),
    Resource(name: "Jane Smith", type: "Personnel")
]

let task1Id = UUID()
let task2Id = UUID()
let task3Id = UUID()
let task4Id = UUID()
let task5Id = UUID()
let milestone1Id = UUID()


let sampleGanttItems: [GanttItem] = [
    .task(GanttTask(id: task1Id, name: "Site Prep", startTime: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, endTime: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, color: .blue, completionPercentage: 0.8, dependencies: [], assignedResources: [sampleResources[0], sampleResources[1]])),
    .task(GanttTask(id: task2Id, name: "Foundation Work", startTime: Calendar.current.date(byAdding: .day, value: 8, to: Date())!, endTime: Calendar.current.date(byAdding: .day, value: 14, to: Date())!, color: .green, completionPercentage: 0.5, dependencies: [task1Id], assignedResources: [sampleResources[0]])),
    .milestone(GanttMilestone(id: milestone1Id, name: "Foundation Complete", date: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, color: .orange, assignedResources: [sampleResources[2]])),
    .task(GanttTask(id: task3Id, name: "Framing", startTime: Calendar.current.date(byAdding: .day, value: 16, to: Date())!, endTime: Calendar.current.date(byAdding: .day, value: 24, to: Date())!, color: .red, completionPercentage: 0.2, dependencies: [task2Id, milestone1Id], assignedResources: [sampleResources[2]])),
    .task(GanttTask(id: task4Id, name: "Roofing", startTime: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, endTime: Calendar.current.date(byAdding: .day, value: 28, to: Date())!, color: .purple, completionPercentage: 0.0, dependencies: [task3Id])),
    .task(GanttTask(id: task5Id, name: "Finishing", startTime: Calendar.current.date(byAdding: .day, value: 25, to: Date())!, endTime: Calendar.current.date(byAdding: .day, value: 35, to: Date())!, color: .orange, completionPercentage: 0.0, dependencies: [task4Id]))
]

// MARK: - Preferences for ScrollView Offset

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Previews
struct ComplexGanttChartView_Previews: PreviewProvider {
    static var previews: some View {
        ComplexGanttChartView()
            .frame(width: 800, height: 400)
    }
} 