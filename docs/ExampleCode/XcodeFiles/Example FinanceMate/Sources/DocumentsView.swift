import SwiftUI

struct DocumentsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Documents")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your documents will appear here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsView()
    }
} 