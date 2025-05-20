import SwiftUI

/// A placeholder view for Evidence Tagging (sandbox version)
struct EvidenceTaggingPlaceholderView_sandbox: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tag.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.accentColor)
            Text("Evidence Tagging")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tag and organize evidence for moderation")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Evidence Tagging Placeholder")
        .accessibilityIdentifier("evidence_tagging_placeholder")
        // Test identifier for UI testing
        .modifier(TestIdentifierModifier(identifier: "evidence_tagging_placeholder"))
    }
}

/// Custom view modifier for test identifiers (used in ExampleCode patterns)
struct TestIdentifierModifier: ViewModifier {
    let identifier: String
    func body(content: Content) -> some View {
        #if DEBUG
        content.accessibilityIdentifier(identifier)
        #else
        content
        #endif
    }
}

// MARK: - Preview
struct EvidenceTaggingPlaceholderView_sandbox_Previews: PreviewProvider {
    static var previews: some View {
        EvidenceTaggingPlaceholderView_sandbox()
            .previewLayout(.sizeThatFits)
    }
} 