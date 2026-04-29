//
//  MapView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/14.
//

import SwiftUI
import MapKit

struct MapView: View {
    let restaurants: [RestaurantDTO]

    // 2. Khởi tạo đối tượng theo dõi vị trí
    @StateObject private var locationManager = LocationManager()
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.06885540186496, longitude: 120.17463043487109), // Tọa độ Annan, Tainan
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    @State private var selectedRestaurant: RestaurantDTO?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Map với MapContentBuilder
            Map(position: $cameraPosition) {
                
                // Hiển thị vị trí người dùng bằng UserAnnotation (Ghim màu xanh lam mặc định của Apple)
                UserAnnotation()
                
                ForEach(restaurants) { restaurant in
                    
                    let coordinate = CLLocationCoordinate2D(latitude: restaurant.lat, longitude: restaurant.lng)
                    
                    Annotation(restaurant.name, coordinate: coordinate) {
                        VStack {
                            if selectedRestaurant?.id == restaurant.id {
                                VStack {
                                    Text(restaurant.name)
                                        .font(.caption)
                                        .bold()
                                    
                                    // 3. Tính toán và hiển thị khoảng cách nếu có vị trí người dùng
                                    if let userLocation = locationManager.location {
                                        let distanceInMeters = calculateDistance(from: userLocation, to: coordinate)
                                        let distanceInKm = distanceInMeters / 1000
                                        
                                        Text(String(format: "Cách %.1f km", distanceInKm))
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(6)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.red)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedRestaurant = restaurant
                                        
                                        cameraPosition = .region(MKCoordinateRegion(
                                            center: coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        ))
                                    }
                                }
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // 4. Nút bấm để quay về vị trí hiện tại của người dùng
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if let userLocation = locationManager.location {
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                ))
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, selectedRestaurant == nil ? 40 : 180) // Đẩy nút lên cao nếu đang mở thẻ nhà hàng
                }
            }
            
            // Popup hiển thị thông tin nhà hàng dưới đáy màn hình
            if let selected = selectedRestaurant {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                selectedRestaurant = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                                .padding(.top, 8)
                        }
                    }
                    
//                    RestaurantCardView(restaurant: selected)
//                        .padding(.horizontal)
//                        .padding(.bottom, 20)
                    // Bọc RestaurantCardView vào trong một Button
                    Button(action: {
                        // Action để trống vì .fullScreenCover sẽ xử lý
                    }) {
                        RestaurantCardView(restaurant: selected)
                    }
                    .buttonStyle(PlainButtonStyle()) // Xóa hiệu ứng mờ chữ của iOS
                    // Gắn .fullScreenCover vào Button này để mở trang chi tiết full màn hình
                    .fullScreenCover(item: $selectedRestaurant) { restaurant in
                        RestaurantDetailView(
                            restaurant: restaurant,
                            showDismissButton: true,
                            viewModel: RestaurantViewModel(
                                restaurantId: restaurant.id,
                                review: ReviewDTO(rating: 0, comment: "")
                            )
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .background(Color(.systemGray6).opacity(0.95))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .transition(.move(edge: .bottom))
                .shadow(radius: 10)
            }
        }
    }
    
    // 5. Hàm tính khoảng cách (Dựa trên Haversine Formula)
    private func calculateDistance(from userLoc: CLLocationCoordinate2D, to destLoc: CLLocationCoordinate2D) -> CLLocationDistance {
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let destCLLocation = CLLocation(latitude: destLoc.latitude, longitude: destLoc.longitude)
        
        // return distance in meters
        return userCLLocation.distance(from: destCLLocation)
    }
}

// Extension bo góc (Giữ nguyên)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
