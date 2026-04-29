import Foundation

class RestaurantRepository {
    private let network: NetworkManager

    init(network: NetworkManager) {
        self.network = network
    }

    func getAll(page: Int, limit: Int) async throws -> [RestaurantDTO] {
        let response: APIResponse<[RestaurantDTO]> = try await network.request(
            MainEndpoint.getRestaurant(page: page, limit: limit)
        )
        if response.success, let data = response.data {
            return data
        }
        throw NetworkError.serverError(statusCode: 0, message: response.error ?? "Get failed")
    }

    func postReview(restaurantId: Int, rating: Int, comment: String) async throws -> ReviewDTO {
        let response: APIResponse<ReviewDTO> = try await network.request(
            MainEndpoint.postReview(restaurantId: restaurantId, rating: rating, comment: comment)
        )
        if response.success, let data = response.data {
            return data
        }
        throw NetworkError.serverError(statusCode: 0, message: response.error ?? "Post failed")
    }
}
