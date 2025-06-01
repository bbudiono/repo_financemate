# BLUEPRINT.md

## Project Name
FinanceMate

## Project Configuration & Environment
- **ProjectRoot**: "/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_FinanceMate"
- **PlatformDir**: "_macOS"
- **ProjectNamePlaceholder**: "FinanceMate"

---

# Product Requirements Document (PRD)

## High-Level Objective
**To develop FinanceMate, a native macOS application that revolutionizes how small businesses, accountants, freelancers, and individuals manage financial documents by providing a seamless, intelligent, and automated solution for extracting, organizing, and integrating data from invoices, receipts, and dockets into their preferred spreadsheet and accounting workflows.**

The project aims to deliver a polished, user-focused application that is:
- **Efficient:** Drastically reduces manual data entry through advanced OCR and AI-powered data mapping.
- **Intuitive:** Offers a clean, modern, and easy-to-navigate SwiftUI interface adhering to macOS HIG and the project's `XCODE_STYLE_GUIDE.MD`.
- **Integrated:** Provides robust connections to popular cloud spreadsheet services (Office365 Excel Online, Google Sheets) and future integrations like Gmail.
- **Secure:** Ensures user data and API keys are handled with utmost security using macOS Keychain and best practices.
- **Reliable:** Built with a focus on stability, maintainability, and continuous improvement through Test-Driven Development (TDD) and comprehensive logging.

## Milestone Targets

### Milestone 1: Foundation (Current Focus)
- Establish robust project structure and technical foundation
- Create comprehensive Core Data models for all entities
- Implement core application architecture and navigation
- Set up authentication services including Google SSO
- Develop MVVM framework for consistent development

### Milestone 2: Core Functionality
- Implement case management (creation and editing)
- Develop basic client information management
- Create simple calendar view and event management
- Build document storage functionality
- Establish notification system for deadlines

### Milestone 3: Advanced Features
- Implement document template system
- Enhance navigation and dashboard experience
- Add client communication logging
- Develop search functionality across data types
- Create time tracking system

### Milestone 4: Integration & Refinement
- Add calendar synchronization with macOS Calendar
- Implement advanced document features (versioning, automation)
- Develop reporting and analytics capabilities
- Optional CloudKit integration for data sync
- UI polish and accessibility improvements

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
- **Drag-and-drop/upload images, screenshots, PDFs, and documents**
  - *What*: Users can easily add documents for processing.
  - *Why*: Simplifies data entry and document management.
  - *How*: SwiftUI drag-and-drop, file picker integration.
- **OCR processing to extract line items**
  - *What*: Extracts structured data from receipts/invoices.
  - *Why*: Automates data entry, reduces manual errors.
  - *How*: Apple Vision framework (or Tesseract if needed).
- **User-defined spreadsheet columns**
  - *What*: Users can customize columns for their needs.
  - *Why*: Flexibility for different accounting/tax requirements.
  - *How*: Editable columns, persisted in UserDefaults/local storage.
- **Spreadsheet view with real-time population**
  - *What*: See extracted data as it is processed.
  - *Why*: Immediate feedback, easy review.
  - *How*: Custom SwiftUI table/grid.
- **Export to Excel/CSV**
  - *What*: Download processed data for use elsewhere.
  - *Why*: Integration with existing workflows.
  - *How*: Local file generation.
- **Office365 Excel Online & Google Sheets integration (SSO/OAuth)**
  - *What*: Sync data to cloud spreadsheets.
  - *Why*: Real-time collaboration, cloud backup.
  - *How*: Microsoft Graph API, Google Sheets API, OAuth 2.0.
- **Gmail integration (future)**
  - *What*: Auto-extract invoices/receipts from email.
  - *Why*: Further automation, less manual upload.
  - *How*: Gmail API, background processing.
- **Secure storage of API keys**
  - *What*: Store OpenAI, Anthropic, Google Gemini API keys securely.
  - *Why*: Protect sensitive credentials.
  - *How*: macOS Keychain.
- **NLP for column matching**
  - *What*: Use LLMs to match text/columns from receipts to spreadsheet.
  - *Why*: Smarter, more accurate data mapping.
  - *How*: Integrate LLM APIs, prompt engineering.
- **Document type detection**
  - *What*: Detect if a document is a docket, receipt, or invoice.
  - *Why*: Filter out irrelevant files.
  - *How*: Rule-based or ML model.
- **Multi-currency and entity support**
  - *What*: Record and convert currencies, split line items by entity.
  - *Why*: International and business/personal use cases.
  - *How*: Currency conversion APIs, entity management UI.
- **Analytics, dashboards, and reporting**
  - *What*: Key reports, charts, and KPIs.
  - *Why*: Business insights, tax prep.
  - *How*: SwiftUI dashboards, chart libraries.

## User Experience
- **User Personas**
  - Small business owners
  - Accountants
  - Freelancers
  - Individuals managing personal finances
- **Key User Flows**
  - Upload/drag-and-drop document → OCR → Review/edit line items → Map to spreadsheet columns → Export or sync
  - Connect to Google Sheets/Office365 → Authorize → Sync data
  - Customize spreadsheet columns → Save preferences
- **UI/UX Considerations**
  - Clean, modern SwiftUI interface (dark/light mode)
  - Left navigation: Settings, Dashboards, Profile
  - Spreadsheet/table view with inline editing
  - Intuitive column customization (add, remove, reorder, rename)
  - Real-time feedback and error handling

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