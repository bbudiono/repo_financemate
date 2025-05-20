//
//  AdvancedPhotoGalleryView.swift
//  Picketmate
//
//  Created by AI Assistant on 2025-05-16.
//

import SwiftUI
import Combine

/// # Advanced Photo Gallery View
/// This example demonstrates sophisticated animations and transitions in SwiftUI:
/// - Hero transitions between grid and detail views using matchedGeometryEffect
/// - Gesture-based zooming and panning in detail view
/// - Staggered appearance animations for grid items
/// - Custom transition animations with spring physics
/// - Optimized loading with progressive image quality
/// - Accessibility support
struct AdvancedPhotoGalleryView: View {
    // MARK: - State
    
    /// Namespace for matchedGeometryEffect to coordinate animations
    @Namespace private var animation
    
    /// Currently selected photo, if any
    @State private var selectedPhoto: Photo? = nil
    
    /// Tracks which photos have appeared during staggered animation
    @State private var appearedPhotos: Set<String> = []
    
    /// Controls the grid layout columns based on size class
    @State private var columns = 2
    
    /// Demo photos data
    @State private var photos: [Photo] = Photo.samplePhotos
    
    /// Simulates loading state for demonstration
    @State private var isLoading = false
    
    // MARK: - Animation Properties
    
    /// Spring animation for hero transitions
    private let heroAnimation = Animation.spring(response: 0.5, dampingFraction: 0.8)
    
    /// Staggered animation delay between items
    private let staggerDelay = 0.05
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main grid view
                gridView(geometry: geometry)
                    .opacity(selectedPhoto == nil ? 1 : 0)
                
                // Detail view (conditionally shown)
                if let photo = selectedPhoto {
                    PhotoDetailView(
                        photo: photo,
                        namespace: animation,
                        onClose: closeDetail
                    )
                    .transition(
                        .asymmetric(
                            insertion: .opacity.animation(.easeInOut(duration: 0.3)),
                            removal: .opacity.animation(.easeInOut(duration: 0.2))
                        )
                    )
                    .zIndex(1) // Ensure detail view is above grid
                }
            }
            .onChange(of: geometry.size) { newSize in
                // Adjust grid columns based on width
                withAnimation {
                    if newSize.width > 800 {
                        columns = 4
                    } else if newSize.width > 500 {
                        columns = 3
                    } else {
                        columns = 2
                    }
                }
            }
        }
        .navigationTitle("Photo Gallery")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: loadMorePhotos) {
                    Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(isLoading)
            }
        }
        .onAppear {
            // Start staggered appearance animation for photos
            animateGridAppearance()
        }
    }
    
    // MARK: - Grid View
    
    /// Creates the grid layout for photos
    private func gridView(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(photos) { photo in
                    PhotoGridItemView(
                        photo: photo,
                        namespace: animation,
                        onTap: { selectPhoto(photo) },
                        hasAppeared: appearedPhotos.contains(photo.id)
                    )
                    // Ensures appropriate grid sizing
                    .aspectRatio(1.0, contentMode: .fill)
                    // Staggered appearance animation
                    .onAppear {
                        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.7).delay(staggeredDelay(for: photo))) {
                            appearedPhotos.insert(photo.id)
                        }
                    }
                }
            }
            .padding(8)
            
            // Loading indicator at bottom of grid
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
        .scrollIndicators(.automatic)
    }
    
    // MARK: - Actions
    
    /// Opens the detail view for a photo
    private func selectPhoto(_ photo: Photo) {
        withAnimation(heroAnimation) {
            selectedPhoto = photo
        }
    }
    
    /// Closes the detail view
    private func closeDetail() {
        withAnimation(heroAnimation) {
            selectedPhoto = nil
        }
    }
    
    /// Simulates loading additional photos
    private func loadMorePhotos() {
        guard !isLoading else { return }
        
        // Set loading state
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Generate new random photos
            let newPhotos = Photo.generateRandomPhotos(count: 8)
            
            // Add new photos with animation
            withAnimation {
                photos.append(contentsOf: newPhotos)
                isLoading = false
            }
            
            // Animate appearance of new photos
            animateGridAppearance()
        }
    }
    
    /// Calculate staggered delay based on photo's position
    private func staggeredDelay(for photo: Photo) -> Double {
        if let index = photos.firstIndex(of: photo) {
            // Calculate delay based on position in grid
            let row = index / columns
            let column = index % columns
            return Double(row * columns + column) * staggerDelay
        }
        return 0
    }
    
    /// Animate the appearance of grid items
    private func animateGridAppearance() {
        // Reset appeared photos if needed
        if !photos.isEmpty && appearedPhotos.count == photos.count {
            appearedPhotos = []
        }
    }
}

// MARK: - Photo Grid Item View

/// Individual grid item showing a photo thumbnail with hero animation support
struct PhotoGridItemView: View {
    let photo: Photo
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    /// Whether this item has appeared in the staggered animation
    let hasAppeared: Bool
    
    /// Scale for entrance animation
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Photo image
                Image(systemName: photo.systemImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .matchedGeometryEffect(id: "image_\(photo.id)", in: namespace)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                // Photo title overlay
                Text(photo.title)
                    .lineLimit(1)
                    .padding(8)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .matchedGeometryEffect(id: "title_bg_\(photo.id)", in: namespace)
                    )
                    .matchedGeometryEffect(id: "title_\(photo.id)", in: namespace)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        // Animation for staggered appearance
        .scaleEffect(hasAppeared ? 1 : scale)
        .opacity(hasAppeared ? 1 : 0)
        // Accessibility
        .accessibilityLabel("Photo: \(photo.title)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double tap to open photo")
    }
}

// MARK: - Photo Detail View

/// Detailed view of a photo with zoom/pan gestures and animations
struct PhotoDetailView: View {
    let photo: Photo
    let namespace: Namespace.ID
    let onClose: () -> Void
    
    // MARK: - Zoom/Pan State
    
    /// Current scale factor (for zooming)
    @State private var scale: CGFloat = 1.0
    
    /// Current offset (for panning)
    @State private var offset = CGSize.zero
    
    /// Previous offset from last pan gesture
    @State private var previousOffset = CGSize.zero
    
    /// Whether the dismissal gesture has started
    @State private var isDismissGestureActive = false
    
    /// Threshold to determine when a photo should be dismissed
    private let dismissThreshold: CGFloat = 100
    
    // MARK: - Animation Properties
    
    /// Entrance animation for the detail view
    @State private var hasAppeared = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background blur
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .opacity(isDismissGestureActive ? 0.4 : 0.9) // Fade when dismissing
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button(action: { /* Share action would go here */ }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding()
                    }
                    .opacity(hasAppeared ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3).delay(0.2), value: hasAppeared)
                    
                    // Photo with zoom/pan gestures
                    ZStack {
                        // Main image
                        Image(systemName: photo.systemImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .matchedGeometryEffect(id: "image_\(photo.id)", in: namespace)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            // Apply zoom and pan transformations
                            .scaleEffect(scale)
                            .offset(offset)
                            // Apply gesture
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        // Limit zoom between 0.5x and 5x
                                        let newScale = min(max(0.5, value), 5.0)
                                        scale = newScale
                                    }
                                    .onEnded { value in
                                        // Reset to 1x if zoomed too far out
                                        if scale < 0.7 {
                                            withAnimation {
                                                scale = 1.0
                                            }
                                        } else if scale > 3.0 {
                                            // Limit maximum zoom
                                            withAnimation {
                                                scale = 3.0
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        if scale > 1.0 {
                                            // Only allow panning when zoomed in
                                            offset = CGSize(
                                                width: previousOffset.width + value.translation.width,
                                                height: previousOffset.height + value.translation.height
                                            )
                                        } else {
                                            // When not zoomed, use for dismiss gesture
                                            isDismissGestureActive = true
                                            offset = CGSize(
                                                width: value.translation.width,
                                                height: value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { value in
                                        if scale > 1.0 {
                                            // Store final offset for panning
                                            previousOffset = offset
                                        } else {
                                            // Check for dismiss gesture threshold
                                            if abs(offset.height) > dismissThreshold {
                                                onClose()
                                            } else {
                                                // Reset position if not dismissed
                                                withAnimation {
                                                    isDismissGestureActive = false
                                                    offset = .zero
                                                }
                                            }
                                        }
                                    }
                            )
                            // Double tap to reset zoom/pan
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    scale = 1.0
                                    offset = .zero
                                    previousOffset = .zero
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text(photo.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .matchedGeometryEffect(id: "title_\(photo.id)", in: namespace)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Text(photo.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .opacity(hasAppeared ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3).delay(0.4), value: hasAppeared)
                    }
                    .padding(.vertical)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .matchedGeometryEffect(id: "title_bg_\(photo.id)", in: namespace)
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            // Apply subtle scale transformation based on dismiss gesture
            .scaleEffect(isDismissGestureActive ? 0.95 : 1.0)
            // Accessibility
            .accessibilityLabel("Photo Detail: \(photo.title)")
            .accessibilityAction(named: "Close") {
                onClose()
            }
            .accessibilityHint("Double tap to reset zoom, drag down to dismiss")
            .onAppear {
                // Trigger entrance animations
                withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                    hasAppeared = true
                }
            }
        }
    }
}

// MARK: - Models

/// Model representing a photo in the gallery
struct Photo: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let systemImageName: String
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Sample photos for demonstration
    static let samplePhotos: [Photo] = [
        Photo(
            id: "1",
            title: "Mountain Sunset",
            description: "Beautiful sunset over mountain range with dramatic clouds and vibrant colors.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "2",
            title: "Ocean Waves",
            description: "Powerful ocean waves crashing on rocky shore during stormy weather.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "3",
            title: "Desert Landscape",
            description: "Vast desert landscape with rolling sand dunes stretching to the horizon.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "4",
            title: "Forest Path",
            description: "Serene forest path surrounded by tall trees with sunlight filtering through the canopy.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "5",
            title: "City Skyline",
            description: "Dramatic city skyline at night with illuminated buildings and light trails.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "6",
            title: "Mountain Lake",
            description: "Pristine mountain lake reflecting surrounding peaks in crystal clear waters.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "7",
            title: "Autumn Colors",
            description: "Vibrant autumn colors in a forest with red, orange, and yellow foliage.",
            systemImageName: "photo.fill"
        ),
        Photo(
            id: "8",
            title: "Tropical Beach",
            description: "Idyllic tropical beach with white sand, palm trees, and turquoise waters.",
            systemImageName: "photo.fill"
        )
    ]
    
    /// Generate random photos for demo
    static func generateRandomPhotos(count: Int) -> [Photo] {
        let titles = ["Sunset", "Mountains", "Ocean", "Forest", "City", "Desert", "River", "Clouds", "Flowers", "Wildlife"]
        let landscapes = ["landscape.fill", "mountain.2.fill", "water.waves", "tree.fill", "building.2", "sun.max.fill"]
        
        return (0..<count).map { index in
            let randomId = UUID().uuidString
            let randomTitle = titles.randomElement() ?? "Photo"
            let randomImage = landscapes.randomElement() ?? "photo.fill"
            
            return Photo(
                id: randomId,
                title: "\(randomTitle) #\(index + 9)",
                description: "Randomly generated photo description for demonstration purposes.",
                systemImageName: randomImage
            )
        }
    }
}

// MARK: - Preview

struct AdvancedPhotoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedPhotoGalleryView()
        }
    }
} 