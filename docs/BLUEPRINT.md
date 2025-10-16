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

#### **3.1.0. Example Extraction from Email** **MANDATORY**

* 2025-10-14: Email From: "City of Gold Coast" | Sender Email: "<noreply@goldcoast.qld.gov.au>" | Order Number (Email): "" | Attachment Name: "05416335.pdf" | Invoice/Receipt Number: "69804724" | External Reference: "PY-4189085" | Company/Vendor: "City of Gold Coast" |
  * Line Item Description:"Rates Assessment: UNIT 1, 173, Olsen Avenue, LABRADOR QLD 4215: 235608361" | Amount/Value: "500.00" | GST: "0.00" | Total: "0.00" | Qty: "" (Assume 1)
 | Qty: "" (Assume 1)  * Line Item Description: "Merchant Service Fee" | Amount/Value: "3.40" | GST: "0.00" | Total: "0.00"
  * Additional Notes: *""*
* 2025-10-01: Email From "Our Sage" | Semder Email: "<OurSage@automedsystems-syd.com.au>" | Order Number (Email): "" | Attachment Name: "Receipt-249589.pdf" | Invoice/Receipt Number: "249589" | External Reference: "" | Company/Vendor: "Our Sage" |
  * Line Item Description: "7. Script - Repeat" | Amount/Value: "21.00" | GST: "0.00" | Total: "21.00" | Qty: "" (Assume 1)
  * Additional Notes: *PDF Attachment requires password - this needs to be escalated to the user*
* 2025-09-26: Email From "Bunnings Marketplace" | Sender Email: "<noreply@marketplace-comms.bunnings.com.au>" | Order Number (Email): "" | Attachment Name: "Invoice-IN2134A-7931.pdf" | Invoice/Receipt Number: "IN2134A-7931" | External Reference: "12091b53-13b0-41f6-b604-f8efc0a68892" | Company/Vendor: "Sello Products Pty.Ltd." |
  * Line Item Description: "Centra Adjustable Parallel Dip Bar" | Amount/Value: "$71.00" | GST: "$6.45" | Qty: "1"
  * Line Item Description: "Shipping" | Amount/Value: "$7.42" | GST: "$0.67" | Qty: "1"

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
* **MANDATORY:** **Comprehensive Gmail Table Column Layout:** The Gmail Receipts table MUST display ALL extracted email information in the collapsed row to enable users to validate AI extraction accuracy at a glance. The table MUST include the following 13 columns in a spreadsheet-like layout:
  * Column 1: Selection checkbox for multi-select operations
  * Column 2: Expand/collapse indicator (►/▼) for detail panel
  * Column 3: Transaction date (sortable, filterable by date range)
  * Column 4: **AI-Extracted Merchant** (editable inline, sortable, filterable with search) - CRITICAL for validating BNPL intermediary detection (e.g., Afterpay→Bunnings)
  * Column 5: **Inferred Category** (editable badge with color coding, multi-select filter) - Must show AI categorization immediately
  * Column 6: Amount (editable, sortable, range filter)
  * Column 7: **GST Amount** (sortable, Yes/No filter) - Australian tax compliance, must be visible in main row
  * Column 8: Email sender domain (sortable, dropdown filter)
  * Column 9: Email subject (flexible width, text search filter)
  * Column 10: **Invoice/Receipt Number** (sortable, text search) - Critical for business expense tracking
  * Column 11: **Payment Method** (sortable, multi-select filter) - Visa/Mastercard/PayPal/etc visibility
  * Column 12: Line items count (sortable, count filter)
  * Column 13: Confidence score with traffic light indicator (sortable, range filter)
  * Column 14: Action buttons (Delete, Import)
* **MANDATORY:** **Excel-Like Table Interactions:** The Gmail Receipts table MUST support Microsoft Excel-equivalent functionality including: multi-select via checkboxes and Shift/Cmd-click, inline editing of merchant/category/amount fields via double-click, column sorting via header clicks, per-column filtering with appropriate controls (dropdowns, range pickers, search boxes), automatic column width adjustment based on content, right-click context menus for batch operations, keyboard navigation (arrow keys, Tab, Enter), and responsive column hiding on smaller screens.
* **MANDATORY:** **Inline Field Editing:** Merchant, Category, and Amount fields MUST be editable directly in the table row without requiring a separate modal or form. Changes must be persisted immediately to the ExtractedTransaction model and visually confirmed with subtle animation feedback.
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
* **MANDATORY:** **Local Storage of Emails:** Ensure we store relevant email information locally (secure and encrypted), to reduce the time/latency, as we should only be downloading the missing emails/difference in emails, we should be able to store in a similar format to Microsoft Outlook for Mac
* **MANDATORY:** **Compatibility with Microsoft Outlook for Mac:** Ensure we allow for the app to be "pointed" towards the MS Outlook (MAC) files locally, so we can read and extract available information from there, but not destroy/harm/edit the Outlook file at all. We should be storing all adaptations/edits/changes in our own local database, then using the Gmail API to push changes appropriately. Ensure we only see the gmail addresses we are allowed to see.
* **MANDATORY:** **Compatibility with other email clients that store emails locally:** If other popular mail clients are available and have locally stored emails, then to save the slow initial download and sync of emails we should ensure we research and understand how to access/sync those emails with `Financemate`
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

#### **3.1.1.4. Intelligent Document Extraction Pipeline (MVP → Beta)**

**Performance Validation (M4 Max):** Foundation Models achieves 83% accuracy vs 54% regex baseline, with 1.72s average extraction time. Zero cost, 100% privacy, offline-capable. See `scripts/extraction_testing/PERFORMANCE_REPORT.md`.

##### **Foundational Architecture (Phase 1-MVP)**

* **MANDATORY: Implement Apple Foundation Models Framework Integration.** The Gmail transaction extraction system MUST be upgraded to use Apple's native Foundation Models framework (macOS 26+) for on-device LLM inference. The system must use the `SystemLanguageModel` API with `LanguageModelSession` for structured data extraction without external API costs or network dependencies.
* **MANDATORY: 3-Tier Hybrid Extraction Architecture.** The extraction pipeline MUST implement: (1) **Fast Regex Baseline** for simple receipts with clear patterns (<100ms, handles 20-30% of emails), (2) **Foundation Models Validation** for schema-variant and BNPL receipts (1-3 seconds on-device, handles 60-70%), (3) **Manual Review Queue** for confidence <0.7 (5-10% requiring user validation). All processing must occur on-device using Apple Silicon GPU acceleration (Metal framework).
* **MANDATORY: JSON-Based Structured Output.** The LLM extraction prompt MUST instruct the Foundation Model to return ONLY valid JSON (no markdown formatting) matching the ExtractedTransaction schema. The system must strip any markdown code block markers (```json) if present and parse JSON with comprehensive error handling. All field types must be validated: String for merchant/category, Double for amounts, optional String? for ABN/invoice/payment.
* **MANDATORY: Multi-Level Confidence Scoring.** The extraction pipeline MUST calculate composite confidence using four factors: (1) Regex pattern match strength (0-1.0 based on number of successful patterns), (2) Foundation Models extraction certainty (0-1.0, LLM self-assessment in JSON), (3) Field completeness (percentage of required fields successfully extracted), (4) Data validation pass rate (format and logic checks). Threshold assignments: >0.9 = "Auto-Approved" (green badge), 0.7-0.9 = "Needs Review" (yellow badge), <0.7 = "Manual Review" (red badge).

##### **On-Device OCR with Vision Framework (Phase 1-MVP)**

* **MANDATORY: Implement Apple Vision Framework OCR.** The system MUST use Apple's native Vision framework (`VNRecognizeTextRequest`) to extract text from PDF and image email attachments. Vision provides spatial text recognition with per-character confidence scores, table structure detection via bounding box analysis, and works completely on-device with zero API costs. OCR text must be combined with email body text before passing to extraction tier.
* **MANDATORY: PDF and Image Attachment Processing.** When Gmail emails contain attachments with MIME types application/pdf, image/png, or image/jpeg, the system must: (1) Download attachment data securely to app sandbox, (2) Pass to VisionOCRService for text extraction using `VNRecognizeTextRequest`, (3) Detect spatial table structures using `VNRecognizedTextObservation.boundingBox` coordinates, (4) Combine OCR text with email body, (5) Feed combined text to Foundation Models Tier 2, (6) Preserve attachment data for user reference in detail panel, (7) Delete temporary files immediately after processing.

##### **Prompt Engineering for Foundation Models (Phase 1-MVP)**

* **MANDATORY: Australian Financial Context in Prompts.** All Foundation Models extraction prompts MUST include Australian financial context and business rules: (1) GST is always 10% of pre-tax total, (2) ABN format is XX XXX XXX XXX (11 digits with spaces), (3) Common BNPL providers and their semantics (Afterpay/Zip/PayPal Pay in 4 are payment intermediaries, not merchants), (4) Major Australian merchants and typical email patterns (Bunnings <noreply@bunnings.com.au> with "TAX INVOICE", Woolworths <receipts@woolworths.com.au> with "WW-" invoice prefix), (5) Payment methods (Visa, Mastercard, Amex, Direct Debit, BPAY).
* **MANDATORY: Anti-Hallucination Prompt Rules.** The extraction prompt MUST include explicit anti-hallucination instructions validated through M4 Max testing: (1) "If a field is not found in the email text, return null - NEVER invent placeholder data like 'XX XXX XXX XXX' or 'INV123'", (2) "Extract the FINAL TOTAL amount only (look for 'Total:', 'Grand Total:', 'Amount Due:'), not subtotals, line item prices, or installment amounts", (3) "For BNPL emails (Afterpay/Zip), extract the TRUE merchant name from 'Merchant:' field or order details, not the payment provider name", (4) "Set confidence to 0.9+ only if certain about ALL extracted fields, 0.7-0.9 if some fields missing or uncertain, <0.7 if mostly guessing".
* **MANDATORY: Semantic Merchant Normalization.** The extraction prompt MUST instruct the Foundation Model to normalize merchant names semantically using Australian business knowledge. Provide few-shot examples in prompt: (1) "Officework" → "Officeworks", (2) "Woollies" → "Woolworths", (3) "Afterpay (Bunnings Warehouse)" → "Bunnings", (4) "via PayPal from Coles Online" → "Coles", (5) "JB HI-FI" → "JB Hi-Fi". The model must extract the canonical merchant name, not abbreviations or payment intermediaries.

##### **Privacy-First Processing (Phase 1-MVP)**

* **MANDATORY: Zero External Data Transmission.** The extraction pipeline MUST process all financial data on-device using Apple's Foundation Models framework and Vision framework. No email content, attachment data, extracted transaction information, or user financial data may be transmitted to external APIs, cloud services, or third-party systems. This ensures GDPR/privacy compliance and eliminates ongoing API costs. Validate using network monitoring during E2E tests.
* **MANDATORY: Secure Temporary File Handling.** When processing PDF/image attachments, temporary files MUST be stored exclusively in the app's sandboxed container using `FileManager.default.temporaryDirectory`. All temporary files must be encrypted at rest using Data Protection API (`NSFileProtectionComplete` attribute) and deleted immediately via `try? FileManager.default.removeItem(at: tempURL)` within a defer block after OCR processing completes, ensuring no financial data persists on disk.

##### **Performance Optimization (Phase 1-MVP)**

* **MANDATORY: Concurrent Batch Processing.** When extracting from multiple emails (e.g., initial 5-year sync of 500 emails), the system MUST process up to 5 emails concurrently using Swift's `TaskGroup` and Apple Silicon's unified memory architecture. Progress must be displayed in Gmail view header with: (1) "Processing 342/500 emails...", (2) Estimated time remaining based on average 1.7s per email on M4 Max, (3) Cancel button to abort batch operation, (4) Error count for failed extractions.
* **MANDATORY: Extraction Result Caching.** Successfully extracted transactions MUST be cached in Core Data as `ExtractedTransaction` entities linked to source email ID via `sourceEmailID` field. Before re-extracting an email (e.g., user refreshes Gmail view), the system must query Core Data for existing extraction by email ID. If found and email content hash matches (`email.snippet.hash(into:)`), skip re-extraction and use cached result, improving performance by 95% on repeated operations.

##### **User Feedback & Continuous Improvement (Phase 1-MVP)**

* **MANDATORY: Track User Corrections in ExtractionFeedback Entity.** Create Core Data entity `ExtractionFeedback` with fields: `id` (UUID), `emailID` (String), `fieldName` (String - "merchant"/"amount"/etc), `originalValue` (String), `correctedValue` (String), `merchant` (String), `timestamp` (Date), `wasHallucination` (Bool). When user edits any field in Gmail Receipts table via inline editing or detail panel, automatically create ExtractionFeedback record. This builds training dataset for future prompt refinement and schema drift detection.
* **MANDATORY: Extraction Analytics Dashboard.** Add "Extraction Health" section to Settings view (after "Connections" section) displaying: (1) Total extractions this month with bar chart, (2) Confidence distribution pie chart (Auto-Approved green / Needs Review yellow / Manual Review red percentages), (3) Top 5 most frequently corrected merchants with correction counts, (4) Average extraction time trend line (last 30 days), (5) Field-level accuracy: merchant 95%, amount 87%, GST 72%, invoice 45%, (6) "Export Feedback Data" button for CSV download. All metrics computed from Core Data `ExtractedTransaction` and `ExtractionFeedback` entities.

##### **Fallback Strategy for Device Compatibility (Phase 1-MVP)**

* **MANDATORY: Graceful Degradation for Pre-macOS 26 Devices.** The system MUST detect Foundation Models availability on app launch using `SystemLanguageModel.default.availability` check. If unavailable (macOS <26, Apple Intelligence disabled, or device ineligible), display warning banner in Gmail view: "Advanced extraction requires macOS 26+ with Apple Intelligence enabled. Using basic regex extraction (54% accuracy)." Automatically fall back to: (1) Pure regex extraction using current `GmailTransactionExtractor` logic, (2) Lower confidence threshold (0.5 instead of 0.7) to account for reduced accuracy, (3) Optional: Anthropic Claude API with user-provided API key in Settings > API Keys > Extraction Service.
* **MANDATORY: Device Capability Detection and User Guidance.** On first app launch, the system MUST detect and log to console using `NSLog()`: (1) macOS version via `ProcessInfo.processInfo.operatingSystemVersion` (require >=26.0), (2) Apple Intelligence enabled status check via `SystemLanguageModel.default.availability` case matching, (3) Foundation Models framework availability boolean, (4) Apple Silicon chip type via `sysctl machdep.cpu.brand_string` (M1/M2/M3/M4 for performance expectations). If requirements not met, display modal `Alert` on first Gmail view navigation with actionable steps: "For best extraction accuracy (83% vs 54%), enable Apple Intelligence in System Settings > Apple Intelligence & Siri and ensure macOS 26+. Current device: macOS X.X, Chip: MX, Apple Intelligence: [Enabled/Disabled]" with "Remind Me Later" and "Open System Settings" buttons.

##### **Error Handling & Resilience (Phase 1-MVP)**

* **MANDATORY: Comprehensive Extraction Error Handling.** The extraction pipeline MUST handle all error scenarios with user-friendly recovery: (1) Foundation Models API timeout (>10 seconds) - fall back to Tier 1 regex, log timeout event, (2) JSON parsing failure - display raw LLM response in detail panel for manual entry, create ExtractionFeedback with `jsonParseError` field, (3) Vision OCR failure on PDF - log error with attachment MIME type and file size, skip attachment and process email text only, (4) Concurrent batch processing cancellation - save partial results to Core Data, display "Cancelled: Processed 245/500 emails" message, allow resume from last processed email ID, (5) Network timeout during Gmail fetch - retry up to 3 times with exponential backoff (2s, 4s, 8s), then display error with "Retry" button.
* **MANDATORY: Extraction Retry Logic with User Control.** When extraction fails for any email (timeout, error, or low confidence <0.3), the system MUST: (1) Mark ExtractedTransaction with `extractionStatus` field set to "Failed", (2) Store error message in `extractionError` field for debugging, (3) Display "Retry Extraction" button in Gmail table row's context menu, (4) On retry, increment `retryCount` field (max 3 attempts), (5) After 3 failed attempts, permanently mark as "Manual Entry Required" and disable retry button, (6) Log all retry attempts with timestamp, tier attempted, and error details to `ExtractionLog` Core Data entity for analytics.
* **MANDATORY: Rate Limiting and Throttling.** To prevent system resource exhaustion during batch extraction, the system MUST implement: (1) Maximum 5 concurrent Foundation Models sessions using `TaskGroup` with `maxConcurrentTasks = 5`, (2) Minimum 100ms delay between starting new sessions to prevent GPU saturation, (3) Memory pressure monitoring using `os_proc_available_memory()` - if available memory <4GB, reduce concurrency to 2 sessions, (4) CPU thermal state monitoring via `ProcessInfo.thermalState` - if thermal state is .critical, pause extraction for 30 seconds and notify user "System is hot - pausing extraction to cool down", (5) User-configurable batch size in Settings > Advanced (default: 50 emails per batch, range: 10-500).

##### **Testing & Validation Requirements (Phase 1-MVP)**

* **MANDATORY: Extraction Pipeline Unit Tests.** Create comprehensive XCTest suite in `FinanceMateTests/Services/IntelligentExtractionServiceTests.swift` with minimum 15 test cases covering: (1) `testRegexTier1FastPath()` - Simple receipt extracts correctly in <100ms, (2) `testFoundationModelsTier2()` - BNPL email extracts true merchant, (3) `testManualReviewTier3()` - Low confidence routes to manual queue, (4) `testJSONParsingWithMarkdown()` - Strips ```json``` blocks correctly, (5) `testAntiHallucination()` - Returns null for missing fields, not placeholder data, (6) `testMerchantNormalization()` - "Officework" → "Officeworks", (7) `testConfidenceScoring()` - Composite calculation produces expected thresholds, (8) `testCacheHit()` - Identical email skips re-extraction, (9) `testCacheMiss()` - Modified email triggers new extraction, (10) `testConcurrentBatchProcessing()` - 10 emails process with 5 concurrency, (11) `testErrorFallback()` - FM timeout falls back to regex, (12) `testVisionOCRIntegration()` - PDF attachment OCR combines with email text, (13) `testExtractionFeedbackCreation()` - User edit creates feedback record, (14) `testGracefulDegradation()` - macOS <26 uses regex only, (15) `testPerformanceThreshold()` - Extraction completes in <5s on M1/M2/M3/M4.
* **MANDATORY: Extraction Accuracy Validation.** The system MUST include an E2E test suite using real Gmail test samples from `scripts/extraction_testing/gmail_test_samples.json` that validates: (1) Overall accuracy >75% on 6 sample emails (Bunnings, Woolworths, Afterpay, Officeworks, Uber, ShopBack), (2) BNPL semantic extraction: "Afterpay" email must extract "Bunnings Warehouse" as merchant (not "Afterpay"), (3) Amount accuracy: Must extract FINAL TOTAL ($158.95) not line items ($129.00) or subtotals ($144.50), (4) Field completeness: 80%+ of present fields must be extracted (GST, ABN, invoice, payment if available in email), (5) No hallucination: If field not in email, must be null (not "XX XXX XXX XXX" or "INV123"), (6) Performance: Average extraction time <3 seconds on M1 or better. Test suite must fail if any validation criteria not met.

##### **Integration with Existing System (Phase 1-MVP)**

* **MANDATORY: Backward-Compatible Integration.** The intelligent extraction service MUST integrate with existing codebase without breaking changes: (1) Replace `GmailTransactionExtractor.extract(from:)` internal implementation while preserving function signature `static func extract(from email: GmailEmail) -> [ExtractedTransaction]`, (2) Maintain compatibility with `GmailViewModel.extractTransactionsFromEmails()` orchestration logic, (3) Preserve all existing `ExtractedTransaction` model fields (id, merchant, amount, date, category, items, confidence, rawText, emailSubject, emailSender, gstAmount, abn, invoiceNumber, paymentMethod), (4) Add NEW optional fields to ExtractedTransaction without modifying existing: `reviewStatus` (enum: autoApproved/needsReview/manualReview), `extractionTier` (enum: regex/foundationModels/manual), `extractionTime` (Double - seconds), `emailHash` (Int - for cache invalidation), (5) All existing unit tests for GmailViewModel must continue passing without modification.
* **MANDATORY: Progressive Rollout Strategy.** The Foundation Models integration MUST be feature-flagged for safe rollout: (1) Create `UserDefaults` key "EnableIntelligentExtraction" (default: true if macOS 26+, false otherwise), (2) Add toggle in Settings > Advanced > "Use AI-Powered Extraction (Requires macOS 26+)" with info button explaining 83% vs 54% accuracy trade-off, (3) When disabled, use only regex Tier 1 extraction, (4) Log feature flag state on app launch: "Intelligent Extraction: [Enabled/Disabled], Reason: [macOS version/User preference/Model unavailable]", (5) Allow users to disable if extraction quality is poor or processing too slow on older M1 devices.

##### **UI/UX Requirements for Extraction Features (Phase 1-MVP)**

* **MANDATORY: Visual Extraction Status Indicators.** The Gmail Receipts table MUST display extraction status visually in each row: (1) **Confidence Badge**: Circle indicator in Column 13 with color (Green >0.9, Yellow 0.7-0.9, Red <0.7) and percentage text, (2) **Review Status Badge**: Text label showing "Auto-Approved" (green background), "Needs Review" (yellow), or "Manual Review" (red) positioned next to confidence, (3) **Extraction Tier Indicator**: Small icon or text showing which tier processed the email (⚡ for regex <100ms, 🧠 for Foundation Models 1-3s, ✋ for manual), (4) **Processing Animation**: During batch extraction, show pulsing gradient overlay on row with "Extracting..." text, (5) **Error State**: Red X icon with tooltip showing error message if extraction failed, with "Retry" mini-button.
* **MANDATORY: Batch Extraction Progress UI.** During concurrent batch processing (500 emails on initial sync), the Gmail view header MUST display real-time progress: (1) **Progress Bar**: Linear progress indicator showing completion percentage with gradient fill (blue to green), (2) **Status Text**: "Processing 342/500 emails (68%)... Est. 4m 23s remaining", updated every second, (3) **Live Stats**: "✅ 298 auto-approved | ⚠️ 38 needs review | ❌ 6 failed" showing distribution, (4) **Cancel Button**: Red "Stop Extraction" button that calls `TaskGroup.cancelAll()` and saves partial results, (5) **Performance Indicator**: "Using Tier 2 (Foundation Models) - 1.8s avg per email" showing current tier and speed, (6) **Completion Message**: On finish, show toast: "Extraction complete: 342 emails processed in 9m 12s. 298 auto-approved, 38 need your review."

##### **Data Model Requirements (Phase 1-MVP)**

* **MANDATORY: ExtractionFeedback Core Data Entity.** Create entity with exact schema: (1) `id`: UUID primary key, (2) `emailID`: String indexed field linking to source email, (3) `transactionID`: UUID optional linking to created Transaction if imported, (4) `fieldName`: String enum ("merchant", "amount", "category", "gstAmount", "abn", "invoiceNumber", "paymentMethod"), (5) `originalValue`: String storing AI-extracted value (may be null for missing fields), (6) `correctedValue`: String storing user-corrected value, (7) `merchant`: String for grouping corrections by merchant, (8) `wasHallucination`: Bool true if originalValue was "XX XXX XXX XXX" or "INV123" style placeholder, (9) `timestamp`: Date indexed for time-series analysis, (10) `confidence`: Double storing original extraction confidence (0-1.0), (11) `extractionTier`: String ("regex"/"foundationModels"/"manual"). Add Core Data fetch request: `ExtractionFeedback.fetchRequest(predicate: NSPredicate(format: "merchant == %@ AND timestamp > %@", merchantName, thirtyDaysAgo))` for analytics.
* **MANDATORY: ExtractedTransaction Schema Extensions.** Add these REQUIRED fields to ExtractedTransaction Core Data entity: (1) `reviewStatus`: String enum (not optional) with values "autoApproved"/"needsReview"/"manualReview", default "needsReview", (2) `extractionTier`: String enum (not optional) with values "regex"/"foundationModels"/"manual", default "regex", (3) `extractionTime`: Double (not optional) storing seconds taken to extract, default 0.0, (4) `emailHash`: Int64 (not optional) computed via `email.snippet.hashValue` for cache invalidation, (5) `retryCount`: Int16 (not optional) tracking extraction retry attempts, default 0, max 3, (6) `extractionError`: String optional storing last error message if extraction failed, (7) `extractionTimestamp`: Date (not optional) when extraction was performed, (8) `foundationModelsVersion`: String optional storing "macOS X.X Foundation Models ~3B" for debugging model version changes. All fields must be @NSManaged properties with Core Data attribute types defined in PersistenceController.swift programmatic model.

##### **Logging, Monitoring & Debugging (Phase 1-MVP)**

* **MANDATORY: Comprehensive Extraction Logging.** The system MUST log all extraction events to console using `NSLog()` with structured format for debugging and analytics: (1) **Start Event**: `[EXTRACT-START] Email: <subject> | Sender: <domain> | Has Attachments: [Yes/No] | Tier: [Attempting Tier X]`, (2) **Tier 1 Result**: `[EXTRACT-TIER1] Regex Confidence: 0.85 | Fields Found: [amount, gst, abn] | Decision: [Proceed/Fallback to Tier 2]`, (3) **Tier 2 Call**: `[EXTRACT-TIER2] Calling Foundation Models | Prompt Length: 450 chars | Timeout: 10s`, (4) **Tier 2 Result**: `[EXTRACT-TIER2] FM Response Time: 1.72s | JSON Valid: [Yes/No] | Confidence: 0.92 | Fields: [merchant, amount, category, gst, invoice, payment]`, (5) **Final Decision**: `[EXTRACT-COMPLETE] Status: Auto-Approved | Tier Used: foundationModels | Total Time: 1.85s | Hash: 123456789`, (6) **Error Event**: `[EXTRACT-ERROR] Tier: Tier2-FoundationModels | Error: <message> | Fallback: Tier3-Manual | Email ID: <id>`. All logs must include timestamp and be filterable by email ID for debugging specific extraction failures.
* **MANDATORY: Extraction Performance Monitoring.** The system MUST track and persist extraction performance metrics in dedicated Core Data entity `ExtractionMetrics` with daily aggregation: (1) `date`: Date (primary key for daily rollup), (2) `totalExtractions`: Int32 count of emails processed, (3) `tier1Count`: Int32 (regex fast path usage), (4) `tier2Count`: Int32 (Foundation Models usage), (5) `tier3Count`: Int32 (manual review required), (6) `avgExtractionTime`: Double (seconds average across all tiers), (7) `avgConfidence`: Double (0-1.0 average across all extractions), (8) `halluc inationCount`: Int32 (emails with invented placeholder data), (9) `errorCount`: Int32 (extraction failures requiring retry), (10) `cacheHitRate`: Double (0-1.0 percentage of cache hits vs misses). Display metrics in Settings > Extraction Health > Performance tab with line charts showing 30-day trends. Alert user if avgConfidence drops below 0.65 or errorCount exceeds 10% of total for 3 consecutive days.

##### **Field Validation Rules (Phase 1-MVP)**

* **MANDATORY: Strict Field Format Validation.** After extraction (regex or Foundation Models), the system MUST validate each field before creating ExtractedTransaction: (1) **Amount**: Must be Double >0.0 and <=999,999.99, reject if negative or >$1M (likely parsing error), (2) **GST**: If present, must be ~10% of amount (tolerance ±2%), if GST differs by >2% log warning and set confidence -0.1, (3) **ABN**: Must match regex `^\d{2}\s?\d{3}\s?\d{3}\s?\d{3}$` exactly 11 digits with optional spaces, reject "XX XXX XXX XXX" placeholder, (4) **Invoice Number**: Must be 3-20 alphanumeric characters matching `^[A-Z0-9-]{3,20}$`, reject "INV123" or "INVOICE" generic placeholders, (5) **Date**: Must be within range (email date -30 days to email date +1 day), reject future dates or dates >5 years old, (6) **Category**: Must be one of predefined Australian categories (Groceries, Retail, Utilities, Transport, Dining, Healthcare, Entertainment, Other), reject unknown categories, (7) **Payment Method**: Must be one of (Visa, Mastercard, Amex, Discover, PayPal, Direct Debit, BPAY, Cash, Afterpay, Zip, Other), case-insensitive matching. If any validation fails, reduce confidence by 0.2 and set reviewStatus to "needsReview".

##### **Integration Testing Requirements (Phase 1-MVP)**

* **MANDATORY: End-to-End Extraction Pipeline Validation.** Create E2E test `test_intelligent_extraction_pipeline_e2e.py` that validates complete flow: (1) **Test Setup**: Load 6 test emails from `gmail_test_samples.json`, ensure Foundation Models available or skip with warning, (2) **Test Execution**: Call `IntelligentExtractionService.extract(from:)` for each email, measure total time, (3) **Accuracy Assertions**: Assert overall accuracy >75% (at least 4/6 emails extract successfully), assert BNPL test (Afterpay email) extracts "Bunnings Warehouse" not "Afterpay", assert NO hallucinations (no "XX XXX XXX XXX" or "INV123" in results), (4) **Performance Assertions**: Assert average extraction time <3.0 seconds on M1+ (test on CI/CD runner), assert memory usage increase <1GB during batch of 10 emails, (5) **Regression Prevention**: Assert regex Tier 1 still works for simple receipts (Bunnings standard format), assert existing GmailViewModel.extractTransactionsFromEmails() integration works without code changes. Test must run on every git commit via pre-commit hook and fail build if assertions not met.
* **MANDATORY: Extraction Quality Regression Detection.** Implement automated quality monitoring that fails E2E tests if extraction performance degrades: (1) **Baseline Metrics**: Store current extraction accuracy (83%), field completeness (90%), hallucination rate (<5%) in test configuration file `test_extraction_baselines.json`, (2) **Regression Thresholds**: Fail test if accuracy drops >5% (below 78%), field completeness drops >10% (below 80%), or hallucination rate increases >5% (above 10%), (3) **Performance Regression**: Fail test if average extraction time increases >50% (above 2.5s on M4 Max) or memory usage increases >30% (above 4GB for batch of 10), (4) **Alert on Degradation**: If test fails due to regression, create GitHub Issue automatically with title "EXTRACTION QUALITY REGRESSION" and body including: current metrics vs baseline, sample emails that failed, suspected cause (model version change, prompt modification, code bug), (5) **Update Baseline**: Provide manual script `scripts/update_extraction_baseline.py` that updates baseline metrics only after code review approval, requires `--approved-by="Name"` flag to prevent accidental updates.

#### **3.1.2. User Management, Security & SSO (MVP)**

* **MANDATORY:** **SSO REQUIRED:** Functional Apple and Google Single Sign-On (SSO) MUST be implemented as the highest priority.
  * Refer to working example patterns: `/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/_ExampleCode/XcodeFiles/Example SSO Application`.
* **MANDATORY:** **Unified OAuth Flow:** Utilize OAuth flows for both SSO and the Gmail feature, allowing the user to authorize both with a single login flow where possible.
* **MANDATORY:** **User Navigation & Settings:**
  * The UI must contain clear navigation for user management (Profile, Sign Out).
  * The "Settings" screen **MUST be a multi-section view** with dedicated, clearly separated sections for "Profile," "Security" (Change Password), "API Keys" (for LLMs), and "Connections" (for linked accounts).
* **MANDATORY:** **Data Protection at Rest.** All financial data including transactions, line items, tax allocations, bank account information, and email content MUST be encrypted at rest using macOS Data Protection API with file protection level `NSFileProtectionComplete`. Database files, cached email content, and temporary extraction files MUST be inaccessible when the device is locked or compromised.
* **MANDATORY:** **Secure Credential Management.** All authentication tokens (Gmail access/refresh tokens, bank API credentials, SSO session tokens), API keys (Anthropic, Basiq), and sensitive configuration data MUST be stored exclusively in macOS Keychain with appropriate access controls. The application MUST never store sensitive credentials in UserDefaults, plain text files, or unencrypted Core Data fields. Keychain items MUST use kSecAttrAccessibleWhenUnlockedThisDeviceOnly accessibility level.
* **MANDATORY:** **Australian Privacy Act Compliance.** The system MUST comply with Australian Privacy Principles (APPs) including obtaining explicit user consent before collecting financial data from external sources, providing clear privacy notices explaining data collection and usage, implementing data minimization practices (collecting only necessary information), enabling data portability through CSV/JSON export functionality, and providing account deletion capability that permanently removes all user data from the system and external services.

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
* **MANDATORY:** **WCAG 2.1 AA Accessibility Compliance.** The application MUST meet Web Content Accessibility Guidelines 2.1 Level AA standards for macOS applications including full VoiceOver screen reader support with descriptive labels for all interactive elements, complete keyboard navigation for all functions without requiring mouse/trackpad input, minimum 4.5:1 color contrast ratios between text and backgrounds in both light and dark modes, and dynamic type support respecting user font size preferences (system-wide accessibility settings).
* **MANDATORY:** **Australian Localization Standards.** The system MUST use Australian conventions throughout including date formatting (DD/MM/YYYY), currency display (AUD with dollar sign prefix and comma thousands separators: $1,234.56), number formatting with Australian decimal/grouping patterns, Australian English spelling and terminology, and GST-specific tax display formats. All financial calculations and displays MUST default to Australian Dollars (AUD) with proper locale-aware currency formatting.
* **MANDATORY:** **Keyboard Navigation Completeness.** Every user workflow MUST be completable using keyboard only without requiring mouse/trackpad interaction. The system MUST support standard macOS keyboard shortcuts (Cmd+N for new transaction, Cmd+F for search, Tab for field navigation, Enter for confirmation, Escape for cancel), provide visible keyboard focus indicators showing current selection, support arrow key navigation in all lists and tables, and enable Shift/Cmd-click multi-selection equivalent through keyboard (Space to select, Shift+arrows for range selection).

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

#### **3.1.7. Data Persistence & Core Data Schema (MVP)**

* **MANDATORY:** **Programmatic Core Data Model Definition.** The application MUST define all Core Data entities, attributes, relationships, and constraints programmatically within `PersistenceController.swift` without relying on `.xcdatamodeld` files. This ensures complete schema visibility in source control, enables programmatic schema evolution, and prevents build dependencies on Xcode's model compiler.
* **MANDATORY:** **Star Schema Database Architecture.** The database MUST implement a proper star schema with clearly defined fact tables (`transactions`, `line_items`, `line_item_splits`) and dimension tables (`entities`, `tax_categories`, `accounts`, `users`, `roles`). All relationships MUST be established through explicit foreign key references using Core Data's relationship system with appropriate delete rules (CASCADE for dependent data, NULLIFY for optional relationships).
* **MANDATORY:** **Seamless Data Migration.** The system MUST support automated Core Data migrations without data loss during application updates. When schema changes are required, the system MUST detect version mismatches, perform migrations transparently in the background, and validate data integrity post-migration. Users MUST never be required to manually export/import data or reset the application.

#### **3.1.8. Performance & Scalability Requirements (MVP)**

* **MANDATORY:** **5-Year Dataset Performance Standards.** The application MUST maintain responsive performance with 5 years of financial history (estimated 50,000+ transactions, 200,000+ line items). All primary operations MUST complete within strict time limits: transaction list loading <500ms, search results <300ms, filter application <200ms, dashboard calculations <1 second, regardless of dataset size.
* **MANDATORY:** **Memory Efficiency with Large Datasets.** The application MUST operate within 2GB memory limit during normal operations including loading, filtering, and analyzing 5 years of data. The system MUST implement lazy loading for large lists, background processing for data-intensive operations, and automatic memory cleanup to prevent system memory pressure warnings or application termination.
* **MANDATORY:** **Responsive Background Processing.** All long-running operations (5-year email synchronization, bulk bank transaction imports, batch extraction processing) MUST execute on background threads without blocking user interface interactions. Users MUST retain full application functionality during background operations, receive real-time progress updates with cancellation capability, and see immediate UI responsiveness for all interactive elements.

#### **3.1.9. Error Handling & System Resilience (MVP)**

* **MANDATORY:** **Comprehensive Error Recovery.** Every system operation (API calls, database queries, file operations, extraction processes) MUST include appropriate error handling with clear user-facing messages explaining the issue and next steps. The system MUST implement automatic retry logic with exponential backoff for transient failures (network timeouts, API rate limits) and provide manual retry options for persistent errors without requiring application restart.
* **MANDATORY:** **Offline Functionality.** The application MUST provide full read and edit functionality when network connectivity is unavailable including viewing all transactions, creating/editing/deleting entries, performing calculations, and accessing all historical data. The system MUST queue network-dependent operations (email synchronization, bank API calls, OAuth token refresh) for automatic execution when connectivity is restored and clearly indicate offline status and pending synchronizations in the user interface.
* **MANDATORY:** **Data Integrity Protection.** The system MUST prevent data loss under all failure scenarios including application crashes, forced quits, system shutdowns, and disk errors. All user edits MUST be persisted immediately to Core Data with appropriate save error handling. The application MUST implement automatic transaction rollback on save failures and provide clear feedback when data persistence issues occur without silently dropping user changes.

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
