import Foundation

// Custom error types for better error handling and user feedback
enum APODError: LocalizedError {
    case networkTimeout
    case invalidURL
    case decodingError(String)
    case invalidDate
    case rateLimitExceeded
    case serverError(statusCode: Int)
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkTimeout:
            return "The request took too long. Please check your internet connection and try again."
        case .invalidURL:
            return "Invalid URL format. Please try again."
        case .decodingError(let details):
            return "Failed to process the data: \(details)"
        case .invalidDate:
            return "The selected date is outside the available range (June 16, 1995 - Today)"
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let code):
            return "Server error: \(code). NASA API might be temporarily unavailable."
        case .noInternetConnection:
            return "No internet connection. Please connect and try again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkTimeout:
            return "Check your internet connection and try again."
        case .rateLimitExceeded:
            return "Wait a moment before retrying."
        case .noInternetConnection:
            return "Connect to the internet and try again."
        default:
            return "Please try again later."
        }
    }
}
