import SwiftUI

struct CaptionBlockView: View {
    let reel: Reel
    let followAction: () -> Void
    let muteAction: () -> Void
    let audioAction: () -> Void

    @EnvironmentObject private var theme: ThemeManager
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AsyncImage(url: reel.creator.avatarURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.white.opacity(0.1)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .onTapGesture { /* Navigate to profile */ }

                VStack(alignment: .leading, spacing: 2) {
                    Text(reel.creator.displayName)
                        .font(.system(.title3, design: .default).weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(reel.creator.handle)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .onTapGesture { /* Navigate to profile */ }

                Spacer()

                FollowButton(isFollowing: reel.isFollowing, action: followAction)
            }

            Text(reel.caption)
                .font(.body)
                .foregroundStyle(.white)
                .lineLimit(expanded ? nil : 2)
                .animation(.easeOut(duration: 0.22), value: expanded)
                .onTapGesture { expanded.toggle() }

            Button(action: audioAction) {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                    Text(reel.audioTitle)
                        .lineLimit(1)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
            }
            .accessibilityLabel("Open audio details")

        }
        .padding(12)
        .background(
            GlassBackground(style: theme.isDarkMode ? .dark : .light, opacity: theme.isDarkMode ? 0.7 : 0.35)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topLeading) {
            Button(action: muteAction) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(
                        Capsule().fill(.ultraThinMaterial)
                    )
            }
            .padding(8)
            .accessibilityLabel("Toggle volume")
        }
    }
}

private struct FollowButton: View {
    let isFollowing: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.12)) { scale = 0.9 }
            withAnimation(.easeOut(duration: 0.12).delay(0.12)) { scale = 1.0 }
            withAnimation(.easeOut(duration: 0.22)) { action() }
        }) {
            Text(isFollowing ? "Following" : "Follow")
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(isFollowing ? Color.white.opacity(0.12) : Color.white)
                )
                .foregroundStyle(isFollowing ? Color.white : Color.black)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .scaleEffect(scale)
        }
        .accessibilityLabel(isFollowing ? "Following" : "Follow")
    }
}
