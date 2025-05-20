import SwiftUI

/// # Database View Configuration Modal (Conceptual)
/// A conceptual view demonstrating a modal for configuring database views (filter, sort, group):
/// - Provides controls for filtering data based on properties
/// - Allows adding and configuring sorting criteria
/// - (Conceptual) Supports grouping and property visibility
struct DatabaseConfigView: View {
    // MARK: - State
    @Binding var isPresented: Bool
    @State private var filters: [FilterRule] = []
    @State private var sorts: [SortRule] = []
    
    // Sample data properties (conceptual)
    private let availableProperties = [
        "Name", "Status", "Due Date", "Priority", "Tags", "Created By"
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationView { // Use NavigationView for better structure in a modal
            Form {
                // MARK: - Filters Section
                Section(header: Text("Filters")) {
                    ForEach(filters.indices, id: \.self) {
                        index in
                        FilterRuleView(rule: $filters[index], availableProperties: availableProperties)
                    }
                    
                    Button(action: { filters.append(FilterRule()) }) {
                        Label("Add filter", systemImage: "plus.circle")
                    }
                }
                
                // MARK: - Sorts Section
                Section(header: Text("Sorts")) {
                     ForEach(sorts.indices, id: \.self) {
                         index in
                         SortRuleView(rule: $sorts[index], availableProperties: availableProperties)
                     }
                    
                    Button(action: { sorts.append(SortRule()) }) {
                        Label("Add sort", systemImage: "plus.circle")
                    }
                }
                
                // MARK: - Other Options (Conceptual)
                Section(header: Text("Other Options")) {
                    // Conceptual controls for Grouping, Property Visibility etc.
                    Text("Grouping options here...")
                        .foregroundColor(.secondary)
                    Text("Property visibility toggles here...")
                         .foregroundColor(.secondary)
                }
            }
            .navigationTitle("View Configuration")
            .toolbar {
                ToolbarItem(placement: .navigationTrailing) {
                    Button("Done") {
                        // Conceptual: Apply changes and dismiss
                        print("Applying configuration...")
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 500, minHeight: 500, idealHeight: 600)
    }
}

// MARK: - Supporting Views

/// View for a single Filter Rule
struct FilterRuleView: View {
    @Binding var rule: FilterRule
    let availableProperties: [String]
    
    // Sample operators (conceptual)
    private let operators = ["is", "is not", "contains", "does not contain", "is empty", "is not empty"]
    
    var body: some View {
        HStack {
            Picker("Property", selection: $rule.property) {
                ForEach(availableProperties, id: \.self) { property in
                    Text(property).tag(property)
                }
            }
            
            Picker("Operator", selection: $rule.operatorValue) {
                ForEach(operators, id: \.self) { op in
                    Text(op).tag(op)
                }
            }
            
            // Conceptual: Value input based on property type
            if rule.operatorValue != "is empty" && rule.operatorValue != "is not empty" {
                 TextField("Value", text: $rule.value)
                     .textFieldStyle(.roundedBorder)
            }
        }
    }
}

/// View for a single Sort Rule
struct SortRuleView: View {
    @Binding var rule: SortRule
    let availableProperties: [String]
    
    var body: some View {
        HStack {
            Picker("Property", selection: $rule.property) {
                ForEach(availableProperties, id: \.self) { property in
                    Text(property).tag(property)
                }
            }
            
            Picker("Order", selection: $rule.order) {
                Text("Ascending").tag("ascending")
                Text("Descending").tag("descending")
            }
        }
    }
}

// MARK: - Data Models

struct FilterRule: Identifiable {
    let id = UUID()
    var property: String = "Name"
    var operatorValue: String = "is"
    var value: String = ""
}

struct SortRule: Identifiable {
    let id = UUID()
    var property: String = "Name"
    var order: String = "ascending"
}

// MARK: - Preview Wrapper
// A helper struct to preview the modal
struct DatabaseConfigView_Preview_Wrapper: View {
    @State private var showConfig = true
    
    var body: some View {
        Button("Show Config") { showConfig = true }
        .sheet(isPresented: $showConfig) {
            DatabaseConfigView(isPresented: $showConfig)
        }
    }
}

// MARK: - Previews
struct DatabaseConfigView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseConfigView_Preview_Wrapper()
    }
} 