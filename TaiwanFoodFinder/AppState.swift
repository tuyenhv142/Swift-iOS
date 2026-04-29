import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var showLoginPopup: Bool = false
    @Published var isReady: Bool = false

    init() {
        checkLoginStatus()
    }

    func prepare() async {
        let repo = AuthRepository(network: .shared)
        do {
            let token = try await repo.fetchPreToken()
            KeychainManager.shared.save(token, key: "app_jwt_token")
            print("Pre-Auth Token ready")
        } catch {
            print("Failed to get pre-auth token: \(error)")
        }
        isReady = true
    }

    func checkLoginStatus() {
        if let token = KeychainManager.shared.get("user_jwt_token"),
           let userData = UserDefaults.standard.data(forKey: "current_user") {
            self.currentUser = try? JSONDecoder().decode(User.self, from: userData)
            print("🏠 Auto Login thành công: \(self.currentUser?.name ?? "")")
        } else {
            print("Guest Mode: Chưa đăng nhập")
        }
    }

    func logout() {
        KeychainManager.shared.delete("user_jwt_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
        self.currentUser = nil
    }
}
