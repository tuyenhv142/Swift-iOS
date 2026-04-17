//
//  LoginView.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import SwiftUI

struct LoginView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Text("Taiwan Food Finder")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                    Text("Login to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)

                // Input Fields
                VStack(spacing: 15) {
                    TextField("Username", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)

                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Login Button
                Button(action: {
                    Task {
                        await viewModel.login()
                        if viewModel.isLoggedIn {
                            // Cập nhật lại AppState để UI chính thay đổi
                            appState.checkLoginStatus()
                            // Đóng popup
                            isPresented = false
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding()
            .task {
                // Tự động lấy mã tạm khi màn hình hiện lên
//                await viewModel.fetchInitialToken()
            }
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                // Sau khi login xong sẽ chuyển sang trang chủ
                ContentView()
//                Text("Chào mừng \(viewModel.username) đến với Đài Loan!")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { isPresented = false }
            }
        }
    }
}
