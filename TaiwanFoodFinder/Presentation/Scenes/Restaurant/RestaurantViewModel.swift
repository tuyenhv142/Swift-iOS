//
//  RestaurantViewModel.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/16.
//

import Foundation
internal import Combine

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var isReviewPosted: Bool = false // Đổi từ isLoggedIn -> isReviewPosted
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var restaurantId: Int
    @Published var review: ReviewDTO
    
    
    // Truyền thẳng restaurantId vào hàm init sẽ an toàn hơn
    init(restaurantId: Int, review: ReviewDTO) {
        self.restaurantId = restaurantId
        self.review = review
    }
    
    private let restaurantRepo = RestaurantRepository()
    
    // Đổi tên hàm cho chuẩn với chức năng
    func submitReview() async {
        // Sửa lại logic: Bắt buộc ID phải KHÁC 0
        guard restaurantId != 0 else {
            errorMessage = "Falied to submit review. Please try again"
            return
        }
        
        isLoading = true
        
        defer { isLoading = false }
        
        errorMessage = nil
        
        do {
            // Chú ý: Check lại xem bên Repository bạn viết là postReview hay postReView (chữ V viết hoa)
            let _ = try await restaurantRepo.postReview(restaurantId: restaurantId, review: review)
            
            isReviewPosted = true
        } catch {
            // Sửa lại thông báo lỗi cho hợp lý
            print("❌ LỖI GỌI API: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Mã lỗi: \(nsError.code)")
                    print("Chi tiết: \(nsError.userInfo)")
                }
            errorMessage = "Đã xảy ra lỗi khi gửi đánh giá. Vui lòng thử lại!"
            print("Lỗi Add Review: \(error)") // Nên in ra console để dễ debug
        }
    }
}

