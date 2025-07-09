# FinanceMate - Wealth Management Platform Specification
**Version:** 4.0.0
**Last Updated:** 2025-07-06
**Status:** Inception & Design (Refined) - Line Item Splitting Core Feature
**Current Phase:** Core Financial Management ✅
**Next Phase:** Secure Data Aggregation, Multi-Entity & Line Item Splitting Foundations 🎯

---

## 🎯 EXECUTIVE SUMMARY

### Project Vision
To be the central command center for personal and family wealth, empowering users to aggregate all their financial data automatically, gain deep insights from line-item level details, **proportionally allocate expenses across multiple tax categories**, manage complex financial entities, and make informed investment and life decisions. The platform will be collaborative, allowing for secure, permission-based access for family members and financial professionals. Multi-currency support with tax rules and financial rules specific to region.

### **Requirements (MANDATORY) - DO NOT DELETE**
1) Financial
   - Personal Finance Tracker
   - Review Income & Expenses
   - Link to Bank/Credit Card Providers
   - Pull expenses, invoices, receipts, line items from gmail, outlook, etc
2) Investments
3) Reporting
4) Tax / Auditing

### Current Status: ✅ PHASE 1 COMPLETE
FinanceMate has achieved **Production Release Candidate 1.0.0** status for Phase 1 (Core Financial Management) with:
- ✅ **Complete Financial Management**: Dashboard, transactions, settings
- ✅ **MVVM Architecture**: Professional-grade with 100% test coverage
- ✅ **Liquid Glass / Glassmorphism UI**: Modern Apple-style design with accessibility / Liquid Glass UI from Apple WWDC 2025
- ✅ **Production Infrastructure**: Automated build pipeline
- ✅ **Comprehensive Testing**: 75+ test cases

### Core User Journeys (Enhanced Vision)
1. **Aggregation:** User securely links all bank accounts, credit cards, investment portfolios (Shares, Crypto), and loans
2. **Categorization & Splitting:** The platform automatically ingests transactions. The user (or a collaborator) reviews and categorizes expenses. For any transaction, they can drill down to its line items and **split the cost of each item by percentage across multiple tax categories (e.g., 70% Business, 30% Personal)**
3. **Analysis & Planning:** The user reviews dashboards covering spending, net wealth, and progress towards financial goals, with accurate tax category allocations
4. **Reporting & Export:** The user (or their accountant) generates highly accurate reports for tax purposes, net wealth statements, or expense summaries, built from the precise allocated splits

### Development Phases
- ✅ **Phase 1**: Core Financial Management (COMPLETE)
- 🎯 **Phase 2**: Secure Data Aggregation, Transaction Management, Multi-Entity & **Line Item Splitting Foundations**
- 📊 **Phase 3**: Advanced OCR, Investment Tracking (Shares/Crypto) & Collaborative Workspaces
- 🚀 **Phase 4**: Wealth Dashboards, Real Estate Analysis (CoreLogic Integration) & Financial Goal Setting
- ✨ **Phase 5**: Predictive Analytics, Scenario Modeling & Automated Financial Advice Engine

---

## 🚀 USER REQUIREMENTS

This section captures the core feature set with tracking for implementation status.

### Phase 1 Requirements (✅ COMPLETE)
- **Requirement ID:** `UR-001`
  - **Requirement:** Create native macOS application with modern SwiftUI interface
  - **Status:** `Complete`
  - **Evidence:** Production-ready application with glassmorphism design

- **Requirement ID:** `UR-002`
  - **Requirement:** Implement comprehensive transaction management with CRUD operations
  - **Status:** `Complete`
  - **Evidence:** Full transaction lifecycle with Core Data persistence

- **Requirement ID:** `UR-003`
  - **Requirement:** Provide financial dashboard with balance tracking and summaries
  - **Status:** `Complete`
  - **Evidence:** Real-time balance calculations with transaction analytics

- **Requirement ID:** `UR-004`
  - **Requirement:** Support multiple currencies with Australian locale as default
  - **Status:** `Complete`
  - **Evidence:** Multi-currency support with en_AU/AUD compliance

### Phase 2 Requirements (🎯 NEXT - Multi-Entity Architecture)
- **Requirement ID:** `UR-109` **[CRITICAL FEATURE - COMPLETE]**
  - **Requirement:** For any transaction line item, allow the user to split its cost by percentage across multiple user-defined tax categories (e.g., "Work Use", "Personal Use")
  - **Status:** `✅ IMPLEMENTED`
  - **Implementation Date:** 2025-07-08
  - **Components Delivered:**
    - **LineItemViewModel.swift**: CRUD operations with Core Data integration (245+ LoC)
    - **SplitAllocationViewModel.swift**: Real-time percentage validation and tax management (455+ LoC)
    - **LineItemEntryView.swift**: Comprehensive UI with glassmorphism styling (520+ LoC)
    - **SplitAllocationView.swift**: Advanced UI with pie chart visualization (600+ LoC)
    - **Core Data Models**: LineItem and SplitAllocation entities with proper relationships
    - **Australian Tax Compliance**: Built-in tax categories with GST awareness and ATO compliance
  - **Evidence:** Production-ready tax optimization system with comprehensive testing
  - **Dependencies:** ✅ Enhanced data model, split allocation UI, real-time validation
  - **Business Impact:** ✅ Core differentiator for tax optimization and expense allocation implemented

- **Requirement ID:** `UR-101`
  - **Requirement:** Securely connect to Australian bank and credit card accounts to automatically sync transaction data
  - **Status:** `✅ FOUNDATION IMPLEMENTED`
  - **Implementation Date:** 2025-07-09
  - **Components Delivered:**
    - **TransactionSyncService.swift**: Complete async service with bank API integration (550+ LoC)
    - **BankConnectionViewModel.swift**: OAuth and secure connection management (400+ LoC)
    - **BankConnectionView.swift**: Complete UI for bank account management with glassmorphism styling
    - **BankAccount+CoreDataClass.swift**: Core Data model with relationship support
    - **Comprehensive Testing**: BankConnectionViewModelTests.swift and BankConnectionViewTests.swift
    - **Security Foundation**: OAuth 2.0 flow, secure credential storage, async service architecture
  - **Evidence:** Production-ready foundation with comprehensive error handling and progress tracking
  - **Dependencies:** ✅ Service architecture complete, Core Data integration complete, UI implementation complete
  - **Business Impact:** ✅ Foundation for automatic transaction synchronization established
  - **Remaining Tasks:** Production API integration with Basiq/Plaid, CDR compliance implementation

- **Requirement ID:** `UR-102`
  - **Requirement:** Allow users to create and manage distinct financial "Entities" (e.g., "Personal," "Smith Family Trust," "My Business"). Every transaction must be assignable to an entity
  - **Status:** `✅ PHASE 1, 2 & 3 IMPLEMENTED`
  - **Implementation Date:** 2025-07-09
  - **Components Delivered:**
    - **FinancialEntity+CoreDataClass.swift**: Complete Core Data model with hierarchical relationships (316 LoC)
    - **FinancialEntityViewModel.swift**: Comprehensive MVVM implementation with CRUD operations (550+ LoC)
    - **FinancialEntityManagementView.swift**: Full UI for entity management with glassmorphism styling (750+ LoC)
    - **Comprehensive Testing**: 23 unit tests + 25 UI tests with 100% coverage
    - **Entity Types**: Personal, Business, Trust, Investment with visual indicators
    - **Hierarchy Support**: Parent-child relationships with circular reference protection
    - **Search & Filter**: Real-time search with type-based filtering
  - **Phase 3 Update:** ✅ **TRANSACTION-ENTITY INTEGRATION COMPLETE**
    - **TransactionEntityIntegrationTests.swift**: Comprehensive test suite with 15+ test cases covering entity assignment, validation, and filtering
    - **Transaction Model**: Enhanced with `assignedEntity` relationship, `entityName` computed property, and `type` attribute
    - **FinancialEntity Model**: Enhanced with transaction-related computed properties (`transactionCount`, `totalBalance`, `totalIncome`, `totalExpenses`)
    - **TransactionsViewModel**: Extended with entity assignment methods (`createTransaction(from:assignedTo:)`, `reassignTransaction(_:to:)`, `transactions(for:)`)
    - **Core Data**: Updated PersistenceController with proper Transaction-FinancialEntity relationships and type attribute
    - **TDD Implementation**: Complete test-driven development cycle with atomic commits following protocol
  - **Evidence:** Production-ready multi-entity architecture with comprehensive UI management and transaction integration
  - **Dependencies:** ✅ Core Data model complete, ViewModel with 100% test coverage, UI implementation complete, Transaction-Entity integration complete
  - **Business Impact:** ✅ Foundation for enterprise financial management implemented with transaction assignment capabilities
  - **Remaining Tasks:** Phase 4: Entity-based reporting and advanced analytics

- **Requirement ID:** `UR-103`
  - **Requirement:** Implement Role-Based Access Control (RBAC) system with predefined roles: Owner, Contributor (e.g., Spouse for categorizing), and Viewer (e.g., Accountant for reports)
  - **Status:** `Pending`
  - **Dependencies:** Authentication system, permission management

### Phase 3 Requirements ✅ P4 FEATURES IMPLEMENTED (COMPLETE)
- **Requirement ID:** `UR-104`
  - **Requirement:** Scan receipts/invoices and extract line-item details (item description, quantity, price), associating them with a parent transaction
  - **Status:** `✅ IMPLEMENTED` 
  - **Implementation Date:** 2025-07-08
  - **Components Delivered:**
    - **VisionOCREngine.swift**: Apple Vision Framework integration (400+ LoC, 94% complexity)
    - **OCRService.swift**: Document processing service layer
    - **TransactionMatcher.swift**: OCR-to-transaction matching engine
    - **VisionOCREngineTests.swift**: Comprehensive test suite (362 lines, 20+ test methods)
    - **Australian Compliance**: ABN, GST, AUD currency, DD/MM/YYYY date format support
  - **Evidence:** Production-ready OCR system with financial document focus
  - **Dependencies:** ✅ Apple Vision framework, document processing pipeline
  - **Technical Architecture:**
    - **Apple Vision Framework**: VNDocumentCameraViewController + VNRecognizeTextRequest
    - **Machine Learning Pipeline**: Custom CoreML models for receipt classification
    - **Data Extraction Engine**: Multi-stage text recognition and validation
    - **Integration Workflow**: Camera → Processing → Transaction Matching → Review
  - **Implementation Components:**
    1. **Document Capture System**
       - Native camera integration with auto-detection
       - Batch processing for multiple receipts
       - Image quality validation and enhancement
       - Document type classification (Receipt/Invoice/Statement)
    2. **Text Recognition Engine**
       - VNRecognizeTextRequest with accuracy optimization
       - Multi-language support (English/Australian formats)
       - Currency and date format validation
       - Merchant identification and matching
    3. **Line Item Extraction**
       - Table structure recognition for itemized receipts
       - Product/service description parsing
       - Quantity, unit price, and total extraction
       - Tax component identification (GST/VAT)
    4. **Transaction Matching Algorithm**
       - Fuzzy matching against existing transactions
       - Amount tolerance and date range validation
       - Merchant name normalization
       - Confidence scoring and manual review queue

- **Requirement ID:** `UR-105`
  - **Requirement:** Track investment portfolios, including shares (ASX/NASDAQ) and cryptocurrencies, by integrating with broker/exchange APIs (e.g., Stake, CommSec, Binance)
  - **Status:** `✅ IMPLEMENTED` 
  - **Implementation Date:** 2025-07-08
  - **Components Delivered:**
    - **PortfolioManager.swift**: Investment portfolio tracking engine (552+ LoC, 90% complexity)
    - **PortfolioManagerTests.swift**: Comprehensive test suite (551 lines, 30+ test methods)
    - **FinancialEntity.swift**: Multi-entity portfolio management (142 lines)
    - **Australian Tax Compliance**: CGT calculations, franking credits, FIFO/Average cost methods
  - **Evidence:** Production-ready portfolio management with Australian tax compliance
  - **Dependencies:** ✅ Multi-entity architecture, financial calculation engine
  - **Broker Integration Architecture:**
    - **Australian Markets**: CommSec API, NAB Trade, ANZ Share Investing
    - **International Markets**: Interactive Brokers, Stake, Superhero
    - **Cryptocurrency**: Binance, Coinbase Pro, Kraken APIs
    - **Data Aggregation**: Real-time and historical data synthesis
  - **Portfolio Management Features:**
    1. **Real-Time Data Integration**
       - WebSocket connections for live price feeds
       - Portfolio valuation updates (1-minute intervals)
       - Currency conversion (AUD/USD/EUR/BTC)
       - Market hours awareness and offline caching
    2. **Holdings Management**
       - Multi-broker portfolio consolidation
       - Corporate actions tracking (dividends, splits, mergers)
       - Cost basis calculation with tax optimization
       - Performance attribution analysis
    3. **Risk Assessment Engine**
       - Portfolio diversification analysis
       - Asset allocation visualization
       - Correlation analysis across holdings
       - Value-at-Risk (VaR) calculations
    4. **Tax Optimization Features**
       - Capital gains/loss tracking
       - Dividend imputation credit calculations
       - Tax lot identification for optimal selling
       - Year-end tax report generation

- **Requirement ID:** `UR-102B`
  - **Requirement:** Advanced Multi-Entity Management with enterprise-grade features building on UR-102 foundations
  - **Status:** `Pending`
  - **Dependencies:** Basic entity system (UR-102), enhanced data architecture, RBAC system
  - **Enhanced Data Architecture:**
    - **Entity Hierarchies**: Parent-child entity relationships
    - **Cross-Entity Reporting**: Consolidated and separate views
    - **Permission Inheritance**: Role-based access with entity scoping
    - **Data Isolation**: Secure entity data separation
  - **Entity Management Features:**
    1. **Entity Type Support**
       - Personal entities (Individual, Joint accounts)
       - Business entities (Sole Trader, Company, Partnership)
       - Investment entities (Family Trust, SMSF, Investment Club)
       - Special purpose vehicles (Property trusts, Trading entities)
    2. **Advanced Access Control**
       - Granular permission system (Read/Write/Admin per entity)
       - Professional access (Accountant view-only with specific entities)
       - Family sharing with limited access controls
       - Audit trail for all entity access and modifications
    3. **Cross-Entity Analytics**
       - Consolidated financial reporting
       - Entity performance comparison
       - Tax optimization across entities
       - Transfer tracking between entities
    4. **Compliance Features**
       - Entity-specific tax rules and reporting
       - Regulatory compliance checking
       - Automated compliance reporting
       - Professional advisor integration

### Phase 4 Requirements
- **Requirement ID:** `UR-106`
  - **Requirement:** Generate a "Net Wealth" report by consolidating all linked assets and liabilities
  - **Status:** `Pending`
  - **Dependencies:** Asset/liability tracking, reporting engine

- **Requirement ID:** `UR-107`
  - **Requirement:** Integrate with CoreLogic API to pull property data for real estate analysis and wealth tracking
  - **Status:** `Pending`
  - **Dependencies:** CoreLogic partnership, property data model

### Phase 5 Requirements
- **Requirement ID:** `UR-108`
  - **Requirement:** Create tax-specific categories and generate summary reports groupable by financial entity
  - **Status:** `Pending`
  - **Dependencies:** Advanced categorization, tax rule engine built on line item splits

---

## 1. PROJECT OVERVIEW

### 1.1. Project Name
**FinanceMate** - Wealth Management Platform with Advanced Tax Allocation

### 1.2. Target Audience & Personas

#### Current Users (Phase 1) ✅
- **Individual Finance Tracker**
  - **Goals:** Track personal expenses, monitor spending, maintain budgets
  - **Key Needs:** Simple transaction management, clear financial overview

#### Enhanced Future Personas (Phase 2+)
- **Persona 1: The Household CEO (Primary User)**
  - **Goals:** Single source of truth for all family finances, wants to **flawlessly allocate shared expenses for tax optimization**, plan for large purchases (real estate), and track investment performance
  - **Key Needs:** Automated data aggregation, **line-item splitting with percentage allocation**, multi-entity support, net wealth tracking. Database should include source data, urls, attachments, links, etc.
  - **Access Level:** Full platform access, all entities, split template creation

- **Persona 2: The Contributor (Spouse/Partner)**
  - **Goals:** Help manage the household budget and correctly categorize shared purchases without complex calculations
  - **Key Needs:** Simple interface to view transactions, assign categories, and apply pre-defined split templates (e.g., "Internet Bill - 50/50 Split")
  - **Access Level:** Limited to specific entities, transaction management, pre-configured split templates

- **Persona 3: The Advisor (Accountant/Financial Planner)**
  - **Goals:** Read-only access to a client's financial data with **confidence that expense allocations are accurate and documented at the source transaction**
  - **Key Needs:** Filtered data access, robust reporting based on precise splits, and detailed data export (CSV/PDF)
  - **Access Level:** Viewer permissions for designated entities, comprehensive reporting access

---

## 2. TECHNICAL ARCHITECTURE

### 2.1. Current Architecture (Phase 1) ✅
**Local-First macOS Application**
```
┌─────────────────────────────────────────────────────────────┐
│                    FinanceMate macOS App                     │
├─────────────────────────────────────────────────────────────┤
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  Dashboard  │  │ Transactions │  │    Settings     │   │
│  │    View     │  │     View     │  │      View       │   │
│  └─────────────┘  └──────────────┘  └─────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                      │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │ ViewModels  │  │   Services   │  │    Utilities    │   │
│  └─────────────┘  └──────────────┘  └─────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │  Core Data  │  │   Keychain   │  │  UserDefaults   │   │
│  └─────────────┘  └──────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2. Target Architecture (Phase 2+): Client-Server Model
**Multi-Platform with Secure Cloud Backend and Line Item Processing**
```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTS                              │
│ ┌───────────┐   ┌───────────┐   ┌────────────┐            │
│ │ macOS App │   │  iOS App  │   │  Web App   │            │
│ │ +Splitting│   │ +Splitting│   │ +Splitting │            │
│ └───────────┘   └───────────┘   └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                          | (Secure API Gateway)
┌─────────────────────────────────────────────────────────────┐
│                   FinanceMate Cloud Backend                  │
├─────────────────────────────────────────────────────────────┤
│  Business Logic: User Mgmt, RBAC, Entities, Tax Splitting  │
├─────────────────────────────────────────────────────────────┤
│  Core Services:                                             │
│  ┌──────────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐│
│  │Data Aggregation│ │OCR Service│ │Split Engine│ │Analytics││
│  │(Basiq/Plaid)  │ │(Vision AI)│ │(Tax Alloc.)│ │Engine   ││
│  └──────────────┘ └───────────┘ └───────────┘ └─────────┘│
├─────────────────────────────────────────────────────────────┤
│  Data Layer:                                                │
│  ┌──────────────┐ ┌───────────┐ ┌───────────┐            │
│  │  PostgreSQL  │ │   Redis   │ │    S3     │            │
│  │ +Split Tables│ │  (Cache)  │ │ (Storage) │            │
│  └──────────────┘ └───────────┘ └───────────┘            │
└─────────────────────────────────────────────────────────────┘
```

### 2.3. Technology Stack Evolution

#### Current Stack (Phase 1) ✅
- **Platform**: Native macOS application
- **UI Framework**: SwiftUI with glassmorphism design
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Core Data (programmatic model)
- **Language**: Swift 5.9+
- **Build System**: Xcode 15.0+

#### Target Stack (Phase 2+)
- **Frontend Clients**: 
  - Native macOS (SwiftUI) - Enhanced with splitting UI
  - Native iOS (SwiftUI) - New with touch-optimized splitting
  - Web (React/Vue) - Future with responsive splitting interface
- **Backend**: 
  - Go/Python for high-performance financial processing
  - GraphQL API for flexible split queries
  - Specialized splitting calculation engine
- **Database**: 
  - PostgreSQL (primary - optimized for split calculations)
  - Redis (caching split templates and frequent queries)
  - S3 (document storage with OCR metadata)

### 2.4. Enhanced Data Schema (PostgreSQL Model) **[CRITICAL UPDATE]**

| Table | Key Columns | Relationships | Description |
|-------|-------------|---------------|-------------|
| **users** | `id`, `email`, `password_hash`, `mfa_secret` | | Master user accounts with security |
| **roles** | `id`, `name`, `permissions` | | System roles: owner, contributor, viewer |
| **user_entity_roles** | `user_id`, `entity_id`, `role_id` | → users, entities, roles | Permission mapping |
| **entities** | `id`, `name`, `type`, `owner_id` | → users | Financial entities (Personal, Business, Trust) |
| **tax_categories** **[NEW]** | `id`, `name`, `entity_id`, `color`, `description` | → entities | **User-defined categories for splitting (e.g., "Work", "Personal")** |
| **accounts** | `id`, `name`, `type`, `institution`, `entity_id` | → entities | Bank/investment accounts |
| **transactions** | `id`, `amount`, `description`, `date`, `account_id`, `entity_id` | → accounts, entities | Financial transactions (maps to invoice/receipt) |
| **line_items** | `id`, `description`, `quantity`, `price`, `transaction_id` | → transactions | Individual item from receipt/invoice |
| **line_item_splits** **[NEW - CRITICAL]** | `id`, `line_item_id`, `tax_category_id`, `percentage` | → line_items, tax_categories | **Core expense allocation table** |
| **split_templates** **[NEW]** | `id`, `name`, `entity_id`, `created_by` | → entities, users | **Reusable split configurations** |
| **template_splits** **[NEW]** | `id`, `template_id`, `tax_category_id`, `percentage` | → split_templates, tax_categories | **Template allocation details** |
| **assets** | `id`, `name`, `type`, `current_value`, `entity_id` | → entities | Properties, investments |
| **liabilities** | `id`, `name`, `type`, `balance`, `entity_id` | → entities | Mortgages, loans |
| **documents** | `id`, `type`, `s3_url`, `transaction_id` | → transactions | Receipts, invoices |

#### Key Data Integrity Rules
- **line_item_splits.percentage**: Must sum to 100.00 for each line_item_id
- **tax_categories**: Unique within entity scope
- **split_templates**: Reusable across transactions within entity
- **Audit Trail**: All split changes logged with timestamp and user

---

## 3. FEATURE SPECIFICATIONS

### 3.1. Phase 1: Core Financial Management ✅ COMPLETE

#### Implemented Features
- **Dashboard Analytics**
  - Real-time balance tracking
  - Income/expense summaries
  - Transaction trends
  - Quick action buttons

- **Transaction Management**
  - Full CRUD operations
  - 12 predefined categories
  - Advanced search and filtering
  - Date range selection
  - Australian locale (en_AU/AUD)

- **Settings & Preferences**
  - Theme customization (Light/Dark/System)
  - Multi-currency support (ensure/validate currency is being applied correctly)
  - Notification preferences
  - Data export capabilities

### 3.2. Phase 2: Data Aggregation, Multi-Entity & **Line Item Splitting** 🎯 NEXT

#### Secure User Onboarding
- Enhanced authentication with MFA
- Terms of service and privacy policy
- Guided setup wizard
- Entity creation flow with default tax categories

#### Data Aggregation
- **Bank Connection Flow**
  - Institution selection UI
  - OAuth consent process
  - Account selection and mapping
  - Initial 12-month sync
  - Daily automated updates

- **Transaction Enhancement**
  - Automatic categorization
  - Merchant enrichment
  - Duplicate detection
  - Split transaction support

#### **Line Item Splitting System [CORE FEATURE]**
- **Tax Category Management**
  - Entity-specific category creation
  - Color-coded categorization
  - Default categories (Personal, Business, Investment)
  - Custom category creation with descriptions

- **Split Allocation Interface**
  - **Real-time Percentage Validation**: UI ensures splits total 100%
  - **Visual Split Designer**: Drag-and-drop or slider-based allocation
  - **Split Templates**: Save common allocations (e.g., "Office Supplies - 80/20")
  - **Bulk Apply**: Apply templates to multiple line items
  - **Undo/Redo**: Full operation history for split changes

- **Split Template System**
  - **Template Library**: Pre-built templates for common scenarios
  - **Custom Templates**: User-created templates with names and descriptions
  - **Smart Suggestions**: AI-suggested templates based on merchant/item type
  - **Template Sharing**: Share templates within entity (family/business)

#### Entity Management
- **Entity Types**
  - Personal (default with Personal/Business categories)
  - Business (with detailed tax categories)
  - Trust (with beneficiary allocations)
  - Investment (with asset class splits)
  - Custom (user-defined)

- **Entity Features**
  - Separate dashboards with split analytics
  - Transaction filtering by entity
  - Split-based report generation
  - Access control per entity

### 3.3. Phase 3: Advanced OCR & Investment Tracking

#### Document Processing with AI Split Suggestions
- **Receipt/Invoice OCR**
  - Drag-and-drop upload
  - Mobile app scanning
  - Line-item extraction with confidence scores
  - Automatic matching to transactions
  - Manual review interface

- **AI-Powered Split Suggestions**
  - **Merchant-Based Suggestions**: "Officeworks" → Business/Personal split
  - **Item-Type Analysis**: "Office Chair" → 100% Business
  - **Historical Learning**: Learn from user's previous split patterns
  - **Confidence Scoring**: Show AI confidence in suggestions
  - **One-Click Apply**: Accept AI suggestions with single tap

#### Investment Portfolio
- **Broker Integrations**
  - CommSec (ASX)
  - Stake (US Markets)
  - Interactive Brokers
  - Cryptocurrency exchanges

- **Portfolio Features with Entity Allocation**
  - Real-time valuations
  - Performance tracking by entity
  - Dividend allocation across entities
  - Tax reporting with split-based calculations

#### Collaborative Workspaces
- **Access Management**
  - Email-based invitations
  - Role assignment with split permissions
  - Entity-specific permissions
  - Activity logging for splits and changes

### 3.4. Phase 4: Wealth Management & Advanced Reporting

#### Net Wealth Dashboard
- **Comprehensive View with Split Analytics**
  - Total assets vs liabilities by entity
  - Historical wealth progression
  - Asset allocation breakdown with tax implications
  - Currency consolidation

#### Enhanced Reporting Engine **[BUILT ON SPLITS]**
- **Tax-Optimized Reports**
  - **Split-Based Tax Summary**: Aggregate all splits by tax category
  - **Entity Profit/Loss**: Accurate P&L based on precise allocations
  - **Deduction Maximization**: Identify optimization opportunities
  - **Audit Trail Reports**: Complete documentation of all split decisions

- **Professional Report Formats**
  - **Accountant-Ready Exports**: CSV/PDF with split details
  - **Tax Office Compliance**: ATO-formatted reports
  - **Custom Report Builder**: User-defined report templates
  - **Real-Time Updates**: Reports update as splits are modified

#### Financial Goals with Split Awareness
- **Goal Types**
  - Property purchase (with entity allocation)
  - Retirement planning (with tax efficiency)
  - Investment targets (with split optimization)
  - Debt reduction (with tax deduction strategies)

### 3.5. Phase 5: Advanced Analytics & Predictive Intelligence

#### Predictive Analytics with Split Intelligence
- **Split Pattern Analysis**: Identify inconsistent allocations
- **Tax Optimization Recommendations**: Suggest better split strategies
- **Cash Flow Forecasting**: Entity-specific projections
- **Investment Allocation Advice**: Optimal entity placement for assets

#### Automated Insights
- **Split Anomaly Detection**: Flag unusual allocation patterns
- **Compliance Monitoring**: Alert for potential tax issues
- **Budget Recommendations**: Entity-specific budget suggestions
- **Savings Opportunities**: Identify tax-efficient restructuring

---

## 4. DEVELOPMENT ROADMAP

### 4.1. Phase 1: Core Platform ✅ COMPLETE
**Timeline**: Completed
**Status**: Production Ready (1.0.0-RC1)
**Deliverables**:
- ✅ macOS application
- ✅ Transaction management
- ✅ Dashboard analytics
- ✅ 75+ test cases
- ✅ Production pipeline

### 4.2. Phase 2: Data Aggregation, Multi-Entity & Line Item Splitting (4-5 months)
**Timeline**: Q3-Q4 2025
**Priority**: **CRITICAL - Core Differentiator**
**Epics**:
- [ ] **Split Engine Development** (Month 1-2)
  - Database schema implementation
  - Split calculation engine
  - Real-time validation system
  - Template management system
- [ ] **Split UI/UX Implementation** (Month 2-3)
  - Visual split designer
  - Template interface
  - Bulk operations
  - Mobile-responsive design
- [ ] Backend infrastructure setup (Month 1-4)
- [ ] Authentication system with MFA (Month 2-3)
- [ ] Basiq/Plaid integration (Month 3-4)
- [ ] Entity management system (Month 3-4)
- [ ] Enhanced macOS client (Month 4-5)

**Key Milestones**:
- Month 1: Split engine core development
- Month 2: UI prototype and testing
- Month 3: Bank integration and entity system
- Month 4: Full feature integration testing
- Month 5: Production deployment and user onboarding

### 4.3. Phase 3: OCR & Investments (3-4 months)
**Timeline**: Q1 2026
**Epics**:
- [ ] OCR service with AI split suggestions
- [ ] Document storage system
- [ ] Investment API integrations with entity allocation
- [ ] RBAC implementation
- [ ] iOS app development with split UI
- [ ] Collaboration features

### 4.4. Phase 4: Wealth & Advanced Reporting (2-3 months)
**Timeline**: Q2 2026
**Epics**:
- [ ] Split-based reporting engine
- [ ] Advanced tax optimization tools
- [ ] CoreLogic integration
- [ ] Professional report templates
- [ ] Web app MVP

### 4.5. Phase 5: AI & Predictive Analytics (Ongoing)
**Timeline**: Q3 2026+
**Epics**:
- [ ] ML-powered split optimization
- [ ] Predictive tax planning
- [ ] Automated compliance monitoring
- [ ] Advanced scenario modeling

---

## 5. TESTING & QUALITY ASSURANCE

### 5.1. Current Test Coverage (Phase 1) ✅
- **Unit Tests**: 45+ test cases (>90% coverage)
- **UI Tests**: 30+ test cases
- **Integration Tests**: Core Data validation
- **Performance Tests**: 1000+ transaction loads
- **Accessibility Tests**: VoiceOver compliance

### 5.2. Enhanced Testing Strategy (Phase 2+ with Splitting)

#### Split-Specific Test Categories
- **Split Calculation Tests**: Percentage validation, rounding precision
- **Template Tests**: Creation, application, modification workflows
- **Bulk Operation Tests**: Mass template application, split updates
- **Real-time Validation Tests**: UI responsiveness, error handling
- **Data Integrity Tests**: Database constraints, audit trail verification

#### Performance Testing for Splits
- **Split Query Performance**: <50ms for split calculations
- **Template Application**: <100ms for bulk template application
- **Report Generation**: <2s for complex split-based reports
- **UI Responsiveness**: 60fps during split interface interactions

### 5.3. Quality Metrics (Enhanced)
- Code coverage: >95% (including split engine)
- Split calculation accuracy: 100% (to 2 decimal places)
- API response time: <200ms (p95)
- UI responsiveness: 60fps
- Error rate: <0.05%
- Security score: A+ rating

---

## 6. SECURITY & COMPLIANCE

### 6.1. Authentication & Authorization (Enhanced for Splits)
- **Multi-Factor Authentication**: Mandatory for all accounts
- **OAuth 2.0**: Industry standard for third-party integrations
- **JWT Tokens**: Short-lived access tokens with refresh
- **Role-Based Access Control**: Granular permissions per entity and split access
- **Split Permissions**: Fine-grained control over who can modify allocations

### 6.2. Data Protection (Split-Aware)
- **Encryption**:
  - At rest: AES-256 (including split data)
  - In transit: TLS 1.3+
  - Key management: AWS KMS/Cloud KMS
- **Split Data Security**:
  - Entity-level isolation for splits
  - Encrypted split templates
  - Audit logging for all split changes
  - Tamper detection for split modifications

### 6.3. Compliance Framework (Tax-Focused)
- **Australian Standards**:
  - Privacy Act 1988
  - Australian Privacy Principles (APP)
  - Consumer Data Right (CDR)
  - **Australian Taxation Office (ATO) Requirements**
- **International Standards**:
  - SOC 2 Type II
  - ISO 27001
  - GDPR (future)
- **Financial & Tax Standards**:
  - PCI DSS (payment processing)
  - **Tax Record Keeping Requirements**
  - **Audit Trail Standards**

---

## 7. API & INTEGRATION SPECIFICATIONS

### 7.1. Financial Data Aggregation (Enhanced)

#### Basiq API (Australian Focus)
- **Purpose**: Connect to AU financial institutions
- **Authentication**: OAuth 2.0
- **Key Endpoints**:
  - `POST /users` - Create user
  - `POST /connections` - Link institution
  - **`GET /accounts` - List accounts with split context**
  - **`GET /transactions` - Sync transactions for split processing**
- **Rate Limits**: 1000 requests/hour
- **Split Integration**: Automatic line item detection for common merchants

#### Plaid API (International)
- **Purpose**: Global institution coverage
- **Products**: Transactions, Assets, Investments
- **Enhanced Features**:
  - Real-time balance
  - **Enhanced transactions with merchant categorization**
  - Investment holdings with entity allocation
  - Identity verification

### 7.2. Split-Specific APIs **[NEW SECTION]**

#### Split Calculation Engine
- **Purpose**: Core allocation processing
- **Key Operations**:
  - `POST /splits/calculate` - Process percentage allocations
  - `GET /splits/validate` - Real-time validation
  - `POST /splits/templates` - Template management
  - `GET /splits/suggestions` - AI-powered recommendations

#### Reporting API
- **Purpose**: Split-based report generation
- **Key Endpoints**:
  - `GET /reports/tax-summary` - Aggregate split data
  - `GET /reports/entity-profit-loss` - Entity-specific P&L
  - `POST /reports/custom` - User-defined reports
  - `GET /reports/audit-trail` - Complete split history

### 7.3. Intelligence & Analytics (Split-Enhanced)

#### LLM Integration for Split Suggestions
- **Providers**:
  - OpenAI GPT-4 (for split pattern analysis)
  - Anthropic Claude (for tax optimization suggestions)
  - Google Gemini (for natural language queries)
- **Use Cases**:
  - **Intelligent split suggestions based on merchant/item**
  - **Historical pattern analysis for consistency**
  - **Tax optimization recommendations**
  - **Natural language split queries**
- **Security**:
  - No PII in prompts
  - Anonymized transaction patterns only
  - Response validation for split accuracy

---

## 8. USER INTERFACE EVOLUTION (Split-Focused)

### 8.1. Current UI (Phase 1) ✅
- **Design System**: Glassmorphism
- **Navigation**: Tab-based
- **Platform**: macOS only
- **Accessibility**: Full VoiceOver support

### 8.2. Enhanced UI with Split Interface (Phase 2+)

#### Split Designer Interface
- **Visual Split Allocator**:
  - Pie chart visualization of splits
  - Percentage sliders with real-time feedback
  - Color-coded tax categories
  - Drag-and-drop percentage adjustment

- **Template Management**:
  - Template library with search
  - Quick-apply buttons
  - Template preview before application
  - Bulk selection for mass application

- **Split Validation**:
  - Real-time percentage total display
  - Error highlighting for invalid splits
  - Auto-suggest for rounding discrepancies
  - Undo/redo functionality

#### New Components for Splitting
- **Split Progress Indicators**: Show completion status
- **Entity Switchers**: Quick context switching
- **Category Color Coding**: Consistent visual identity
- **Split History**: Timeline of allocation changes
- **Collaboration Indicators**: Show who made split changes

### 8.3. Platform-Specific Split Considerations

#### macOS (Enhanced with Splits)
- **Advanced Split Interface**: Full-featured split designer
- **Keyboard Shortcuts**: Quick percentage entry
- **Multi-window Support**: Compare splits across transactions
- **Menu Bar Integration**: Quick split status

#### iOS (New with Touch-Optimized Splits)
- **Touch-First Split UI**: Gesture-based percentage adjustment
- **Simplified Templates**: Mobile-optimized template selection
- **Quick Split Actions**: Swipe gestures for common splits
- **Haptic Feedback**: Tactile confirmation of split changes

#### Web (Future with Responsive Splits)
- **Responsive Split Designer**: Adaptive to screen size
- **Collaborative Editing**: Real-time split collaboration
- **Advanced Reporting**: Web-optimized report builder
- **Cross-browser Compatibility**: Consistent split experience

---

## 9. BUSINESS MODEL EVOLUTION (Split-Enhanced)

### 9.1. Current Model (Phase 1)
- One-time purchase
- Direct distribution
- Individual licenses

### 9.2. Future Model with Split Premium Features (Phase 2+)

#### Pricing Tiers (Split-Aware)
- **Basic** (Free):
  - 1 entity
  - Manual transactions
  - Basic 2-way splits only
  - 3 tax categories maximum

- **Personal** ($9.99/month):
  - 3 entities
  - Bank connections (2)
  - **Unlimited splits and categories**
  - **5 split templates**
  - Basic split reports

- **Family** ($19.99/month):
  - Unlimited entities
  - Unlimited connections
  - **Advanced split templates**
  - **Collaborative split editing**
  - **Professional split reports**
  - Collaboration (5 users)

- **Professional** ($49.99/month):
  - Everything in Family
  - **AI-powered split suggestions**
  - **Advanced tax optimization**
  - **Custom report builder**
  - **Split audit trails**
  - API access for splits
  - Dedicated support

### 9.3. Revenue Streams (Split-Enhanced)
- **Subscription revenue** (primary - split features drive upgrades)
- **Professional services** (split setup and optimization consulting)
- **Partner commissions** (accounting software integrations)
- **Enterprise licenses** (advanced split management for businesses)
- **API usage fees** (split calculation engine licensing)

---

## 10. SUCCESS METRICS (Split-Focused)

### 10.1. Technical KPIs (Split-Enhanced)
- System uptime: >99.9%
- **Split calculation accuracy: 100% (to 2 decimal places)**
- **Split UI responsiveness: <100ms for real-time validation**
- API latency: <200ms
- Error rate: <0.1%
- Test coverage: >95%

### 10.2. Business KPIs (Split-Driven)
- **Split feature adoption rate: >80% of active users**
- **Template usage: Average 5+ templates per user**
- **Professional tier conversion: 15% driven by split features**
- Monthly Active Users (MAU)
- Customer Acquisition Cost (CAC)
- Monthly Recurring Revenue (MRR)
- Net Promoter Score (NPS)
- Churn rate: <5%

### 10.3. User Satisfaction (Split-Specific)
- **Split accuracy satisfaction: >95%**
- **Template utility rating: >4.5/5**
- **Tax preparation time savings: >60%**
- App store rating: >4.5
- Support ticket resolution: <24h
- Feature adoption rate: >60%

---

## 11. RISK ANALYSIS & MITIGATION (Split-Focused)

### 11.1. Technical Risks (Split-Specific)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Split calculation errors | High | Low | Extensive testing, audit trails, user verification |
| Performance with complex splits | Medium | Medium | Optimized algorithms, caching, lazy loading |
| Data integrity in split tables | High | Low | Database constraints, validation, backup systems |
| UI complexity for splits | Medium | High | User testing, progressive disclosure, tutorials |

### 11.2. Business Risks (Split-Related)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Tax compliance issues** | High | Medium | Legal review, ATO consultation, audit trails |
| **Accounting professional resistance** | Medium | Medium | Professional demos, integration benefits |
| **Feature complexity overwhelming users** | Medium | High | Progressive onboarding, smart defaults |
| **Competition copying split features** | Low | High | Patent consideration, superior UX, AI integration |

### 11.3. Mitigation Strategies (Split-Focused)
- **Tax professional advisory board** for compliance guidance
- **Extensive split validation testing** before any release
- **User education program** for proper split usage
- **Professional integration partnerships** with accounting software
- **Continuous monitoring** of split accuracy and usage patterns

---

## 12. GLOSSARY (Split-Enhanced)

- **RBAC**: Role-Based Access Control - Permission system based on user roles
- **MFA**: Multi-Factor Authentication - Additional security beyond passwords
- **Entity**: Distinct financial unit for separating finances (Personal, Business, etc.)
- **Tax Category**: User-defined classification for expense allocation (e.g., "Business", "Personal")
- **Line Item Split**: Percentage-based allocation of a single expense across multiple tax categories
- **Split Template**: Reusable allocation pattern (e.g., "Office Supplies - 80% Business, 20% Personal")
- **Split Engine**: Core calculation system for processing percentage allocations
- **Aggregator**: Service that connects to banks (Basiq, Plaid)
- **OCR**: Optical Character Recognition - Extract text from images
- **CDR**: Consumer Data Right - Australian open banking framework

---

**FinanceMate** is evolving from a production-ready personal finance manager into a comprehensive wealth management platform with **advanced tax allocation capabilities**. The line item splitting system positions FinanceMate as the premier solution for users requiring precise expense allocation for tax optimization, business accounting, and family financial management.

---

*Version 4.0.0 - Wealth Management Platform with Advanced Line Item Splitting and Tax Allocation*