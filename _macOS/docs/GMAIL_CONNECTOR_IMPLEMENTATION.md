# Gmail Connector Implementation - P0 MANDATORY

**Date**: 2025-08-10  
**Status**: 🚨 **P0 URGENT IMPLEMENTATION**  
**User Email**: `bernhardbudiono@gmail.com`  
**Acceptance Criteria**: Display expense table from email receipts  
**Priority**: MANDATORY - Highest Priority  

---

## 🎯 **USER ACCEPTANCE CRITERIA**

**MANDATORY DELIVERABLE**: 
User must see expense table populated with real receipt data from `bernhardbudiono@gmail.com` Gmail account.

**SUCCESS DEFINITION**:
- Real Gmail API integration (NO MOCK DATA)
- Receipt parsing and expense extraction
- Expense table display in FinanceMate UI
- End-to-end workflow from Gmail → Expense Table

---

## 🔧 **IMPLEMENTATION PLAN**

### **Phase 1: Google Cloud Console OAuth Setup** (15 minutes)

1. **Create Google Cloud Project**:
   - Go to: https://console.cloud.google.com/
   - Create new project: "FinanceMate Gmail Integration"
   - Enable Gmail API

2. **Configure OAuth 2.0**:
   - Navigate to: APIs & Services → Credentials
   - Create OAuth 2.0 Client ID
   - Application type: Desktop application
   - Name: FinanceMate macOS Gmail Connector

3. **Update ProductionConfig.swift**:
   ```swift
   static let gmailClientId = "[ACTUAL-CLIENT-ID-FROM-GOOGLE]"
   ```

### **Phase 2: Gmail API Integration** (30 minutes)

1. **Enhanced EmailOAuthManager**:
   - Add Gmail OAuth flow
   - Token management with Keychain storage
   - Error handling and refresh token logic

2. **Gmail Service Implementation**:
   - Create GmailAPIService.swift
   - Implement email fetching with receipt filtering
   - Attachment processing for receipt images/PDFs

### **Phase 3: Receipt Processing Engine** (45 minutes)

1. **Receipt Parser**:
   - Create ReceiptParser.swift
   - Text extraction from email bodies
   - Attachment OCR processing
   - Amount/date/vendor extraction

2. **Expense Data Model**:
   - Create ExpenseItem Core Data entity
   - Integration with existing Transaction model
   - Data validation and deduplication

### **Phase 4: Expense Table UI** (30 minutes)

1. **ExpenseTableView Implementation**:
   - SwiftUI table with receipt data
   - Integration with existing glassmorphism design
   - Real-time data updates from Gmail

2. **Navigation Integration**:
   - Add to main TabView
   - Connect with existing transaction workflow

---

## 🚀 **IMMEDIATE ACTIONS REQUIRED**

### **Step 1: Google Cloud Console Setup** (NOW)

**YOU NEED TO DO THIS**:
1. Go to: https://console.cloud.google.com/
2. Sign in with bernhardbudiono@gmail.com
3. Create new project: "FinanceMate Gmail"
4. Enable Gmail API
5. Create OAuth 2.0 credentials
6. Provide the client ID for ProductionConfig update

### **Step 2: I Will Implement** (Starting immediately)

1. **Gmail API Integration**: Complete OAuth flow and API service
2. **Receipt Processing**: Extract expenses from email content
3. **Expense Table UI**: Display real data in FinanceMate
4. **End-to-End Testing**: Verify with your actual Gmail data

---

## 📋 **TECHNICAL SPECIFICATIONS**

### **Gmail API Scope**
```
https://www.googleapis.com/auth/gmail.readonly
```

### **Email Search Criteria**
- Subject contains: receipt, invoice, purchase, payment
- From domains: receipts, invoices, financial services
- Attachment types: PDF, images with receipt content
- Date range: Last 30 days (configurable)

### **Data Extraction**
- Amount (with currency detection)
- Date of purchase
- Vendor/merchant name
- Category (auto-classification)
- Payment method (if available)

### **UI Requirements**
- Table format with sortable columns
- Real-time loading indicators
- Error handling for API failures
- Integration with existing FinanceMate theme

---

## 🔐 **SECURITY IMPLEMENTATION**

- OAuth 2.0 with PKCE for native app
- Token storage in macOS Keychain
- Minimum required permissions (gmail.readonly)
- Secure API key management
- Data encryption for processed receipts

---

## 🧪 **TESTING STRATEGY**

- Unit tests for receipt parsing logic
- Integration tests with Gmail API
- UI tests for expense table display
- End-to-end tests with real Gmail data
- Performance tests for large email volumes

---

## ⏰ **TIMELINE**

- **NOW**: Google Cloud Console setup (user action)
- **Next 30 min**: Gmail API integration implementation
- **Next 30 min**: Receipt processing engine
- **Next 30 min**: Expense table UI
- **Next 15 min**: End-to-end testing
- **TOTAL**: 2 hours for complete implementation

---

**🚨 BLOCKING DEPENDENCY: Google Cloud Console OAuth setup required before implementation can begin. Please complete Step 1 IMMEDIATELY.**