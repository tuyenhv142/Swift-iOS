import Foundation

// MARK: - Network Manager

/// The core networking engine. Thin wrapper around `URLSession` that:
/// - Builds a `URLRequest` from `NetworkConfig` + `APIEndpoint`
/// - Auto-injects `Authorization` header via `TokenProvider`
/// - Encodes JSON body from `Encodable`
/// - Parses server error messages from non-2xx response bodies
/// - Maps `URLError` codes to typed `NetworkError`
///
/// Create one `NetworkManager` per backend service via `NetworkConfig`:
/// ```swift
/// let network = NetworkManager(
///     config: NetworkConfig(baseURL: "https://api.example.com")
/// )
/// let user: UserDTO = try await network.request(UserEndpoint.getProfile)
/// ```
final class NetworkManager {
    private let config: NetworkConfig
    private let decoder: JSONDecoder

    /// - Parameters:
    ///   - config: Base URL, timeout, headers, token provider, session.
    ///   - decoder: JSONDecoder used for all responses. Customise `keyDecodingStrategy`,
    ///              `dateDecodingStrategy`, etc. here.
    init(config: NetworkConfig, decoder: JSONDecoder = JSONDecoder()) {
        self.config = config
        self.decoder = decoder
    }

    // MARK: - Public API

    /// Executes a request described by `endpoint` and decodes the response into `T`.
    ///
    /// - Parameter endpoint: A type conforming to `APIEndpoint` that fully describes the request.
    /// - Returns: The decoded response body of type `T`.
    /// - Throws: `NetworkError` on failure (never throws `URLError` directly).
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(from: endpoint)
        logRequest(request)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await config.session.data(for: request)
        } catch let error as URLError {
            throw mapURLError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }

        logResponse(httpResponse, data)

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = parseErrorMessage(from: data) ?? ""
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: - Request Building

    /// Assembles a `URLRequest` by merging config defaults with endpoint-specific values.
    ///
    /// Header merge order (last wins):
    /// 1. `NetworkConfig.defaultHeaders`
    /// 2. `Authorization: Bearer <token>` from `NetworkConfig.tokenProvider` (if set)
    /// 3. `APIEndpoint.headers` (use this to override the token per-request)
    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        guard var components = URLComponents(string: config.baseURL + endpoint.path) else {
            throw NetworkError.badURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = config.timeoutInterval

        // Layer 1 — config defaults
        var allHeaders = config.defaultHeaders

        // Layer 2 — auto token from TokenProvider
        if let token = config.tokenProvider?.getToken() {
            allHeaders["Authorization"] = "Bearer \(token)"
        }

        // Layer 3 — endpoint overrides (e.g. different token for a specific route)
        if let endpointHeaders = endpoint.headers {
            allHeaders.merge(endpointHeaders) { _, new in new }
        }

        request.allHTTPHeaderFields = allHeaders

        // Encode body from any Encodable struct / dict
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        return request
    }

    // MARK: - Error Mapping

    /// Converts `URLError` codes to semantic `NetworkError` cases,
    /// so callers only deal with `NetworkError`.
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        default:
            return .unknown(error)
        }
    }

    /// Attempts to extract the `error` field from a JSON error response body.
    /// Falls back to the raw body string if decoding fails.
    private func parseErrorMessage(from data: Data) -> String? {
        if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
            return errorResponse.error
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Debug Logging

    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("📡 \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        if let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
            print("📦 Body: \(json)")
        }
        #endif
    }

    private func logResponse(_ response: HTTPURLResponse, _ data: Data) {
        #if DEBUG
        let icon = (200...299).contains(response.statusCode) ? "✅" : "❌"
        print("\(icon) HTTP \(response.statusCode)")
        if !((200...299).contains(response.statusCode)),
           let body = String(data: data, encoding: .utf8) {
            print("❌ Body: \(body)")
        }
        #endif
    }
}

// MARK: - Type-Erased Encodable

/// Wraps any `Encodable` value so it can be passed to `JSONEncoder.encode()`.
/// Swift does not allow `any Encodable` directly as an argument to a generic
/// function, so we box it here.
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
