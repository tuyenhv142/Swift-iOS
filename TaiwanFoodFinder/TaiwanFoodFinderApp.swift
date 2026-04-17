//
//  TaiwanFoodFinderApp.swift
//  TaiwanFoodFinder
//
//  Created by Hoang Mit on 2026/4/9.
//

import SwiftUI
import SwiftData

@main
struct TaiwanFoodFinderApp: App {
    @StateObject private var appState = AppState()
    init() {
        // Gọi lấy token ngay khi app vừa load vào bộ nhớ
        Task {
            // Chúng ta gọi thẳng vào Repository hoặc Service để lấy token
            let repo = AuthRepository()
            do {
                let token = try await repo.fetchPreToken()
                print("App running. Pre-Auth Token: \(token)")
                // Bạn có thể lưu vào UserDefaults để dùng sau
//                UserDefaults.standard.set(token, forKey: "pre_auth_token")
                KeychainManager.shared.save(token, key: "app_jwt_token")
            } catch {
                print("Failure to get pre-auth token: \(error)")
            }
        }
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
//            LoginView()
        }
        .modelContainer(sharedModelContainer)
    }
}
