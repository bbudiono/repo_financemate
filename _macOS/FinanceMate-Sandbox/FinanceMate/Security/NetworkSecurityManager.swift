//
//  NetworkSecurityManager.swift
//  FinanceMate
//
//  Purpose: Network security hardening and monitoring for API communications
//  Implements certificate pinning, request validation, and threat detection

import CryptoKit
import Foundation
import Network
import Security

@MainActor
public final class NetworkSecurityManager: NSObject, ObservableObject {
    public static let shared = NetworkSecurityManager()
    
    private let auditLogger = SecurityAuditLogger.shared
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkSecurityMonitor")
    
    // Certificate pinning configuration
    private let pinnedCertificates: [String: Data] = [
        "api.openai.com": Data(), // Add actual certificate data in production
        "accounts.google.com": Data(),
        "oauth2.googleapis.com": Data()
    ]
    
    // Request security configuration
    private let allowedHosts = [
        "api.openai.com",
        "accounts.google.com",
        "oauth2.googleapis.com",
        "www.googleapis.com"
    ]
    
    // Security metrics
    @Published public var networkSecurityScore: Double = 100.0
    @Published public var activeThreats: [NetworkThreat] = []
    @Published public var isSecureConnection: Bool = true
    
    private var requestCount: Int = 0
    private var secureRequestCount: Int = 0
    private var blockedRequestCount: Int = 0
    
    override private init() {
        super.init()
        setupNetworkMonitoring()
    }
    
    // MARK: - Secure URLSession Configuration
    
    /// Creates a hardened URLSession with security configurations
    public func createSecureURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        // Security hardening
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv13
        configuration.tlsMaximumSupportedProtocolVersion = .TLSv13
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        
        // Disable caching for sensitive data
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Custom headers for security
        configuration.httpAdditionalHeaders = [
            "User-Agent": "FinanceMate/1.0 (Secure)",
            "X-Requested-With": "FinanceMate",
            "Cache-Control": "no-cache, no-store, must-revalidate",
            "Pragma": "no-cache",
            "Expires": "0"
        ]
        
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
        
        return session
    }
    
    /// Validates and secures an outgoing request
    public func secureRequest(_ request: URLRequest) throws -> URLRequest {
        var securedRequest = request
        
        // Validate URL
        guard let url = request.url else {
            throw NetworkSecurityError.invalidURL
        }
        
        // Check against allowed hosts
        guard let host = url.host, allowedHosts.contains(host) else {
            auditLogger.log(event: .suspiciousActivity(
                details: "Blocked request to unauthorized host: \(url.host ?? "unknown")"
            ))
            blockedRequestCount += 1
            throw NetworkSecurityError.unauthorizedHost(url.host ?? "unknown")
        }
        
        // Ensure HTTPS
        guard url.scheme == "https" else {
            auditLogger.log(event: .suspiciousActivity(
                details: "Blocked insecure HTTP request to: \(url.absoluteString)"
            ))
            throw NetworkSecurityError.insecureProtocol
        }
        
        // Add security headers
        securedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        securedRequest.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        securedRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        // Add request signature for integrity
        if let body = request.httpBody {
            let signature = generateRequestSignature(url: url, body: body)
            securedRequest.setValue(signature, forHTTPHeaderField: "X-Request-Signature")
        }
        
        // Add timestamp for replay attack prevention
        let timestamp = String(Int(Date().timeIntervalSince1970))
        securedRequest.setValue(timestamp, forHTTPHeaderField: "X-Timestamp")
        
        requestCount += 1
        secureRequestCount += 1
        
        return securedRequest
    }
    
    /// Validates an incoming response for security
    public func validateResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkSecurityError.invalidResponse
        }
        
        // Check status code
        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkSecurityError.httpError(httpResponse.statusCode)
        }
        
        // Validate content type
        guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") else {
            throw NetworkSecurityError.missingContentType
        }
        
        // Check for security headers
        validateSecurityHeaders(httpResponse)
        
        // Validate response data
        if let data = data {
            try validateResponseData(data, contentType: contentType)
        }
        
        // Check response size limits
        if let data = data, data.count > 10 * 1024 * 1024 { // 10MB limit
            throw NetworkSecurityError.responseTooLarge
        }
    }
    
    // MARK: - Certificate Pinning
    
    private func validateCertificatePinning(for host: String, trust: SecTrust) -> Bool {
        guard let pinnedCertData = pinnedCertificates[host] else {
            // No pinned certificate for this host - allow but log
            auditLogger.log(event: .securityPolicyViolation(
                policy: "Certificate Pinning",
                details: "No pinned certificate configured for host: \(host)"
            ))
            return true
        }
        
        // Get server certificate
        guard let serverCert = SecTrustGetCertificateAtIndex(trust, 0) else {
            return false
        }
        
        // Get certificate data
        let serverCertData = SecCertificateCopyData(serverCert)
        let serverCertBytes = CFDataGetBytePtr(serverCertData)
        let serverCertLength = CFDataGetLength(serverCertData)
        
        let serverData = Data(bytes: serverCertBytes!, count: serverCertLength)
        
        // Compare with pinned certificate
        let isValid = serverData == pinnedCertData
        
        if !isValid {
            auditLogger.log(event: .suspiciousActivity(
                details: "Certificate pinning failed for host: \(host)"
            ))
            
            activeThreats.append(NetworkThreat(
                type: .certificatePinningFailure,
                host: host,
                detectedAt: Date(),
                severity: .high
            ))
        }
        
        return isValid
    }
    
    // MARK: - Request/Response Validation
    
    private func generateRequestSignature(url: URL, body: Data) -> String {
        let message = "\(url.absoluteString)\(body.base64EncodedString())"
        let signature = HMAC<SHA256>.authenticationCode(
            for: message.data(using: .utf8)!,
            using: getSigningKey()
        )
        return Data(signature).base64EncodedString()
    }
    
    private func getSigningKey() -> SymmetricKey {
        // In production, this would be a proper key derivation
        let keyData = "FinanceMate-Security-Key-2024".data(using: .utf8)!
        return SymmetricKey(data: SHA256.hash(data: keyData))
    }
    
    private func validateSecurityHeaders(_ response: HTTPURLResponse) {
        let requiredHeaders = [
            "Strict-Transport-Security",
            "Content-Security-Policy",
            "X-Content-Type-Options",
            "X-Frame-Options"
        ]
        
        var missingHeaders: [String] = []
        
        for header in requiredHeaders {
            if response.value(forHTTPHeaderField: header) == nil {
                missingHeaders.append(header)
            }
        }
        
        if !missingHeaders.isEmpty {
            auditLogger.log(event: .securityPolicyViolation(
                policy: "Security Headers",
                details: "Missing security headers: \(missingHeaders.joined(separator: ", "))"
            ))
        }
    }
    
    private func validateResponseData(_ data: Data, contentType: String) throws {
        // Validate JSON responses
        if contentType.contains("application/json") {
            do {
                _ = try JSONSerialization.jsonObject(with: data)
            } catch {
                throw NetworkSecurityError.invalidJSON
            }
        }
        
        // Check for suspicious content
        if let content = String(data: data, encoding: .utf8) {
            let suspiciousPatterns = [
                "<script",
                "javascript:",
                "data:text/html",
                "eval(",
                "document.write"
            ]
            
            for pattern in suspiciousPatterns {
                if content.lowercased().contains(pattern) {
                    auditLogger.log(event: .suspiciousActivity(
                        details: "Suspicious content detected in response: \(pattern)"
                    ))
                    throw NetworkSecurityError.suspiciousContent
                }
            }
        }
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.handleNetworkPathUpdate(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    private func handleNetworkPathUpdate(_ path: NWPath) {
        isSecureConnection = path.status == .satisfied
        
        // Log network changes
        auditLogger.log(event: .securityPolicyViolation(
            policy: "Network Monitoring",
            details: "Network path updated - Status: \(path.status), Interface: \(path.availableInterfaces.first?.type.rawValue ?? "unknown")"
        ))
        
        // Check for suspicious network conditions
        if path.isExpensive {
            auditLogger.log(event: .securityPolicyViolation(
                policy: "Network Security",
                details: "Connected to expensive network - increased security monitoring"
            ))
        }
        
        if path.isConstrained {
            auditLogger.log(event: .securityPolicyViolation(
                policy: "Network Security",
                details: "Connected to constrained network - potential security risk"
            ))
        }
        
        updateSecurityScore()
    }
    
    // MARK: - Threat Detection
    
    private func detectNetworkThreats() {
        // Rate limiting check
        let requestRate = Double(requestCount) / 60.0 // requests per second
        if requestRate > 10.0 {
            activeThreats.append(NetworkThreat(
                type: .highRequestRate,
                host: "various",
                detectedAt: Date(),
                severity: .medium
            ))
        }
        
        // Security ratio check
        let securityRatio = secureRequestCount > 0 ? Double(secureRequestCount) / Double(requestCount) : 0.0
        if securityRatio < 0.9 {
            activeThreats.append(NetworkThreat(
                type: .lowSecurityRatio,
                host: "various",
                detectedAt: Date(),
                severity: .medium
            ))
        }
        
        // Blocked requests check
        if blockedRequestCount > 5 {
            activeThreats.append(NetworkThreat(
                type: .multipleBlockedRequests,
                host: "various",
                detectedAt: Date(),
                severity: .high
            ))
        }
    }
    
    private func updateSecurityScore() {
        var score = 100.0
        
        // Deduct points for threats
        for threat in activeThreats {
            score -= threat.severity.scoreImpact
        }
        
        // Deduct points for network conditions
        if !isSecureConnection {
            score -= 30.0
        }
        
        // Deduct points for blocked requests
        score -= Double(blockedRequestCount) * 2.0
        
        networkSecurityScore = max(0.0, score)
    }
    
    // MARK: - Security Report
    
    public func generateNetworkSecurityReport() -> NetworkSecurityReport {
        detectNetworkThreats()
        updateSecurityScore()
        
        return NetworkSecurityReport(
            securityScore: networkSecurityScore,
            totalRequests: requestCount,
            secureRequests: secureRequestCount,
            blockedRequests: blockedRequestCount,
            activeThreats: activeThreats,
            isSecureConnection: isSecureConnection,
            certificatePinningEnabled: !pinnedCertificates.isEmpty
        )
    }
}

// MARK: - URLSessionDelegate

extension NetworkSecurityManager: URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let host = challenge.protectionSpace.host as String? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Validate certificate pinning
        let isPinningValid = validateCertificatePinning(for: host, trust: serverTrust)
        
        if isPinningValid {
            // Evaluate server trust
            let policy = SecPolicyCreateSSL(true, host as CFString)
            SecTrustSetPolicies(serverTrust, policy)
            
            var result: SecTrustResultType = .invalid
            let status = SecTrustEvaluate(serverTrust, &result)
            
            if status == errSecSuccess && (result == .unspecified || result == .proceed) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                auditLogger.log(event: .suspiciousActivity(
                    details: "Server trust evaluation failed for host: \(host)"
                ))
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// MARK: - Supporting Types

public struct NetworkThreat {
    let type: NetworkThreatType
    let host: String
    let detectedAt: Date
    let severity: ThreatSeverity
}

public enum NetworkThreatType {
    case certificatePinningFailure
    case highRequestRate
    case lowSecurityRatio
    case multipleBlockedRequests
    case suspiciousResponse
    case unauthorizedHost
}

public struct NetworkSecurityReport {
    let securityScore: Double
    let totalRequests: Int
    let secureRequests: Int
    let blockedRequests: Int
    let activeThreats: [NetworkThreat]
    let isSecureConnection: Bool
    let certificatePinningEnabled: Bool
}

public enum NetworkSecurityError: LocalizedError {
    case invalidURL
    case unauthorizedHost(String)
    case insecureProtocol
    case invalidResponse
    case httpError(Int)
    case missingContentType
    case invalidJSON
    case suspiciousContent
    case responseTooLarge
    case certificateValidationFailed
    case networkUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .unauthorizedHost(let host):
            return "Unauthorized host: \(host)"
        case .insecureProtocol:
            return "Insecure protocol - HTTPS required"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .missingContentType:
            return "Missing Content-Type header"
        case .invalidJSON:
            return "Invalid JSON response"
        case .suspiciousContent:
            return "Suspicious content detected in response"
        case .responseTooLarge:
            return "Response size exceeds limit"
        case .certificateValidationFailed:
            return "Certificate validation failed"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}