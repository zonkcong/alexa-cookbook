import SwiftUI

struct ActionSheetView: View {
    var body: some View {
        VStack(spacing: 0) {
            sheetRow(title: "Save", system: "bookmark.fill")
            Divider().background(Color.white.opacity(0.15))
            sheetRow(title: "Not Interested", system: "hand.thumbsdown.fill")
            Divider().background(Color.white.opacity(0.15))
            sheetRow(title: "Report", system: "exclamationmark.triangle.fill")
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
