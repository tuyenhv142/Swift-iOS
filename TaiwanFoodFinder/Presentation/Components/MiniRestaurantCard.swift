//
//  MiniRestaurantCard.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/17.
//

import SwiftUI

struct MiniRestaurantCard: View {
    let restaurant: RestaurantDTO
    
    var body: some View {
        VStack(alignment: .leading) {
            // Ảnh Cover
            if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 160, height: 120)
                .clipped()
                .cornerRadius(12)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 160, height: 120)
                    .cornerRadius(12)
            }
            
            // Thông tin
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(2) // Chỉ cho phép dài 1 dòng
                
                Text(restaurant.category ?? "Ẩm thực")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", restaurant.rating ?? 0.0))
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(.top, 4)
        }
        .frame(width: 160)
    }
}
