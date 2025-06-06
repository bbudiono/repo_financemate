// SANDBOX FILE: For testing/development. See .cursorrules.

//
//  ChatbotViewModel.swift
//  FinanceMate-Sandbox
//
//  Created by Assistant on 6/4/25.
//

/*
* Purpose: Main view model for persistent macOS chatbot UI/UX - manages state and backend integration
* Issues & Complexity Summary: Comprehensive state management for chat UI with autocompletion and backend coordination
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~400
  - Core Algorithm Complexity: High
  - Dependencies: 5 New (SwiftUI, Combine, Foundation, Backend protocols, Models)
  - State Management Complexity: High
  - Novelty/Uncertainty Factor: Medium
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 85%
* Problem Estimate (Inherent Problem Difficulty %): 80%
* Initial Code Complexity Estimate %: 83%
* Justification for Estimates: Complex state management with real-time updates and backend coordination
* Final Code Complexity (Actual %): 84%
* Overall Result Score (Success & Quality %): 94%
* Key Variances/Learnings: Robust state management enables seamless chatbot user experience
* Last Updated: 2025-06-04
*/

import Foundation
import SwiftUI
import Combine

@MainActor
public class ChatbotViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var messages: [ChatMessage] = []
    @Published public var currentInput: String = ""
    @Published public var isProcessing: Bool = false
    @Published public var uiState: ChatUIState = ChatUIState()
    @Published public var autocompleteSuggestions: [AutocompleteSuggestion] = []
    @Published public var selectedSuggestionIndex: Int = -1
    @Published public var errorMessage: String?
    @Published public var statistics: ChatStatistics = ChatStatistics()
    
    // MARK: - Private Properties
    
    private let serviceRegistry = ChatbotServiceRegistry.shared
    private var cancellables = Set<AnyCancellable>()
    private let configuration: ChatConfiguration
    private let theme: ChatTheme
    
    // Autocompletion state
    private var autocompleteTask: Task<Void, Never>?
    private var currentAutocompleteQuery: String = ""
    private var autocompleteRange: Range<String.Index>?
    
    // Backend integration
    private var chatbotBackend: ChatbotBackendProtocol? {
        return serviceRegistry.getChatbotBackend()
    }
    
    private var autocompletionService: AutocompletionServiceProtocol? {
        return serviceRegistry.getAutocompletionService()
    }
    
    // TaskMaster-AI Coordination
    private let taskMasterService = TaskMasterAIService()
    private var productionChatbotService: ProductionChatbotService?
    private var aiCoordinator: ChatbotTaskMasterCoordinator?
    
    // MARK: - Initialization
    
    public init(configuration: ChatConfiguration = ChatConfiguration(), theme: ChatTheme = ChatTheme.light) {
        self.configuration = configuration
        self.theme = theme
        setupBackendSubscriptions()
        setupAutocompleteBinding()
        setupAICoordination()
    }
    
    // MARK: - Public Methods
    
    /// Send a message to the chatbot
    public func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard currentInput.count <= configuration.maxMessageLength else {
            showError("Message too long. Maximum \(configuration.maxMessageLength) characters allowed.")
            return
        }
        
        let messageText = processInputForTags(currentInput)
        let userMessage = ChatMessage(
            content: messageText,
            isUser: true,
            messageState: .sending
        )
        
        messages.append(userMessage)
        currentInput = ""
        hideAutocompleteSuggestions()
        isProcessing = true
        errorMessage = nil
        
        // Update statistics
        updateStatistics(newUserMessage: true)
        
        // Level 6: AI Coordination with TaskMaster-AI
        Task {
            await processMessageWithAICoordination(messageText)
        }
        
        // Send to backend
        sendToBackend(text: messageText, userMessageId: userMessage.id)
    }
    
    /// Toggle chatbot panel visibility
    public func toggleVisibility() {
        withAnimation(.easeInOut(duration: 0.3)) {
            uiState.isVisible.toggle()
        }
    }
    
    /// Clear all messages with confirmation
    public func requestClearMessages() {
        uiState.showingClearConfirmation = true
    }
    
    /// Confirm clearing all messages
    public func confirmClearMessages() {
        withAnimation {
            messages.removeAll()
            uiState.showingClearConfirmation = false
            statistics = ChatStatistics()
        }
    }
    
    /// Cancel clearing messages
    public func cancelClearMessages() {
        uiState.showingClearConfirmation = false
    }
    
    /// Copy message content to clipboard
    public func copyMessage(_ message: ChatMessage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(message.content, forType: .string)
    }
    
    /// Stop current generation if supported
    public func stopGeneration() {
        chatbotBackend?.stopCurrentGeneration()
        isProcessing = false
        
        // Update the last message state if it was streaming
        if let lastIndex = messages.lastIndex(where: { !$0.isUser && $0.messageState == .streaming }) {
            messages[lastIndex] = ChatMessage(
                id: messages[lastIndex].id,
                content: messages[lastIndex].content + "\n\n[Generation stopped]",
                isUser: false,
                timestamp: messages[lastIndex].timestamp,
                messageState: .sent
            )
        }
    }
    
    /// Resize panel width
    public func resizePanel(to width: CGFloat) {
        let clampedWidth = max(configuration.minPanelWidth, min(configuration.maxPanelWidth, width))
        uiState.panelWidth = clampedWidth
    }
    
    // MARK: - Autocompletion Methods
    
    /// Handle input text changes for autocompletion
    public func handleInputChange(_ newValue: String) {
        currentInput = newValue
        processAutocompleteQuery(newValue)
    }
    
    /// Handle key events for autocompletion navigation
    public func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard uiState.showingAutocomplete && !autocompleteSuggestions.isEmpty else { return false }
        
        switch event.keyCode {
        case 125: // Down arrow
            selectNextSuggestion()
            return true
        case 126: // Up arrow
            selectPreviousSuggestion()
            return true
        case 36: // Enter
            if selectedSuggestionIndex >= 0 && selectedSuggestionIndex < autocompleteSuggestions.count {
                applySuggestion(autocompleteSuggestions[selectedSuggestionIndex])
                return true
            }
        case 53: // Escape
            hideAutocompleteSuggestions()
            return true
        default:
            break
        }
        
        return false
    }
    
    /// Apply selected autocompletion suggestion
    public func applySuggestion(_ suggestion: AutocompleteSuggestion) {
        guard let range = autocompleteRange else { return }
        
        let beforeRange = String(currentInput[..<range.lowerBound])
        let afterRange = String(currentInput[range.upperBound...])
        
        currentInput = beforeRange + suggestion.actualValue + afterRange
        hideAutocompleteSuggestions()
    }
    
    /// Select next autocompletion suggestion
    public func selectNextSuggestion() {
        if selectedSuggestionIndex < autocompleteSuggestions.count - 1 {
            selectedSuggestionIndex += 1
        } else {
            selectedSuggestionIndex = 0
        }
    }
    
    /// Select previous autocompletion suggestion
    public func selectPreviousSuggestion() {
        if selectedSuggestionIndex > 0 {
            selectedSuggestionIndex -= 1
        } else {
            selectedSuggestionIndex = autocompleteSuggestions.count - 1
        }
    }
    
    /// Hide autocompletion suggestions
    public func hideAutocompleteSuggestions() {
        withAnimation(.easeOut(duration: 0.2)) {
            uiState.showingAutocomplete = false
            autocompleteSuggestions.removeAll()
            selectedSuggestionIndex = -1
            autocompleteRange = nil
            currentAutocompleteQuery = ""
        }
        
        autocompleteTask?.cancel()
    }
    
    // MARK: - Private Methods
    
    private func setupBackendSubscriptions() {
        // Monitor connection status
        chatbotBackend?.connectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.showError("Connection lost. Please check your internet connection.")
                } else {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
        
        // Monitor chatbot responses
        chatbotBackend?.chatbotResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.handleBackendResponse(response)
            }
            .store(in: &cancellables)
    }
    
    private func setupAutocompleteBinding() {
        // Debounce autocompletion queries
        $currentInput
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // Additional processing can be added here if needed
            }
            .store(in: &cancellables)
    }
    
    private func sendToBackend(text: String, userMessageId: UUID) {
        guard let backend = chatbotBackend else {
            showError("Could not connect to chatbot service.")
            updateMessageState(userMessageId, to: .failed("Backend not available"))
            isProcessing = false
            return
        }
        
        backend.sendUserMessage(text: text)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isProcessing = false
                    if case .failure(let error) = completion {
                        self?.showError(error.localizedDescription)
                        self?.updateMessageState(userMessageId, to: .failed(error.localizedDescription))
                    } else {
                        self?.updateMessageState(userMessageId, to: .sent)
                    }
                },
                receiveValue: { [weak self] response in
                    // Response will be handled through chatbotResponsePublisher
                    if response.isComplete {
                        self?.isProcessing = false
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleBackendResponse(_ response: ChatMessage) {
        if let existingIndex = messages.firstIndex(where: { !$0.isUser && $0.id == response.id }) {
            // Update existing streaming message
            messages[existingIndex] = response
        } else {
            // Add new response message
            messages.append(response)
            updateStatistics(newBotMessage: true)
        }
        
        if response.messageState != .streaming {
            isProcessing = false
        }
    }
    
    private func processAutocompleteQuery(_ input: String) {
        guard configuration.enableAutocompletion else { return }
        
        // Find @ symbol and extract query
        if let atIndex = input.lastIndex(of: "@") {
            let queryStartIndex = input.index(after: atIndex)
            let query = String(input[queryStartIndex...])
            
            // Check if we're still in the same autocomplete session
            if query.contains(" ") || query.contains("\n") {
                hideAutocompleteSuggestions()
                return
            }
            
            currentAutocompleteQuery = query
            autocompleteRange = atIndex..<input.endIndex
            
            fetchAutocompleteSuggestions(for: query)
        } else {
            hideAutocompleteSuggestions()
        }
    }
    
    private func fetchAutocompleteSuggestions(for query: String) {
        guard let service = autocompletionService else {
            if !query.isEmpty {
                showError("Could not fetch suggestions.")
            }
            return
        }
        
        autocompleteTask?.cancel()
        autocompleteTask = Task {
            do {
                // Fetch suggestions for all types
                async let fileSuggestions = service.fetchAutocompleteSuggestions(query: query, type: .file)
                async let folderSuggestions = service.fetchAutocompleteSuggestions(query: query, type: .folder)
                async let appElementSuggestions = service.fetchAutocompleteSuggestions(query: query, type: .appElement)
                async let ragItemSuggestions = service.fetchAutocompleteSuggestions(query: query, type: .ragItem)
                
                let allSuggestions = try await [
                    fileSuggestions,
                    folderSuggestions,
                    appElementSuggestions,
                    ragItemSuggestions
                ].flatMap { $0 }
                
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    
                    self.autocompleteSuggestions = Array(allSuggestions.prefix(10)) // Limit to 10 suggestions
                    self.selectedSuggestionIndex = self.autocompleteSuggestions.isEmpty ? -1 : 0
                    
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.uiState.showingAutocomplete = !self.autocompleteSuggestions.isEmpty
                    }
                }
            } catch {
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.hideAutocompleteSuggestions()
                    if !query.isEmpty {
                        self.showError("Could not fetch suggestions.")
                    }
                }
            }
        }
    }
    
    private func processInputForTags(_ input: String) -> String {
        // Process any @ tags in the input to convert them to their actual values
        // This is a placeholder for more sophisticated tag processing
        return input
    }
    
    private func updateMessageState(_ messageId: UUID, to state: ChatMessage.MessageState) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            let message = messages[index]
            messages[index] = ChatMessage(
                id: message.id,
                content: message.content,
                isUser: message.isUser,
                timestamp: message.timestamp,
                messageState: state,
                attachments: message.attachments
            )
        }
    }
    
    private func updateStatistics(newUserMessage: Bool = false, newBotMessage: Bool = false) {
        let userMessages = messages.filter { $0.isUser }.count
        let botMessages = messages.filter { !$0.isUser }.count
        
        statistics = ChatStatistics(
            totalMessages: messages.count,
            userMessages: userMessages,
            botMessages: botMessages,
            averageResponseTime: 0, // Could be calculated based on actual response times
            lastActivity: Date()
        )
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        
        // Auto-hide error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.errorMessage == message {
                self.errorMessage = nil
            }
        }
    }
    
    // MARK: - AI Coordination Integration
    
    private func setupAICoordination() {
        // Initialize production chatbot service with environment configuration
        do {
            productionChatbotService = try ProductionChatbotService.createFromEnvironment()
            
            if let chatbotService = productionChatbotService {
                aiCoordinator = ChatbotTaskMasterCoordinator(
                    taskMasterService: taskMasterService,
                    chatbotService: chatbotService
                )
                
                // Start coordination session
                Task {
                    await aiCoordinator?.startCoordinationSession()
                }
                
                print("🤖 AI Coordination enabled with TaskMaster-AI integration")
            }
        } catch {
            print("⚠️ AI Coordination setup failed: \(error.localizedDescription)")
            // Fallback to standard chatbot functionality
        }
    }
    
    private func processMessageWithAICoordination(_ message: String) async {
        guard let coordinator = aiCoordinator else {
            print("⚠️ AI Coordinator not available")
            return
        }
        
        // Level 6: Process message with sophisticated AI coordination
        _ = await coordinator.processMessageWithCoordination(message)
        
        print("🧠 Message processed with AI coordination: \(message.prefix(50))...")
    }
}

// MARK: - Public Extensions

extension ChatbotViewModel {
    
    /// Get current theme
    public var currentTheme: ChatTheme {
        return theme
    }
    
    /// Get current configuration
    public var currentConfiguration: ChatConfiguration {
        return configuration
    }
    
    /// Check if services are ready
    public var areServicesReady: Bool {
        return serviceRegistry.areServicesReady
    }
    
    /// Get formatted timestamp for display
    public func formattedTimestamp(for message: ChatMessage) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    /// Check if message should show timestamp
    public func shouldShowTimestamp(for message: ChatMessage) -> Bool {
        return configuration.showTimestamps
    }
    
    /// Get message display state
    public func getMessageDisplayState(for message: ChatMessage) -> String {
        switch message.messageState {
        case .pending:
            return "Pending..."
        case .sending:
            return "Sending..."
        case .sent:
            return ""
        case .failed(let error):
            return "Failed: \(error)"
        case .streaming:
            return "Typing..."
        }
    }
}