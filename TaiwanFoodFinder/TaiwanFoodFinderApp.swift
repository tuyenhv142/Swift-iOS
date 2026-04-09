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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
