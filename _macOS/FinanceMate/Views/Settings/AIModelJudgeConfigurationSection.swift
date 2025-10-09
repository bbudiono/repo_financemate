import SwiftUI

// MARK: - Judge Model Configuration Section

struct AIModelJudgeConfigurationSection: View {
    @ObservedObject var configurationManager: AIModelConfigurationManager
    @Binding var availableLocalModels: [AIModel]
    let isLoadingModels: Bool
    let onSelectJudgeModel: (AIModel) -> Void
    let onRemoveJudgeModel: () -> Void

    var body: some View {
        EnhancedCard {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                EnhancedSectionHeader(
                    title: "Judge Model",
                    subtitle: "Select a local Ollama model to evaluate AI responses and ensure quality control",
                    icon: "gavel"
                )

                if isLoadingModels {
                    EnhancedLoadingView(message: "Discovering local models...")
                } else {
                    VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                        // Current Judge Model Section
                        if let currentJudgeModel = configurationManager.getCurrentJudgeModel() {
                            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.md) {
                                Text("Current Judge Model")
                                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                                    .foregroundColor(.primary)

                                EnhancedModelRow(
                                    isSelected: true,
                                    isEnabled: false,
                                    action: nil
                                ) {
                                    VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                                        Text(currentJudgeModel.name)
                                            .font(AIModelSelectionDesignSystem.Typography.body)
                                            .fontWeight(.medium)

                                        HStack {
                                            Image(systemName: "checkmark.shield.fill")
                                                .foregroundColor(AIModelSelectionDesignSystem.Colors.success)
                                                .font(.caption)

                                            Text("Active Judge Model")
                                                .font(AIModelSelectionDesignSystem.Typography.caption)
                                                .foregroundColor(AIModelSelectionDesignSystem.Colors.success)
                                        }
                                    }
                                } trailing: {
                                    Button("Remove", role: .destructive) {
                                        onRemoveJudgeModel()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                        }

                        // Available Models Section
                        if !availableLocalModels.isEmpty {
                            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.md) {
                                HStack {
                                    Text("Available Local Models")
                                        .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Text("\(availableLocalModels.count) models")
                                        .font(AIModelSelectionDesignSystem.Typography.caption)
                                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                }

                                LazyVStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                                    ForEach(availableLocalModels) { model in
                                        EnhancedModelRow(
                                            isSelected: false,
                                            isEnabled: true,
                                            action: { onSelectJudgeModel(model) }
                                        ) {
                                            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                                                Text(model.name)
                                                    .font(AIModelSelectionDesignSystem.Typography.body)
                                                    .fontWeight(.medium)

                                                HStack {
                                                    Image(systemName: "cpu")
                                                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                                        .font(.caption)

                                                    Text("Local • \(model.provider.rawValue)")
                                                        .font(AIModelSelectionDesignSystem.Typography.caption)
                                                        .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                                                }
                                            }
                                        } trailing: {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(AIModelSelectionDesignSystem.Colors.accent)
                                                .font(.title3)
                                        }
                                    }
                                }
                            }
                        } else if configurationManager.getCurrentJudgeModel() == nil {
                            EnhancedEmptyState(
                                title: "No Local Models Found",
                                subtitle: "Make sure Ollama is running and has models installed, or check your network connection.",
                                systemImage: "server.rack"
                            )
                        }
                    }
                }
            }
        }
    }
}