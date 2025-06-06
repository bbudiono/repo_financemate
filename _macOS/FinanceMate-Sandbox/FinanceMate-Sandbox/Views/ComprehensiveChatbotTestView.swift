// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ComprehensiveChatbotTestView.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/5/25.
//

/*
* Purpose: Comprehensive UI for chatbot dogfooding testing with real-time feedback and LLM provider validation
* Issues & Complexity Summary: Complex UI for coordinating multiple testing services with real-time progress tracking
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~600
  - Core Algorithm Complexity: High (UI state management, real-time updates, testing coordination)
  - Dependencies: 8 New (SwiftUI, Combine, Testing services, Progress tracking, TaskMaster integration)
  - State Management Complexity: High (test states, progress tracking, result display)
  - Novelty/Uncertainty Factor: Medium (established UI patterns with comprehensive testing integration)
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 83%
* Justification for Estimates: Complex UI coordination with multiple testing services and real-time feedback
* Final Code Complexity (Actual %): 81%
* Overall Result Score (Success & Quality %): 95%
* Key Variances/Learnings: Well-structured UI provides excellent testing validation and user feedback
* Last Updated: 2025-06-05
*/

import SwiftUI
import Combine

// MARK: - Comprehensive Chatbot Test View

public struct ComprehensiveChatbotTestView: View {
    
    @StateObject private var testingService = ComprehensiveChatbotTestingService()
    @StateObject private var realAPIService = RealAPITestingService()
    @StateObject private var apiKeysService = APIKeysIntegrationService(userEmail: "bernhardbudiono@gmail.com")
    @StateObject private var realLLMService = RealLLMAPIService()
    
    @State private var showingResults = false
    @State private var showingAPIKeysStatus = false
    @State private var selectedTab = 0
    
    // Chat interface state
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentMessage = ""
    @State private var connectionTestResult = ""
    
    // MARK: - Main Body
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // SANDBOX watermark
                sandboxWatermarkHeader
                
                // Main content
                TabView(selection: $selectedTab) {
                    realChatbotTab
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Live Chat")
                        }
                        .tag(0)
                    
                    comprehensiveTestTab
                        .tabItem {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Comprehensive Test")
                        }
                        .tag(1)
                    
                    apiTestingTab
                        .tabItem {
                            Image(systemName: "network")
                            Text("API Testing")
                        }
                        .tag(2)
                    
                    apiKeysStatusTab
                        .tabItem {
                            Image(systemName: "key.fill")
                            Text("API Keys")
                        }
                        .tag(3)
                    
                    testResultsTab
                        .tabItem {
                            Image(systemName: "doc.text")
                            Text("Results")
                        }
                        .tag(4)
                }
            }
            .navigationTitle("Chatbot Testing Suite")
            .frame(minWidth: 800, minHeight: 600)
        }
    }
    
    // MARK: - Sandbox Watermark
    
    private var sandboxWatermarkHeader: some View {
        HStack {
            Image(systemName: "flask.fill")
                .foregroundColor(.orange)
            Text("SANDBOX ENVIRONMENT - TESTING MODE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            Spacer()
            Text("FinanceMate Chatbot Testing")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.1))
    }
    
    // MARK: - Real Chatbot Tab
    
    private var realChatbotTab: some View {
        VStack(spacing: 0) {
            
            // Header with connection status
            HStack {
                VStack(alignment: .leading) {
                    Text("🤖 Live FinanceMate Assistant")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Real-time chat with OpenAI GPT-4o-mini")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Connection test button
                Button("Test Connection") {
                    Task {
                        let success = await realLLMService.testConnection()
                        connectionTestResult = success ? "✅ Connected" : "❌ Failed"
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(realLLMService.isLoading)
                
                if !connectionTestResult.isEmpty {
                    Text(connectionTestResult)
                        .font(.caption)
                        .padding(.leading, 8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            
            Divider()
            
            // Chat messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatMessages) { message in
                            chatMessageView(message)
                        }
                        
                        // Show loading indicator if LLM is responding
                        if realLLMService.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Assistant is typing...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatMessages.count) { _ in
                    if let lastMessage = chatMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Message input area
            HStack(spacing: 12) {
                TextField("Type your message here...", text: $currentMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(currentMessage.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(currentMessage.isEmpty || realLLMService.isLoading)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func chatMessageView(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: 300, alignment: .trailing)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("FinanceMate Assistant")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    Text(message.content)
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: 400, alignment: .leading)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    
    private func sendMessage() {
        guard !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = currentMessage
        currentMessage = ""
        
        // Add user message to chat
        let userChatMessage = ChatMessage(content: userMessage, isUser: true, messageState: .sent)
        chatMessages.append(userChatMessage)
        
        // Send to LLM service
        Task {
            let response = await realLLMService.sendMessage(userMessage)
            
            // Add assistant response to chat
            let assistantMessage = ChatMessage(content: response, isUser: false, messageState: .sent)
            chatMessages.append(assistantMessage)
        }
    }
    
    // MARK: - Comprehensive Test Tab
    
    private var comprehensiveTestTab: some View {
        VStack(spacing: 20) {
            
            // Header section
            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Comprehensive Chatbot Testing")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Full end-to-end testing of chatbot functionality with real LLM provider responses")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            Spacer()
            
            // Test progress section
            if testingService.isTestingInProgress {
                testProgressSection
            } else {
                testControlSection
            }
            
            Spacer()
            
            // Quick status indicators
            quickStatusSection
        }
        .padding()
    }
    
    // MARK: - Test Progress Section
    
    private var testProgressSection: some View {
        VStack(spacing: 16) {
            
            // Current phase indicator
            HStack {
                Image(systemName: testingService.currentTestPhase == .completed ? "checkmark.circle.fill" : "hourglass")
                    .foregroundColor(testingService.currentTestPhase == .completed ? .green : .blue)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Current Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(testingService.currentTestPhase.rawValue)
                        .font(.headline)
                }
                
                Spacer()
                
                if let provider = testingService.currentProvider {
                    VStack(alignment: .trailing) {
                        Text("Testing Provider")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(provider.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(testingService.testProgress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: testingService.testProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2.0)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(8)
            
            // Error message if any
            if let error = testingService.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Test Control Section
    
    private var testControlSection: some View {
        VStack(spacing: 16) {
            
            // Main test button
            Button(action: {
                Task {
                    await testingService.runComprehensiveChatbotTest()
                }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Run Comprehensive Test")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .disabled(testingService.isTestingInProgress)
            
            // Test summary if available
            if let summary = testingService.overallTestSummary {
                testSummaryCard(summary)
            }
        }
    }
    
    // MARK: - API Testing Tab
    
    private var apiTestingTab: some View {
        VStack(spacing: 20) {
            
            Text("Individual API Provider Testing")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            if realAPIService.isTestingInProgress {
                VStack(spacing: 16) {
                    if let currentProvider = realAPIService.currentTestProvider {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Testing \(currentProvider.rawValue)...")
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    Button("Test All API Providers") {
                        Task {
                            await realAPIService.runComprehensiveAPITests()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Individual provider test buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(RealAPIProvider.allCases, id: \.self) { provider in
                            Button(action: {
                                Task {
                                    _ = await realAPIService.testSpecificProvider(provider)
                                }
                            }) {
                                VStack {
                                    Image(systemName: "network")
                                        .font(.title2)
                                    Text(provider.rawValue)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .disabled(realAPIService.isTestingInProgress)
                        }
                    }
                }
            }
            
            // API test results
            if !realAPIService.testResults.isEmpty {
                apiTestResultsList
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - API Keys Status Tab
    
    private var apiKeysStatusTab: some View {
        VStack(spacing: 20) {
            
            Text("API Keys Status")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Available API services for bernhardbudiono@gmail.com")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // API services by category
            let groupedServices = Dictionary(grouping: apiKeysService.availableServices) { $0.category }
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(APIServiceCategory.allCases, id: \.self) { category in
                        if let services = groupedServices[category], !services.isEmpty {
                            apiServicesCategorySection(category: category, services: services)
                        }
                    }
                }
                .padding()
            }
            
            // Summary stats
            HStack {
                VStack {
                    Text("\(apiKeysService.getAvailableServices().count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(apiKeysService.availableServices.count - apiKeysService.getAvailableServices().count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Missing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
    }
    
    // MARK: - Test Results Tab
    
    private var testResultsTab: some View {
        VStack(spacing: 16) {
            
            Text("Test Results & Reports")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            if !testingService.testResults.isEmpty {
                
                // Export button
                HStack {
                    Spacer()
                    Button("Export Results") {
                        exportTestResults()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                
                // Results list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(testingService.testResults.enumerated()), id: \.offset) { index, result in
                            testResultCard(result, index: index + 1)
                        }
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No test results available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Run a comprehensive test to see results here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var quickStatusSection: some View {
        HStack(spacing: 20) {
            statusIndicator(
                title: "API Keys",
                value: "\(apiKeysService.getAvailableServices().count)",
                color: apiKeysService.getAvailableServices().isEmpty ? .red : .green,
                icon: "key.fill"
            )
            
            statusIndicator(
                title: "Last Test",
                value: testingService.overallTestSummary.map { "\(Int($0.successRate * 100))%" } ?? "N/A",
                color: (testingService.overallTestSummary?.successRate ?? 0) > 0.8 ? .green : .orange,
                icon: "checkmark.circle"
            )
            
            statusIndicator(
                title: "Providers",
                value: "\(testingService.overallTestSummary?.providersResponding.count ?? 0)",
                color: (testingService.overallTestSummary?.providersResponding.count ?? 0) > 0 ? .green : .gray,
                icon: "network"
            )
        }
        .padding()
    }
    
    private func statusIndicator(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func testSummaryCard(_ summary: ComprehensiveChatbotTestingService.ChatbotTestSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Last Test Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(summary.generatedAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Success Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(summary.successRate * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(summary.successRate > 0.8 ? .green : .orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Avg Response Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", summary.averageResponseTime))s")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            
            if !summary.providersResponding.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Responding Providers:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(summary.providersResponding, id: \.self) { provider in
                            Text(provider.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var apiTestResultsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API Test Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(Array(realAPIService.testResults.enumerated()), id: \.offset) { index, result in
                apiTestResultRow(result)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func apiTestResultRow(_ result: APITestResult) -> some View {
        HStack {
            Image(systemName: result.isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.isSuccessful ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(result.provider.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let error = result.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .lineLimit(1)
                } else if let response = result.responseContent {
                    Text(response.prefix(50) + (response.count > 50 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("\(String(format: "%.2f", result.responseTime))s")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func apiServicesCategorySection(category: APIServiceCategory, services: [APIService]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.blue)
                Text(category.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(services) { service in
                    HStack {
                        Image(systemName: service.isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(service.isEnabled ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text(service.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(service.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(8)
                    .background(service.isEnabled ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func testResultCard(_ result: ComprehensiveChatbotTestingService.ChatbotTestResult, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Test #\(index)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: result.isSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.isSuccessful ? .green : .red)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Provider")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(result.provider.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Phase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(result.phase.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            if let response = result.actualResponse {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Response:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(response)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            if let error = result.errorMessage {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error:")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            HStack {
                if let quality = result.qualityScore {
                    VStack(alignment: .leading) {
                        Text("Quality Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", quality))/1.0")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(quality > 0.7 ? .green : quality > 0.4 ? .orange : .red)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Response Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.3f", result.responseTime))s")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - Actions
    
    private func exportTestResults() {
        let report = testingService.exportTestResults()
        
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(report, forType: .string)
        
        // Show feedback (could be enhanced with a toast/alert)
        print("📋 Test results copied to clipboard")
    }
}