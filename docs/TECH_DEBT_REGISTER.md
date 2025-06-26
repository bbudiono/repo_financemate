# Technical Debt Register

**Objective:** To catalogue non-critical issues that impact code quality, maintainability, and scalability. This register should be consulted after the application is in a stable, buildable state.

---

### TD-001: Centralize Localizable Strings

- **Location:** `AnalyticsView.swift` (and likely others)
- **Issue:** User-facing strings are hardcoded directly in the SwiftUI `View` definitions. This prevents localization and makes updating text difficult and error-prone.
- **Example Strings:** `"Financial Analytics"`, `"Analytics Dashboard"`, `"Total Income"`, `"Spending Trends"`.
- **Remediation Plan:**
    1.  Create a `Localizable.strings` file in the project.
    2.  For each hardcoded string, create a key-value pair in the `.strings` file (e.g., `"analytics.title" = "Financial Analytics";`).
    3.  In the Swift code, replace the hardcoded string with a `Text("analytics.title")` call. SwiftUI will automatically handle the lookup.

---

### TD-002: Extract Magic Values into Constants

- **Location:** `AnalyticsView.swift`
- **Issue:** Numeric literals (for spacing, corner radii, view dimensions) and string literals (for default categories, states) are used directly in the code, reducing readability and making global style changes difficult.
- **Example Values:** `spacing: 20`, `cornerRadius: 8`, `maxWidth: 300`, `selectedCategory: "All"`.
- **Remediation Plan:**
    1.  Create a `StyleGuide.swift` or similar constants file.
    2.  Define static constants for common UI values (e.g., `static let standardSpacing: CGFloat = 16`, `static let defaultCornerRadius: CGFloat = 8`).
    3.  Define string constants in an appropriate enum or struct (e.g., `enum FilterState { static let all = "All" }`).
    4.  Replace all magic values in the code with references to these constants.

---

### TD-003: Centralize System Image Names

- **Location:** `AnalyticsView.swift`
- **Issue:** SFSymbol names are hardcoded as strings, which can lead to typos and makes it difficult to manage the app's icon set.
- **Example Strings:** `"chevron.down"`, `"chart.bar.doc.horizontal"`, `"arrow.up.circle.fill"`.
- **Remediation Plan:**
    1.  Create a `AppIcons.swift` or similar constants file.
    2.  Define an `enum` or `struct` containing static string constants for all system image names used in the app (e.g., `enum SFSymbol { static let chevronDown = "chevron.down" }`).
    3.  Replace all `Image(systemName: "...")` calls with `Image(systemName: SFSymbol. ...)` references.

---

### TD-004: Decompose Monolithic SwiftUI Views

- **Location:** `ContentView.swift`
- **Issue:** The `ContentView` struct has an excessive number of responsibilities. It contains the complete view logic for both the authenticated and unauthenticated states, as well as the action handlers for authentication results. This violates the Single Responsibility Principle, making the view difficult to read, maintain, and test.
- **Remediation Plan:**
    1.  Create a new `AuthenticationView.swift` file. Move all view code and related logic for the unauthenticated state (the login screen) into this new, dedicated view. `ContentView` should only contain a call to `AuthenticationView()` in its `else` block.
    2.  Create a new `MainAppView.swift` or `AuthenticatedView.swift`. Move the `NavigationSplitView` and all its related toolbar logic into this new view. `ContentView` will call this when `authService.isAuthenticated` is true.
    3.  Refactor authentication handlers (`handleSignInWithAppleResult`, `signInWithGoogle`) into the `AuthenticationService` view model, where they belong. The view should only be responsible for calling these methods (e.g., `authService.signInWithApple(result: result)`).
    4.  After these changes, `ContentView` should be a simple, lightweight router containing almost no UI code itself, only the top-level `if authService.isAuthenticated` condition.

---

### TD-005: Implement Safe, User-Facing Error Handling

- **Location:** `AuthenticationService.swift`
- **Issue:** The service directly exposes raw `error.localizedDescription` strings to the UI layer via a published `errorMessage`. This is a security risk and provides a poor user experience, as system error messages are not meant for end-users.
- **Remediation Plan:**
    1.  In `AuthenticationService`, define a simple, local `enum` for user-facing errors (e.g., `enum AuthDisplayError: Error { case signInFailed, networkUnavailable, unknownError }`).
    2.  In all `catch` blocks within the service, map the underlying system `Error` to a case from `AuthDisplayError`. For example, a network error would map to `.networkUnavailable`.
    3.  The service should publish this `AuthDisplayError?` enum instead of a `String?`.
    4.  The UI layer (`ContentView` or its children) will observe this error enum and present a pre-defined, localized, user-friendly message for each case (e.g., "Sign-In Failed. Please try again." or "Please check your internet connection.").

---

### TD-006: Remove "Magic Sleep" and Await Asynchronous Operations Deterministically

- **Location:** `AuthenticationService.swift`, in `signInWithApple()`
- **Issue:** The code uses `try await Task.sleep(...)` to wait for the `OAuth2Manager` to complete its work. This is a fragile code smell that indicates a race condition. The code is guessing how long an operation will take instead of properly awaiting its completion.
- **Remediation Plan:**
    1.  The `OAuth2Manager` must be refactored. Instead of relying on other services to guess when it's done, it should expose a mechanism for deterministic waiting. This can be an `AsyncStream`, a `PassthroughSubject<AuthenticatedUser>` from Combine, or a new `async` function that resolves only when authentication is fully complete.
    2.  The `signInWithApple` function in `AuthenticationService` must be updated to use this new mechanism. The `Task.sleep` call must be removed and replaced with a robust `await` on the new property or function from `OAuth2Manager`.

---

### File: `_macOS/FinanceMate/FinanceMate/Security/OAuth2Manager.swift`
- **Unsafe Error Handling:** The `authenticate(with:credentials:)` method uses `try?` when calling `keychainManager.store(credentials:for:)`, which means any failure to save credentials to the keychain is silently ignored. This could lead to a state where the user believes they are logged in, but their session will not persist.
- **Lack of Input Validation:** The method accepts a `Credentials` object but does not perform any validation on the `username` or `password` fields before attempting to use them.
- **Hardcoded Redirect URI:** `private let redirectURI = "com.ablankcanvas.financemate://oauth"` is a hardcoded custom URL scheme. This is inflexible and will break in different environments (e.g., debug vs. release). It should be loaded from a configuration file.
- **Hardcoded Google Endpoints:** The authorization, token, and revocation endpoints for Google's OAuth 2.0 service are all hardcoded as string literals. This makes the code brittle and difficult to update or point to a staging environment.
- **Incomplete Apple Sign-In Implementation:** The `authenticateWithApple()` method initiates a request but the delegate methods that handle the response (`authorizationController(controller:didCompleteWithAuthorization:)`) contain synthetic token creation logic with hardcoded expiration, rather than using the values provided by Apple.
- **Inappropriate use of `@MainActor`:** This class performs networking and cryptographic operations which should not be required to run on the main thread. While it publishes UI-related state, the work itself should be done on background threads, with only the final state updates dispatched to the main actor.
- **Insecure Fallback for `clientId`:** The line `ProcessInfo.processInfo.environment["OAUTH_CLIENT_ID"] ?? "financemate-client"` uses a predictable, hardcoded fallback client ID if the environment variable is not set. This is a significant security risk in improperly configured environments. Secrets should be handled via a dedicated management system, not environment variables.
- **Hardcoded Session Duration ("Magic Number"):** `keychainManager.storeSessionToken(sessionToken, expiresAt: Date().addingTimeInterval(3600))` uses the number `3600` directly in the code. This should be extracted into a named constant (e.g., `let oneHourInSeconds: TimeInterval = 3600`) for clarity and ease of maintenance.
- **Mocked Token Validation:** The function `verifyTokenSignature` returns `true` unconditionally. This represents a critical security vulnerability, as it completely bypasses JWT signature validation, effectively meaning the application will trust any token, regardless of its origin or integrity.
- **Forced-Unwrap Crash Potential:** The delegate method `presentationAnchor(for:)` uses `NSApplication.shared.windows.first!`, which will crash the entire application if it is called at a time when no windows are available.
- **Silent Error Handling in Token Revocation:** The `revokeTokens` function uses `_ = try? await URLSession.shared.data(for: request)`, which silently discards any network or server errors. The application has no way of knowing if token revocation failed, which could leave active sessions on the identity provider side.
- **Hardcoded Apple Token Expiration:** When handling an Apple Sign-In credential, the `expiresIn` value is hardcoded to `3600`. The token's actual expiration, provided by Apple in the `identityToken`, should be decoded and used instead.
- **Inconsistent Error Handling:** The class mixes multiple error handling strategies: throwing custom `OAuth2Error` types, assigning to a `@Published var authenticationError`, and using `try?` to silently ignore errors. A consistent strategy should be used to make the component's behavior predictable.
- **Redundant Token Object Creation:** For Apple Sign-In, a synthetic `OAuthTokens` object is created. While this is necessary to fit the manager's structure, it highlights a design flaw where the abstraction is leaky and doesn't cleanly support providers that don't use refresh tokens.

---

### File: `_macOS/FinanceMate/FinanceMate/Security/KeychainManager.swift`
- **Inappropriate use of `@MainActor`:** This class performs blocking I/O and cryptographic work, which should not be pinned to the main thread. This can cause UI freezes.
- **Hardcoded Service Name and Access Group:** The `serviceName` and `accessGroup` are hardcoded, making the class inflexible for use in different targets (e.g., tests) or build configurations. These should be configurable.
- **Insecure Custom Encryption:** The manager implements a custom encryption layer on top of the already-encrypted keychain. This layer is critically flawed: it derives its key from the device's easily-discoverable serial number, provides a false sense of security, and risks permanent data loss if the hardware changes or the serial number is unavailable (in which case it falls back to a static, known key). This entire custom encryption scheme should be removed.
- **Inefficient Keychain Updates:** The `store` method performs a `SecItemDelete` followed by a `SecItemAdd`. The correct, more efficient, and safer pattern is to attempt a `SecItemUpdate` first and only call `SecItemAdd` if the item does not exist (`errSecItemNotFound`).
- **Duplicated `OAuthTokens` Struct:** The file re-defines the `OAuthTokens` struct, which is also defined in `OAuth2Manager.swift`. This violates the DRY (Don't Repeat Yourself) principle and creates a risk of the two definitions diverging, leading to subtle bugs. A single definition should be shared in a common location.
- **Redundant Encryption:** The keychain is already a secure, encrypted store provided by the operating system. Adding another layer of custom encryption is unnecessary, adds complexity, and as implemented here, actually reduces the overall security of the system.

---

### File: `_macOS/FinanceMate/FinanceMate/Views/ContentView.swift`
- **Monolithic "God Object" View:** At over 1500 lines, this file contains the logic for the entire application, including authentication, navigation, view routing, state management, and definitions for multiple distinct sub-views. This is a critical architectural flaw that makes the code nearly impossible to maintain, test, or reason about.
- **Violation of Single Responsibility Principle:** The `ContentView` struct is responsible for far too much, acting as the view for both authenticated and unauthenticated states, handling user input, managing navigation, and controlling the presentation of sheets and side panels.
- **Authentication Logic in the View:** The view directly instantiates `AuthenticationService` and contains the full delegate handling logic for Sign in with Apple. This business logic must be extracted from the UI layer.
- **Hardcoded UI Strings and Values:** The view is filled with hardcoded strings (e.g., "Welcome to FinanceMate"), frame sizes, fonts, and colors, which prevents localization and makes maintaining a consistent design system impossible.
- **Overloaded State Management:** The view uses a large number of `@State` variables to manage the entire application's UI state, creating a complex and fragile web of dependencies within a single file.
- **Incorrect `AuthenticationService` Instantiation:** The service is created with `@StateObject` inside the view. For an app-wide service like this, it should be instantiated once at the root of the application (e.g., in the `App` struct) and provided to the view hierarchy as an `@EnvironmentObject`.
- **Private Views in Same File:** The file defines numerous other complex views (e.g., `SidebarView`, `DetailView`, various placeholder views) that are only usable within this file. Each distinct view should be in its own file.
- **Incomplete Placeholder UI:** The file is bloated with a large number of placeholder views, indicating that significant portions of the application are not implemented.
- **Confirmation of Scope Creep:** The view contains UI code for the "Multi-LLM Agent Coordination System" (MLACS), a complex backend feature that is out of scope for the user-facing application. This confirms its tentacles reach directly into the UI layer.
- **Inconsistent Naming and Duplication:** The presence of both a standalone `MLACSPlaceholderView` and a separate, inline view for the `.mlacs` navigation case suggests disorganized, copy-paste development.

---

### File: `_macOS/FinanceMate/FinanceMateTests/E2ETests/AuthenticationE2ETests.swift`
- **Misplaced UI Test File:** This is an `XCUITest` (UI Test) file, but it is located in the `FinanceMateTests` target, which is an `XCTest` (Unit Test) target. It is impossible to compile or run this test in its current location. This represents a fundamental misunderstanding of the Xcode testing framework.
- **Unreliable `UIInterruptionMonitor`:** The `testSuccessfulLoginJourney` uses the deprecated and notoriously flaky `addUIInterruptionMonitor` to handle the system-level Sign in with Apple dialog. The code's own comments admit this is a "fragile way" to write tests.
- **Fabricated Google Sign-In Test:** The `testGoogleSignInJourney` does not test the Google flow. It only asserts that the Google sign-in button does *not* exist. This creates a false impression of test coverage for a feature that isn't fully implemented in the view.
- **Reliance on Fabricated `ScreenshotService`:** The tests make calls to a `ScreenshotService.capture(...)` method. Given the overall state of the project, this is almost certainly a non-existent or non-functional piece of helper code, adding to the "Deception Index" of the test suite.