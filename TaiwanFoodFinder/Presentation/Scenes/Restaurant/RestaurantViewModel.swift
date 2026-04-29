import Foundation
import Combine

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var isReviewPosted: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var restaurantId: Int

    var review: ReviewDTO

    private let network = NetworkManager.shared

    init(restaurantId: Int, review: ReviewDTO) {
        self.restaurantId = restaurantId
        self.review = review
    }

    func submitReview() async {
        guard restaurantId != 0 else {
            errorMessage = "Failed to submit review. Please try again"
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let _ = try await RestaurantRepository(network: network)
                .postReview(restaurantId: restaurantId, rating: review.rating, comment: review.comment)
            isReviewPosted = true
        } catch {
            print("❌ Error submitting review: \(error.localizedDescription)")
            errorMessage = "Failed to submit review. Please try again."
        }
    }
}
