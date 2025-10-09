import Foundation
import os.log

/// Basiq API client for handling raw API requests
class BasiqAPIClient {

    private let logger = Logger(subsystem: "FinanceMate", category: "BasiqAPIClient")
    private let session = URLSession.shared
    private let authManager: BasiqAuthManager
    private let baseURL = "https://au-api.basiq.io"
    private let apiVersion = "3.0"

    init(authManager: BasiqAuthManager) {
        self.authManager = authManager
    }

    func fetchInstitutions() async throws -> [BasiqInstitution] {
        let url = URL(string: "\(baseURL)/institutions")!
        let request = try createAuthenticatedRequest(url: url)
        let response = try await performRequest(request: request, responseType: BasiqInstitutionsResponse.self)
        return response.data
    }

    func createConnection(institutionId: String, loginId: String, password: String) async throws -> String {
        let url = URL(string: "\(baseURL)/users/temp/connections")!
        let connectionData = ["institution": ["id": institutionId], "loginId": loginId, "password": password]
        let body = try JSONSerialization.data(withJSONObject: connectionData)
        let request = try createAuthenticatedRequest(url: url, method: "POST", body: body)
        let response = try await performRequest(request: request, responseType: BasiqConnectionResponse.self)
        return response.id
    }

    func fetchConnections() async throws -> [BasiqConnection] {
        let url = URL(string: "\(baseURL)/users/temp/connections")!
        let request = try createAuthenticatedRequest(url: url)
        let response = try await performRequest(request: request, responseType: BasiqConnectionsResponse.self)
        return response.data
    }

    func fetchTransactions(for connectionId: String, limit: Int = 500) async throws -> [BasiqTransaction] {
        let encodedId = connectionId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? connectionId
        let url = URL(string: "\(baseURL)/users/temp/transactions?filter=connection.id.eq('\(encodedId)')&limit=\(limit)")!
        let request = try createAuthenticatedRequest(url: url)
        let response = try await performRequest(request: request, responseType: BasiqTransactionsResponse.self)
        return response.data
    }

    private func performRequest<T: Decodable>(request: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BasiqAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 || httpResponse.statusCode == 202 else {
            throw BasiqAPIError.requestFailed("HTTP \(httpResponse.statusCode)")
        }

        return try JSONDecoder().decode(responseType, from: data)
    }

    private func createAuthenticatedRequest(url: URL, method: String = "GET", body: Data? = nil) throws -> URLRequest {
        guard let token = authManager.getAccessToken() else {
            throw BasiqAPIError.notAuthenticated
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(apiVersion, forHTTPHeaderField: "basiq-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return request
    }
}