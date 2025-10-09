import SwiftUI

// MARK: - Design System for AI Model Selection

/// Shared design system components for consistent AI Model Configuration UI
struct AIModelSelectionDesignSystem {

    // MARK: - Spacing Constants
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
    }

    // MARK: - Typography
    struct Typography {
        static let sectionTitle = Font.headline.weight(.semibold)
        static let subsectionTitle = Font.subheadline.weight(.medium)
        static let body = Font.body
        static let caption = Font.caption
        static let footnote = Font.footnote
    }

    // MARK: - Colors
    struct Colors {
        static let cardBackground = Color(.systemBackground)
        static let sectionBackground = Color(.secondarySystemGroupedBackground)
        static let accent = Color.blue
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let secondaryText = Color.secondary
        static let border = Color(.separator)
    }

    // MARK: - Shadow
    struct Shadow {
        static let card = Color.black.opacity(0.05)
        static let cardRadius: CGFloat = 2
        static let cardOffset: CGSize = .init(width: 0, height: 1)
    }
}

// MARK: - Reusable Components

/// Enhanced section header with better visual hierarchy
struct EnhancedSectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String?

    init(title: String, subtitle: String, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    var body: some View {
        HStack(alignment: .top, spacing: AIModelSelectionDesignSystem.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                Text(title)
                    .font(AIModelSelectionDesignSystem.Typography.sectionTitle)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(AIModelSelectionDesignSystem.Typography.footnote)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

/// Enhanced card container with consistent styling
struct EnhancedCard<Content: View>: View {
    let content: Content
    let padding: CGFloat

    init(padding: CGFloat = AIModelSelectionDesignSystem.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(padding)
        .background(AIModelSelectionDesignSystem.Colors.cardBackground)
        .cornerRadius(AIModelSelectionDesignSystem.CornerRadius.large)
        .shadow(
            color: AIModelSelectionDesignSystem.Shadow.card,
            radius: AIModelSelectionDesignSystem.Shadow.cardRadius,
            x: AIModelSelectionDesignSystem.Shadow.cardOffset.width,
            y: AIModelSelectionDesignSystem.Shadow.cardOffset.height
        )
    }
}

/// Enhanced row component for consistent model display
struct EnhancedModelRow<Content: View, Trailing: View>: View {
    let content: Content
    let trailing: Trailing?
    let isSelected: Bool
    let isEnabled: Bool
    let action: (() -> Void)?

    init(
        isSelected: Bool = false,
        isEnabled: Bool = true,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder trailing: () -> Trailing?
    ) {
        self.content = content()
        self.trailing = trailing()
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(EnhancedButtonStyle(isSelected: isSelected, isEnabled: isEnabled))
            } else {
                rowContent
            }
        }
    }

    private var rowContent: some View {
        HStack(alignment: .top, spacing: AIModelSelectionDesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                content
            }

            Spacer(minLength: AIModelSelectionDesignSystem.Spacing.sm)

            if let trailing = trailing {
                trailing
            }
        }
        .padding(AIModelSelectionDesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                .fill(isSelected ? AIModelSelectionDesignSystem.Colors.accent.opacity(0.1) : AIModelSelectionDesignSystem.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                        .stroke(isSelected ? AIModelSelectionDesignSystem.Colors.accent : AIModelSelectionDesignSystem.Colors.border, lineWidth: isSelected ? 2 : 1)
                )
        )
    }
}

/// Enhanced button style for better accessibility and visual feedback
struct EnhancedButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Status indicator with improved visual design
struct EnhancedStatusIndicator: View {
    let status: Status
    let text: String

    enum Status {
        case healthy, unhealthy, checking, unknown

        var color: Color {
            switch self {
            case .healthy: return AIModelSelectionDesignSystem.Colors.success
            case .unhealthy: return AIModelSelectionDesignSystem.Colors.error
            case .checking: return AIModelSelectionDesignSystem.Colors.warning
            case .unknown: return AIModelSelectionDesignSystem.Colors.secondaryText
            }
        }

        var icon: String {
            switch self {
            case .healthy: return "checkmark.circle.fill"
            case .unhealthy: return "xmark.circle.fill"
            case .checking: return "clock.fill"
            case .unknown: return "questionmark.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            Image(systemName: status.icon)
                .font(.caption)
                .foregroundColor(status.color)

            Text(text)
                .font(AIModelSelectionDesignSystem.Typography.caption)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
        }
        .padding(.horizontal, AIModelSelectionDesignSystem.Spacing.sm)
        .padding(.vertical, AIModelSelectionDesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(status.color.opacity(0.1))
        )
    }
}

/// Loading state with better visual design
struct EnhancedLoadingView: View {
    let message: String

    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(0.8)

            Text(message)
                .font(AIModelSelectionDesignSystem.Typography.body)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(AIModelSelectionDesignSystem.Spacing.xl)
    }
}

/// Empty state with better visual design
struct EnhancedEmptyState: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AIModelSelectionDesignSystem.Spacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)

            VStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                Text(title)
                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(AIModelSelectionDesignSystem.Typography.body)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AIModelSelectionDesignSystem.Spacing.xxl)
    }
}