import SwiftUI

// MARK: - Action Buttons

struct AIModelActionButtons: View {
    let onRefreshModels: () -> Void
    let onSaveConfiguration: () -> Void
    let onResetConfiguration: () -> Void

    var body: some View {
        EnhancedCard(padding: AIModelSelectionDesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                EnhancedSectionHeader(
                    title: "Actions",
                    subtitle: "Manage your AI model configuration and settings",
                    icon: "gearshape.2"
                )

                VStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
                    // Primary Action
                    PrimaryActionButton(
                        title: "Save Configuration",
                        icon: "checkmark.circle.fill",
                        action: onSaveConfiguration
                    )

                    // Secondary Actions
                    VStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                        SecondaryActionButton(
                            title: "Refresh Models",
                            icon: "arrow.clockwise",
                            description: "Discover new local and cloud models",
                            action: onRefreshModels
                        )

                        DestructiveActionButton(
                            title: "Reset to Defaults",
                            icon: "arrow.counterclockwise",
                            description: "Restore original configuration settings",
                            action: onResetConfiguration
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Action Button Components

private struct PrimaryActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.headline)

                Text(title)
                    .font(AIModelSelectionDesignSystem.Typography.body)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(AIModelSelectionDesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                    .fill(AIModelSelectionDesignSystem.Colors.accent)
            )
            .foregroundColor(.white)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct SecondaryActionButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                    Text(title)
                        .font(AIModelSelectionDesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(AIModelSelectionDesignSystem.Typography.caption)
                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
            }
            .padding(AIModelSelectionDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                    .fill(AIModelSelectionDesignSystem.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                            .stroke(AIModelSelectionDesignSystem.Colors.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct DestructiveActionButton: View {
    let title: String
    let icon: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.error)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                    Text(title)
                        .font(AIModelSelectionDesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(AIModelSelectionDesignSystem.Colors.error)

                    Text(description)
                        .font(AIModelSelectionDesignSystem.Typography.caption)
                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
            }
            .padding(AIModelSelectionDesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                    .fill(AIModelSelectionDesignSystem.Colors.error.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                            .stroke(AIModelSelectionDesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Custom Button Styles

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}