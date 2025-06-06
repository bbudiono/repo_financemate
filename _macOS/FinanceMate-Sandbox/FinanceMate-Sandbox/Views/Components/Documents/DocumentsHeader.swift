// SANDBOX FILE: For testing/development. See .cursorrules.
//
//  DocumentsHeader.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/6/25.
//

/*
* Purpose: Modular documents header component with search, filters, and import functionality
* Issues & Complexity Summary: Header component with search functionality, filtering, and TaskMaster-AI workflow tracking
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~120
  - Core Algorithm Complexity: Medium (search handling, filter management, button actions)
  - Dependencies: 4 New (SwiftUI, TaskMasterWiringService, search/filter binding, action callbacks)
  - State Management Complexity: Medium (search text, filter state, button actions)
  - Novelty/Uncertainty Factor: Low (extracted from working implementation)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 40%
* Problem Estimate (Inherent Problem Difficulty %): 35%
* Initial Code Complexity Estimate %): 38%
* Justification for Estimates: Straightforward header extraction with TaskMaster integration
* Final Code Complexity (Actual %): 42%
* Overall Result Score (Success & Quality %): 94%
* Key Variances/Learnings: Clean header separation improves component reusability
* Last Updated: 2025-06-06
*/

import SwiftUI

struct DocumentsHeader: View {
    @Binding var searchText: String
    @Binding var selectedFilter: DocumentFilter
    @Binding var showingFileImporter: Bool
    @ObservedObject var wiringService: TaskMasterWiringService
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Document Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("🧪 SANDBOX")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(6)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(6)
                
                Button("Import Files") {
                    Task {
                        await handleImportButtonAction()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search documents...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            Task {
                                await handleSearchAction()
                            }
                        }
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Filter picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(DocumentFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName)
                            .tag(filter)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
                .onChange(of: selectedFilter) { oldValue, newValue in
                    Task {
                        await handleFilterChangeAction(from: oldValue, to: newValue)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - TaskMaster-AI Integration
    
    @MainActor
    private func handleImportButtonAction() async {
        let buttonTask = await wiringService.trackButtonAction(
            buttonId: "documents_import_files_button",
            viewName: "DocumentsView",
            actionDescription: "Open file browser for document import",
            expectedOutcome: "File browser opened for document selection",
            metadata: [
                "ui_element": "import_button",
                "action_type": "file_browser",
                "workflow_level": "4"
            ]
        )
        
        // Show file importer after tracking
        showingFileImporter = true
        
        print("🔘 TaskMaster-AI: Tracked import button action - Task ID: \(buttonTask.id)")
    }
    
    @MainActor
    private func handleSearchAction() async {
        let searchText = self.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchText.isEmpty else { return }
        
        let searchTask = await wiringService.trackFormInteraction(
            formId: "documents_search_form",
            viewName: "DocumentsView",
            formAction: "Search documents with text: '\(searchText)'",
            validationSteps: [
                "Search term validation",
                "Document indexing",
                "Result filtering",
                "Performance optimization"
            ],
            metadata: [
                "search_term": searchText,
                "search_type": "text_search",
                "performance_critical": "true"
            ]
        )
        
        print("🔍 TaskMaster-AI: Tracked search action - Task ID: \(searchTask.id)")
    }
    
    @MainActor
    private func handleFilterChangeAction(from oldFilter: DocumentFilter, to newFilter: DocumentFilter) async {
        guard oldFilter != newFilter else { return }
        
        let filterTask = await wiringService.trackButtonAction(
            buttonId: "documents_filter_picker",
            viewName: "DocumentsView",
            actionDescription: "Change document filter from \(oldFilter.displayName) to \(newFilter.displayName)",
            expectedOutcome: "Documents filtered by \(newFilter.displayName)",
            metadata: [
                "old_filter": oldFilter.displayName,
                "new_filter": newFilter.displayName,
                "filter_type": "category"
            ]
        )
        
        print("🔽 TaskMaster-AI: Tracked filter change - Task ID: \(filterTask.id)")
    }
}