//
// FinancialEntityManagementView.swift
// FinanceMate
//
// Purpose: Main UI for managing financial entities with CRUD operations and hierarchy visualization
// Issues & Complexity Summary: SwiftUI view with complex state management, entity hierarchy, and glassmorphism styling
// Key Complexity Drivers:
//   - Logic Scope (Est. LoC): ~400
//   - Core Algorithm Complexity: High
//   - Dependencies: SwiftUI, FinancialEntityViewModel, GlassmorphismModifier
//   - State Management Complexity: High
//   - Novelty/Uncertainty Factor: Medium
// AI Pre-Task Self-Assessment: 80%
// Problem Estimate: 85%
// Initial Code Complexity Estimate: 82%
// Final Code Complexity: TBD
// Overall Result Score: TBD
// Key Variances/Learnings: TBD
// Last Updated: 2025-07-09

import SwiftUI

struct FinancialEntityManagementView: View {
    @StateObject var viewModel: FinancialEntityViewModel
    @State private var showingCreateSheet = false
    @State private var showingEditSheet = false
    @State private var selectedEntity: FinancialEntity?
    @State private var showingDeleteAlert = false
    @State private var entityToDelete: FinancialEntity?
    @State private var searchText = ""
    @State private var selectedEntityType: FinancialEntity.EntityType?
    
    init(viewModel: FinancialEntityViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                searchAndFilterSection
                
                // Entity List Section
                entityListSection
                
                Spacer()
            }
            .navigationTitle("Financial Entities")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Create Entity") {
                        showingCreateSheet = true
                    }
                    .accessibilityLabel("Create new financial entity")
                }
            }
        }
        .accessibilityIdentifier("EntityManagementView")
        .onAppear {
            Task {
                await viewModel.fetchAllEntities()
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateEntitySheet(viewModel: viewModel)
                .accessibilityIdentifier("CreateEntitySheet")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let entity = selectedEntity {
                EditEntitySheet(viewModel: viewModel, entity: entity)
                    .accessibilityIdentifier("EditEntitySheet")
            }
        }
        .alert("Confirm Delete", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let entity = entityToDelete {
                    Task {
                        await viewModel.deleteEntity(entity)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this entity? This action cannot be undone.")
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    // MARK: - Search and Filter Section
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search entities...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("Search Entities")
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                }
            }
            .padding(.horizontal)
            
            // Entity Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterButton(title: "All", isSelected: selectedEntityType == nil) {
                        selectedEntityType = nil
                    }
                    
                    ForEach(FinancialEntity.EntityType.allCases, id: \.self) { type in
                        FilterButton(title: type.displayName, isSelected: selectedEntityType == type) {
                            selectedEntityType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Entity List Section
    
    private var entityListSection: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(filteredEntities, id: \.id) { entity in
                    EntityRow(
                        entity: entity,
                        onEdit: {
                            selectedEntity = entity
                            showingEditSheet = true
                        },
                        onDelete: {
                            entityToDelete = entity
                            showingDeleteAlert = true
                        },
                        onAddChild: {
                            // TODO: Implement add child functionality
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .accessibilityIdentifier("EntityList")
        .accessibilityLabel("Financial entities list")
    }
    
    // MARK: - Computed Properties
    
    private var filteredEntities: [FinancialEntity] {
        var entities = viewModel.entities
        
        // Filter by search text
        if !searchText.isEmpty {
            entities = entities.filter { entity in
                entity.name.localizedCaseInsensitiveContains(searchText) ||
                entity.type.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by entity type
        if let selectedType = selectedEntityType {
            entities = entities.filter { $0.type == selectedType.rawValue }
        }
        
        return entities.sorted { $0.name < $1.name }
    }
}

// MARK: - Entity Row Component

struct EntityRow: View {
    let entity: FinancialEntity
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onAddChild: () -> Void
    
    var body: some View {
        HStack {
            // Entity Type Icon
            Image(systemName: entityTypeIcon)
                .foregroundColor(entityTypeColor)
                .font(.title2)
                .accessibilityIdentifier("\(entity.type)EntityIcon")
            
            // Entity Information
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(entity.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let parent = entity.parentEntity {
                        Text("• Child of \(parent.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let description = entity.entityDescription, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button("Add Child Entity") {
                    onAddChild()
                }
                .buttonStyle(PlainButtonStyle())
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Edit Entity") {
                    onEdit()
                }
                .buttonStyle(PlainButtonStyle())
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Delete Entity") {
                    onDelete()
                }
                .buttonStyle(PlainButtonStyle())
                .font(.caption)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .modifier(GlassmorphismModifier(.secondary))
    }
    
    private var entityTypeIcon: String {
        switch entity.type {
        case "Personal":
            return "person.fill"
        case "Business":
            return "building.2.fill"
        case "Trust":
            return "shield.fill"
        case "Investment":
            return "chart.line.uptrend.xyaxis"
        default:
            return "folder.fill"
        }
    }
    
    private var entityTypeColor: Color {
        switch entity.type {
        case "Personal":
            return .blue
        case "Business":
            return .green
        case "Trust":
            return .orange
        case "Investment":
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - Filter Button Component

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Entity Sheet

struct CreateEntitySheet: View {
    @StateObject var viewModel: FinancialEntityViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var entityName = ""
    @State private var selectedType: FinancialEntity.EntityType = .personal
    @State private var entityDescription = ""
    @State private var selectedParent: FinancialEntity?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Entity Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entity Name")
                        .font(.headline)
                    
                    TextField("Enter entity name", text: $entityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("Entity Name")
                }
                
                // Entity Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entity Type")
                        .font(.headline)
                    
                    Picker("Entity Type", selection: $selectedType) {
                        ForEach(FinancialEntity.EntityType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("Entity Type")
                }
                
                // Parent Entity Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parent Entity (Optional)")
                        .font(.headline)
                    
                    Picker("Parent Entity", selection: $selectedParent) {
                        Text("None").tag(nil as FinancialEntity?)
                        ForEach(viewModel.entities.filter { $0.parentEntity == nil }, id: \.id) { entity in
                            Text(entity.name).tag(entity as FinancialEntity?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accessibilityIdentifier("Parent Entity")
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("Enter description", text: $entityDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                // Error Message
                if showingError, let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                    
                    Button("Save") {
                        Task {
                            await createEntity()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entityName.isEmpty || viewModel.isLoading)
                }
            }
            .padding()
            .navigationTitle("Create Entity")
            .navigationBarTitleDisplayMode(.inline)
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    private func createEntity() async {
        let entityData = FinancialEntityData(
            name: entityName,
            type: selectedType.rawValue,
            description: entityDescription.isEmpty ? nil : entityDescription,
            parentEntityId: selectedParent?.id
        )
        
        await viewModel.createEntity(from: entityData)
        
        if viewModel.errorMessage != nil {
            showingError = true
        } else {
            dismiss()
        }
    }
}

// MARK: - Edit Entity Sheet

struct EditEntitySheet: View {
    @StateObject var viewModel: FinancialEntityViewModel
    let entity: FinancialEntity
    @Environment(\.dismiss) private var dismiss
    
    @State private var entityName: String
    @State private var selectedType: FinancialEntity.EntityType
    @State private var entityDescription: String
    @State private var selectedParent: FinancialEntity?
    @State private var showingError = false
    
    init(viewModel: FinancialEntityViewModel, entity: FinancialEntity) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.entity = entity
        self._entityName = State(initialValue: entity.name)
        self._selectedType = State(initialValue: FinancialEntity.EntityType(rawValue: entity.type) ?? .personal)
        self._entityDescription = State(initialValue: entity.entityDescription ?? "")
        self._selectedParent = State(initialValue: entity.parentEntity)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Entity Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entity Name")
                        .font(.headline)
                    
                    TextField("Enter entity name", text: $entityName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityIdentifier("Entity Name")
                }
                
                // Entity Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entity Type")
                        .font(.headline)
                    
                    Picker("Entity Type", selection: $selectedType) {
                        ForEach(FinancialEntity.EntityType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accessibilityIdentifier("Entity Type")
                }
                
                // Parent Entity Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parent Entity (Optional)")
                        .font(.headline)
                    
                    Picker("Parent Entity", selection: $selectedParent) {
                        Text("None").tag(nil as FinancialEntity?)
                        ForEach(viewModel.entities.filter { $0.id != entity.id && $0.parentEntity == nil }, id: \.id) { availableEntity in
                            Text(availableEntity.name).tag(availableEntity as FinancialEntity?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accessibilityIdentifier("Parent Entity")
                }
                
                // Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("Enter description", text: $entityDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                // Error Message
                if showingError, let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                    
                    Button("Save") {
                        Task {
                            await updateEntity()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entityName.isEmpty || viewModel.isLoading)
                }
            }
            .padding()
            .navigationTitle("Edit Entity")
            .navigationBarTitleDisplayMode(.inline)
        }
        .modifier(GlassmorphismModifier(.primary))
    }
    
    private func updateEntity() async {
        let entityData = FinancialEntityData(
            name: entityName,
            type: selectedType.rawValue,
            description: entityDescription.isEmpty ? nil : entityDescription,
            parentEntityId: selectedParent?.id
        )
        
        await viewModel.updateEntity(entity, with: entityData)
        
        if viewModel.errorMessage != nil {
            showingError = true
        } else {
            dismiss()
        }
    }
}

// MARK: - Preview

struct FinancialEntityManagementView_Previews: PreviewProvider {
    static var previews: some View {
        FinancialEntityManagementView(viewModel: FinancialEntityViewModel(context: PersistenceController.preview.container.viewContext))
    }
}