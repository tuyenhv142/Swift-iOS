//
//  AuthRepository.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation

class AuthRepository {
    func fetchPreToken() async throws -> String {
        // Gọi NetworkManager với Endpoint tương ứng
        let response: APIResponseDTO<PreAuthTokenDTO> = try await NetworkManager.shared.request(MainEndpoint.getPreAuthToken, body: ["ApiKey": "REDACTED_API_KEY"])
        
        if let token = response.data?.preAuthToken {
            return token
        }
        throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: response.error ?? "Unknown"])
    }
    
    func login(username: String, password: String) async throws -> LoginResponseDTO {
        let response: APIResponseDTO<LoginResponseDTO> = try await NetworkManager.shared.request(
            MainEndpoint.login,
            body: [
                "username": username,
                "password": password
            ]
        )
        
        if response.success, let data = response.data {
            return data
        } else {
            throw NSError(
                domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: response.error ?? "Login failed"]
            )
        }
    }
}
