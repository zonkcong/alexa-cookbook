import SwiftUI

struct ProgressBarView: View {
    var progress: Double // 0..1

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.2))
                Capsule().fill(Color.white)
                    .frame(width: proxy.size.width * max(0, min(1, progress)))
            }
        }
    }
}
