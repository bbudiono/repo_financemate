# AI_MODEL_STM.MD
Created by cleanup_directory_structure.sh on Tue May 20 07:19:33 AEST 2025
Please update with proper content.

## [YYYY-MM-DD HH:MM UTC] Pre-Coding Assessment & Design Outline: Task 41.1 - Design Modular SSO Modal UI and Architecture

**Parent Task:** 41 - Implement Modular, Polished SSO Modal with Apple and Google Integration (P0 Feature)

**1. Task Understanding & Goal:**
   - Implement a modular, polished SSO modal for macOS (Sandbox) supporting Apple & Google Sign-In.
   - Adhere to Corporate Style Guide, `.cursorrules` (TDD, documentation, quality).
   - Handle loading/error states.
   - Be reusable.
   - Reference example code: `docs/ExampleCode/XcodeFiles/Example macOS Application/`.

**2. Research & Information Gathering (MCP Usage):**
   - **`web_search` (Google Sign-In):** Successfully retrieved Google's guidelines for macOS integration, including use of `GoogleSignInButton` for SwiftUI. (Logged in DEVELOPMENT_LOG.MD)
   - **`web_search` (Sign in with Apple HIG):** Failed to retrieve specific HIG for "Sign in with Apple" button and modal flow after multiple attempts. This is a minor impediment for precise Apple button styling/placement but general modal design can proceed. (Logged as an issue to resolve later or make best judgment based on common Apple UI patterns in DEVELOPMENT_LOG.MD).
   - **Local Example Code Review:** Planned: Analyze `docs/ExampleCode/XcodeFiles/Example macOS Application/` for UI patterns and modular component examples during implementation of 41.2.

**3. UI Elements & Layout (General Modal Design):**
   *(To be refined based on Corporate Style Guide and eventually Apple HIG for Sign in with Apple button)*
   - **Modal Container:** Standard macOS modal appearance (sheet or distinct window), Title (e.g., "Sign In"), Optional introductory text/app logo.
   - **SSO Provider Buttons:** "Sign in with Apple" (style pending HIG), "Sign in with Google" (using `GoogleSignInButton`). Vertically stacked.
   - **Loading Indicator:** `ProgressView` or similar, clearly visible.
   - **Error Display Area:** Clear text view for error messages.
   - **Close/Cancel Button:** Standard macOS modal close mechanism.

**4. State Management Strategy:**
   - `enum SSOModalState { case idle, loading(provider: SSOProvider), success(provider: SSOProvider, credential: SSOURCredential), error(provider: SSOProvider?, errorMessage: String) }`
   - `enum SSOProvider { case apple, google }`
   - `AuthViewModel` will hold this state as an `@Published` property.
   - `SSOURCredential` (struct/class): To hold user info/tokens post-authentication.

**5. Proposed Modular Architecture:**
   - **`SSOModalView` (Main View):** Manages state, initiates flows, displays UI. Takes `isPresented` binding and `onCompletion` closure.
   - **`SSOButtonView` (Reusable Component(s)):** Renders provider-specific buttons, delegates actions. (e.g., `AppleSignInButtonView`, `GoogleSignInButtonView`)
   - **`AuthViewModel` (ObservableObject):** Business logic, SDK interactions, updates `SSOModalState`. Injected into `SSOModalView`.
   - **Helper Services (e.g., `AppleAuthService`, `GoogleAuthService`):** Encapsulate SDK interactions, injected into `AuthViewModel`. (Protocols and Implementations).

**6. Accessibility Considerations:**
   - Descriptive `accessibilityLabel`s for all interactive elements.
   - Correct keyboard focus order.
   - Announce loading states and error messages to screen readers.
   - Adhere to contrast ratios.
   - Standard modal dismissal (Escape key).

**7. Props/Parameters for `SSOModalView`:**
   - `isPresented: Binding<Bool>`
   - `onCompletion: (Result<SSOURCredential, Error>) -> Void`
   - Optional: Configuration for dynamic provider display.

**8. Communication of Results:**
   - `onCompletion` closure called with `.success(credential)` or `.failure(error)`.
   - Cancellation handling to be defined (specific error or distinct callback).

**9. High-Level Implementation Plan for Task 41.1 (Design & Initial Structure - mostly conceptual for this subtask):**
   1.  Define file structure for `SSOModalView.swift`, `AuthViewModel.swift`, `SSOButtonView.swift` (Sandbox).
   2.  Define `SSOModalState`, `SSOProvider` enums, and `SSOURCredential` structure.
   3.  Outline `AuthViewModel` (state, placeholder methods).
   4.  Conceptual layout for `SSOModalView` (placeholders for buttons, error/loading).
   5.  Document plan in `AI_MODEL_STM.MD`, `DEVELOPMENT_LOG.MD`, `TASKS.MD` for 41.1.
   6.  Ensure new file stubs (created in 41.2) will have mandatory comment blocks.

**Risk Assessment for Task 41.1:**
- **Low-Medium Risk.**
- **Potential Challenges:**
    - Finalizing Apple Sign-In button style without direct HIG confirmation.
    - Ensuring true modularity for future providers.
    - Aligning with potential specifics in Corporate Style Guide for modals.
- **Learning Objectives:** macOS modal presentation (SwiftUI), state management for async auth, architectural patterns for UI.

**Decision:** Proceed with this design outline for Task 41.1. The primary output for 41.1 will be this documented design. Actual file creation and initial implementation will commence with Task 41.2.
