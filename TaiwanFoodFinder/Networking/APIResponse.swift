import Foundation

// MARK: - Generic API Response

/// Standard wrapper for backend responses that follow the `{ success, data, error }` envelope.
///
/// ```swift
/// let response: APIResponse<UserDTO> = try await network.request(...)
/// if response.success, let user = response.data { ... }
/// ```
struct APIResponse<T: Decodable>: Decodable {
    /// Whether the server considered the request successful.
    let success: Bool
    /// The decoded payload (only present when `success == true`).
    let data: T?
    /// Server-side error message (only present when `success == false`).
    let error: String?
}

// MARK: - Error-only Response

/// Lightweight decoder used internally to extract the `error` field
/// from a non-2xx response body without knowing the full `T` type.
struct APIErrorResponse: Decodable {
    let success: Bool
    let error: String?
}
