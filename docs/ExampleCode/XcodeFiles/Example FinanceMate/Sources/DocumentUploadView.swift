import SwiftUI

struct DocumentUploadView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload Documents")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Drag and drop files here or click to browse")
                .foregroundColor(.secondary)
            
            Button("Select Files") {
                // File selection action
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DocumentUploadView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentUploadView()
    }
} 