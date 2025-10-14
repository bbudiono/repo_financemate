import Foundation

/// Gmail API error types
enum GmailAPIError: LocalizedError {
    case invalidURL(String)
    case networkError(String)
    case apiError(Int, String)
    case invalidData(String)
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)"
        case .networkError(let message): return "Network error: \(message)"
        case .apiError(let code, let message): return "API error (\(code)): \(message)"
        case .invalidData(let message): return "Invalid data: \(message)"
        case .rateLimitExceeded: return "Rate limit exceeded"
        }
    }
}
