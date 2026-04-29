//
//  TaiwanFoodFinderApp.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import SwiftUI

@main
struct TaiwanFoodFinderApp: App {
    @StateObject private var appState = AppState()
    init() {
        configureURLCache()
    }

    private func configureURLCache() {
        let memoryCapacity = 50 * 1024 * 1024   // 50 MB
        let diskCapacity = 200 * 1024 * 1024    // 200 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        URLCache.shared = cache
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
    }
}
