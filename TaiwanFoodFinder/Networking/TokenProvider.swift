import Foundation

// MARK: - Token Provider Protocol

/// Abstracts token retrieval so `NetworkManager` never knows *where* the token comes from.
///
/// Conform to this protocol to plug in any token source:
/// - Keychain (per-user JWT)
/// - In-memory (session token)
/// - Hardcoded (API key for third-party services)
/// - Custom chain (try multiple sources, fallback logic, refresh on expiry)
protocol TokenProvider {
    /// Returns the current token, or `nil` if unavailable / expired.
    func getToken() -> String?
}

// MARK: - Built-in Providers

/// A token that never changes (e.g. API key, license key).
struct StaticTokenProvider: TokenProvider {
    private let token: String
    init(_ token: String) { self.token = token }
    func getToken() -> String? { token }
}

/// Reads a token from the iOS Keychain by key.
/// Useful for JWTs stored by `KeychainManager`.
struct KeychainTokenProvider: TokenProvider {
    private let key: String
    init(key: String) { self.key = key }
    func getToken() -> String? { KeychainManager.shared.get(key) }
}

/// Tries multiple `TokenProvider`s in order. The first non-nil result wins.
/// Useful for "check memory cache first, then fall back to Keychain" patterns.
struct CompositeTokenProvider: TokenProvider {
    private let providers: [TokenProvider]
    init(_ providers: [TokenProvider]) { self.providers = providers }
    func getToken() -> String? {
        for provider in providers {
            if let token = provider.getToken() { return token }
        }
        return nil
    }
}
