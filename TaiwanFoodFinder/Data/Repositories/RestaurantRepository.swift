//
//  RestaurantRepository.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import Foundation

class RestaurantRepository {
    func GetAll(page: Int, limit: Int) async throws -> [RestaurantDTO] {
        let response: APIResponseDTO<[RestaurantDTO]> = try await NetworkManager.shared.request(MainEndpoint.getRestaurant(page:page,limit:limit))
//        let endpoint = MainEndpoint.getRestaurant(page: page, limit: limit)
//        print("🌍 [GET] Calling API: \(endpoint.baseURL)\(endpoint.path)")
        if response.success, let data = response.data {
//            print(data)
            
            return data
            
        } else {
            throw NSError(
                domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: response.error ?? "Get failed"]
                
            )
            
        }
    }
    
    func postReview(restaurantId:Int,review: ReviewDTO) async throws -> ReviewDTO {
        
        let parameters: [String: Any] = [
                "rating": review.rating,
                "comment": review.comment
            ]
        print(parameters)
        let response: APIResponseDTO<ReviewDTO> = try await NetworkManager.shared.request(MainEndpoint.postReview(restaurantId: restaurantId),body: parameters)
        
        if response.success, let data = response.data {
            print(data)
            return data
        }else {
            throw NSError(
                domain: "AuthError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: response.error ?? "Get failed"]
            )
        }
    }
}
