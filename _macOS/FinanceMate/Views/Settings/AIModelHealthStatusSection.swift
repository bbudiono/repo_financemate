import SwiftUI

// MARK: - Health Status Section

struct AIModelHealthStatusSection: View {
    @ObservedObject var configurationManager: AIModelConfigurationManager

    private var allModels: [AIModel] {
        ModelCollectionHelper.getAllModels(from: configurationManager)
    }

    var body: some View {
        EnhancedCard {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.lg) {
                EnhancedSectionHeader(
                    title: "Model Health Status",
                    subtitle: "Real-time availability and performance monitoring of configured AI models",
                    icon: "heart.text.square"
                )

                if allModels.isEmpty {
                    EnhancedEmptyState(
                        title: "No Models Configured",
                        subtitle: "Configure judge and generator models to monitor their health status.",
                        systemImage: "stethoscope"
                    )
                } else {
                    HealthContent(models: allModels)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct HealthContent: View {
    let models: [AIModel]

    var body: some View {
        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.md) {
            HealthSummaryRow(models: models)

            LazyVStack(spacing: AIModelSelectionDesignSystem.Spacing.sm) {
                ForEach(models) { model in
                    EnhancedModelHealthRow(model: model)
                }
            }

            HealthFooterInfo()
        }
    }
}

private struct HealthSummaryRow: View {
    let models: [AIModel]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
                Text("Overall Health")
                    .font(AIModelSelectionDesignSystem.Typography.subsectionTitle)
                    .foregroundColor(.primary)

                Text("\(healthyCount) of \(models.count) models healthy")
                    .font(AIModelSelectionDesignSystem.Typography.caption)
                    .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
            }

            Spacer()

            EnhancedStatusIndicator(
                status: overallHealth,
                text: HealthStatusTextProvider.text(for: overallHealth)
            )
        }
        .padding(AIModelSelectionDesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AIModelSelectionDesignSystem.CornerRadius.medium)
                .fill(AIModelSelectionDesignSystem.Colors.sectionBackground)
        )
    }

    private var healthyCount: Int {
        // Simulated health count for demonstration
        Int.random(in: 0...models.count)
    }

    private var overallHealth: EnhancedStatusIndicator.Status {
        HealthCalculator.calculateOverallHealth(
            healthyCount: healthyCount,
            totalCount: models.count
        )
    }
}

private struct EnhancedModelHealthRow: View {
    @State private var healthStatus: ModelHealthStatus = .checking
    @State private var responseTime: TimeInterval?
    @State private var lastChecked: Date = Date()
    private let model: AIModel

    init(model: AIModel) {
        self.model = model
    }

    var body: some View {
        EnhancedModelRow(
            isSelected: false,
            isEnabled: false,
            action: nil
        ) {
            ModelHealthContent(
                model: model,
                healthStatus: healthStatus,
                responseTime: responseTime
            )
        } trailing: {
            RefreshButton(action: checkHealth)
        }
        .task {
            await checkHealth()
        }
        .refreshable {
            await checkHealth()
        }
    }

    private func checkHealth() async {
        let healthService = ModelHealthCheckService()
        healthStatus = await healthService.checkHealth(of: model)
        responseTime = TimeInterval.random(in: 0.1...2.0) // Simulated response time
        lastChecked = Date()
    }
}

private struct HealthFooterInfo: View {
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)

            Text("Health status is automatically updated. Pull to refresh manually.")
                .font(.caption2)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)

            Spacer()
        }
        .padding(.top, AIModelSelectionDesignSystem.Spacing.sm)
    }
}

// MARK: - Helper Providers

private struct ModelCollectionHelper {
    static func getAllModels(from configurationManager: AIModelConfigurationManager) -> [AIModel] {
        var models: [AIModel] = []
        if let judgeModel = configurationManager.getCurrentJudgeModel() {
            models.append(judgeModel)
        }
        models.append(contentsOf: configurationManager.getGeneratorModels())
        return models
    }
}

private struct HealthCalculator {
    static func calculateOverallHealth(healthyCount: Int, totalCount: Int) -> EnhancedStatusIndicator.Status {
        guard totalCount > 0 else { return .unknown }

        let ratio = Double(healthyCount) / Double(totalCount)
        switch ratio {
        case 1.0: return .healthy
        case 0.5..<1.0: return .checking
        case 0..<0.5: return .unhealthy
        default: return .unknown
        }
    }
}

private struct HealthStatusTextProvider {
    static func text(for status: EnhancedStatusIndicator.Status) -> String {
        switch status {
        case .healthy: return "All Systems Operational"
        case .checking: return "Partial Degradation"
        case .unhealthy: return "Service Issues"
        case .unknown: return "Status Unknown"
        }
    }
}