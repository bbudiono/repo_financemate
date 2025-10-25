import SwiftUI

// WCAG 2.1 AA: 2.4.7 Focus Visible (BLUEPRINT Line 264)
// Focus indicator MUST have minimum 2px width and 3:1 contrast ratio

/// FocusIndicatorModifier adds a visible 2px blue outline when an element receives keyboard focus
/// Complies with WCAG 2.1 AA Level requirement (2.4.7 Focus Visible)
struct FocusIndicatorModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focusable()
            .focused($isFocused)
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.accentColor, lineWidth: 2)
                        .padding(-2) // Extend outline slightly beyond content
                }
            }
    }
}

/// Extension to easily apply accessible focus indicators to any View
extension View {
    /// Adds WCAG 2.1 AA compliant focus indicator (2px blue outline)
    /// - Returns: View with visible focus indicator when focused via keyboard navigation
    func accessibleFocus() -> some View {
        modifier(FocusIndicatorModifier())
    }
}

// MARK: - Custom Focus Ring for Interactive Elements

/// Custom focus ring for buttons and interactive controls
/// Uses Apple standard blue (#007AFF) with 2px width
struct AccessibleButtonStyle: ButtonStyle {
    @FocusState private var isFocused: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .focusable()
            .focused($isFocused)
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.accentColor, lineWidth: 2)
                        .padding(-4)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Focus Environment Keys

/// FocusedValues environment key for tracking currently focused element
struct FocusedElementKey: FocusedValueKey {
    typealias Value = String
}

extension FocusedValues {
    var focusedElement: FocusedElementKey.Value? {
        get { self[FocusedElementKey.self] }
        set { self[FocusedElementKey.self] = newValue }
    }
}
