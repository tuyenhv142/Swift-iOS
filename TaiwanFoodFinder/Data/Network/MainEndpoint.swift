//
//  AuthEndpoint.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation

enum MainEndpoint: APiEndpoint {
    case getPreAuthToken
    case login
    
    //restaurant
    
    case getRestaurant(page : Int,limit : Int)
    case postReview(restaurantId: Int)
    

    var baseURL: String {
        return "http://10.67.68.154:8765/api" // Hoặc IP máy của Hoang
    }

    var path: String {
        switch self {
            case .getPreAuthToken: return "/auth/token"
            case .login: return "/auth/login"
            case .getRestaurant: return "/restaurants"
            case .postReview(let restaurantId): return "/restaurants/\(restaurantId)/reviews"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getPreAuthToken, .login, .postReview:
            return .post
        case .getRestaurant:
            return .get
        }
    }

    var headers: [String : String]? {
        var headers = ["Content-Type": "application/json"]
        
        switch self {
        case .getRestaurant,.login:
            if let token = KeychainManager.shared.get("app_jwt_token") {
                headers["Authorization"] = "Bearer \(token)"
            }
        case .postReview:
            if let token = KeychainManager.shared.get("user_jwt_token") {
                headers["Authorization"] = "Bearer \(token)"
            }
        default:
            break
        }
        
        return headers
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getRestaurant(let page, let limit):
            // Swift sẽ tự động ghép thành ?page=1&limit=20 cực kỳ an toàn
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        default:
            return nil
        }
    }
}
