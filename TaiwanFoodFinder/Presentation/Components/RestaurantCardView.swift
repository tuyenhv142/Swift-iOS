//
//  RestaurantCardView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import SwiftUI

struct RestaurantCardView: View {
    // Nhận dữ liệu từ View cha, không tự quản lý state để giữ tính "Stateless"
    let restaurant: RestaurantDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Phần hiển thị hình ảnh món ăn (Đã gọi hàm load ảnh thực)
            realImage(from: restaurant.imageUrl)
            
            // Phần hiển thị thông tin chi tiết
            restaurantInfo
        }
        .padding()
        .background(Color(.systemBackground)) // Tự động thích ứng Light/Dark Mode
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Nâng cấp: Hàm xử lý tải ảnh từ URL
    @ViewBuilder
    private func realImage(from urlString: String?) -> some View {
        // Kiểm tra xem backend có gửi link ảnh không
        if let urlString = urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // Trạng thái đang tải
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                case .success(let image):
                    // Tải thành công -> Hiển thị ảnh xịn
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity) // Ép full chiều ngang của thẻ
                        .frame(height: 150)
                        .clipped() // Xén bớt phần ảnh thừa
                        .cornerRadius(12)
                        
                case .failure:
                    // Link hỏng hoặc mất mạng
                    placeholderImage
                    
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            // Nếu imageUrl = nil thì dùng ngay ảnh mặc định
            placeholderImage
        }
    }
    
    // Giữ nguyên thiết kế cũ của Hoang Mit để làm ảnh dự phòng
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.orange.opacity(0.2))
            .frame(maxWidth: .infinity) // Bổ sung để luôn full ngang
            .frame(height: 150)
            .overlay(
                Image(systemName: "fork.knife") // Icon mặc định nếu chưa có ảnh thực
                    .font(.largeTitle)
                    .foregroundColor(.orange)
            )
            .cornerRadius(12)
    }
    
    private var restaurantInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(restaurant.name)
                .font(.title3)
                .bold()
            
            // Dùng ?? để xử lý Optional thay vì String(describing:) để tránh lỗi hiển thị "Optional(Món ăn)"
            Text("\(restaurant.city) • \(restaurant.category ?? "Đặc sản Đài Loan")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
