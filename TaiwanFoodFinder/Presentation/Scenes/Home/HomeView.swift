import SwiftUI

struct HomeView: View {
    // Nhận ViewModel chứa dữ liệu dùng chung từ ContentView
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. Header & Thanh tìm kiếm
                VStack(alignment: .leading, spacing: 12) {
                    Text("What you want to eat?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search for food name")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 2. Section: Quán Việt Nam tại Đài Nam (Lọc theo Category)
                let vietFood = viewModel.restaurants.filter { $0.category?.contains("Vietnamese") == true }
                if !vietFood.isEmpty {
                    HorizontalSection(title: "🇻🇳 Viet Nam taste", restaurants: vietFood)
                }
                
                // 3. Section: Trà Sữa & Giải Khát
                let boba = viewModel.restaurants.filter { $0.category?.contains("Bubble Tea") == true }
                if !boba.isEmpty {
                    HorizontalSection(title: "🧋 Milk tea", restaurants: boba)
                }
                
                // 4. Section: Đánh giá cao nhất (Lọc theo Rating > 4.5)
                let topRated = viewModel.restaurants.filter { ($0.rating ?? 0) >= 4.5 }
                if !topRated.isEmpty {
                    HorizontalSection(title: "🔥 Highly rated", restaurants: topRated)
                }
                
                let exploreAll = viewModel.restaurants
//                if !topRated.isEmpty {
                HorizontalSection(title: "Explore all", restaurants: exploreAll)
//                }
                
                // 5. Section: Tất cả quán ăn (Dạng danh sách dọc)
//                VStack(alignment: .leading) {
//                    Text("Explore all")
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .padding(.horizontal)
//                    
//                    ForEach(viewModel.restaurants) { restaurant in
//                        // Có thể dùng lại RestaurantCardView to ở đây
//                        RestaurantCardView(restaurant: restaurant)
//                            .padding(.horizontal)
//                            .padding(.bottom, 12)
//                    }
//                }
//                .padding(.top, 10)
            }
            .padding(.bottom, 100) // Đẩy lên để không bị che bởi TabBar
        }
        .navigationTitle("Khám phá")
        .navigationBarHidden(true)
    }
}

// Sub-Component để render một hàng cuộn ngang cho code gọn gàng
struct HorizontalSection: View {
    let title: String
    let restaurants: [RestaurantDTO]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            // Khung cuộn ngang (Horizontal ScrollView)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(restaurants) { restaurant in
                        // Khi bấm vào thẻ nhỏ, mở ra màn hình chi tiết
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant, viewModel: RestaurantViewModel(
                            restaurantId: restaurant.id,
                            review: ReviewDTO(rating: 5, comment: "") // Provide a default empty review
                        ))) {
                            MiniRestaurantCard(restaurant: restaurant)
                        }
                        .buttonStyle(PlainButtonStyle()) // Bỏ màu xanh mặc định của NavigationLink
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
