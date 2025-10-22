import SwiftUI

struct PagingReelsView: View {
    let items: [ReelItem]

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    pageView(for: item)
                        .containerRelativeFrame(.vertical)
                }
            }
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 16) {
                Image(systemName: "hand.thumbsup.fill")
                Image(systemName: "message.fill")
                Image(systemName: "arrowshape.turn.up.right.fill")
            }
            .font(.title2)
            .padding(16)
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private func pageView(for item: ReelItem) -> some View {
        switch item {
        case .organic(let reel):
            ReelPageView(title: reel.userName, subtitle: reel.caption, color: reel.color)
        case .ad(let ad):
            AdPageView(advertiser: ad.advertiser, cta: ad.callToAction, color: ad.color)
        }
    }
}

private struct ReelPageView: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(color.gradient)
                .overlay(GlassBackground().opacity(0.2))
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline).bold()
                Text(subtitle).font(.subheadline)
            }
            .padding(16)
            .foregroundStyle(.white)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}

private struct AdPageView: View {
    let advertiser: String
    let cta: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(color.gradient)
                .overlay(GlassBackground().opacity(0.2))
                .ignoresSafeArea()

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(advertiser)
                        .font(.headline).bold()
                    Text("Sponsored")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(cta) {}
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .foregroundStyle(.white)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}
