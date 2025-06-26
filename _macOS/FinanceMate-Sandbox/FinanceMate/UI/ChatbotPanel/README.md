# Persistent macOS Chatbot UI/UX System

A comprehensive, production-ready chatbot interface designed for native macOS applications with advanced features including smart tagging, autocompletion, and seamless backend integration.

## 🏗️ SANDBOX Environment Notice

This implementation is currently in the Sandbox environment for development and testing. All files include appropriate Sandbox watermarks and are ready for integration with live backend services.

## ✨ Features

### Core Functionality
- **Persistent Sidebar Panel**: Always-visible chatbot panel that integrates seamlessly with your main application
- **Resizable Interface**: User-adjustable panel width with configurable minimum and maximum bounds
- **Native macOS Styling**: Adheres to macOS Human Interface Guidelines with automatic Light/Dark mode support
- **Message Management**: Rich message display with timestamps, state indicators, and user interactions

### Smart Tagging & Autocompletion
- **@ Symbol Triggering**: Type `@` to trigger intelligent autocompletion suggestions
- **Multi-Type Suggestions**: Support for files, folders, app elements, and RAG (knowledge base) items
- **Real-Time Filtering**: Dynamic suggestion filtering as users type
- **Keyboard Navigation**: Full keyboard support with arrow keys and Enter selection
- **Visual Distinction**: Clear visual indicators for different suggestion types

### Advanced UI/UX
- **Streaming Responses**: Real-time message updates with typing indicators
- **Error Handling**: User-friendly error displays with auto-dismissal
- **Loading States**: Comprehensive loading indicators for all async operations
- **Accessibility**: Full keyboard navigation and screen reader support
- **Performance Optimized**: Memory-efficient implementation preventing heap issues

## 🏗️ Architecture

### Component Structure
```
ChatbotPanel/
├── Models/
│   └── ChatModels.swift           # Core data models
├── Services/
│   ├── ChatbotBackendProtocol.swift    # Backend integration protocols
│   └── DemoChatbotService.swift        # Demo implementation for testing
├── ViewModels/
│   └── ChatbotViewModel.swift          # Main state management
├── Views/
│   ├── ChatbotPanelView.swift         # Main panel container
│   └── Components/
│       ├── ChatMessageView.swift      # Individual message display
│       └── ChatInputView.swift        # Input with autocompletion
└── ChatbotPanelIntegration.swift      # Integration utilities
```

### Key Classes

#### `ChatbotViewModel`
- Main state management and business logic
- Handles backend communication and autocompletion
- Manages UI state and error handling

#### `ChatbotPanelView`
- Complete panel interface with all features
- Resizable functionality and panel management
- Integration with main application window

#### `ChatInputView`
- Advanced text input with multi-line support
- Smart tagging and autocompletion UI
- Keyboard event handling and navigation

#### `ChatMessageView`
- Rich message display with formatting support
- State indicators and interaction features
- Context menus and copy functionality

## 🚀 Quick Start

### 1. Basic Integration

```swift
import SwiftUI

struct YourMainApp: View {
    var body: some View {
        ChatbotIntegrationView {
            // Your main application content
            YourMainContentView()
        }
        .onAppear {
            // Initialize with demo services for testing
            ChatbotSetupManager.shared.setupDemoServices()
        }
    }
}
```

### 2. Custom Configuration

```swift
let configuration = ChatConfiguration(
    maxMessageLength: 4000,
    autoScrollEnabled: true,
    showTimestamps: false,
    enableAutocompletion: true,
    minPanelWidth: 280,
    maxPanelWidth: 600,
    maxInputHeight: 120
)

let chatbotPanel = ChatbotPanelView(configuration: configuration)
```

### 3. Backend Integration

```swift
// Implement the protocols with your actual services
class YourChatbotBackend: ChatbotBackendProtocol {
    func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError> {
        // Your implementation
    }
    
    var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> {
        // Your implementation
    }
    
    // ... other required methods
}

class YourAutocompletionService: AutocompletionServiceProtocol {
    func fetchAutocompleteSuggestions(query: String, type: AutocompleteSuggestion.AutocompleteType) async throws -> [AutocompleteSuggestion] {
        // Your implementation
    }
    
    // ... other required methods
}

// Register your services
ChatbotServiceRegistry.shared.register(chatbotBackend: YourChatbotBackend())
ChatbotServiceRegistry.shared.register(autocompletionService: YourAutocompletionService())
```

## 🔌 Backend Integration

### Required Protocols

#### `ChatbotBackendProtocol`
Implement this protocol to connect your chatbot service:

```swift
protocol ChatbotBackendProtocol {
    func sendUserMessage(text: String) -> AnyPublisher<ChatResponse, ChatError>
    var chatbotResponsePublisher: AnyPublisher<ChatMessage, Never> { get }
    func stopCurrentGeneration()
    var isConnected: Bool { get }
    var connectionStatusPublisher: AnyPublisher<Bool, Never> { get }
    func reconnect() -> AnyPublisher<Bool, ChatError>
}
```

#### `AutocompletionServiceProtocol`
Implement this protocol for smart tagging functionality:

```swift
protocol AutocompletionServiceProtocol {
    func fetchAutocompleteSuggestions(query: String, type: AutocompleteSuggestion.AutocompleteType) async throws -> [AutocompleteSuggestion]
    func fetchAllSuggestions(type: AutocompleteSuggestion.AutocompleteType) async throws -> [AutocompleteSuggestion]
    var isServiceAvailable: Bool { get }
}
```

### Autocompletion Types

The system supports four types of autocompletion suggestions:

- **`.file`**: Individual files (PDFs, images, documents)
- **`.folder`**: Directory paths and folder structures  
- **`.appElement`**: UI elements within your application (settings, views, etc.)
- **`.ragItem`**: Knowledge base items from your RAG system

## 🎨 Customization

### Themes
The system automatically adapts to macOS Light and Dark modes. You can customize colors:

```swift
let customTheme = ChatTheme(
    userMessageColor: Color.blue.opacity(0.1),
    botMessageColor: Color.gray.opacity(0.1),
    backgroundColor: Color(NSColor.windowBackgroundColor),
    accentColor: Color.accentColor
)
```

### Configuration Options
Extensive configuration options available:

```swift
let config = ChatConfiguration(
    maxMessageLength: 4000,        // Maximum characters per message
    autoScrollEnabled: true,        // Auto-scroll to new messages
    showTimestamps: false,         // Display message timestamps
    enableAutocompletion: true,    // Enable @ tagging
    minPanelWidth: 280,           // Minimum resizable width
    maxPanelWidth: 600,           // Maximum resizable width
    maxInputHeight: 120           // Maximum input field height
)
```

## 🔧 Advanced Features

### Streaming Support
The system fully supports streaming responses:

```swift
// Backend emits partial responses
let partialMessage = ChatMessage(
    content: "Partial response...",
    isUser: false,
    messageState: .streaming
)

// Final response
let finalMessage = ChatMessage(
    content: "Complete response",
    isUser: false,
    messageState: .sent
)
```

### Error Handling
Comprehensive error handling with user-friendly messages:

```swift
enum ChatError: Error, LocalizedError {
    case sendMessageFailed(String)
    case connectionLost
    case invalidMessage
    case autocompleteServiceUnavailable
    case backendUnavailable
}
```

### Panel Management
Full control over panel visibility and sizing:

```swift
// Toggle panel visibility
viewModel.toggleVisibility()

// Resize panel programmatically
viewModel.resizePanel(to: 400)

// Check if services are ready
if viewModel.areServicesReady {
    // Ready to use
}
```

## 📱 Integration Patterns

### SwiftUI Integration
Use `ChatbotIntegrationView` for automatic layout management:

```swift
ChatbotIntegrationView(configuration: myConfig) {
    YourMainContentView()
}
```

### AppKit Integration
For AppKit applications, use `ChatbotSplitViewController`:

```swift
let mainController = YourMainViewController()
let splitController = ChatbotSplitViewController(mainContent: mainController)
window.contentViewController = splitController
```

### Toolbar Integration
Add a toggle button to your toolbar:

```swift
let chatbotViewModel = ChatbotViewModel()
let toggleButton = ChatbotToggleButton(viewModel: chatbotViewModel)
```

## 🧪 Testing & Demo

The system includes comprehensive demo services for development:

- **`DemoChatbotService`**: Simulates realistic chatbot responses with streaming
- **`DemoAutocompletionService`**: Provides sample file, folder, and app suggestions
- **Realistic Behavior**: Includes network delays, occasional failures, and connection simulation

Enable demo mode:
```swift
ChatbotSetupManager.shared.setupDemoServices()
```

## 🔒 Security & Performance

### Security Features
- No hardcoded API keys or credentials
- Secure service registration pattern
- Error messages don't expose sensitive information

### Performance Optimizations
- Memory-efficient message handling
- Debounced autocompletion queries
- Lazy loading for large conversation histories
- Cancellable async operations

### Memory Management
- Proper cleanup of subscribers and tasks
- Weak references to prevent retain cycles
- Efficient scrollview with lazy loading

## 📋 Requirements

- **macOS**: 12.0+ (Monterey)
- **Swift**: 5.7+
- **SwiftUI**: 4.0+
- **Xcode**: 14.0+

## 🤝 Integration Checklist

- [ ] Implement `ChatbotBackendProtocol` with your service
- [ ] Implement `AutocompletionServiceProtocol` for smart tagging
- [ ] Register services with `ChatbotServiceRegistry`
- [ ] Add `ChatbotPanelView` or `ChatbotIntegrationView` to your UI
- [ ] Configure theming and panel settings
- [ ] Test with demo services first
- [ ] Handle error states appropriately
- [ ] Verify accessibility and keyboard navigation

## 🐛 Troubleshooting

### Common Issues

**Autocompletion not working**
- Verify `AutocompletionServiceProtocol` is implemented and registered
- Check `configuration.enableAutocompletion` is `true`
- Ensure service returns `isServiceAvailable = true`

**Messages not appearing**
- Verify `ChatbotBackendProtocol` is implemented and registered
- Check `chatbotResponsePublisher` is emitting messages
- Ensure proper `ChatMessage` structure

**Panel not resizing**
- Check `minPanelWidth` and `maxPanelWidth` configuration
- Verify proper drag gesture handling
- Ensure adequate window size

### Debug Mode
Enable detailed logging in demo services to troubleshoot integration issues.

## 📚 Additional Resources

- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework Guide](https://developer.apple.com/documentation/combine)

---

**Note**: This implementation is currently in Sandbox mode with demo services. Replace demo implementations with your production services for live deployment.