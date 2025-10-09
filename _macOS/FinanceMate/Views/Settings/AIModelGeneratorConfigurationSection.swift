import SwiftUI

// MARK: - Generator Models Configuration Section

struct AIModelGeneratorConfigurationSection: View {
    @ObservedObject var configurationManager: AIModelConfigurationManager
    @Binding var availableCloudModels: [AIModel]
    let onAddGeneratorModel: (AIModel) -> Void
    let onRemoveGeneratorModel: (AIModel) -> Void

    private var generatorModels: [AIModel] {
        configurationManager.getGeneratorModels()
    }

    private var remainingSlots: Int {
        max(0, 3 - generatorModels.count)
    }

    var body: some View {
        EnhancedCard {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                EnhancedSectionHeader(
                    title: "Generator Models",
                    subtitle: "Select up to 3 models to generate AI responses and financial insights",
                    icon: "brain.head.profile"
                )

                VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                    // Progress Indicator
                    GeneratorProgressIndicator(
                        currentCount: generatorModels.count,
                        maxCount: 3
                    )

                    // Configured Models Section
                    if !generatorModels.isEmpty {
                        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.md) {
                            HStack {
                                Text("Configured Models")
                                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(generatorModels.count)/3 slots used")
                                    .font(AIModelSelectionDesignSystem.Typography.caption)
                                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                            }

                            LazyVStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                                ForEach(generatorModels) { model in
                                    EnhancedModelRow(
                                        isSelected: true,
                                        isEnabled: false,
                                        action: nil
                                    ) {
                                        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                                            HStack {
                                                Text(model.name)
                                                    .font(AIModelSelectionDesignSystem.Typography.body)
                                                    .fontWeight(.medium)

                                                Spacer()

                                                ModelTypeBadge(type: model.type)
                                            }

                                            HStack {
                                                Image(systemName: providerIcon(for: model.provider))
                                                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                                    .font(.caption)

                                                Text("\(model.provider.rawValue) • \(model.type.rawValue)")
                                                    .font(AIModelSelectionDesignSystem.Typography.caption)
                                                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                            }
                                        }
                                    } trailing: {
                                        Button("Remove", role: .destructive) {
                                            onRemoveGeneratorModel(model)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                            }
                        }
                    }

                    // Available Models Section
                    if remainingSlots > 0 {
                        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.md) {
                            HStack {
                                Text("Available Cloud Models")
                                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(availableCloudModels.count) available")
                                    .font(AIModelSelectionDesignSystem.Typography.caption)
                                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                            }

                            if !availableCloudModels.isEmpty {
                                LazyVStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                                    ForEach(availableCloudModels) { model in
                                        EnhancedModelRow(
                                            isSelected: false,
                                            isEnabled: true,
                                            action: { onAddGeneratorModel(model) }
                                        ) {
                                            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                                                HStack {
                                                    Text(model.name)
                                                        .font(AIModelSelectionDesignSystem.Typography.body)
                                                        .fontWeight(.medium)

                                                    Spacer()

                                                    ModelTypeBadge(type: model.type)
                                                }

                                                HStack {
                                                    Image(systemName: "cloud")
                                                        .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                                                        .font(.caption)

                                                    Text("Cloud • \(model.provider.rawValue)")
                                                        .font(AIModelSelectionDesignSystem.Typography.caption)
                                                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                                }
                                            }
                                        } trailing: {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                                                .font(.title3)
                                        }
                                    }
                                }
                            } else {
                                EnhancedEmptyState(
                                    title: "No Cloud Models Available",
                                    subtitle: "Check your internet connection and API credentials to discover available models.",
                                    systemImage: "icloud.slash"
                                )
                            }
                        }
                    }

                    // Maximum Reached Notice
                    if generatorModels.count >= 3 {
                        EnhancedStatusIndicator(
                            status: .healthy,
                            text: "Maximum generator models configured"
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, AIModelSelectionDesignSystem.Spacing.sm)
                    }
                }
            }
        }
    }

    private func providerIcon(for provider: AIModelProvider) -> String {
        switch provider {
        case .openai: return "brain.head.profile"
        case .anthropic: return "brain.head.profile"
        case .google: return "brain.head.profile"
        case .ollama: return "cpu"
        case .azure: return "brain.head.profile"
        }
    }
}

// MARK: - Supporting Views

private struct GeneratorProgressIndicator: View {
    let currentCount: Int
    let maxCount: Int

    private var progress: Double {
        Double(currentCount) / Double(maxCount)
    }

    private var progressColor: Color {
        switch currentCount {
        case 0: return AIModelSelectionDesignSystem.Colors.error
        case 1: return AIModelSelectionDesignSystem.Colors.warning
        case 2: return AIModelSelectionDesignSystem.Colors.accent
        case 3: return AIModelSelectionDesignSystem.Colors.success
        default: return AIModelSelectionDesignSystem.Colors.secondaryText
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.sm) {
            HStack {
                Text("Model Slots")
                    .font(AIModelSelectionDesignSystem.Typography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(currentCount) of \(maxCount)")
                    .font(AIModelSelectionDesignSystem.Typography.caption)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(y: 1.5)
        }
        .padding(AIModelSelectionDesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                .fill(AIModelSelectionDesignSystem.Colors.sectionBackground)
        )
    }
}

private struct ModelTypeBadge: View {
    let type: AIModelType

    private var typeColor: Color {
        switch type {
        case .cloud: return AIModelSelectionDesignSystem.Colors.accent
        case .local: return AIModelSelectionDesignSystem.Colors.success
        }
    }

    private var typeIcon: String {
        switch type {
        case .cloud: return "cloud.fill"
        case .local: return "cpu.fill"
        }
    }

    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            Image(systemName: typeIcon)
                .font(.caption2)

            Text(type.rawValue.capitalized)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, AIModelSelectionDesignSystem.Spacing.sm)
        .padding(.vertical, AIModelSelectionDesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(typeColor.opacity(0.15))
        )
        .foregroundColor(typeColor)
    }
}