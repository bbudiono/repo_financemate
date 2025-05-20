//
//  WelcomePopupView.swift
//  EduTrackQLD
//
//  Created by AI Assistant on 2025-05-12.
//

import SwiftUI

struct WelcomePopupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = WelcomePopupViewModel()
    
    // Constants based on Style Guide
    private let spacing: CGFloat = 24.0
    private let cornerRadius: CGFloat = 12.0
    private let padding: CGFloat = 16.0
    
    var body: some View {
        VStack(spacing: spacing) {
            // Header with logo
            HStack {
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding([.top, .trailing], 16)
                    .onTapGesture {
                        dismiss()
                    }
            }
            
            // Logo - Replace with actual app logo if available
            Image(systemName: "graduationcap.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.accentColor)
                .padding(.top, -spacing) // Offset to compensate for the spacer
            
            // Welcome Title
            Text("Welcome to EduTrack QLD")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // App Description
            Text("Your comprehensive tool for curriculum planning, evidence collection, and professional standards alignment in Queensland education.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Feature Cards
            VStack(spacing: 16) {
                // Feature 1
                WelcomeFeatureCard(
                    icon: "doc.text.magnifyingglass",
                    title: "Streamlined Curriculum Planning",
                    description: "Easily align with Australian Curriculum v9"
                )
                
                // Feature 2
                WelcomeFeatureCard(
                    icon: "folder.badge.plus",
                    title: "Simplified Evidence Collection",
                    description: "Quickly capture and tag student work"
                )
                
                // Feature 3
                WelcomeFeatureCard(
                    icon: "checkmark.seal",
                    title: "Integrated Professional Standards",
                    description: "Link practice to AITSL standards"
                )
            }
            .padding(.vertical)
            
            // Get Started Button
            Button(action: {
                viewModel.markWelcomePopupAsShown()
                dismiss()
            }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(minWidth: 200)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(cornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom)
        }
        .padding(padding)
        .frame(width: 500, height: 650)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 10)
        )
    }
}

// Feature Card Component
struct WelcomeFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .padding(.horizontal)
    }
}

// Preview
struct WelcomePopupView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePopupView()
            .frame(width: 500, height: 650)
            .previewLayout(.sizeThatFits)
    }
} 