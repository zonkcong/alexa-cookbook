import SwiftUI

struct ShareSheetView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Share")
                    .font(.headline)
                Spacer()
            }
            .padding(16)

            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { i in
                    VStack(spacing: 6) {
                        Circle().fill(Color.white.opacity(0.2)).frame(width: 54, height: 54)
                        Text("Target")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)

            Divider().background(Color.white.opacity(0.15))

            VStack(spacing: 0) {
                sheetRow(title: "Copy Link", system: "link")
                sheetRow(title: "Report", system: "exclamationmark.triangle")
            }
        }
        .foregroundStyle(.white)
        .background(BlurredSheetBackground())
    }

    private func sheetRow(title: String, system: String) -> some View {
        Button(action: { Haptics.light() }) {
            HStack {
                Image(systemName: system)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(16)
        }
        .background(Color.white.opacity(0.0001))
    }
}
