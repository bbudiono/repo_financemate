//
//  ImmersiveOnboardingView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// A visually stunning onboarding experience demonstrating advanced SwiftUI techniques
/// including parallax effects, animated gradients, particle systems, and smooth transitions.
struct ImmersiveOnboardingView: View {
    // MARK: - Properties
    
    /// Current onboarding page
    @State private var currentPage = 0
    
    /// Tracks if onboarding is completed
    @State private var isOnboardingComplete = false
    
    /// Controls animation states
    @State private var animateBackground = false
    @State private var animateParticles = false
    @State private var heroScale: CGFloat = 1.0
    
    /// Drag gesture state
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    
    /// Particle system properties
    @State private var particleSystemOpacity = 0.0
    
    // MARK: - Animation Properties
    private let backgroundAnimation = Animation.linear(duration: 15).repeatForever(autoreverses: false)
    private let particleAnimation = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    private let heroAnimation = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    
    // MARK: - Constants
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Picketmate",
            subtitle: "Your all-in-one productivity companion",
            description: "Organize your tasks, track your progress, and achieve your goals with our beautiful and intuitive interface.",
            imageName: "chart.bar.doc.horizontal",
            primaryColor: .blue,
            secondaryColor: .purple,
            particleColor: .pink
        ),
        OnboardingPage(
            title: "Smart Organization",
            subtitle: "Effortlessly manage your workflow",
            description: "Our AI-powered system learns your preferences and helps you organize tasks in the most efficient way possible.",
            imageName: "brain.head.profile",
            primaryColor: .purple,
            secondaryColor: .pink,
            particleColor: .blue
        ),
        OnboardingPage(
            title: "Real-time Analytics",
            subtitle: "Visualize your productivity",
            description: "Beautiful charts and insights help you understand your work patterns and optimize your productivity.",
            imageName: "chart.xyaxis.line",
            primaryColor: .pink,
            secondaryColor: .orange,
            particleColor: .purple
        ),
        OnboardingPage(
            title: "Ready to Start?",
            subtitle: "Your productivity journey begins now",
            description: "Join thousands of users who have transformed their work habits with Picketmate.",
            imageName: "sparkles",
            primaryColor: .orange,
            secondaryColor: .yellow,
            particleColor: .green
        )
    ]
    
    private var maxPage: Int {
        onboardingPages.count - 1
    }
    
    // MARK: - Computed Properties
    
    /// Current page data
    private var currentPageData: OnboardingPage {
        onboardingPages[currentPage]
    }
    
    /// Next page data (for transitions)
    private var nextPageData: OnboardingPage? {
        currentPage < maxPage ? onboardingPages[currentPage + 1] : nil
    }
    
    /// Progress percentage through onboarding
    private var progressPercentage: CGFloat {
        CGFloat(currentPage) / CGFloat(maxPage)
    }
    
    /// Parallax offset based on drag
    private var parallaxOffset: CGFloat {
        dragOffset / 10
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Animated gradient background
            animatedGradientBackground
                .ignoresSafeArea()
            
            // Particle system
            ParticleSystem(
                particleCount: 25,
                baseColor: currentPageData.particleColor,
                isAnimating: animateParticles,
                opacity: particleSystemOpacity
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                // Page content (with transitioning capability)
                pageContent
                    .padding(.horizontal, 25)
                
                Spacer()
                
                // Bottom controls (pagination and buttons)
                controlsView
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: currentPage) { _ in
            // Animate hero image when page changes
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                heroScale = 1.2
            }
            
            // Reset to normal scale after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    heroScale = 1.0
                }
            }
        }
        // Handle navigation based on onboarding completion
        .fullScreenCover(isPresented: $isOnboardingComplete) {
            // This would typically navigate to your main app
            // For demo purposes, we'll use a placeholder view
            MainAppPlaceholderView(onRestart: {
                isOnboardingComplete = false
                currentPage = 0
            })
        }
    }
    
    // MARK: - Animated Gradient Background
    
    /// Creates a beautiful animated gradient that shifts between current and next page colors
    private var animatedGradientBackground: some View {
        ZStack {
            // Current page's gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    currentPageData.primaryColor.opacity(0.5),
                    currentPageData.secondaryColor.opacity(0.2)
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 900
            )
            
            // Transitional gradient (if there's a next page)
            if let nextPage = nextPageData {
                RadialGradient(
                    gradient: Gradient(colors: [
                        nextPage.primaryColor.opacity(0.5),
                        nextPage.secondaryColor.opacity(0.2)
                    ]),
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: 900
                )
                .opacity(dragOffset < 0 ? min(-dragOffset / 200, 1.0) : 0)
            }
            
            // Moving blurred shapes for dynamic effect
            ZStack {
                // Animated blob 1
                Circle()
                    .fill(currentPageData.primaryColor.opacity(0.4))
                    .frame(width: 250, height: 250)
                    .blur(radius: 30)
                    .offset(x: animateBackground ? 100 : -100, y: animateBackground ? -50 : 50)
                
                // Animated blob 2
                Circle()
                    .fill(currentPageData.secondaryColor.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .offset(x: animateBackground ? -120 : 120, y: animateBackground ? 100 : -100)
                
                // Animated blob 3
                Circle()
                    .fill(currentPageData.particleColor.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                    .offset(x: animateBackground ? 50 : -50, y: animateBackground ? 30 : -30)
            }
            
            // Subtle noise texture overlay
            Color.white.opacity(0.02)
                .ignoresSafeArea()
        }
        .scaleEffect(1.2) // Slightly oversized to allow for subtle movement
        .offset(x: parallaxOffset, y: -parallaxOffset) // Parallax effect
    }
    
    // MARK: - Page Content
    
    /// Content for the current page with hero image and text
    private var pageContent: some View {
        VStack(spacing: 40) {
            // Hero image with dynamic effects
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                currentPageData.primaryColor.opacity(0.5),
                                currentPageData.secondaryColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                // Main icon
                Image(systemName: currentPageData.imageName)
                    .font(.system(size: 70, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                .white,
                                .white.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 150, height: 150)
                    .background(
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            currentPageData.primaryColor,
                                            currentPageData.secondaryColor
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Highlight effect
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .padding(4)
                                .blur(radius: 2)
                                .offset(x: -20, y: -20)
                                .mask(Circle())
                        }
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .blur(radius: 1)
                    )
                    .shadow(color: currentPageData.primaryColor.opacity(0.5), radius: 20, x: 0, y: 10)
            }
            .scaleEffect(heroScale)
            .offset(x: parallaxOffset * 2, y: 0) // Enhanced parallax for hero
            
            // Page text content
            VStack(spacing: 16) {
                Text(currentPageData.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                Text(currentPageData.subtitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                Text(currentPageData.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }
            .offset(x: 0, y: parallaxOffset * 1.5) // Vertical parallax for text
            .padding(.top, 20)
        }
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .updating($isDragging) { value, state, _ in
                    state = true
                }
                .onChanged { value in
                    // Only allow dragging left on last page or in any direction on other pages
                    if currentPage == maxPage && value.translation.width > 0 {
                        dragOffset = value.translation.width / 3 // Add resistance
                    } else if currentPage == 0 && value.translation.width < 0 {
                        dragOffset = value.translation.width / 3 // Add resistance
                    } else {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        // Determine if we should change page based on drag distance
                        let predictedEndOffset = value.predictedEndTranslation.width
                        let threshold: CGFloat = 100
                        
                        if predictedEndOffset < -threshold && currentPage < maxPage {
                            currentPage += 1
                        } else if predictedEndOffset > threshold && currentPage > 0 {
                            currentPage -= 1
                        }
                        
                        // Reset drag offset
                        dragOffset = 0
                    }
                }
        )
        // Custom transition between pages
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
        .id(currentPage) // Force view recreation when page changes
    }
    
    // MARK: - Controls View
    
    /// Bottom controls including page indicators and navigation buttons
    private var controlsView: some View {
        VStack(spacing: 30) {
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<onboardingPages.count, id: \.self) { pageIndex in
                    Circle()
                        .fill(pageIndex == currentPage ? Color.white : Color.white.opacity(0.4))
                        .frame(width: pageIndex == currentPage ? 12 : 8, height: pageIndex == currentPage ? 12 : 8)
                        .scaleEffect(pageIndex == currentPage ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentPage = pageIndex
                            }
                        }
                }
            }
            
            // Navigation buttons
            HStack(spacing: 20) {
                // Skip button (except on last page)
                if currentPage < maxPage {
                    Button(action: {
                        isOnboardingComplete = true
                    }) {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle())
                }
                
                // Next/Done button
                Button(action: {
                    if currentPage < maxPage {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            currentPage += 1
                        }
                    } else {
                        // Complete onboarding
                        isOnboardingComplete = true
                    }
                }) {
                    Text(currentPage < maxPage ? "Next" : "Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 36)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            currentPageData.primaryColor,
                                            currentPageData.secondaryColor
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: currentPageData.primaryColor.opacity(0.5), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    
    /// Starts all animations when the view appears
    private func startAnimations() {
        // Start background animation
        withAnimation(backgroundAnimation) {
            animateBackground = true
        }
        
        // Start particle animation with slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 1.0)) {
                particleSystemOpacity = 1.0
            }
            
            withAnimation(particleAnimation) {
                animateParticles = true
            }
        }
        
        // Start hero animation
        withAnimation(heroAnimation.delay(0.5)) {
            heroScale = 1.05
        }
    }
}

// MARK: - Supporting Models

/// Model representing onboarding page data
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let primaryColor: Color
    let secondaryColor: Color
    let particleColor: Color
}

// MARK: - Supporting Views

/// Particle effect system for visual enhancement
struct ParticleSystem: View {
    let particleCount: Int
    let baseColor: Color
    let isAnimating: Bool
    let opacity: Double
    
    var body: some View {
        ZStack {
            // Multiple particles with different characteristics
            ForEach(0..<particleCount, id: \.self) { index in
                Particle(
                    baseColor: baseColor,
                    size: CGFloat.random(in: 5...15),
                    position: randomPosition(for: index),
                    animation: animation(for: index),
                    blurRadius: CGFloat.random(in: 0...2)
                )
            }
        }
        .opacity(opacity)
    }
    
    /// Generates a random position for a particle
    private func randomPosition(for index: Int) -> CGPoint {
        // Create a somewhat deterministic random pattern based on index
        let xPercent = Double(index % 5) / 5.0 + Double.random(in: -0.1...0.1)
        let yPercent = Double(index / 5) / Double((particleCount / 5)) + Double.random(in: -0.1...0.1)
        
        // Convert to screen coordinates 
        // Note: Using UIScreen is simpler but not ideal for all SwiftUI contexts
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let x = screenWidth * CGFloat(xPercent) + CGFloat.random(in: -50...screenWidth+50)
        let y = screenHeight * CGFloat(yPercent) + CGFloat.random(in: -50...screenHeight+50)
        
        return CGPoint(x: x, y: y)
    }
    
    /// Creates a unique animation for each particle
    private func animation(for index: Int) -> Animation {
        let duration = Double.random(in: 3...8)
        let delay = Double.random(in: 0...4)
        
        return Animation
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
            .delay(delay)
    }
}

/// Individual particle view
struct Particle: View {
    let baseColor: Color
    let size: CGFloat
    let position: CGPoint
    let animation: Animation
    let blurRadius: CGFloat
    
    @State private var offset: CGPoint = .zero
    @State private var opacity: Double = Double.random(in: 0.5...0.9)
    
    var body: some View {
        Circle()
            .fill(
                baseColor.opacity(opacity)
            )
            .frame(width: size, height: size)
            .blur(radius: blurRadius)
            .position(x: position.x + offset.x, y: position.y + offset.y)
            .onAppear {
                withAnimation(animation) {
                    offset = CGPoint(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -100...100)
                    )
                    opacity = Double.random(in: 0.3...0.7)
                }
            }
    }
}

/// Placeholder view for the main app (demonstration purposes)
struct MainAppPlaceholderView: View {
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            // Simple gradient background
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Welcome to Picketmate!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("This is where your main app experience would begin.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 30)
                
                Button(action: onRestart) {
                    Text("Restart Onboarding")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
                .padding(.top, 30)
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
    }
}

// MARK: - Preview
struct ImmersiveOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        ImmersiveOnboardingView()
    }
} 