import SwiftUI

// MARK: - Model Health Components

private struct ModelHealthContent: View {
    let model: AIModel
    let healthStatus: ModelHealthStatus
    let responseTime: TimeInterval?

    var body: some View {
        VStack(alignment: .leading, spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            ModelNameHeader(model: model)
            ModelProviderInfo(model: model)
            ModelHealthDetails(healthStatus: healthStatus, responseTime: responseTime)
        }
    }
}

private struct ModelNameHeader: View {
    let model: AIModel

    var body: some View {
        HStack {
            Text(model.name)
                .font(AIModelSelectionDesignSystem.Typography.body)
                .fontWeight(.medium)

            Spacer()

            ModelRoleBadge(role: model.type == .local ? "Judge" : "Generator")
        }
    }
}

private struct ModelProviderInfo: View {
    let model: AIModel

    var body: some View {
        HStack {
            Image(systemName: ModelIconProvider.icon(for: model.provider))
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
                .font(.caption)

            Text("\(model.provider.rawValue) • \(model.type.rawValue)")
                .font(AIModelSelectionDesignSystem.Typography.caption)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
        }
    }
}

private struct ModelHealthDetails: View {
    let healthStatus: ModelHealthStatus
    let responseTime: TimeInterval?

    var body: some View {
        HStack {
            EnhancedStatusIndicator(
                status: HealthStatusConverter.convert(healthStatus),
                text: healthStatus.displayText
            )

            Spacer()

            if let responseTime = responseTime {
                ResponseTimeIndicator(time: responseTime)
            }
        }
    }
}

private struct RefreshButton: View {
    let action: () async -> Void

    var body: some View {
        Button("Refresh") {
            Task {
                await action()
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.mini)
    }
}

private struct ResponseTimeIndicator: View {
    let time: TimeInterval

    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            Image(systemName: "clock")
                .font(.caption2)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)

            Text(String(format: "%.0fms", time * 1000))
                .font(.caption2)
                .foregroundColor(AIModelSelectionDesignSystem.Colors.secondaryText)
        }
    }
}

private struct ModelRoleBadge: View {
    let role: String

    private var roleColor: Color {
        switch role {
        case "Judge": return AIModelSelectionDesignSystem.Colors.success
        case "Generator": return AIModelSelectionDesignSystem.Colors.accent
        default: return AIModelSelectionDesignSystem.Colors.secondaryText
        }
    }

    private var roleIcon: String {
        switch role {
        case "Judge": return "gavel.fill"
        case "Generator": return "brain.head.profile.fill"
        default: return "questionmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: AIModelSelectionDesignSystem.Spacing.xs) {
            Image(systemName: roleIcon)
                .font(.caption2)

            Text(role)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, AIModelSelectionDesignSystem.Spacing.sm)
        .padding(.vertical, AIModelSelectionDesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(roleColor.opacity(0.15))
        )
        .foregroundColor(roleColor)
    }
}

// Helper providers to reduce complexity
private struct ModelIconProvider {
    static func icon(for provider: AIModelProvider) -> String {
        switch provider {
        case .openai, .anthropic, .google, .azure: return "brain.head.profile"
        case .ollama: return "cpu"
        }
    }
}

private struct HealthStatusConverter {
    static func convert(_ status: ModelHealthStatus) -> EnhancedStatusIndicator.Status {
        switch status {
        case .healthy: return .healthy
        case .unhealthy: return .unhealthy
        case .checking: return .checking
        case .unknown: return .unknown
        }
    }
}