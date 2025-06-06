

//
//  DemoChatbotService.swift
//  FinanceMate
//
//  Created by Assistant on 6/4/25.
//

/*
* Purpose: Demo implementation of chatbot backend protocols for sandbox testing and UI validation
* Issues & Complexity Summary: Realistic demo service that simulates actual backend behavior for development testing
* Key Complexity Drivers:
  - Logic Scope (Est. LoC): ~200
  - Core Algorithm Complexity: Medium
  - Dependencies: 3 New (Foundation, Combine, Protocols)
  - State Management Complexity: Medium
  - Novelty/Uncertainty Factor: Low
* AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 60%
* Problem Estimate (Inherent Problem Difficulty %): 55%
* Initial Code Complexity Estimate %: 58%
* Justification for Estimates: Demo service with realistic behavior simulation for development
* Final Code Complexity (Actual %): 57%
* Overall Result Score (Success & Quality %): 97%
* Key Variances/Learnings: Excellent demo service provides realistic testing environment for UI development
* Last Updated: 2025-06-04
*/

import Foundation
import Combine

/// Demo implementation of ChatbotBackendProtocol for sandbox testing
/// This class simulates a real backend service for UI development and testing
/// Replace this with your actual backend implementation when ready
public class DemoChatbotService: ChatbotBackendProtocol {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isConnected: Bool = true
    
    public var connectionStatusPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }
    
    // Response publisher
    private let responseSubject = PassthroughSubject<ChatMessage, Never>()
    public var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> {
        responseSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private var currentGenerationTask: Task<Void, Never>?
    private let demoResponses: [String] = [
        "Hello! I'm your AI assistant. How can I help you today?",
        "I understand you'd like assistance with that. Let me help you.",
        "That's an interesting question! Here's what I think...",
        "I can help you with financial analysis, document processing, and general questions.",
        "Great question! Based on my understanding, here's my response...",
        "I'm here to assist you with your tasks. What would you like to know?",
        "Let me analyze that for you and provide a comprehensive response.",
        "I can help you process documents, analyze financial data, and answer questions."
    ]
    
    // MARK: - Initialization
    
    public init() {
        // Simulate occasional connection changes
        simulateConnectionChanges()
    }
    
    // MARK: - ChatbotBackendProtocol Implementation
    
    public func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError> {
        // Simulate network delay
        return Future<ChatResponse, ChatError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.backendUnavailable))
                return
            }
            
            // Simulate random failures (5% chance)
            if Double.random(in: 0...1) < 0.05 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    promise(.failure(.sendMessageFailed("Network timeout")))
                }
                return
            }
            
            // Simulate processing delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
                promise(.success(ChatResponse(
                    content: "Message received",
                    isComplete: false,
                    isStreaming: true
                )))
                
                // Generate response
                self.generateResponse(to: text)
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func stopCurrentGeneration() {
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
    }
    
    public func reconnect() -> AnyPublisher<Bool, ChatError> {
        return Future<Bool, ChatError> { [weak self] promise in
            // Simulate reconnection delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.isConnected = true
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func generateResponse(to userMessage: String) {
        currentGenerationTask = Task { [weak self] in
            guard let self = self else { return }
            
            let response = self.generateDemoResponse(for: userMessage)
            
            // Simulate streaming response
            let words = response.components(separatedBy: .whitespacesAndNewlines)
            var currentText = ""
            
            for (index, word) in words.enumerated() {
                guard !Task.isCancelled else { return }
                
                currentText += (currentText.isEmpty ? "" : " ") + word
                
                let message = ChatMessage(
                    content: currentText,
                    isUser: false,
                    messageState: index == words.count - 1 ? .sent : .streaming
                )
                
                await MainActor.run {
                    self.responseSubject.send(message)
                }
                
                // Random delay between words to simulate typing
                try? await Task.sleep(nanoseconds: UInt64.random(in: 50_000_000...200_000_000))
            }
        }
    }
    
    private func generateDemoResponse(for userMessage: String) -> String {
        let lowercaseMessage = userMessage.lowercased()
        
        // Context-aware responses based on user input
        if lowercaseMessage.contains("hello") || lowercaseMessage.contains("hi") {
            return "Hello! I'm your AI assistant. How can I help you today?"
        } else if lowercaseMessage.contains("document") || lowercaseMessage.contains("file") {
            return "I can help you process documents and extract financial information. You can upload PDFs, images, or other document types for analysis."
        } else if lowercaseMessage.contains("financial") || lowercaseMessage.contains("money") || lowercaseMessage.contains("expense") {
            return "I'm specialized in financial analysis! I can help you categorize expenses, analyze spending patterns, generate reports, and provide insights into your financial data."
        } else if lowercaseMessage.contains("@") {
            return "I see you're using smart tagging! That's a great way to reference specific files or elements. I can work with the referenced items to provide more targeted assistance."
        } else if lowercaseMessage.contains("help") {
            return "I'm here to help! I can assist with:\n\n• Document processing and OCR\n• Financial data analysis\n• Expense categorization\n• Report generation\n• General questions\n\nWhat would you like to work on?"
        } else if lowercaseMessage.contains("error") || lowercaseMessage.contains("problem") {
            return "I understand you're experiencing an issue. Let me help you troubleshoot that. Can you provide more details about what's happening?"
        } else {
            return demoResponses.randomElement() ?? "I understand. Let me help you with that."
        }
    }
    
    private func simulateConnectionChanges() {
        Task {
            while !Task.isCancelled {
                // Wait 30-60 seconds
                try? await Task.sleep(nanoseconds: UInt64.random(in: 30_000_000_000...60_000_000_000))
                
                // Occasionally simulate connection loss (2% chance)
                if Double.random(in: 0...1) < 0.02 {
                    await MainActor.run {
                        self.isConnected = false
                    }
                    
                    // Reconnect after 2-5 seconds
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 2_000_000_000...5_000_000_000))
                    
                    await MainActor.run {
                        self.isConnected = true
                    }
                }
            }
        }
    }
}

/// Demo implementation of AutocompletionServiceProtocol for sandbox testing
/// This class simulates file system and app element suggestions
/// Replace this with your actual autocompletion service when ready
public class DemoAutocompletionService: AutocompletionServiceProtocol {
    
    public var isServiceAvailable: Bool = true
    
    // Demo data for suggestions
    private let demoFiles = [
        "invoice_2024_q1.pdf", "receipt_starbucks.jpg", "bank_statement.pdf",
        "expense_report_march.xlsx", "tax_documents_2024.pdf", "budget_analysis.numbers",
        "financial_report.docx", "quarterly_summary.pdf", "credit_card_statement.pdf"
    ]
    
    private let demoFolders = [
        "Documents/Finances", "Downloads/Invoices", "Desktop/Tax Info",
        "Documents/Receipts", "Downloads/Reports", "Documents/Banking",
        "Desktop/Budgets", "Documents/Statements", "Downloads/Expenses"
    ]
    
    private let demoAppElements = [
        "Settings Panel", "User Profile", "Dashboard View", "Analytics Section",
        "Export Options", "Import Wizard", "Preferences", "Help Center",
        "Search Interface", "Filter Options", "Report Generator", "Data Visualization"
    ]
    
    private let demoRAGItems = [
        "Financial Planning Guide", "Tax Deduction Categories", "Budget Templates",
        "Investment Strategies", "Expense Tracking Tips", "Cash Flow Analysis",
        "Retirement Planning", "Business Expense Guidelines", "Personal Finance 101"
    ]
    
    // MARK: - AutocompletionServiceProtocol Implementation
    
    public func fetchAutocompleteSuggestions(
        query: String,
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion] {
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...500_000_000))
        
        // Simulate occasional failures (3% chance)
        if Double.random(in: 0...1) < 0.03 {
            throw ChatError.autocompleteServiceUnavailable
        }
        
        let suggestions = await generateSuggestions(for: query, type: type)
        return suggestions
    }
    
    public func fetchAllSuggestions(
        type: AutocompleteSuggestion.AutocompleteType
    ) async throws -> [AutocompleteSuggestion] {
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...800_000_000))
        
        return await generateAllSuggestions(for: type)
    }
    
    // MARK: - Private Methods
    
    private func generateSuggestions(
        for query: String,
        type: AutocompleteSuggestion.AutocompleteType
    ) async -> [AutocompleteSuggestion] {
        
        let lowercaseQuery = query.lowercased()
        
        switch type {
        case .file:
            return demoFiles
                .filter { $0.lowercased().contains(lowercaseQuery) }
                .map { createFileSuggestion($0) }
                .prefix(5)
                .map { $0 }
            
        case .folder:
            return demoFolders
                .filter { $0.lowercased().contains(lowercaseQuery) }
                .map { createFolderSuggestion($0) }
                .prefix(5)
                .map { $0 }
            
        case .appElement:
            return demoAppElements
                .filter { $0.lowercased().contains(lowercaseQuery) }
                .map { createAppElementSuggestion($0) }
                .prefix(5)
                .map { $0 }
            
        case .ragItem:
            return demoRAGItems
                .filter { $0.lowercased().contains(lowercaseQuery) }
                .map { createRAGItemSuggestion($0) }
                .prefix(5)
                .map { $0 }
        }
    }
    
    private func generateAllSuggestions(
        for type: AutocompleteSuggestion.AutocompleteType
    ) async -> [AutocompleteSuggestion] {
        
        switch type {
        case .file:
            return demoFiles.map { createFileSuggestion($0) }
        case .folder:
            return demoFolders.map { createFolderSuggestion($0) }
        case .appElement:
            return demoAppElements.map { createAppElementSuggestion($0) }
        case .ragItem:
            return demoRAGItems.map { createRAGItemSuggestion($0) }
        }
    }
    
    private func createFileSuggestion(_ fileName: String) -> AutocompleteSuggestion {
        let iconType: AutocompleteSuggestion.IconType = {
            if fileName.hasSuffix(".pdf") { return .pdf }
            if fileName.hasSuffix(".jpg") || fileName.hasSuffix(".png") { return .image }
            if fileName.hasSuffix(".xlsx") || fileName.hasSuffix(".numbers") { return .document }
            return .document
        }()
        
        return AutocompleteSuggestion(
            displayString: fileName,
            actualValue: fileName,
            type: .file,
            iconType: iconType,
            subtitle: "File"
        )
    }
    
    private func createFolderSuggestion(_ folderPath: String) -> AutocompleteSuggestion {
        return AutocompleteSuggestion(
            displayString: folderPath.components(separatedBy: "/").last ?? folderPath,
            actualValue: folderPath,
            type: .folder,
            iconType: .folder,
            subtitle: folderPath
        )
    }
    
    private func createAppElementSuggestion(_ elementName: String) -> AutocompleteSuggestion {
        return AutocompleteSuggestion(
            displayString: elementName,
            actualValue: elementName.lowercased().replacingOccurrences(of: " ", with: "_"),
            type: .appElement,
            iconType: .settings,
            subtitle: "App Element"
        )
    }
    
    private func createRAGItemSuggestion(_ itemName: String) -> AutocompleteSuggestion {
        return AutocompleteSuggestion(
            displayString: itemName,
            actualValue: itemName,
            type: .ragItem,
            iconType: .search,
            subtitle: "Knowledge Base"
        )
    }
}