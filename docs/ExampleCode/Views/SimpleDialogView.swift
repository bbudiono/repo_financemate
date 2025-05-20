import SwiftUI

struct SimpleDialogView: View {
    @Binding var isPresented: Bool
    @AppStorage("dontShowDialog") private var dontShowDialog = false
    @State private var appear = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay with blur effect
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        appear = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                    }
                }
            
            // Dialog content
            VStack(spacing: 24) {
                // Header with app logo and close button
                HStack {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("WELCOME TO")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        Text("EduTrackQLD")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            appear = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
                
                // Visual divider
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.2))
                
                // Main content area
                VStack(spacing: 20) {
                    // Icon with animation
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 110, height: 110)
                        
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "graduationcap.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(appear ? 0 : -30))
                            .scaleEffect(appear ? 1 : 0.7)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
                    }
                    .padding(.top, 10)
                    
                    // Welcome message
                    Text("Track student progress with ease")
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("This powerful educational tracking system helps Queensland educators maintain comprehensive student records, track curriculum alignment, and generate detailed reports.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    
                    // Features bullets
                    HStack(spacing: 16) {
                        FeatureBullet(icon: "doc.text.magnifyingglass", text: "Document Scanner")
                        FeatureBullet(icon: "chart.bar.xaxis", text: "Analytics")
                        FeatureBullet(icon: "person.text.rectangle", text: "Student Records")
                    }
                    .padding(.top, 5)
                }
                
                Spacer()
                
                // Footer with action buttons
                VStack(spacing: 16) {
                    // Don't show again toggle - using AppStorage for persistence
                    Toggle(isOn: $dontShowDialog) {
                        Text("Don't show this again")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    
                    // Action button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            appear = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                            // The preference is already saved via AppStorage
                            print("Dialog closing with 'Don't show again' set to: \(dontShowDialog)")
                        }
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(30)
            .frame(width: 500, height: 580)
            .background(
                ZStack {
                    // Background gradient - MORE VIBRANT BLUE
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.4, blue: 0.9), // Brighter blue
                            Color(red: 0.1, green: 0.1, blue: 0.5)  // Deeper blue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Background pattern
                    GeometryReader { geo in
                        ZStack {
                            ForEach(0..<20) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(width: CGFloat.random(in: 50...150))
                                    .position(
                                        x: CGFloat.random(in: 0...geo.size.width),
                                        y: CGFloat.random(in: 0...geo.size.height)
                                    )
                            }
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 10)
            .scaleEffect(appear ? 1 : 0.9)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)
        }
        .zIndex(999) // Ensure it appears above all other content
        .onAppear {
            print("SimpleDialogView appeared")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appear = true
                print("Animation value 'appear' set to true")
            }
        }
    }
}

// Helper view for feature bullets
struct FeatureBullet: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
}

struct SimpleDialogView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleDialogView(isPresented: .constant(true))
    }
} 