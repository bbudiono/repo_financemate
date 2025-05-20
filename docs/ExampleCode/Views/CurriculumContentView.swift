import SwiftUI

/// A view that displays curriculum content with search, filtering, and detailed display capabilities.
struct CurriculumContentView: View {
    // MARK: - Properties
    
    /// The collection of curriculum content items to display
    @Binding var curriculumItems: [CurriculumContent]
    
    /// The currently selected curriculum item
    @State private var selectedItem: CurriculumContent?
    
    /// Search text for filtering curriculum items
    @State private var searchText: String = ""
    
    /// Filter options for curriculum items
    @State private var selectedSubject: String = "All"
    @State private var selectedYearLevel: String = "All"
    
    /// Available subjects for filtering (computed based on available items)
    private var availableSubjects: [String] {
        let subjects = Set(curriculumItems.map { $0.subject })
        return ["All"] + subjects.sorted()
    }
    
    /// Available year levels for filtering (computed based on available items)
    private var availableYearLevels: [String] {
        let yearLevels = Set(curriculumItems.map { $0.yearLevel })
        return ["All"] + yearLevels.sorted()
    }
    
    /// Filtered curriculum items based on search text and filters
    private var filteredItems: [CurriculumContent] {
        curriculumItems.filter { item in
            let matchesSearch = searchText.isEmpty || 
                               item.title.localizedCaseInsensitiveContains(searchText) ||
                               item.description.localizedCaseInsensitiveContains(searchText) ||
                               item.code.localizedCaseInsensitiveContains(searchText)
            
            let matchesSubject = selectedSubject == "All" || item.subject == selectedSubject
            let matchesYearLevel = selectedYearLevel == "All" || item.yearLevel == selectedYearLevel
            
            return matchesSearch && matchesSubject && matchesYearLevel
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter controls
            VStack(spacing: 8) {
                HStack {
                    Text("🔍")
                        .foregroundColor(.secondary)
                    
                    TextField("Search curriculum content...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    Text("Filter:")
                        .font(.subheadline)
                    
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(availableSubjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    .frame(width: 150)
                    
                    Picker("Year Level", selection: $selectedYearLevel) {
                        ForEach(availableYearLevels, id: \.self) { yearLevel in
                            Text(yearLevel).tag(yearLevel)
                        }
                    }
                    .frame(width: 150)
                    
                    Spacer()
                    
                    Text("\(filteredItems.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.textBackgroundColor).opacity(0.3))
            
            // Main content area with list and detail view
            HSplitView {
                // List of curriculum items
                List(filteredItems, id: \.id, selection: $selectedItem) { item in
                    CurriculumItemRow(item: item)
                        .tag(item)
                }
                .frame(minWidth: 300)
                .listStyle(.plain)
                
                // Detail view
                if let selectedItem = selectedItem {
                    CurriculumDetailView(item: selectedItem)
                        .frame(minWidth: 400)
                        .id(selectedItem.id)
                } else {
                    VStack {
                        Text("📚")
                            .font(.largeTitle)
                        Text("No Selection")
                            .font(.headline)
                        Text("Select a curriculum item to view details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.controlBackgroundColor))
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// Row item for displaying a curriculum content item in the list
struct CurriculumItemRow: View {
    let item: CurriculumContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(item.code)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(item.subject)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(colorForSubject(item.subject).opacity(0.2))
                    .cornerRadius(4)
                
                Text(item.yearLevel)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Helper to get color for subject tag (moved here or keep in parent if needed elsewhere)
    private func colorForSubject(_ subject: String) -> Color {
        // Example color mapping
        switch subject {
        case "English": return .blue
        case "Mathematics": return .purple
        case "Science": return .green
        case "HASS": return .orange
        default: return .gray
        }
    }
}

/// Detail view for displaying a selected curriculum content item
struct CurriculumDetailView: View {
    let item: CurriculumContent
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(item.code)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(item.subject)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorForSubject(item.subject).opacity(0.2))
                            .cornerRadius(6)
                        
                        Text(item.yearLevel)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    Text(item.description)
                        .padding(.vertical, 4)
                }
                .padding()
                .background(Color(.windowBackgroundColor))
                .cornerRadius(8)
                
                if !item.achievementStandards.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Achievement Standards")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(item.achievementStandards, id: \.self) { standard in
                                HStack(alignment: .top) {
                                    Text("✓")
                                        .foregroundColor(.green)
                                    Text(standard)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                }
                
                if !item.relatedResources.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Related Resources")
                            .font(.headline)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(item.relatedResources, id: \.self) { resource in
                                HStack(alignment: .top) {
                                    Text("🔗")
                                        .foregroundColor(.blue)
                                    Text(resource)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding()
                    .background(Color(.windowBackgroundColor))
                    .cornerRadius(8)
                }
                
                HStack {
                    Spacer()
                    HStack {
                        Text(item.assessmentFlag ? "⚠️" : "✅")
                        Text(item.assessmentFlag ? "Assessment Required" : "No Assessment Required")
                    }
                    .foregroundColor(item.assessmentFlag ? .orange : .green)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.assessmentFlag ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                    )
                    Spacer()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.textBackgroundColor).opacity(0.1))
    }
    
    private func colorForSubject(_ subject: String) -> Color {
        switch subject {
        case "English": return .blue
        case "Mathematics": return .purple
        case "Science": return .green
        case "HASS": return .orange
        default: return .gray
        }
    }
}

// MARK: - Preview
#Preview {
    @State var sampleItems = CurriculumContent.sampleData
    return CurriculumContentView(curriculumItems: $sampleItems)
        .frame(width: 900, height: 600)
} 