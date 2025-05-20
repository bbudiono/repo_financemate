import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Welcome to DocketMate")
                .font(.title2)
            
            Text("This is the production version of the application")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 