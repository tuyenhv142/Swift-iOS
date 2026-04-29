import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    let reviewSuccessPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("ReviewPostedSuccess"))

    var body: some View {
        if !appState.isReady {
            VStack(spacing: 16) {
                ProgressView()
                Text("Loading...")
                    .foregroundColor(.secondary)
            }
            .task {
                await appState.prepare()
            }
        } else {
            TabView(selection: $selectedTab) {
                homeTab
                    .tabItem {
                        Label("Explore", systemImage: "safari")
                    }
                    .tag(0)

                mapTab
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .tag(1)

                userTab
                    .tabItem {
                        Label("Account", systemImage: "person.circle")
                    }
                    .tag(2)
            }
            .accentColor(.orange)
            .onAppear {
                Task {
                    await viewModel.loadRestaurants(page: 1, limit: 20)
                }
            }
            .onReceive(reviewSuccessPublisher) { _ in
                Task {
                    await viewModel.loadRestaurants(page: 1, limit: 20)
                }
            }
            .sheet(isPresented: $appState.showLoginPopup) {
                LoginView(isPresented: $appState.showLoginPopup)
                    .environmentObject(appState)
            }
        }
    }

    private var homeTab: some View {
        NavigationView {
            HomeView(viewModel: viewModel)
        }
    }

    private var mapTab: some View {
        NavigationView {
            MapView(restaurants: viewModel.restaurants)
        }
    }

    private var userTab: some View {
        NavigationView {
            AccountView()
        }
    }
}
