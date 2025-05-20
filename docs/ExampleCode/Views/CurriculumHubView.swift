import SwiftUI

/// The main hub for curriculum-related content and features
/**
 * CurriculumHubView
 *
 * Refactored: 0.5.3 (Build 8) – UI modernization: refresh button now uses standard Button instead of PrimaryButton
 */
@available(macOS 13.0, *)
struct CurriculumHubView: View {
    // MARK: - State Variables for Navigation
    @State private var selectedYear: YearLevel? = nil
    @State private var selectedTerm: Term? = nil
    @State private var selectedWeek: Week? = nil

    // MARK: - Properties
    
    /// Access to the curriculum data service
    private let dataService = CurriculumDataService() // Instantiate directly
    
    /// Collection of curriculum items FOR THE SELECTED WEEK (fetched from service)
    @State private var weeklyCurriculumItems: [CurriculumContent] = []
    
    /// Selected view mode
    @State private var selectedViewMode: ViewMode = .list
    
    /// Enum defining different view modes
    enum ViewMode: String, CaseIterable, Identifiable {
        case list = "List View"
        case grid = "Grid View"
        case dashboard = "Dashboard"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .grid: return "square.grid.2x2"
            case .dashboard: return "chart.bar.xaxis"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                hubHeader
                YearNavigationView(selectedYear: $selectedYear)
                    .navigationDestination(for: YearLevel.self) { year in 
                        TermNavigationView(year: year, selectedTerm: $selectedTerm)
                            .navigationDestination(for: Term.self) { term in 
                                WeekNavigationView(term: term, selectedWeek: $selectedWeek)
                                    .navigationDestination(for: Week.self) { week in 
                                        selectedWeekContentView(week: week)
                                            .onAppear { fetchContent(for: week) }
                                    }
                            }
                    }
            }
            .navigationTitle("Curriculum Explorer") 
        }
    }
    
    // MARK: - Header View
    private var hubHeader: some View {
        HStack {
            Text(headerTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Picker("View Mode", selection: $selectedViewMode) {
                ForEach(ViewMode.allCases) { mode in
                    HStack {
                        Image(systemName: mode.icon)
                        Text(mode.rawValue)
                    }.tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 350)
            .opacity(selectedWeek == nil ? 0 : 1) 
            
            Button(action: refreshData) {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 36, height: 36)
            }
            .accessibilityLabel("Refresh Curriculum Data")
        }
        .padding()
        .background(Color(.windowBackgroundColor).opacity(0.3))
    }

    // MARK: - Dynamic Header Title
    private var headerTitle: String {
        if let week = selectedWeek, let term = selectedTerm, let year = selectedYear {
            return "\(year.displayString) - \(term.name) - Week \(week.number)"
        } else if let term = selectedTerm, let year = selectedYear {
            return "\(year.displayString) - \(term.name)"
        } else if let year = selectedYear {
            return year.displayString
        } else {
            return "Select Year Level"
        }
    }

    // MARK: - Content View for Selected Week
    @ViewBuilder
    private func selectedWeekContentView(week: Week) -> some View {
        // Now uses the @State variable populated by fetchContent
        let itemsToDisplay = weeklyCurriculumItems
        
        // Use existing view mode logic for the fetched items
        switch selectedViewMode {
        case .list:
            // Replace CurriculumContentView with a simple List for now
            List(itemsToDisplay) { item in
                VStack(alignment: .leading) {
                    Text(item.title).font(.headline)
                    Text(item.description).font(.body)
                }
            }
            .navigationTitle(headerTitle)
        case .grid:
            // Replace CurriculumGridView with a simple GridView
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 16)], spacing: 16) {
                    ForEach(itemsToDisplay) { item in
                        VStack(alignment: .leading) {
                            Text(item.title).font(.headline)
                            Text(item.description).font(.body)
                        }
                        .padding()
                        .background(Color(.windowBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle(headerTitle)
        case .dashboard:
            // Replace CurriculumDashboardView with a simple dashboard
            Text("Dashboard View - Item Count: \(itemsToDisplay.count)")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(headerTitle)
        }
    }
    
    // MARK: - Functions
    
    /// Fetches curriculum content for a specific week from the data service
    private func fetchContent(for week: Week) {
        weeklyCurriculumItems = dataService.getCurriculumContent(for: week)
    }
    
    /// Refreshes curriculum data
    private func refreshData() {
        withAnimation {
            weeklyCurriculumItems = []
            selectedYear = nil
            selectedTerm = nil
            selectedWeek = nil
        }
    }
}

// MARK: - Placeholder Navigation Views (Ensure models conform to Hashable)
@available(macOS 13.0, *)
struct YearNavigationView: View {
    @Binding var selectedYear: YearLevel?
    private let years: [YearLevel] = YearLevel.allCases // Use allCases if available

    var body: some View {
        List(years, id: \.self) { year in
            NavigationLink(year.displayString, value: year)
        }
        .navigationTitle("Select Year")
    }
}

@available(macOS 13.0, *)
struct TermNavigationView: View {
    let year: YearLevel
    @Binding var selectedTerm: Term?
    private let terms: [Term] = Term.sampleData(for: .year1) // Use actual data service call later

    var body: some View {
        List(terms) { term in
            NavigationLink(term.name, value: term)
        }
        .navigationTitle(year.displayString)
    }
}

@available(macOS 13.0, *)
struct WeekNavigationView: View {
    let term: Term
    @Binding var selectedWeek: Week?
    private let weeks: [Week] = Week.sampleData(for: .term1) // Use actual data service call later

    var body: some View {
        List(weeks) { week in
            NavigationLink("Week \(week.number)", value: week)
        }
        .navigationTitle(term.name)
    }
}

// MARK: - Supporting Views

/// A grid layout view for curriculum content
struct CurriculumGridView: View {
    let curriculumItems: [CurriculumContent]
    
    /// Returns color for subject tag
    private func colorForSubject(_ subject: String) -> Color {
        switch subject {
        case "English": return .blue
        case "Mathematics": return .purple
        case "Science": return .green
        case "HASS": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 16)], spacing: 16) {
                ForEach(curriculumItems) { item in
                    CurriculumGridCell(item: item, subjectColor: colorForSubject(item.subject))
                }
            }
            .padding()
        }
    }
}

/// Grid cell for curriculum content
struct CurriculumGridCell: View {
    let item: CurriculumContent
    let subjectColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.code)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(item.yearLevel)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(item.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Spacer()
            
            HStack {
                Text(item.subject)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(subjectColor.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                if item.assessmentFlag {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.windowBackgroundColor).opacity(0.5))
                .shadow(radius: 2)
        )
    }
}

/// Dashboard view for curriculum analytics
struct CurriculumDashboardView: View {
    let curriculumItems: [CurriculumContent]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Curriculum Overview")
                    .font(.title)
                    .padding(.horizontal)
                
                // Subject distribution
                Group {
                    Text("Subject Distribution")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        ForEach(subjectCounts.sorted(by: { $0.key < $1.key }), id: \.key) { subject, count in
                            VStack {
                                Text("\(count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(subject)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.windowBackgroundColor).opacity(0.5))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Year level distribution
                Group {
                    Text("Year Level Distribution")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        ForEach(yearLevelCounts.sorted(by: { $0.key < $1.key }), id: \.key) { yearLevel, count in
                            VStack {
                                Text("\(count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(yearLevel)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.windowBackgroundColor).opacity(0.5))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Assessment requirements
                Group {
                    Text("Assessment Requirements")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(assessmentCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Requires Assessment")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.1))
                        )
                        
                        VStack {
                            Text("\(curriculumItems.count - assessmentCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("No Assessment Required")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Dictionary of subject counts
    private var subjectCounts: [String: Int] {
        Dictionary(grouping: curriculumItems, by: { $0.subject })
            .mapValues { $0.count }
    }
    
    /// Dictionary of year level counts
    private var yearLevelCounts: [String: Int] {
        Dictionary(grouping: curriculumItems, by: { $0.yearLevel })
            .mapValues { $0.count }
    }
    
    /// Count of items requiring assessment
    private var assessmentCount: Int {
        curriculumItems.filter { $0.assessmentFlag }.count
    }
}

// MARK: - Preview
#Preview {
    CurriculumHubView()
        .frame(width: 1000, height: 700)
} 