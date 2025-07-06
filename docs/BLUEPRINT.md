# FinanceMate - Wealth Management Platform Specification
**Version:** 3.0.0
**Last Updated:** 2025-07-06
**Status:** Phase 1 Complete (Core Financial Management) - Evolving to Wealth Management Platform
**Current Phase:** Core Financial Management ✅
**Next Phase:** Secure Data Aggregation & Multi-Entity Foundations 🎯

---

## 🎯 EXECUTIVE SUMMARY

### Project Vision
To be the central command center for personal and family wealth, empowering users to aggregate all their financial data automatically, gain deep insights from line-item level details, manage complex tax entities, and make informed investment and life decisions. The platform will evolve from a robust personal finance manager into a comprehensive wealth management solution with collaborative features for family members and financial professionals.

### Current Status: ✅ PHASE 1 COMPLETE
FinanceMate has achieved **Production Release Candidate 1.0.0** status for Phase 1 (Core Financial Management) with:
- ✅ **Complete Financial Management**: Dashboard, transactions, settings
- ✅ **MVVM Architecture**: Professional-grade with 100% test coverage
- ✅ **Glassmorphism UI**: Modern Apple-style design with accessibility
- ✅ **Production Infrastructure**: Automated build pipeline
- ✅ **Comprehensive Testing**: 75+ test cases

### Core User Journeys (Future Vision)
1. **Aggregation:** User securely links all bank accounts, credit cards, investment portfolios (Shares, Crypto), and loans
2. **Categorization & Review:** Platform automatically ingests transactions with intelligent categorization and entity splitting
3. **Analysis & Planning:** Comprehensive dashboards for spending, net wealth, and financial goal progress
4. **Reporting & Export:** Generate professional reports for tax purposes, wealth statements, and financial planning

### Development Phases
- ✅ **Phase 1**: Core Financial Management (COMPLETE)
- 🎯 **Phase 2**: Secure Data Aggregation, Transaction Management & Multi-Entity Foundations
- 📊 **Phase 3**: Advanced OCR, Investment Tracking & Collaborative Workspaces
- 🚀 **Phase 4**: Wealth Dashboards, Real Estate Analysis & Financial Goal Setting
- ✨ **Phase 5**: Predictive Analytics, Scenario Modeling & Automated Financial Advice

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

### Phase 2 Requirements (🎯 NEXT)
- **Requirement ID:** `UR-101`
  - **Requirement:** Securely connect to Australian bank and credit card accounts to automatically sync transaction data
  - **Status:** `Pending`
  - **Dependencies:** Basiq/Plaid API integration, OAuth implementation

- **Requirement ID:** `UR-102`
  - **Requirement:** Allow users to create and manage distinct financial "Entities" (e.g., "Personal," "Smith Family Trust," "My Business")
  - **Status:** `Pending`
  - **Dependencies:** Enhanced data model, UI for entity management

- **Requirement ID:** `UR-103`
  - **Requirement:** Implement Role-Based Access Control (RBAC) with predefined roles: Owner, Contributor, Viewer
  - **Status:** `Pending`
  - **Dependencies:** Authentication system, permission management

### Phase 3 Requirements
- **Requirement ID:** `UR-104`
  - **Requirement:** Scan receipts/invoices and extract line-item details with OCR
  - **Status:** `Pending`
  - **Dependencies:** Apple Vision framework, document processing pipeline

- **Requirement ID:** `UR-105`
  - **Requirement:** Track investment portfolios including shares (ASX/NASDAQ) and cryptocurrencies
  - **Status:** `Pending`
  - **Dependencies:** Broker API integrations, portfolio data model

### Phase 4 Requirements
- **Requirement ID:** `UR-106`
  - **Requirement:** Generate "Net Wealth" report consolidating all assets and liabilities
  - **Status:** `Pending`
  - **Dependencies:** Asset/liability tracking, reporting engine

- **Requirement ID:** `UR-107`
  - **Requirement:** Integrate with CoreLogic API for real estate analysis
  - **Status:** `Pending`
  - **Dependencies:** CoreLogic partnership, property data model

### Phase 5 Requirements
- **Requirement ID:** `UR-108`
  - **Requirement:** Create tax-specific categories with entity-based reporting
  - **Status:** `Pending`
  - **Dependencies:** Advanced categorization, tax rule engine

---

## 1. PROJECT OVERVIEW

### 1.1. Project Name
**FinanceMate** - Wealth Management Platform

### 1.2. Target Audience & Personas

#### Current Users (Phase 1) ✅
- **Individual Finance Tracker**
  - **Goals:** Track personal expenses, monitor spending, maintain budgets
  - **Key Needs:** Simple transaction management, clear financial overview

#### Future Personas (Phase 2+)
- **Persona 1: The Household CEO (Primary User)**
  - **Goals:** Single source of truth for family finances, tax optimization, property planning, investment tracking
  - **Key Needs:** Automated data aggregation, multi-entity support, net wealth tracking
  - **Access Level:** Full platform access, all entities

- **Persona 2: The Contributor (Spouse/Partner)**
  - **Goals:** Help manage household budget without accessing sensitive investment data
  - **Key Needs:** Simple interface for transaction categorization
  - **Access Level:** Limited to specific entities, transaction management

- **Persona 3: The Advisor (Accountant/Financial Planner)**
  - **Goals:** Efficient access to client financial data for tax and planning
  - **Key Needs:** Read-only access, robust reporting, data export capabilities
  - **Access Level:** Viewer permissions for designated entities

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
**Multi-Platform with Secure Cloud Backend**
```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTS                              │
│ ┌───────────┐   ┌───────────┐   ┌────────────┐            │
│ │ macOS App │   │  iOS App  │   │  Web App   │            │
│ └───────────┘   └───────────┘   └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                          | (Secure API Gateway)
┌─────────────────────────────────────────────────────────────┐
│                   FinanceMate Cloud Backend                  │
├─────────────────────────────────────────────────────────────┤
│  Business Logic: User Mgmt, RBAC, Entities, Reporting      │
├─────────────────────────────────────────────────────────────┤
│  Core Services:                                             │
│  ┌──────────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐│
│  │Data Aggregation│ │OCR Service│ │Inv.Tracking│ │Analytics││
│  │(Basiq/Plaid)  │ │(Vision AI)│ │(APIs)      │ │Engine   ││
│  └──────────────┘ └───────────┘ └───────────┘ └─────────┘│
├─────────────────────────────────────────────────────────────┤
│  Data Layer:                                                │
│  ┌──────────────┐ ┌───────────┐ ┌───────────┐            │
│  │  PostgreSQL  │ │   Redis   │ │    S3     │            │
│  │  (Primary)   │ │  (Cache)  │ │ (Storage) │            │
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
  - Native macOS (SwiftUI) - Enhanced from Phase 1
  - Native iOS (SwiftUI) - New
  - Web (React/Vue) - Future
- **Backend**: 
  - Go/Python for high-performance financial processing
  - GraphQL API for flexible client queries
- **Database**: 
  - PostgreSQL (primary - relational integrity)
  - Redis (caching layer)
  - S3 (document storage)
- **Infrastructure**: 
  - AWS/GCP with multi-region support
  - Kubernetes for container orchestration
- **Data Aggregation**: 
  - Basiq API (Australian focus)
  - Plaid API (international reach)
- **Authentication**: 
  - OAuth 2.0 with MFA
  - Auth0/AWS Cognito

### 2.4. Data Schema (PostgreSQL Model)

| Table | Key Columns | Relationships | Description |
|-------|-------------|---------------|-------------|
| **users** | `id`, `email`, `password_hash`, `mfa_secret` | | Master user accounts with security |
| **roles** | `id`, `name`, `permissions` | | System roles: owner, contributor, viewer |
| **user_entity_roles** | `user_id`, `entity_id`, `role_id` | → users, entities, roles | Permission mapping |
| **entities** | `id`, `name`, `type`, `owner_id` | → users | Financial entities (Personal, Business, Trust) |
| **accounts** | `id`, `name`, `type`, `institution`, `entity_id` | → entities | Bank/investment accounts |
| **transactions** | `id`, `amount`, `description`, `date`, `account_id`, `entity_id` | → accounts, entities | Financial transactions |
| **line_items** | `id`, `description`, `quantity`, `price`, `transaction_id` | → transactions | Receipt/invoice details |
| **categories** | `id`, `name`, `type`, `tax_deductible` | | Transaction categories |
| **assets** | `id`, `name`, `type`, `current_value`, `entity_id` | → entities | Properties, investments |
| **liabilities** | `id`, `name`, `type`, `balance`, `entity_id` | → entities | Mortgages, loans |
| **documents** | `id`, `type`, `s3_url`, `transaction_id` | → transactions | Receipts, invoices |

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
  - Multi-currency support
  - Notification preferences
  - Data export capabilities

### 3.2. Phase 2: Data Aggregation & Multi-Entity 🎯 NEXT

#### Secure User Onboarding
- Enhanced authentication with MFA
- Terms of service and privacy policy
- Guided setup wizard
- Entity creation flow

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

#### Entity Management
- **Entity Types**
  - Personal (default)
  - Business
  - Trust
  - Investment
  - Custom

- **Entity Features**
  - Separate dashboards
  - Transaction filtering
  - Report generation
  - Access control

### 3.3. Phase 3: OCR & Investment Tracking

#### Document Processing
- **Receipt/Invoice OCR**
  - Drag-and-drop upload
  - Mobile app scanning
  - Line-item extraction
  - Automatic matching to transactions
  - Manual review interface

#### Investment Portfolio
- **Broker Integrations**
  - CommSec (ASX)
  - Stake (US Markets)
  - Interactive Brokers
  - Cryptocurrency exchanges

- **Portfolio Features**
  - Real-time valuations
  - Performance tracking
  - Dividend tracking
  - Tax reporting

#### Collaborative Workspaces
- **Access Management**
  - Email-based invitations
  - Role assignment
  - Entity-specific permissions
  - Activity logging

### 3.4. Phase 4: Wealth Management & Goals

#### Net Wealth Dashboard
- **Comprehensive View**
  - Total assets vs liabilities
  - Historical wealth progression
  - Asset allocation breakdown
  - Currency consolidation

#### Real Estate Integration
- **CoreLogic Features**
  - Property valuation updates
  - Rental yield analysis
  - Market comparisons
  - Suburb insights

#### Financial Goals
- **Goal Types**
  - Property purchase
  - Retirement planning
  - Investment targets
  - Debt reduction

- **Goal Features**
  - Progress tracking
  - Scenario modeling
  - Milestone alerts
  - Strategy recommendations

### 3.5. Phase 5: Advanced Analytics & AI

#### Predictive Analytics
- Spending forecasts
- Cash flow projections
- Investment recommendations
- Tax optimization suggestions

#### Automated Insights
- Subscription detection
- Unusual transaction alerts
- Budget recommendations
- Savings opportunities

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

### 4.2. Phase 2: Data Aggregation & Multi-Entity (3-4 months)
**Timeline**: Q3 2025
**Epics**:
- [ ] Backend infrastructure setup
- [ ] Authentication system with MFA
- [ ] Basiq/Plaid integration
- [ ] Entity management system
- [ ] Enhanced macOS client
- [ ] API gateway implementation

**Key Milestones**:
- Month 1: Backend setup, authentication
- Month 2: Data aggregation integration
- Month 3: Entity system, client updates
- Month 4: Testing, security audit

### 4.3. Phase 3: OCR & Investments (3-4 months)
**Timeline**: Q4 2025
**Epics**:
- [ ] OCR service implementation
- [ ] Document storage system
- [ ] Investment API integrations
- [ ] RBAC implementation
- [ ] iOS app development
- [ ] Collaboration features

### 4.4. Phase 4: Wealth & Real Estate (2-3 months)
**Timeline**: Q1 2026
**Epics**:
- [ ] Net wealth calculations
- [ ] CoreLogic integration
- [ ] Goal setting module
- [ ] Advanced reporting
- [ ] Web app MVP

### 4.5. Phase 5: AI & Analytics (Ongoing)
**Timeline**: Q2 2026+
**Epics**:
- [ ] ML pipeline setup
- [ ] Predictive models
- [ ] Automated insights
- [ ] Scenario engine
- [ ] Advisory features

---

## 5. TESTING & QUALITY ASSURANCE

### 5.1. Current Test Coverage (Phase 1) ✅
- **Unit Tests**: 45+ test cases (>90% coverage)
- **UI Tests**: 30+ test cases
- **Integration Tests**: Core Data validation
- **Performance Tests**: 1000+ transaction loads
- **Accessibility Tests**: VoiceOver compliance

### 5.2. Enhanced Testing Strategy (Phase 2+)

#### Test Categories
- **Unit Tests**: Business logic, data transformations, API contracts
- **Integration Tests**: Service interactions, API gateway flows
- **End-to-End Tests**: Complete user journeys
- **Security Tests**: Penetration testing, vulnerability scanning
- **Performance Tests**: Load testing, stress testing
- **Contract Tests**: API compatibility (Pact)

#### Test Environments
- **Local**: Developer machines
- **CI/CD**: Automated pipeline
- **Staging**: Production-like
- **UAT**: User acceptance
- **Production**: Monitoring only

### 5.3. Quality Metrics
- Code coverage: >90%
- API response time: <200ms (p95)
- UI responsiveness: 60fps
- Error rate: <0.1%
- Security score: A+ rating

---

## 6. SECURITY & COMPLIANCE

### 6.1. Authentication & Authorization
- **Multi-Factor Authentication**: Mandatory for all accounts
- **OAuth 2.0**: Industry standard for third-party integrations
- **JWT Tokens**: Short-lived access tokens with refresh
- **Role-Based Access Control**: Granular permissions per entity
- **Session Management**: Secure session handling with timeout

### 6.2. Data Protection
- **Encryption**:
  - At rest: AES-256
  - In transit: TLS 1.3+
  - Key management: AWS KMS/Cloud KMS
- **API Security**:
  - Read-only keys where possible
  - Key rotation policy
  - Rate limiting
  - IP whitelisting (optional)
- **Data Isolation**:
  - Entity-level separation
  - Row-level security
  - Audit logging

### 6.3. Compliance Framework
- **Australian Standards**:
  - Privacy Act 1988
  - Australian Privacy Principles (APP)
  - Consumer Data Right (CDR)
- **International Standards**:
  - SOC 2 Type II
  - ISO 27001
  - GDPR (future)
- **Financial Standards**:
  - PCI DSS (payment processing)
  - Open Banking compliance

### 6.4. Security Practices
- Regular penetration testing
- Dependency scanning
- Code security analysis
- Security awareness training
- Incident response plan
- Disaster recovery procedures

---

## 7. API & INTEGRATION SPECIFICATIONS

### 7.1. Financial Data Aggregation

#### Basiq API (Australian Focus)
- **Purpose**: Connect to AU financial institutions
- **Authentication**: OAuth 2.0
- **Key Endpoints**:
  - `POST /users` - Create user
  - `POST /connections` - Link institution
  - `GET /accounts` - List accounts
  - `GET /transactions` - Sync transactions
- **Rate Limits**: 1000 requests/hour

#### Plaid API (International)
- **Purpose**: Global institution coverage
- **Products**: Transactions, Assets, Investments
- **Key Features**:
  - Real-time balance
  - Enhanced transactions
  - Investment holdings
  - Identity verification

### 7.2. Investment & Trading APIs

#### Broker Integrations
- **CommSec**: Via secure file export/import
- **Stake**: REST API for portfolio data
- **Interactive Brokers**: FIX protocol
- **Sharesight**: Portfolio tracking API

#### Cryptocurrency Exchanges
- **Binance**: REST/WebSocket APIs
- **Coinbase**: OAuth integration
- **Kraken**: REST API with signing

### 7.3. Real Estate & Valuation

#### CoreLogic API
- **Purpose**: Property data and valuations
- **Key Endpoints**:
  - Property search
  - Automated valuations
  - Sales history
  - Suburb profiles
  - Rental estimates
- **Data Points**:
  - Current market value
  - Historical prices
  - Comparable sales
  - Demographic data

### 7.4. Intelligence & Analytics

#### LLM Integration
- **Providers**:
  - OpenAI GPT-4
  - Anthropic Claude
  - Google Gemini
- **Use Cases**:
  - Transaction categorization
  - Receipt parsing assistance
  - Financial insights
  - Natural language queries
- **Security**:
  - No PII in prompts
  - Response validation
  - Rate limiting

---

## 8. USER INTERFACE EVOLUTION

### 8.1. Current UI (Phase 1) ✅
- **Design System**: Glassmorphism
- **Navigation**: Tab-based
- **Platform**: macOS only
- **Accessibility**: Full VoiceOver support

### 8.2. Enhanced UI (Phase 2+)
- **Design Evolution**:
  - Maintain glassmorphism aesthetics
  - Add data visualization components
  - Implement responsive layouts
  - Create unified design system

- **Navigation Enhancement**:
  - Sidebar navigation (macOS)
  - Tab bar (iOS)
  - Responsive menu (Web)
  - Quick actions
  - Global search

- **New Components**:
  - Entity switcher
  - Connection status indicators
  - Sync progress displays
  - Collaboration avatars
  - Permission badges

### 8.3. Platform-Specific Considerations

#### macOS (Enhanced)
- Native menu bar integration
- Keyboard shortcuts
- Multi-window support
- Touch Bar support
- Notification Center

#### iOS (New)
- Face ID/Touch ID
- Widget support
- Share extensions
- Camera integration
- Haptic feedback

#### Web (Future)
- Progressive Web App
- Responsive design
- Browser notifications
- Offline support
- Cross-browser compatibility

---

## 9. OPERATIONAL CONSIDERATIONS

### 9.1. Deployment Strategy

#### Phase 1 (Current)
- Direct distribution
- Manual updates
- Local data only

#### Phase 2+ (Cloud)
- **Infrastructure**:
  - Multi-region deployment
  - Auto-scaling groups
  - Load balancers
  - CDN for static assets

- **Deployment Pipeline**:
  - Blue-green deployments
  - Canary releases
  - Feature flags
  - Rollback capability

### 9.2. Monitoring & Analytics

#### Application Monitoring
- Performance metrics (APM)
- Error tracking (Sentry)
- User analytics (Mixpanel)
- Custom dashboards

#### Business Metrics
- User acquisition
- Feature adoption
- Retention rates
- Revenue metrics

### 9.3. Support Structure
- In-app help system
- Knowledge base
- Email support
- Community forum
- Priority support (premium)

---

## 10. BUSINESS MODEL EVOLUTION

### 10.1. Current Model (Phase 1)
- One-time purchase
- Direct distribution
- Individual licenses

### 10.2. Future Model (Phase 2+)

#### Pricing Tiers
- **Basic** (Free):
  - 1 entity
  - Manual transactions
  - Basic reports

- **Personal** ($9.99/month):
  - 3 entities
  - Bank connections (2)
  - OCR (50/month)
  - Email support

- **Family** ($19.99/month):
  - Unlimited entities
  - Unlimited connections
  - Unlimited OCR
  - Collaboration (5 users)
  - Priority support

- **Professional** ($49.99/month):
  - Everything in Family
  - API access
  - Advanced analytics
  - Custom reports
  - Dedicated support

### 10.3. Revenue Streams
- Subscription revenue (primary)
- Transaction fees (premium features)
- Partner commissions (financial products)
- Enterprise licenses
- API usage fees

---

## 11. RISK ANALYSIS & MITIGATION

### 11.1. Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Data breach | High | Medium | Encryption, security audits, insurance |
| API deprecation | Medium | High | Multiple providers, abstraction layer |
| Scaling issues | Medium | Medium | Cloud architecture, load testing |
| Integration failures | Low | High | Retry logic, fallback options |

### 11.2. Business Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Regulatory changes | High | Medium | Legal counsel, compliance team |
| Competition | Medium | High | Unique features, superior UX |
| User adoption | High | Medium | Freemium model, marketing |
| Partner dependencies | Medium | Medium | Multiple partners, contracts |

### 11.3. Mitigation Strategies
- Regular security assessments
- Disaster recovery planning
- Legal compliance reviews
- User feedback loops
- Agile development process
- Financial reserves

---

## 12. SUCCESS METRICS

### 12.1. Technical KPIs
- System uptime: >99.9%
- API latency: <200ms
- Error rate: <0.1%
- Test coverage: >90%
- Security score: A+

### 12.2. Business KPIs
- Monthly Active Users (MAU)
- Customer Acquisition Cost (CAC)
- Monthly Recurring Revenue (MRR)
- Net Promoter Score (NPS)
- Churn rate: <5%

### 12.3. User Satisfaction
- App store rating: >4.5
- Support ticket resolution: <24h
- Feature adoption rate: >60%
- User retention: >80% (6 months)

---

## 13. GLOSSARY

- **RBAC**: Role-Based Access Control - Permission system based on user roles
- **MFA**: Multi-Factor Authentication - Additional security beyond passwords
- **Entity**: Distinct financial unit for separating finances (Personal, Business, etc.)
- **Aggregator**: Service that connects to banks (Basiq, Plaid)
- **OCR**: Optical Character Recognition - Extract text from images
- **CDR**: Consumer Data Right - Australian open banking framework
- **APM**: Application Performance Monitoring
- **KPI**: Key Performance Indicator
- **MAU**: Monthly Active Users
- **MRR**: Monthly Recurring Revenue
- **CAC**: Customer Acquisition Cost
- **NPS**: Net Promoter Score

---

**FinanceMate** is evolving from a production-ready personal finance manager into a comprehensive wealth management platform. This specification guides both current operations and the transformation into a multi-platform, collaborative financial command center.

---

*Version 3.0.0 - Wealth Management Platform Vision with Phased Implementation*