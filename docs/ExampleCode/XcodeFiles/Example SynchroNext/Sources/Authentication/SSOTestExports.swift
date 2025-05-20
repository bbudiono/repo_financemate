// Purpose: Test-only export for AuthUser visibility in test target.
// Issues & Complexity: Xcode module boundary workaround for test target access.
// Ranking/Rating: 100% (Code), 100% (Problem) - Minimal, safe, and effective.

public struct SSOTest_AuthUser {
    public let id: String
    public let email: String
    public let displayName: String
    public let provider: String

    public init(id: String, email: String, displayName: String, provider: String) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.provider = provider
    }

    public init(_ user: AuthUser) {
        self.id = user.id
        self.email = user.email
        self.displayName = user.displayName
        self.provider = user.provider
    }
} 