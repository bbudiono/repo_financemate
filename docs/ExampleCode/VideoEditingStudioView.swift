import SwiftUI
import AVKit

/// # Video Editing Studio View
/// Professional video editing interface with:
/// - Multi-track timeline
/// - Clip management
/// - Video preview
/// - Effects and transitions panel
/// - Export options
struct VideoEditingStudioView: View {
    // MARK: - State
    @State private var mediaClips: [MediaClip] = sampleClips
    @State private var selectedClipId: UUID?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var timelineScale: Double = 1.0
    @State private var timelineOffset: CGFloat = 0
    @State private var draggedClip: MediaClip?
    @State private var dragLocation: CGPoint?
    @State private var showEffectsPanel = false
    @State private var showExportSheet = false
    @State private var projectName = "My Video Project"
    @State private var selectedTrackIndex = 0
    @State private var showSplitClipMenu = false
    
    // Timeline dimensions
    private let timelineHeight: CGFloat = 80
    private let trackHeight: CGFloat = 60
    private let timelineHeaderHeight: CGFloat = 40
    private let rulerHeight: CGFloat = 30
    private let secondWidth: CGFloat = 100 // Width of one second at 1.0 scale
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbar
                .padding(.horizontal)
                .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main content
            HSplitView {
                // Media browser and effects panel
                VStack(spacing: 0) {
                    mediaLibraryPanel
                    
                    if showEffectsPanel {
                        Divider()
                        effectsPanel
                    }
                }
                .frame(width: 250)
                
                // Preview and timeline
                VStack(spacing: 0) {
                    // Preview panel
                    previewPanel
                    
                    Divider()
                    
                    // Timeline panel
                    timelinePanel
                }
            }
        }
        .sheet(isPresented: $showExportSheet) {
            exportOptionsSheet
        }
    }
    
    // MARK: - UI Components
    
    // Top toolbar
    private var toolbar: some View {
        HStack {
            // Project name and save indicators
            VStack(alignment: .leading, spacing: 2) {
                Text(projectName)
                    .font(.headline)
                
                Text("Last saved 2 minutes ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Transport controls
            HStack(spacing: 16) {
                Button(action: jumpToStart) {
                    Image(systemName: "backward.end.fill")
                }
                .buttonStyle(.plain)
                
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Button(action: jumpToEnd) {
                    Image(systemName: "forward.end.fill")
                }
                .buttonStyle(.plain)
                
                Text(formatTimecode(currentTime))
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { showEffectsPanel.toggle() }) {
                    Label("Effects", systemImage: "sparkles")
                }
                .buttonStyle(.plain)
                
                Button(action: { showExportSheet = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Media library panel
    private var mediaLibraryPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Media Library")
                    .font(.headline)
                
                Spacer()
                
                Button(action: importMedia) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Media clips list
            List {
                ForEach(MediaCategory.allCases, id: \.self) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(mediaClips.filter { $0.category == category }) { clip in
                            MediaClipRow(clip: clip)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedClipId = clip.id
                                }
                                .draggable(clip.id.uuidString) {
                                    MediaClipDragPreview(clip: clip)
                                }
                        }
                    }
                }
            }
        }
    }
    
    // Effects panel
    private var effectsPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Effects & Transitions")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showEffectsPanel = false }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Effects groups
            List {
                Group {
                    Section(header: Text("Video Effects")) {
                        EffectItem(name: "Color Correction", icon: "camera.filters")
                        EffectItem(name: "Blur", icon: "camera.metering.center.weighted")
                        EffectItem(name: "Stylize", icon: "wand.and.stars")
                    }
                    
                    Section(header: Text("Audio Effects")) {
                        EffectItem(name: "Equalizer", icon: "waveform")
                        EffectItem(name: "Normalize", icon: "speaker.wave.3")
                        EffectItem(name: "Echo", icon: "waveform.path.ecg")
                    }
                    
                    Section(header: Text("Transitions")) {
                        EffectItem(name: "Dissolve", icon: "arrow.left.and.right.square")
                        EffectItem(name: "Push", icon: "arrow.right.square")
                        EffectItem(name: "Wipe", icon: "square.and.pencil")
                    }
                }
                .onDrag { NSItemProvider(object: "effect" as NSString) }
            }
        }
        .frame(height: 300)
    }
    
    // Preview panel with video display
    private var previewPanel: some View {
        VStack {
            // Preview display
            ZStack {
                // Video frame
                Rectangle()
                    .fill(Color.black)
                
                // Sample frame from video
                if let selectedClip = mediaClips.first(where: { $0.id == selectedClipId }) {
                    Image(nsImage: NSImage(named: "sampleFrame") ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                } else {
                    // No selection
                    VStack {
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No preview available")
                            .foregroundColor(.gray)
                    }
                }
                
                // Overlay play button when paused
                if !isPlaying {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 300)
            
            // Preview controls
            HStack {
                Slider(value: $currentTime, in: 0...120)
                    .padding()
            }
        }
    }
    
    // Timeline panel with time ruler and tracks
    private var timelinePanel: some View {
        VStack(spacing: 0) {
            // Zoom controls
            HStack {
                Button(action: zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .buttonStyle(.plain)
                
                Text("Timeline Zoom: \(Int(timelineScale * 100))%")
                    .font(.caption)
                
                Button(action: zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: addNewTrack) {
                    Label("Add Track", systemImage: "plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            // Timeline header with time markers
            ScrollView(.horizontal) {
                ZStack(alignment: .top) {
                    // Time ruler
                    TimeRuler(scale: timelineScale, secondWidth: secondWidth)
                        .frame(height: rulerHeight)
                    
                    // Playhead
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: CGFloat(currentTime) * secondWidth * CGFloat(timelineScale))
                        .frame(maxHeight: .infinity)
                }
                .frame(height: timelineHeaderHeight)
                .padding(.leading, 100) // Space for track labels
                
                // Timeline tracks
                VStack(spacing: 1) {
                    // Video track
                    TimelineTrack(
                        trackIndex: 0,
                        name: "Video",
                        clips: mediaClips.filter { $0.trackIndex == 0 },
                        selectedClipId: $selectedClipId,
                        currentTime: $currentTime,
                        timelineScale: timelineScale,
                        secondWidth: secondWidth,
                        trackHeight: trackHeight,
                        onClipSelected: selectClip,
                        onClipMoved: moveClip
                    )
                    
                    // Audio track
                    TimelineTrack(
                        trackIndex: 1,
                        name: "Audio",
                        clips: mediaClips.filter { $0.trackIndex == 1 },
                        selectedClipId: $selectedClipId,
                        currentTime: $currentTime,
                        timelineScale: timelineScale,
                        secondWidth: secondWidth,
                        trackHeight: trackHeight,
                        onClipSelected: selectClip,
                        onClipMoved: moveClip
                    )
                    
                    // Additional tracks from user
                    ForEach(2..<4) { index in
                        TimelineTrack(
                            trackIndex: index,
                            name: "Track \(index+1)",
                            clips: mediaClips.filter { $0.trackIndex == index },
                            selectedClipId: $selectedClipId,
                            currentTime: $currentTime,
                            timelineScale: timelineScale,
                            secondWidth: secondWidth,
                            trackHeight: trackHeight,
                            onClipSelected: selectClip,
                            onClipMoved: moveClip
                        )
                    }
                }
                .padding(.leading, 100) // Space for track labels
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .dropDestination(for: String.self) { items, location in
            return handleDrop(items: items, location: location)
        }
    }
    
    // Export options sheet
    private var exportOptionsSheet: some View {
        VStack(spacing: 20) {
            Text("Export Project")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Picker("Format", selection: .constant("MP4")) {
                    Text("MP4").tag("MP4")
                    Text("MOV").tag("MOV")
                    Text("AVI").tag("AVI")
                }
                
                Picker("Resolution", selection: .constant("1080p")) {
                    Text("720p").tag("720p")
                    Text("1080p").tag("1080p")
                    Text("4K").tag("4K")
                }
                
                Picker("Quality", selection: .constant("High")) {
                    Text("Draft").tag("Draft")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                    Text("Maximum").tag("Maximum")
                }
                
                HStack {
                    Text("Duration:")
                    Spacer()
                    Text("\(formatTimecode(getProjectDuration()))")
                        .foregroundColor(.secondary)
                }
                
                Toggle("Include Audio", isOn: .constant(true))
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    showExportSheet = false
                }
                
                Spacer()
                
                Button("Export") {
                    // Export would happen here
                    showExportSheet = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 350)
    }
    
    // MARK: - Helper Methods
    
    private func formatTimecode(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let seconds = Int(seconds) % 60
        let frames = Int((seconds - Double(Int(seconds))) * 30)
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
        } else {
            return String(format: "%02d:%02d:%02d", minutes, seconds, frames)
        }
    }
    
    private func importMedia() {
        // Would trigger system file picker in real app
        // For demo, we'll just add a new clip
        let newClip = MediaClip(
            id: UUID(),
            name: "Imported Clip \(Int.random(in: 1...100))",
            duration: Double.random(in: 3...15),
            startTime: 0,
            trackIndex: selectedTrackIndex,
            category: .video,
            thumbnailColor: .blue
        )
        
        mediaClips.append(newClip)
    }
    
    private func selectClip(_ clip: MediaClip) {
        selectedClipId = clip.id
        currentTime = clip.startTime
    }
    
    private func moveClip(_ clip: MediaClip, to trackIndex: Int, startTime: Double) {
        if let index = mediaClips.firstIndex(where: { $0.id == clip.id }) {
            var updatedClip = clip
            updatedClip.trackIndex = trackIndex
            updatedClip.startTime = max(0, startTime)
            mediaClips[index] = updatedClip
        }
    }
    
    private func zoomIn() {
        timelineScale = min(timelineScale * 1.5, 5.0)
    }
    
    private func zoomOut() {
        timelineScale = max(timelineScale / 1.5, 0.5)
    }
    
    private func jumpToStart() {
        currentTime = 0
    }
    
    private func jumpToEnd() {
        currentTime = getProjectDuration()
    }
    
    private func getProjectDuration() -> Double {
        let lastEndTime = mediaClips.map { $0.startTime + $0.duration }.max() ?? 0
        return max(lastEndTime, 60) // Minimum 60-second project
    }
    
    private func handleDrop(items: [String], location: CGPoint) -> Bool {
        // Handle dropping clips onto timeline
        guard let draggedItem = items.first else { return false }
        
        if let uuid = UUID(uuidString: draggedItem),
           let draggedClip = mediaClips.first(where: { $0.id == uuid }) {
            
            // Calculate track index and time based on drop location
            let trackIndex = min(max(Int((location.y) / trackHeight), 0), 3)
            let dropTime = Double(max(0, location.x - 100)) / (secondWidth * timelineScale)
            
            // Create a new instance of the clip at the dropped position
            let newClip = MediaClip(
                id: UUID(),
                name: draggedClip.name,
                duration: draggedClip.duration,
                startTime: dropTime,
                trackIndex: trackIndex,
                category: draggedClip.category,
                thumbnailColor: draggedClip.thumbnailColor
            )
            
            mediaClips.append(newClip)
            return true
        }
        
        // Handle dropping effects onto clips (would be implemented here)
        
        return false
    }
    
    private func addNewTrack() {
        // Would add a new track in a real implementation
        // For this example, we already have fixed tracks
    }
    
    // Sample data for the preview
    private static var sampleClips: [MediaClip] {
        [
            MediaClip(
                id: UUID(),
                name: "Intro Sequence",
                duration: 8.0,
                startTime: 2.0,
                trackIndex: 0,
                category: .video,
                thumbnailColor: .blue
            ),
            MediaClip(
                id: UUID(),
                name: "Main Footage",
                duration: 15.0,
                startTime: 12.0,
                trackIndex: 0,
                category: .video,
                thumbnailColor: .green
            ),
            MediaClip(
                id: UUID(),
                name: "Background Music",
                duration: 30.0,
                startTime: 0.0,
                trackIndex: 1,
                category: .audio,
                thumbnailColor: .purple
            ),
            MediaClip(
                id: UUID(),
                name: "Interview Audio",
                duration: 12.0,
                startTime: 15.0,
                trackIndex: 1,
                category: .audio,
                thumbnailColor: .orange
            ),
            MediaClip(
                id: UUID(),
                name: "B-Roll Footage",
                duration: 5.0,
                startTime: 0.0,
                trackIndex: 2,
                category: .video,
                thumbnailColor: .red
            )
        ]
    }
}

// MARK: - Supporting Views & Types

// Timeline track view
struct TimelineTrack: View {
    let trackIndex: Int
    let name: String
    let clips: [MediaClip]
    @Binding var selectedClipId: UUID?
    @Binding var currentTime: Double
    let timelineScale: Double
    let secondWidth: CGFloat
    let trackHeight: CGFloat
    let onClipSelected: (MediaClip) -> Void
    let onClipMoved: (MediaClip, Int, Double) -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Track background
            Rectangle()
                .fill(Color(NSColor.textBackgroundColor))
                .overlay(
                    GeometryReader { geometry in
                        // Time grid
                        ForEach(0..<Int(120), id: \.self) { second in
                            if second % 5 == 0 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 1)
                                    .offset(x: CGFloat(second) * secondWidth * CGFloat(timelineScale))
                            }
                        }
                    }
                )
            
            // Track label (positioned outside the ZStack, handled by padding)
            HStack {
                Text(name)
                    .font(.caption)
                    .frame(width: 90, alignment: .leading)
                    .padding(.leading, 8)
                    .foregroundColor(.primary)
                    .offset(x: -100) // To position outside
                Spacer()
            }
            
            // Media clips in this track
            ForEach(clips) { clip in
                TimelineClip(
                    clip: clip,
                    isSelected: selectedClipId == clip.id,
                    timelineScale: timelineScale,
                    secondWidth: secondWidth,
                    trackHeight: trackHeight,
                    onSelected: {
                        onClipSelected(clip)
                    },
                    onMoved: { newStartTime in
                        onClipMoved(clip, trackIndex, newStartTime)
                    }
                )
            }
        }
        .frame(height: trackHeight)
        .clipped()
    }
}

// Individual clip in the timeline
struct TimelineClip: View {
    let clip: MediaClip
    let isSelected: Bool
    let timelineScale: Double
    let secondWidth: CGFloat
    let trackHeight: CGFloat
    let onSelected: () -> Void
    let onMoved: (Double) -> Void
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Clip header with name
            Text(clip.name)
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(clip.thumbnailColor.opacity(0.8))
                .foregroundColor(.white)
            
            // Clip body
            Rectangle()
                .fill(clip.thumbnailColor.opacity(0.4))
                .overlay(
                    VStack {
                        if clip.category == .video {
                            Image(systemName: "film")
                                .foregroundColor(clip.thumbnailColor)
                        } else {
                            Image(systemName: "waveform")
                                .foregroundColor(clip.thumbnailColor)
                        }
                        
                        Text(String(format: "%.1fs", clip.duration))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                )
        }
        .frame(width: CGFloat(clip.duration) * secondWidth * CGFloat(timelineScale))
        .frame(height: trackHeight)
        .background(clip.thumbnailColor.opacity(0.3))
        .cornerRadius(3)
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(isSelected ? Color.yellow : Color.gray, lineWidth: isSelected ? 2 : 1)
        )
        .offset(x: CGFloat(clip.startTime) * secondWidth * CGFloat(timelineScale))
        .position(x: CGFloat(clip.startTime) * secondWidth * CGFloat(timelineScale) + 
                    (CGFloat(clip.duration) * secondWidth * CGFloat(timelineScale)) / 2, 
                 y: trackHeight / 2)
        .gesture(
            DragGesture(minimumDistance: 2)
                .onChanged { value in
                    isDragging = true
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    // Calculate new position
                    let dragInSeconds = dragOffset / (secondWidth * CGFloat(timelineScale))
                    onMoved(clip.startTime + Double(dragInSeconds))
                    isDragging = false
                    dragOffset = 0
                }
        )
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .zIndex(isSelected ? 10 : 0)
        .contextMenu {
            Button("Split at Playhead") {}
            Button("Duplicate") {}
            Button("Delete", role: .destructive) {}
        }
        .onTapGesture {
            onSelected()
        }
    }
}

// Time ruler for the timeline
struct TimeRuler: View {
    let scale: Double
    let secondWidth: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // Draw time markers
            for second in 0...120 {
                let x = CGFloat(second) * secondWidth * CGFloat(scale)
                
                // Major tick every 5 seconds
                let tickHeight: CGFloat = second % 5 == 0 ? 12.0 : 6.0
                
                let tickPath = Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: tickHeight))
                }
                
                context.stroke(tickPath, with: .color(.gray), lineWidth: 1)
                
                // Add text labels for major ticks
                if second % 5 == 0 {
                    let text = "\(second)s"
                    let textSize = CGSize(width: 30, height: 16)
                    
                    context.draw(Text(text).font(.system(size: 10)), in: CGRect(
                        x: x - textSize.width/2,
                        y: tickHeight + 2,
                        width: textSize.width,
                        height: textSize.height
                    ))
                }
            }
        }
    }
}

// Media clip display for the library
struct MediaClipRow: View {
    let clip: MediaClip
    
    var body: some View {
        HStack {
            // Thumbnail
            RoundedRectangle(cornerRadius: 4)
                .fill(clip.thumbnailColor.opacity(0.3))
                .frame(width: 40, height: 30)
                .overlay(
                    Group {
                        if clip.category == .video {
                            Image(systemName: "film")
                                .foregroundColor(clip.thumbnailColor)
                        } else {
                            Image(systemName: "waveform")
                                .foregroundColor(clip.thumbnailColor)
                        }
                    }
                )
            
            VStack(alignment: .leading) {
                Text(clip.name)
                    .lineLimit(1)
                
                Text(String(format: "%.1fs", clip.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// Drag preview for media clips
struct MediaClipDragPreview: View {
    let clip: MediaClip
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(clip.thumbnailColor.opacity(0.7))
                .frame(width: 30, height: 20)
            
            Text(clip.name)
                .font(.caption)
                .lineLimit(1)
                .padding(.trailing, 4)
        }
        .padding(6)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(6)
        .shadow(radius: 2)
    }
}

// Effect item in the effects panel
struct EffectItem: View {
    let name: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(name)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models

struct MediaClip: Identifiable {
    let id: UUID
    let name: String
    let duration: Double
    var startTime: Double
    var trackIndex: Int
    let category: MediaCategory
    let thumbnailColor: Color
}

enum MediaCategory: String, CaseIterable {
    case video = "Video"
    case audio = "Audio"
    case image = "Images"
    case title = "Titles"
}

// MARK: - Previews
struct VideoEditingStudioView_Previews: PreviewProvider {
    static var previews: some View {
        VideoEditingStudioView()
            .frame(width: 1200, height: 800)
    }
} 