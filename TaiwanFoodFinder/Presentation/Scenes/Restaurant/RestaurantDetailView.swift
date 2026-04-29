//
//  RestaurantDetailView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/15.
//

import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: RestaurantDTO
    var showDismissButton: Bool = false
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: RestaurantViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var localReviews: [Review] = []
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 1. Ảnh Bìa (Cover Image)
                ZStack(alignment: .topLeading) {
                    if let imageUrl = restaurant.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 250)
                        .clipped()
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 250)
                    }

                    // Nút dismiss - chỉ hiện khi mở từ MapView (fullScreenCover)
                    if showDismissButton {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding(.top, 50)
                        .padding(.leading, 16)
                    }
                }
                
                // 2. Thông tin chi tiết
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(restaurant.category ?? "Ẩm thực Đài Loan")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        // Rating
                        if let rating = restaurant.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", rating))
                                    .fontWeight(.bold)
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    
                    Divider()
                    
                    // Địa chỉ
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                            .font(.title3)
                        
                        Text(restaurant.address)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Nút Chỉ đường (Mở Apple Maps thật)
                    Button(action: {
                        openAppleMaps()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Chỉ đường bằng Apple Maps")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    if !localReviews.isEmpty {
                        Divider()
                            .padding(.top, 10)
                        
                        Text("Customer Reviews (\(localReviews.count))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 4)
                        
                        // Duyệt qua từng review để hiển thị
                        ForEach(localReviews.indices, id: \.self) { index in
                            let review = localReviews[index]
                            ReviewRowView(review: review)
                        }
                    } else {
                        // Nếu chưa có đánh giá nào
                        Text("No reviews yet. Be the first to review!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.top, 10)
                    }
                    // Form Đánh Giá
                    ReviewFormView(viewModel: viewModel, restaurantId: restaurant.id,appState: appState,localReviews: $localReviews)
                }
                .padding(20)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            self.localReviews = restaurant.reviews ?? []
        }
    }
    
    private func openAppleMaps() {
        let urlString = "maps://?daddr=\(restaurant.lat),\(restaurant.lng)&dirflg=d"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// ==========================================
// THÊM MỚI: COMPONENT HIỂN THỊ TỪNG REVIEW
// ==========================================
struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Avatar giả định
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                
                // Tên người dùng (Kiểm tra theo struct Review của bạn, có thể là review.userName hoặc review.user?.name)
                // Chú ý: Hãy sửa biến `review.user?.name` cho khớp với tên biến trong file Model Review của bạn!
                Text(review.user?.name ?? "Anonymous")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Hiển thị số sao
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            // Nội dung comment
            Text(review.comment)
                .font(.body)
                .foregroundColor(.black.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.bottom, 4)
    }
}

// Form để viết Đánh giá (Giữ nguyên code của bạn)
struct ReviewFormView: View {
    @ObservedObject var viewModel: RestaurantViewModel
    var restaurantId: Int
    let appState: AppState
    
    @Binding var localReviews: [Review]
    @State private var comment: String = ""
    @State private var rating: Int = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Write a review")
                .font(.headline)
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.title2)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            
            TextEditor(text: $comment)
                .frame(height: 100)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            if viewModel.isReviewPosted {
                Text("Thank you for your feedback!")
                    .foregroundColor(.green)
                    .font(.footnote)
            }
            
            Button(action: submitReview) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("Send review")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(comment.isEmpty ? Color.gray : Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(comment.isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func submitReview() {
        guard !comment.isEmpty else { return }
        guard let currentUser = appState.currentUser else { return }
        
        viewModel.review = ReviewDTO( rating: rating, comment: comment)
        viewModel.restaurantId = restaurantId
        
        Task {
            
            await viewModel.submitReview()
            
            if viewModel.isReviewPosted {
                NotificationCenter.default.post(name: NSNotification.Name("ReviewPostedSuccess"), object: nil)
                                
                    // CẬP NHẬT GIAO DIỆN TỨC THÌ:
                    // Tạo một review ảo và nhét thẳng lên đầu danh sách (index 0)
                    // Lưu ý: Các tham số khởi tạo Review ở đây bạn tự điều chỉnh cho khớp với struct Review của bạn nhé!
                    let newReview = Review(
                        id: 0, // If your Review.id is Int, change this to 0
                        user: Users(id: currentUser.id, name: currentUser.name),
                        rating: rating,
                        comment: comment,
                        createdAt: ""
                        
                    )
                    
                    // Chèn lên đầu danh sách bằng animation mượt mà
                    withAnimation(.spring()) {
                        localReviews.insert(newReview, at: 0)
                    }
                    
                    // Xóa trắng form
                    comment = ""
                    rating = 5
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                viewModel.isReviewPosted = false
            }
        }
    }
}

