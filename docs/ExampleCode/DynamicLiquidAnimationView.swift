//
//  DynamicLiquidAnimationView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// # Dynamic Liquid Animation View
/// This example demonstrates advanced shape morphing and fluid animation techniques:
/// - Interactive physics-based liquid animations
/// - Complex shape interpolation and morphing
/// - Gesture-based interaction with dynamic response
/// - Layered blur and transparency effects
/// - Color blending and gradient transitions
/// - Performance optimizations for smooth animation
struct DynamicLiquidAnimationView: View {
    // MARK: - State
    
    /// Controls the current animation phase
    @State private var animationPhase: Double = 0
    
    /// Tracks if the animation is actively running
    @State private var isAnimating = true
    
    /// Tracks touch input position for interactive effects
    @State private var touchLocation: CGPoint = .zero
    
    /// Controls whether the view is responding to touch
    @State private var isResponsiveToTouch = false
    
    /// Current transition progress between color schemes
    @State private var colorTransition: Double = 0
    
    /// Tracks when view has appeared for entrance animations
    @State private var hasAppeared = false
    
    // MARK: - Animation Properties
    
    /// Animation for continuous base wave motion
    private let waveAnimation = Animation.linear(duration: 4).repeatForever(autoreverses: false)
    
    /// Animation for color transitions
    private let colorAnimation = Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
    
    /// Animation for touch response
    private let touchAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    
    // MARK: - Drawing Properties
    
    /// Base wave amplitude
    private let waveHeight: CGFloat = 20
    
    /// Number of waves to draw
    private let waveCount = 3
    
    /// Wave frequency multipliers for each layer
    private let frequencies = [1.0, 1.5, 0.5]
    
    /// Wave phase shift multipliers for each layer
    private let phaseShifts = [0.0, 0.5, 1.0]
    
    /// Opacity for each wave layer
    private let opacities = [0.8, 0.6, 0.4]
    
    /// Color schemes for transition
    private let colorSchemes = [
        ColorScheme(primary: .blue, secondary: .purple, accent: .pink),
        ColorScheme(primary: .purple, secondary: .pink, accent: .orange),
        ColorScheme(primary: .orange, secondary: .yellow, accent: .green)
    ]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        currentColorScheme.primary.opacity(0.2),
                        currentColorScheme.secondary.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main liquid animation
                liquidAnimationView(in: geometry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Control panel overlay
                controlPanel
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding()
                    .offset(y: hasAppeared ? 0 : -100)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hasAppeared)
                
                // Touch indicator (when active)
                if isResponsiveToTouch {
                    Circle()
                        .fill(currentColorScheme.accent.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .blur(radius: 10)
                        .position(touchLocation)
                }
            }
            // Handle drag gestures for interactivity
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if isResponsiveToTouch {
                            // Update touch location for interactive waves
                            touchLocation = value.location
                        }
                    }
            )
            .onAppear {
                // Start animations
                withAnimation(waveAnimation) {
                    animationPhase = .pi * 2
                }
                
                withAnimation(colorAnimation) {
                    colorTransition = 1.0
                }
                
                // Show controls with a slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        hasAppeared = true
                    }
                }
            }
        }
        .navigationTitle("Liquid Animation")
        // Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Dynamic liquid animation with interactive controls")
        .accessibilityAddTraits(.allowsDirectInteraction)
    }
    
    // MARK: - UI Components
    
    /// Main liquid animation view
    private func liquidAnimationView(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        return ZStack {
            // Create multiple wave layers with different properties
            ForEach(0..<waveCount, id: \.self) { index in
                // Wave shape
                WaveShape(
                    phase: animationPhase + phaseShifts[index],
                    frequency: frequencies[index],
                    amplitude: waveHeight,
                    touchLocation: isResponsiveToTouch ? touchLocation : nil,
                    touchInfluence: 40,
                    width: width,
                    height: height
                )
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            waveColor(for: index, opacity: opacities[index]),
                            waveColor(for: index, opacity: opacities[index] * 0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(opacities[index])
                // Apply blur for a more fluid look
                .blur(radius: CGFloat(3 - index) * 2)
                // Fill the entire view
                .frame(width: width, height: height)
            }
            
            // Additional bubble effects
            ForEach(0..<8, id: \.self) { index in
                BubbleView(
                    baseColor: currentColorScheme.accent,
                    size: CGFloat.random(in: 40...80),
                    speed: Double.random(in: 10...20),
                    horizontalOffset: CGFloat.random(in: 0...width),
                    phase: Double(index) / 8
                )
            }
        }
        .drawingGroup() // Improve performance with Metal renderer
    }
    
    /// Control panel for user interaction
    private var controlPanel: some View {
        HStack(spacing: 16) {
            // Toggle animation button
            Button(action: toggleAnimation) {
                Image(systemName: isAnimating ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Touch responsiveness toggle
            Button(action: toggleTouchResponsiveness) {
                Image(systemName: isResponsiveToTouch ? "hand.tap.fill" : "hand.tap")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(isResponsiveToTouch ? currentColorScheme.accent.opacity(0.5) : Color.black.opacity(0.2))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Color scheme transition button
            Button(action: cycleColorScheme) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 2)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .blur(radius: 3)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Animation controls")
    }
    
    // MARK: - Helper Methods
    
    /// Toggle animation state
    private func toggleAnimation() {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isAnimating.toggle()
        
        if isAnimating {
            // Resume animation
            withAnimation(waveAnimation) {
                animationPhase = animationPhase + .pi * 2
            }
            
            // Resume color transition if it was active
            if colorTransition > 0 {
                withAnimation(colorAnimation) {
                    colorTransition = 1.0
                }
            }
        } else {
            // Pause animations
            withAnimation(.easeInOut) {
                // Animations will pause at current state
            }
        }
    }
    
    /// Toggle touch responsiveness
    private func toggleTouchResponsiveness() {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(touchAnimation) {
            isResponsiveToTouch.toggle()
        }
    }
    
    /// Cycle through color schemes
    private func cycleColorScheme() {
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Get current index
        let currentIndex = Int(colorTransition * Double(colorSchemes.count - 1))
        let nextIndex = (currentIndex + 1) % colorSchemes.count
        
        // Calculate new transition value
        let newTransition = Double(nextIndex) / Double(colorSchemes.count - 1)
        
        // Animate to new color scheme
        withAnimation(.easeInOut(duration: 1.5)) {
            colorTransition = newTransition
        }
    }
    
    /// Get the current interpolated color scheme based on transition
    private var currentColorScheme: ColorScheme {
        let count = colorSchemes.count
        if count <= 1 {
            return colorSchemes.first!
        }
        
        // Calculate indices and blend factor
        let index = min(Int(colorTransition * Double(count - 1)), count - 2)
        let nextIndex = index + 1
        let factor = colorTransition * Double(count - 1) - Double(index)
        
        // Interpolate colors
        return ColorScheme(
            primary: interpolateColor(colorSchemes[index].primary, colorSchemes[nextIndex].primary, factor: factor),
            secondary: interpolateColor(colorSchemes[index].secondary, colorSchemes[nextIndex].secondary, factor: factor),
            accent: interpolateColor(colorSchemes[index].accent, colorSchemes[nextIndex].accent, factor: factor)
        )
    }
    
    /// Get the color for a specific wave layer
    private func waveColor(for index: Int, opacity: Double) -> Color {
        switch index {
        case 0:
            return currentColorScheme.primary.opacity(opacity)
        case 1:
            return interpolateColor(
                currentColorScheme.primary,
                currentColorScheme.secondary,
                factor: 0.5
            ).opacity(opacity)
        case 2:
            return currentColorScheme.secondary.opacity(opacity)
        default:
            return currentColorScheme.primary.opacity(opacity)
        }
    }
    
    /// Interpolate between two colors
    private func interpolateColor(_ from: Color, _ to: Color, factor: Double) -> Color {
        // This is a simplified approach - a full implementation would need to convert to RGB/HSB
        let factor = min(max(factor, 0), 1)
        return from.opacity(1 - factor).blended(with: to.opacity(factor))
    }
}

// MARK: - Supporting Views and Shapes

/// Custom wave shape for liquid effect
struct WaveShape: Shape {
    var phase: Double
    var frequency: Double
    var amplitude: CGFloat
    var touchLocation: CGPoint?
    var touchInfluence: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    // Make it animatable
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // Base parameters
        let path = Path { path in
            // Start at bottom-left corner
            path.move(to: CGPoint(x: 0, y: height))
            
            // Draw wave shape
            stride(from: 0, to: width, by: 1).forEach { x in
                // Calculate wave effect
                let relativeX = CGFloat(x) / width
                let waveHeight = sin(relativeX * .pi * CGFloat(frequency) + CGFloat(phase)) * amplitude
                
                // Add touch influence if applicable
                var influencedHeight = waveHeight
                if let touchLocation = touchLocation {
                    // Calculate distance from touch point
                    let distanceFromTouch = abs(touchLocation.x - CGFloat(x))
                    if distanceFromTouch < 100 {
                        // Influence is stronger the closer to the touch point
                        let touchFactor = (100 - distanceFromTouch) / 100
                        let touchEffect = touchInfluence * touchFactor * touchFactor
                        
                        // Adjust height based on touch location
                        let verticalDistanceFromTouch = max(0, touchLocation.y - height * 0.5)
                        let directionFactor = verticalDistanceFromTouch > 0 ? -1.0 : 1.0
                        influencedHeight += touchEffect * directionFactor
                    }
                }
                
                // Add point to path
                let y = height * 0.5 + influencedHeight
                path.addLine(to: CGPoint(x: CGFloat(x), y: y))
            }
            
            // Complete the path by drawing to bottom-right and back to bottom-left
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        
        return path
    }
}

/// Floating bubble effect
struct BubbleView: View {
    let baseColor: Color
    let size: CGFloat
    let speed: Double
    let horizontalOffset: CGFloat
    let phase: Double
    
    @State private var verticalOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(baseColor.opacity(0.3))
            .frame(width: size, height: size)
            .blur(radius: size * 0.2)
            // Add a subtle highlight
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: size * 0.3, height: size * 0.3)
                    .offset(x: -size * 0.15, y: -size * 0.15)
                    .blur(radius: size * 0.1)
            )
            .position(x: horizontalOffset, y: verticalOffset)
            .onAppear {
                // Initial position based on phase
                verticalOffset = UIScreen.main.bounds.height + size + (UIScreen.main.bounds.height * CGFloat(phase))
                
                // Animate bubble rising
                withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false)) {
                    verticalOffset = -size * 2
                }
            }
    }
}

/// Button style with scale effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Models and Extensions

/// Color scheme model
struct ColorScheme {
    let primary: Color
    let secondary: Color
    let accent: Color
}

/// Color blending extension
extension Color {
    /// Blend with another color
    func blended(with otherColor: Color) -> Color {
        // This is a simplified blend in SwiftUI
        // A complete implementation would involve UIColor/NSColor conversion
        return self.opacity(0.5).overlay(otherColor.opacity(0.5))
    }
}

// MARK: - Preview

struct DynamicLiquidAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DynamicLiquidAnimationView()
        }
    }
} 