import SwiftUI

struct LandingView: View {
    @State private var isAnimating: Bool = false
    @State private var showGetStarted: Bool = false
    
    // App version from the build
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                // Logo and welcome text
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        .accessibilityLabel("Picketmate logo")
                    
                    Text("Welcome to Picketmate")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Your Personal Task Management Assistant")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .accessibilityAddTraits(.isStaticText)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Feature highlights
                VStack(alignment: .leading, spacing: 25) {
                    FeatureRow(
                        icon: "list.bullet.clipboard",
                        title: "Organize Your Tasks",
                        description: "Create and manage tasks with intuitive organization tools"
                    )
                    
                    FeatureRow(
                        icon: "bell.badge",
                        title: "Smart Reminders",
                        description: "Never miss a deadline with customizable notifications"
                    )
                    
                    FeatureRow(
                        icon: "chart.bar",
                        title: "Progress Tracking",
                        description: "Visualize your productivity with detailed analytics"
                    )
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Get started button
                Button(action: {
                    showGetStarted = true
                }) {
                    Text("Get Started")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 220, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(radius: 8)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .shadow(radius: 5)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Get Started")
                .accessibilityHint("Tap to begin using Picketmate")
                
                // Footer with version
                HStack {
                    Spacer()
                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                        .accessibilityLabel("Version \(appVersion)")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 1.2), value: isAnimating)
        }
        .navigationTitle("Welcome")
        // .navigationViewStyle(.stack) // Removed for macOS compatibility
        .onAppear {
            // Start animations when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showGetStarted) {
            OnboardingView()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("LandingView")
    }
}

// Feature row component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 40)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

// Simple onboarding view
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Let's Get Started!")
                .font(.largeTitle.bold())
                .padding(.top, 40)
                .accessibilityAddTraits(.isHeader)
            
            Text("Picketmate helps you organize your tasks, set reminders, and track your progress effectively.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .accessibilityAddTraits(.isStaticText)
            
            Spacer()
            
            Button("Continue to App") {
                dismiss()
            }
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(width: 220, height: 55)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.blue)
            )
            .padding(.bottom, 50)
            .accessibilityAddTraits(.isButton)
        }
        .frame(width: 600, height: 400)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("OnboardingView")
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}

#Preview {
    LandingView()
} 