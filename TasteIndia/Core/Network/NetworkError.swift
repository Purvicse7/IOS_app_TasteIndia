import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case noData
    case requestCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .invalidResponse:
            return "Received an unexpected server response."
        case .httpError(let statusCode):
            return "Server responded with HTTP status code \(statusCode)."
        case .decodingError(let message):
            return "Failed to parse data: \(message)"
        case .noData:
            return "No data was returned from the server."
        case .requestCancelled:
            return "The network request was cancelled."
        }
    }
}
