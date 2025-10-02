import SwiftUI

struct CommentsSheetView: View {
    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
            }
            .padding(16)

            Divider().background(Color.white.opacity(0.15))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    ForEach(0..<16, id: \.self) { i in
                        HStack(alignment: .top, spacing: 12) {
                            Circle().fill(Color.white.opacity(0.2)).frame(width: 32, height: 32)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("user\(i)")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("2h")
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.6))
                                    Spacer()
                                    Button { } label: {
                                        Image(systemName: "heart")
                                            .font(.system(size: 14))
                                    }
                                }
                                Text("This is an awesome reel! 💯🔥")
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding(16)
            }

            HStack(spacing: 10) {
                TextField("Add a comment...", text: $text, axis: .vertical)
                    .lineLimit(1...3)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                Button(action: {}) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
                .disabled(text.isEmpty)
                .accessibilityLabel("Send comment")
            }
            .padding(16)
        }
        .background(BlurredSheetBackground())
        .foregroundStyle(.white)
    }
}

private struct BlurredSheetBackground: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .background(Color.black.opacity(0.6))
            .ignoresSafeArea()
    }
}
