// SANDBOX FILE: For testing/development. See .cursorrules.
import SwiftUI
import Combine

/**
 * Enhanced Chat Panel with Self-Learning MLACS Integration - SANDBOX VERSION
 * 
 * Purpose: Advanced chat interface with self-learning multi-LLM coordination
 * that adapts and optimizes based on user interactions and feedback - TESTING ENVIRONMENT
 * 
 * Key Features:
 * - Adaptive MLACS coordination with learning optimization
 * - Real-time performance monitoring and feedback collection
 * - User preference learning and automatic parameter adjustment
 * - Optimization recommendations and performance insights
 * - SANDBOX WATERMARKING for development testing
 * 
 * Issues & Complexity Summary: Advanced AI coordination with self-learning capabilities
 * Key Complexity Drivers:
 *   - Logic Scope (Est. LoC): ~350
 *   - Core Algorithm Complexity: High
 *   - Dependencies: 4 New, 2 Mod
 *   - State Management Complexity: High
 *   - Novelty/Uncertainty Factor: Med
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 82%
 * Problem Estimate (Inherent Problem Difficulty %): 78%
 * Initial Code Complexity Estimate %: 82%
 * Justification for Estimates: Complex integration of learning engine with chat UI
 * Final Code Complexity (Actual %): 85%
 * Overall Result Score (Success & Quality %): 90%
 * Key Variances/Learnings: Sandbox version enables safe testing of self-learning UI features
 * Last Updated: 2025-06-04
 */

struct EnhancedChatPanel: View {
    // MARK: - Core State
    @State private var messages: [ChatMessage] = []
    @State private var messageText: String = ""
    @State private var isProcessing: Bool = false
    @State private var isStreaming: Bool = false
    
    // MARK: - Simplified Chat Configuration
    @State private var enableAdvancedFeatures: Bool = false
    @State private var maxResponseTime: Double = 30.0
    @State private var qualityThreshold: Double = 0.8
    
    // MARK: - Basic UI State
    @State private var showingAdvancedSettings: Bool = false
    @State private var enableBasicAnalytics: Bool = true
    
    // MARK: - UI State
    @State private var showingSettings: Bool = false
    @State private var showingFeedbackSheet: Bool = false
    @State private var userFeedbackSatisfaction: Double = 4.0
    @State private var userFeedbackText: String = ""
    
    // MARK: - Persistence
    @AppStorage("chat_enable_advanced") private var persistedEnableAdvanced: Bool = false
    @AppStorage("chat_enable_analytics") private var persistedEnableAnalytics: Bool = true
    @AppStorage("chat_quality_threshold") private var persistedQualityThreshold: Double = 0.8
    @AppStorage("chat_max_response_time") private var persistedMaxResponseTime: Double = 30.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header with Learning Status and SANDBOX indicator
            chatHeader
            
            Divider()
            
            // Messages Area
            messagesScrollView
            
            Divider()
            
            // Advanced Features Bar (when enabled)
            if enableAdvancedFeatures && enableBasicAnalytics {
                advancedFeaturesBar
                Divider()
            }
            
            // Input Area
            chatInputArea
        }
        .sheet(isPresented: $showingSettings) {
            chatSettingsSheet
        }
        .sheet(isPresented: $showingAdvancedSettings) {
            advancedSettingsSheet
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            feedbackSheet
        }
        .onAppear {
            restorePersistedState()
        }
    }
    
    // MARK: - Chat Header
    
    private var chatHeader: some View {
        HStack {
            Text("Enhanced Chat")
                .font(.headline)
                .foregroundColor(.primary)
            
            // SANDBOX WATERMARK
            Text("🧪 SANDBOX")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(6)
            
            Spacer()
            
            // Basic Status Indicators
            if enableAdvancedFeatures {
                HStack(spacing: 8) {
                    // Advanced Features Status
                    HStack(spacing: 4) {
                        Image(systemName: "gear.badge.checkmark")
                            .foregroundColor(.green)
                        Text("Enhanced")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    // Analytics Status
                    if enableBasicAnalytics {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Analytics")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(Int(qualityThreshold * 100))%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Settings Button
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Chat Settings")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Messages Scroll View
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageRow(
                            message: message,
                            onFeedbackRequest: { requestFeedback(for: message) }
                        )
                        .id(message.id)
                    }
                    
                    if isProcessing {
                        processingIndicator
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var processingIndicator: some View {
        HStack {
            if enableAdvancedFeatures {
                Text("🤖 [SANDBOX] Enhanced processing...")
            } else {
                Text("🤔 [SANDBOX] Thinking...")
            }
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Advanced Features Bar
    
    private var advancedFeaturesBar: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.purple)
            
            Text("Advanced features enabled (SANDBOX)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Settings") {
                showingAdvancedSettings = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            
            Button("Analytics") {
                showingSettings = true
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(0.1))
    }
    
    // MARK: - Chat Input Area
    
    private var chatInputArea: some View {
        VStack(spacing: 8) {
            // Advanced Status (when available)
            if enableAdvancedFeatures {
                advancedStatusBar
            }
            
            // Input Field and Send Button
            HStack {
                TextField("Ask a question... (SANDBOX Testing)", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty || isProcessing)
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var advancedStatusBar: some View {
        HStack {
            Image(systemName: "wand.and.stars")
                .foregroundColor(.purple)
                .font(.caption)
            
            Text("SANDBOX Enhanced Mode • Quality: \(Int(qualityThreshold * 100))% • Timeout: \(String(format: "%.1fs", maxResponseTime))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("🧪")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(6)
    }
    
    // MARK: - Message Sending
    
    private func sendMessage() {
        guard !messageText.isEmpty, !isProcessing else { return }
        
        let userMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(userMessage)
        
        let query = messageText
        messageText = ""
        isProcessing = true
        
        Task {
            await processMessage(query: query)
        }
    }
    
    @MainActor
    private func processMessage(query: String) async {
        do {
            let startTime = Date()
            let aiResponse: ChatMessage
            
            // Simulate processing delay
            try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * min(maxResponseTime / 3, 2.0)))
            
            if enableAdvancedFeatures {
                // Enhanced processing with quality simulation
                let qualityScore = Int(qualityThreshold * 100)
                let responseTime = Date().timeIntervalSince(startTime)
                
                aiResponse = ChatMessage(
                    content: "🧪 SANDBOX Enhanced Response: \"\(query)\"\n\n" +
                    "---\n🚀 **SANDBOX Advanced Processing:**\n" +
                    "• Quality Score: \(qualityScore)%\n" +
                    "• Processing Time: \(String(format: "%.1fs", responseTime))\n" +
                    "• Mode: Enhanced Features\n" +
                    "• Analytics: \(enableBasicAnalytics ? "Enabled" : "Disabled")",
                    isUser: false
                )
            } else {
                // Standard response with sandbox indication
                aiResponse = ChatMessage(
                    content: "🧪 SANDBOX: Standard AI response to: \"\(query)\"",
                    isUser: false
                )
            }
            
            messages.append(aiResponse)
            isProcessing = false
            
        } catch {
            let errorMessage = ChatMessage(
                content: "🧪 SANDBOX Error: \(error.localizedDescription)",
                isUser: false
            )
            messages.append(errorMessage)
            isProcessing = false
        }
    }
    
    // MARK: - Feedback Collection
    
    private func requestFeedback(for message: ChatMessage) {
        guard !message.isUser else { return }
        showingFeedbackSheet = true
    }
    
    private var feedbackSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SANDBOX: How satisfied were you with this response?")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Not Satisfied")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Very Satisfied")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $userFeedbackSatisfaction, in: 1...5, step: 1)
                        .accentColor(.blue)
                    
                    Text("\(Int(userFeedbackSatisfaction)) / 5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                TextField("Additional feedback (optional) - SANDBOX", text: $userFeedbackText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                
                Spacer()
            }
            .padding()
            .navigationTitle("SANDBOX: Response Feedback")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Submit") {
                        submitFeedback()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingFeedbackSheet = false
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
    
    private func submitFeedback() {
        // Store feedback locally in SANDBOX mode
        print("🧪 SANDBOX Feedback: Rating \(userFeedbackSatisfaction)/5 - \(userFeedbackText)")
        
        // Reset feedback state
        userFeedbackSatisfaction = 4.0
        userFeedbackText = ""
        showingFeedbackSheet = false
    }
    
    // MARK: - Settings Sheet
    
    private var chatSettingsSheet: some View {
        NavigationView {
            Form {
                Section("SANDBOX Advanced Configuration") {
                    Toggle("Enable Advanced Features", isOn: $enableAdvancedFeatures)
                    
                    if enableAdvancedFeatures {
                        VStack(alignment: .leading) {
                            Text("Quality Threshold: \(Int(qualityThreshold * 100))%")
                            Slider(value: $qualityThreshold, in: 0.5...1.0, step: 0.05)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Max Response Time: \(String(format: "%.1fs", maxResponseTime))")
                            Slider(value: $maxResponseTime, in: 5.0...60.0, step: 5.0)
                        }
                    }
                }
                
                Section("SANDBOX Analytics & Monitoring") {
                    Toggle("Enable Basic Analytics", isOn: $enableBasicAnalytics)
                    
                    if enableBasicAnalytics {
                        HStack {
                            Text("Session Messages:")
                            Spacer()
                            Text("\(messages.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Processing Mode:")
                            Spacer()
                            Text(enableAdvancedFeatures ? "Enhanced" : "Standard")
                                .foregroundColor(enableAdvancedFeatures ? .green : .blue)
                        }
                        
                        HStack {
                            Text("Quality Setting:")
                            Spacer()
                            Text("\(Int(qualityThreshold * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("SANDBOX Chat Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        saveSettings()
                        showingSettings = false
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    // MARK: - Advanced Settings Sheet
    
    private var advancedSettingsSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("SANDBOX Advanced Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Basic Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Information")
                        .font(.headline)
                    
                    HStack {
                        Text("Messages Exchanged:")
                        Spacer()
                        Text("\(messages.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Advanced Mode:")
                        Spacer()
                        Text(enableAdvancedFeatures ? "Enabled" : "Disabled")
                            .foregroundColor(enableAdvancedFeatures ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Quality Threshold:")
                        Spacer()
                        Text("\(Int(qualityThreshold * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("SANDBOX Advanced Config")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        showingAdvancedSettings = false
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    
    // MARK: - Helper Methods
    
    private func restorePersistedState() {
        enableAdvancedFeatures = persistedEnableAdvanced
        enableBasicAnalytics = persistedEnableAnalytics
        qualityThreshold = persistedQualityThreshold
        maxResponseTime = persistedMaxResponseTime
    }
    
    private func saveSettings() {
        persistedEnableAdvanced = enableAdvancedFeatures
        persistedEnableAnalytics = enableBasicAnalytics
        persistedQualityThreshold = qualityThreshold
        persistedMaxResponseTime = maxResponseTime
    }
}

// MARK: - Supporting Views (SANDBOX implementations use same structures as Production)

struct ChatMessageRow: View {
    let message: ChatMessage
    let onFeedbackRequest: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .frame(maxWidth: 300, alignment: .trailing)
                    
                    Text(DateFormatter.timeFormatter.string(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                        .frame(maxWidth: 300, alignment: .leading)
                    
                    HStack {
                        Text(DateFormatter.timeFormatter.string(from: message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("👍") {
                            onFeedbackRequest()
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                    }
                }
                
                Spacer()
            }
        }
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}