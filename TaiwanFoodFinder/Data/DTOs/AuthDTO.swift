//
//  AuthDTO.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation

// Wrapper chung cho mọi API của Hoang
struct APIResponseDTO<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

// DTO cho bước lấy mã tạm
struct PreAuthTokenDTO: Codable {
    let preAuthToken: String
}

// DTO cho bước đăng nhập
struct LoginResponseDTO: Codable {
    let accessToken: String
    let user: User
}

struct User: Codable {
    let id: Int
    let name: String
    let imageUrl: String?
}


