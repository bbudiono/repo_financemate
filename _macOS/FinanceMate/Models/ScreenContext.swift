import Foundation

// MARK: - Screen Context Model
// BLUEPRINT Line 135: Context-Aware AI Assistant
// Tracks current screen for dynamic AI assistant suggestions

enum ScreenContext: String, CaseIterable {
    case dashboard = "Dashboard"
    case transactions = "Transactions"
    case gmail = "Gmail Receipts"
    case settings = "Settings"

    // MARK: - Context-Specific Properties

    var welcomeMessage: String {
        switch self {
        case .dashboard:
            return """
            I'm here to help with your financial dashboard. I can help you with:

            • Understanding your spending patterns
            • Budget analysis and recommendations
            • Income vs expenses breakdown
            • Financial goal tracking

            What would you like to know about your finances?
            """
        case .transactions:
            return """
            I'm here to help with your transactions. I can help you with:

            • Finding specific transactions
            • Categorizing expenses
            • Tax deduction identification
            • Transaction splitting for tax purposes

            What would you like to know about your transactions?
            """
        case .gmail:
            return """
            I'm here to help with your Gmail receipts. I can help you with:

            • Understanding extracted transactions
            • Improving extraction accuracy
            • Importing receipts to transactions
            • Identifying missing receipts

            What would you like to know about your email receipts?
            """
        case .settings:
            return """
            I'm here to help with your settings. I can help you with:

            • Configuring API keys for AI features
            • Managing connected accounts
            • Setting up automation rules
            • Understanding extraction health metrics

            What would you like to configure?
            """
        }
    }

    var suggestedQueries: [SuggestedQuery] {
        switch self {
        case .dashboard:
            return [
                SuggestedQuery(icon: "chart.pie.fill", title: "Expenses", query: "Show me a breakdown of my expenses this month"),
                SuggestedQuery(icon: "dollarsign.circle.fill", title: "Budget", query: "How am I tracking against my budget?"),
                SuggestedQuery(icon: "arrow.up.right.circle.fill", title: "Trends", query: "What are my spending trends over the last 3 months?"),
                SuggestedQuery(icon: "target", title: "Goals", query: "How close am I to my savings goals?")
            ]
        case .transactions:
            return [
                SuggestedQuery(icon: "magnifyingglass", title: "Find", query: "Find all transactions from Woolworths"),
                SuggestedQuery(icon: "tag.fill", title: "Categorize", query: "Help me categorize my uncategorized transactions"),
                SuggestedQuery(icon: "doc.text.fill", title: "Tax", query: "Which transactions are tax deductible?"),
                SuggestedQuery(icon: "divide.circle.fill", title: "Split", query: "How do I split a transaction for tax purposes?")
            ]
        case .gmail:
            return [
                SuggestedQuery(icon: "envelope.open.fill", title: "Extract", query: "Extract transactions from my recent emails"),
                SuggestedQuery(icon: "checkmark.circle.fill", title: "Review", query: "Show me receipts that need review"),
                SuggestedQuery(icon: "arrow.right.circle.fill", title: "Import", query: "How do I import a receipt to transactions?"),
                SuggestedQuery(icon: "questionmark.circle.fill", title: "Missing", query: "Are there any missing receipts I should look for?")
            ]
        case .settings:
            return [
                SuggestedQuery(icon: "key.fill", title: "API Keys", query: "How do I configure my API keys?"),
                SuggestedQuery(icon: "link.circle.fill", title: "Connect", query: "How do I connect my bank account?"),
                SuggestedQuery(icon: "gearshape.fill", title: "Automate", query: "What automation rules can I set up?"),
                SuggestedQuery(icon: "chart.bar.doc.horizontal.fill", title: "Health", query: "What does extraction health mean?")
            ]
        }
    }

    var placeholderText: String {
        switch self {
        case .dashboard:
            return "Ask about your spending, budget, or trends..."
        case .transactions:
            return "Search transactions, ask about categories..."
        case .gmail:
            return "Ask about receipts or extraction..."
        case .settings:
            return "Ask about settings or configuration..."
        }
    }

    // MARK: - Factory Method

    static func from(tabIndex: Int) -> ScreenContext {
        switch tabIndex {
        case 0: return .dashboard
        case 1: return .transactions
        case 2: return .gmail
        case 3: return .settings
        default: return .dashboard
        }
    }
}

// MARK: - Suggested Query Model

struct SuggestedQuery: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let query: String
}
