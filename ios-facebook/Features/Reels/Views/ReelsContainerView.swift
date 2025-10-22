import SwiftUI

struct ReelsContainerView: View {
    @StateObject private var viewModel = ReelsViewModel()
    @State private var selection: String?

    var body: some View {
        ZStack(alignment: .top) {
            PagingReelsView(items: viewModel.items)
                .ignoresSafeArea()

            // Top overlay with glass material to match iOS look
            HStack {
                Text("Reels")
                    .font(.title.weight(.bold))
                Spacer()
                Image(systemName: "camera.fill")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.top, 8)
            .padding(.horizontal, 12)
        }
    }
}
