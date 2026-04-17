//
//  NetworkManager.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func request<T: Codable>(_ endpoint: APiEndpoint, body: [String: Any]? = nil) async throws -> T {
        // 1. Tạo URL từ baseURL và path
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else { throw URLError(.badURL) }
        
        // 2. Tạo URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // 3. Đính kèm Body nếu có
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        print(" Request: \(request.url?.absoluteString ?? "Lỗi URL")")
        print(" Method: \(request.httpMethod ?? "N/A")")
        
        // 4. Thực thi request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // 5. Giải mã JSON
        return try JSONDecoder().decode(T.self, from: data)
    }
}
