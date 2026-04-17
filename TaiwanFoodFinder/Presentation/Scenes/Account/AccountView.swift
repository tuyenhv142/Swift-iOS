//
//  AccountView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationView {
            VStack {
                if let user = appState.currentUser {
                    // Nếu đã login: Hiện thông tin User
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.orange)
                        
                        Text("Hello, \(user.name)")
                            .font(.title2).bold()
                        
                        Button("Logout") {
                            appState.logout()
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                } else {
                    // Nếu chưa login: Hiện nút yêu cầu đăng nhập
                    VStack(spacing: 20) {
                        Text("You are not logged in.")
                            .foregroundColor(.gray)
                        
                        Button("Login") {
                            appState.showLoginPopup = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
    
}
