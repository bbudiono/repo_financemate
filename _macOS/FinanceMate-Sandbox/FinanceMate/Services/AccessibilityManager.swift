import AppKit
import Foundation
import SwiftUI

// MARK: - Accessibility Manager

@MainActor
public class AccessibilityManager: ObservableObject {
    @Published public var isVoiceOverEnabled: Bool = false
    @Published public var isReduceMotionEnabled: Bool = false
    @Published public var preferredContentSizeCategory: ContentSizeCategory = .medium
    @Published public var isHighContrastEnabled: Bool = false

    private var notificationCenter = NSWorkspace.shared.notificationCenter

    public static let shared = AccessibilityManager()

    private init() {
        updateAccessibilitySettings()
        setupNotifications()
    }

    // MARK: - Public Methods

    public func updateAccessibilitySettings() {
        // Check VoiceOver status
        isVoiceOverEnabled = NSWorkspace.shared.isVoiceOverEnabled

        // Check Reduce Motion
        isReduceMotionEnabled = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion

        // Check High Contrast
        isHighContrastEnabled = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast

        // Update content size category based on system preferences
        updateContentSizeCategory()
    }

    public func announceForAccessibility(_ message: String) {
        guard isVoiceOverEnabled else { return }

        DispatchQueue.main.async {
            NSAccessibility.post(
                element: NSApp.mainWindow as Any,
                notification: .announcementRequested,
                userInfo: [.announcement: message]
            )
        }
    }

    public func setAccessibilityFocus(to element: Any) {
        guard isVoiceOverEnabled else { return }

        NSAccessibility.post(
            element: element,
            notification: .focusedUIElementChanged
        )
    }

    // MARK: - Keyboard Navigation Support

    public func handleKeyboardNavigation(_ keyCode: UInt16) -> Bool {
        switch keyCode {
        case 36: // Return key
            return handleReturnKey()
        case 48: // Tab key
            return handleTabKey()
        case 53: // Escape key
            return handleEscapeKey()
        case 49: // Space key
            return handleSpaceKey()
        default:
            return false
        }
    }

    private func handleReturnKey() -> Bool {
        announceForAccessibility("Action activated")
        return true
    }

    private func handleTabKey() -> Bool {
        announceForAccessibility("Focus moved to next element")
        return true
    }

    private func handleEscapeKey() -> Bool {
        announceForAccessibility("Dialog dismissed")
        return true
    }

    private func handleSpaceKey() -> Bool {
        announceForAccessibility("Button activated")
        return true
    }

    // MARK: - WCAG 2.1 Compliance

    public func validateColorContrast(foreground: NSColor, background: NSColor) -> ContrastValidationResult {
        let contrastRatio = calculateContrastRatio(foreground: foreground, background: background)

        return ContrastValidationResult(
            ratio: contrastRatio,
            passesAA: contrastRatio >= 4.5,
            passesAAA: contrastRatio >= 7.0,
            passesLargeTextAA: contrastRatio >= 3.0
        )
    }

    private func calculateContrastRatio(foreground: NSColor, background: NSColor) -> Double {
        let fgLuminance = getLuminance(color: foreground)
        let bgLuminance = getLuminance(color: background)

        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    private func getLuminance(color: NSColor) -> Double {
        guard let rgbColor = color.usingColorSpace(.deviceRGB) else { return 0 }

        let red = linearizeColorComponent(rgbColor.redComponent)
        let green = linearizeColorComponent(rgbColor.greenComponent)
        let blue = linearizeColorComponent(rgbColor.blueComponent)

        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }

    private func linearizeColorComponent(_ component: CGFloat) -> Double {
        let value = Double(component)
        if value <= 0.03928 {
            return value / 12.92
        } else {
            return pow((value + 0.055) / 1.055, 2.4)
        }
    }

    // MARK: - Dynamic Type Support

    private func updateContentSizeCategory() {
        // Map system text size to ContentSizeCategory
        // This is a simplified implementation
        let systemTextSize = NSFont.systemFontSize

        switch systemTextSize {
        case 0..<11:
            preferredContentSizeCategory = .extraSmall
        case 11..<12:
            preferredContentSizeCategory = .small
        case 12..<13:
            preferredContentSizeCategory = .medium
        case 13..<15:
            preferredContentSizeCategory = .large
        case 15..<17:
            preferredContentSizeCategory = .extraLarge
        case 17..<19:
            preferredContentSizeCategory = .extraExtraLarge
        case 19..<21:
            preferredContentSizeCategory = .extraExtraExtraLarge
        default:
            preferredContentSizeCategory = .accessibilityMedium
        }
    }

    // MARK: - Notifications Setup

    private func setupNotifications() {
        notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateAccessibilitySettings()
            }
        }
    }

    deinit {
        notificationCenter.removeObserver(self)
    }
}

// MARK: - Supporting Types

public struct ContrastValidationResult {
    public let ratio: Double
    public let passesAA: Bool
    public let passesAAA: Bool
    public let passesLargeTextAA: Bool

    public var wcagLevel: WCAGLevel {
        if passesAAA {
            return .aaa
        } else if passesAA {
            return .aa
        } else if passesLargeTextAA {
            return .largeTextAA
        } else {
            return .fails
        }
    }
}

public enum WCAGLevel: String, CaseIterable {
    case aaa = "WCAG AAA"
    case aa = "WCAG AA"
    case largeTextAA = "WCAG AA (Large Text)"
    case fails = "Does not meet WCAG standards"

    public var description: String {
        switch self {
        case .aaa:
            return "Exceeds accessibility standards (7:1 contrast ratio)"
        case .aa:
            return "Meets accessibility standards (4.5:1 contrast ratio)"
        case .largeTextAA:
            return "Meets large text accessibility standards (3:1 contrast ratio)"
        case .fails:
            return "Does not meet minimum accessibility standards"
        }
    }
}

// MARK: - Accessibility Extensions

extension NSWorkspace {
    var isVoiceOverEnabled: Bool {
        NSWorkspace.shared.isVoiceOverEnabled
    }
}

extension View {
    // MARK: - Enhanced Accessibility Modifiers

    func accessibilityEnhanced(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = [],
        identifier: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
            .if(identifier != nil) { view in
                view.accessibilityIdentifier(identifier!)
            }
    }

    func accessibilityGroup(label: String) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
    }

    func accessibilityKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        self
            .keyboardShortcut(key, modifiers: modifiers)
            .accessibilityHint("Keyboard shortcut: \(modifiers.description) + \(key.description)")
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension EventModifiers {
    var description: String {
        var parts: [String] = []
        if contains(.command) { parts.append("⌘") }
        if contains(.option) { parts.append("⌥") }
        if contains(.control) { parts.append("⌃") }
        if contains(.shift) { parts.append("⇧") }
        return parts.joined()
    }
}

extension KeyEquivalent {
    var description: String {
        switch self {
        case .return: return "Return"
        case .escape: return "Escape"
        case .space: return "Space"
        case .tab: return "Tab"
        case .delete: return "Delete"
        case .upArrow: return "↑"
        case .downArrow: return "↓"
        case .leftArrow: return "←"
        case .rightArrow: return "→"
        default: return String(character)
        }
    }
}
