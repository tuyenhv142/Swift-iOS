import Foundation

// MARK: - Network Error

/// Typed errors produced by `NetworkManager`.
/// Replaces vague `NSError` / `URLError` with clear, user-readable messages.
enum NetworkError: LocalizedError {
    /// The URL could not be constructed from the endpoint + config.
    case badURL
    /// The request exceeded the configured `timeoutInterval`.
    case timeout
    /// The device has no internet connection or lost it mid-request.
    case noConnection
    /// The server responded with a non-2xx status code.
    /// - `statusCode`: HTTP status (e.g. 401, 500).
    /// - `message`: Parsed error body from the API, if available.
    case serverError(statusCode: Int, message: String)
    /// JSON decoding of a successful (2xx) response body failed.
    case decodingFailed(Error)
    /// An unclassified error occurred (e.g. unexpected `URLError` code).
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .timeout:
            return "Request timed out"
        case .noConnection:
            return "No internet connection"
        case .serverError(let code, let message):
            return message.isEmpty ? "Server error (\(code))" : message
        case .decodingFailed(let error):
            return "Data parsing failed: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
