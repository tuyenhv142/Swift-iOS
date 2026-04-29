import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    @Published var username: String = ""
    @Published var password: String = ""

    private let network = NetworkManager.shared

    func login() async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        // Ensure pre-auth token exists
        if KeychainManager.shared.get("app_jwt_token") == nil {
            do {
                let token = try await AuthRepository(network: network).fetchPreToken()
                KeychainManager.shared.save(token, key: "app_jwt_token")
            } catch {
                errorMessage = "Cannot safely connect to the server"
                isLoading = false
                return
            }
        }

        do {
            let data = try await AuthRepository(network: network).login(username: username, password: password)
            KeychainManager.shared.save(data.accessToken, key: "user_jwt_token")
            if let encodedUser = try? JSONEncoder().encode(data.user) {
                UserDefaults.standard.set(encodedUser, forKey: "current_user")
            }
            isLoggedIn = true
        } catch {
            errorMessage = "Username or password is incorrect"
            print("❌ Login error: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
