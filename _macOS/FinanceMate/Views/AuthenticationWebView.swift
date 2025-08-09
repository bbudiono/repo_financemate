import SwiftUI
import WebKit

/// OAuth2 Authentication WebView for CDR-compliant bank authentication
struct AuthenticationWebView: NSViewRepresentable {
    let url: URL
    let onAuthorizationCode: (String, String?) -> Void
    let onError: (Error) -> Void
    let onCancel: () -> Void
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: AuthenticationWebView
        
        init(_ parent: AuthenticationWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // Check if this is a callback URL
            if url.scheme == "financemate" && url.host == "auth" {
                handleCallback(url: url)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        private func handleCallback(url: URL) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            // Check for error parameter first
            if let error = components?.queryItems?.first(where: { $0.name == "error" })?.value {
                let errorDescription = components?.queryItems?.first(where: { $0.name == "error_description" })?.value
                let authError = AuthenticationError.authorizationFailed(error, errorDescription)
                parent.onError(authError)
                return
            }
            
            // Look for authorization code
            if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
                let state = components?.queryItems?.first(where: { $0.name == "state" })?.value
                parent.onAuthorizationCode(code, state)
                return
            }
            
            // No valid callback parameters found
            parent.onError(AuthenticationError.invalidCallback("No authorization code found in callback"))
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError(error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onError(error)
        }
    }
}

// MARK: - Authentication Errors

enum AuthenticationError: LocalizedError {
    case authorizationFailed(String, String?)
    case invalidCallback(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let error, let description):
            if let description = description {
                return "Authorization failed: \(error) - \(description)"
            } else {
                return "Authorization failed: \(error)"
            }
        case .invalidCallback(let message):
            return "Invalid callback: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Bank Authentication Sheet

struct BankAuthenticationSheet: View {
    @Binding var isPresented: Bool
    let bank: BankType
    let authURL: URL
    let onSuccess: (String, String?) -> Void
    let onError: (Error) -> Void
    
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading \(bank.displayName) Authentication...")
                            .font(.headline)
                        Text("Please wait while we redirect you to \(bank.displayName) to authorize access to your account data.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    AuthenticationWebView(
                        url: authURL,
                        onAuthorizationCode: { code, state in
                            onSuccess(code, state)
                            isPresented = false
                        },
                        onError: { error in
                            onError(error)
                            isPresented = false
                        },
                        onCancel: {
                            isPresented = false
                        }
                    )
                }
            }
            .navigationTitle("\(bank.displayName) Authentication")
            .navigationSubtitle("Consumer Data Right Authorization")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            // Simulate loading delay to show user what's happening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BankAuthenticationSheet(
        isPresented: .constant(true),
        bank: .anz,
        authURL: URL(string: "https://example.com/auth")!,
        onSuccess: { _, _ in },
        onError: { _ in }
    )
}