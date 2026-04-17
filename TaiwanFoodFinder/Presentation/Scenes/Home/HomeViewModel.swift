//
//  HomeViewModel.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation
internal import Combine

// @MainActor đảm bảo mọi cập nhật UI đều diễn ra trên Main Thread (luồng chính)
@MainActor
class HomeViewModel: ObservableObject {
    // @Published: Khi biến này thay đổi, SwiftUI sẽ tự động render lại giao diện
    @Published var restaurants: [RestaurantDTO] = []
    private let restaurantRepo = RestaurantRepository()
    // Hàm giả lập việc lấy dữ liệu từ Backend
    func loadRestaurants(page: Int, limit: Int) async{
        // Trong thực tế, đây là nơi gọi API (async/await)
        // Hiện tại dùng Mock Data để phát triển giao diện độc lập
//        self.restaurants = RestaurantDTO.mockdata
        do {
            let data = try await restaurantRepo.GetAll(page: page,limit: limit)
//            print(data)
            self.restaurants = data
        }catch {
            print(error)
        }
        
    }
}
