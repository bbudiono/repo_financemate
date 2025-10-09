import SwiftUI

// MARK: - AI Model Selection Header

struct AIModelSelectionHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
            // Title Section with Icon
            HStack(alignment: .top, spacing: AIModelSelectionDesignSystem.Spacing.md) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                    Text("AI Model Configuration")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("LLM-as-a-Judge Architecture")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                }
            }

            // Description Cards
            VStack(spacing: AIModelSelectionDesignSystem.Spacing.md) {
                DescriptionCard(
                    icon: "gavel.fill",
                    title: "Judge Model",
                    description: "Evaluates AI responses for accuracy, quality, and compliance with financial standards.",
                    color: AIModelSelectionDesignSystem.Colors.success
                )

                DescriptionCard(
                    icon: "brain.head.profile.fill",
                    title: "Generator Models",
                    description: "Creates financial insights, categorization, and analysis content (up to 3 models).",
                    color: AIModelSelectionDesignSystem.Colors.accent
                )
            }

            // Status Overview
            StatusOverviewCard()
        }
        .padding(AIModelSelectionDesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [
                            AIModelSelectionDesignSystem.Colors.accent.opacity(0.05),
                            AIModelSelectionDesignSystem.Colors.cardBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Supporting Views

private struct DescriptionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: AIModelSelectionDesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                Text(title)
                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(description)
                    .font(AIModelSelectionDesignSystem.Typography.caption)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(AIModelSelectionDesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                .fill(color.opacity(0.08))
        )
    }
}

private struct StatusOverviewCard: View {
    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.lg) {
            StatusItem(
                icon: "shield.checkerboard",
                title: "Quality Control",
                description: "Automated response validation",
                color: AIModelSelectionDesignSystem.Colors.success
            )

            Divider()
                .frame(height: 40)

            StatusItem(
                icon: "person.2.fill",
                title: "Multi-Model",
                description: "Diverse AI perspectives",
                color: AIModelSelectionDesignSystem.Colors.accent
            )

            Divider()
                .frame(height: 40)

            StatusItem(
                icon: "gear.badge.checkmark",
                title: "Configurable",
                description: "Flexible model selection",
                color: AIModelSelectionDesignSystem.Colors.secondaryText
            )
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
}

private struct StatusItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(description)
                .font(.caption2)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}