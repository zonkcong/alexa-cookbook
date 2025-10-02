import SwiftUI

struct ActionRailView: View {
    let likeAction: () -> Void
    let commentAction: () -> Void
    let shareAction: () -> Void
    let audioAction: () -> Void
    let moreAction: () -> Void

    let likeState: Bool
    let likeCount: Int
    let commentCount: Int

    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 18) {
            Button(action: {
                heartScale = 0.9
                withAnimation(.easeOut(duration: 0.12)) { heartScale = 1.12 }
                withAnimation(.easeOut(duration: 0.12).delay(0.12)) { heartScale = 1.0 }
                likeAction()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: likeState ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(likeState ? Color.red : Color.white)
                        .scaleEffect(heartScale)
                    Text("\(likeCount)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(width: 44, height: 44)
                .glassChip()
                .accessibilityLabel("Like, \(likeState ? "on" : "off")")
            }

            Button(action: commentAction) {
                VStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(commentCount)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(width: 44, height: 44)
                .glassChip()
                .accessibilityLabel("Open comments")
            }

            Button(action: shareAction) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .glassChip()
                    .accessibilityLabel("Open share")
            }

            Button(action: audioAction) {
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .glassChip()
                    .accessibilityLabel("Open audio details")
            }

            Button(action: moreAction) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .glassChip()
                    .accessibilityLabel("More actions")
            }
        }
        .parallax(3)
    }
}
