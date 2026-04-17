//
//  APIEndpoint.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation

enum HTTPMethod:String {
    case get = "GET"
    case post = "POST"
}

protocol APiEndpoint {
    var baseURL: String {get}
    var path: String {get}
    var method: HTTPMethod {get}
    var headers: [String:String]? {get}
    var queryItems: [URLQueryItem]? {get}
}
