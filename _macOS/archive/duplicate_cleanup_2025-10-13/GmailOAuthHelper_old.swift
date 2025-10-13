import Foundation

struct GmailOAuthHelper {
    static func getAuthorizationURL(clientID: String) -> URL? {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/gmail.readonly"),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent")
        ]
        return components?.url
    }

    static func exchangeCodeForToken(code: String, clientID: String, clientSecret: String) async throws -> String {
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            throw GmailAPIError.invalidURL("oauth2.googleapis.com/token")
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "redirect_uri", value: "urn:ietf:wg:oauth:2.0:oob"),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)

        if let refreshToken = response.refreshToken {
            KeychainHelper.save(value: refreshToken, account: "gmail_refresh_token")
        }
        KeychainHelper.save(value: response.accessToken, account: "gmail_access_token")

        return response.refreshToken ?? ""
    }
}
