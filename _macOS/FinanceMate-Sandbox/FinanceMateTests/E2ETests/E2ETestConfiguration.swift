import XCTest

// Configuration for E2E tests with proper accessibility identifiers
struct E2ETestConfiguration {
    // Accessibility identifiers for UI elements
    struct AccessibilityIdentifiers {
        // Authentication screen
        static let welcomeText = "Welcome to FinanceMate"
        static let signInWithAppleButton = "Sign In with Apple"
        static let signInWithGoogleButton = "Sign In with Google"

        // Main navigation
        static let dashboardButton = "Dashboard"
        static let documentsButton = "Documents"
        static let analyticsButton = "Analytics"
        static let settingsButton = "Settings"

        // Dashboard elements
        static let mainDashboardView = "mainDashboardView"
        static let totalBalanceLabel = "totalBalanceLabel"
        static let recentTransactionsTable = "recentTransactionsTable"
    }

    // Timeouts
    struct Timeouts {
        static let uiElement: TimeInterval = 5.0
        static let authentication: TimeInterval = 10.0
        static let networkRequest: TimeInterval = 15.0
    }

    // Test data
    struct TestCredentials {
        static let testUsername = "test@example.com"
        static let testPassword = "TestPassword123!"
    }
}

// Extension to add accessibility identifiers to the app
extension View {
    func e2eAccessibilityIdentifier(_ identifier: String) -> some View {
        self.accessibilityIdentifier(identifier)
            .accessibilityElement(children: .contain)
    }
}
