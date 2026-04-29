import Foundation

// MARK: - Network Configuration

/// Immutable configuration for a `NetworkManager` instance.
///
/// Create one config per backend service you call:
/// ```swift
/// let config = NetworkConfig(
///     baseURL: "https://api.example.com/v1",
///     tokenProvider: KeychainTokenProvider(key: "auth_token")
/// )
/// ```
struct NetworkConfig {
    /// Root URL of the API (e.g. `"https://api.example.com/v1"`).
    /// Endpoint paths are appended to this.
    let baseURL: String

    /// Maximum time (seconds) a request can take before it is cancelled.
    /// Default: 30 seconds.
    let timeoutInterval: TimeInterval

    /// Headers sent on every request unless overridden by the endpoint.
    /// Default: `["Content-Type": "application/json"]`.
    let defaultHeaders: [String: String]

    /// Optional token source. When set, `NetworkManager` automatically adds
    /// `Authorization: Bearer <token>` to every request. An endpoint can
    /// still override this header if it needs a different token.
    let tokenProvider: TokenProvider?

    /// The `URLSession` used for all requests. Inject a custom session
    /// (e.g. with a different `URLCache` or for mocking in tests).
    let session: URLSession

    init(
        baseURL: String,
        timeoutInterval: TimeInterval = 30,
        defaultHeaders: [String: String] = ["Content-Type": "application/json"],
        tokenProvider: TokenProvider? = nil,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.defaultHeaders = defaultHeaders
        self.tokenProvider = tokenProvider
        self.session = session
    }
}

// MARK: - Service Registry

/// Central place to register all backend services.
///
/// Add a static property for each service your app talks to.
/// Each service gets its own `NetworkManager` with its own `NetworkConfig`
/// (different base URL, token, timeout, etc.).
///
/// ```swift
/// // Usage:
/// let data = try await NetworkService.main.request(SomeEndpoint.xyz)
/// let image = try await NetworkService.cdn.request(CDNEndpoint.abc)
/// ```
enum NetworkService {
    /// Primary API — restaurants, auth, reviews.
    static let main = NetworkManager(
        config: NetworkConfig(
            baseURL: "http://localhost:8765/api",
            tokenProvider: KeychainTokenProvider(key: "app_jwt_token")
        )
    )

    // Example: add more services here as the app grows
    //
    // static let cdn = NetworkManager(
    //     config: NetworkConfig(baseURL: "https://cdn.example.com")
    // )
    //
    // static let analytics = NetworkManager(
    //     config: NetworkConfig(
    //         baseURL: "https://analytics.example.com/v2",
    //         tokenProvider: StaticTokenProvider("analytics_key_xxx")
    //     )
    // )
}

// MARK: - Shared Convenience

extension NetworkManager {
    /// Default shared instance pointing to `NetworkService.main`.
    /// Convenient for apps with only one backend.
    static let shared = NetworkService.main
}
