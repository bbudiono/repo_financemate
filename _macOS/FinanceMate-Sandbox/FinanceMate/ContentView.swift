// SANDBOX FILE: For testing/development. See .cursorrules.
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "ladybug.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("FinanceMate Sandbox")
        }
        .padding()
    }
}

#Preview {
    ContentView()
} 