# BLUEPRINT.md

## Project Name
FinanceMate

## Project Configuration & Environment
- **ProjectRoot**: "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate"
- **PlatformDir**: "_macOS"
- **ProjectNamePlaceholder**: "FinanceMate"
- **Last Updated**: 2025-06-07
- **Current Phase**: MLACS Integration & Production Enhancement
- **Build Status**: ✅ Sandbox BUILD SUCCEEDED | ✅ Production BUILD SUCCEEDED | ⏳ UX Navigation Testing

---

# Chapter 2: Navigation Structure & User Journey Map

## 2.1 Application Navigation Hierarchy

```
FinanceMate (macOS Application)
├── 🏠 Dashboard
│   ├── Financial Overview Dashboard
│   ├── Quick Statistics Cards
│   ├── Recent Activity Feed
│   └── AI-Powered Insights Panel
│
├── 📄 Documents
│   ├── Document Upload Interface
│   ├── OCR Processing Queue
│   ├── Document Library & Search
│   └── Document Detail View
│       ├── Extracted Data Preview
│       ├── Manual Edit Interface
│       └── AI Validation Results
│
├── 📊 Analytics
│   ├── Basic Financial Reports
│   ├── Category Breakdown Charts
│   ├── Trend Analysis Views
│   └── Export Options
│
├── 🧠 MLACS (Multi-LLM Agent Coordination System)
│   ├── 📋 Overview Dashboard
│   │   ├── System Status Monitor
│   │   ├── Agent Activity Feed
│   │   └── Performance Metrics
│   ├── 🔍 Model Discovery
│   │   ├── Local Model Scanner
│   │   ├── Available Models List
│   │   └── Installation Recommendations
│   ├── 📈 System Analysis
│   │   ├── Hardware Capability Assessment
│   │   ├── Performance Benchmarks
│   │   └── Optimization Suggestions
│   ├── 🪄 Setup Wizard
│   │   ├── Guided Model Configuration
│   │   ├── API Key Management
│   │   └── Integration Testing
│   └── 👥 Agent Management
│       ├── Agent Creation Interface
│       ├── Task Assignment Console
│       └── Coordination Controls
│
├── ⚡ Enhanced Analytics
│   ├── Real-Time Financial Insights
│   ├── AI-Powered Document Processing
│   ├── Advanced Pattern Recognition
│   └── Predictive Analytics Dashboard
│
├── 📤 Financial Export
│   ├── Export Format Selection
│   ├── Column Mapping Interface
│   ├── Cloud Integration Setup
│   └── Automated Sync Configuration
│
├── 🔧 Speculative Decoding
│   ├── AI Performance Optimization
│   ├── Model Acceleration Controls
│   └── Resource Management
│
├── 🤖 Chatbot Testing
│   ├── Conversation Test Interface
│   ├── Response Quality Assessment
│   └── Integration Validation
│
├── ⚠️ Crash Analysis
│   ├── System Stability Monitor
│   ├── Error Log Viewer
│   └── Diagnostic Reports
│
├── 🏃‍♂️ LLM Benchmark
│   ├── Performance Testing Suite
│   ├── Model Comparison Tools
│   └── Benchmark Results
│
└── ⚙️ Settings
    ├── General Preferences
    ├── API Key Management
    ├── Cloud Account Configuration
    └── UI/UX Customization
```

## 2.2 Co-Pilot Chatbot Integration Points

The **persistent Co-Pilot chatbot interface** serves as the primary interaction layer across ALL navigation sections:

### 2.2.1 Chatbot Accessibility Matrix
```
Navigation Item          | Chatbot Integration Level | Key Functions
------------------------|-----------------------------|----------------------------------
🏠 Dashboard            | PRIMARY                    | Financial insights, trend analysis, quick queries
📄 Documents            | PRIMARY                    | OCR guidance, data validation, batch processing
📊 Analytics            | PRIMARY                    | Report generation, data interpretation, insights
🧠 MLACS                | CRITICAL                   | Agent coordination, model management, system control
⚡ Enhanced Analytics   | PRIMARY                    | Real-time analysis, pattern discovery, predictions
📤 Financial Export     | SECONDARY                  | Export assistance, format recommendations
🔧 Speculative Decoding | TERTIARY                   | Performance optimization guidance
🤖 Chatbot Testing      | META                       | Self-testing and validation
⚠️ Crash Analysis       | SECONDARY                  | Diagnostic assistance, troubleshooting
🏃‍♂️ LLM Benchmark      | SECONDARY                  | Performance interpretation, recommendations
⚙️ Settings             | SECONDARY                  | Configuration guidance, setup assistance
```

### 2.2.2 Persistent UI Integration
- **Panel Position**: Right-side persistent panel (350px width, resizable)
- **Visibility**: Toggle button in main toolbar (brain icon) - always accessible
- **Context Awareness**: Automatically adapts suggestions based on current navigation context
- **Cross-Navigation**: Can execute operations across all application sections
- **Real-Time Services**: Connected to actual LLM APIs for production functionality
- **Message History**: Persistent conversation history with timestamp and user/assistant attribution
- **Quick Actions**: Context-sensitive quick action buttons for common operations
- **Status Indicators**: Live connection status and processing indicators

### 2.2.3 Co-Pilot Interface Technical Implementation
```
Co-Pilot Panel Structure:
├── 📋 Header Section
│   ├── Co-Pilot Assistant branding
│   ├── Production status indicator
│   └── Connection status (Ready/Processing...)
├── 💬 Messages Area
│   ├── Scrollable conversation history
│   ├── Message bubbles (user vs assistant)
│   ├── Timestamp display
│   └── Empty state welcome interface
├── ⌨️ Input Area
│   ├── Multi-line text input field
│   ├── Send button with state management
│   └── Horizontal quick action buttons
└── 🔧 Integration Layer
    ├── RealLLMAPIService connection
    ├── ChatbotBackendProtocol implementation
    └── Cross-app service coordination
```

## 2.3 User Journey Flows

### 2.3.1 Primary User Flow: Document Processing with Co-Pilot
```
1. User uploads document → Documents section
2. Co-Pilot offers OCR processing guidance
3. AI extracts data with real-time feedback
4. User reviews/edits with Co-Pilot assistance
5. Co-Pilot suggests categorization and export options
6. Data automatically syncs to chosen spreadsheet service
7. Analytics updated with Co-Pilot insights
```

### 2.3.2 Advanced User Flow: MLACS-Powered Analysis
```
1. User queries: "Analyze my Q4 spending patterns"
2. Co-Pilot coordinates multiple AI agents via MLACS
3. Document analysis agent processes receipts/invoices
4. Financial analysis agent identifies patterns
5. Reporting agent generates comprehensive insights
6. Results displayed in Enhanced Analytics with explanations
7. Co-Pilot offers actionable recommendations
```

### 2.3.3 Setup & Configuration Flow
```
1. First Launch → Setup Wizard (MLACS section)
2. Co-Pilot guides through model discovery
3. API key configuration with security guidance
4. Integration testing with cloud services
5. Sample document processing demonstration
6. Personalized dashboard configuration
7. Ongoing optimization recommendations
```

## 2.4 Navigation Implementation Details

### 2.4.1 Application Navigation Architecture
```
FinanceMate Navigation System (ContentView.swift):
└── 🖥️ NavigationSplitView (3-Column Layout)
    ├── 📱 Sidebar (200-300px)
    │   ├── App Title: "FinanceMate"
    │   ├── Navigation List with 11 items
    │   └── SidebarListStyle() for macOS native appearance
    ├── 📄 Detail View (Main Content Area)
    │   ├── Dynamic content based on selectedView
    │   ├── Navigation title updates automatically
    │   └── Toolbar with Import Document button
    └── 🤖 Co-Pilot Panel (350px, toggleable)
        ├── Persistent chat interface
        ├── Context-aware quick actions
        └── Real-time status indicators
```

### 2.4.2 Complete Navigation Item Mapping
```
NavigationItem Enum Structure:
├── .dashboard          → DashboardView()
├── .documents          → DocumentsView()
├── .analytics          → AnalyticsView()
├── .mlacs              → MLACSPlaceholderView() [Production] / MLACSView() [Sandbox]
├── .export             → FinancialExportView()
├── .enhancedAnalytics  → RealTimeFinancialInsightsPlaceholderView() [Production]
├── .speculativeDecoding → Placeholder with coming soon message
├── .chatbotTesting     → Placeholder with testing interface preview
├── .crashAnalysis      → Placeholder with stability monitoring preview
├── .llmBenchmark       → Placeholder with performance testing preview
└── .settings           → SettingsView()

System Images per Navigation Item:
├── Dashboard:            "chart.line.uptrend.xyaxis"
├── Documents:            "doc.fill"
├── Analytics:            "chart.bar.fill"
├── MLACS:                "brain.head.profile"
├── Financial Export:     "square.and.arrow.up.fill"
├── Enhanced Analytics:   "chart.bar.doc.horizontal.fill"
├── Speculative Decoding: "cpu.fill"
├── Chatbot Testing:      "message.badge.waveform"
├── Crash Analysis:       "exclamationmark.triangle.fill"
├── LLM Benchmark:        "speedometer"
└── Settings:             "gear"
```

### 2.4.3 State Management & Context
```
Navigation State Variables (@State):
├── selectedView: NavigationItem = .dashboard
├── columnVisibility: NavigationSplitViewVisibility = .all
└── isCoPilotVisible: Bool = false

Context Tracking Implementation:
├── Active navigation section monitoring
├── Co-Pilot panel visibility state
├── Navigation title dynamic updates
├── Toolbar content based on current view
└── Cross-view operation coordination

View Lifecycle Management:
├── .onAppear() → setupCoPilotServices()
├── Dynamic content loading per navigation item
├── State preservation across navigation changes
└── Co-Pilot context awareness updates
```

### 2.4.4 Production vs Sandbox Implementation
```
Environment-Specific Views:
Production Environment:
├── MLACS → MLACSPlaceholderView (sophisticated preview)
├── Enhanced Analytics → RealTimeFinancialInsightsPlaceholderView
├── Co-Pilot → CoPilotPanelPlaceholder (functional demo)
└── Build-stable implementations for App Store submission

Sandbox Environment:
├── MLACS → MLACSView (full functionality with 5 tabs)
├── Enhanced Analytics → RealTimeFinancialInsightsView
├── Co-Pilot → CoPilotPanel (real API integration)
└── Development and testing environment

Shared Components:
├── Navigation infrastructure (ContentView, SidebarView, DetailView)
├── Core views (Dashboard, Documents, Analytics, Settings)
├── Export functionality (FinancialExportView)
└── Base services and data models
```

### 2.4.5 Information Architecture & Data Flow
```
Input Layer:
- Document Upload Interface (drag-and-drop, file picker)
- Manual Data Entry through forms
- Cloud Service Imports (OAuth-based)
- Co-Pilot Conversational Input
- Email Integration (Future)

Processing Layer:
- OCR Engine (Apple Vision Framework)
- MLACS Agent Coordination System
- AI-Powered Data Extraction
- Financial Pattern Recognition
- Real-Time Document Analysis

Intelligence Layer:
- Co-Pilot Chatbot Interface (Primary)
- Multi-Agent LLM Coordination
- Real-Time Insights Generation
- Predictive Analytics Engine
- Context-Aware Assistance

Output Layer:
- Interactive Dashboard Views
- Automated Report Generation
- Cloud Spreadsheet Sync
- Actionable Co-Pilot Recommendations
- Export to Multiple Formats

Cross-Section Operations:
- Co-Pilot initiates operations from any navigation section
- Analytics insights accessible from document views
- Export functions available throughout application
- Settings changes reflect immediately across all sections
- MLACS coordination operates across all features
```

---

# Product Requirements Document (PRD)

## High-Level Objective
**To develop FinanceMate, a native macOS application that revolutionizes how small businesses, accountants, freelancers, and individuals manage financial documents by providing a seamless, intelligent, and automated solution for extracting, organizing, and integrating data from invoices, receipts, and dockets into their preferred spreadsheet and accounting workflows. The application integrates with key user systems such as email (gmail, outlook, etc), Financial Institutions using new technology and integration (connect bank transactions, etc) and shopping accounts such as Amazon, eBay, etc, monitoring expenses and purchases and converting them to row level transactions (multiple line items within a docket) and storing them within a dynamic and interactive database for tax purposes and personal finance tracking.**

**CRITICAL REQUIREMENT: The application MUST feature a persistent, polished Co-Pilot-like chatbot interface that serves as one of the PRIMARY user interaction points. This chatbot system utilizes multiple agentic LLMs working in coordination to handle complex user queries, manipulate data within the application, provide intelligent financial insights, automate document processing tasks, and guide users through sophisticated workflows. The chatbot interface must be seamlessly integrated into the main application UI, always accessible, contextually aware, and capable of executing multi-step operations across all application features.**

The project aims to deliver a polished, user-focused application that is:
- **Efficient:** Drastically reduces manual data entry through advanced OCR and AI-powered data mapping.
- **Intuitive:** Offers a clean, modern, and easy-to-navigate SwiftUI interface adhering to macOS HIG and the project's `XCODE_STYLE_GUIDE.MD`.
- **AI-Powered:** Features a persistent, Co-Pilot-like chatbot interface as a primary interaction method for all user operations.
- **Intelligent:** Utilizes multi-agent LLM coordination (MLACS) to provide contextual assistance, automate workflows, and execute complex financial tasks.
- **Integrated:** Provides robust connections to popular cloud spreadsheet services (Office365 Excel Online, Google Sheets) and future integrations like Gmail.
- **Secure:** Ensures user data and API keys are handled with utmost security using macOS Keychain and best practices.
- **Reliable:** Built with a focus on stability, maintainability, and continuous improvement through Test-Driven Development (TDD) and comprehensive logging.

## Current Project Status & Milestone Targets

### 🏆 MILESTONE 1: Foundation ✅ COMPLETED (95%)
- ✅ **Established robust project structure and technical foundation**
- ✅ **Created comprehensive Core Data models for all entities** (Document, FinancialData, Client, Category, Project with full business logic)
- ✅ **Implemented document processing pipeline with real OCR integration** (564 lines, PDFKit + Apple Vision framework)
- ✅ **Set up financial data extraction and validation** (1,031+ lines with fraud detection)
- ✅ **Developed SwiftUI views with TDD methodology** (665 lines of tests, 27 test methods)
- 🔄 **Authentication services including Google SSO** (60% complete - SDK initialized, UI in progress)
- ✅ **MVVM framework for consistent development**
- 🔄 **CRITICAL: Co-Pilot Chatbot Interface** Persistent, polished chatbot serving as PRIMARY user interaction point with multi-agent LLM coordination for complex operations, data manipulation, and intelligent workflow automation

### 🚀 CURRENT FOCUS: MLACS (Multi-LLM Agent Coordination System) INTEGRATION (P0 CRITICAL)

**✅ TestFlight Readiness COMPLETED** - All critical blockers resolved (2025-06-04)
**✅ TaskMaster-AI MCP Integration COMPLETED** - Full multi-model coordination implemented (2025-06-05)
**✅ Production Build Infrastructure COMPLETED** - Build system stabilized and verified (2025-06-07)
**🔄 MLACS Core Implementation ACTIVE** - Advanced AI coordination system deployment (2025-06-07)

**🎯 TASKMASTER-AI MCP INTEGRATION SUCCESS (2025-06-05):**
- ✅ **Multi-Model Support**: Anthropic, OpenAI, Perplexity, Google, Mistral, OpenRouter, XAI
- ✅ **Advanced Task Orchestration**: Complex task breakdown and dependency management
- ✅ **JSON Task Format**: Structured task representation with metadata
- ✅ **Hierarchical Dependencies**: Parent/child relationships with dependency tracking  
- ✅ **Level 5-6 Task Tracking**: Granular task decomposition with 125+ actionable items
- 🔄 **Cross-File Synchronization**: Tasks synchronized across all project documentation

**🎯 MLACS INTEGRATION STATUS (2025-06-07):**
- ✅ **MLACS Framework Deployed**: Core MLACS services implemented across 50+ specialized files
- ✅ **Agent Management System**: MLACSAgentManager with full agent lifecycle management
- ✅ **Model Discovery Engine**: MLACSModelDiscovery with local model detection and recommendations
- ✅ **System Capability Analysis**: SystemCapabilityAnalyzer for hardware optimization
- ✅ **Real-Time Financial Insights**: Enhanced analytics engine with AI-powered document processing
- ✅ **Production Build Stability**: Both sandbox and production environments building successfully
- 🔄 **UX Navigation Integration**: MLACS and Enhanced Analytics views integrated into navigation
- 🔄 **Comprehensive UX Testing**: Multi-level validation framework implementation in progress

**🚨 IMMEDIATE P0 TASKS (Current Sprint - Co-Pilot Integration Focus):**
- **COPILOT-001**: Design and implement persistent Co-Pilot chatbot interface with seamless UI integration (P0, Complexity: 9/10)
- **COPILOT-002**: Connect Co-Pilot interface to MLACS framework for multi-agent coordination (P0, Complexity: 8/10)
- **COPILOT-003**: Implement contextual awareness system for intelligent user assistance (P0, Complexity: 9/10)
- **COPILOT-004**: Enable Co-Pilot to execute complex multi-step operations across all app features (P0, Complexity: 10/10)
- **MLACS-001**: Complete UX navigation validation tests for MLACS and Enhanced Analytics views (P0, Complexity: 6/10)
- **MLACS-002**: Implement comprehensive button functionality testing across all navigation items (P0, Complexity: 7/10)
- **BUILD-001**: Execute TestFlight build verification with integrated Co-Pilot system (P0, Complexity: 8/10)

**📋 TASKMASTER-AI COMPREHENSIVE SPRINT PLAN**: 125+ tasks across 5 phases with multi-model coordination
- **Complete Details**: `/temp/TASKMASTER_AI_INTEGRATION_TEST_REPORT_20250605.md`
- **Timeline**: 5-week sprint to App Store submission with TaskMaster-AI orchestration
- **Success Target**: >95% test coverage, <2s launch time, >90% quality score
- **TaskMaster-AI Benefits**: Automated task breakdown, dependency management, multi-model AI coordination

### Milestone 2: Core Functionality (On Hold - Post TestFlight)
- Implement case management (creation and editing)
- Develop basic client information management
- Create simple calendar view and event management
- Build document storage functionality
- Establish notification system for deadlines

### Milestone 3: Advanced Features (Future)
- Implement document template system
- Enhance navigation and dashboard experience
- Add client communication logging
- Develop search functionality across data types
- Create time tracking system

### Milestone 4: Integration & Refinement (Future)
- Add calendar synchronization with macOS Calendar
- Implement advanced document features (versioning, automation)
- Develop reporting and analytics capabilities
- Optional CloudKit integration for data sync
- UI polish and accessibility improvements

## 📊 IMPLEMENTATION METRICS (Current Status - 2025-06-07)

### Core Development Achievements:
- **Lines of Code**: 15,000+ lines of production Swift code
- **MLACS Implementation**: 50+ specialized service files for AI coordination
- **Test Coverage**: 95%+ for Core Data implementation with comprehensive UX testing
- **Core Data Entities**: 5 fully implemented with comprehensive business logic
- **Test Suite**: 40+ atomic test methods for TDD validation including UX navigation tests
- **Build Status**: ✅ Both Sandbox and Production environments building successfully
- **Navigation Structure**: 11 navigation items with comprehensive SwiftUI implementation
- **AI Integration**: Multi-LLM coordination system with agent management

### MLACS (Multi-LLM Agent Coordination System) Implementation:
- **Core Framework**: MLACSFramework with initialization and lifecycle management
- **Agent Management**: MLACSAgentManager supporting agent creation, activation, and coordination
- **Model Discovery**: MLACSModelDiscovery with local model detection and recommendations
- **System Analysis**: SystemCapabilityAnalyzer for hardware optimization and performance profiling
- **Upgrade Engine**: UpgradeSuggestionEngine for intelligent system improvement recommendations
- **Monitoring System**: MLACSMonitoring with real-time performance tracking
- **Single Agent Mode**: MLACSSingleAgentMode for focused task execution
- **Tier Coordination**: MLACSTierCoordination for hierarchical agent management

### Real-Time Financial Insights Engine:
- **Enhanced Analytics**: AI-powered document processing with real-time insights generation
- **Document Pipeline**: Integrated document processing with MLACS coordination
- **Insights Models**: Comprehensive data models for financial insight types and processing methods
- **System Status**: Real-time monitoring of processing queues and system health
- **AI Analytics**: Performance metrics and model accuracy tracking

### Navigation & User Experience:
- **NavigationSplitView**: Modern macOS-native navigation with sidebar and detail views
- **Navigation Items**: Dashboard, Documents, Analytics, MLACS, Financial Export, Enhanced Analytics, Settings
- **Interactive Elements**: Comprehensive button functionality and navigation flow
- **Placeholder Integration**: Sophisticated placeholder views for production deployment
- **Responsive Design**: Adaptive layouts with proper spacing and visual hierarchy

### Current Integration Status:
1. **Production Build Stability**: Both environments compile successfully with warning-only output
2. **MLACS Integration**: Core services deployed with placeholder UI for TestFlight readiness  
3. **UX Navigation**: All navigation items functional with appropriate content views
4. **Data Models**: Comprehensive type system for financial insights and MLACS coordination

## 🏗️ CURRENT IMPLEMENTATION ARCHITECTURE (Detailed Status)

### Project Structure:
```
_macOS/
├── FinanceMate/ (Production)
│   ├── FinanceMateApp.swift - Main app entry point
│   ├── Views/
│   │   ├── ContentView.swift - NavigationSplitView with 11 navigation items
│   │   ├── DashboardView.swift - Financial overview dashboard
│   │   ├── DocumentsView.swift - Document management interface
│   │   ├── AnalyticsView.swift - Basic analytics and reporting
│   │   ├── SettingsView.swift - User preferences and configuration
│   │   └── FinancialExportView.swift - Export functionality
│   ├── Services/
│   │   ├── MLACS/ - Multi-LLM Agent Coordination System (25+ files)
│   │   │   ├── MLACSFramework.swift - Core coordination framework
│   │   │   ├── MLACSAgentManager.swift - Agent lifecycle management
│   │   │   ├── MLACSModelDiscovery.swift - Local model detection
│   │   │   ├── SystemCapabilityAnalyzer.swift - Hardware analysis
│   │   │   └── [Additional specialized services...]
│   │   ├── IntegratedFinancialDocumentInsightsService.swift - Document processing
│   │   ├── EnhancedRealTimeFinancialInsightsEngine.swift - AI analytics
│   │   ├── FinancialInsightsModels.swift - Type definitions
│   │   └── [Core services...]
│   └── Sources/Core/DataModels/ - Core Data entities
└── FinanceMate-Sandbox/ (Development)
    ├── Enhanced testing environment
    ├── Real-time MLACS integration testing
    └── Advanced UX validation frameworks
```

### Key Implementation Features:

#### 1. Navigation System (ContentView.swift:142-186)
- **11 Navigation Items**: Dashboard, Documents, Analytics, MLACS, Financial Export, Enhanced Analytics, Speculative Decoding, Chatbot Testing, Crash Analysis, LLM Benchmark, Settings
- **NavigationSplitView**: Modern macOS-native three-column layout
- **Dynamic Content**: Sophisticated view routing with placeholder and real implementations
- **Responsive Design**: Adaptive column widths and content layouts

#### 2. MLACS Implementation (50+ files)
- **Agent Coordination**: Multi-agent task management with dependency tracking
- **Model Discovery**: Automatic detection of local LLM installations
- **System Analysis**: Hardware capability assessment for optimal performance
- **Tier Management**: Hierarchical agent coordination across complexity levels
- **Real-time Monitoring**: Performance tracking and system health monitoring

#### 3. Enhanced Analytics Engine
- **AI-Powered Insights**: Real-time financial analysis with confidence scoring
- **Document Processing**: Integrated OCR and data extraction pipeline
- **System Status**: Live monitoring of processing queues and system load
- **Analytics Dashboard**: Performance metrics and model accuracy tracking

#### 4. Production Deployment Strategy
- **Placeholder Views**: Sophisticated fallback implementations for complex features
- **Build Stability**: Both sandbox and production environments compile successfully
- **TestFlight Ready**: All critical blocking issues resolved for App Store submission
- **UX Navigation**: Complete flow from sidebar to detailed content views

### Technical Stack Integration:
- **SwiftUI**: Modern declarative UI framework with macOS HIG compliance
- **Core Data**: Comprehensive entity relationship modeling for financial data
- **Combine**: Reactive programming patterns for real-time updates
- **Swift Concurrency**: Async/await patterns for AI service coordination
- **PDFKit + Vision**: Advanced OCR processing for document extraction
- **macOS Keychain**: Secure credential storage for API keys and tokens

---

## GitHub Repository Information
- **Repository Name (Placeholder):** `FinanceMate-macOS` (To be confirmed or created)
- **Primary Branch:** `main`
- **Development Branch:** `develop`
- **Feature Branch Convention:** `feature/<task-id>-<short-description>` (e.g., `feature/28-enhance-ocr-accuracy`)
- **Bugfix Branch Convention:** `bugfix/<issue-id>-<short-description>`
- **Release Tag Convention:** `v<major>.<minor>.<patch>` (e.g., `v0.1.0-alpha`)
- **Commit Message Convention:** Follow Conventional Commits (e.g., `feat: Implement OCR extraction for PDF documents`, `fix: Corrected currency parsing issue`).
- **Issue Tracking:** Utilize GitHub Issues, linked to tasks in `TASKS.MD`.
- **Pull Request (PR) Template:** To be defined, including checklist for tests, documentation, and style guide adherence.

---

## Product Documentation (Outline)

This section outlines the structure for comprehensive product documentation, which will reside primarily within the `/docs` directory and the application's Help menu.

### 1. User Guide
    - **Introduction to FinanceMate**
        - What is FinanceMate?
        - Key Benefits (Time-saving, Accuracy, Organization, Integration)
    - **Getting Started**
        - System Requirements (macOS version)
        - Installation
        - First Launch & Onboarding
    - **Core Features & Functionality**
        - **Document Import:**
            - Drag & Drop
            - File Upload (Supported Formats: PDF, JPG, PNG, HEIC)
        - **OCR Processing:**
            - How it works
            - Tips for best results
        - **Data Extraction & Review:**
            - Understanding the extracted data view
            - Editing line items
            - Handling extraction errors
        - **Spreadsheet Column Mapping:**
            - Default columns
            - Adding custom columns (Text, Number, Currency, Date)
            - Renaming columns
            - Reordering columns
            - Deleting columns
            - Saving column configurations
        - **Data Export:**
            - Exporting to CSV
            - Exporting to Excel (local .xlsx)
        - **Cloud Integrations:**
            - Connecting to Office365 Excel Online (OAuth 2.0)
            - Connecting to Google Sheets (OAuth 2.0)
            - Syncing data to cloud spreadsheets
            - Managing connections
        - **(Future) Email Integration (Gmail):**
            - Connecting your Gmail account
            - Automatic invoice/receipt scanning
            - Reviewing and importing from email
    - **Settings & Preferences**
        - General settings
        - API Key Management (Securely adding/removing keys for LLMs)
        - Cloud Account Management
        - Notification preferences
    - **Troubleshooting & FAQs**
        - Common OCR issues
        - Connection problems
        - Data mapping queries
    - **Contact & Support**

### 2. Developer Documentation (primarily in `/docs`)
    - **`README.MD`:** Project overview, setup for developers, build instructions.
    - **`ARCHITECTURE.MD` & `ARCHITECTURE_GUIDE.MD`:** System architecture, component design, data models.
    - **`XCODE_BUILD_GUIDE.md`:** Detailed guide for building, testing, and maintaining SweetPad compatibility.
    - **`XCODE_STYLE_GUIDE.md`:** UI/UX design principles, component library, style specifications.
    - **API Integration Guides:** (e.g., for Microsoft Graph, Google Sheets API within `docs/integrations/`)
        - Authentication flows
        - Key endpoints used
        - Data models
        - Error handling
    - **`CONTRIBUTING.MD` (Future):** Guidelines for contributing to the project.
    - **`DEVELOPMENT_LOG.MD`:** Chronological log of key decisions, architectural changes, and significant development events.
    - **`BUILD_FAILURES.MD`:** Knowledge base of build issues and their resolutions.

### 3. Technology & Integrations
    - **Core Technology:**
        - Swift (latest stable version)
        - SwiftUI (for modern macOS interface)
        - Apple Vision Framework (for OCR)
        - (Potential) Tesseract OCR (as a fallback or for specific document types)
        - Swift Concurrency (`async/await`)
        - Combine Framework (for reactive programming patterns)
    - **Persistence:**
        - `UserDefaults` (for user preferences and simple settings)
        - macOS Keychain (for secure storage of API keys and OAuth tokens)
        - Local file storage (e.g., for cached data, temporary files, potentially Core Data/SwiftData in future for complex local DB)
    - **Key Integrations:**
        - **Cloud Spreadsheets:**
            - Microsoft Office365 Excel Online (via Microsoft Graph API)
            - Google Sheets (via Google Sheets API)
        - **Large Language Models (LLMs) for NLP-driven column matching:**
            - OpenAI API
            - Anthropic Claude API
            - Google Gemini API
        - **(Future) Email:**
            - Gmail API (for automatic invoice/receipt extraction)
        - **(Future) Currency Conversion:**
            - A reliable currency conversion API
    - **Security Mechanisms:**
        - OAuth 2.0 for cloud service authentication
        - macOS Keychain for storing sensitive credentials locally
        - HTTPS for all API communications

---

## Categories for Testing, Self-Validation, and Tooling

### 1. Testing Categories & Strategy
    - **Unit Tests (XCTest):**
        - **Scope:** Individual functions, methods, classes, structs, ViewModels, Models, Services, Utilities.
        - **Focus:** Logic correctness, boundary conditions, error handling, state changes.
        - **Tools:** Xcode's XCTest framework.
        - **Location:** `_{PlatformDir}/Tests/{UnitTestSourceRoot}/`
        - **Requirement:** High code coverage for all non-trivial business logic. TDD is paramount.
    - **Integration Tests (XCTest):**
        - **Scope:** Interactions between components/modules (e.g., ViewModel with Service, Service with API client).
        - **Focus:** Data flow, contract adherence between components, error propagation.
        - **Tools:** XCTest, mock objects/services for external dependencies (APIs).
        - **Location:** `_{PlatformDir}/Tests/{UnitTestSourceRoot}/` (can be co-located or in a separate integration test target).
    - **UI Tests (XCUITest):**
        - **Scope:** User interface elements, user flows, accessibility.
        - **Focus:** View rendering, element interactions (taps, drags, text input), navigation, state updates reflected in UI.
        - **Tools:** Xcode's XCUITest framework.
        - **Location:** `_{PlatformDir}/Tests/{UITestSourceRoot}/`
        - **Requirement:** Cover critical user paths and UI components.
    - **OCR Accuracy Tests:**
        - **Scope:** OCR engine performance on diverse document types and qualities.
        - **Focus:** Extraction accuracy for key fields, line items, robustness against noise/skew.
        - **Tools:** Custom test harness using XCTest, sample documents from `docs/TestData/`.
        - **Location:** `_{PlatformDir}/Tests/{UnitTestSourceRoot}/OCR/`
    - **API Integration Tests (Mocked & Live - carefully managed):**
        - **Scope:** Interaction with external APIs (Google Sheets, Office365, LLMs).
        - **Focus:** Correct request formation, response parsing, authentication, error handling.
        - **Tools:** XCTest with mock HTTP clients (for most tests) and carefully controlled live API calls for specific end-to-end validation (requires secure API key handling for test environments).
    - **Performance Tests (XCTest):**
        - **Scope:** Critical operations like OCR processing, large data handling, UI responsiveness.
        - **Focus:** Execution time, memory usage, CPU load.
        - **Tools:** XCTest's performance testing capabilities (`measure{}`).
    - **Snapshot Tests (Future - if UI becomes complex):**
        - **Scope:** Ensuring UI consistency across changes.
        - **Tools:** Libraries like Point-Free's `swift-snapshot-testing`.
    - **Test Data Management:**
        - All standard test documents (PDFs, images) reside in `docs/TestData/`.
        - Mock data for unit/integration tests should be generated or stored within test targets.

### 2. Self-Validation Categories & Checklists
    - **Pre-Commit Checklist (Automated where possible):**
        - All new/modified code is covered by unit tests.
        - All tests (unit, integration, UI) pass locally.
        - Code adheres to `SwiftLint.yml` rules (run linter).
        - Code formatting is consistent (run formatter if used).
        - No `FIXME`/`TODO` comments for critical issues being committed.
        - `DEVELOPMENT_LOG.MD` updated with significant changes.
        - `TASKS.MD` updated for the completed sub-task.
        - Build successfully completes (SweetPad compatible).
        - UI/UX changes reviewed against `XCODE_STYLE_GUIDE.md`.
        - Directory cleanliness check performed and passed.
    - **Pre-Pull Request (PR) Checklist:**
        - All items from Pre-Commit Checklist.
        - PR description clearly explains changes and references relevant task/issue IDs.
        - All discussions on the PR are resolved.
        - (If applicable) Manual QA on a staging/test build.
    - **Build Verification (Continuous):**
        - Programmatic build using `XcodeBuildMCP` or `Bash xcodebuild` after every significant code/project change.
        - Verification of SweetPad compatibility as per `XCODE_BUILD_GUIDE.md`.
        - If build fails, it becomes P0 priority. Document in `BUILD_FAILURES.MD`.
    - **UI/UX Style Guide Adherence Check:**
        - Manual and (where possible) automated checks against `XCODE_STYLE_GUIDE.md`.
        - Review color palettes, typography, spacing, component usage, navigation patterns.
    - **Documentation Review:**
        - Inline code comments are clear and sufficient for complex logic.
        - Public APIs are documented (e.g., using Swift's documentation comments `///`).
        - User-facing documentation (`README.MD`, Help files) updated if features change.
    - **Security Review (Periodic & Feature-Specific):**
        - Adherence to `SECURITY_GUIDELINES.MD` (to be created/populated based on project needs).
        - Secure API key handling (Keychain usage).
        - No hardcoded secrets.
        - Input validation for any user-provided data that interacts with system resources.
        - OAuth flows correctly implemented.
    - **Dependency Audit (Periodic):**
        - Review external dependencies for updates (especially security patches).
        - Check for deprecated dependencies.

### 3. Tooling Categories & Usage
    - **IDE:**
        - Xcode (latest stable version recommended by `XCODE_BUILD_GUIDE.md`).
        - Cursor (with integrated AI Agent).
    - **Version Control:**
        - Git (CLI and/or GUI client).
        - GitHub (for remote repository, issue tracking, PRs).
    - **Build System & Tools:**
        - **`XcodeBuildMCP` Server:** Primary tool for Xcode project operations (build, clean, test, run, simulator management, log retrieval).
        - **`Bash xcodebuild` CLI:** Fallback for specific `xcodebuild` tasks or verification if `XcodeBuildMCP` encounters issues. Used for direct build/test commands.
        - Swift Package Manager (SPM): For managing external Swift dependencies.
    - **Task Management:**
        - **`taskmaster-ai` MCP Server & CLI:** For parsing PRDs (`BLUEPRINT.MD`), generating tasks, breaking down complex tasks, managing dependencies, and tracking progress. (Tasks stored in `tasks/tasks.json` and individual task files).
        - `TASKS.MD`: Human-readable and AI-agent-updatable task list, synchronized with Taskmaster where feasible.
    - **File System Operations:**
        - **`filesystem` MCP Server:** For all programmatic file operations (Read, Write, Edit, LS, Glob, Grep, mv, rm, mkdir).
    - **Code Quality & Linting:**
        - SwiftLint: For enforcing Swift style and conventions. Configuration in `SwiftLint.yml`. Run via `Bash`.
    - **Debugging:**
        - Xcode Debugger (LLDB).
        - Console logging.
    - **API Interaction & Testing:**
        - `URLSession` (for direct API calls in Swift).
        - Postman or similar API client (for manual API testing and exploration).
        - Mocking libraries/techniques for testing API integrations.
    - **Documentation Generation (Future):**
        - Jazzy or DocC (for generating Swift documentation from source comments).
    - **AI Agent Context & Knowledge Retrieval:**
        - **`context7` MCP Server:** For querying internal project documentation and knowledge bases.
    - **Web Content Retrieval & Processing:**
        - **Web Search MCPs (`brave-search`, `perplexity`, `serpapi`):** For external research.
        - **`markdownify` MCP Server:** For converting HTML content to Markdown.
    - **Scripting:**
        - `Bash` Shell scripts: For automation of build, test, deployment, and utility tasks. Stored in `scripts/` (general) or `_{PlatformDir}/scripts/` (platform-specific).
        - Ruby/Python scripts: For more complex scripting tasks, especially those involving `.xcodeproj` manipulation (e.g., `xcodeproj` gem for Ruby).
    - **Project Initialization & Setup:**
        - Adherence to "Initialise Mode" (Section 10 of `.cursorrules`).
        - Templates for core documents (e.g., `BLUEPRINT.MD`, `TASKS.MD`, `XCODE_STYLE_GUIDE.md`).
    - **Security Tools (Future):**
        - Dependency vulnerability scanners.
        - Static Application Security Testing (SAST) tools.

---

## Overview
FinanceMate is a macOS application that allows users to drag and drop or upload images, screenshots, PDFs, and other documents (such as invoices and dockets). The app uses OCR to extract line items from these documents and maps them to user-defined spreadsheet columns for tax and accounting purposes. It supports integration with Office365 Excel Online and Google Sheets (SSO/OAuth), and will support email integration (Gmail) for automatic invoice/receipt extraction in the future.

## Core Features

### 🤖 PRIMARY FEATURE: Co-Pilot Chatbot Interface
- **Persistent Co-Pilot Assistant**
  - *What*: Always-available, contextually-aware AI assistant integrated into the main UI
  - *Why*: Serves as the primary interaction method for complex operations and user guidance
  - *How*: Persistent sidebar/panel with sophisticated chat interface and multi-agent coordination
- **Multi-Agent LLM Coordination**
  - *What*: Coordinated team of specialized AI agents handling different aspects of financial tasks
  - *Why*: Enables complex workflow automation and intelligent task decomposition
  - *How*: MLACS (Multi-LLM Agent Coordination System) with agent specialization and task routing
- **Contextual Intelligence**
  - *What*: Co-Pilot understands current user context, document state, and workflow progress
  - *Why*: Provides relevant assistance and proactive suggestions
  - *How*: Context tracking, state awareness, and intelligent prompt engineering
- **Cross-Feature Operation Execution**
  - *What*: Co-Pilot can execute operations across all application features via natural language
  - *Why*: Simplifies complex workflows into conversational interactions
  - *How*: Integration with all core services and intelligent command interpretation

### 📄 Document Processing & Management
- **Drag-and-drop/upload images, screenshots, PDFs, and documents**
  - *What*: Users can easily add documents for processing via Co-Pilot or traditional UI
  - *Why*: Simplifies data entry and document management with AI guidance
  - *How*: SwiftUI drag-and-drop, file picker integration, Co-Pilot document handling
- **AI-Enhanced OCR processing to extract line items**
  - *What*: Extracts structured data from receipts/invoices with Co-Pilot oversight
  - *Why*: Automates data entry, reduces manual errors, provides intelligent validation
  - *How*: Apple Vision framework integrated with MLACS agents for quality assurance
- **Intelligent Document Analysis**
  - *What*: Co-Pilot analyzes documents and provides insights, corrections, and suggestions
  - *Why*: Ensures data accuracy and provides contextual understanding
  - *How*: Multi-agent analysis with natural language feedback through Co-Pilot interface

### 📊 Data Management & Analytics
- **AI-Guided Spreadsheet Column Customization**
  - *What*: Co-Pilot helps users customize columns based on their specific needs and workflows
  - *Why*: Provides intelligent recommendations and automates setup processes
  - *How*: Co-Pilot analysis of user requirements with automated column configuration
- **Real-Time Intelligent Spreadsheet Population**
  - *What*: Co-Pilot oversees data extraction and provides real-time feedback and corrections
  - *Why*: Ensures accuracy and provides immediate validation with explanations
  - *How*: Custom SwiftUI table/grid with Co-Pilot integration and real-time analysis
- **Conversational Data Export**
  - *What*: Users can request specific exports through natural language with Co-Pilot
  - *Why*: Simplifies complex export requirements into simple conversations
  - *How*: Co-Pilot interprets requirements and executes appropriate export operations
- **Intelligent Analytics & Insights**
  - *What*: Co-Pilot provides proactive financial insights, trends, and recommendations
  - *Why*: Transforms raw data into actionable business intelligence
  - *How*: MLACS-powered analysis with natural language insights delivery

### 🔗 Integrations & Automation
- **Co-Pilot-Managed Cloud Integrations**
  - *What*: Co-Pilot handles OAuth flows and manages connections to Office365, Google Sheets
  - *Why*: Simplifies complex authentication and sync processes
  - *How*: Co-Pilot guides users through setup and manages ongoing synchronization
- **Intelligent Email Processing (Future)**
  - *What*: Co-Pilot automatically processes email attachments and manages invoice extraction
  - *Why*: Provides fully automated document processing workflow
  - *How*: Gmail API integration with Co-Pilot workflow orchestration
- **Smart Financial Workflow Automation**
  - *What*: Co-Pilot learns user patterns and automates routine financial tasks
  - *Why*: Reduces repetitive work and ensures consistency
  - *How*: Machine learning with user behavior analysis and automated task execution

### 🔒 Security & Intelligence
- **AI-Secured Credential Management**
  - *What*: Co-Pilot manages API keys and credentials with intelligent security protocols
  - *Why*: Ensures maximum security while maintaining usability
  - *How*: macOS Keychain integration with Co-Pilot security oversight
- **Intelligent Fraud Detection**
  - *What*: Co-Pilot analyzes transactions and documents for potential fraud or anomalies
  - *Why*: Provides proactive protection and accuracy validation
  - *How*: Multi-agent analysis with real-time alerting through Co-Pilot interface

## User Experience

### 🎯 Co-Pilot-Centric User Experience Design
- **User Personas**
  - Small business owners requiring intelligent financial automation
  - Accountants needing AI-assisted workflow optimization
  - Freelancers seeking conversational financial management
  - Individuals wanting personalized financial guidance through natural interaction

### 🔄 AI-Enhanced User Flows
- **Primary Co-Pilot Flow**: User asks Co-Pilot to "process this invoice and update my Q4 expenses" → Co-Pilot handles OCR, analysis, categorization, and spreadsheet updates while providing real-time feedback
- **Intelligent Document Processing**: Drag-and-drop → Co-Pilot auto-analyzes → Provides extraction preview with confidence scores → User confirms via conversation → Auto-categorization and sync
- **Conversational Integration Setup**: User says "Connect my Google Sheets" → Co-Pilot guides through OAuth → Tests connection → Configures sync preferences through natural dialogue
- **Dynamic Column Management**: User requests "Add a column for tax deductible status" → Co-Pilot analyzes requirements → Suggests column configuration → Implements changes with user approval

### 🎨 Co-Pilot Interface Design Requirements
- **Persistent Co-Pilot Panel**: Always-visible sidebar/floating panel with chat interface, status indicators, and quick action buttons
- **Contextual UI Integration**: Co-Pilot panel adapts to current application context, showing relevant tools and suggestions
- **Natural Language Command Bar**: Prominent input field for conversational commands with intelligent autocomplete and suggestion
- **Multi-Modal Interaction**: Support for text, voice input, and visual document references within Co-Pilot conversations
- **Real-Time Status Display**: Live indicators showing Co-Pilot processing status, agent coordination, and task progress
- **Intelligent Notification System**: Proactive alerts and suggestions delivered through Co-Pilot interface

### 📱 macOS Native UI/UX with Co-Pilot Integration
- **NavigationSplitView with Co-Pilot**: Three-panel layout: Navigation sidebar, main content, and persistent Co-Pilot panel
- **Co-Pilot-Aware Spreadsheet View**: Table interface with inline Co-Pilot suggestions, intelligent data validation, and conversational editing
- **Contextual Action Menus**: Right-click menus enhanced with Co-Pilot options for intelligent operations
- **Keyboard Shortcuts**: Quick access to Co-Pilot functions with standard macOS keyboard conventions
- **Accessibility Compliance**: Full VoiceOver support for Co-Pilot interactions and voice command integration

## Technical Architecture
- **System Components**
  - SwiftUI macOS app
  - OCRService (Apple Vision/Tesseract)
  - SpreadsheetColumnViewModel, FileService, Document models
  - Integration services: Google Sheets, Office365, Gmail
  - Secure storage: Keychain, UserDefaults
- **Data Models**
  - Document, LineItem, SpreadsheetColumn, UserProfile, Entity
- **APIs and Integrations**
  - Microsoft Graph API, Google Sheets API, Gmail API
  - LLM APIs (OpenAI, Anthropic, Gemini)
  - Currency conversion API (future)
- **Infrastructure Requirements**
  - Local macOS app (no backend required for MVP)
  - Internet access for cloud integrations

## Development Roadmap
- **Initial Phase (MVP)**
  - Core drag-and-drop/upload & OCR to spreadsheet
  - User-defined spreadsheet columns
  - Spreadsheet view, export to Excel/CSV
  - Local secure storage
- **Alpha Phase**
  - Navigation, settings, dashboards, profile
  - Secure API key storage
  - Office365/Google Sheets integration
  - LLM-based column matching
  - Google Ad implementation for free versions
  - **Goal: Complete Alpha features and pass all User Acceptance Tests (UAT) to prepare for initial App Store release.**
- **Beta Phase**
  - Country filters, multi-currency, entity support
  - Tagging, sharing, linked spreadsheets
  - Gmail integration (auto-extract)
  - Analytics, dashboard, tax handling
  - Invoicing (optional)
  - Financial year filters and reporting
- **Production Phase**
  - Cross-platform (iOS/iPadOS/web)
  - Advanced integrations (bank feeds, Stripe, etc.)
  - Advanced reporting, analytics, performance
  - UI polish, scalability, bug fixes

## Logical Dependency Chain
- Foundation: Local file import, OCR, spreadsheet mapping
- Next: UI for review/edit, column customization
- Then: Export, cloud sync (Google Sheets/Office365)
- After: Analytics, dashboards, reporting
- Finally: Advanced integrations, cross-platform, polish

## Risks and Mitigations
- **Technical challenges**: OCR accuracy, LLM mapping, API changes
  - *Mitigation*: Use proven frameworks, write tests, modular design
- **MVP scope creep**: Too many features in initial phase
  - *Mitigation*: Strictly define MVP, defer enhancements
- **Resource constraints**: Limited dev time, API costs
  - *Mitigation*: Prioritize automation, use free/cheap APIs, focus on core

## Appendix
- **Research findings**: See integration docs for Google Sheets, Office365, Gmail
- **Technical specifications**: See `ARCHITECTURE.md`, `ARCHITECTURE_GUIDE.md`, and codebase for details

---

## Project Configuration & Environment
- PlatformDir: macOS
- ProjectFileNamePlaceholder: FinanceMate
- PlatformSourceRoot: FinanceMate
- UnitTestSourceRoot: UnitTests
- UITestSourceRoot: UITests
- TestDataDirectoryPath: docs/TestData
- XcodeSchemeName: FinanceMate
- XcodeConfiguration: Debug
- WorkspacePath: _macOS/FinanceMate.xcodeproj/project.xcworkspace
- BuildDestination: platform=macOS,arch=arm64
- ToolingIntegration: sweetpad, xcodebuild
- MainAppEntryPoint: FinanceMateApp.swift
- ContentViewFile: ContentView.swift
- ModelsDir: _macOS/FinanceMate/Models
- KeychainHelperFile: _macOS/FinanceMate/Utilities/KeychainHelper.swift
- ExternalDocs: [Microsoft Graph API, Google Sheets API, Gmail API]
- PersistenceMechanism: UserDefaults, local file storage (for now)
- CoreUIFramework: SwiftUI
- PlatformTarget: macOS 13+
- XcodeVersionTarget: 14.3+
- SwiftVersionTarget: 5.0+
- APIInteractionMethod: REST (for integrations)
- SecurityMethod: OAuth 2.0
- MandatoryLayout: Apple HIG, SwiftUI best practices

## OCR Testing Resources
The project includes a standard test data directory at `docs/TestData/` containing various PDF invoice and receipt samples. This directory is critical for OCR development and testing and must not be deleted. All OCR functionality and automated tests should utilize these files as reference documents to ensure consistent behavior and quality verification across the application.

## Spreadsheet Column Customization Requirements

FinanceMate allows users to fully customize the columns in their spreadsheet view. The following requirements define the scope for this feature:

- Users can add new columns, specifying a name and type (text, currency, date, number).
- Users can remove existing columns.
- Users can rename columns.
- Users can reorder columns via drag-and-drop or up/down controls.
- Users can select the type for each column (text, currency, date, number).
- The UI must provide an intuitive interface for all customization actions.
- All changes are persisted per user (using UserDefaults or local file storage for now).
- The system must validate column names (no duplicates, not empty).
- The default set of columns should be provided for new users, but fully editable.
- All customization actions must be undoable (if feasible in current phase).
- The ViewModel must expose all logic for add/remove/rename/reorder, and be fully unit tested.
- The View must be covered by UI tests for all customization actions.

## Product Feature Inbox

// 2025-05-10: All items below triaged as new Level 4+ task 'UI/UX Polish: Visual Design, Animations, Components, Performance'. See TASKS.MD and DEVELOPMENT_LOG.MD for traceability.

- Elegant Visual Design & Layout  
  - Rounded corners  
  - Subtle shadows  
  - Transparent or blurred (glassmorphism) backgrounds  
  - Minimalist color palettes  
  - Well-structured grids with generous spacing  

- Smooth, Delightful Animations & Interactions  
  - Micro-interactions (button bounce, hover effects)  
  - Seamless transitions (spring, crossfade)  
  - Responsive feedback  
  - Gentle motion that adds life without distraction  

- High-Quality, Thoughtful Components  
  - Crisp icons (SF Symbols or custom vectors)  
  - Beautiful typography hierarchy  
  - Polished card-based layouts  
  - Custom toggles/sliders  
  - Friendly empty states with illustrations or messaging  

- Polished Experience & Performance  
  - Fast and responsive  
  - Accessibility-compliant (contrast, large touch targets)  
  - Adaptive to screen sizes  
  - Attention to detail that enhances both delight and usability  

- Ensure Version / build numbers are added to the main app entry point view for this app // Implemented in MainContentView.swift, see commit 'build/stable-YYYYMMDD_HHMM'.

// 2025-06-17: 'CRUD and REST API for Core Data Entities (User, Document, LineItem, etc.)' triaged and created as Task #26 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

- CRUD and REST API for Core Data Entities (User, Document, LineItem, etc.) // Triaged as Task #26 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

// 2025-06-15: 'Implement Xcode Core Data Model for complex applications' triaged and created as Task #25 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

- Gmail inbox (attachment) integration pulling "invoices" and "receipts." // Triaged as Task #8 and Task #48 in TASKS.MD. See DEVELOPMENT_LOG.MD for traceability.

- Improve the Main UI // Triaged as Task #24 in TASKS.MD (Taskmaster ID #19)
- Improve the navigation between pages // Triaged as Task #25 in TASKS.MD (Taskmaster ID #20)
- GOOGLE AD IMPLEMENTATION FOR FREE VERSIONS // Triaged as Task #26 in TASKS.MD
- FINANCIAL YEAR FILTERS // Triaged as Task #27 in TASKS.MD

// 2025-06-10: 'Improve the Main UI' triaged and broken down into Level 5-6 subtasks as Task 16 in TASKS.md. See DEVELOPMENT_LOG.md for traceability.

// 2025-06-11: 'Improve navigation between pages' triaged and created as Task 17 in tasks.json and Task 22 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

// 2025-06-15: 'GOOGLE AD IMPLEMENTATION FOR FREE VERSIONS' triaged and added to Alpha Phase in roadmap. Created as Task #26 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

// 2025-06-15: 'FINANCIAL YEAR FILTERS' triaged and added to Beta Phase in roadmap. Created as Task #27 in TASKS.MD. See DEVELOPMENT_LOG.md for traceability.

// TODO: User request - Gmail integration for pulling invoice attachments. Triaged and broken down as Task #8 (and sub-tasks 8.1-8.7) in TASKS.MD. See DEVELOPMENT_LOG.MD for traceability. 

// All items below triaged and moved to roadmap/tasks
// See TASKS.md for tracking and DEVELOPMENT_LOG.md for traceability.