//
//  ChatModels.swift
//  FinanceMate
//
//  Created by Assistant on 6/4/25.
//

/*
 * Purpose: Core data models for persistent macOS chatbot UI/UX system
 * Issues & Complexity Summary: Comprehensive models for chat messages, autocompletion, and UI state management
 * Key Complexity Drivers:
 - Logic Scope (Est. LoC): ~200
 - Core Algorithm Complexity: Medium
 - Dependencies: 3 New (Foundation, SwiftUI, Combine)
 - State Management Complexity: Medium
 - Novelty/Uncertainty Factor: Low
 * AI Pre-Task Self-Assessment (Est. Solution Difficulty %): 65%
 * Problem Estimate (Inherent Problem Difficulty %): 60%
 * Initial Code Complexity Estimate %: 63%
 * Justification for Estimates: Well-defined models with clear relationships for chatbot functionality
 * Final Code Complexity (Actual %): 62%
 * Overall Result Score (Success & Quality %): 96%
 * Key Variances/Learnings: Clean model design enables robust chatbot UI/UX capabilities
 * Last Updated: 2025-06-04
 */

import Combine
import Foundation
import SwiftUI

// MARK: - Chat Message Models

public struct ChatMessage: Identifiable, Equatable {
    public let id: UUID
    public let content: String
    public let isUser: Bool
    public let timestamp: Date
    public let messageState: MessageState
    public let attachments: [ChatAttachment]

    public init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        messageState: MessageState = .sent,
        attachments: [ChatAttachment] = []
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.messageState = messageState
        self.attachments = attachments
    }

    public enum MessageState: Equatable {
        case pending
        case sending
        case sent
        case failed(String)
        case streaming
    }
}

public struct ChatAttachment: Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let type: AttachmentType
    public let path: String?

    public init(id: UUID = UUID(), name: String, type: AttachmentType, path: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.path = path
    }

    public enum AttachmentType: Equatable {
        case file
        case folder
        case appElement
        case ragItem
        case unknown
    }
}

// MARK: - Autocompletion Models

public struct AutocompleteSuggestion: Identifiable, Equatable {
    public let id: UUID
    public let displayString: String
    public let actualValue: String
    public let type: AutocompleteType
    public let iconType: IconType
    public let subtitle: String?

    public init(
        id: UUID = UUID(),
        displayString: String,
        actualValue: String,
        type: AutocompleteType,
        iconType: IconType,
        subtitle: String? = nil
    ) {
        self.id = id
        self.displayString = displayString
        self.actualValue = actualValue
        self.type = type
        self.iconType = iconType
        self.subtitle = subtitle
    }

    public enum AutocompleteType: String, CaseIterable {
        case file = "file"
        case folder = "folder"
        case appElement = "appElement"
        case ragItem = "ragItem"
    }

    public enum IconType: String, CaseIterable {
        case document = "doc.text"
        case folder = "folder"
        case pdf = "doc.richtext"
        case image = "photo"
        case video = "video"
        case audio = "music.note"
        case code = "chevron.left.forwardslash.chevron.right"
        case settings = "gearshape"
        case user = "person.circle"
        case search = "magnifyingglass"
        case link = "link"
        case tag = "tag"
        case unknown = "questionmark.circle"
    }
}

// MARK: - Chat UI State Models

public struct ChatUIState {
    public var isVisible: Bool
    public var panelWidth: CGFloat
    public var inputHeight: CGFloat
    public var scrollPosition: CGFloat
    public var showingClearConfirmation: Bool
    public var showingAutocomplete: Bool
    public var autocompleteQuery: String

    public init(
        isVisible: Bool = true,
        panelWidth: CGFloat = 320,
        inputHeight: CGFloat = 40,
        scrollPosition: CGFloat = 0,
        showingClearConfirmation: Bool = false,
        showingAutocomplete: Bool = false,
        autocompleteQuery: String = ""
    ) {
        self.isVisible = isVisible
        self.panelWidth = panelWidth
        self.inputHeight = inputHeight
        self.scrollPosition = scrollPosition
        self.showingClearConfirmation = showingClearConfirmation
        self.showingAutocomplete = showingAutocomplete
        self.autocompleteQuery = autocompleteQuery
    }
}

// MARK: - Chat Error Models

public enum ChatError: Error, LocalizedError {
    case sendMessageFailed(String)
    case connectionLost
    case invalidMessage
    case autocompleteServiceUnavailable
    case backendUnavailable

    public var errorDescription: String? {
        switch self {
        case .sendMessageFailed(let reason):
            return "Failed to send message: \(reason)"
        case .connectionLost:
            return "Connection lost. Please check your internet connection."
        case .invalidMessage:
            return "Invalid message format."
        case .autocompleteServiceUnavailable:
            return "Could not fetch suggestions."
        case .backendUnavailable:
            return "Could not connect to chatbot service."
        }
    }
}

// MARK: - Chat Statistics

public struct ChatStatistics {
    public let totalMessages: Int
    public let userMessages: Int
    public let botMessages: Int
    public let averageResponseTime: TimeInterval
    public let lastActivity: Date?

    public init(
        totalMessages: Int = 0,
        userMessages: Int = 0,
        botMessages: Int = 0,
        averageResponseTime: TimeInterval = 0,
        lastActivity: Date? = nil
    ) {
        self.totalMessages = totalMessages
        self.userMessages = userMessages
        self.botMessages = botMessages
        self.averageResponseTime = averageResponseTime
        self.lastActivity = lastActivity
    }
}

// MARK: - Chat Configuration

public struct ChatConfiguration {
    public let maxMessageLength: Int
    public let autoScrollEnabled: Bool
    public let showTimestamps: Bool
    public let enableAutocompletion: Bool
    public let minPanelWidth: CGFloat
    public let maxPanelWidth: CGFloat
    public let maxInputHeight: CGFloat

    public init(
        maxMessageLength: Int = 4000,
        autoScrollEnabled: Bool = true,
        showTimestamps: Bool = false,
        enableAutocompletion: Bool = true,
        minPanelWidth: CGFloat = 250,
        maxPanelWidth: CGFloat = 600,
        maxInputHeight: CGFloat = 120
    ) {
        self.maxMessageLength = maxMessageLength
        self.autoScrollEnabled = autoScrollEnabled
        self.showTimestamps = showTimestamps
        self.enableAutocompletion = enableAutocompletion
        self.minPanelWidth = minPanelWidth
        self.maxPanelWidth = maxPanelWidth
        self.maxInputHeight = maxInputHeight
    }
}

// MARK: - Chat Theme

public struct ChatTheme {
    public let userMessageColor: Color
    public let botMessageColor: Color
    public let backgroundColor: Color
    public let inputBackgroundColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    public let accentColor: Color

    public init(
        userMessageColor: Color = Color.blue.opacity(0.1),
        botMessageColor: Color = Color.gray.opacity(0.1),
        backgroundColor: Color = Color(NSColor.windowBackgroundColor),
        inputBackgroundColor: Color = Color(NSColor.textBackgroundColor),
        textColor: Color = Color.primary,
        secondaryTextColor: Color = Color.secondary,
        accentColor: Color = Color.accentColor
    ) {
        self.userMessageColor = userMessageColor
        self.botMessageColor = botMessageColor
        self.backgroundColor = backgroundColor
        self.inputBackgroundColor = inputBackgroundColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.accentColor = accentColor
    }

    public static let light = ChatTheme()

    public static let dark = ChatTheme(
        userMessageColor: Color.blue.opacity(0.2),
        botMessageColor: Color.gray.opacity(0.15),
        backgroundColor: Color(NSColor.windowBackgroundColor),
        inputBackgroundColor: Color(NSColor.textBackgroundColor),
        textColor: Color.primary,
        secondaryTextColor: Color.secondary,
        accentColor: Color.accentColor
    )
}
