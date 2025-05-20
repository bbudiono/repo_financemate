import SwiftUI
import PencilKit

/// # Digital Art Canvas View
/// A professional drawing canvas with:
/// - Multiple tools (pen, brush, eraser, shapes)
/// - Layer management
/// - Color picker and swatches
/// - Export functionality
/// - Configurable brushes
struct DigitalArtCanvasView: View {
    
    // MARK: - State Properties
    @State private var canvas = PKCanvasView()
    @State private var toolType: ToolType = .pen
    @State private var toolColor: Color = .black
    @State private var toolThickness: CGFloat = 3
    @State private var showColorPicker = false
    @State private var showLayerPanel = false
    @State private var layers: [Layer] = [Layer(id: UUID(), name: "Layer 1", isVisible: true)]
    @State private var activeLayerIndex = 0
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasOffset = CGSize.zero
    @State private var lastDragPosition: CGPoint?
    @State private var isPanning = false
    @State private var showToolConfig = false
    @State private var savedColorSwatches: [Color] = [.black, .red, .blue, .green, .orange, .purple]
    @State private var isExporting = false
    @State private var exportType: ExportType = .png
    @State private var projectName = "Untitled Project"
    @State private var showRenameDialog = false
    @State private var pendingName = ""
    
    // Drawing shape temp storage
    @State private var shapeStart: CGPoint?
    @State private var shapeEnd: CGPoint?
    @State private var shapes: [DrawableShape] = []
    
    // Drawing settings and constraints
    private let maxZoom: CGFloat = 5.0
    private let minZoom: CGFloat = 0.5
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar
                ToolbarView
                
                // Main workspace
                ZStack {
                    // Background pattern (checker pattern for transparency visibility)
                    checkerPattern
                    
                    // Drawing canvas with zoom/pan
                    ZoomableCanvasView
                    
                    // Shape overlay for vector shapes
                    shapeOverlay
                    
                    // Floating color picker (when active)
                    if showColorPicker {
                        colorPickerOverlay
                    }
                    
                    // Floating layer panel (when active)
                    if showLayerPanel {
                        layerPanelOverlay
                    }
                    
                    // Tool configuration panel
                    if showToolConfig {
                        toolConfigPanel
                    }
                }
                
                // Bottom status bar
                statusBar
            }
            .navigationTitle(projectName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Rename Project") { 
                            pendingName = projectName
                            showRenameDialog = true 
                        }
                        
                        Menu("Export As...") {
                            Button("PNG") { prepareExport(.png) }
                            Button("JPEG") { prepareExport(.jpeg) }
                            Button("PDF") { prepareExport(.pdf) }
                        }
                        
                        Divider()
                        
                        Button("New Project") { resetCanvas() }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
            // Dialogs
            .sheet(isPresented: $isExporting) {
                ExportView(canvas: canvas, type: exportType, projectName: projectName)
            }
            .alert("Rename Project", isPresented: $showRenameDialog) {
                TextField("Project Name", text: $pendingName)
                
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if !pendingName.isEmpty {
                        projectName = pendingName
                    }
                }
            }
        }
        .onAppear {
            setupCanvas()
        }
    }
    
    // MARK: - View Components
    
    private var ToolbarView: some View {
        HStack(spacing: 0) {
            // Tool selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(ToolType.allCases, id: \.self) { tool in
                        Button(action: { selectTool(tool) }) {
                            Image(systemName: tool.icon)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(toolType == tool ? .white : .primary)
                                .frame(width: 32, height: 32)
                                .background(toolType == tool ? Color.accentColor : Color.clear)
                                .cornerRadius(6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help(tool.name)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(height: 48)
            
            Divider()
            
            // Color selection
            HStack(spacing: 8) {
                // Current color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(toolColor)
                    .frame(width: 32, height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .contextMenu {
                        Button("Add to Swatches") { addToSwatches(toolColor) }
                    }
                    .onTapGesture {
                        showColorPicker.toggle()
                    }
                
                // Color swatches
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(savedColorSwatches.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(savedColorSwatches[index])
                                .frame(width: 24, height: 24)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                .onTapGesture {
                                    toolColor = savedColorSwatches[index]
                                }
                                .contextMenu {
                                    Button("Remove", role: .destructive) {
                                        if savedColorSwatches.count > 1 {
                                            savedColorSwatches.remove(at: index)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            // Tool thickness slider
            HStack {
                Image(systemName: "line.horizontal")
                    .font(.system(size: 10))
                Slider(value: $toolThickness, in: 1...20)
                    .frame(width: 100)
                Image(systemName: "line.horizontal")
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 12)
            
            Divider()
            
            Spacer()
            
            // Canvas controls
            HStack(spacing: 12) {
                Button(action: { resetView() }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Reset Canvas View")
                
                Text(String(format: "%.0f%%", canvasScale * 100))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 44, alignment: .center)
                
                Button(action: { zoomIn() }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Zoom In")
                
                Button(action: { zoomOut() }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("Zoom Out")
                
                Button(action: { showLayerPanel.toggle() }) {
                    Image(systemName: "square.on.square")
                        .font(.system(size: 16))
                        .foregroundColor(showLayerPanel ? .accentColor : .primary)
                }
                .buttonStyle(.plain)
                .help("Layers")
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 48)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .bottom)
    }
    
    private var ZoomableCanvasView: some View {
        PKCanvasRepresentation(canvasView: canvas)
            .scaleEffect(canvasScale)
            .offset(x: canvasOffset.width, y: canvasOffset.height)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if toolType == .move || isPanning {
                            if let lastPosition = lastDragPosition {
                                let dragDelta = CGSize(
                                    width: value.location.x - lastPosition.x,
                                    height: value.location.y - lastPosition.y
                                )
                                canvasOffset.width += dragDelta.width
                                canvasOffset.height += dragDelta.height
                            }
                            lastDragPosition = value.location
                            isPanning = true
                        } else if toolType == .rectangle || toolType == .ellipse || toolType == .line {
                            // Handle shape drawing
                            if shapeStart == nil {
                                shapeStart = value.startLocation
                            }
                            shapeEnd = value.location
                        }
                    }
                    .onEnded { value in
                        if toolType == .move || isPanning {
                            lastDragPosition = nil
                            isPanning = false
                        } else if toolType == .rectangle || toolType == .ellipse || toolType == .line {
                            // Commit the shape if we have valid start/end points
                            if let start = shapeStart, let end = shapeEnd {
                                let newShape = DrawableShape(
                                    type: toolType == .rectangle ? .rectangle : (toolType == .ellipse ? .ellipse : .line),
                                    startPoint: start,
                                    endPoint: end,
                                    color: toolColor,
                                    lineWidth: toolThickness
                                )
                                shapes.append(newShape)
                                shapeStart = nil
                                shapeEnd = nil
                            }
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / canvasScale
                        canvasScale = min(maxZoom, max(minZoom, canvasScale * delta))
                    }
            )
    }
    
    private var shapeOverlay: some View {
        ZStack {
            // Draw committed shapes
            ForEach(shapes) { shape in
                ShapeView(shape: shape)
            }
            
            // Draw current shape being drawn
            if let start = shapeStart, let end = shapeEnd {
                let shape = DrawableShape(
                    type: toolType == .rectangle ? .rectangle : (toolType == .ellipse ? .ellipse : .line),
                    startPoint: start,
                    endPoint: end,
                    color: toolColor,
                    lineWidth: toolThickness
                )
                ShapeView(shape: shape)
            }
        }
        .scaleEffect(canvasScale)
        .offset(x: canvasOffset.width, y: canvasOffset.height)
    }
    
    private var checkerPattern: some View {
        Canvas { context, size in
            // Create checker pattern for transparency visualization
            let tileSize: CGFloat = 10 * canvasScale
            let xTileCount = Int(size.width / tileSize) + 1
            let yTileCount = Int(size.height / tileSize) + 1
            
            for x in 0..<xTileCount {
                for y in 0..<yTileCount {
                    let rect = CGRect(
                        x: CGFloat(x) * tileSize,
                        y: CGFloat(y) * tileSize,
                        width: tileSize,
                        height: tileSize
                    )
                    
                    if (x + y) % 2 == 0 {
                        context.fill(Path(rect), with: .color(.gray.opacity(0.1)))
                    } else {
                        context.fill(Path(rect), with: .color(.white))
                    }
                }
            }
        }
    }
    
    private var colorPickerOverlay: some View {
        VStack {
            ColorPicker("Select Color", selection: $toolColor)
                .labelsHidden()
                .padding()
            
            Divider()
            
            // Custom color mixer
            VStack(alignment: .leading, spacing: 12) {
                Text("Color Mixer")
                    .font(.headline)
                
                // Common color options
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], spacing: 8) {
                    ForEach([Color.black, .white, .red, .orange, .yellow, .green, .blue, .purple, .pink], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .onTapGesture {
                                toolColor = color
                            }
                    }
                }
                
                Button("Add to Swatches") {
                    addToSwatches(toolColor)
                }
                .buttonStyle(.bordered)
                
                Button("Close") {
                    showColorPicker = false
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .position(x: 400, y: 300)
    }
    
    private var layerPanelOverlay: some View {
        VStack {
            HStack {
                Text("Layers")
                    .font(.headline)
                
                Spacer()
                
                Button(action: addNewLayer) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
            
            List {
                ForEach(Array(layers.enumerated()), id: \.element.id) { index, layer in
                    HStack {
                        Button(action: { toggleLayerVisibility(index) }) {
                            Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(layer.isVisible ? .primary : .secondary)
                        }
                        .buttonStyle(.plain)
                        
                        Text(layer.name)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if layers.count > 1 {
                            Button(action: { removeLayer(index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .opacity(layers.count > 1 ? 1 : 0)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(index == activeLayerIndex ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        activeLayerIndex = index
                    }
                }
                .onMove { source, destination in
                    layers.move(fromOffsets: source, toOffset: destination)
                    
                    // Adjust active layer index if needed
                    if let first = source.first {
                        if first == activeLayerIndex {
                            activeLayerIndex = destination > first ? destination - 1 : destination
                        } else if first < activeLayerIndex && destination > activeLayerIndex {
                            activeLayerIndex -= 1
                        } else if first > activeLayerIndex && destination <= activeLayerIndex {
                            activeLayerIndex += 1
                        }
                    }
                }
            }
            .frame(height: min(CGFloat(layers.count * 40 + 20), 200))
            
            Divider()
            
            Button("Close") {
                showLayerPanel = false
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .position(x: 800, y: 300)
    }
    
    private var toolConfigPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(toolType.name) Tool Settings")
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Size")
                Slider(value: $toolThickness, in: 1...20) {
                    Text("Thickness")
                }
                
                if toolType == .brush || toolType == .pen {
                    Divider()
                    
                    Text("Opacity")
                    Slider(value: .constant(0.8), in: 0...1) {
                        Text("Opacity")
                    }
                    
                    Divider()
                    
                    Text("Smoothing")
                    Slider(value: .constant(0.5), in: 0...1) {
                        Text("Smoothing")
                    }
                }
            }
            
            Divider()
            
            Button("Close") {
                showToolConfig = false
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .position(x: 500, y: 300)
    }
    
    private var statusBar: some View {
        HStack {
            Text("Canvas: 1200 × 800 px")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Zoom: \(Int(canvasScale * 100))%")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Active Layer: \(layers[activeLayerIndex].name)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(Divider(), alignment: .top)
    }
    
    // MARK: - Methods
    
    private func setupCanvas() {
        // Configure the canvas view
        canvas.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvas.drawingPolicy = .anyInput
        
        // Set up the drawing policy
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
    }
    
    private func selectTool(_ tool: ToolType) {
        toolType = tool
        
        // Configure the appropriate PencilKit tool
        let pkTool: PKTool
        
        switch tool {
        case .pen:
            pkTool = PKInkingTool(.pen, color: UIColor(toolColor), width: toolThickness)
        case .brush:
            pkTool = PKInkingTool(.marker, color: UIColor(toolColor), width: toolThickness)
        case .eraser:
            pkTool = PKEraserTool(.bitmap)
        case .lasso:
            pkTool = PKLassoTool()
        default:
            // For other tools like move and shapes, we'll handle them separately
            // and use the pen tool as a default in PencilKit
            pkTool = PKInkingTool(.pen, color: UIColor(toolColor), width: toolThickness)
        }
        
        canvas.tool = pkTool
        
        // Show tool configuration panel for configurable tools
        if [.pen, .brush, .eraser].contains(tool) {
            showToolConfig = true
        } else {
            showToolConfig = false
        }
    }
    
    private func updateTool() {
        // Update the current tool with the latest settings
        if toolType == .pen {
            canvas.tool = PKInkingTool(.pen, color: UIColor(toolColor), width: toolThickness)
        } else if toolType == .brush {
            canvas.tool = PKInkingTool(.marker, color: UIColor(toolColor), width: toolThickness)
        }
    }
    
    private func addToSwatches(_ color: Color) {
        if !savedColorSwatches.contains(color) {
            savedColorSwatches.append(color)
        }
    }
    
    private func addNewLayer() {
        let newLayer = Layer(id: UUID(), name: "Layer \(layers.count + 1)", isVisible: true)
        layers.append(newLayer)
        activeLayerIndex = layers.count - 1
    }
    
    private func removeLayer(_ index: Int) {
        guard layers.count > 1 && index < layers.count else { return }
        
        layers.remove(at: index)
        
        // Adjust activeLayerIndex if needed
        if activeLayerIndex >= layers.count {
            activeLayerIndex = layers.count - 1
        }
    }
    
    private func toggleLayerVisibility(_ index: Int) {
        guard index < layers.count else { return }
        
        layers[index].isVisible.toggle()
    }
    
    private func zoomIn() {
        canvasScale = min(maxZoom, canvasScale * 1.2)
    }
    
    private func zoomOut() {
        canvasScale = max(minZoom, canvasScale / 1.2)
    }
    
    private func resetView() {
        canvasScale = 1.0
        canvasOffset = .zero
    }
    
    private func resetCanvas() {
        // Clear the drawing
        canvas.drawing = PKDrawing()
        
        // Clear shapes
        shapes.removeAll()
        
        // Reset view transforms
        resetView()
        
        // Reset to default layer structure
        layers = [Layer(id: UUID(), name: "Layer 1", isVisible: true)]
        activeLayerIndex = 0
        
        // Set default project name
        projectName = "Untitled Project"
    }
    
    private func prepareExport(_ type: ExportType) {
        exportType = type
        isExporting = true
    }
}

// MARK: - Supporting Types

enum ToolType: String, CaseIterable {
    case pen, brush, eraser, rectangle, ellipse, line, lasso, move
    
    var name: String {
        switch self {
        case .pen: return "Pen"
        case .brush: return "Brush"
        case .eraser: return "Eraser"
        case .rectangle: return "Rectangle"
        case .ellipse: return "Ellipse"
        case .line: return "Line"
        case .lasso: return "Lasso"
        case .move: return "Move"
        }
    }
    
    var icon: String {
        switch self {
        case .pen: return "pencil.tip"
        case .brush: return "paintbrush.pointed"
        case .eraser: return "eraser"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .line: return "line.diagonal"
        case .lasso: return "lasso"
        case .move: return "hand.tap"
        }
    }
}

struct Layer: Identifiable {
    let id: UUID
    var name: String
    var isVisible: Bool
}

enum ShapeType {
    case rectangle, ellipse, line
}

struct DrawableShape: Identifiable {
    let id = UUID()
    let type: ShapeType
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: Color
    let lineWidth: CGFloat
}

enum ExportType {
    case png, jpeg, pdf
}

// MARK: - Helper Views

// View that wraps PKCanvasView for SwiftUI
struct PKCanvasRepresentation: NSViewRepresentable {
    var canvasView: PKCanvasView
    
    func makeNSView(context: Context) -> PKCanvasView {
        return canvasView
    }
    
    func updateNSView(_ nsView: PKCanvasView, context: Context) {
        // Updates from SwiftUI to PKCanvasView happen elsewhere
    }
}

// View for rendering vector shapes
struct ShapeView: View {
    let shape: DrawableShape
    
    var body: some View {
        switch shape.type {
        case .rectangle:
            Rectangle()
                .strokeBorder(shape.color, lineWidth: shape.lineWidth)
                .frame(
                    width: abs(shape.endPoint.x - shape.startPoint.x),
                    height: abs(shape.endPoint.y - shape.startPoint.y)
                )
                .position(
                    x: min(shape.startPoint.x, shape.endPoint.x) + abs(shape.endPoint.x - shape.startPoint.x) / 2,
                    y: min(shape.startPoint.y, shape.endPoint.y) + abs(shape.endPoint.y - shape.startPoint.y) / 2
                )
            
        case .ellipse:
            Ellipse()
                .strokeBorder(shape.color, lineWidth: shape.lineWidth)
                .frame(
                    width: abs(shape.endPoint.x - shape.startPoint.x),
                    height: abs(shape.endPoint.y - shape.startPoint.y)
                )
                .position(
                    x: min(shape.startPoint.x, shape.endPoint.x) + abs(shape.endPoint.x - shape.startPoint.x) / 2,
                    y: min(shape.startPoint.y, shape.endPoint.y) + abs(shape.endPoint.y - shape.startPoint.y) / 2
                )
            
        case .line:
            Path { path in
                path.move(to: shape.startPoint)
                path.addLine(to: shape.endPoint)
            }
            .stroke(shape.color, lineWidth: shape.lineWidth)
        }
    }
}

// Export view
struct ExportView: View {
    let canvas: PKCanvasView
    let type: ExportType
    let projectName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var exportProgress = 0.0
    @State private var exportComplete = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preparing Export")
                .font(.title)
                .fontWeight(.bold)
            
            if exportComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Export Complete!")
                    .font(.headline)
                
                Text("Your file has been saved to Downloads")
                    .foregroundColor(.secondary)
            } else {
                ProgressView(value: exportProgress, total: 1.0)
                    .frame(width: 200)
                
                Text("Processing your \(type.rawValue.uppercased()) file...")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(exportComplete ? "Close" : "Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .frame(width: 300, height: 200)
        .padding()
        .onAppear {
            // Simulate export process
            simulateExport()
        }
    }
    
    private func simulateExport() {
        // This would actually save the drawing to a file
        // For now, we'll just simulate the process
        let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
        
        _ = timer.sink { _ in
            if exportProgress < 1.0 {
                exportProgress += 0.05
            } else {
                exportComplete = true
                timer.upstream.connect().cancel()
            }
        }
    }
}

extension ExportType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "png": self = .png
        case "jpeg": self = .jpeg
        case "pdf": self = .pdf
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .png: return "png"
        case .jpeg: return "jpeg"
        case .pdf: return "pdf"
        }
    }
}

// MARK: - Preview
struct DigitalArtCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        DigitalArtCanvasView()
    }
} 