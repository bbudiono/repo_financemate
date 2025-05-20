//
//  ModernCardView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI

/// A modern card view that showcases advanced SwiftUI visual effects
/// including animated gradients, glass morphism, and interactive gestures.
struct ModernCardView: View {
    // MARK: - Properties
    
    /// Controls whether the card is expanded or collapsed
    @State private var isExpanded = false
    
    /// Tracks the drag gesture for interactive animations
    @State private var dragOffset: CGSize = .zero
    
    /// Controls the animation phase of the gradient
    @State private var gradientPhase: Double = 0.0
    
    /// Colors used in the animated gradient
    private let gradientColors: [Color] = [
        .blue.opacity(0.8),
        .purple.opacity(0.7),
        .pink.opacity(0.8),
        .blue.opacity(0.7)
    ]
    
    // MARK: - Animation Properties
    private let cardSpringAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    private let expandedHeight: CGFloat = 380
    private let collapsedHeight: CGFloat = 180
    
    // MARK: - Accessibility Identifiers
    private let cardAccessibilityID = "modernCard"
    private let toggleButtonAccessibilityID = "expandToggleButton"
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Animated background gradient
            AnimatedGradientBackground(
                colors: gradientColors,
                phase: gradientPhase
            )
            
            // Card content
            VStack(spacing: 15) {
                // Header with avatar and title
                HStack {
                    CircleAvatar()
                        .padding(.leading, 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Modern Design")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Interactive Card Example")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Expand/collapse button
                    Button(action: {
                        withAnimation(cardSpringAnimation) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 10)
                    .accessibilityIdentifier(toggleButtonAccessibilityID)
                }
                .padding(.top, 20)
                
                // Divider with gradient
                GradientDivider()
                    .padding(.horizontal)
                
                // Main content area - only visible when expanded
                if isExpanded {
                    VStack(alignment: .leading, spacing: 15) {
                        // Card metrics
                        HStack(spacing: 20) {
                            MetricItem(value: "87%", label: "Progress", icon: "chart.bar.fill")
                            MetricItem(value: "24", label: "Tasks", icon: "checklist")
                            MetricItem(value: "12", label: "Days Left", icon: "calendar")
                        }
                        .padding(.horizontal)
                        
                        // Additional content
                        Text("Project Details")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        Text("This card demonstrates modern SwiftUI techniques including animated gradients, glass morphism, interactive gestures, and smooth transitions between states.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal)
                            .lineLimit(4)
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            ActionButton(title: "Details", icon: "doc.text.fill")
                            ActionButton(title: "Share", icon: "square.and.arrow.up")
                        }
                        .padding(.top, 10)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        // Card container styling
        .frame(maxWidth: 380, maxHeight: isExpanded ? expandedHeight : collapsedHeight)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        // 3D rotation effect based on drag
        .rotation3DEffect(
            .degrees(dragOffset.width / 20),
            axis: (x: 0, y: 1, z: 0)
        )
        .rotation3DEffect(
            .degrees(dragOffset.height / 20),
            axis: (x: 1, y: 0, z: 0)
        )
        // Shadow for depth
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
        // Gesture handling
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Limit the rotation effect
                    let limitedDrag = CGSize(
                        width: min(max(value.translation.width, -40), 40),
                        height: min(max(value.translation.height, -30), 30)
                    )
                    dragOffset = limitedDrag
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        dragOffset = .zero
                    }
                }
        )
        .accessibilityIdentifier(cardAccessibilityID)
        // Animate gradient continuously
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                gradientPhase = 360
            }
        }
    }
}

// MARK: - Supporting Views

/// Creates an animated gradient background that shifts over time
struct AnimatedGradientBackground: View {
    let colors: [Color]
    let phase: Double
    
    var body: some View {
        ZStack {
            // Base glass effect background
            Color.black.opacity(0.2)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 30, style: .continuous)
                )
            
            // Animated gradient overlay
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(phase))
            .blendMode(.overlay)
        }
    }
}

/// Circular avatar component with pulsing animation
struct CircleAvatar: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Pulsing circle
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 54, height: 54)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
            
            // Avatar image
            Image(systemName: "person.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .onAppear {
            // Start pulsing animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

/// Gradient divider line
struct GradientDivider: View {
    var body: some View {
        LinearGradient(
            colors: [.blue.opacity(0.5), .purple.opacity(0.7), .pink.opacity(0.5)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
    }
}

/// Metric display component
struct MetricItem: View {
    let value: String
    let label: String
    let icon: String
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            .linearGradient(
                                colors: [.blue.opacity(0.7), .purple.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false).delay(Double.random(in: 0...2))) {
                isAnimating = true
            }
        }
    }
}

/// Action button component
struct ActionButton: View {
    let title: String
    let icon: String
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ModernCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Dark background to showcase the card effects
            Color.black.edgesIgnoringSafeArea(.all)
            
            ModernCardView()
                .padding()
        }
    }
} 