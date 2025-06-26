import SwiftUI

struct ModelSelectorView: View {
    @ObservedObject var frontierService: FrontierModelsService
    @State private var showingModelDetails = false
    @State private var selectedModelForDetails: FrontierModel?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                    .font(.title2)

                Text("AI Model")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { showingModelDetails = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Model List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(frontierService.availableModels) { model in
                        ModelRowView(
                            model: model,
                            isSelected: model == frontierService.selectedModel,
                            onSelect: {
                                frontierService.switchModel(model)
                            },
                            onInfo: {
                                selectedModelForDetails = model
                                showingModelDetails = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showingModelDetails) {
            if let model = selectedModelForDetails {
                ModelDetailView(model: model)
            } else {
                ModelOverviewView(models: frontierService.availableModels)
            }
        }
    }
}

struct ModelRowView: View {
    let model: FrontierModel
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Model Icon
            Image(systemName: model.icon)
                .foregroundColor(isSelected ? .white : providerColor(model.provider))
                .font(.system(size: 18))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? providerColor(model.provider) : providerColor(model.provider).opacity(0.1))
                )

            // Model Info
            VStack(alignment: .leading, spacing: 2) {
                Text(model.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(model.provider)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }

            Spacer()

            // Capabilities Badge
            if !model.capabilities.isEmpty {
                Text("\(model.capabilities.count) features")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.1))
                    )
                    .foregroundColor(isSelected ? .white : .secondary)
            }

            // Info Button
            Button(action: onInfo) {
                Image(systemName: "info.circle")
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    .font(.system(size: 14))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? providerColor(model.provider) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected ? Color.clear : Color.secondary.opacity(0.2),
                    lineWidth: 1
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func providerColor(_ provider: String) -> Color {
        switch provider {
        case "Anthropic": return .orange
        case "OpenAI": return .green
        case "Google": return .blue
        case "Perplexity": return .purple
        default: return .gray
        }
    }
}

struct ModelDetailView: View {
    let model: FrontierModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: model.icon)
                            .font(.system(size: 64))
                            .foregroundColor(providerColor(model.provider))

                        VStack(spacing: 8) {
                            Text(model.displayName)
                                .font(.title)
                                .fontWeight(.bold)

                            Text(model.provider)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                    // Capabilities
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Capabilities")
                            .font(.headline)
                            .fontWeight(.semibold)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(model.capabilities, id: \.self) { capability in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 12))

                                    Text(capability)
                                        .font(.subheadline)

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Use Cases
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Best For")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(getUseCases(for: model), id: \.self) { useCase in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.secondary)

                                    Text(useCase)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Model Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }

    private func providerColor(_ provider: String) -> Color {
        switch provider {
        case "Anthropic": return .orange
        case "OpenAI": return .green
        case "Google": return .blue
        case "Perplexity": return .purple
        default: return .gray
        }
    }

    private func getUseCases(for model: FrontierModel) -> [String] {
        switch model {
        case .claudeSonnet4:
            return [
                "Complex financial analysis and modeling",
                "Advanced document processing and extraction",
                "Strategic business planning and insights",
                "Sophisticated reasoning and problem-solving"
            ]
        case .claudeOpus4:
            return [
                "Expert-level financial consulting",
                "Complex multi-step analysis",
                "Research and investigation tasks",
                "High-stakes decision support"
            ]
        case .gpt41:
            return [
                "Creative financial reporting",
                "Multimodal document analysis",
                "Interactive financial planning",
                "Advanced reasoning and predictions"
            ]
        case .gemini25Pro:
            return [
                "Long-context financial document analysis",
                "Complex mathematical modeling",
                "Multi-format data processing",
                "Advanced pattern recognition"
            ]
        case .gpt4o:
            return [
                "Real-time financial insights",
                "Visual document processing",
                "Interactive analysis and Q&A",
                "Balanced performance for most tasks"
            ]
        case .claude35Sonnet:
            return [
                "General financial assistance",
                "Document processing and analysis",
                "Writing and communication",
                "Coding and automation tasks"
            ]
        case .gemini15Pro:
            return [
                "Research and information gathering",
                "Long document analysis",
                "Multimodal understanding",
                "Educational and explanatory content"
            ]
        case .perplexityPro:
            return [
                "Real-time market research",
                "Current financial news analysis",
                "Live data integration",
                "Fact-checking and verification"
            ]
        }
    }
}

struct ModelOverviewView: View {
    let models: [FrontierModel]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Introduction
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frontier AI Models")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("FinanceMate integrates with the most advanced AI models available, each optimized for different financial tasks and use cases.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    // Models by Provider
                    ForEach(["Anthropic", "OpenAI", "Google", "Perplexity"], id: \.self) { provider in
                        let providerModels = models.filter { $0.provider == provider }
                        if !providerModels.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(provider)
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                ForEach(providerModels) { model in
                                    HStack {
                                        Image(systemName: model.icon)
                                            .foregroundColor(providerColor(provider))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(model.displayName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)

                                            Text("\(model.capabilities.count) capabilities")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("AI Models")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 700)
    }

    private func providerColor(_ provider: String) -> Color {
        switch provider {
        case "Anthropic": return .orange
        case "OpenAI": return .green
        case "Google": return .blue
        case "Perplexity": return .purple
        default: return .gray
        }
    }
}

#Preview {
    ModelSelectorView(frontierService: FrontierModelsService())
        .frame(width: 300, height: 400)
}
