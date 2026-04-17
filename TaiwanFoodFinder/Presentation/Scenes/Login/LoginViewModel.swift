//
//  LoginViewModel.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/10.
//

import Foundation
internal import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    @Published var username: String = ""
    @Published var password: String = ""
    
    private let authRepo = AuthRepository()
    
    private func getValidAuthToken() async -> String? {
        if let token = UserDefaults.standard.string(forKey:"pre_auth_token"), !token.isEmpty {
            return token
        }
        do {
            let preToken = try await authRepo.fetchPreToken()
            UserDefaults.standard.set(preToken, forKey: "pre_auth_token")
            return preToken
        } catch {
            return nil
        }
    }
    
    func login() async{
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let preAuthToken  = await getValidAuthToken() else {
            errorMessage = "Can not safely conect to the server"
            isLoading = false
            return
        }
        
        do {
            let data = try await authRepo.login(username: username, password: password )
            
            print("\(username),\(password)")
            KeychainManager.shared.save(data.accessToken, key: "user_jwt_token")
            let encoder = JSONEncoder()
            if let encodedUser = try? encoder.encode(data.user) {
                UserDefaults.standard.set(encodedUser, forKey: "current_user")
            }
            
            isLoggedIn = true
        } catch {
            errorMessage = "Username or password is incorrect"
            print("❌ LỖI GỌI API: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Mã lỗi: \(nsError.code)")
                    print("Chi tiết: \(nsError.userInfo)")
                }
        }
        isLoading = false
    }
        
    
    
}
