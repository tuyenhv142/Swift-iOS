import Foundation

// MARK: - HTTP Method

/// Standard HTTP methods supported by the networking layer.
enum HTTPMethod: String {
    /// Retrieve a resource (no body).
    case get    = "GET"
    /// Create a new resource.
    case post   = "POST"
    /// Replace an existing resource entirely.
    case put    = "PUT"
    /// Partially update an existing resource.
    case patch  = "PATCH"
    /// Remove a resource.
    case delete = "DELETE"
}
