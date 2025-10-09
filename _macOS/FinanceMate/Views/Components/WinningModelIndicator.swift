import SwiftUI

/// UI component to display the winning model that generated an AI response
/// BLUEPRINT.md 3.1.1.9: Transparency in AI model selection and response generation
struct WinningModelIndicator: View {
    let modelName: String
    let modelProvider: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(modelName)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("•")
                .font(.caption2)
                .foregroundColor(.tertiary)

            Text(modelProvider)
                .font(.caption2)
                .foregroundColor(.tertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray6))
        )
    }
}

/// Extension to detect winning model from AI response telemetry
extension WinningModelIndicator {
    init? (response: String, telemetry: [String: Any]) {
        guard let winningModel = telemetry["winning_model"] as? String else {
            return nil
        }

        let modelInfo = parseModelInfo(winningModel)
        self.init(modelName: modelInfo.name, modelProvider: modelInfo.provider)
    }

    private struct ModelInfo {
        let name: String
        let provider: String
    }

    private func parseModelInfo(_ modelId: String) -> ModelInfo {
        // Parse model ID to extract name and provider
        let components = modelId.components(separatedBy: ":")

        let provider = components.first ?? "Unknown"
        let name = components.last ?? modelId

        return ModelInfo(name: name, provider: provider)
    }
}

#Preview {
    VStack(spacing: 8) {
        WinningModelIndicator(modelName: "GPT-4", modelProvider: "OpenAI")
        WinningModelIndicator(modelName: "Claude-3.5-Sonnet", modelProvider: "Anthropic")
        WinningModelIndicator(modelName: "Llama-3.2", modelProvider: "Ollama")
    }
    .padding()
}