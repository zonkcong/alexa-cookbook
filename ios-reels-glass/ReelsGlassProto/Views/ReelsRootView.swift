import SwiftUI

struct ReelsRootView: View {
    @EnvironmentObject private var theme: ThemeManager

    @State private var selectedTab: Int = 1 // Reels active

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    PlaceholderTabView(title: "Home")
                case 1:
                    ReelsFeedView()
                case 2:
                    PlaceholderTabView(title: "Create")
                case 3:
                    PlaceholderTabView(title: "Inbox")
                case 4:
                    ProfileView()
                default:
                    ReelsFeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())

            bottomNav
        }
    }

    private var bottomNav: some View {
        HStack(spacing: 24) {
            navItem(symbol: "house.fill", index: 0)
            navItem(symbol: "play.rectangle.fill", index: 1) // Reels
            navItem(symbol: "plus.app.fill", index: 2)
            navItem(symbol: "tray.full.fill", index: 3)
            navItem(symbol: "person.crop.circle.fill", index: 4)

            Spacer().frame(width: 12)

            Toggle(isOn: $theme.isDarkMode) {
                Image(systemName: theme.isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 16, weight: .semibold))
            }
            .toggleStyle(SwitchToggleStyle(tint: .white.opacity(0.6)))
            .labelsHidden()
            .accessibilityLabel("Toggle theme")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            GlassBackground(style: theme.isDarkMode ? .dark : .light, opacity: theme.isDarkMode ? 0.7 : 0.35)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        )
        .padding(.bottom, 8)
        .parallax(4)
    }

    private func navItem(symbol: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.22)) { selectedTab = index }
            Haptics.light()
        }) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(index == selectedTab ? Color.white : Color.white.opacity(0.6))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .accessibilityLabel(index == 1 ? "Reels (selected)" : symbol)
        }
    }
}

struct PlaceholderTabView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(title)
                .foregroundStyle(.white.opacity(0.8))
                .font(.system(size: 17, weight: .semibold))
        }
    }
}
