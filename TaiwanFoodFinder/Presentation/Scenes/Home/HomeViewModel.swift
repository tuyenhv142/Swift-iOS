import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var restaurants: [RestaurantDTO] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let network = NetworkManager.shared

    func loadRestaurants(page: Int, limit: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await RestaurantRepository(network: network).getAll(page: page, limit: limit)
            self.restaurants = data
        } catch {
            // Refresh token and retry once
            print("⚠️ First attempt failed, refreshing token...")
            do {
                let token = try await AuthRepository(network: network).fetchPreToken()
                KeychainManager.shared.save(token, key: "app_jwt_token")
                let data = try await RestaurantRepository(network: network).getAll(page: page, limit: limit)
                self.restaurants = data
            } catch {
                self.errorMessage = error.localizedDescription
                print("❌ Load restaurants failed: \(error)")
            }
        }
        isLoading = false
    }
}
