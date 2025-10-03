# FinanceMate - Complete Project Blueprint

**Version:** 6.0.0 (Enhanced & Finalized)
**Last Updated:** 2025-10-03
**Status:** MVP Build In Progress

---

## **1.0. Executive Summary & Project Vision**

### **1.1. Project Vision**

To be the central command center for personal and family wealth, empowering users to aggregate all their financial data automatically, gain deep insights from line-item level details, **proportionally allocate expenses across multiple tax categories**, manage complex financial entities, and make informed investment and life decisions. The platform will be collaborative, allowing for secure, permission-based access for family members and financial professionals. Multi-currency support with tax rules and financial rules specific to region.

### **1.2. Core User Journeys**

1. **Onboarding & Aggregation:** The user securely logs in via SSO (Apple/Google) and is guided to link their financial sources. They connect their bank accounts (e.g., ANZ, NAB via Basiq) and email accounts (Gmail, Outlook) to begin automatic ingestion of transactions, receipts, and invoices.
2. **Triage & Categorization:** Ingested items appear in a central "Inbox" or "Needs Review" area. The user reviews items, confirms auto-categorizations, or manually assigns categories.
3. **Splitting & Allocation:** For any transaction, the user can drill down to its line items and **split the cost of each item by percentage across multiple tax categories (e.g., 70% Business, 30% Personal)** using a visual interface, or apply a pre-saved template.
4. **Analysis & Insights:** The user reviews dashboards covering spending habits, net wealth progression, and progress towards financial goals, with all data reflecting the accurate, real-time tax allocations.
5. **Reporting & Export:** The user (or an invited "Viewer" like an accountant) generates highly accurate, compliant reports for tax purposes, net wealth statements, or expense summaries, which are built from the precise, audited splits.

---

## **2.0. Core Principles & Technical Specification**

### **2.1. Foundational Mandates & Development Principles**

* **MANDATORY:** **P0 CRITICAL EVENT - NO MOCK DATA:** The main application logic MUST NOT contain any hardcoded, `DEMO`, or mock data. All features must be built and tested against real data structures and functional data sources. Mock data is only permitted within isolated unit test targets with explicit user authorization.
* **MANDATORY:** **Development Methodology:** A strict Test-Driven Development (TDD) approach is required. For every feature, failing tests must be written first, followed by the minimum code to make them pass, and then refactoring. Changes must be atomic.
* **MANDATORY:** **Programmatic Execution:** All development, testing, and deployment tasks MUST be performed programmatically. The agent is prohibited from requiring manual user intervention (e.g., "click this button in Xcode").
* **MANDATORY:** **Component Size & Responsibility Limits:** Any component (file, class, view) exceeding **200 lines of code** or having more than **3 distinct responsibilities** must be immediately flagged for refactoring into smaller, modular, and reusable components. This is a strict quality gate.
* **MANDATORY:** **Security First:** All secrets (API keys, tokens) MUST be managed via environment files (`.env`) for local development and a secure vault/secrets management system for production. Secrets MUST be obfuscated from logs and NEVER committed to version control.
* **MANDATORY:** **Prerequisite & Dependency Documentation:** The root `README.md` MUST contain a comprehensive guide detailing all prerequisites, dependencies, environment setup, and bootstrap instructions for the project.

### **2.2. Technical Architecture & Data Model**

* **Technology Stack:**
  * **Platform:** Native macOS application (macOS 14.0+).
  * **UI Framework:** SwiftUI with a custom, reusable glassmorphism design system.
  * **Architecture:** A strict MVVM (Model-View-ViewModel) pattern must be enforced. Views must be lightweight and declarative, containing no business logic.
  * **Data Persistence:** Core Data with a programmatic model (no `.xcdatamodeld` file) and a singleton `PersistenceController`.
  * **Language:** Swift 5.9+.
  * **Build System:** Xcode with automated `xcodebuild` scripts.
* **Data Model:**
  * **MANDATORY:** A star schema relational model MUST be developed and documented in `ARCHITECTURE.md`, defining how all data tables are linked with primary and foreign keys.
  * **MANDATORY:** The Core Data schema must programmatically define entities equivalent to this target schema: `users`, `roles`, `entities`, `tax_categories`, `accounts`, `transactions`, `line_items`, and the critical `line_item_splits`.

---

## **3.0. Development Roadmap: Phased Rollout**

<MVP>
### **3.1. Minimum Viable Product (MVP)**

*Focus: Establish the core application with foundational data aggregation, a functional user management system, and the primary line-item splitting feature.*

#### **3.1.1. Core Functionality & Data Aggregation (MVP)**

* **MANDATORY:** **Bank API Integration:**
  * Securely connect to Australian bank and credit card accounts to automatically sync transaction data via the Basiq API.
  * Must support at a minimum: ANZ BANK and NAB BANK.
* **MANDATORY:** **Email-Based Data Ingestion (HIGHEST PRIORITY):**
  * Implement a service to pull and parse expenses, invoices, and receipts from connected Gmail and Outlook accounts.
  * Use `bernhardbudiono@gmail.com` as the primary E2E test account.
  * Every line item from a parsed email/receipt must be created as a distinct record in the transaction table.
  * Gmail Receipts should be displayed in an interactive, detailed, comprehensive table. It needs to be filterable, sortable and best practice.
  * Gmail Receipts Table should be compact, information dense and `spreadsheet-like` with the ability to edit in-line, and structured, data typed and allows for user `confirmation` (like a database/spreadsheet). Ensure Gmail Receipt items are able to be deleted/edited within the table.
  * Gmail Receipts Table should allow a user to quick delete/edit/process emails
  * Gmail Receipts Table would be extremely large, and therefore appropriate pagination, filters, and UI/UX all in line with best practice to ensure appropriate handling
  * Gmail Receipts Table should handle a robust, and complex filtering control system that is able to handle large API calls (i.e. 5 years of information), therefore `best practice` rate limiting, pagination, etc, needs to be implemented. We need a robust `rules` system, similar to frontier `email managers` and robust filtering to assist in automation and identification.
  * Gmail Receipts Table should store and capture complex user patterns and allow users to store easily editable "memory" that also has robust infrastructure to allow Machine Learning and diagnostic information to allow an AI/LLM to suggest automatic filtering rules and automate processing of new emails, etc. I.e. So the app can "learn" how a user operates and the "types" of emails that often become processable "transactions."
  * Gmail Receipts Table should only "auto-refresh" when "auto-refresh" is set to `true` (or checked).
  * Gmail Receipts Table should always cache to improve performance and reduce the "load times". Use `best practice` to implement a rolling/phased solution that will balance performance, speed and compute.
  * Gmail Receipts Table should always be formatted with a `user-focus` and should allow `best practice` implementations; such as multi-select; multi-delete, multi-edit. Sort, Filter, Auto-compact column widths based on content; ensuring that a user can always see all actions available (i.e. delete, etc). Think of a user experience similar to `Microsoft Excel` spreadsheets.
  * Gmail Receipts Table should always `hide` or `archive` items that have been `processed` or added to the `transactions` table. Ensure that every item is considered as `unique` (ALWAYS STORE UUID's) so that we DO NOT `DUPLICATE` items.
  * Gmail Receipts Table should allow users to `right-click` on items or a selection of items and conduct key actions such as `delete`, etc.
  * Gmail Receipts Table should always make optimal use of available space, and implement `best practices` when it comes to UI implementations, especially handling dynamic resizing and widths, etc. Ensuring no adverse UI/UX such as overlap, hidden elements, broken elements, etc.
* **MANDATORY:** **Email Transaction Filtering (BUG FIX):** The current email ingestion is filtering incorrectly. This must be fixed. The system MUST correctly parse and display all relevant financial transactions from the test email account.
* **MANDATORY:** **Long-term Email Span:** Ensure we search through "All Emails" and not just the "Inbox" within an email. This should identify (At minimum) 5 years worth of rolling information, however, if an email is "converted" to a transaction it becomes static and stored in the database.
* **MANDATORY:** **Unified Transaction Table:**
  * ONLY ONE transaction table will exist in the database.
  * The UI will provide filtered "views" of this table for "expenses," "income," etc.
  * The table MUST be performant, filterable, searchable, and sortable in real-time.
  * Transactions Table should be displayed in an interactive, detailed, comprehensive table. It needs to be filterable, sortable and best practice.
  * Transactions Table should be compact, information dense and `spreadsheet-like` with the ability to edit in-line, and structured, data typed and allows for user `confirmation` (like a database/spreadsheet). Ensure Transaction items are able to be deleted/edited within the table.
  * Transactions Table should allow a user to quick delete/edit/process transactions that are extracted from the "emails" in the "Gmail Receipts" table.
  * Transactions Table would be extremely large, and therefore appropriate pagination, filters, and UI/UX all in line with best practice to ensure appropriate handling
  * Transactions Table should handle a robust, and complex filtering control system that is able to handle large API calls (i.e. 5 years of information), therefore `best practice` rate limiting, pagination, etc, needs to be implemented. We need a robust `rules` system, similar to frontier `email managers` and robust filtering to assist in automation and identification.
  * Transactions Table should store and capture complex user patterns and allow users to store easily editable "memory" that also has robust infrastructure to allow Machine Learning and diagnostic information to allow an AI/LLM to suggest automatic filtering rules and automate processing of new transactions, etc. I.e. So the app can "learn" how a user operates and the "types" of transactions that are processed.
  * Transactions Table should only "auto-refresh" when "auto-refresh" is set to `true` (or checked).
  * Transactions Table should always cache to improve performance and reduce the "load times". Use `best practice` to implement a rolling/phased solution that will balance performance, speed and compute.
  * Transactions Table should always be formatted with a `user-focus` and should allow `best practice` implementations; such as multi-select; multi-delete, multi-edit. Sort, Filter, Auto-compact column widths based on content; ensuring that a user can always see all actions available (i.e. delete, etc). Think of a user experience similar to `Microsoft Excel` spreadsheets.
  * Transactions Table should always be able to be edited as `income`, `expense`, `transfer` (and anything else based on accounting or ledge best practice).
  * Transactions Table should allow users to `right-click` on items or a selection of items and conduct key actions such as `delete`, etc.
  * Transactions Table should always make optimal use of available space, and implement `best practices` when it comes to UI implementations, especially handling dynamic resizing and widths, etc. Ensuring no adverse UI/UX such as overlap, hidden elements, broken elements, etc.
* **MANDATORY:** **Multi-Currency Support:** The system must handle multiple currencies, with Australian Dollars (AUD) as the default. All UI displays must use locale-correct currency formatting.
* **MANDATORY:** **Expanded Settings:** Expand the Settings Screen. The "Settings" screen MUST be expanded into a multi-section view. It must include dedicated, clearly separated sections for "Profile," "Security" (Change Password), "API Keys" (for LLMs), and "Connections" (for linked bank/email accounts).
* **MANDATORY:** **Enhanced Visual Indicators:** Provide Visual Indicators for Splits. A clear visual indicator (e.g., a small icon or badge) MUST be present on any transaction in the main list that has been split.
* **MANDATORY:** **Context-Aware AI Assistant:** The AI Assistant MUST be context-aware. When the user navigates to a new screen (e.g., "Transactions"), the assistant's placeholder text and suggested query buttons (Expenses, Budget, etc.) MUST dynamically update to be relevant to that screen's content.
* **MANDATORY:** **Implement Advanced Filtering Controls:** The simple filter pills MUST be upgraded to a more robust and complex filtering control system. This should allow for multi-selection of categories, date range picking, and rule-based filtering (e.g., "merchant contains 'Uber'").
* **MANDATORY:** **Archive Processed Items:** The "Gmail Receipts" table MUST automatically hide or archive items that have been successfully imported into the "Transactions" table. A toggle or filter must be available for the user to view these archived items.

#### **3.1.2. User Management, Security & SSO (MVP)**

* **MANDATORY:** **SSO REQUIRED:** Functional Apple and Google Single Sign-On (SSO) MUST be implemented as the highest priority.
  * Refer to working example patterns: `/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/_ExampleCode/XcodeFiles/Example SSO Application`.
* **MANDATORY:** **Unified OAuth Flow:** Utilize OAuth flows for both SSO and the Gmail feature, allowing the user to authorize both with a single login flow where possible.
* **MANDATORY:** **User Navigation & Settings:**
  * The UI must contain clear navigation for user management (Profile, Sign Out).
  * The "Settings" screen **MUST be a multi-section view** with dedicated, clearly separated sections for "Profile," "Security" (Change Password), "API Keys" (for LLMs), and "Connections" (for linked accounts).

#### **3.1.3. Line Item Splitting & Tax Allocation [CORE FEATURE] (MVP)**

* **MANDATORY:** **Core Splitting Functionality:** For any transaction line item, the user must be able to split its cost by percentage across multiple tax categories.
* **MANDATORY:** **Timeframes and Data Retention:** We should be able to do a rolling 5 year FY transaction history and capture. We can implement in phases, but we need to build infrastructure and tooling to cope with an enormous amount of data.
* **MANDATORY:** **Split Interface:**
  * The UI must provide real-time validation to ensure splits sum to 100%, disabling the "Save" button otherwise.
  * A visual split designer (e.g., pie chart, sliders) must be included for intuitive allocation.
  * A clear **visual indicator MUST be present on any transaction row** in the main list that has been split.
* **MANDATORY:** **Tax Category Management:**
  * The user must be able to create, edit, and delete entity-specific, color-coded tax categories.
  * The system must provide default Australian tax categories (Personal, Business, Investment) on first setup.
* **MANDATORY:** User-focused UI/UX. Ensure the AI/Chatbot does not *BLOCK* the transactions and Gmail Receipts Table. Ensure all table UI/UX is working (i.e. sort, filter, etc.)

#### **3.1.4. UI/UX & Design System (MVP)**

* **MANDATORY:** **Design Philosophy:** The application must have a "Simple, beautiful, professional, clean and minimalist design."
* **MANDATORY:** **Glassmorphism Design System:** This design system **MUST be implemented across all primary UI components** (cards, sidebars, modals) to create depth and a modern aesthetic.
* **MANDATORY:** **Dashboard Enhancements:** The "Dashboard" summary cards **MUST be enhanced to provide context**, including relevant icons, secondary metrics (e.g., monthly spending total), and a visual trend indicator (e.g., up/down arrow).
* **MANDATORY:** **Transaction View Enhancements:** The main transaction list view **MUST display the monetary amount** and visually distinguish between debit and credit transactions.
* **MANDATORY:** **Visual & Typographic Hierarchy:** A clear **visual and typographic hierarchy MUST be established** on all screens to guide the user's focus.
* **MANDATORY:** **Empty States:** Every view that can display a list of data **MUST have a well-designed "empty state"** with a helpful message, an icon, and a primary call-to-action.
* **MANDATORY:** **Interactive Feedback:** All interactive elements **MUST provide clear visual feedback** on interaction (e.g., hover effects, active/selected states).
* **MANDATORY:** **User-focused UI/UX:** Ensure all visual components don't overlap/cover/interfere with other key elements of the application. i.e. AI Chatbot should NEVER block buttons, information and other interactive UI/UX.
* **MANDATORY:** **Enhanced Dashboard Cards:** Enhance Dashboard Cards. The "Dashboard" summary cards MUST be enhanced to provide more context. This includes adding relevant icons (e.g., a wallet for balance, a list for transactions), secondary metrics (e.g., monthly spending total), and a visual trend indicator (e.g., an up/down arrow with percentage change).
* **MANDATORY:** **Enhanced Transaction Limits:** Add Monetary Amounts to Transaction Lists. The main "Transactions" and "Gmail Receipts" list views MUST display the monetary amount for each item, formatted for the local currency. Debit and credit/income transactions must be made visually distinct from each other (e.g., using color or +/- symbols).
* **MANDATORY:** **Typographic Enhancements:** Establish Typographic Hierarchy. A clear visual and typographic hierarchy MUST be established on all screens. Use varying font weights (e.g., bold for primary data like amounts and merchant names) and opacities/colors (e.g., dimmer text for secondary info like dates and categories) to guide the user's focus.
* **MANDATORY:** **Tooltips and Information:** Implement Data-Rich Tooltips or Expandable Rows. On the main transaction list, hovering over a row (or clicking an expand icon) MUST reveal a tooltip or an expandable inline view showing more details,
* **MANDATORY:** **Implement Glassmorphism Design System:** The "glassmorphism" design system MUST be implemented across all primary UI components. All cards, sidebars, modals, and primary containers must use a background blur/translucency effect with a subtle border to create depth and a modern aesthetic.
* **MANDATORY:** **Optimize Layout for Information Density:** The layout MUST make optimal use of available space. Implement best practices for handling dynamic resizing and column widths to ensure no UI elements overlap, become hidden, or break on different window sizes.
* **MANDATORY:** **Unify Iconography:** The application MUST use a single, high-quality, and consistent icon set for all interactive elements, including navigation tabs, dashboard cards, and action buttons, to create a professional and cohesive visual language.
* **MANDATORY:** **Non-Blocking UI:** The AI Assistant chatbot sidebar MUST NOT overlap or functionally block any core content or interactive elements in the main view. The main content area must intelligently resize or adapt its layout when the assistant is visible.

#### **3.1.5. AI/ML/LLM and Feature Development**

* **MANDATORY:** A dedicated data model/table for "User Automation Memory" MUST be created. It must store associations between transaction characteristics (e.g., merchant name, keywords) and user actions (e.g., assigned category, split template used) to serve as a training dataset for the AI/LLM.
* **MANDATORY:** A new section within "Settings" MUST be created for "Automation Rules." This UI must allow users to create, view, edit, and delete the filtering and categorization rules for incoming email transactions.
* **MANDATORY:** All ingested email items MUST have a status field (e.g., 'Needs Review', 'Transaction Created', 'Archived'). The "Gmail Receipts" table should, by default, only display items with the 'Needs Review' status. An option or filter must be provided to view archived items.
* **MANDATORY:** Ensure the LLM/Chatbot is context aware about the data within the application. This includes being able to do aggregation, and other `agentic` actions on the transactional and email data/information.

#### **3.1.6 Workflow & Interactivity**

* **MANDATORY:** Automate Gmail Receipt Parsing. The "Gmail Receipts" view MUST automatically parse raw email data into a structured, pre-filled transaction form. It must intelligently extract the merchant, date, total amount, and line items, presenting them for one-click confirmation rather than requiring manual data entry.
* **MANDATORY:** Implement "Spreadsheet-Like" Table Functionality. Both the "Transactions" and "Gmail Receipts" tables MUST support advanced, spreadsheet-like interactions. This includes multi-select (e.g., using checkboxes or Shift/Command-click), in-line editing of fields, and automatic column width adjustment.
* **MANDATORY:** Add a Contextual Right-Click Menu. Users MUST be able to right-click on a single transaction/receipt or a multi-selected group to access a contextual menu with key actions like "Categorize," "Assign to Entity," "Apply Split Template," and "Delete."
* **MANDATORY:** rovide Clear Visual Feedback. All interactive elements (buttons, list items, tabs, filters) MUST provide clear visual feedback. This includes distinct hover effects, a clear "active/selected" state for navigation items and filters, and subtle animations on tap/click to confirm user actions.
* **MANDATORY:** Design "Empty States" and Onboarding Cues. Every view that can display a list of data MUST have a well-designed "empty state." This state must not be a blank screen; it should include a helpful message, an icon, and a primary call-to-action button (e.g., "You have no transactions yet. Link your first bank account to get started.").

</MVP>

### **3.2. Alpha Phase**

*Focus: Expand on the MVP by introducing more advanced data management, collaboration, and intelligence features for a limited audience.*

* **MANDATORY:** **Financial Entity Management:** Implement full CRUD functionality for "Entities" (e.g., Personal, Trust, Business), including support for parent-child hierarchical relationships.
* **MANDATORY:** **Role-Based Access Control (RBAC):** Implement the RBAC system with predefined roles (Owner, Contributor, Viewer) and granular, entity-level permissions.
* **MANDATORY:** **Receipt & Invoice Scanning (OCR):** Implement OCR using Apple's Vision Framework to scan receipts/invoices, extract line-item details, and associate them with transactions.
* **MANDATORY:** **AI Co-Pilot & Chat Interface:** Implement the persistent, collapsible chatbot UI. Ensure it is context-aware, can use APIs/MCPs for data manipulation, and can handle complex queries.
* **MANDATORY:** **Split Templates:** Implement the ability for users to create, save, and manage reusable split templates and apply them in bulk.

### **3.3. Beta Phase**

*Focus: Broaden the feature set with wealth and investment tracking, preparing for a wider audience with advanced reporting.*

* **MANDATORY:** **Investment Portfolio Tracking:** Implement tracking for shares (ASX/NASDAQ) and cryptocurrencies by integrating with broker/exchange APIs (e.g., Stake, CommSec, Binance).
* **MANDATORY:** **Net Wealth Reporting:** Implement the "Net Wealth" report consolidating all linked assets and liabilities.
* **MANDATORY:** **Tax-Specific Reporting:** Implement advanced tax summary reports, groupable by financial entity, with accountant-ready exports (CSV/PDF).
* **MANDATORY:** **Frontier Model Capability:** Implement support for the latest models from major providers (Claude, Gemini, OpenAI).

### **3.4. Future / Post-Launch Features**

* **Real Estate Analysis:** Integrate with CoreLogic API.
* **Predictive Analytics & AI Insights:** Introduce features for cash flow forecasting and split intelligence.
* **Platform Expansion:** Develop native iOS and Web App clients.
* **Collaborative Workspaces:** Enhance RBAC with email-based invitations and activity logging.

---

## **4.0. Testing & Quality Assurance Protocol**

* **MANDATORY:** **Testing Methodology:** All testing MUST follow a Test-Driven Development (TDD) approach.
* **MANDATORY:** **Execution Environment:** All testing tasks MUST be executed headlessly, silently, in the background, and fully automated.
* **MANDATORY:** **Non-Intrusive Testing:**
  * The agent is strictly prohibited from using AppleScript, `screencapture`, or any tool that controls the global system cursor or keyboard.
  * **Environment Gating:** Before any test, the agent MUST verify an environment variable such as `IS_HEADLESS_TESTING=true` is set, or halt the operation.
* **MANDATORY:** **Approved Testing Types:**
  * **Unit Tests (Primary):** Must cover all ViewModels and business logic.
  * **Integration Tests:** For Core Data and service-level validation.
  * **Performance Tests:** For load testing with large datasets.
  * **PROHIBITED:** XCUITest and other forms of automated UI testing are forbidden. All UI logic MUST be verifiable through ViewModel unit tests.
* **MANDATORY:** **Visual Validation (If Explicitly Required):** If a task requires visual validation, it MUST be performed using non-intrusive, framework-native APIs in a sandboxed environment, with results processed by a vision AI.
* **MANDATORY:** **E2E & Functional Validation (via Unit/Integration Tests):**
  * Every feature's multi-step user scenario **must be validated** through chained integration tests.
  * These tests **must verify the entire data flow**; mocking of primary internal services is forbidden.
  * For every feature, at least one **"negative path" test** must be implemented.
  * Tests **must use dynamic data**.
  * Every test **must be explicitly linked via comments to its requirement ID**.
  * The logic behind every UI element **MUST be tested by calling the corresponding ViewModel function** and **asserting a verifiable change** in state.
  * The code within an interactive element's action handler **MUST achieve a minimum of 90% test coverage**.
  * A **static analysis script MUST execute before any build test** to fail the process if it detects interactive UI elements with empty or placeholder action handlers.
* **MANDATORY:** **Test Suite Integrity:**
  * Test everything 3-5 times minimum. 100% test passage is mandatory.
  * Upon feature completion, an **independent verification process** must re-run all tests from a clean environment.

---

## **Appendix A: Feature Backlog / Vision**

*(This section contains a list of features from previous designs to serve as a backlog for future development.)*

* **ADVANCED ANALYTICS:** Predictive analytics, cash flow forecasting, pattern recognition.
* **ARCHITECTURAL:** Advanced dependency injection, memory management optimization.
* **CONTEXTUAL HELP:** Intelligent guidance overlays, feature onboarding, interactive tutorials.
* **NETWORK & CONNECTIVITY:** Real-time data synchronization capabilities, network monitoring.

---

## **Appendix B: AI Agent Operational Protocol**

*(This section contains meta-rules defining how the AI agent should operate, manage tasks, and ensure quality.)*

### **P0 MANDATORY RULES (ZERO TOLERANCE)**

* **MANDATORY:** ENSURE YOU DO NOT GO TO THE USER UNTIL YOU HAVE VERIFIED EVERYTHING 100% YOURSELF.
* **MANDATORY:** ENSURE FOR EVERY TEST THEN SUBSEQUENT CODE YOU WRITE, THAT THE TEST PASSES AND THE CODE PASSES CODE REVIEW BEFORE PUSHING A COMMIT TO GITHUB.
* **MANDATORY:** ENSURE EVERY UI COMPONENT'S *LOGIC* IS TESTED via its ViewModel.

### **A-V-A (ASSIGN-VERIFY-APPROVE) PROTOCOL**

* **MANDATORY:** All significant tasks MUST follow the A-V-A protocol. The agent is BLOCKED from continuing without explicit user approval of tangible proof (screenshots, logs, test results).
* **MANDATORY:** Agents CANNOT self-assess work quality or declare tasks complete autonomously.

### **PRIMARY WORKFLOW**

1. Read `TASKS.md` for current todo items.
2. Deploy `technical-project-lead` agent to coordinate all work.
3. Execute using TDD methodology.
4. Commit to GitHub after each stabilization.
5. Update `TASKS.md` with progress.

### **AGENT COORDINATION**

* **DEFAULT:** Use the `technical-project-lead` agent (from `/Users/bernhardbudiono/.claude/agents/`) for all primary coordination.
* **ECOSYSTEM:** The lead agent may delegate to specialized agents (e.g., `code-reviewer`, `test-writer`, `engineer-swift`).
* **PROTOCOLS:** Enforce A-V-A and I-Q-I (Iterate-Quality-Improve) protocols.
