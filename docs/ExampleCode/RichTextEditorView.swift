import SwiftUI
import AppKit

/// # Rich Text Editor View
/// Professional word processing interface with:
/// - Text formatting options (bold, italic, underline, etc.)
/// - Paragraph styling
/// - Document structure navigation
/// - Multiple editing modes
struct RichTextEditorView: View {
    // MARK: - State
    @State private var documentTitle = "Untitled Document"
    @State private var textContent = NSAttributedString(string: "Start typing your document here...")
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var fontSize: CGFloat = 12.0
    @State private var fontName = "Helvetica"
    @State private var showFormatPanel = true
    @State private var showNavigator = false
    @State private var documentMode: DocumentMode = .editing
    @State private var documentSections: [DocumentSection] = defaultSections
    @State private var wordCount = 0
    @State private var characterCount = 0
    @State private var currentPage = 1
    @State private var totalPages = 3
    @State private var showInsertMenu = false
    @State private var showExportMenu = false
    @State private var zoom: CGFloat = 1.0
    @State private var lastSaved = Date()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            documentToolbar
                .padding(.horizontal)
                .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Main editor area
            HSplitView {
                // Optional document navigator
                if showNavigator {
                    documentNavigator
                        .frame(width: 200)
                    
                    Divider()
                }
                
                // Main editing area
                VStack(spacing: 0) {
                    // Format toolbar (conditionally shown)
                    if showFormatPanel {
                        formattingToolbar
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.windowBackgroundColor))
                        
                        Divider()
                    }
                    
                    // Document view with rulers
                    documentEditor
                }
            }
            
            Divider()
            
            // Status bar
            statusBar
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color(NSColor.windowBackgroundColor))
        }
    }
    
    // MARK: - UI Components
    
    // Document toolbar with primary actions
    private var documentToolbar: some View {
        HStack {
            // Document title (editable)
            TextField("Document Title", text: $documentTitle)
                .textFieldStyle(.plain)
                .font(.headline)
                .frame(width: 200)
            
            // Last saved
            Text("Last saved \(timeAgo(lastSaved))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Main action buttons
            HStack(spacing: 16) {
                // View mode selector
                Picker("Mode", selection: $documentMode) {
                    ForEach(DocumentMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
                
                // Key action buttons
                Button(action: { showExportMenu.toggle() }) {
                    Label("Export", systemImage: "arrow.up.doc")
                }
                .buttonStyle(.plain)
                
                Menu {
                    Button("Save", action: saveDocument)
                    Button("Save As...", action: saveDocumentAs)
                    Divider()
                    Button("Revert to Last Saved", action: revertDocument)
                } label: {
                    Label("Save", systemImage: "arrow.down.doc")
                }
                
                // Toggle panels
                Button(action: { showNavigator.toggle() }) {
                    Label("Navigator", systemImage: "sidebar.left")
                }
                .buttonStyle(.plain)
                
                Button(action: { showFormatPanel.toggle() }) {
                    Label("Format", systemImage: "textformat")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Text formatting toolbar
    private var formattingToolbar: some View {
        HStack(spacing: 16) {
            // Font picker
            HStack {
                Picker("Font", selection: $fontName) {
                    Text("Helvetica").tag("Helvetica")
                    Text("Times New Roman").tag("Times New Roman")
                    Text("Courier").tag("Courier")
                    Text("Arial").tag("Arial")
                    Text("Georgia").tag("Georgia")
                }
                .labelsHidden()
                .frame(width: 150)
                
                Picker("Size", selection: $fontSize) {
                    Text("9").tag(CGFloat(9))
                    Text("10").tag(CGFloat(10))
                    Text("11").tag(CGFloat(11))
                    Text("12").tag(CGFloat(12))
                    Text("14").tag(CGFloat(14))
                    Text("18").tag(CGFloat(18))
                    Text("24").tag(CGFloat(24))
                    Text("36").tag(CGFloat(36))
                }
                .labelsHidden()
                .frame(width: 60)
            }
            
            Divider()
                .frame(height: 16)
            
            // Text style buttons
            Group {
                Button(action: applyBold) {
                    Image(systemName: "bold")
                }
                .buttonStyle(.plain)
                
                Button(action: applyItalic) {
                    Image(systemName: "italic")
                }
                .buttonStyle(.plain)
                
                Button(action: applyUnderline) {
                    Image(systemName: "underline")
                }
                .buttonStyle(.plain)
                
                Button(action: applyStrikethrough) {
                    Image(systemName: "strikethrough")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .frame(height: 16)
            
            // Paragraph style buttons
            Group {
                Button(action: alignLeft) {
                    Image(systemName: "text.alignleft")
                }
                .buttonStyle(.plain)
                
                Button(action: alignCenter) {
                    Image(systemName: "text.aligncenter")
                }
                .buttonStyle(.plain)
                
                Button(action: alignRight) {
                    Image(systemName: "text.alignright")
                }
                .buttonStyle(.plain)
                
                Button(action: alignJustified) {
                    Image(systemName: "text.justify")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .frame(height: 16)
            
            // List style buttons
            Group {
                Button(action: applyBulletList) {
                    Image(systemName: "list.bullet")
                }
                .buttonStyle(.plain)
                
                Button(action: applyNumberedList) {
                    Image(systemName: "list.number")
                }
                .buttonStyle(.plain)
                
                Button(action: decreaseIndent) {
                    Image(systemName: "decrease.indent")
                }
                .buttonStyle(.plain)
                
                Button(action: increaseIndent) {
                    Image(systemName: "increase.indent")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .frame(height: 16)
            
            // Insert buttons
            Menu {
                Button("Image...", action: insertImage)
                Button("Table...", action: insertTable)
                Button("Chart...", action: insertChart)
                Button("Page Break", action: insertPageBreak)
                Button("Footnote", action: insertFootnote)
                Divider()
                Button("Special Character...", action: insertSpecialCharacter)
                Button("Hyperlink...", action: insertHyperlink)
            } label: {
                Label("Insert", systemImage: "plus.square")
            }
            
            Spacer()
            
            // Color pickers
            ColorPicker("Text Color", selection: .constant(Color.black))
                .labelsHidden()
            
            ColorPicker("Highlight", selection: .constant(Color.yellow.opacity(0.3)))
                .labelsHidden()
        }
    }
    
    // Document navigator sidebar
    private var documentNavigator: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Navigator header
            HStack {
                Text("Navigator")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { /* Toggle navigator options */ }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Document outline
            List {
                Section(header: Text("Document Structure")) {
                    ForEach(documentSections) { section in
                        DocumentSectionRow(section: section)
                    }
                }
                
                Section(header: Text("Media and References")) {
                    NavigatorItem(title: "Images (3)", icon: "photo")
                    NavigatorItem(title: "Tables (1)", icon: "tablecells")
                    NavigatorItem(title: "Citations (5)", icon: "quote.opening")
                    NavigatorItem(title: "Comments (2)", icon: "text.bubble")
                }
                
                Section(header: Text("History")) {
                    NavigatorItem(title: "Yesterday 2:30 PM", icon: "clock.arrow.circlepath")
                    NavigatorItem(title: "Yesterday 11:45 AM", icon: "clock.arrow.circlepath")
                    NavigatorItem(title: "May 14, 4:22 PM", icon: "clock.arrow.circlepath")
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    // Main editor component
    private var documentEditor: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                // Horizontal ruler
                HStack(spacing: 0) {
                    // Space for vertical ruler
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 20, height: 20)
                    
                    PageRulerView(width: 800 * zoom)
                        .frame(height: 20)
                }
                
                HStack(spacing: 0) {
                    // Vertical ruler
                    VerticalRulerView(height: 1100 * zoom)
                        .frame(width: 20)
                    
                    // Document page (A4 proportions)
                    VStack {
                        // Paper
                        RichTextEditorContentView(
                            attributedText: $textContent,
                            selectedRange: $selectedRange,
                            fontSize: fontSize,
                            fontName: fontName
                        )
                        .background(Color.white)
                        .cornerRadius(1)
                        .shadow(radius: 1)
                        .frame(width: 800 * zoom, height: 1100 * zoom)
                        .padding(20)
                        
                        // Space for additional pages
                        if totalPages > 1 {
                            ForEach(2...totalPages, id: \.self) { pageNum in
                                Rectangle()
                                    .fill(Color.white)
                                    .cornerRadius(1)
                                    .shadow(radius: 1)
                                    .frame(width: 800 * zoom, height: 1100 * zoom)
                                    .padding(20)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
    }
    
    // Status bar
    private var statusBar: some View {
        HStack {
            // Word count
            HStack(spacing: 4) {
                Image(systemName: "character.textbox")
                    .font(.caption)
                
                Text("\(wordCount) words, \(characterCount) characters")
                    .font(.caption)
            }
            
            Spacer()
            
            // Page indicator
            HStack(spacing: 4) {
                Image(systemName: "doc")
                    .font(.caption)
                
                Text("Page \(currentPage) of \(totalPages)")
                    .font(.caption)
            }
            
            Spacer()
            
            // Zoom controls
            Slider(value: $zoom, in: 0.5...1.5, step: 0.1)
                .frame(width: 120)
            
            Text("\(Int(zoom * 100))%")
                .font(.caption)
                .frame(width: 40)
            
            Button(action: { zoom = 1.0 }) {
                Text("Reset")
                    .font(.caption)
            }
            .controlSize(.small)
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: - Helper Methods
    
    private func timeAgo(_ date: Date) -> String {
        let minutes = Int(-date.timeIntervalSinceNow / 60)
        if minutes < 1 {
            return "just now"
        } else if minutes < 60 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            let hours = minutes / 60
            if hours < 24 {
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            } else {
                let days = hours / 24
                return "\(days) day\(days == 1 ? "" : "s") ago"
            }
        }
    }
    
    // Format button actions
    private func applyBold() {}
    private func applyItalic() {}
    private func applyUnderline() {}
    private func applyStrikethrough() {}
    
    // Alignment actions
    private func alignLeft() {}
    private func alignCenter() {}
    private func alignRight() {}
    private func alignJustified() {}
    
    // List actions
    private func applyBulletList() {}
    private func applyNumberedList() {}
    private func decreaseIndent() {}
    private func increaseIndent() {}
    
    // Insert actions
    private func insertImage() {}
    private func insertTable() {}
    private func insertChart() {}
    private func insertPageBreak() {}
    private func insertFootnote() {}
    private func insertSpecialCharacter() {}
    private func insertHyperlink() {}
    
    // Document actions
    private func saveDocument() {
        lastSaved = Date()
    }
    
    private func saveDocumentAs() {}
    private func revertDocument() {}
    
    // Sample data
    private static var defaultSections: [DocumentSection] {
        [
            DocumentSection(
                id: UUID(),
                title: "Introduction",
                level: 1,
                children: []
            ),
            DocumentSection(
                id: UUID(),
                title: "Literature Review",
                level: 1,
                children: [
                    DocumentSection(
                        id: UUID(),
                        title: "Previous Studies",
                        level: 2,
                        children: []
                    ),
                    DocumentSection(
                        id: UUID(),
                        title: "Theoretical Framework",
                        level: 2,
                        children: []
                    )
                ]
            ),
            DocumentSection(
                id: UUID(),
                title: "Methodology",
                level: 1,
                children: [
                    DocumentSection(
                        id: UUID(),
                        title: "Research Design",
                        level: 2,
                        children: []
                    ),
                    DocumentSection(
                        id: UUID(),
                        title: "Data Collection",
                        level: 2,
                        children: []
                    ),
                    DocumentSection(
                        id: UUID(),
                        title: "Analysis Techniques",
                        level: 2,
                        children: []
                    )
                ]
            ),
            DocumentSection(
                id: UUID(),
                title: "Results",
                level: 1,
                children: []
            ),
            DocumentSection(
                id: UUID(),
                title: "Discussion",
                level: 1,
                children: []
            ),
            DocumentSection(
                id: UUID(),
                title: "Conclusion",
                level: 1,
                children: []
            ),
            DocumentSection(
                id: UUID(),
                title: "References",
                level: 1,
                children: []
            )
        ]
    }
}

// MARK: - Supporting Views

// Rich text editor content (would integrate with NSTextView in real app)
struct RichTextEditorContentView: View {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    var fontSize: CGFloat
    var fontName: String
    
    var body: some View {
        TextEditor(text: .constant(attributedText.string))
            .font(.system(size: fontSize))
            .padding()
    }
}

// Horizontal page ruler
struct PageRulerView: View {
    let width: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let tickIntervalCm = 35.0 // ~1cm in points
            let numTicks = Int(width / tickIntervalCm) + 1
            
            for i in 0..<numTicks {
                let x = CGFloat(i) * tickIntervalCm
                let isMajor = i % 5 == 0
                let tickHeight: CGFloat = isMajor ? 12.0 : 8.0
                
                let tickPath = Path { path in
                    path.move(to: CGPoint(x: x, y: size.height))
                    path.addLine(to: CGPoint(x: x, y: size.height - tickHeight))
                }
                
                context.stroke(tickPath, with: .color(.gray), lineWidth: isMajor ? 1.0 : 0.5)
                
                if isMajor {
                    let text = "\(i)"
                    let textSize = CGSize(width: 30, height: 16)
                    
                    context.draw(Text(text).font(.system(size: 8)).foregroundColor(.gray), in: CGRect(
                        x: x - textSize.width/2,
                        y: 0,
                        width: textSize.width,
                        height: textSize.height
                    ))
                }
            }
        }
        .frame(width: width)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// Vertical page ruler
struct VerticalRulerView: View {
    let height: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let tickIntervalCm = 35.0 // ~1cm in points
            let numTicks = Int(height / tickIntervalCm) + 1
            
            for i in 0..<numTicks {
                let y = CGFloat(i) * tickIntervalCm
                let isMajor = i % 5 == 0
                let tickWidth: CGFloat = isMajor ? 12.0 : 8.0
                
                let tickPath = Path { path in
                    path.move(to: CGPoint(x: size.width, y: y))
                    path.addLine(to: CGPoint(x: size.width - tickWidth, y: y))
                }
                
                context.stroke(tickPath, with: .color(.gray), lineWidth: isMajor ? 1.0 : 0.5)
                
                if isMajor {
                    let text = "\(i)"
                    let textSize = CGSize(width: 16, height: 16)
                    
                    context.draw(Text(text).font(.system(size: 8)).foregroundColor(.gray), in: CGRect(
                        x: 2,
                        y: y - textSize.height/2,
                        width: textSize.width,
                        height: textSize.height
                    ))
                }
            }
        }
        .frame(height: height)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// Document section row for the navigator
struct DocumentSectionRow: View {
    let section: DocumentSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(section.title)
                    .font(.system(size: 13))
                    .padding(.leading, CGFloat(section.level - 1) * 10)
                Spacer()
            }
            .contentShape(Rectangle())
            
            ForEach(section.children) { child in
                DocumentSectionRow(section: child)
            }
        }
    }
}

// Generic navigator item
struct NavigatorItem: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(title)
                .font(.system(size: 13))
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Data Models

// Document section for navigator
struct DocumentSection: Identifiable {
    let id: UUID
    let title: String
    let level: Int // Heading level (1-6)
    let children: [DocumentSection]
}

// Document editing modes
enum DocumentMode: String, CaseIterable {
    case editing = "Editing"
    case readingView = "Reading View"
    case fullScreen = "Full Screen"
    case reviewing = "Reviewing"
}

// MARK: - Preview
struct RichTextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        RichTextEditorView()
            .frame(width: 1200, height: 900)
    }
} 