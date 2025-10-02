import SwiftUI

struct StatusBarOverlay: View {
    @State private var timeString: String = Self.formatter.string(from: Date())

    private static var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm"
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Text(timeString).font(.footnote.weight(.semibold))
            Image(systemName: "antenna.radiowaves.left.and.right")
            Image(systemName: "wifi")
            Spacer()
            Image(systemName: "camera.fill")
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                timeString = Self.formatter.string(from: Date())
            }
        }
        .accessibilityHidden(true)
    }
}
