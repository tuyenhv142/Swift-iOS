import Foundation

class AuthRepository {
    private let network: NetworkManager

    init(network: NetworkManager) {
        self.network = network
    }

    func fetchPreToken() async throws -> String {
        let response: APIResponse<PreAuthTokenDTO> = try await network.request(
            MainEndpoint.getPreAuthToken(apiKey: AppConfig.apiKey)
        )
        if let token = response.data?.preAuthToken {
            return token
        }
        throw NetworkError.serverError(statusCode: 0, message: response.error ?? "Unknown")
    }

    func login(username: String, password: String) async throws -> LoginResponseDTO {
        let response: APIResponse<LoginResponseDTO> = try await network.request(
            MainEndpoint.login(username: username, password: password)
        )
        if response.success, let data = response.data {
            return data
        }
        throw NetworkError.serverError(statusCode: 0, message: response.error ?? "Login failed")
    }
}
