import SwiftUI

struct ProfileView: View {
    @State private var username = "User"
    @State private var email = "user@example.com"
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Text("Username")
                    Spacer()
                    TextField("Username", text: $username)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 200)
                }
                
                HStack {
                    Text("Email")
                    Spacer()
                    TextField("Email", text: $email)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 200)
                }
            }
            
            Section {
                Button("Update Profile") {
                    // Update profile action
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: 600)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 