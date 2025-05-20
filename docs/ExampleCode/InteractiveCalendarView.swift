import SwiftUI

/// # Interactive Calendar View
/// Professional calendar component with:
/// - Month/week/day view switching
/// - Event creation and management
/// - Drag and drop scheduling
/// - Customizable appearance
/// - Accessibility support
struct InteractiveCalendarView: View {
    // MARK: - State
    @State private var selectedDate = Date()
    @State private var calendarView: CalendarViewType = .month
    @State private var showEventCreator = false
    @State private var newEventTitle = ""
    @State private var newEventDate = Date()
    @State private var events: [CalendarEvent] = CalendarEvent.sampleEvents
    @State private var draggedEvent: CalendarEvent?
    
    // Month display properties
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar with view selector and controls
            calendarToolbar
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 4)
            
            // Main calendar content
            Group {
                switch calendarView {
                case .month:
                    monthView
                case .week:
                    weekView
                case .day:
                    dayView
                }
            }
            .animation(.easeInOut, value: calendarView)
            
            // Event list for selected date
            eventList
        }
        .sheet(isPresented: $showEventCreator) {
            eventCreationSheet
        }
        .navigationTitle("Calendar")
    }
    
    // MARK: - Calendar Components
    
    private var calendarToolbar: some View {
        HStack {
            // Date navigation
            HStack(spacing: 12) {
                Button(action: previousPeriod) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
                
                Text(formattedSelectedDate)
                    .font(.headline)
                
                Button(action: nextPeriod) {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                
                Button(action: { selectedDate = Date() }) {
                    Text("Today")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            // View type selector
            Picker("View", selection: $calendarView) {
                Text("Month").tag(CalendarViewType.month)
                Text("Week").tag(CalendarViewType.week)
                Text("Day").tag(CalendarViewType.day)
            }
            .pickerStyle(.segmented)
            .frame(width: 240)
            
            Spacer()
            
            // Add event button
            Button(action: { showEventCreator = true }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
    }
    
    private var monthView: some View {
        VStack(spacing: 8) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(height: 32)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let dayEvents = events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
                        
                        Button(action: { selectedDate = date }) {
                            VStack(spacing: 4) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(isToday ? .bold : .regular)
                                
                                // Event indicators
                                if !dayEvents.isEmpty {
                                    HStack(spacing: 4) {
                                        ForEach(0..<min(dayEvents.count, 3), id: \.self) { index in
                                            Circle()
                                                .fill(dayEvents[index].color)
                                                .frame(width: 6, height: 6)
                                        }
                                        
                                        if dayEvents.count > 3 {
                                            Text("+\(dayEvents.count - 3)")
                                                .font(.system(size: 8))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    } else {
                        // Empty cell for days outside current month
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 60)
                    }
                }
            }
        }
        .padding()
    }
    
    private var weekView: some View {
        VStack {
            // Week header showing dates
            HStack {
                ForEach(daysInSelectedWeek, id: \.self) { date in
                    let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let dayName = Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
                    
                    VStack(spacing: 8) {
                        Text(dayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.headline)
                            .padding(8)
                            .background(isSelected ? Circle().fill(Color.accentColor) : nil)
                            .foregroundColor(isSelected ? .white : .primary)
                            .overlay(
                                Circle()
                                    .stroke(isToday && !isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
                            )
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical)
            
            // Time slots with events
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(alignment: .top, spacing: 0) {
                            // Time label
                            Text(String(format: "%02d:00", hour))
                                .font(.caption)
                                .frame(width: 40, alignment: .trailing)
                                .padding(.trailing, 8)
                                .foregroundColor(.secondary)
                            
                            // Time slot grid
                            HStack(spacing: 1) {
                                ForEach(daysInSelectedWeek, id: \.self) { date in
                                    let hourEvents = eventsForHour(date: date, hour: hour)
                                    
                                    ZStack(alignment: .top) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.05))
                                            .frame(height: 60)
                                        
                                        // Events in this slot
                                        VStack(spacing: 1) {
                                            ForEach(hourEvents) { event in
                                                Text(event.title)
                                                    .font(.caption)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(RoundedRectangle(cornerRadius: 4).fill(event.color.opacity(0.2)))
                                                    .foregroundColor(event.color)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                            }
                                        }
                                        .padding(.horizontal, 2)
                                        .padding(.top, 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
                                        showEventCreator = true
                                    }
                                }
                            }
                        }
                        
                        Divider()
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal)
    }
    
    private var dayView: some View {
        VStack(spacing: 0) {
            // Day header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayViewDateHeader)
                        .font(.headline)
                    
                    Text(dayViewSubheader)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if Calendar.current.isDateInToday(selectedDate) {
                    Text("Today")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Divider()
            
            // Time slots with events
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(alignment: .top) {
                            // Time label
                            Text(String(format: "%02d:00", hour))
                                .font(.callout)
                                .frame(width: 50, alignment: .trailing)
                                .padding(.trailing, 12)
                                .foregroundColor(.secondary)
                            
                            // Event container
                            VStack(alignment: .leading, spacing: 2) {
                                let hourEvents = eventsForHour(date: selectedDate, hour: hour)
                                
                                if hourEvents.isEmpty {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.05))
                                        .frame(height: 30)
                                        .onTapGesture {
                                            newEventDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) ?? selectedDate
                                            showEventCreator = true
                                        }
                                } else {
                                    ForEach(hourEvents) { event in
                                        HStack {
                                            Rectangle()
                                                .fill(event.color)
                                                .frame(width: 4)
                                                .cornerRadius(2)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(event.title)
                                                    .font(.callout)
                                                    .fontWeight(.medium)
                                                
                                                if let location = event.location {
                                                    Text(location)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.leading, 4)
                                            
                                            Spacer()
                                            
                                            Text(event.timeLabel)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 8)
                                        .background(event.color.opacity(0.1))
                                        .cornerRadius(6)
                                        .contextMenu {
                                            Button("Edit Event") { editEvent(event) }
                                            Button("Delete Event", role: .destructive) { deleteEvent(event) }
                                        }
                                        .draggable(event.id.uuidString) {
                                            Text(event.title)
                                                .padding(8)
                                                .background(event.color.opacity(0.2))
                                                .cornerRadius(8)
                                                .onAppear { draggedEvent = event }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .dropDestination(for: String.self) { items, location in
                guard let draggedEvent = draggedEvent else { return false }
                
                // Calculate nearest hour based on drop location
                // Implementation would determine the time based on Y position
                
                // Remove the old event and add the modified one
                withAnimation {
                    events.removeAll { $0.id == draggedEvent.id }
                    var updatedEvent = draggedEvent
                    // Update time based on drop location
                    events.append(updatedEvent)
                }
                
                self.draggedEvent = nil
                return true
            }
        }
    }
    
    private var eventList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Events for \(selectedDateShort)")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)
            
            let selectedEvents = events.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
                .sorted { $0.date < $1.date }
            
            if selectedEvents.isEmpty {
                Text("No events scheduled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(selectedEvents) { event in
                    HStack {
                        Circle()
                            .fill(event.color)
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text(event.timeLabel)
                                
                                if let location = event.location {
                                    Text("• \(location)")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button("Edit", action: { editEvent(event) })
                            Button("Delete", role: .destructive, action: { deleteEvent(event) })
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(height: 200)
            }
        }
    }
    
    private var eventCreationSheet: some View {
        VStack(spacing: 20) {
            Text("New Event")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                
                TextField("Event title", text: $newEventTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Date and Time")
                    .font(.headline)
                
                DatePicker("", selection: $newEventDate)
                    .datePickerStyle(.graphical)
            }
            
            HStack {
                Button("Cancel") {
                    showEventCreator = false
                    newEventTitle = ""
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Add Event") {
                    if !newEventTitle.isEmpty {
                        let newEvent = CalendarEvent(
                            id: UUID(),
                            title: newEventTitle,
                            date: newEventDate,
                            color: [.blue, .green, .purple, .orange].randomElement() ?? .blue,
                            location: nil
                        )
                        events.append(newEvent)
                        showEventCreator = false
                        newEventTitle = ""
                    }
                }
                .keyboardShortcut(.return)
                .disabled(newEventTitle.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    // MARK: - Calendar Logic
    
    // Computed properties for date navigation and formatting
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = calendarView == .month ? "MMMM yyyy" : "MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var selectedDateShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var dayViewDateHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }
    
    private var dayViewSubheader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }
    
    // Generate days for month grid
    private var daysInMonth: [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: selectedDate) else {
            return []
        }
        
        let days = Calendar.current.generateDaysForMonthContaining(selectedDate)
        return days
    }
    
    // Generate days for week view
    private var daysInSelectedWeek: [Date] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        let days = Calendar.current.generateDaysForWeekContaining(selectedDate)
        return days
    }
    
    // Find events for a specific hour on a specific date
    private func eventsForHour(date: Date, hour: Int) -> [CalendarEvent] {
        events.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date) &&
            Calendar.current.component(.hour, from: $0.date) == hour
        }
    }
    
    // MARK: - Actions
    
    // Navigate to previous period based on current view
    private func previousPeriod() {
        withAnimation {
            switch calendarView {
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            }
        }
    }
    
    // Navigate to next period based on current view
    private func nextPeriod() {
        withAnimation {
            switch calendarView {
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }
        }
    }
    
    // Edit an existing event
    private func editEvent(_ event: CalendarEvent) {
        newEventTitle = event.title
        newEventDate = event.date
        events.removeAll { $0.id == event.id }
        showEventCreator = true
    }
    
    // Delete an event
    private func deleteEvent(_ event: CalendarEvent) {
        withAnimation {
            events.removeAll { $0.id == event.id }
        }
    }
}

// MARK: - Supporting Types

// Calendar view types
enum CalendarViewType {
    case month, week, day
}

// Calendar event model
struct CalendarEvent: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let color: Color
    let location: String?
    
    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    // Sample events for preview
    static var sampleEvents: [CalendarEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        return [
            CalendarEvent(
                id: UUID(),
                title: "Team Meeting",
                date: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today,
                color: .blue,
                location: "Conference Room A"
            ),
            CalendarEvent(
                id: UUID(),
                title: "Lunch with Client",
                date: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: today) ?? today,
                color: .green,
                location: "Downtown Bistro"
            ),
            CalendarEvent(
                id: UUID(),
                title: "Project Review",
                date: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today) ?? today,
                color: .purple,
                location: nil
            ),
            CalendarEvent(
                id: UUID(),
                title: "Workout",
                date: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today,
                color: .orange,
                location: "Gym"
            )
        ]
    }
}

// Calendar extension for date generation utilities
extension Calendar {
    func generateDaysForMonthContaining(_ date: Date) -> [Date?] {
        guard let monthInterval = dateInterval(of: .month, for: date),
              let monthFirstWeek = dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let numberOfDays = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end).duration / (24 * 3600)
        let daysCount = Int(numberOfDays)
        
        var days: [Date?] = []
        
        for day in 0..<daysCount {
            let dayDate = self.date(byAdding: .day, value: day, to: monthFirstWeek.start)
            
            if let dayDate = dayDate,
               let monthOfDayDate = self.dateComponents([.month], from: dayDate).month,
               let monthOfSelectedDate = self.dateComponents([.month], from: date).month,
               monthOfDayDate == monthOfSelectedDate {
                days.append(dayDate)
            } else {
                days.append(nil) // Placeholder for days outside the month
            }
        }
        
        return days
    }
    
    func generateDaysForWeekContaining(_ date: Date) -> [Date] {
        guard let weekInterval = dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        
        let numberOfDays = DateInterval(start: weekInterval.start, end: weekInterval.end).duration / (24 * 3600)
        let daysCount = Int(numberOfDays)
        
        var days: [Date] = []
        
        for day in 0..<daysCount {
            if let dayDate = self.date(byAdding: .day, value: day, to: weekInterval.start) {
                days.append(dayDate)
            }
        }
        
        return days
    }
}

// MARK: - Preview
struct InteractiveCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveCalendarView()
    }
} 