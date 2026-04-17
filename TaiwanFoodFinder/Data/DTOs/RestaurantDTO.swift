//
//  Restaurant.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import Foundation


struct RestaurantDTO: Codable,Identifiable {
    let id: Int
    let name: String
    let address:String
    let city: String
    let rating: Double?
    let imageUrl: String?
    let category: String?
    let lat: Double
    let lng: Double
    let createdAt: String
    let updatedAt: String
    let reviews: [Review]?
}

struct Review : Codable {
    let id : Int
    let user: Users?
    let rating: Int
    let comment: String
    let createdAt: String
}

struct Users : Codable {
    let id: Int
    let name: String
}

struct ReviewDTO : Codable {
    let rating: Int
    let comment: String
}
