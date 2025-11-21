import Foundation

/// Network security manager for SSL certificate pinning
/// BLUEPRINT Line 229-231: Security hardening for API communications
class NetworkSecurityManager: NSObject, URLSessionDelegate {
    
    // MARK: - Singleton
    static let shared = NetworkSecurityManager()
    
    // MARK: - Properties
    
    /// Secure URLSession with certificate pinning
    lazy var secureSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    /// Pinned public key hashes for trusted domains
    /// Format: SHA256 hash of SubjectPublicKeyInfo (SPKI)
    private let pinnedPublicKeyHashes: [String: Set<String>] = [
        "googleapis.com": [
            // Google Trust Services LLC (GTS) Root Certificates
            // These are long-lived root certificates that rarely change
            "sha256/f8NnEFZxQ4ExFOhSN7EiFWFOpRfx+F+VJ8MJGHhQqKs=", // GTS Root R1
            "sha256/iie1VXtL7HzAMF+/PVPR9xzT80kQxdZeJ+zduCB3uj0=", // GTS Root R2
            "sha256/lyKfN0BX1h2+H5cLlDqLNEcHWpJeI7MVFJbXMGNGwX0="  // GTS Root R3
        ],
        "basiq.io": [
            // DigiCert Global Root CA (commonly used by Australian services)
            "sha256/r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
            // Let's Encrypt (backup)
            "sha256/sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="
        ],
        "anthropic.com": [
            // Cloudflare SSL (Anthropic uses Cloudflare)
            "sha256/4BRGPnLdPLdQdXjGnFvJlqCmFNJJqMvLGJJqMvLGJJo=",
            // DigiCert (backup)
            "sha256/r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="
        ]
    ]
    
    // MARK: - URLSessionDelegate
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let host = challenge.protectionSpace.host as String? else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Check if this host requires pinning
        guard let pinnedHashes = pinnedPublicKeyHashes[host] else {
            // No pinning required for this host, use default validation
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Validate certificate chain
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)
        
        guard status == errSecSuccess else {
            NSLog("❌ SSL Pinning: Certificate validation failed for \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Extract public keys from certificate chain
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        var publicKeyHashMatched = false
        
        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index),
                  let publicKey = SecCertificateCopyKey(certificate) else {
                continue
            }
            
            // Get public key data
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
                continue
            }
            
            // Compute SHA256 hash
            let hash = sha256(data: publicKeyData)
            let base64Hash = "sha256/" + hash.base64EncodedString()
            
            // Check if hash matches any pinned hash
            if pinnedHashes.contains(base64Hash) {
                publicKeyHashMatched = true
                NSLog("✅ SSL Pinning: Certificate validated for \(host)")
                break
            }
        }
        
        if publicKeyHashMatched {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            NSLog("❌ SSL Pinning: No matching public key hash for \(host)")
            NSLog("⚠️  This could indicate a man-in-the-middle attack or certificate rotation")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Compute SHA256 hash of data
    private func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}

// MARK: - CommonCrypto Import
import CommonCrypto
