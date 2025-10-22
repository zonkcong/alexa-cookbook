import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ReelsContainerView()
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Reels")
                }

            MarketplaceView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Marketplace")
                }

            DatingView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Dating")
                }
        }
        .background(.ultraThinMaterial)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Home")
                    .font(.largeTitle.weight(.bold))
                Text("News Feed placeholder")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GlassBackground())
            .navigationTitle("Home")
        }
    }
}

struct MarketplaceView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Marketplace")
                    .font(.largeTitle.weight(.bold))
                Text("Browse items near you")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GlassBackground())
            .navigationTitle("Marketplace")
        }
    }
}

struct DatingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Dating")
                    .font(.largeTitle.weight(.bold))
                Text("Discover matches")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GlassBackground())
            .navigationTitle("Dating")
        }
    }
}
