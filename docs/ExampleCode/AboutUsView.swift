import SwiftUI

/// AboutUsView displays information about the app, team, and credits.
struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Text("About Picketmate")
                    .font(.largeTitle)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                Text("Picketmate is a modern macOS app designed to help users manage their digital life with ease and security.")
                    .font(.body)
                Divider()
                Text("Team")
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                Text("- Jane Doe (Lead Developer)\n- John Smith (Product Manager)\n- Alice Lee (UX Designer)")
                    .font(.body)
                Divider()
                Text("Credits")
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                Text("Thanks to the open-source community and all contributors.")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("About Us")
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    AboutUsView()
} 