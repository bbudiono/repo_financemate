# Microsoft Azure OAuth 2.0 Setup Guide for Outlook Integration

**Date**: 2025-08-10  
**Status**: 📋 **IMPLEMENTATION READY**  
**Purpose**: Enable Outlook email receipt processing for automated transaction extraction  
**Priority**: P1 - Core OAuth functionality for email integrations  

---

## 🎯 **OBJECTIVE**

Configure Microsoft Azure App Registration to enable secure Outlook email authentication for automated receipt processing and financial transaction extraction in FinanceMate.

---

## 🔧 **MICROSOFT AZURE APP REGISTRATION SETUP**

### **Step 1: Access Azure Portal**
1. Go to: https://portal.azure.com/
2. Sign in with Microsoft account (preferably business account)
3. Navigate to: **Azure Active Directory**

### **Step 2: Create App Registration**
1. Click: **App registrations** (left sidebar)
2. Click: **+ New registration**
3. Configure:
   - **Name**: `FinanceMate Email Processor`
   - **Supported account types**: Select "Accounts in any organizational directory (Any Azure AD directory - Multitenant) and personal Microsoft accounts"
   - **Redirect URI**: 
     - Platform: **Public client/native (mobile & desktop)**
     - URI: `https://login.microsoftonline.com/common/oauth2/nativeclient`
4. Click: **Register**

### **Step 3: Configure Authentication**
1. In your new app registration, click: **Authentication** (left sidebar)
2. Under **Platform configurations**:
   - Click: **+ Add a platform**
   - Select: **Mobile and desktop applications**
   - Check: `https://login.microsoftonline.com/common/oauth2/nativeclient`
   - Check: `msal{Application-ID}://auth` (replace {Application-ID} with your actual app ID)
3. Under **Advanced settings**:
   - **Allow public client flows**: Set to **Yes**
4. Click: **Save**

### **Step 4: Configure API Permissions**
1. Click: **API permissions** (left sidebar)
2. Click: **+ Add a permission**
3. Select: **Microsoft Graph**
4. Select: **Delegated permissions**
5. Add these permissions:
   - `Mail.Read` - Read user mail
   - `Mail.ReadBasic` - Read basic mail properties
   - `offline_access` - Maintain access to data you have given it access to
   - `openid` - Sign users in
   - `profile` - View users' basic profile
   - `email` - View users' email address
6. Click: **Add permissions**
7. Click: **Grant admin consent for [Your Directory]** (if available)

### **Step 5: Create Client Secret (Optional - for web apps)**
For native macOS app, we'll use PKCE instead, but record the process:
1. Click: **Certificates & secrets** (left sidebar)
2. Click: **+ New client secret**
3. Description: `FinanceMate macOS Client Secret`
4. Expires: **24 months**
5. Click: **Add**
6. **CRITICAL**: Copy the secret value immediately (it won't be shown again)

### **Step 6: Record Configuration Values**
From your App registration overview page, record:
- **Application (client) ID**: `[Your-App-ID-Here]`
- **Directory (tenant) ID**: `[Your-Tenant-ID-Here]`
- **Client Secret**: `[Your-Secret-Here]` (if created)

---

## 🔧 **FINANCEMATE INTEGRATION CONFIGURATION**

### **Update ProductionConfig.swift**

The OAuth configuration is already prepared in `ProductionConfig.swift`. You need to update the Outlook client ID:

```swift
// Update line 45 in ProductionConfig.swift:
static let outlookClientId = "your-outlook-client-id"

// Replace with your actual Azure App Registration Application (client) ID:
static let outlookClientId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### **MSAL Integration (Microsoft Authentication Library)**

For robust Microsoft authentication, FinanceMate should integrate MSAL (Microsoft Authentication Library):

1. **Add MSAL Framework** (via Package Manager):
   - In Xcode: File → Add Package Dependencies
   - URL: `https://github.com/AzureAD/microsoft-authentication-library-for-objc`
   - Version: Latest

2. **Update Info.plist** with URL scheme:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>com.ablankcanvas.financemate</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>msal[Your-Application-ID]</string>
           </array>
       </dict>
   </array>
   ```

### **Enhanced EmailOAuthManager Integration**

The EmailOAuthManager is already configured to use ProductionConfig values. Once you update the `outlookClientId`, the Outlook integration will be ready for testing.

---

## 🧪 **TESTING VERIFICATION**

### **Post-Configuration Testing Steps**

1. **Update ProductionConfig.swift** with your Azure Application (client) ID
2. **Build and Run** FinanceMate
3. **Navigate to Email Settings** (when available)
4. **Test Outlook Authentication**:
   - Should redirect to Microsoft login
   - Should complete OAuth 2.0 flow
   - Should return with valid access token
5. **Verify Email Access**: Test reading Outlook emails (when implemented)

### **Configuration Validation**

Use the built-in validation in ProductionConfig:

```swift
// Check if Outlook is configured:
let isOutlookReady = ProductionAPIConfig.validateProvider("outlook")

// Get configuration status:
print(ProductionAPIConfig.configurationSummary)

// Check if ready for production:
let isReady = ProductionAPIConfig.isReadyForProduction
```

---

## 📋 **REQUIRED VALUES TO COMPLETE SETUP**

From your Azure App Registration, you need:

1. **Application (client) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Copy from Azure Portal → App registrations → [Your App] → Overview
   - Update `ProductionAPIConfig.outlookClientId`

2. **Directory (tenant) ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Copy from Azure Portal → App registrations → [Your App] → Overview
   - Add to ProductionConfig if needed for multi-tenant scenarios

3. **Redirect URI Configuration**: `financemate://oauth/outlook`
   - Already configured in ProductionConfig
   - Must match exactly in Azure Portal

---

## 🚨 **SECURITY BEST PRACTICES**

### **Implemented Security Measures**

1. **PKCE (Proof Key for Code Exchange)**: Use PKCE flow for native app security
2. **No Client Secrets**: Native macOS app uses public client flow
3. **Secure Storage**: Tokens stored in macOS Keychain
4. **Scope Limitation**: Only request minimum required permissions (`mail.read`)
5. **Token Validation**: Validate all OAuth responses

### **Production Security Checklist**

- [ ] **Application Type**: Set to "Public client/native (mobile & desktop)"
- [ ] **Allow public client flows**: Set to "Yes"
- [ ] **Redirect URI**: Exact match with ProductionConfig
- [ ] **API Permissions**: Only minimum required permissions granted
- [ ] **Admin Consent**: Granted for organizational accounts (if applicable)

---

## 🎯 **SUCCESS CRITERIA**

### **✅ Azure Configuration Complete When:**

1. **App Registration Created**: FinanceMate Email Processor registered
2. **Authentication Configured**: Redirect URI and public client flow enabled
3. **API Permissions Set**: Mail.Read and basic permissions configured
4. **Application ID Obtained**: Client ID copied and ready for ProductionConfig
5. **Testing Ready**: Configuration values ready for integration testing

### **✅ FinanceMate Integration Complete When:**

1. **ProductionConfig Updated**: outlookClientId contains actual Azure client ID
2. **Build Successful**: Project compiles with updated configuration
3. **OAuth Flow Working**: Outlook authentication redirects and completes successfully
4. **Email Access**: Can authenticate and access user's Outlook emails
5. **Validation Passing**: `ProductionAPIConfig.validateProvider("outlook")` returns true

---

## 📞 **NEXT STEPS**

### **Immediate Actions Required:**

1. **Complete Azure App Registration** using the steps above
2. **Copy Application (client) ID** from Azure Portal
3. **Update ProductionConfig.swift** with actual client ID
4. **Test OAuth Integration** with Outlook authentication
5. **Verify Email Access** functionality

### **Integration with Email Receipt Processing:**

Once Azure OAuth is configured, the email receipt processing system can:
- Authenticate with user's Outlook account
- Read emails for receipt attachments and transaction data
- Extract financial information for automatic transaction creation
- Maintain secure, token-based access to email data

---

**🔧 COMPLETION STEPS**: 
1. Follow Azure Portal setup (15-20 minutes)
2. Update ProductionConfig.swift with client ID (2 minutes)
3. Test OAuth flow (5-10 minutes)
4. Verify email access integration (5-10 minutes)

**Total Estimated Time**: 25-40 minutes for complete Azure OAuth integration

<function_calls>
<invoke name="Read">
<parameter name="file_path">/Users/bernhardbudiono/Library/CloudStorage/Dropbox/_Documents - Apps (Working)/repos_github/Working/repo_financemate/_macOS/FinanceMate/FinanceMate/Models/ProductionConfig.swift