import SwiftUI
import MapKit

/// # Interactive Map with Overlay Tools and Annotations (Conceptual)
/// Demonstrates an interactive map with overlay tools and annotations that trigger details.
/// Combines:
/// - MapKit integration (Map view)
/// - ZStack for layering overlays
/// - Conceptual drawing/tool overlay
/// - MapAnnotation with interaction triggering modals/popovers
/// - Inspired by the first image's map and the existing InteractiveMapView.
struct InteractiveMapWithOverlays: View {
    // MARK: - State
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Example: Los Angeles
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var annotations: [MapAnnotationItem] = sampleAnnotations
    @State private var selectedAnnotation: MapAnnotationItem? = nil
    @State private var showAnnotationDetails = false
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // MARK: - Map View
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) {
                item in
                MapAnnotation(coordinate: item.coordinate) {
                    AnnotationMarker(item: item) // Reusing the marker view from InteractiveMapView
                        .onTapGesture {
                            selectedAnnotation = item
                            showAnnotationDetails = true
                        }
                }
            }
            .ignoresSafeArea()
            
            // MARK: - Overlay Tools (Conceptual Toolbar)
            VStack(spacing: 10) {
                Text("Map Tools")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                // Conceptual Tool Buttons
                Button(action: { print("Select Tool") }) {
                    Image(systemName: "cursorarrow.rays")
                        .padding(8)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: { print("Draw Line Tool") }) {
                     Image(systemName: "line.diagonal")
                         .padding(8)
                         .background(Color.secondary.opacity(0.2))
                         .cornerRadius(8)
                 }
                 .buttonStyle(.plain)
                
                Button(action: { print("Add Annotation Tool") }) {
                     Image(systemName: "mappin.circle")
                         .padding(8)
                         .background(Color.secondary.opacity(0.2))
                         .cornerRadius(8)
                 }
                 .buttonStyle(.plain)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding() // Outer padding for position
            
            // MARK: - Conceptual Drawing/Overlay Surface
            // This Rectangle represents a layer where custom drawing (like vector shapes)
            // could be implemented on top of the map.
            Rectangle()
                 .fill(Color.red.opacity(0.0))
                 .contentShape(Rectangle()) // Make the whole area tappable/draggable for drawing
                 .allowsHitTesting(activeDrawingTool != nil) // Only active when a drawing tool is selected (conceptual)
                // Add drag gesture for drawing here conceptually
            
        }
        .sheet(isPresented: $showAnnotationDetails) {
            if let annotation = selectedAnnotation {
                AnnotationDetailView(annotation: annotation) // Reusing detail view from InteractiveMapView
            }
        }
        .navigationTitle("Interactive Map")
    }
}

// Reusing supporting views and data models from InteractiveMapView.swift
// struct AnnotationMarker: View { ... }
// struct AnnotationDetailView: View { ... }
// struct MapAnnotationItem: Identifiable { ... }
// enum DrawingTool: String, Identifiable, CaseIterable { ... }
// struct MapShape: Identifiable { ... }

// Sample Data (can be reused or expanded)
// let sampleAnnotations: [MapAnnotationItem] = [ ... ]

// MARK: - Preview
struct InteractiveMapWithOverlays_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMapWithOverlays()
    }
} 