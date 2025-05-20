import SwiftUI
import MapKit

/// # Interactive Map with Vector Tools View
/// Professional view for map interaction with drawing and annotation tools:
/// - Integrated map display (MapKit)
/// - Drawing tools (conceptual: lines, shapes)
/// - Interactive annotations (markers, labels)
/// - Modals/Popovers for detail/editing
struct InteractiveMapView: View {
    // MARK: - State
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Example: Los Angeles
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var annotations: [MapAnnotationItem] = sampleAnnotations
    @State private var drawingShapes: [MapShape] = [] // Conceptual drawn shapes
    @State private var activeDrawingTool: DrawingTool? = nil
    @State private var selectedAnnotation: MapAnnotationItem? = nil
    @State private var showAnnotationDetails = false
    
    // MARK: - Body
    var body: some View {
        VVStack(spacing: 0) {
            // Map View
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) {
                item in
                MapAnnotation(coordinate: item.coordinate) {
                    AnnotationMarker(item: item)
                        .onTapGesture {
                            selectedAnnotation = item
                            showAnnotationDetails = true
                        }
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                // Drawing Tools Toolbar
                VStack(spacing: 10) {
                    ForEach(DrawingTool.allCases) {
                        tool in
                        Button(action: { activeDrawingTool = tool }) {
                            Image(systemName: tool.icon)
                                .padding(8)
                                .background(activeDrawingTool == tool ? Color.accentColor : Color.secondary.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding()
            }
            .sheet(isPresented: $showAnnotationDetails) {
                if let annotation = selectedAnnotation {
                    AnnotationDetailView(annotation: annotation)
                }
            }
            
            // Conceptual Drawing Canvas Overlay
            // This would handle drawing gestures and add shapes to `drawingShapes`
            // ZStack { ... drawing canvas implementation ... }
            
            // Map Controls (Conceptual: Layers, Filters)
            HStack {
                Text("Map Controls (Layers, Filters etc.)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 30)
            .background(Color.gray.opacity(0.1))
        }
    }
}

// MARK: - Supporting Views

/// Custom marker view for annotations
struct AnnotationMarker: View {
    let item: MapAnnotationItem
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(item.color.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.icon)
                    .foregroundColor(.white)
                    .font(.title2)
            }
            Text(item.name)
                .font(.caption)
                .padding(.horizontal, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(4)
        }
    }
}

/// Detail view for a selected annotation (presented in a sheet)
struct AnnotationDetailView: View {
    let annotation: MapAnnotationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(annotation.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: annotation.icon)
                    .foregroundColor(annotation.color)
                    .font(.title)
            }
            
            Text("Latitude: \(annotation.coordinate.latitude), Longitude: \(annotation.coordinate.longitude)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Details about the location or annotation...")
                .font(.body)
            
            Spacer()
            
            Button("Done") {
                // Dismiss sheet
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 400)
    }
}

// MARK: - Data Models

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let icon: String
    let color: Color
}

enum DrawingTool: String, Identifiable, CaseIterable {
    case marker, line, shape, text
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .marker: return "mappin.circle.fill"
        case .line: return "line.diagonal"
        case .shape: return "square.on.circle"
        case .text: return "textformat"
        }
    }
}

struct MapShape: Identifiable { // Conceptual model for drawn shapes
    let id = UUID()
    // Properties to define the shape (e.g., coordinates, type)
    // var coordinates: [CLLocationCoordinate2D]
    // var type: ShapeType
}

enum ShapeType { // Conceptual shape types
    case polyline, polygon, circle
}

// Sample Data
let sampleAnnotations: [MapAnnotationItem] = [
    MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), name: "Los Angeles", icon: "house.fill", color: .red),
    MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), name: "New York", icon: "building.2.fill", color: .blue),
    MapAnnotationItem(coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), name: "Paris", icon: "book.closed.fill", color: .green)
]

// MARK: - Previews
struct InteractiveMapView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMapView()
            .frame(width: 800, height: 600)
    }
} 