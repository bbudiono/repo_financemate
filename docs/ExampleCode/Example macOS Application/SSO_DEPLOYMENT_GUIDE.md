# SynchroNext macOS Application: SSO Deployment Guide (Apple & Google)

---

## Overview
This guide provides a step-by-step process to deploy Single Sign-On (SSO) for both **Apple** and **Google** in the SynchroNext macOS application. It is based on the latest codebase and best practices, ensuring a professional, production-ready integration.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Apple SSO Setup](#apple-sso-setup)
    - [Apple Developer Portal](#apple-developer-portal)
    - [Xcode Project Configuration](#xcode-project-configuration)
    - [Entitlements & Info.plist](#entitlements--infoplist)
    - [Code Integration](#code-integration-apple)
    - [Apple SSO: Advanced Notes](#apple-sso-advanced-notes)
3. [Google SSO Setup](#google-sso-setup)
    - [Google Cloud Console](#google-cloud-console)
    - [OAuth Client Configuration](#oauth-client-configuration)
    - [Info.plist & Redirect URI](#infoplist--redirect-uri)
    - [Code Integration](#code-integration-google)
    - [Google SSO: Advanced Notes](#google-sso-advanced-notes)
4. [Testing SSO](#testing-sso)
5. [Troubleshooting & Best Practices](#troubleshooting--best-practices)
6. [Advanced Configuration & Compliance](#advanced-configuration--compliance)
7. [OAuth Use Cases: Web, Desktop, Mobile, and More](#oauth-use-cases-web-desktop-mobile-and-more)
8. [References](#references)

---

## Prerequisites
- **Apple Developer Account** (for Apple SSO)
- **Google Cloud Project** (for Google SSO)
- Xcode 15+
- macOS 13.0+
- Access to the SynchroNext codebase
- Familiarity with [Apple's SSO documentation](https://developer.apple.com/sign-in-with-apple/) and [Google Identity documentation](https://developers.google.com/identity)

---

## Apple SSO Setup

### 1. Apple Developer Portal
- Log in to [Apple Developer](https://developer.apple.com/account/).
- Register your app's **Bundle Identifier** (e.g., `com.synchronext.synchronext`).
- Enable **Sign In with Apple** capability for your app ID.
- Create and download the necessary provisioning profiles.
- See: [Registering Your App with Apple](https://developer.apple.com/documentation/sign_in_with_apple/register_your_app_for_sign_in_with_apple)

### 2. Xcode Project Configuration
- Open your project in Xcode.
- Go to **Signing & Capabilities** tab for your target.
- Add **Sign In with Apple** capability.
- Ensure your **Team** and **Bundle Identifier** match those registered in the Apple Developer portal.
- For macOS, ensure your deployment target is at least macOS 13.0.

### 3. Entitlements & Info.plist
- Add or update your entitlements file (e.g., `SynchroNext.entitlements`):
  ```xml
  <key>com.apple.developer.applesignin</key>
  <array>
      <string>Default</string>
  </array>
  ```
- In `Info.plist`, add:
  ```xml
  <key>NSAppleEventsUsageDescription</key>
  <string>This app requires access to authenticate with Apple services.</string>
  <key>CFBundleURLTypes</key>
  <array>
      <dict>
          <key>CFBundleTypeRole</key>
          <string>Viewer</string>
          <key>CFBundleURLName</key>
          <string>com.products.synchronext</string>
          <key>CFBundleURLSchemes</key>
          <array>
              <string>com.products.synchronext</string>
          </array>
      </dict>
  </array>
  ```
- Ensure the minimum system version is set to at least macOS 13.0.

### 4. Code Integration (Apple)
- Use the provided `AppleAuthProvider.swift` and `AppleSignInView.swift` components.
- Example usage in your main view:
  ```swift
  AppleSignInView(
      onSignIn: { credential in
          // Handle successful sign in
      },
      onError: { error in
          // Handle error
      }
  )
  ```
- The provider handles nonce generation, secure token storage, and error management.
- For sandbox/testing, use the `-Sandbox.swift` variants.

### Apple SSO: Advanced Notes
- **User Privacy:** Apple only provides user email and name on the first sign-in. Store these securely if needed.
- **Token Validation:** Always validate the identity token on your backend for production. See [Apple's Token Validation Guide](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms).
- **Compliance:** Follow [Apple's Human Interface Guidelines for Sign In with Apple](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/introduction/).
- **Security:** Use Keychain for all sensitive data. Never log tokens or user info in production.
- **Error Handling:** Map all `ASAuthorizationError` codes to user-friendly messages. See [Apple Error Codes](https://developer.apple.com/documentation/authenticationservices/asauthorizationerror/code).

---

## Google SSO Setup

### 1. Google Cloud Console
- Go to [Google Cloud Console](https://console.cloud.google.com/).
- Create a new project or select an existing one.
- Navigate to **APIs & Services > Credentials**.
- Click **Create Credentials > OAuth client ID**.
- Select **Desktop app** or **macOS** as the application type.
- Set the **Authorized redirect URI** to:
  ```
  com.products.synchronext:/oauth2redirect
  ```
- Download the client ID and note it for the next step.
- See: [Google OAuth Client Setup](https://developers.google.com/identity/protocols/oauth2/native-app)

### 2. OAuth Client Configuration
- In `Info.plist`, add:
  ```xml
  <key>GoogleOAuthClientID</key>
  <string>[YOUR_GOOGLE_CLIENT_ID]</string>
  <key>GoogleOAuthRedirectURI</key>
  <string>com.products.synchronext:/oauth2redirect</string>
  ```
- For sandbox, use the `GoogleOAuthClientIDSandbox` and `GoogleOAuthRedirectURISandbox` keys.

### 3. Info.plist & Redirect URI
- Ensure the redirect URI matches both in Google Cloud and your app's `Info.plist`.
- The URL scheme (`com.products.synchronext`) must be registered in `CFBundleURLTypes`.
- See: [Google Redirect URI Best Practices](https://developers.google.com/identity/protocols/oauth2/native-app#redirect-uri)

### 4. Code Integration (Google)
- Use the provided `GoogleAuthProvider.swift` and integrate as shown in `AppleSignInView.swift`:
  ```swift
  Button(action: {
      guard let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? NSApplication.shared.windows.first else { return }
      googleAuthProvider.signIn(presentingWindow: window)
  }) {
      // Google Sign-In button UI
  }
  ```
- The provider handles OAuth flow, token exchange, and error management.
- For sandbox/testing, use the `GoogleAuthProvider-Sandbox.swift` variant.

### Google SSO: Advanced Notes
- **Scopes:** Only request the minimum scopes required (e.g., `openid email profile`).
- **PKCE:** Google recommends using PKCE for native apps. See [Google PKCE Guide](https://developers.google.com/identity/protocols/oauth2/native-app#pkce).
- **Token Validation:** Always validate the ID token on your backend for production. See [Google Token Validation](https://developers.google.com/identity/sign-in/web/backend-auth).
- **Security:** Never embed client secrets in the app. Use public client type for macOS.
- **Branding:** Follow [Google Sign-In branding guidelines](https://developers.google.com/identity/branding-guidelines).
- **Error Handling:** Handle all error codes and provide user-friendly feedback. See [Google OAuth Error Reference](https://developers.google.com/identity/protocols/oauth2/native-app#handlingresponse).

---

## Testing SSO
- Use the included test suites in `SynchroNextTests/` and `SynchroNext-SandboxTests/` for comprehensive coverage.
- Run tests via Xcode's Test navigator or `Cmd+U`.
- Test both production and sandbox targets.
- Ensure you can:
  - Sign in with Apple and Google
  - Handle error and cancellation flows
  - Store and retrieve tokens securely
- For UI/UX compliance, review [Apple SSO UI Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/introduction/) and [Google Sign-In UX](https://developers.google.com/identity/branding-guidelines).

---

## Troubleshooting & Best Practices
- **Common Issues:**
  - *Invalid redirect URI*: Ensure it matches exactly in both Google Cloud and `Info.plist`.
  - *Missing entitlements*: Double-check your `.entitlements` file and Xcode capabilities.
  - *Provisioning errors*: Refresh your provisioning profiles in Xcode.
  - *Token storage issues*: Use the provided `TokenStorage` classes for secure storage.
  - *App Transport Security (ATS) issues*: If using non-HTTPS endpoints, update `NSAppTransportSecurity` in `Info.plist` (not recommended for production).
- **Security:**
  - Never hardcode secrets in source code for production.
  - Use Keychain for all token storage.
  - Always validate tokens on your backend for production.
  - Regularly review [Apple Security Advisories](https://support.apple.com/en-us/HT201222) and [Google Security Bulletins](https://cloud.google.com/support/bulletins).
- **Testing:**
  - Use the sandbox target for development and testing.
  - Run all unit and UI tests before production deployment.
  - Test on multiple macOS versions and hardware.
- **Upgrades:**
  - Keep dependencies and OAuth credentials up to date.
  - Review Apple and Google SSO documentation for breaking changes.
  - Monitor [Apple Developer News](https://developer.apple.com/news/) and [Google Cloud Release Notes](https://cloud.google.com/release-notes).
- **User Experience:**
  - Use native buttons and branding for both Apple and Google SSO.
  - Provide clear error messages and fallback options.
  - Respect user privacy and data minimization principles.

---

## Advanced Configuration & Compliance
- **App Store Review:** Ensure your SSO implementation complies with [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).
- **Privacy Policy:** Update your privacy policy to reflect SSO data usage. See [Apple Privacy Requirements](https://developer.apple.com/app-store/user-privacy-and-data-use/).
- **Accessibility:** Ensure SSO UI is accessible (VoiceOver, keyboard navigation). See [Apple Accessibility Guide](https://developer.apple.com/accessibility/).
- **Internationalization:** Support multiple languages for SSO flows if your app is localized.
- **Logging & Analytics:** Never log sensitive user data or tokens. Use analytics only for non-PII events.
- **Compliance:** For enterprise or regulated environments, review [Apple Platform Security](https://support.apple.com/guide/security/welcome/web) and [Google Cloud Compliance](https://cloud.google.com/security/compliance).

---

## OAuth Use Cases: Web, Desktop, Mobile, and More

Modern SSO and OAuth implementations differ based on the type of application. Below is a summary of the main use cases, recommended flows, and platform-specific considerations, based on the latest Apple and Google documentation (Context7 MCP).

### 1. Web Applications
- **Typical Flow:** Authorization Code Flow (with PKCE for public clients)
- **Redirect URI:** HTTPS URL (e.g., `https://yourapp.com/oauth2/callback`)
- **Security:** Use HTTPS, store secrets securely on the server, never expose client secrets to the browser.
- **Best Practices:**
  - Use short-lived tokens and refresh tokens.
  - Implement CSRF protection (state parameter).
  - Validate ID tokens on the backend.
- **References:**
  - [Google OAuth 2.0 for Web Server Applications](https://developers.google.com/identity/protocols/oauth2/web-server)
  - [Apple Web SSO](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js)

### 2. Desktop Applications (macOS, Windows, Linux)
- **Typical Flow:** Authorization Code Flow with PKCE (no client secret)
- **Redirect URI:** Custom scheme (e.g., `com.products.synchronext:/oauth2redirect`) or loopback address (`http://127.0.0.1:port`)
- **Security:**
  - Never embed client secrets in the app.
  - Use PKCE to protect against interception.
  - Store tokens securely (e.g., Keychain on macOS).
- **Best Practices:**
  - Use ephemeral browser sessions for authentication.
  - Always validate tokens on the backend if possible.
- **References:**
  - [Google OAuth 2.0 for Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
  - [Apple SSO for macOS](https://developer.apple.com/documentation/authenticationservices)

### 3. Mobile Applications (iOS, Android)
- **Typical Flow:** Authorization Code Flow with PKCE
- **Redirect URI:** Custom scheme (e.g., `com.example.app:/oauth2redirect`) or App Link/Universal Link
- **Security:**
  - Use PKCE for all mobile flows.
  - Never embed client secrets in the app.
  - Use secure storage (Keychain, Keystore).
- **Best Practices:**
  - Use system browser (ASWebAuthenticationSession/SFAuthenticationSession on iOS, Custom Tabs on Android) for authentication.
  - Validate tokens on backend for sensitive operations.
- **References:**
  - [Google OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
  - [Apple SSO for iOS](https://developer.apple.com/documentation/authenticationservices)

### 4. Single Page Applications (SPA)
- **Typical Flow:** Authorization Code Flow with PKCE (never Implicit Flow)
- **Redirect URI:** HTTPS URL
- **Security:**
  - Never use the Implicit Flow (deprecated by both Google and Apple).
  - Use PKCE to protect against interception.
- **Best Practices:**
  - Store tokens in memory, not in localStorage/sessionStorage if possible.
  - Use short-lived tokens.
- **References:**
  - [Google OAuth 2.0 for Client-side Web Apps](https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow)
  - [Apple SSO for Web](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js)

### 5. Backend/Server-to-Server
- **Typical Flow:** OAuth 2.0 Client Credentials Flow
- **Redirect URI:** Not required (no user interaction)
- **Security:**
  - Store client secrets securely on the server.
  - Use strong authentication and authorization for API access.
- **Best Practices:**
  - Use for service-to-service communication only.
- **References:**
  - [Google OAuth 2.0 for Service Accounts](https://developers.google.com/identity/protocols/oauth2/service-account)

### Summary Table

| Use Case         | Recommended Flow         | Redirect URI Type         | Client Secret | PKCE Required | Token Storage      | Notes                                  |
|------------------|-------------------------|--------------------------|--------------|---------------|--------------------|-----------------------------------------|
| Web App          | Auth Code (PKCE/server) | HTTPS URL                | Yes (server) | Yes (public)  | Server-side        | Use HTTPS, CSRF protection              |
| Desktop App      | Auth Code (PKCE)        | Custom scheme/loopback   | No           | Yes           | Keychain/secure    | Never embed secrets, use PKCE           |
| Mobile App       | Auth Code (PKCE)        | Custom/Universal Link    | No           | Yes           | Keychain/Keystore   | Use system browser, PKCE                |
| SPA              | Auth Code (PKCE)        | HTTPS URL                | No           | Yes           | In-memory          | Never use Implicit Flow                 |
| Server-to-Server | Client Credentials      | N/A                      | Yes          | No            | Server-side        | No user interaction, API/service only   |

**Security Note:**
- Always use PKCE for public clients (desktop, mobile, SPA).
- Never embed client secrets in distributed apps.
- Always validate tokens on the backend for sensitive operations.
- Use secure storage for all tokens and credentials.

**References:**
- [OAuth 2.0 Security Best Current Practice (RFC 9207)](https://datatracker.ietf.org/doc/html/rfc9207)
- [Google OAuth 2.0 Use Cases](https://developers.google.com/identity/protocols/oauth2)
- [Apple Authentication Services](https://developer.apple.com/documentation/authenticationservices)

---

## References
- [Apple Sign In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Apple SSO Token Validation](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_js/incorporating_sign_in_with_apple_into_other_platforms)
- [Apple Error Codes](https://developer.apple.com/documentation/authenticationservices/asauthorizationerror/code)
- [Apple Human Interface Guidelines: Sign In with Apple](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/introduction/)
- [Apple Security Advisories](https://support.apple.com/en-us/HT201222)
- [Apple Accessibility Guide](https://developer.apple.com/accessibility/)
- [Google Identity Platform](https://developers.google.com/identity)
- [Google OAuth Client Setup](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Google PKCE Guide](https://developers.google.com/identity/protocols/oauth2/native-app#pkce)
- [Google Token Validation](https://developers.google.com/identity/sign-in/web/backend-auth)
- [Google OAuth Error Reference](https://developers.google.com/identity/protocols/oauth2/native-app#handlingresponse)
- [Google Sign-In Branding Guidelines](https://developers.google.com/identity/branding-guidelines)
- [Google Security Bulletins](https://cloud.google.com/support/bulletins)
- [macOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Platform Security](https://support.apple.com/guide/security/welcome/web)
- [Google Cloud Compliance](https://cloud.google.com/security/compliance)
- [SynchroNext Example Code](./)

---

*For further details, see the code comments and test suites in the Example macOS Application directory. This guide is maintained per .cursorrules and Context7 MCP standards. Last updated: 2024-06.* 