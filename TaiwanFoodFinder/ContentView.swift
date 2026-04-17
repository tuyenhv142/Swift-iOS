//
//  ContentView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import SwiftUI

struct ContentView: View {
    // Quản lý trạng thái tab hiện tại đang được chọn
    @State private var selectedTab: Int = 0
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    let reviewSuccessPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("ReviewPostedSuccess"))
    var body: some View {
        // TabView giúp tạo thanh điều hướng (Bottom Bar) chuyên nghiệp
        TabView(selection: $selectedTab) {
            
            // --- TAB 1: TRANG CHỦ ---
            homeTab
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
                .tag(0)
            
            // --- TAB 2: BẢN ĐỒ ---
            // Hiện tại dùng tạm một View trống để build sau
            mapTab
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            // --- TAB 3: CÀI ĐẶT ---
            userTab
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
                .tag(2)
        }
        // AccentColor giúp định màu cho icon khi được chọn (ví dụ màu cam cho ẩm thực)
        .accentColor(.orange)
        .onAppear {
//            appState.checkLoginStatus()
            Task {
                await viewModel.loadRestaurants(page:1,limit: 20)
            }
        
        }
        .onReceive(reviewSuccessPublisher) { _ in
            print("🔄 Đã nghe thấy thông báo! Đang tải lại danh sách nhà hàng...")
            
            // Gọi lại hàm load dữ liệu của bạn ở đây
            // Ví dụ:
            Task {
                await viewModel.loadRestaurants(page: 1, limit: 20)
            }
        }
        // 2. POPUP LOGIN: Tự động hiển thị khi showLoginPopup = true
        .sheet(isPresented: $appState.showLoginPopup) {
            LoginView(isPresented: $appState.showLoginPopup)
                // Phải truyền environmentObject vào sheet vì sheet là một cây View mới
                .environmentObject(appState)
        }
    }
    
    // Tách logic màn hình Home ra một biến riêng để code gọn gàng hơn (Refactoring)
    private var homeTab: some View {
        NavigationView {
            // Sử dụng mã nguồn cũ của bạn đã có ViewModel
            HomeView(viewModel: viewModel)
        }
    }
    
    private var mapTab: some View {
        NavigationView {
            // Sử dụng mã nguồn cũ của bạn đã có ViewModel
            MapView(restaurants: viewModel.restaurants)
        }
    }
    
    private var userTab: some View {
        NavigationView {
            // Sử dụng mã nguồn cũ của bạn đã có ViewModel
            AccountView()
        }
    }
}

