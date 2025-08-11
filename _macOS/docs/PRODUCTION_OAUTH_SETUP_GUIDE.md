# PRODUCTION OAUTH 2.0 SETUP GUIDE - FINANCEMATE

**Status**: CRITICAL - Production API Credentials Required  
**Priority**: P0 - Blocking Production Deployment  
**Estimated Time**: 90-120 minutes total  
**Updated**: 2025-08-10  

---

## 🚨 CRITICAL: PRODUCTION API SETUP REQUIRED

**Current Status**: EmailOAuthManager.swift has production-ready OAuth 2.0 PKCE implementation but **placeholder credentials** that must be replaced with real production API keys.

**Placeholder Values to Replace**:
- **Gmail**: `"your-gmail-client-id.apps.googleusercontent.com"` (line 79)
- **Outlook**: `"your-outlook-client-id"` (line 89)

---

## 📋 TASK 1.1: GOOGLE CLOUD CONSOLE OAUTH 2.0 SETUP (45 minutes)

### Step 1.1.1: Create Production Google Cloud Project (10 minutes)

1. **Navigate to Google Cloud Console**: https://console.cloud.google.com
2. **Create New Project**:
   - Click "Select a project" → "New Project"
   - Project name: `FinanceMate-Production`
   - Organization: (your organization or personal)
   - Location: (your preferred location)
   - Click "Create"

3. **Enable Billing** (if not already configured):
   - Select the new project
   - Navigate to "Billing" → "Link a billing account"
   - **Note**: Gmail API has generous free tier (1 billion quota units/day)

### Step 1.1.2: Enable Gmail API with Production Quotas (10 minutes)

1. **Enable Gmail API**:
   - In Google Cloud Console → "APIs & Services" → "Library"
   - Search for "Gmail API"
   - Click "Gmail API" → "Enable"

2. **Configure API Quotas**:
   - Navigate to "APIs & Services" → "Quotas"
   - Filter by "Gmail API"
   - Verify quotas (defaults are sufficient):
     - Queries per day: 1,000,000,000 units
     - Queries per 100 seconds per user: 250 units

### Step 1.1.3: Configure OAuth 2.0 Consent Screen (15 minutes)

1. **Navigate to OAuth Consent Screen**:
   - "APIs & Services" → "OAuth consent screen"

2. **Configure App Registration**:
   - User Type: **External** (for public distribution)
   - Click "Create"

3. **OAuth Consent Screen Configuration**:
   ```
   App name: FinanceMate
   User support email: [your-email]
   Developer contact information: [your-email]
   
   App domain (optional):
   - Application home page: https://financemate.app (if available)
   - Application privacy policy: https://financemate.app/privacy
   - Application terms of service: https://financemate.app/terms
   
   Authorized domains:
   - financemate.app (if you have a website)
   ```

4. **Scopes Configuration**:
   - Click "Add or Remove Scopes"
   - Add: `https://www.googleapis.com/auth/gmail.readonly`
   - Justification: "Read user's Gmail messages to extract financial receipts and transaction data"

5. **Test Users** (for testing):
   - Add your Gmail address for initial testing
   - Click "Save and Continue"

### Step 1.1.4: Generate Production Client Credentials (10 minutes)

1. **Create OAuth 2.0 Client**:
   - Navigate to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"

2. **Configure OAuth Client**:
   ```
   Application type: macOS app
   Name: FinanceMate-macOS-Production
   
   Bundle ID: com.ablankcanvas.financemate
   
   Authorized redirect URIs:
   - financemate://oauth/gmail
   ```

3. **Download Credentials**:
   - Click "Create"
   - **CRITICAL**: Download the JSON file immediately
   - Save as: `google_oauth_credentials_production.json`
   - **Note the Client ID**: Format will be `XXXXX.apps.googleusercontent.com`

---

## 📋 TASK 1.2: MICROSOFT AZURE APP REGISTRATION (45 minutes)

### Step 1.2.1: Create Production Azure App Registration (10 minutes)

1. **Navigate to Azure Portal**: https://portal.azure.com
2. **Go to App Registrations**:
   - Search "App registrations" → select service
   - Click "New registration"

3. **Register Application**:
   ```
   Name: FinanceMate-Production
   Supported account types: Accounts in any organizational directory and personal Microsoft accounts
   Redirect URI: 
     - Type: Public client/native (mobile & desktop)
     - URI: financemate://oauth/outlook
   ```
   - Click "Register"

### Step 1.2.2: Configure Microsoft Graph API Permissions (15 minutes)

1. **API Permissions**:
   - In your app registration → "API permissions"
   - Click "Add a permission"

2. **Microsoft Graph**:
   - Select "Microsoft Graph" → "Delegated permissions"
   - Expand "Mail" → Select:
     - `Mail.Read` - Read user mail
   - Click "Add permissions"

3. **Admin Consent** (for organizational accounts):
   - Click "Grant admin consent" (if you're admin)
   - Or document requirement for tenant admin approval

### Step 1.2.3: Multi-tenant Support Configuration (10 minutes)

1. **Authentication Settings**:
   - Navigate to "Authentication"
   - Confirm redirect URI: `financemate://oauth/outlook`
   - **Advanced settings**:
     - Allow public client flows: **Yes**
     - Supported account types: Multi-tenant

2. **Token Configuration**:
   - Navigate to "Token configuration"
   - Add optional claims if needed (typically not required)

### Step 1.2.4: Generate Production Client Credentials (10 minutes)

1. **Application (client) ID**:
   - Copy from "Overview" page
   - Format: `XXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX`

2. **Client Secret** (optional for native apps):
   - Navigate to "Certificates & secrets"
   - Not required for native macOS app using PKCE

3. **Document Configuration**:
   ```
   Client ID: [from Overview page]
   Tenant ID: common (for multi-tenant)
   Authority: https://login.microsoftonline.com/common
   Scopes: https://graph.microsoft.com/mail.read
   Redirect URI: financemate://oauth/outlook
   ```

---

## 📋 TASK 1.3: PRODUCTION CONFIGURATION MANAGEMENT (30 minutes)

### Step 1.3.1: Secure Configuration System (15 minutes)

Create secure configuration management for API credentials:

```swift
// File: _macOS/FinanceMate/Configuration/ProductionConfig.swift

import Foundation

struct ProductionAPIConfig {
    
    // MARK: - Gmail Configuration
    static let gmailClientId = "YOUR_GMAIL_CLIENT_ID.apps.googleusercontent.com"
    static let gmailScope = "https://www.googleapis.com/auth/gmail.readonly"
    
    // MARK: - Microsoft Configuration  
    static let outlookClientId = "YOUR_OUTLOOK_CLIENT_ID"
    static let outlookScope = "https://graph.microsoft.com/mail.read"
    
    // MARK: - Validation
    static func validateConfiguration() -> Bool {
        return !gmailClientId.contains("YOUR_") && 
               !outlookClientId.contains("YOUR_")
    }
}
```

### Step 1.3.2: Update EmailOAuthManager with Production Credentials (10 minutes)

Replace placeholder values in `EmailOAuthManager.swift`:

**Lines 74-94**: Update EmailProvider static properties:

```swift
static let gmail = EmailProvider(
    id: "gmail",
    name: "Gmail",
    authorizationURL: "https://accounts.google.com/o/oauth2/v2/auth",
    tokenURL: "https://oauth2.googleapis.com/token",
    clientId: ProductionAPIConfig.gmailClientId, // UPDATED
    scope: ProductionAPIConfig.gmailScope,       // UPDATED
    redirectURI: "financemate://oauth/gmail"
)

static let outlook = EmailProvider(
    id: "outlook", 
    name: "Microsoft Outlook",
    authorizationURL: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
    tokenURL: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
    clientId: ProductionAPIConfig.outlookClientId, // UPDATED
    scope: ProductionAPIConfig.outlookScope,        // UPDATED
    redirectURI: "financemate://oauth/outlook"
)
```

### Step 1.3.3: Add Production Validation (5 minutes)

Add validation in `EmailOAuthManager.init()`:

```swift
init() {
    // Validate production configuration
    assert(ProductionAPIConfig.validateConfiguration(), 
           "Production API credentials not configured!")
    
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30.0
    self.urlSession = URLSession(configuration: config)
    
    // Check for existing authenticated providers
    Task {
        await loadAuthenticatedProviders()
    }
}
```

---

## 🧪 TESTING & VALIDATION

### Gmail OAuth Testing (10 minutes)

1. **Test Gmail Authentication**:
   ```swift
   // In app: Settings → Email Integration → Connect Gmail
   await emailOAuthManager.authenticateProvider("gmail")
   ```

2. **Verify Token Storage**:
   - Check Keychain Access app
   - Search for "FinanceMate" entries
   - Confirm secure token storage

3. **Test API Call**:
   - Use stored token to make Gmail API request
   - Verify receipt email retrieval

### Outlook OAuth Testing (10 minutes)

1. **Test Outlook Authentication**:
   ```swift
   await emailOAuthManager.authenticateProvider("outlook")
   ```

2. **Verify Multi-tenant Support**:
   - Test with personal Microsoft account
   - Test with organizational account (if available)

3. **Test Graph API**:
   - Retrieve mail messages
   - Confirm proper scope permissions

---

## 🔒 SECURITY CHECKLIST

### Production Security Requirements ✅

- [ ] **Client Secrets**: Not required for native macOS app (PKCE used)
- [ ] **Redirect URI Validation**: Exact match `financemate://oauth/[provider]`
- [ ] **Scope Minimization**: Only `mail.read` permissions requested
- [ ] **Token Storage**: Keychain with device-only access control
- [ ] **PKCE Implementation**: Full RFC 7636 compliance with SHA256
- [ ] **Certificate Pinning**: Recommended for production deployment
- [ ] **Rate Limiting**: Built into provider APIs, respect quotas

### Compliance Verification ✅

- [ ] **Privacy Policy**: Document email data access and processing
- [ ] **Terms of Service**: Include API usage terms reference
- [ ] **User Consent**: Clear explanation of email access permissions
- [ ] **Data Retention**: Implement data cleanup for revoked access
- [ ] **Audit Logging**: Log authentication events securely

---

## 📊 SUCCESS METRICS

### API Integration KPIs

- **Authentication Success Rate**: Target >95%
- **Token Refresh Success**: Target >98%
- **API Response Time**: Target <3 seconds
- **Error Handling Coverage**: 100% error scenarios handled

### User Experience Metrics

- **Setup Completion Rate**: Target >90%
- **Setup Time**: Target <5 minutes per provider
- **User Satisfaction**: Target >4.5/5 rating

---

## 🚨 DEPLOYMENT BLOCKERS RESOLVED

After completing this OAuth 2.0 setup:

- ✅ **Real API Credentials**: Production Google and Microsoft OAuth clients
- ✅ **Security Compliance**: Enterprise-grade PKCE implementation  
- ✅ **Multi-tenant Support**: Both personal and organizational accounts
- ✅ **Production Validation**: Configuration validation and testing

**Next Task**: TASK 2 - AI Chatbot Production Enhancement

---

## 📞 SUPPORT & TROUBLESHOOTING

### Common Issues

**Google Cloud Console Issues**:
- Billing account required (even for free tier usage)
- OAuth consent screen requires domain verification for production
- Gmail API quota limits: 1B units/day (very generous)

**Microsoft Azure Issues**:
- Multi-tenant requires proper redirect URI configuration
- Admin consent may be required for organizational accounts
- Personal accounts work immediately with delegated permissions

**Configuration Issues**:
- Bundle ID must match exactly: `com.ablankcanvas.financemate`
- Redirect URIs are case-sensitive: `financemate://oauth/gmail`
- Client IDs must not contain placeholder text

---

**CRITICAL NEXT STEPS**:
1. Complete Google Cloud Console setup (45 minutes)
2. Complete Microsoft Azure app registration (45 minutes)  
3. Update EmailOAuthManager with production credentials (30 minutes)
4. Test end-to-end OAuth flows (20 minutes)
5. Proceed to TASK 2: AI Chatbot Production Enhancement

**Total Estimated Time**: 2.5 hours for complete production OAuth setup