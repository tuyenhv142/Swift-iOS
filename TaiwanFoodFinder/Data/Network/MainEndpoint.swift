import Foundation

// MARK: - Main Endpoints

enum MainEndpoint {
    case getPreAuthToken(apiKey: String)
    case login(username: String, password: String)
    case getRestaurant(page: Int, limit: Int)
    case postReview(restaurantId: Int, rating: Int, comment: String)
}

extension MainEndpoint: APIEndpoint {

    var path: String {
        switch self {
        case .getPreAuthToken:      return "/auth/token"
        case .login:                return "/auth/login"
        case .getRestaurant:        return "/restaurants"
        case .postReview(let id, _, _): return "/restaurants/\(id)/reviews"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getPreAuthToken, .login, .postReview: return .post
        case .getRestaurant:                        return .get
        }
    }

    // Chỉ override khi cần token khác với config (app_jwt_token)
    // getPreAuthToken: không cần token
    // login, getRestaurant: dùng app_jwt_token từ TokenProvider (auto)
    // postReview: dùng user_jwt_token → override
    var headers: [String: String]? {
        if case .postReview = self,
           let token = KeychainManager.shared.get("user_jwt_token") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getRestaurant(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        default:
            return nil
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .getPreAuthToken(let apiKey):
            return PreAuthBody(apiKey: apiKey)
        case .login(let username, let password):
            return LoginBody(username: username, password: password)
        case .postReview(_, let rating, let comment):
            return ReviewBody(rating: rating, comment: comment)
        default:
            return nil
        }
    }
}

// MARK: - Request Body Models

private struct PreAuthBody: Encodable {
    let apiKey: String
    enum CodingKeys: String, CodingKey { case apiKey = "ApiKey" }
}

private struct LoginBody: Encodable {
    let username: String
    let password: String
}

private struct ReviewBody: Encodable {
    let rating: Int
    let comment: String
}

