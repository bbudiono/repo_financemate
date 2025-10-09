# Technical Architecture Specification

**Purpose**: This document defines the technical architecture of FinanceMate, including system components, data flow, and design patterns.

**Version**: 1.0.0
**Last Updated**: 2025-10-09

## EXECUTIVE SUMMARY

FinanceMate is built using the MVVM (Model-View-ViewModel) architecture pattern with SwiftUI, ensuring separation of concerns, testability, and maintainability. The application leverages Core Data for persistence and follows Test-Driven Development principles.

## PROJECT OVERVIEW

### Core Components

#### 1. Presentation Layer (Views)
- **Dashboard**: Main financial overview interface
- **Transactions**: Transaction management and categorization
- **Gmail**: Email integration and receipt processing
- **Settings**: Application configuration and preferences

#### 2. Business Logic Layer (ViewModels)
- **DashboardViewModel**: Financial data aggregation and presentation
- **TransactionsViewModel**: Transaction management logic
- **GmailViewModel**: Email processing and transaction extraction
- **SettingsViewModel**: Configuration management

#### 3. Data Layer (Models & Services)
- **Core Data Models**: Persistent data storage
- **Gmail Service**: Email API integration
- **Transaction Service**: Business logic for financial operations
- **Authentication Manager**: OAuth and user session management

## TECHNICAL ARCHITECTURE

### Architecture Pattern: MVVM

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      View       │    │   ViewModel     │    │     Model       │
│  (SwiftUI)      │◄──►│  (Business      │◄──►│ (Core Data)     │
│                 │    │   Logic)        │    │                 │
│ • UI State      │    │ • State Mgmt    │    │ • Data Models   │
│ • User Input    │    │ • Validation    │    │ • Persistence   │
│ • Presentation  │    │ • Services      │    │ • Business      │
└─────────────────┘    └─────────────────┘    │   Rules         │
                                              └─────────────────┘
```

### Key Architectural Principles

1. **Single Responsibility**: Each component has a single, well-defined purpose
2. **Dependency Injection**: Services are injected into ViewModels
3. **Observable Objects**: ViewModels use `@Observable` for state management
4. **Testability**: All business logic is unit testable

### Data Flow

```
User Action → View → ViewModel → Service → Core Data
     ↑                                           ↓
   Update ← State Change ← Business Logic ← Data Store
```

## Core Components

### 1. Authentication System
- **Manager**: `AuthenticationManager`
- **Protocol**: OAuth 2.0 with Gmail
- **Storage**: Keychain for secure token storage
- **State Management**: `AuthenticationViewModel`

### 2. Transaction Management
- **Models**: `Transaction`, `LineItem`, `SplitAllocation`
- **Service**: `TransactionService`
- **Features**: CRUD operations, categorization, search, filter
- **Validation**: Business rule validation

### 3. Gmail Integration
- **Service**: `GmailService`, `EmailOAuthManager`
- **Processing**: Receipt extraction and transaction creation
- **Authentication**: OAuth 2.0 flow
- **Rate Limiting**: API rate limit management

### 4. Core Data Stack
- **Model**: Programmatic model with entities
- **Context**: Main context for UI operations
- **Persistence**: Background context for data operations
- **Migration**: Automatic migration support

## Technology Stack

### Frameworks & Libraries
- **SwiftUI**: User interface framework
- **Core Data**: Persistent storage
- **Combine**: Reactive programming (for async operations)
- **Foundation**: Core system functionality

### External Integrations
- **Gmail API**: Email access and receipt processing
- **Anthropic API**: AI-powered financial insights
- **Apple Sign In**: User authentication

### Development Tools
- **Xcode**: IDE and build system
- **XCTest**: Unit and integration testing
- **Swift Package Manager**: Dependency management

## Security Architecture

### Data Protection
- **Keychain Storage**: Sensitive data (tokens, credentials)
- **App Sandbox**: Application sandboxing
- **Network Security**: HTTPS for all network communications
- **Data Encryption**: Core Data encryption where appropriate

### Authentication
- **OAuth 2.0**: Secure third-party authentication
- **Token Management**: Secure token storage and refresh
- **Session Management**: User session lifecycle

## Performance Considerations

### Optimization Strategies
- **Lazy Loading**: Data loaded on demand
- **Background Processing**: Heavy operations on background queues
- **Caching**: Frequently accessed data cached in memory
- **Pagination**: Large datasets paginated

### Memory Management
- **Weak References**: Avoid retain cycles
- **Automatic Reference Counting**: Proper memory management
- **Background Context**: Prevent UI blocking

## Testing Architecture

### Test Structure
- **Unit Tests**: Business logic validation
- **Integration Tests**: Component interaction testing
- **E2E Tests**: Complete workflow validation
- **Mock Services**: Test doubles for external dependencies

### Test Coverage
- **Target**: >90% code coverage
- **Critical Paths**: 100% coverage
- **Business Logic**: Comprehensive test coverage

## Deployment Architecture

### Build Configuration
- **Debug**: Development build with debugging enabled
- **Release**: Production build with optimizations
- **Code Signing**: Apple developer certificate required

### Distribution
- **Direct Distribution**: For enterprise deployment
- **App Store**: Public distribution (future)
- **TestFlight**: Beta testing distribution

---

*This architecture specification should be reviewed and updated as the application evolves.*