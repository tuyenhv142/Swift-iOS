//
//  AppState.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import Foundation
internal import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var showLoginPopup: Bool = false
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        // Kiểm tra xem có Token trong Keychain không
        if let token = KeychainManager.shared.get("user_jwt_token"),
           let userData = UserDefaults.standard.data(forKey: "current_user") {
            
            // Giải mã thông tin user để hiển thị UI
            self.currentUser = try? JSONDecoder().decode(User.self, from: userData)
            print("🏠 Auto Login thành công: \(self.currentUser?.name ?? "")")
        } else {
            print("Guest Mode: Chưa đăng nhập")
        }
    }
    
    func logout() {
        KeychainManager.shared.delete("user_jwt_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
        self.currentUser = nil
    }
}
