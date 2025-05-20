//
//  ImmersiveOnboardingFlow.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// # Immersive Onboarding Flow
/// This example demonstrates advanced animation techniques for onboarding:
/// - Custom page transitions with parallax effects
/// - Particle system animations for visual interest
/// - Animated illustrations with coordinated timing
/// - Interactive gesture-based navigation
/// - Progress tracking visualization
/// - Responsive layout adaptation
struct ImmersiveOnboardingFlow: View {
    // MARK: - State
    
    /// Current page index
    @State private var currentPage = 0
    
    /// Tracks if onboarding has been completed
    @State private var isOnboardingComplete = false
    
    /// Tracks the drag gesture for manual page transitions
    @State private var dragOffset: CGFloat = 0
    
    /// Controls the background animation phase
    @State private var backgroundPhase = 0.0
    
    /// Tracks when all animations have loaded
    @State private var animationsLoaded = false
    
    // MARK: - Animation Properties
    
    /// Background animation for continuous movement
    private let backgroundAnimation = Animation.linear(duration: 15).repeatForever(autoreverses: false)
    
    /// Staggered animation delays for content elements
    private let contentAnimationDelays = [0.3, 0.4, 0.5, 0.6]
    
    /// Particle system animation
    private let particleAnimation = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    
    // MARK: - Constants
    
    /// Sample onboarding pages data
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Picketmate",
            subtitle: "Your personal productivity assistant",
            description: "Organize tasks, track habits, and achieve your goals with our intuitive interface.",
            mainImage: "sparkles",
            backgroundColor1: .blue,
            backgroundColor2: .purple,
            particleColor: .pink
        ),
        OnboardingPage(
            title: "Smart Task Management",
            subtitle: "Work smarter, not harder",
            description: "AI-powered suggestions help prioritize your tasks and optimize your workflow.",
            mainImage: "brain.head.profile",
            backgroundColor1: .purple,
            backgroundColor2: .pink,
            particleColor: .blue
        ),
        OnboardingPage(
            title: "Progress Tracking",
            subtitle: "Visualize your achievements",
            description: "Beautiful charts and insights help you understand your productivity patterns.",
            mainImage: "chart.xyaxis.line",
            backgroundColor1: .pink,
            backgroundColor2: .orange,
            particleColor: .yellow
        ),
        OnboardingPage(
            title: "Ready to Begin?",
            subtitle: "Your productivity journey starts now",
            description: "Join thousands of users who have transformed their work habits with Picketmate.",
            mainImage: "checkmark.circle.fill",
            backgroundColor1: .orange,
            backgroundColor2: .yellow,
            particleColor: .green
        )
    ]
    
    // MARK: - Computed Properties
    
    /// Current page data
    private var currentPageData: OnboardingPage {
        pages[currentPage]
    }
    
    /// Progress percentage through onboarding
    private var progressPercentage: CGFloat {
        CGFloat(currentPage) / CGFloat(max(1, pages.count - 1))
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background gradient
                backgroundView
                    .ignoresSafeArea()
                
                // Particle effects
                ParticleSystemView(
                    color: currentPageData.particleColor,
                    isAnimating: animationsLoaded
                )
                .ignoresSafeArea()
                
                // Content container with page content
                VStack(spacing: 0) {
                    // Skip button (except on last page)
                    skipButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top + 16)
                    
                    Spacer()
                    
                    // Page content
                    pageContent(size: geometry.size)
                        // Apply parallax effect based on drag gesture
                        .offset(x: dragOffset * 0.8)
                        // Slide transition between pages
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                    
                    Spacer()
                    
                    // Bottom controls with page indicators and next button
                    bottomControls
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // Handle drag gesture for page swiping
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            if value.translation.width < -threshold && currentPage < pages.count - 1 {
                                currentPage += 1
                            } else if value.translation.width > threshold && currentPage > 0 {
                                currentPage -= 1
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onAppear {
                // Start animations with a slight delay to allow view to load
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(backgroundAnimation) {
                        backgroundPhase = 360
                    }
                    
                    withAnimation {
                        animationsLoaded = true
                    }
                }
            }
        }
        // Present main app when onboarding is complete
        .fullScreenCover(isPresented: $isOnboardingComplete) {
            OnboardingCompletedView(resetOnboarding: resetOnboarding)
        }
    }
    
    // MARK: - UI Components
    
    /// Animated gradient background
    private var backgroundView: some View {
        ZStack {
            // Base gradient that shifts based on current page
            LinearGradient(
                gradient: Gradient(colors: [
                    currentPageData.backgroundColor1.opacity(0.8),
                    currentPageData.backgroundColor2.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated shape 1
            Circle()
                .fill(currentPageData.backgroundColor1.opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 30)
                .offset(
                    x: sin(Angle(degrees: backgroundPhase).radians) * 30,
                    y: cos(Angle(degrees: backgroundPhase).radians) * 20
                )
            
            // Animated shape 2
            Circle()
                .fill(currentPageData.backgroundColor2.opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 20)
                .offset(
                    x: cos(Angle(degrees: backgroundPhase).radians) * -40,
                    y: sin(Angle(degrees: backgroundPhase).radians) * 30
                )
                
            // Subtle noise texture overlay
            Rectangle()
                .fill(Color.white.opacity(0.03))
        }
        // Apply slight scale for a "breathing" effect
        .scaleEffect(1.1)
        // Cross-fade between pages
        .animation(.easeInOut(duration: 0.7), value: currentPage)
    }
    
    /// Main content for the current page
    private func pageContent(size: CGSize) -> some View {
        VStack(spacing: 40) {
            // Main image/icon
            mainImage
                .padding(.bottom, 20)
            
            // Text content
            textContent
                // Apply offset based on drag for parallax effect
                .offset(x: dragOffset * 0.2)
        }
        .frame(width: size.width - 48)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Onboarding page \(currentPage + 1) of \(pages.count): \(currentPageData.title)")
        .id(currentPage) // Force view recreation on page change
    }
    
    /// Animated main image for the current page
    private var mainImage: some View {
        ZStack {
            // Background glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            currentPageData.backgroundColor1.opacity(0.6),
                            currentPageData.backgroundColor1.opacity(0)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(animationsLoaded ? 1.1 : 0.8)
                .opacity(animationsLoaded ? 1 : 0)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: animationsLoaded
                )
            
            // Main icon
            Image(systemName: currentPageData.mainImage)
                .font(.system(size: 70, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    currentPageData.backgroundColor1,
                                    currentPageData.backgroundColor2
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .blur(radius: 2)
                )
                .shadow(color: currentPageData.backgroundColor1.opacity(0.5), radius: 20, x: 0, y: 10)
                // Animation for image changes
                .scaleEffect(animationsLoaded ? 1 : 0.5)
                .opacity(animationsLoaded ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(contentAnimationDelays[0]), value: animationsLoaded)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentPage)
        }
    }
    
    /// Text content with staggered animations
    private var textContent: some View {
        VStack(spacing: 16) {
            // Title
            Text(currentPageData.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .scaleEffect(animationsLoaded ? 1 : 0.8)
                .opacity(animationsLoaded ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(contentAnimationDelays[1]), value: animationsLoaded)
            
            // Subtitle
            Text(currentPageData.subtitle)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .scaleEffect(animationsLoaded ? 1 : 0.8)
                .opacity(animationsLoaded ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(contentAnimationDelays[2]), value: animationsLoaded)
            
            // Description
            Text(currentPageData.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .scaleEffect(animationsLoaded ? 1 : 0.8)
                .opacity(animationsLoaded ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(contentAnimationDelays[3]), value: animationsLoaded)
        }
    }
    
    /// Skip button at the top
    private var skipButton: some View {
        Group {
            if currentPage < pages.count - 1 {
                Button(action: completeOnboarding) {
                    Text("Skip")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.opacity)
                .animation(.easeInOut, value: currentPage)
            }
        }
    }
    
    /// Bottom controls including page indicators and next button
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page indicators
            PageIndicatorView(
                pageCount: pages.count,
                currentPage: currentPage,
                progressTint: currentPageData.backgroundColor1,
                defaultTint: Color.white.opacity(0.3)
            )
            
            // Next/Get Started button
            Button(action: nextButtonTapped) {
                HStack {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if currentPage < pages.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                }
                .frame(height: 50)
                .frame(minWidth: 200)
                .background(
                    LinearGradient(
                        colors: [
                            currentPageData.backgroundColor1,
                            currentPageData.backgroundColor2
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: currentPageData.backgroundColor1.opacity(0.4), radius: 8, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .scaleEffect(animationsLoaded ? 1 : 0.8)
            .opacity(animationsLoaded ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6), value: animationsLoaded)
        }
    }
    
    // MARK: - Actions
    
    /// Handles next button tap
    private func nextButtonTapped() {
        // Use light haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    /// Completes the onboarding process
    private func completeOnboarding() {
        // Use success haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            isOnboardingComplete = true
        }
    }
    
    /// Resets onboarding to the beginning (for demo purposes)
    private func resetOnboarding() {
        // Reset state
        currentPage = 0
        dragOffset = 0
        animationsLoaded = false
        isOnboardingComplete = false
        
        // Restart animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(backgroundAnimation) {
                backgroundPhase = 0
                backgroundPhase = 360 // Restart the animation
            }
            
            withAnimation {
                animationsLoaded = true
            }
        }
    }
}

// MARK: - Supporting Views

/// Custom button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Page indicator with animated progress
struct PageIndicatorView: View {
    let pageCount: Int
    let currentPage: Int
    let progressTint: Color
    let defaultTint: Color
    
    /// Spacing between indicators
    private let spacing: CGFloat = 8
    
    /// Size of individual indicators
    private let dotSize: CGFloat = 8
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<pageCount, id: \.self) { index in
                // Individual indicator
                Circle()
                    .fill(index == currentPage ? progressTint : defaultTint)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .overlay(
                        // Show outline for current page
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: index == currentPage ? 1 : 0)
                            .scaleEffect(1.3)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    // Make tappable for direct navigation
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            // This would be connected to a state property in parent view
                            // Simulating tap handling by logging
                            print("Tapped page indicator \(index)")
                        }
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pageCount)")
        .accessibilityHint("Swipe left or right to navigate between pages")
    }
}

/// Particle system for visual effects
struct ParticleSystemView: View {
    let color: Color
    let isAnimating: Bool
    
    /// Number of particles to display
    private let particleCount = 25
    
    var body: some View {
        ZStack {
            // Create multiple particles
            ForEach(0..<particleCount, id: \.self) { index in
                Particle(
                    color: color,
                    size: randomSize(for: index),
                    position: randomPosition(for: index),
                    opacity: randomOpacity(for: index),
                    animationSpeed: randomSpeed(for: index),
                    isAnimating: isAnimating
                )
            }
        }
        .animation(.easeInOut(duration: 0.7), value: color)
    }
    
    /// Generate a random size for a particle
    private func randomSize(for index: Int) -> CGFloat {
        let baseSize = CGFloat(((index % 5) + 1) * 3)
        return baseSize + CGFloat.random(in: 0...5)
    }
    
    /// Generate a random opacity for a particle
    private func randomOpacity(for index: Int) -> Double {
        return Double.random(in: 0.2...0.5)
    }
    
    /// Generate a random speed for a particle
    private func randomSpeed(for index: Int) -> Double {
        return Double.random(in: 1.0...3.0)
    }
    
    /// Generate a random position for a particle
    private func randomPosition(for index: Int) -> CGPoint {
        // Create a deterministic but seemingly random distribution
        let angle = Double(index) * 137.5 * .pi / 180 // Golden angle in radians
        let radius = (Double(index % 15) + 10) * 15
        
        return CGPoint(
            x: 200 + CGFloat(cos(angle) * radius),
            y: 400 + CGFloat(sin(angle) * radius)
        )
    }
}

/// Individual particle view with animation
struct Particle: View {
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let opacity: Double
    let animationSpeed: Double
    let isAnimating: Bool
    
    @State private var phase: Double = 0
    
    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: size * 0.2)
            .position(
                x: position.x + CGFloat(cos(phase)) * 20,
                y: position.y + CGFloat(sin(phase)) * 20
            )
            .onAppear {
                // Set a random starting phase
                self.phase = Double.random(in: 0..<(2 * .pi))
                
                // Animate continuously
                if isAnimating {
                    withAnimation(Animation.linear(duration: animationSpeed).repeatForever(autoreverses: false)) {
                        // Complete one full cycle
                        self.phase += 2 * .pi
                    }
                }
            }
            .animation(.easeInOut(duration: 1.0), value: isAnimating)
    }
}

/// View shown after onboarding is complete
struct OnboardingCompletedView: View {
    let resetOnboarding: () -> Void
    
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Welcome message
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .opacity(showCelebration ? 1 : 0)
                        .scaleEffect(showCelebration ? 1 : 0.5)
                    
                    Text("Welcome to Picketmate!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(showCelebration ? 1 : 0)
                        .offset(y: showCelebration ? 0 : 20)
                    
                    Text("Your productivity journey begins now")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .opacity(showCelebration ? 1 : 0)
                        .offset(y: showCelebration ? 0 : 15)
                }
                
                // Continue button
                Button(action: {}) {
                    Text("Continue to Dashboard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(minWidth: 240)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.4), radius: 5, y: 3)
                }
                .opacity(showCelebration ? 1 : 0)
                .scaleEffect(showCelebration ? 1 : 0.8)
                
                // Demo reset button
                Button(action: resetOnboarding) {
                    Text("Reset Onboarding (Demo Only)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
                .opacity(showCelebration ? 0.6 : 0)
            }
            .padding()
            
            // Confetti celebration
            if showCelebration {
                ConfettiView()
            }
        }
        .onAppear {
            // Animate welcome elements with staggered timing
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.3)) {
                showCelebration = true
            }
        }
    }
}

/// Simple confetti celebration effect
struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let confettiCount = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<confettiCount, id: \.self) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    position: randomPosition(),
                    size: randomSize(),
                    rotation: Double.random(in: 0...360)
                )
            }
        }
    }
    
    /// Generate a random position for confetti
    private func randomPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: -50...UIScreen.main.bounds.height * 0.5)
        )
    }
    
    /// Generate a random size for confetti
    private func randomSize() -> CGFloat {
        return CGFloat.random(in: 5...12)
    }
}

/// Individual confetti piece with animation
struct ConfettiPiece: View {
    let color: Color
    let position: CGPoint
    let size: CGFloat
    let rotation: Double
    
    @State private var animationComplete = false
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size * 1.5)
            .position(position)
            .rotationEffect(.degrees(rotation + (animationComplete ? 180 : 0)))
            .offset(y: animationComplete ? 800 : 0)
            .opacity(animationComplete ? 0 : 1)
            .onAppear {
                // Random delay before animation starts
                let delay = Double.random(in: 0...0.3)
                withAnimation(Animation.easeIn(duration: Double.random(in: 1.5...2.5)).delay(delay)) {
                    animationComplete = true
                }
            }
    }
}

// MARK: - Models

/// Model for onboarding page data
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let mainImage: String // System image name
    let backgroundColor1: Color
    let backgroundColor2: Color
    let particleColor: Color
}

// MARK: - Preview

struct ImmersiveOnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        ImmersiveOnboardingFlow()
    }
} 