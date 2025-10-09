//
// ContextualMenu.swift
// FinanceMate
//
// Purpose: GREEN PHASE - Contextual Right-Click Menu component implementation
// BLUEPRINT.md Requirements: Contextual Right-Click Menu with key actions
// Complexity: Atomic implementation (<100 lines)
// Last Updated: 2025-10-08
//

import SwiftUI

/// Contextual Right-Click Menu for Transactions
/// BLUEPRINT MANDATORY: Right-click menu with Categorize, Assign to Entity, Apply Split Template, and Delete actions
struct ContextualMenu: View {

    // MARK: - Properties

    let transactions: [Transaction]
    let onAction: (ContextualMenuAction) -> Void

    // Computed Properties
    var supportsBatchOperations: Bool {
        transactions.count > 1
    }

    var availableActions: [String] {
        ["Categorize", "Assign to Entity", "Apply Split Template", "Delete"]
    }

    var error: Error? { nil } // GREEN PHASE: Basic implementation

    // MARK: - Initializers

    init(transactions: [Transaction], onAction: @escaping (ContextualMenuAction) -> Void) {
        self.transactions = transactions
        self.onAction = onAction
    }

    // MARK: - Body

    var body: some View {
        Menu {
            categorizeMenuSection
            assignToEntityMenuSection
            applySplitTemplateMenuSection
            Divider()
            deleteMenuSection
        } label: {
            EmptyView()
        }
    }

    // MARK: - Menu Sections

    @ViewBuilder
    private var categorizeMenuSection: some View {
        Menu("Categorize") {
            Button("Business") {
                onAction(.categorize(categories: ["Business"], onCategorySelected: { _ in }))
            }
            Button("Personal") {
                onAction(.categorize(categories: ["Personal"], onCategorySelected: { _ in }))
            }
            Button("Investment") {
                onAction(.categorize(categories: ["Investment"], onCategorySelected: { _ in }))
            }
        }
    }

    @ViewBuilder
    private var assignToEntityMenuSection: some View {
        Menu("Assign to Entity") {
            Button("Personal") {
                onAction(.assignToEntity(entities: ["Personal"], onEntitySelected: { _ in }))
            }
            Button("Business") {
                onAction(.assignToEntity(entities: ["Business"], onEntitySelected: { _ in }))
            }
        }
    }

    @ViewBuilder
    private var applySplitTemplateMenuSection: some View {
        Menu("Apply Split Template") {
            Button("100% Business") {
                let template = SplitTemplate(name: "Full Business", allocations: ["Business": 100])
                onAction(.applySplitTemplate(templates: [template], onTemplateSelected: { _ in }))
            }
            Button("70/30 Business/Personal") {
                let template = SplitTemplate(name: "Standard Split", allocations: ["Business": 70, "Personal": 30])
                onAction(.applySplitTemplate(templates: [template], onTemplateSelected: { _ in }))
            }
        }
    }

    @ViewBuilder
    private var deleteMenuSection: some View {
        Button(role: .destructive) {
            Label(
                supportsBatchOperations ? "Delete \(transactions.count) Transactions" : "Delete Transaction",
                systemImage: "trash"
            )
        } onTapGesture: {
            onAction(.delete(onDelete: {}))
        }
    }
}

// MARK: - Supporting Types

/// Represents contextual menu actions for transactions
enum ContextualMenuAction {
    case categorize(categories: [String], onCategorySelected: (String) -> Void)
    case assignToEntity(entities: [String], onEntitySelected: (String) -> Void)
    case applySplitTemplate(templates: [SplitTemplate], onTemplateSelected: (SplitTemplate) -> Void)
    case delete(onDelete: () -> Void)

    var title: String {
        switch self {
        case .categorize: return "Categorize"
        case .assignToEntity: return "Assign to Entity"
        case .applySplitTemplate: return "Apply Split Template"
        case .delete: return "Delete"
        }
    }

    var type: ContextualMenuActionType {
        switch self {
        case .categorize: return .categorize
        case .assignToEntity: return .assignToEntity
        case .applySplitTemplate: return .applySplitTemplate
        case .delete: return .delete
        }
    }

    var subActions: [String]? {
        switch self {
        case .categorize(let categories, _): return categories
        case .assignToEntity(let entities, _): return entities
        case .applySplitTemplate(let templates, _): return templates.map { $0.name }
        case .delete: return nil
        }
    }

    var isDestructive: Bool {
        switch self {
        case .delete: return true
        default: return false
        }
    }
}

enum ContextualMenuActionType {
    case categorize
    case assignToEntity
    case applySplitTemplate
    case delete
}

/// Split template for tax allocation
struct SplitTemplate {
    let name: String
    let allocations: [String: Int]
}