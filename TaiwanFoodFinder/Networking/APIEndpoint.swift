import Foundation

// MARK: - API Endpoint Protocol

/// Describes a single API request.
///
/// Conform your endpoint enum to this protocol. Each case fully defines
/// one network call — path, method, headers, query params, and body.
///
/// ```swift
/// enum UserEndpoint: APIEndpoint {
///     case getProfile(userId: Int)
///
///     var path: String { "/users/\(userId)" }
///     var method: HTTPMethod { .get }
/// }
/// ```
///
/// - Note: `headers` override or extend the `NetworkConfig.defaultHeaders`.
///         Use this for endpoint-specific auth (e.g. a different JWT per route).
protocol APIEndpoint {
    /// URL path appended to `NetworkConfig.baseURL` (e.g. `"/auth/login"`).
    var path: String { get }

    /// HTTP method for this request.
    var method: HTTPMethod { get }

    /// Additional headers merged on top of `NetworkConfig.defaultHeaders`.
    /// Return a different `Authorization` header here to override the config's `TokenProvider`.
    var headers: [String: String]? { get }

    /// Query parameters appended to the URL (`?key=value`).
    var queryItems: [URLQueryItem]? { get }

    /// JSON-encodable request body. `nil` for GET / DELETE requests.
    var body: (any Encodable)? { get }
}

// MARK: - Defaults

extension APIEndpoint {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: (any Encodable)? { nil }
}
