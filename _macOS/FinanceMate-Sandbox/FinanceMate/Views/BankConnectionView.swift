// SANDBOX FILE: For testing/development. See .cursorrules.

import SwiftUI

/*
 * Purpose: Bank connection interface for Basiq API integration - Australian bank connectivity
 * Issues & Complexity Summary: Complex OAuth flow UI, secure credential handling, real-time status
 * Key Complexity Drivers:
   - Logic Scope (Est. LoC): ~400
   - Core Algorithm Complexity: Medium-High (UI state management, secure forms)
   - Dependencies: SwiftUI, BasiqAPIService, Combine
   - State Management Complexity: High (connection states, form validation)
   - Novelty/Uncertainty Factor: Medium (Bank connection UX patterns)
 * AI Pre-Task Self-Assessment: 82%
 * Problem Estimate: 80%
 * Initial Code Complexity Estimate: 78%
 * Final Code Complexity: TBD
 * Overall Result Score: TBD
 * Key Variances/Learnings: TBD
 * Last Updated: 2025-08-08
 */

struct BankConnectionView: View {
  @StateObject private var basiqService = BasiqAPIService()
  @State private var selectedInstitution: BasiqInstitution?
  @State private var loginId = ""
  @State private var password = ""
  @State private var isConnecting = false
  @State private var showingConnectionForm = false
  @State private var searchText = ""
  @State private var showingSuccess = false
  @State private var connectionResult: String?

  // Security state
  @State private var isPasswordVisible = false
  @FocusState private var isLoginIdFocused: Bool
  @FocusState private var isPasswordFocused: Bool

  var filteredInstitutions: [BasiqInstitution] {
    if searchText.isEmpty {
      return basiqService.availableInstitutions
    } else {
      return basiqService.availableInstitutions.filter { institution in
        institution.name.localizedCaseInsensitiveContains(searchText)
          || institution.shortName.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Header
        headerSection

        Divider()

        // Main content
        if basiqService.isAuthenticated {
          if showingConnectionForm, let institution = selectedInstitution {
            connectionFormView(for: institution)
          } else {
            institutionSelectionView
          }
        } else {
          authenticationView
        }
      }
      .navigationTitle("Bank Connections")
      .navigationSubtitle("Connect your Australian bank accounts")
      .alert("Connection Successful", isPresented: $showingSuccess) {
        Button("OK") {
          showingSuccess = false
          showingConnectionForm = false
          selectedInstitution = nil
          clearForm()
        }
      } message: {
        Text("Your bank account has been successfully connected and is ready for transaction sync.")
      }
      .alert("Connection Error", isPresented: .constant(basiqService.errorMessage != nil)) {
        Button("OK") {
          basiqService.errorMessage = nil
        }
      } message: {
        if let error = basiqService.errorMessage {
          Text(error)
        }
      }
    }
    .task {
      if basiqService.isAuthenticated && basiqService.availableInstitutions.isEmpty {
        await fetchInstitutions()
      }
    }
  }

  // MARK: - Header Section

  private var headerSection: some View {
    VStack(spacing: 12) {
      HStack {
        Image(systemName: "building.columns.circle.fill")
          .font(.title)
          .foregroundColor(.blue)

        VStack(alignment: .leading, spacing: 4) {
          Text("Secure Bank Connection")
            .font(.headline)
            .fontWeight(.semibold)

          Text("Connect securely to Australian banks using Basiq")
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        // Connection status indicator
        connectionStatusIndicator
      }

      // Progress indicator
      if basiqService.connectionStatus == .connecting || basiqService.connectionStatus == .syncing {
        ProgressView()
          .progressViewStyle(LinearProgressViewStyle(tint: .blue))
          .frame(height: 4)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
  }

  private var connectionStatusIndicator: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(statusColor)
        .frame(width: 8, height: 8)

      Text(statusText)
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }

  private var statusColor: Color {
    switch basiqService.connectionStatus {
    case .connected:
      return .green
    case .connecting, .syncing:
      return .orange
    case .disconnected:
      return .gray
    case .error:
      return .red
    }
  }

  private var statusText: String {
    switch basiqService.connectionStatus {
    case .connected:
      return "Connected"
    case .connecting:
      return "Connecting"
    case .syncing:
      return "Syncing"
    case .disconnected:
      return "Disconnected"
    case .error:
      return "Error"
    }
  }

  // MARK: - Authentication View

  private var authenticationView: some View {
    VStack(spacing: 24) {
      Spacer()

      VStack(spacing: 16) {
        Image(systemName: "shield.checkered")
          .font(.system(size: 60))
          .foregroundColor(.blue)

        Text("Authenticate with Basiq")
          .font(.title2)
          .fontWeight(.semibold)

        Text("Secure authentication is required to connect to Australian banking institutions")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }

      Button(action: {
        Task {
          await authenticate()
        }
      }) {
        HStack {
          if basiqService.connectionStatus == .connecting {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(0.8)
          } else {
            Image(systemName: "key.fill")
          }

          Text("Authenticate")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .disabled(basiqService.connectionStatus == .connecting)
      .padding(.horizontal)

      Spacer()
    }
  }

  // MARK: - Institution Selection View

  private var institutionSelectionView: some View {
    VStack(spacing: 0) {
      // Search bar
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.secondary)

        TextField("Search banks and institutions...", text: $searchText)
          .textFieldStyle(.plain)

        if !searchText.isEmpty {
          Button("Clear") {
            searchText = ""
          }
          .font(.caption)
          .foregroundColor(.blue)
        }
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
      .padding(.horizontal)
      .padding(.bottom)

      // Institutions list
      ScrollView {
        LazyVStack(spacing: 8) {
          ForEach(filteredInstitutions) { institution in
            InstitutionRowView(institution: institution) {
              selectedInstitution = institution
              showingConnectionForm = true
            }
          }
        }
        .padding(.horizontal)
      }

      if filteredInstitutions.isEmpty && !basiqService.availableInstitutions.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "magnifyingglass.circle")
            .font(.system(size: 48))
            .foregroundColor(.secondary)

          Text("No institutions found")
            .font(.title3)
            .fontWeight(.medium)

          Text("Try adjusting your search terms")
            .font(.body)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      }
    }
  }

  // MARK: - Connection Form View

  private func connectionFormView(for institution: BasiqInstitution) -> some View {
    VStack(spacing: 24) {
      // Institution header
      HStack {
        Button("Back") {
          showingConnectionForm = false
          selectedInstitution = nil
          clearForm()
        }
        .foregroundColor(.blue)

        Spacer()

        VStack {
          Text(institution.name)
            .font(.headline)
            .multilineTextAlignment(.center)

          Text(institution.shortName)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        // Placeholder for back button alignment
        Text("Back")
          .foregroundColor(.clear)
      }
      .padding()

      // Connection form
      VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
          Text(institution.loginIdCaption ?? "Login ID")
            .font(.subheadline)
            .fontWeight(.medium)

          TextField(institution.loginIdCaption ?? "Enter your login ID", text: $loginId)
            .textFieldStyle(.roundedBorder)
            .focused($isLoginIdFocused)
            .textContentType(.username)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }

        VStack(alignment: .leading, spacing: 8) {
          Text(institution.passwordCaption ?? "Password")
            .font(.subheadline)
            .fontWeight(.medium)

          HStack {
            if isPasswordVisible {
              TextField(institution.passwordCaption ?? "Enter your password", text: $password)
                .focused($isPasswordFocused)
            } else {
              SecureField(institution.passwordCaption ?? "Enter your password", text: $password)
                .focused($isPasswordFocused)
            }

            Button(action: {
              isPasswordVisible.toggle()
            }) {
              Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
          }
          .textFieldStyle(.roundedBorder)
          .textContentType(.password)
        }

        // Security notice
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: "lock.shield")
              .foregroundColor(.green)

            Text("Your credentials are encrypted and secure")
              .font(.caption)
              .foregroundColor(.secondary)
          }

          Text(
            "FinanceMate uses bank-grade security to protect your information. Your login details are never stored and are only used to establish a secure connection."
          )
          .font(.caption2)
          .foregroundColor(.secondary)
          .padding(.leading, 24)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(.green.opacity(0.1)))
      }
      .padding()

      Spacer()

      // Connect button
      Button(action: {
        Task {
          await connectToBank()
        }
      }) {
        HStack {
          if isConnecting {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .scaleEffect(0.8)
          } else {
            Image(systemName: "link")
          }

          Text(isConnecting ? "Connecting..." : "Connect Account")
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(canConnect ? .blue : .gray)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .disabled(!canConnect || isConnecting)
      .padding()
    }
  }

  private var canConnect: Bool {
    !loginId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  // MARK: - Actions

  private func authenticate() async {
    do {
      try await basiqService.authenticate()
      await fetchInstitutions()
    } catch {
      // Error handling is managed by the service
    }
  }

  private func fetchInstitutions() async {
    do {
      try await basiqService.fetchInstitutions()
    } catch {
      // Error handling is managed by the service
    }
  }

  private func connectToBank() async {
    guard let institution = selectedInstitution else { return }

    isConnecting = true

    do {
      let connectionId = try await basiqService.createConnection(
        institutionId: institution.id,
        loginId: loginId.trimmingCharacters(in: .whitespacesAndNewlines),
        password: password
      )

      connectionResult = connectionId
      showingSuccess = true

      // Fetch updated connections
      try await basiqService.fetchConnections()

    } catch {
      // Error handling is managed by the service
    }

    isConnecting = false
  }

  private func clearForm() {
    loginId = ""
    password = ""
    isPasswordVisible = false
  }
}

// MARK: - Institution Row View

struct InstitutionRowView: View {
  let institution: BasiqInstitution
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 16) {
        // Institution icon placeholder
        RoundedRectangle(cornerRadius: 8)
          .fill(.blue.opacity(0.1))
          .frame(width: 48, height: 48)
          .overlay(
            Text(institution.shortName.prefix(2))
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(.blue)
          )

        VStack(alignment: .leading, spacing: 4) {
          Text(institution.name)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)

          HStack {
            Text(institution.institutionType.capitalized)
              .font(.caption)
              .foregroundColor(.secondary)

            if institution.authorization.adr {
              Text("• Open Banking")
                .font(.caption)
                .foregroundColor(.green)
            }
          }
        }

        Spacer()

        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel("Connect to \(institution.name)")
  }
}

// MARK: - Preview

struct BankConnectionView_Previews: PreviewProvider {
  static var previews: some View {
    BankConnectionView()
      .frame(width: 800, height: 600)
  }
}




